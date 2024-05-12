/* SPDX-License-Identifier: GPL-2.0-or-later */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "buffer.h"
#include "hbios.h"
#include "sio.h"
#include "wave.h"

#define CTC1_BASE 0x60
#define CTC1_CH3 (CTC1_BASE+3)

#define CTC2_BASE 0x44
#define CTC2_CH0 (CTC2_BASE+0)
#define CTC2_CH1 (CTC2_BASE+1)
#define CTC2_CH2 (CTC2_BASE+2)
#define CTC2_CH3 (CTC2_BASE+3)

#define NEW_BUFFER_SIZE 4096
#define BUFFER_START 0x8000

// Copy handler to hi address dest_addr, optionally replacing DAC output port with output_port.
void *copy_interrupt_handler(void (*handler)(), uint16_t dest_addr, uint8_t output_port, int verbose)
{
    /* 
     * The interrupt handler has to live in the upper 32K of the address space
     * under the RomWBW architecture. Copy the handler. The copy stops when it
     * sees an 0xc9 for a RET instruction. But it's possible that there is
     * an 0xc9 for other reasons, so we should be smarter about this.
     */

    int count = 1000, i;
    uint8_t *src = (uint8_t *) handler;
    uint8_t *dest = (uint8_t *)(dest_addr);
    int replace_port = 0;
    for (i = 0; i < count; i++) { 
        dest[i] = replace_port ? output_port : src[i];
        /* Look for an OUT instruction, followed by the 0xBB DAC port. Replace it with chosen port. */
        replace_port = ((src[i] == 0xd3) && (src[i+1] == 0xbb));
        if (verbose && replace_port) { 
            printf("Replacing output port with 0x%02x\n", output_port);
        }
        if (dest[i] == 0xc9) break; /* return instruction */
     }
     if (verbose) printf("Copied %d bytes of the interrupt handler. Used port 0x%02x\n", i, output_port);
     return (void *) dest;
}

// Initialize CTC2 interrupt and Channel 3 timer. Disable system tick.
void setup_timers(int base_vector, uint32_t samples_per_second, int verbose)
{
    /* Disable the system timer tick while playing back. */
    outp(CTC1_CH3, 0x03); /* reset channel */    

    /* Set the interrupt vector, which can only be done by writing to Channel 0. */
    outp(CTC2_CH0, 0x03); /* reset channel */
    outp(CTC2_CH0, base_vector * 2); 

    /* Compute time constant. CTC2 runs at 7,372,800 Hz and we program the prescaler to divide by 16. */
    uint32_t clk_div_16 = 7372800 / 16;
    float time_const_f = (float) clk_div_16 / (float) samples_per_second;
    long time_const = (long) (time_const_f + 0.5);
    if (verbose) printf("Computed time constant is %f or %ld\n", time_const_f, time_const);
    if (time_const > 255) { 
        fprintf(stderr, "Warning: computed time constant %ld is too big!!\n", time_const);
    }
    /* Set up Channel 3 to generate the interrupt at the required rate. */
    outp(CTC2_CH3, 0x03); /* reset channel. */
    outp(CTC2_CH3, 0x85); /* enable interrupt, select timer mode, divide-by-16, auto trigger. */
    outp(CTC2_CH3, (uint8_t) time_const); 
}

// After playback, stop CTC2 channel 3, restore old interrupt handler and restore system tick.
void restore_timers(int vector, void (*old_handler)())
{
    // Turn off the CTC2 CH3 interrupt by resetting the channel.
    outp(CTC2_CH3, 0x03);

    // Restore the old interrupt handler
    set_interrupt(vector, old_handler);

    // Restore the system timer tick
    outp(CTC1_CH3, 0xD7);
    outp(CTC1_CH3, 72);
}

void print_hbios_info(void)
{
    int version = get_hbios_version();
    int platform = get_hbios_platform();
    int intr_info = get_hbios_intr_info();
    int interrupt_mode = (intr_info >> 8) & 0xFF;
    int ivt_size = intr_info & 0xFF;

    printf("HBIOS Version = 0x%04x, Platform = 0x%02x, interrupt mode = %d, IVT size = %d\n", 
        version, platform, interrupt_mode, ivt_size);
}

struct Config { 
    int verbose;
    int serial;
    int print_usage;
    char *arg1;
    char *prog_name;
};

// Parse command line arguments into Config struct.
void parse_config(struct Config *cfg, int argc, char **argv)
{
    cfg->verbose = 0;
    cfg->serial = 0;
    cfg->print_usage = 0;
    cfg->arg1 = NULL;
    cfg->prog_name = "dactone";

    for (int i = 1; i < argc; i++) {
        char *arg = argv[i];
        if (arg[0] == '-') { 
            char option = arg[1];
            switch (option) { 
                case 'V': 
                    cfg->verbose = 1; 
                    printf("Verbose output enabled.\n");
                    break;
                case 'S':
                    cfg->serial = 1;
                    printf("Serial output enabled.\n");
                    break;
                case 'H':
                    cfg->print_usage = 1;
                    break;
                default:
                    fprintf(stderr, "Error: unknown option '%c'\n", option);
                    cfg->print_usage = 1;
            }
        } else { 
            cfg->arg1 = arg;
        }
    }
}

// Print a help message.
void print_usage(struct Config *cfg)
{
    fprintf(stderr, "usage: %s [-v] [-s] frequency\n", cfg->prog_name);
    fprintf(stderr, "     -v         Show verbose output.\n");
    fprintf(stderr, "     -s         Send samples (four seconds) to SIO0 Channel A instead of the DAC.\n");
    fprintf(stderr, "\n     frequency  The frequency of the tone to generate.\n");
}

// Weird field order is for interrupt handler efficiency. 
struct BufInfo { 
    uint16_t head;
    uint16_t end;
    uint16_t start;
    uint16_t passes;
};

void new_interrupt_handler(void);

// Use the HBIOS framework on install an interrupt handler. Copy handler to high address first.
void *setup_interrupt_handler(int vector, void (*handler)(void), uint16_t hi_addr, uint8_t output_port, int verbose)
{
    /* Copy the code for the interrupt handler to hi_addr. */
    void *hi_interrupt_handler = copy_interrupt_handler(handler, hi_addr, output_port, verbose);
    void *old_handler = set_interrupt(vector, hi_interrupt_handler);
    return old_handler;
}

// When looking to periodic samples, are the 'window' samples close enough (not more than diff of 1)?
static int is_close_enough(uint8_t *buffer, uint16_t index, int window)
{   
     for (int i = 0; i < window; i++) {
          int diff = abs(buffer[i] - buffer[index+i]);
          if (diff > 1) return 0;
     }
     return 1;
}

// Look for the last occurance of a sample sequence in a buffer.
static uint16_t get_last_index(uint8_t *buffer, uint32_t samples_per_second, int window)
{
    uint16_t result = 0;
     for (int i = 1; i < samples_per_second-window; i++) {
          if (is_close_enough(buffer, i, window)) {
               result = i;
          }
     }
     return result;
}

void generate_tone(struct Config *cfg, int base_vector)
{
    int samples_per_second = 8000;
    int duration = 4;

    struct BufInfo *bufinfo = (struct BufInfo *) BUFFER_INFO;

    bufinfo->start = bufinfo->head = BUFFER_START;
    bufinfo->end = BUFFER_START + NEW_BUFFER_SIZE;
    bufinfo->passes = 0;
    struct WavetableFixed table;

    double frequency = atof(cfg->arg1);

    /* Fill the interrupt handler buffer with samples from the wave table. */
    init_wavetable(&table, 1024, frequency, samples_per_second);
    get_table_samples(&table, (uint8_t *) bufinfo->start, NEW_BUFFER_SIZE);

    /* Find the latest matching start of the waveform. */
    int check_window = 8;
    uint16_t last_index = get_last_index((uint8_t *) bufinfo->start, samples_per_second, check_window);
    if (cfg->verbose) printf("last index = %u\n", last_index);
    bufinfo->end = BUFFER_START + last_index;

    uint32_t total_samples = duration * samples_per_second;
    uint32_t number_of_passes = (total_samples / last_index) + 1;
    uint32_t samples_remaining = number_of_passes * last_index;

    if (cfg->serial) {
        // If serial debug is enabled, send a WAV header first.
        struct SimpleWAV wav;
        initWAV(&wav, samples_per_second, samples_remaining);
        char buffer[128];
        int header_size = getWAVHeader(buffer, &wav);
        sio_write_buffer(buffer, header_size);
        printf("Sending about four seconds of samples to the serial port.\n");
    } else {
        printf("Sending samples for %7.2f Hz sine wave to the DAC.\n", frequency);
        printf("Press a key to exit...\n");
    }

    /* Start playing! */
    uint16_t next_pass = 1;
    int done = 0;
    setup_timers(base_vector, samples_per_second, cfg->verbose);
    
    while (!done) {
        /* Wait for the interrupt handler to finish a pass. */
        while (bufinfo->passes != next_pass)
            ;
        samples_remaining -= last_index;
        if (cfg->serial) { 
            if (samples_remaining == 0) done = 1;
        } else { 
            if (bdos(CPM_ICON, 0) != 0) done = 1;
        }
        if (!done) {
            outp(LED_PORT, next_pass & 1 ? 2 : 1);
            if (cfg->serial) printf("pass %d\n", next_pass-1);
            next_pass++;
        }
    }
    /* Turn off the CTC2 CH3 interrupt by resetting the channel. ASAP. */
    outp(CTC2_CH3, 0x03);

    if (cfg->serial) outp(LED_PORT, 0);

    printf("Exiting...\n");
}

int main(int argc, char **argv)
{
    struct Config cfg;
    parse_config(&cfg, argc, argv);

    if (cfg.print_usage) { 
        print_usage(&cfg);
        exit(1);
    }

    if (cfg.serial) { 
        init_sio_8n1(SIO0_PORTA);
        printf("SIO0 PORT A initialized.\n");
    }

    if (cfg.verbose) {
        int *topram = (int *)(0x7);
        printf("Top of RAM seems to be 0x%04x\n", *topram);
        print_hbios_info();
    }

    if (cfg.arg1== NULL) {
        fprintf(stderr, "usage: dactone.com frequency\n");
        exit(1);
    }

    /* 
     * CTC2 will occupy vectors 8-11 while this program is running.
     * We will use vector 11 for Channel 3 interrupts.
     */
    int base_vector = 8;
    //void *old_handler = setup_interrupt_handler(base_vector + 3, interrupt_handler, 0xC100, cfg.verbose);
    void *old_handler = setup_interrupt_handler(base_vector + 3, new_interrupt_handler, 0xC100, 
        cfg.serial ? SIO0A_DAT : DAC_PORT, cfg.verbose);

    generate_tone(&cfg, base_vector);
    /* All done */
    restore_timers(base_vector + 3, old_handler);
    return 0;
}

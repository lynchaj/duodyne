/* SPDX-License-Identifier: GPL-2.0-or-later */

#include <stdio.h>
#include <string.h>
#include "wave.h"
#include "wavetable_sin_1024.h"

static uint32_t read_uint32(FILE *fp)
{
    uint32_t result = 0;
    uint16_t lower, upper;
    fread(&lower, sizeof(lower), 1, fp);
    fread(&upper, sizeof(upper), 1, fp);
    result = upper;
    result <<= 16;
    result |= lower;
    return result;
}

static uint16_t read_uint16(FILE *fp)
{
    uint16_t result;
    fread(&result, sizeof(result), 1, fp);
    return result;
}

static void read_string(FILE *fp, char *buf, int size)
{
    fread(buf, size, 1, fp);
    buf[size] = 0;
}

static int put_uint16(char*buf, uint16_t v)
{
    char *p = buf;
    *p++ = v & 0xFF;
    *p++ = (v >> 8) & 0xFF;
    return p - buf;
}

static int put_uint32(char *buf, uint32_t v)
{
    char *p = buf;
    *p++ = v & 0xFF;
    *p++ = (v >> 8) & 0xFF;
    *p++ = (v >> 16) & 0xFF;
    *p++ = (v >> 24) & 0xFF;
    return p - buf;
}

void initWAV(struct SimpleWAV *wav, uint32_t samples_per_second, uint32_t datasize)
{
     wav->ck0size = datasize + 36;
     wav->formatSize = 16;
     wav->formatTag = 1;
     wav->nChannels = 1;
     wav->nSamplesPerSec = samples_per_second;
     wav->dataRate = samples_per_second;
     wav->blockAlign = 1;
     wav->bitsPerSample = 8;
     wav->dataSize = datasize;
}

int getWAVHeader(char *buf, struct SimpleWAV *wav)
{
    char *p = buf;
    strncpy(p, "RIFF", 4);
    p += 4;
    p += put_uint32(p, wav->ck0size);
    strncpy(p, "WAVE", 4);
    p += 4;
    strncpy(p, "fmt ", 4);
    p += 4;
    p += put_uint32(p, wav->formatSize);
    p += put_uint16(p, wav->formatTag);
    p += put_uint16(p, wav->nChannels);
    p += put_uint32(p, wav->nSamplesPerSec);
    p += put_uint32(p, wav->dataRate);
    p += put_uint16(p, wav->blockAlign);
    p += put_uint16(p, wav->bitsPerSample);
    strncpy(p, "data", 4);
    p += 4;
    p += put_uint32(p, wav->dataSize);
    return p-buf;
}

int parseWAVHeader(FILE *fp, struct SimpleWAV *wav)
{
    read_string(fp, wav->ck0ID, 4);
    wav->ck0size = read_uint32(fp);
    read_string(fp, wav->waveID, 4);
    read_string(fp, wav->formatID, 4);
    wav->formatSize = read_uint32(fp);    
    
    if (wav->formatSize != 16) { 
        fprintf(stderr, "Unsupported format chunk size of %d. Only size of 16 is supported.\n", wav->formatSize);
        return 0;
    }
    wav->formatTag = read_uint16(fp);
    wav->nChannels = read_uint16(fp);
    wav->nSamplesPerSec = read_uint32(fp);
    wav->dataRate = read_uint32(fp);
    wav->blockAlign = read_uint16(fp);
    wav->bitsPerSample = read_uint16(fp);
    read_string(fp, wav->dataID, 4);
    wav->dataSize = read_uint32(fp);
    return 1;
}

void dumpWAVheader(struct SimpleWAV *wav)
{
    printf("ck0ID = '%s'\n", wav->ck0ID);
    printf("ck0size = %lu\n", wav->ck0size);
    printf("WAVEID = '%s'\n", wav->waveID);
    printf("ck1ID = '%s'\n", wav->formatID);
    printf("ck1size = %lu\n", wav->formatSize);
    printf("formatTag = %d\n", wav->formatTag);
    printf("nChannels = %d\n", wav->nChannels);
    printf("nSamplesPerSec = %lu\n", wav->nSamplesPerSec);
    printf("dataRate = %lu\n", wav->dataRate);
    printf("blockAlign = %d\n", wav->blockAlign);
    printf("bitsPerSample = %d\n", wav->bitsPerSample);
    printf("ck2ID = '%s'\n", wav->dataID);
    printf("ck2size = %lu\n", wav->dataSize);
}

void init_wavetable(struct WavetableFixed *table, int table_len, double frequency, uint32_t samples_per_second)
{
    
    double incr = (double) table_len * frequency / (double) samples_per_second;
    table->fixed_incr = (uint16_t)(incr * (double)(1 << 6));
    table->fixed_index = 0;
}

void get_table_samples(struct WavetableFixed *table, uint8_t *buffer, uint16_t len)
{
    for (uint16_t count = 0; count < len; count++) {
        uint16_t f_index = table->fixed_index >> 6;
        buffer[count] = wavtable_sin_1024[f_index];
        table->fixed_index += table->fixed_incr;
    }
}
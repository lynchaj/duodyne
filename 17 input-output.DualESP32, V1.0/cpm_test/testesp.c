#define CONIO_VT100
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <ctype.h>
#include <cpm.h>

#define ESP0 $9C       // ESP0 IO PORT
#define ESP1 $9D       // ESP1 IO PORT
#define ESP_STATUS $9E // ESP status IO PORT

int cpm_ver;

int esp0_outbyte(char c) __naked
{
    // SEND BYTE TO ESP0
    __asm
    pop bc      //return address
    pop hl      //character to print in l
    push hl
    push bc
    ld a,l      // char to send is now in a
    PUSH AF
    LD C,0
OUTESP0_1:
    INC C
    JP Z,OUTESP0_TIMEOUT
    IN A,(ESP_STATUS)  //GET STATUS
    AND 2               // Is ESP0 BUSY ?
    JP NZ, OUTESP0_1    // IF BUSY WAIT
    POP AF
    OUT(ESP0),A         //SEND BYTE
    LD C,$E0
OUTESP0_2:
    INC C
    JP Z,OUTESP0_3
    IN A,(ESP_STATUS)   // GET STATUS
    AND 2               // Is ESP0 BUSY ?
    JP Z, OUTESP0_2     // IF NOT BUSY WAIT
OUTESP0_3:
    RET
OUTESP0_TIMEOUT:
    POP AF
    RET
    __endasm;
}


// Allows user to send some characters to the display
send_char_test()
{
    char ch=' ';
    printf("\e[2J\e[0m\e[H");
    printf("                          Nhodyne ESP32 IO board test\n\r\n\r");
    printf("                          \e[1m Output single char to VGA \e[0m\n\r\n\r");
    printf("Type characters to be echoed to the ESP display.  Press 'ESC' to return to menu\n\r");
    while(ch!='\e')
    {
        printf("\e[15;10HKey->\e[1m");
        ch = getchar();
        printf("\e[0m");

        if(ch!='\e')
        {
            esp0_outbyte(1);    // send opcode '1'
            esp0_outbyte(ch);   // send char
        }
    }
}

// Sends 100 chars, very quickly
send_100_char_test()
{
    for(int x=0;x<100;x++)
    {
        esp0_outbyte(1);    // send opcode '1'
        esp0_outbyte('*');   // send char
    }

}

// Sends a string (fancy, eh?)
send_string_test()
{

    char *test = "\n\r\e[40;31mH\e[40;32mI \e[40;33mF\e[40;34mR\e[40;35mOM \e[40;36mD\e[40;37mU\e[40;92mO\e[40;93mD\e[40;94mY\e[40;95mN\e[40;96mE\e[40;97m.\n\r\0";
    char *c =test;
    esp0_outbyte(2);    // send opcode '2'
    while (*c != '\0') esp0_outbyte(*++c);
}


menu_page1()
{
    char ch;

    printf("\e[2J\e[0m\e[H");

    printf("                          Nhodyne ESP32 IO board test\n\r\n\r");

    printf("  \e[1m1\e[0m. Output single char to VGA                  \e[1mH\e[0m. Set Resolution\n\r");
    printf("  \e[1m2\e[0m. Output 100 single chars to VGA             \e[1mI\e[0m. Load Font\n\r");
    printf("  \e[1m3\e[0m. Output string to VGA                       \e[1mJ\e[0m. Copy Rectangle\n\r");
    printf("  \e[1m4\e[0m. Get Keystroke                              \e[1mK\e[0m. Draw Bitmap\n\r");
    printf("  \e[1m5\e[0m. Get Key Buffer Length                      \e[1mL\e[0m. Draw Char\n\r");
    printf("  \e[1m6\e[0m. Set Cursor visibility                      \e[1mM\e[0m. Draw Ellipse\n\r");
    printf("                                                \e[1mN\e[0m. Draw Glyph\n\r");
    printf("  \e[1m7\e[0m. Set serial baud rate                       \e[1mO\e[0m. Draw Line\n\r");
    printf("  \e[1m8\e[0m. Set serial mode                            \e[1mP\e[0m. Draw Rectangle\n\r");
    printf("  \e[1m9\e[0m. Serial TX single char                      \e[1mQ\e[0m. Fill Ellipse\n\r");
    printf("  \e[1mA\e[0m. Serial TX string                           \e[1mR\e[0m. Fill Rectangle\n\r");
    printf("  \e[1mB\e[0m. Serial RX                                  \e[1mS\e[0m. Get Pixel\n\r");
    printf("  \e[1mC\e[0m. Serial Buffer Length                       \e[1mT\e[0m. Invert Rectangle\n\r");
    printf("                                                \e[1mU\e[0m. Draw Line To\n\r");
    printf("  \e[1mD\e[0m. Play String                                \e[1mV\e[0m. Move Cursor To\n\r");
    printf("  \e[1mE\e[0m. Play Sound                                 \e[1mW\e[0m. Scrol\n\r");
    printf("  \e[1mF\e[0m. Set Volume                                 \e[1mX\e[0m. Set Brush Color\n\r");
    printf("  \e[1mG\e[0m. Clear Screen                               \e[1mY. Menu Page TWO\e[0m\n\r");
    printf("  \e[1mZ. Exit Program\e[0m\n\r");

    for(;;)
    {
        printf("\e[23;1HSelection->\e[1m");
        ch = getchar();
        printf("\e[0m");
        ch = toupper(ch);

        switch (ch)
        {
            case '1':
                send_char_test();
                return 1;
            case '2':
                send_100_char_test();
                break;
            case '3':
                send_string_test();
                break;
            case 'Z':
                printf("\e[2J\e[0m\e[H\e[0m\n\r\n\r");
                exit(0);
        }
    }
}

main()
{
    cpm_ver = bdos(CPM_VERS, 0);

    if ((cpm_ver == 0) || (cpm_ver > 0x2F))
        printf("\nWARNING: unsupported CP/M version detected: %x.%x\n\n", cpm_ver >> 4, cpm_ver & 0xf);

    for(;;)
        menu_page1();



    return 0;
}

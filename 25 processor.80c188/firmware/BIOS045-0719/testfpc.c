/*************************************************************************
*  testfpc.c   for the N8VEM  SBC-188
**************************************************************************
*
*   This version watcom C
* 
*
*
*************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <i86.h>
#include <sys/stat.h>


void fpDisplayBuffer(char *);
int fpGetKey(void);
int fpScanKey(void);
void fpDecodeDisplay(char *,unsigned short,unsigned short);

char buffer[8]={0x01,0x4E,0x67,0x3E,0x00,0x3E,0x67,0x01};

void main()
{
    union REGS r;
    char result=0;

    printf("Begin Front Panel Test Program\n");


    fpDisplayBuffer(buffer);
    
    fpGetKey();

    fpDecodeDisplay(buffer,0xab,00);
    fpDecodeDisplay(buffer,0xcd,01);
    fpDecodeDisplay(buffer,0xef,02);
    fpDecodeDisplay(buffer,0x00,03);

    do {
      result=fpGetKey();

      fpDecodeDisplay(buffer,result,03);

    } while(result!=0x12);



    exit(0);
}


void fpDisplayBuffer(char *buffer)
  {
    union REGS r;
    /* ah = 51h, int 15h "display buffer" */
    r.x.ax = 0x5100;
    r.x.dx = (unsigned short)buffer;
    int86(0x15, &r, &r);
  }


int fpGetKey(void)
  {
    union REGS r;
    /* ah= 0x53, int 15h "GET KEY" */
    r.x.ax = 0x5300;
    int86(0x15, &r, &r);

    return r.x.ax & 0xff;
  }

int fpScanKey(void)
  {
    union REGS r;
    /* ah= 0x54, int 15h "GET KEY" */
    r.x.ax = 0x5400;
    int86(0x15, &r, &r);

    return r.x.ax & 0xff;
  }

void fpDecodeDisplay(char *buffer,unsigned short value,unsigned short position)
  {
    union REGS r;
    /* ah = 52h, int 15h "decode display" */
    r.x.ax = 0x5200+(value & 0xff);  /* al= value */
    r.x.dx = (unsigned short)buffer; /*Buffer*/
    r.x.cx = position & 0x03;   /* offset */
    int86(0x15, &r, &r);
  }


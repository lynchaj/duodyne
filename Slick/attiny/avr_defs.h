/*************************************************************************
**************************************************************************
**                                                                      **
**  Project:   myAVRlib                                                 **
**  Title:     Usefull Definitions                                      **
**  File:      avrdefs.h                                                **
**  Date:      14.10.2003                                               **
**  Version:   1.02                                                     **
**  Plattform: WinAVR-20060421 & AVR Studio 4.12.498 & STK500           **
**                                                                      **
**  Created by Gerald Ebert                                             **
**                                                                      **
**************************************************************************
*************************************************************************/

#ifndef _AVR_DEFS_H_
  #define _AVR_DEFS_H_

#include <avr\io.h>
#include <avr\interrupt.h>
#include <avr\pgmspace.h>

//========================================================================
// Standard Type Definitions
//========================================================================

typedef  signed char            BOOL;
typedef  char                   CHAR;
typedef  prog_char              PCHAR;
typedef  unsigned char          BYTE;
typedef  prog_uchar             PBYTE;
typedef  signed short           INT;
typedef  unsigned short         WORD;
typedef  WORD                   PWORD PROGMEM;
typedef  signed long            LONG;
typedef  unsigned long          DWORD;
typedef  void *                 LPVOID;
typedef  char *                 LPSTR;
typedef  const char *           LPCSTR;
typedef  const prog_char *      LPCPSTR;
typedef  unsigned char *        LPBYTE;
typedef  const unsigned char *  LPCBYTE;
typedef  PBYTE *                LPCPBYTE;
typedef  WORD *                 LPWORD;
typedef  const WORD *           LPCWORD;

//========================================================================
// Standard Type Helper Defines
//========================================================================

#define TRUE  (1)
#define FALSE (0)

#ifndef NULL
  #define NULL ((void *)0)
#endif

#define countof(array) (sizeof(array)/sizeof(array[0]))

#define GET_PCHAR(address)   pgm_read_byte(address)
#define GET_PBYTE(address)   pgm_read_byte(address)
#define GET_PWORD(address)   pgm_read_word(address)

#define BV(bitnr)  (1<<bitnr)
#define NOP { __asm__ __volatile__ ("nop \n\t" :: ); }
#define CLI { __asm__ __volatile__ ("cli \n\t" :: ); }
#define SEI { __asm__ __volatile__ ("sei \n\t" :: ); }

#define CBI(_reg, _bit) { __asm__ __volatile__ ( "cbi %0,%1 \n\t" : :"I" (_SFR_IO_ADDR(_reg)), "I" (_bit) ); }
#define SBI(_reg, _bit) { __asm__ __volatile__ ( "sbi %0,%1 \n\t" : :"I" (_SFR_IO_ADDR(_reg)), "I" (_bit) ); }

//========================================================================
// Additional Port Defines
//========================================================================

#define DDR(x) (*(&x - 1))         // Address of input register of port x
#define PIN(x) (*(&x - 2))         // Address of data direction register of port x

//========================================================================
//========================================================================
// POWER MANAGEMENT AND SLEEP MODES
//========================================================================
//========================================================================

#define SLEEP_MODE_IDLE         0

#if defined(SM) && !defined(SM0) && !defined(SM1) && !defined(SM2)
  #define SLEEP_MODE_PWR_DOWN     BV(SM)
  #define SLEEP_MODE_MASK         BV(SM)
#elif !defined(SM) && defined(SM0) && defined(SM1) && !defined(SM2)
  #define SLEEP_MODE_ADC          BV(SM0)
  #define SLEEP_MODE_PWR_DOWN     BV(SM1)
  #define SLEEP_MODE_PWR_SAVE     (BV(SM0) | BV(SM1))
  #define SLEEP_MODE_MASK         (BV(SM0) | BV(SM1))
#elif !defined(SM) && defined(SM0) && defined(SM1) && defined(SM2)
  #define SLEEP_MODE_ADC          BV(SM0)
  #define SLEEP_MODE_PWR_DOWN     BV(SM1)
  #define SLEEP_MODE_PWR_SAVE     (BV(SM0) | BV(SM1))
  #define SLEEP_MODE_STANDBY      (BV(SM1) | BV(SM2))
  #define SLEEP_MODE_EXT_STANDBY  (BV(SM0) | BV(SM1) | BV(SM2))
  #define SLEEP_MODE_MASK         (BV(SM0) | BV(SM1) | BV(SM2))
#else
  #error "No SLEEP mode defined for device."
#endif

#ifdef SMCR
  #define Set_Sleep_Mode(mode) (SMCR = ((SMCR & ~SLEEP_MODE_MASK) | (mode)))
#else
  #define Set_Sleep_Mode(mode) (MCUCR = ((MCUCR & ~SLEEP_MODE_MASK) | (mode)))
#endif

#define SLEEP { MCUCR |= BV(SE);   __asm__ __volatile__ ("sleep" "\n\t" :: );   MCUCR &= ~BV(SE); }

//========================================================================
//========================================================================
// WATCHDOG TIMER
//========================================================================
//========================================================================

#define WDT_16MS     0
#define WDT_32MS     1
#define WDT_65MS     2
#define WDT_125MS    3
#define WDT_250MS    4
#define WDT_500MS    5
#define WDT_1SEC     6
#define WDT_2SEC     7

#define WDT { __asm__ __volatile__ ("wdr \n\t" :: ); }

#if defined(__AVR_ATmega48__) || defined(__AVR_ATmega88__) || defined(__AVR_ATmega168__)

  #define WDTI_Enable(Timeout)           \
     { __asm__ __volatile__ (            \
       "in __tmp_reg__,__SREG__   \n\t"  \
       "cli                       \n\t"  \
       "wdr                       \n\t"  \
       "sts %0,%1                 \n\t"  \
       "out __SREG__,__tmp_reg__  \n\t"  \
       "sts %0,%2                 \n\t"  \
      : /* no outputs */                 \
      : "M" (_SFR_MEM_ADDR(WDTCSR)),     \
        "r" (BV(WDCE) | BV(WDE)),        \
        "r" ((BYTE)((Timeout&0x07) | BV(WDIE))) \
      : "r0" ); }

  #define WDTI_Disable()                 \
	  { __asm__ __volatile__ (            \
		 "in __tmp_reg__,__SREG__   \n\t"  \
       "cli                       \n\t"  \
       "sts %0,%1                 \n\t"  \
       "sts %0,__zero_reg__       \n\t"  \
       "out __SREG__,__tmp_reg__  \n\t"  \
      : /* no outputs */                 \
      : "M" (_SFR_MEM_ADDR(WDTCSR)),     \
        "r" (BV(WDCE) | BV(WDE))         \
      : "r0" ); }

#else

  #define WDTI_Enable(Timeout)           \
	  { __asm__ __volatile__ (            \
       "in __tmp_reg__,__SREG__   \n\t"  \
       "cli                       \n\t"  \
       "wdr                       \n\t"  \
       "out %0,%1                 \n\t"  \
       "out __SREG__,__tmp_reg__  \n\t"  \
       "out %0,%2"                       \
      : /* no outputs */                 \
      : "I" (_SFR_IO_ADDR(WDTCSR)),      \
        "r" (BV(WDCE) | BV(WDE)),        \
        "r" ((BYTE)((Timeout&0x07) | BV(WDIE))) \
      : "r0" ); }

  #define WDTI_Disable()                 \
	  { __asm__ __volatile__ (            \
       "in __tmp_reg__,__SREG__   \n\t"  \
       "cli                       \n\t"  \
       "out %0,%1"                \n\t"  \
       "out %0,__zero_reg__       \n\t"  \
       "out __SREG__,__tmp_reg__  \n\t"  \
      : /* no outputs */                 \
      : "I" (_SFR_IO_ADDR(WDTCSR)),      \
        "r" (BV(WDCE) | BV(WDE))         \
      : "r0" ); }

#endif

//========================================================================

#endif // _AVR_DEFS_H_

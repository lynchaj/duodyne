/*************************************************************************
**************************************************************************
**                                                                      **
**  Project:   ATtiny13 Monoflop                                        **
**  Title:     ATtiny13 Monoflop                                        **
**  File:      t13monoflop.c                                            **
**  Date:      16.04.2007                                               **
**  Version:   0.80                                                     **
**  Plattform: WinAVR-20060421 & AVR Studio 4.12.498 & STK500           **
**                                                                      **
**  Created by Gerald Ebert                                             **
**  Modified for N8VEM ECB-RAF2011 by Dr. Wolfgang Kabatzke             **
**                                                                      **
**************************************************************************
 Version   Description/Changes

   8.00    Projekt 11/2011 

**************************************************************************
*************************************************************************/

#include "avr_defs.h"

//========================================================================
// Hardwiring the ATtiny13
//========================================================================
/*
                             ____  ____
               /RESET (PB5) -|   \/   |- (Vcc)
                   nc (PB3) -|        |- (PB2) Activity LED
                   nc (PB4) -|        |- (PB1) Ext. Activity
                      (GND) -|________|- (PB0) nc

*/

//========================================================================
// Defines
//========================================================================

//------------------------------
// External signals

#define ISC0MASK            (BV(ISC01)|BV(ISC00))
#define ISC0RISE            (BV(ISC01)|BV(ISC00))
#define ISC0FALL            (BV(ISC01))

#define LEDctrl_EXT         BV(PB1)
#define LEDctrl_OUT         BV(PB2)
#define LEDctrl_PORT        PORTB
#define LEDctrl_DDR         DDRB

// --- Set timer clock prescaler to 1/256. Set timer register to generate a 25 Hz interrupt
#define LEDctrl_INIT        { TCCR0B = 0x04; }
#define LEDctrl_ENABLE      { CLI;   LEDctrl_PORT |= LEDctrl_OUT;   TCNT0 = 0xFF-0xBB;   TIFR0 |= BV(TOV0); \
                                     TIMSK0 |= BV(TOIE0);   SEI; }
#define LEDctrl_DISABLE     { CLI;   LEDctrl_PORT &= ~LEDctrl_OUT;   TIMSK0 &= ~BV(TOIE0);   SEI;}

//========================================================================
//========================================================================
// Interrupt Sevice Routines
//========================================================================
//========================================================================

//------------------------------------------------------------------------
// Default Interrupt Sevice Routine
//------------------------------------------------------------------------

EMPTY_INTERRUPT(__vector_default);

//------------------------------------------------------------------------
// External Interrupt 1 Interrupt Sevice Routine
//------------------------------------------------------------------------

// Any other controller can indicate an activity over the INT0 pin.

ISR(INT0_vect)
{
   LEDctrl_ENABLE;                               // Switch activity led on
}


//------------------------------------------------------------------------
// TIMER0 Output Compare A Match Interrupt Sevice Routine
//------------------------------------------------------------------------

ISR(TIM0_OVF_vect)
{
   LEDctrl_DISABLE;                              // Switch activity led off
}

//========================================================================
//========================================================================
// MAIN
//========================================================================

int main (void)
{
   DDRB  = 0xFF;    PORTB = 0xFF;

   Set_Sleep_Mode(SLEEP_MODE_IDLE);              // Initialize Sleep Mode for AVR
   LEDctrl_INIT;                                 // Initialze TIMER0 for activity led control

   LEDctrl_DDR  &= ~LEDctrl_EXT;                 // Activity pin as input
   LEDctrl_PORT &= ~LEDctrl_OUT;                 // LED off
   MCUCR = (MCUCR & (~ISC0MASK)) | ISC0FALL;     // Set INT0 on falling edge 
   GIMSK |= BV(INT0);                            // Enable external INT0

   SEI;                                          // Enable all used ISR

   while ( TRUE )
   {
   }
}

//========================================================================

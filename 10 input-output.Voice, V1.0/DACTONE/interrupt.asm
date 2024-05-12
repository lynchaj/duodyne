; SPDX-License-Identifier: GPL-2.0-or-later

	INCLUDE "buffer.h"

    GLOBAL _new_interrupt_handler

_new_interrupt_handler:
    DI

    ; BC := buffer head pointer.
    LD  BC,(BUF_HEAD)

    ; Get the byte from the head pointer and send it out.
    LD  A,(BC)
    OUT (DAC_PORT),A

    ; Bump the head pointer.
    INC BC
    
    ; Now we need to see if we need to wrap the head pointer back
    ; to the beginning of the buffer.
    LD HL,(BUF_END)

    AND A   ; clear the carry

    ; Are we at the end?
    SBC HL,BC
    JR  NZ,SKIP  ; no, keep going

    ; Yes, at the end and need to wrap. Increment the 'passes' counter
    LD BC,(BUF_PASSES)
    INC BC
    LD (BUF_PASSES),BC

    ; Wrap the head pointer back to the start of the buffer.
    LD BC,(BUF_START)
SKIP:
    ; Save the incremented head pointer (wrapped if necessary) back out.
    LD (BUF_HEAD),BC

    RET

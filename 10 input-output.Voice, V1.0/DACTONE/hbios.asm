; SPDX-License-Identifier: GPL-2.0-or-later

	GLOBAL _get_hbios_intr_info
	GLOBAL _get_hbios_version
	GLOBAL _get_hbios_platform

	GLOBAL _get_interrupt
	GLOBAL _set_interrupt


; int get_hbios_intr_info(void)

_get_hbios_intr_info:
  LD B,$FC
  LD C,$0
  CALL $FFF0
  LD HL,DE
  RET
 
; int get_hbios_version(void)

_get_hbios_version:
   LD B,$F1
   CALL $FFF0
   LD HL,DE
   RET
    
; int get_hbios_platform(void)

_get_hbios_platform:
   LD B,$F1
   CALL $FFF0
   LD BC,0 
   LD C,L
   LD HL,BC
   RET

; int get_interrupt(int ivt_num)
_get_interrupt:
    LD HL,2
    ADD HL,SP
    LD E,(HL)

    LD B,$FC
    LD C,$10
    CALL $FFF0
    RET

; returns previous handler
; int set_interrupt(int ivt_num, void (*handler)(void))
_set_interrupt:
    LD HL,4  ; ivt_num pointer
    ADD HL,SP
    LD E,(HL)

    LD HL,2  ; handler pointer
    ADD HL,SP
    LD C,(HL)
    INC HL
    LD B,(HL)
    LD HL,BC

    LD B,$FC
    LD C,$20
    CALL $FFF0
    RET

; em187a.asm

	even
override dw     es_over, cs_over, ss_over, ds_over
fp0tab  dw      fp0,fp1,fp2,fp3,fp4,fp5,fp6,fp7

;                                 opA opB
fmt12t  dw      genFADD         ; 000 000       R32
        dw      genFMUL         ; 000 001       R32
        dw      genFCOM         ; 000 010       R32
        dw      genFCOMP        ; 000 011       R32
        dw      genFSUB         ; 000 100       R32
        dw      genFSUBR        ; 000 101       R32
        dw      genFDIV         ; 000 110       R32
        dw      genFDIVR        ; 000 111       R32

        dw      genFLD          ; 001 000       R32
        dw      unimplemented   ; 001 001
        dw      genFST          ; 001 010       R32
        dw      genFSTP         ; 001 011       R32
        dw      gFLDENV         ; 001 100       14 bytes
        dw      gFLDCW          ; 001 101
        dw      gFSTENV         ; 001 110       14 bytes
        dw      gFSTCW          ; 001 111

        dw      genFADD         ; 010 000       I32
        dw      genFMUL         ; 010 001       I32
        dw      genFCOM         ; 010 010       I32
        dw      genFCOMP        ; 010 011       I32
        dw      genFSUB         ; 010 100       I32
        dw      genFSUBR        ; 010 101       I32
        dw      genFDIV         ; 010 110       I32
        dw      genFDIVR        ; 010 111       I32

        dw      genFLD          ; 011 000       I32
        dw      unimplemented   ; 011 001
        dw      genFST          ; 011 010       I32
        dw      genFSTP         ; 011 011       I32
        dw      unimplemented   ; 011 100
        dw      FLDtmp          ; 011 101
        dw      unimplemented   ; 011 110
        dw      FSTPtmp         ; 011 111

        dw      genFADD         ; 100 000       R64
        dw      genFMUL         ; 100 001       R64
        dw      genFCOM         ; 100 010       R64
        dw      genFCOMP        ; 100 011       R64
        dw      genFSUB         ; 100 100       R64
        dw      genFSUBR        ; 100 101       R64
        dw      genFDIV         ; 100 110       R64
        dw      genFDIVR        ; 100 111       R64

        dw      genFLD          ; 101 000       R64
        dw      unimplemented   ; 101 001
        dw      genFST          ; 101 010       R64
        dw      genFSTP         ; 101 011       R64
        dw      gFRSTOR         ; 101 100       94 bytes
        dw      unimplemented   ; 101 101
        dw      gFSAVE          ; 101 110       94 bytes
        dw      gFSTSW          ; 101 111

        dw      genFADD         ; 110 000       I16
        dw      genFMUL         ; 110 001       I16
        dw      genFCOM         ; 110 010       I16
        dw      genFCOMP        ; 110 011       I16
        dw      genFSUB         ; 110 100       I16
        dw      genFSUBR        ; 110 101       I16
        dw      genFDIV         ; 110 110       I16
        dw      genFDIVR        ; 110 111       I16

        dw      genFLD          ; 111 000       I16
        dw      unimplemented   ; 111 001
        dw      genFST          ; 111 010       I16
        dw      genFSTP         ; 111 011       I16
        dw      gFBLD           ; 111 100
        dw      FLDi64          ; 111 101
        dw      gFBSTP          ; 111 110
        dw      FSTPi64         ; 111 111

fmt03t  dw      FADDrr              ; 0000      & FADDP
        dw      FLD_i_to_0          ; 0001      & FFREE (R==1)
        dw      FMULrr              ; 0010
        dw      gFXCH               ; 0011
        dw      FCOMrr              ; 0100
        dw      FST_0_to_i          ; 0101      & FNOP
        dw      FCOMPrr             ; 0110      & FCOMPP
        dw      FSTP_0_to_i         ; 0111
        dw      FSUBi               ; 1000      ST - ST(i)
        dw      FSTSW_ax            ; 1001
        dw      FSUB0               ; 1010      ST(i) - ST
        dw      unimplemented       ; 1011
        dw      FDIVi               ; 1100      ST / ST(i)
        dw      unimplemented       ; 1101
        dw      FDIV0               ; 1110      ST(i) / ST
        dw      unimplemented       ; 1111

fmt04t  dw      gFCHS               ; 00000
        dw      gFABS               ; 00001
        dw      unimplemented       ; 00010
        dw      unimplemented       ; 00011
        dw      gFTST               ; 00100
        dw      gFXAM               ; 00101
        dw      unimplemented       ; 00110
        dw      unimplemented       ; 00111
        dw      gFLD1               ; 01000
        dw      gFLDL2T             ; 01001
        dw      gFLDL2E             ; 01010
        dw      gFLDPI              ; 01011
        dw      gFLDLG2             ; 01100
        dw      gFLDLN2             ; 01101
        dw      gFLDZ               ; 01110
        dw      unimplemented       ; 01111

        dw      gF2XM1              ; 10000
        dw      gFYL2X              ; 10001
        dw      gFPTAN              ; 10010
        dw      gFPATAN             ; 10011
        dw      gFXTRACT            ; 10100
        dw      unimplemented       ; 10101
        dw      gFDECSTP            ; 10110
        dw      gFINCSTP            ; 10111
        dw      gFPREM              ; 11000
        dw      gFYL2XP1            ; 11001
        dw      gFSQRT              ; 11010
        dw      unimplemented       ; 11011
        dw      gFRNDINT            ; 11100
        dw      gFSCALE             ; 11101
        dw      unimplemented       ; 11110
        dw      unimplemented       ; 11111

fmt05t  dw      gFENI               ; 00000
        dw      gFDISI              ; 00001
        dw      gFCLEX              ; 00010
        dw      gFINIT              ; 00011
        dw      unimplemented       ; 00100
        dw      unimplemented       ; 00101
        dw      unimplemented       ; 00110
        dw      unimplemented       ; 00111
        dw      unimplemented       ; 01000
        dw      unimplemented       ; 01001
        dw      unimplemented       ; 01010
        dw      unimplemented       ; 01011
        dw      unimplemented       ; 01100
        dw      unimplemented       ; 01101
        dw      unimplemented       ; 01110
        dw      unimplemented       ; 01111

        dw      unimplemented       ; 10000
        dw      unimplemented       ; 10001
        dw      unimplemented       ; 10010
        dw      unimplemented       ; 10011
        dw      unimplemented       ; 10100
        dw      unimplemented       ; 10101
        dw      unimplemented       ; 10110
        dw      unimplemented       ; 10111
        dw      unimplemented       ; 11000
        dw      unimplemented       ; 11001
        dw      unimplemented       ; 11010
        dw      unimplemented       ; 11011
        dw      unimplemented       ; 11100
        dw      unimplemented       ; 11101
        dw      unimplemented       ; 11110
        dw      unimplemented       ; 11111


	even
vecFLD  dw  load_R32, load_I32, load_R64, load_I16  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; FLD of i16, i32, r32, and r64
;   Floating point load
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFLD:
        call    alloc
        mov     si,bx
        mov     bx,FMbits           ;get format mask
        and     bl,ch
;;;        push    OFFSET restore_segs
        push    restore_segs
  cs    jmp     [vecFLD+bx]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; do overall emulator initialization -- FINIT instruction
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFINIT:
        mov     byte [codes], C3
;;;        mov     byte [masks], 7Fh      ;mask all interrupts
;;;        mov     byte [ctrl], 03H
	mov	word [Control],037Fh
        xor     ax,ax           ;get Zero
%if 1
	push	ds
	pop	es
	mov	di,Status
	mov	cx,nFINIT
	rep	stosw
%else
; clear CS:IP, data DS:PTR, instruct
	mov	[Status],ax	; Zap flags & codes
        mov     [enables],al      ;mask all interrupts
        mov     [tos],al
        mov     [round],ax        ;set round to nearest
%endif
        mov     cx,8
;;;        mov     si,offset fp0
        mov     si, fp0
gFINIT1:
        mov     byte [si+tag], tag_empty
        add     si, lenAccum
        loop    gFINIT1
; fall into

; clear exceptions

gFCLEX:
        mov     byte [flags], 0
        jmp     restore_segs



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   RRsetup -- setup for ST(i) - ST(0) operations
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RRsetup:	;	 proc    near

        mov     bl,cl           ;get source register
        call    regptr          ;get pointer to source
        mov     si,bx           ;source ptr to SI
        xor     bx,bx           ;get ST(0)
        call    regptr          ;get pointer to destination
        mov     di,bx           ;dest. ptr to DI
        test    ch,Rbit         ;test reversal bit
        jz      RR010           ;don't reverse
        xchg    si,di           ;reverse source and destination
RR010:
        ret

;RRsetup endp



;  something is rotten in Source or Destination

FA200:              ;;;; ****
        pop     si                  ; clean up the stack for now
        mov     byte [si+tag], tag_invalid
        push    Iexcept             ;signal exception
        call    exception
        jmp     FA100


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Add register - register
;       SI and DI point to operands
;       BX is place to put result, may be same as SI or DI
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
do_add:		;      proc    near
        push    bx              ;save place to which to move result
        mov     al,[si+tag]     ;get source tag
        or      al,[di+tag]     ;or on destination tag
        test    al, tag_infin   ;test for infinity, empty, or invalid
        jnz     FA200           ;if not both valid, something needs checking
; both tags are valid
        mov     ax,[si+expon]   ;get source exponent
        cmp     ax,[di+expon]   ;get dest exponent
        jge     FA040           ;jump if source exponent is bigger
        xchg    si,di           ;source has bigger or equal exponent
FA040:
        mov     bx,di           ;smaller exponent
        mov     cx,[si+expon]   ;larger exponent
        sub     cx,[bx+expon]   ;smaller exponent

        mov     ah,[si+sign]    ;get sign of source
        xor     ah,[bx+sign]    ;get sign of destination
        jz      FA070           ;go do add if signs are the same
; signs are different
        call    vloadshift      ;get right shifted mantissa
%if BIG
        mov     di,[si+mantis+6]
        sub     di,cx
        mov     cx,[si+mantis+4]
        sbb     cx,bx
        mov     bx,[si+mantis+2]
        sbb     bx,ax
        mov     ax,[si+mantis]
        sbb     ax,dx
        xchg    dx,di               ; AX:BX:CX:DX
%else
        mov     bx,[si+mantis+2]
        sub     bx,ax
        mov     ax,[si+mantis]
        sbb     ax,dx               ; AX:BX
%endif
        pop     di                  ;get where to put it
        mov     bp,[si]             ;get sign & exponent
        mov     [di],bp             ;store at destination
        mov     si,[si+expon]       ;get result exponent
        jnc     FA050
; carry is set, invert the sign, and negate the mantissa
        xor     byte [di+sign],01h
%if BIG
        neg     dx
        cmc
        not     cx
        adc     cx,0
        not     bx
        adc     bx,0
%else
        neg     bx
        cmc
%endif
        not     ax
        adc     ax,0                ;end of negate
FA050:
; will have to normalize the result
; result exponent is currently in SI
        xchg    si,di               ;swap exponent to DI, dest to SI
        jmp     normalize_and_exit

;  Actually add the mantissas

FA070:
        call    vloadshift      ;get right shifted mantissa
%if BIG
        add     cx,[si+mantis+6]
        adc     bx,[si+mantis+4]
        adc     ax,[si+mantis+2]
%else
        add     ax,[si+mantis+2]
%endif
        adc     dx,[si+mantis]
        pop     di
        mov     bp,[si]             ;get sign & tag
        mov     [di],bp             ;store them
; 
        mov     si,[si+expon]       ;get exponent
        jnc     FA080
        rcr     dx,1                ;carry bit to DX
        rcr     ax,1
%if BIG
        rcr     bx,1
        rcr     cx,1
%endif
        inc     si                  ;increment exponent
FA080:
        mov     [di+expon],si       ;store result exponent
        mov     [di+mantis],dx      ;store result
        mov     [di+mantis+2],ax
%if BIG
        mov     [di+mantis+4],bx
        mov     [di+mantis+6],cx
%endif
        xchg    si,di               ;return pointer in SI
FA100:
        ret

;do_add      endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FADD    ST,ST(i)        R=0, P=0
;   FADD    ST(i),ST        R=1, P=0
;   FADDP   ST(i),ST        R=1, P=1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FADDrr:
        call    RRsetup         ;get source and destination reg. ptrs
        mov     bx,di           ;BX is where final result will go
        call    do_add          ;do the register to register add
        jmp     test_pop        ;test stack for pop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSUB    ST,ST(i)        R=0, P=0
;   FSUBR   ST(i),ST        R=1, P=0
;   FSUBRP  ST(i),ST        R=1, P=1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FSUBi:
        mov     bl,cl           ;get ST(i)
        call    regptr          ;BX is ST(i) pointer
        mov     si,bx           ;SI is ST(i) pointer
        xor     bx,bx           ;get ST
        call    regptr          ;BX is ST pointer
        mov     di,bx           ;DI is ST pointer
        xor     byte [si+sign],01    ;invert ST(i) sign
        test    ch,Rbit         ;see who gets the result
        jnz     FSUBi01         ;ST(i) does
; ST gets the result
        push    si              ;save ST(i) pointer
        call    do_add          ;get the answer
        pop     si              ;restore ST(i) pointer
        xor     byte [si+sign],01    ;invert ST(i) sign
        jmp     restore_segs    ;no pop is possible
FSUBi01:
        mov     bx,si           ;result to ST(i)
;;;     push    OFFSET test_pop ;pop is possible
        push    test_pop	;pop is possible
        jmp     do_add          ;will return to 'test_pop'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSUBR   ST,ST(i)        R=0, P=0
;   FSUB    ST(i),ST        R=1, P=0
;   FSUBP   ST(i),ST        R=1, P=1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FSUB0:
        mov     bl,cl           ;get ST(i)
        call    regptr          ;BX is ST(i) pointer
        mov     si,bx           ;SI is ST(i) pointer
        xor     bx,bx           ;get ST
        call    regptr          ;BX is ST pointer
        mov     di,bx           ;DI is ST pointer
        xor     byte [di+sign],01h   ;invert ST sign
        test    ch,Rbit         ;see if ST(i) gets result
        jnz     FSUB001         ;
; ST gets the result
;;;     push    OFFSET restore_segs ;no pop is possible
        push    restore_segs	;no pop is possible
        jmp     do_add          ;will return to exit sequence

FSUB001:    ; ST(i) will get the result
        mov     bx,si           ;ST(i) gets the result
        push    di              ;save pointer to ST
        call    do_add          ;do the register to register add
        pop     di              ;restore pointer
        xor     byte [di+sign],01h   ;restore the original sign
        jmp     test_pop        ;possible pop of ST


; end em187a.asm

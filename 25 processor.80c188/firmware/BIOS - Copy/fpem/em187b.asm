; em187b.asm

	even
vecFST  dw  store_R32, store_I32, store_R64, store_I16  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FST     mem
;
;       ES:DI is the destination address
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFST:
        xor     bx,bx               ;get ST(0)
        call    regptr              ;   pointer to BX
        mov     si,bx               ;put source pointer in SI
        mov     bx,FMbits           ;get format mask
        and     bl,ch

;;;     push    OFFSET restore_segs
        push    restore_segs
  cs    jmp     [vecFST+bx]          ;dispatch to proper store routine
        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSTP    mem
;
;       ES:DI is the destination address
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFSTP:
        xor     bx,bx               ;get ST(0)
        call    regptr              ;   pointer to BX
        mov     si,bx               ;put source pointer in SI
        mov     bx,FMbits           ;get format mask
        and     bl,ch
        push    si                  ;save pointer to ST(0)
  cs    call    [vecFST+bx]          ;dispatch to proper store routine
        pop     bx                  ;get ST(0) pointer
        jmp     pop_stack           ;pop stack with BX set

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSTCW   mem         ; store Control Word
;
;       ES:DI is the destination address
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFSTCW:
        mov     ax,word [Control]
  es    mov     [di],ax
        jmp     restore_segs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLDCW   mem         ; load Control Word
;
;       ES:DI is the source address
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFLDCW:
  es    mov     ax,word [di]
        mov     [Control],ax        ;set up new control word
        not     al                  ;interrupt masks become interrupt enables
        and     al,3Fh              ;mask bits which may cause interrupt
        mov     [enables],al        ;store interrupt enables

        mov     al,ah               ;extract rounding bits
        and     ax,0Ch              ; **
        shr     ax,1                ;get 0, 2, 4 or 6
        mov     [round],ax          ;store rounding index
        jmp     restore_segs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSTSW   mem         ; store Status Word (8087, 80287, 80387)
;   FSTSW   AX          ; store Status Word to AX (not on 8087)
;
;       ES:DI is the destination address
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FSTSW_ax:
        call    get_status          ;get Status to AX
        mov     [v7_ax+bp],ax
        jmp     restore_segs
gFSTSW:
        call    get_status          ;get Status to AX
  es    mov     word [di],ax
        jmp     restore_segs

;
;   Get Status word to AX
;
get_status:		;  proc    near
        mov     ax,[Status]
        mov     dh,[tos]            ;get top of stack pointer
        shl     dh,3
        or      ah,dh               ;combine TOS with condition codes
        test    al,[enables]        ;test for interrupts enabled
        jz      GS010

        or      al,Estatus        ;set error summary status
GS010:
        ret
;get_status  endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLD     ST(i)       push operand onto stack from another register
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLD_i_to_0:
        mov     bl,cl               ;source register
        call    regptr
        mov     si,bx               ;source pointer to si
        call    alloc
        mov     di,bx               ;destination pointer to di
;;;        cld
%if 0
            REPT   lenAccum/2
        movsw
            ENDM
%else
	%rep	lenAccum/2
	movsw
	%endrep
%endif
        jmp     restore_segs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FST     ST(i)       store ST(0) into another stack register
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FST_0_to_i:
        call    RRsetup             ;setup SI and DI
;;;        cld
%if 0
            REPT   lenAccum/2
        movsw
            ENDM
%else
	%rep	lenAccum/2
	movsw
	%endrep
%endif
        jmp     restore_segs

FSTP_0_to_i:
        call    RRsetup             ;setup SI and DI
;;;        cld
        push    si
%if 0
            REPT   lenAccum/2
        movsw
            ENDM
%else
	%rep	lenAccum/2
	movsw
	%endrep
%endif
; now pop the stack top
        pop     bx
        jmp     pop_stack


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FXCH    ST(i)       exchange register with ST(0)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFXCH:
        call    RRsetup             ;setup SI and DI
        mov     cx,lenAccum/2       ;get count of words to exchange
;;;        cld                         ;set to work forward
	even
xch000:
        lodsw                       ;load AX and increment SI
        mov     dx,[di]             ;get DX from DI
        mov     [si-2],dx           ;remember SI has already been incremented
        stosw                       ;store AX and increment DI
        loop    xch000              ; loop back until done

        jmp     restore_segs



%if BIG
FP_1:
;FP_1    ACCUM   <tag_valid, 0, 0, 8000H, 0, 0, 0>
	db	tag_valid, 0
	dw	0, 8000H, 0, 0, 0
%else
FP_1:
;FP_1    ACCUM   <tag_valid, 0, 0, 8000H, 0>
	db	tag_valid, 0
	dw	0, 8000H, 0
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLD1        load the constant 1.0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFLD1:
;;;     mov     si,OFFSET   FP_1
        mov     si, FP_1
        jmp     short gFLDconstant

%if BIG
FP_L2T:
;FP_L2T    ACCUM   <tag_valid, 0, 1, 0D49Ah, 0784Bh, 0CD1Bh, 08AFEh>
	db	tag_valid, 0
	dw	1, 0D49Ah, 0784Bh, 0CD1Bh, 08AFEh
%else
FP_L2T:
;FP_L2T    ACCUM   <tag_valid, 0, 1, 0D49Ah, 0784Ch>
	db	tag_valid, 0
	dw	1, 0D49Ah, 0784Ch
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLDL2T        load the constant  LOG2(10)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFLDL2T:
;;;     mov     si,OFFSET   FP_L2T
        mov     si, FP_L2T
        jmp     short gFLDconstant

%if BIG
FP_L2E:
;FP_L2E    ACCUM   <tag_valid, 0, 0, 0B8AAh, 03B29h, 05C17h, 0F0BCh>
	db	tag_valid, 0
	dw	0, 0B8AAh, 03B29h, 05C17h, 0F0BCh
%else
FP_L2E:
;FP_L2E    ACCUM   <tag_valid, 0, 0, 0B8AAh, 03B29h>
	db	tag_valid, 0
	dw	0, 0B8AAh, 03B29h
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLDL2E        load the constant  LOG2(E)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFLDL2E:
;;;     mov     si,OFFSET   FP_L2E
        mov     si, FP_L2E
        jmp     short gFLDconstant

%if BIG
FP_PI:
;FP_PI    ACCUM   <tag_valid, 0, 1, 0C90Fh, 0DAA2h, 02168h, 0C235h>
	db	tag_valid, 0
	dw	1, 0C90Fh, 0DAA2h, 02168h, 0C235h
%else
FP_PI:
;FP_PI    ACCUM   <tag_valid, 0, 1, 0C90Fh, 0DAA2h>
	db	tag_valid, 0
	dw	1, 0C90Fh, 0DAA2h
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLDPI        load the constant  PI
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFLDPI:
        mov     si,  FP_PI
        jmp     short gFLDconstant

%if BIG
FP_LG2:
;FP_LG2    ACCUM   <tag_valid, 0, -2, 09A20h, 09A84h, 0FBCFh, 0F799h>
	db	tag_valid, 0
	dw	-2, 09A20h, 09A84h, 0FBCFh, 0F799h
%else
FP_LG2:
;FP_LG2    ACCUM   <tag_valid, 0, -2, 09A20h, 09A85h>
	db	tag_valid, 0
	dw	-2, 09A20h, 09A85h
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLDLG2        load the constant LOG10(2)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFLDLG2:
        mov     si,  FP_LG2
        jmp     short gFLDconstant

%if BIG
FP_LN2:
;FP_LN2    ACCUM   <tag_valid, 0, -1, 0B172h, 017F7h, 0D1CFh, 079ACh>
	db	tag_valid, 0
	dw	-1, 0B172h, 017F7h, 0D1CFh, 079ACh
%else
FP_LN2:
;FP_LN2    ACCUM   <tag_valid, 0, -1, 0B172h, 017F8h>
	db	tag_valid, 0
	dw	-1, 0B172h, 017F8h
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLDLN2        load the constant LN(2)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFLDLN2:
        mov     si,  FP_LN2
        jmp     short gFLDconstant

%if BIG
FP_Z:
;FP_Z    ACCUM   <tag_zero, 0, exp_of_FPzero, 0, 0, 0, 0>
	db	tag_zero, 0
	dw	exp_of_FPzero, 0, 0, 0, 0
%else
FP_Z:
;FP_Z    ACCUM   <tag_zero, 0, exp_of_FPzero, 0, 0>
	db	tag_zero, 0
	dw	exp_of_FPzero, 0, 0
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLDZ        load the constant 0.0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFLDZ:
        mov     si,  FP_Z
gFLDconstant:
        call    alloc           ;allocate space on the stack
        mov     di,bx
;;;        cld
        mov     ax,cs
        mov     ds,ax
		%rep lenAccum/2
        movsw
		%endrep
        jmp     restore_segs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Name:  vloadshift
;   Desc:  get the mantissa pointed to by BX, and shift right by
;          the amount in CX.  Return result in  DX:AX[:BX:CX]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vloadshift:		;  proc    near
%if BIG
        cmp     cx,63       ;shift of 63 is the max for 64-bit mantissa
        ja      vlds100     ;go return zero

        push    si          ;counter will be here for 64-bit mantissa
%else
        cmp     cx,31       ;shift of 31 is the max for 32-bit mantissa
        ja      vlds100     ;go return zero
%endif
        mov     dx,[bx+mantis]      ;first word of mantissa
        mov     ax,[bx+mantis+2]    ;second word
%if BIG
        mov     si,[bx+mantis+6]    ;fourth word of mantissa
        mov     bx,[bx+mantis+4]    ;third word of mantissa
%endif
        cmp     cl,16               ;compare to 16
        jb      vlds020             ;skip 16 bit shifts if below 16
%if BIG
vlds010:
        mov     si,bx               ;shift by 16 bits
        mov     bx,ax               ;**
%endif
        mov     ax,dx               ; **
        xor     dx,dx               ;  **
        sub     cl,16
%if BIG
        cmp     cl,16               ;compare if another 16-bit shift is needed
        ja      vlds010             ;loop back if above zero
%endif
vlds020:            ; check for 8 bit shift
        cmp     cl,8            
        jb      vlds040
%if BIG
        xchg    cx,si           ;do a long 8 bit shift
        mov     cl,ch
        mov     ch,bl
        mov     bl,bh
        mov     bh,al
        xchg    cx,si
%endif
        mov     al,ah           ;do the short portion of an 8-bit shift
        mov     ah,dl
        mov     dl,dh
        xor     dh,dh
        sub     cl,8
vlds040:
        jcxz    vlds090         ;may have been reduced this far
        even
vlds050:
        shr     dx,1            ;short right shift of 1 bit
        rcr     ax,1
%if BIG
        rcr     bx,1            ;long extension, right shift 1 bit
        rcr     si,1
%endif
        loop    vlds050
vlds090:
%if BIG
        mov     cx,si           ;result goes back in DX:AX:BX:CX
        pop     si              ;restore saved register
%endif
vlds099:
        ret
; shift was so big, zero mantissa is the result
vlds100:
        xor     dx,dx
        xor     ax,ax
%if BIG
        xor     bx,bx
        xor     cx,cx
%endif
        jmp     vlds099

;vloadshift  endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; allocate FP stack element
;
;   return with [bx] pointing at stack top
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	even
alloc:		;   proc    near
        mov     bl,[tos]        ;get top of stack
        dec     bl
        and     bx,7            ;mask to 3 bits
        mov     [tos],bl
        shl     bx,1            ;index words
  cs    mov     bx, [fp0tab+bx]  ; get accumulator array pointer
        cmp     byte [bx+tag], tag_empty
        jne     alloc9
        ret
alloc9:
        or      byte [codes],C1        ;flag overflow
        push    errStkOverflow+Sflag+Iexcept
        call    exception
        ret

;alloc   endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; regptr -- get pointer to ST(i), and check for validity
;  enter with reg in low 3 bits of bx
;  return with pointer in [bx]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        even
regptr:		;	  proc    near
        add     bl,[tos]        ;get index to actual register
        and     bx,7            ;mask to 3 bits
        shl     bx,1            ;index words
  cs    mov     bx, [fp0tab+bx]  ; get offset into accumulator array
        ret
;regptr  endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; load IEEE 4-byte real to accumulator
;       es:di   points to value to load
;       si      points to accumulator to receive value
; uses: ax & dx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_R32:	;	    proc    near
  es    mov     dx, word [di+2]     ;get exponent
        xor     ax,ax
        shl     dx,1            ; sign goes to carry
        rcl     al,1            ; sign goes to AL
        mov     [si+sign], al
        mov     al,dh           ; ax is biased exponent
        or      ax,ax
        jz      lr3201
        cmp     al,255          ; test for max exponent
        je      lr3211
        mov     byte [si+tag], tag_valid

        sub     ax,127          ; get correct exponent
        mov     [si+expon], ax
        stc
        rcr     dl,1            ; put fractional part on mantissa
  es    mov     ax, word [di]
        mov     dh,dl
        mov     dl,ah
        mov     [si+mantis], dx
        mov     ah,al
        xor     al,al
        mov     word [si+mantis+2], ax
%if  BIG
lr3200:
        xor     ax,ax
        mov     [si+mantis+4], ax           ; zero out low words
        mov     [si+mantis+6], ax
%endif
        jmp     lr3299

; biased exponent was 0
lr3201:
        or      al,dl
  es    or      ax,word [di]
        jnz     lr3202           ; not a real zero
; got real zero
        mov     byte [si+tag], tag_zero
        mov     word [si+expon], exp_of_FPzero
lr32015:
        mov     [si+mantis], ax
        mov     [si+mantis+2], ax
%if  BIG
        mov     [si+mantis+4], ax
        mov     [si+mantis+6], ax
%endif
        jmp     lr3299

; not a real zero -- actually a denormal
lr3202:
        push    Dexcept
        call    exception

  es    mov     ax,word [di]     ; get second word
        shl     ax,1
        adc     dl,0                ;move bit into dl
lr3203:
        dec     dh              ; count shifts
        shl     ax,1            ; try to normalize
        rcl     dl,1
        jnc     lr3203

        rcr     dl,1
        rcr     ax,1            ; bit has been put back
        xchg    dl,ah
        xchg    dl,al
        mov     [si+mantis], ax
        xchg    dl,ah
        xor     al,al
        mov     [si+mantis+2], ax
        mov     al,dh
        cbw
        sub     ax,127          ; get correct exponent
        mov     [si+expon], ax
        mov     byte [si+tag], tag_valid           
%if BIG
        jmp     lr3200
%else
        jmp     lr3299
%endif

        
; biased exponent was 255 -- possible infinity
lr3211:
        xor     ax,ax
  es    or      dl, byte [di]
  es    or      dl, byte [di+1]
        jnz     lr3215              ; if not zero in packed for, NaN
        mov     byte [si+tag], tag_infin
lr3213:
        mov     word [si+expon], exp_of_FPinf
        jmp     lr32015

lr3215:
        mov     byte [si+tag], tag_invalid
        push    Iexcept
        call    exception

        jmp     lr3213

lr3299:
        ret
;load_R32    endp

; end em187b.asm

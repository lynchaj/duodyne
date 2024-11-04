; em187c.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; load 2-byte integer to accumulator
;       es:di   points to value to load
;       si      points to accumulator to receive value
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_I16:		;    proc    near
  es    mov     ax,word [di]            ;get 16 bit word
        xor     bx,bx
        mov     di,15                   ;initial exponent
        jmp     short L3200
;load_I16    endp


LDindef:
        push    Iexcept
        call    exception
        jmp     short L3204

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; load 4-byte integer to accumulator
;       es:di   points to value to load
;       si      points to accumulator to receive value
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_I32:		;    proc    near
  es    mov     bx,[di]          ;get low order
  es    mov     ax,[di+2]
        mov     di,31               ;initial exponent
L3200:
%if BIG
        xor     cx,cx               ;if 64 bit mantissas,
        xor     dx,dx               ;  zero out the low order
%endif
        mov     byte [si+sign],0
        or      ax,ax           ;test sign of integer
        jge     L3204
; is negative, must negate
        inc     byte [si+sign]       ;indicate negative value
        not     ax
%if BIG
        xor     bp,bp           ;get a zero
        not     bx
        not     cx
        neg     dx
        cmc
        adc     cx,bp
        adc     bx,bp
        adc     ax,bp
%else
        neg     bx
        cmc
        adc     ax,0
%endif
        js      LDindef
L3204:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Normalize the value in AX:BX:[CX:DX], 
;   adjusting the exponent in di
;
;   Tag, exponent, and mantissa are stored at DS:SI if normal number
;   Tag and sign stored, too, if result is zero
;
;   BP is destroyed
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
normalize_and_exit:
        mov     bp,ax               ;test for zero result first
        or      bp,bx               ;
%if BIG
        or      bp,cx
        or      bp,dx
%endif
        jz      NM060               ;result of FADD is zero
        mov     byte [si+tag], tag_valid
NM055:
        or      ax,ax               ;test for hi zero
        jnz     short NM056
        xchg    bx,ax
%if BIG
        xchg    cx,bx
        xchg    dx,cx
%endif
        sub     di,16               ;decrease exponent
        jmp     NM055
NM056:
        or      ah,ah               ;test for hi zero byte
        jnz     short   NM057
        xchg    al,ah
        xchg    bh,al
        xchg    bl,bh
%if BIG
        xchg    ch,bl
        xchg    cl,ch
        xchg    dh,cl
        xchg    dl,dh
%endif
        sub     di,8                ;adjust exponent
NM057:
        test    ah,80H              ;test for normalized bit
        jnz     NM058
%if BIG
        shl     dx,1                ;normalize a bit at a time
        rcl     cx,1
        rcl     bx,1
%else
        shl     bx,1
%endif
        rcl     ax,1
        dec     di                  ;decrease exponent
        jmp     NM057

NM058:  ; non-zero result
        mov     [si+expon],di       ;store new exponent
        mov     [si+mantis],ax
        mov     [si+mantis+2],bx
%if BIG
        mov     [si+mantis+4],cx
        mov     [si+mantis+6],dx
%endif
        ret


NM060:  ; zero result
        mov     byte [si+tag], tag_zero      ;result was zero
        mov     [si+sign],al            ;all regs are zero
        mov     di,exp_of_FPzero        ;zero has funny exponent
        jmp     NM058

;load_I32    endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FILD    qword ptr QJ        load 64-bit integer
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLDi64:
        call    alloc                   ;get new ST
        mov     si,bx                   ;SI will receive value
        push    restore_segs     ; call to load_I64 returns to r_s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; load 8-byte integer to accumulator
;       es:di   points to value to load
;       si      points to accumulator to receive value
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_I64:		;    proc    near
  es    mov     dx,[di]      ;get lowest order
  es    mov     cx,[di+2]
  es    mov     bx,[di+4]
  es    mov     ax,[di+6]
        mov     di,63           ;initial exponent

        mov     byte [si+tag], tag_valid
        mov     byte [si+sign],0
        or      ax,ax           ;test sign of integer
        jge     L6404
; is negative, must negate
        inc     byte [si+sign]       ;indicate negative value
        xor     bp,bp           ;get a zero
        not     ax
        not     bx
        not     cx
        neg     dx
        cmc
        adc     cx,bp
        adc     bx,bp
        adc     ax,bp
        jns     L6404
; loading integer indefinite
        push    Iexcept
        call    exception
L6404:
        mov     bp,ax               ;test for zero result first
        or      bp,bx               ;
        or      bp,cx
        or      bp,dx
        jz      L6460               ;result is zero
L6455:
        or      ax,ax               ;test for hi zero
        jnz     short   L6456
        xchg    bx,ax
        xchg    cx,bx
        xchg    dx,cx
        sub     di,16               ;decrease exponent
        jmp     L6455
L6456:
        or      ah,ah               ;test for hi zero byte
        jnz     short   L6457
        xchg    al,ah
        xchg    bh,al
        xchg    bl,bh
        xchg    ch,bl
        xchg    cl,ch
        xchg    dh,cl
        xchg    dl,dh
        sub     di,8                ;adjust exponent
L6457:
        test    ah,80H              ;test for normalized bit
        jnz     L6458
        shl     dx,1                ;normalize a bit at a time
        rcl     cx,1
        rcl     bx,1
        rcl     ax,1
        dec     di                  ;decrease exponent
        jmp     L6457

L6458:  ; non-zero result
        mov     [si+expon],di       ;store new exponent
        mov     [si+mantis],ax
        mov     [si+mantis+2],bx
%if BIG
        mov     [si+mantis+4],cx
        mov     [si+mantis+6],dx
%endif
        ret


L6460:  ; zero result
        mov     byte [si+tag], tag_zero      ;result was zero
        mov     [si+sign],al            ;all regs are zero
        mov     di,exp_of_FPzero        ;zero has funny exponent
        jmp     L6458

;load_I64    endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Store a REAL 32-bit value
;
;       ES:DI is the destination address
;       SI is the source address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
store_R32:		;   proc    near
        cmp     byte [si+tag], tag_zero  ;test for problem tags
        jae     str3270             ;jump if not tag_valid
        mov     ax,[si+expon]       ;get exponent
        mov     bx,[si+mantis]      ;get high order mantissa
        mov     cx,[si+mantis+2]    ;get lower order mantissa
        add     cx,0080H            ;round to nearest for now
        adc     bx,0                ;continue
        jc      str3250             ;jump if carry
str3210:
        sub     ax,-127             ;bias the exponent
        jle     str3279             ;go store +0.0
        cmp     ax,255              ;check for overflow
        jae     str3285             ;overflow
        mov     dh,al               ;exponent to DH
        mov     dl,bh               ;hi-mantissa to DL
        shl     dl,1                ;hide hi-bit
        or      dl,[si+sign]        ;get sign in low order
        ror     dx,1                ;get high word of result
  es    mov     [di+2],dx        ;store it
        mov     cl,bl               ;form low word
        xchg    cl,ch               ;swap bytes
  es    mov     [di],cx          ;store low word of result
str3299:
        ret
; 
; carry occurred on round to nearest; fix the exponent and result
str3250:
        rcr     bx,1                ;put hi-bit back
        inc     ax                  ;increment the exponent
        jmp     str3210             ;CX is zero
str3270:
        ja      str3280             ;jump if not tag_zero
str3275:
; store signed zero
        xor     ax,ax
str3276:
        mov     bl,[si+sign]        ;get the sign
        shr     bl,1
        rcr     ax,1                ;move sign to hi-bit
str3277:
  es    mov     [di+2],ax        ;
        xor     ax,ax               ;zap it out
  es    mov     [di],ax          ;store low zero
        jmp     str3299

; store absolute zero
str3279:
        push    Uexcept             ;underflow
        call    exception

        xor     ax,ax               ;zap hi-word
        jmp     str3277

; tag is not zero
str3280:
        cmp     byte [si+tag], tag_infin ;test for infinity
        je      str3286
        ja      str3290
; store signed infinity
str3285:
        push    Oexcept             ;overflow
        call    exception
str3286:
        mov     ax,0FF00h           ;following code will store sign
        jmp     str3276             ;go put on sign

; store indefinite
str3290:
        mov     ax,0FFC0h           ;get indefinite code
        push    Iexcept             ;invalid operation
        call    exception
        jmp     str3277             ;go store it
;store_R32   endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FCHS        change the sign of ST
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFCHS:
        xor     bl,bl               ;get ST pointer
        call    regptr              ; in BX
        xor     byte [bx+sign],1         ;invert the sign
        jmp     restore_segs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FABS        absolute value of ST
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFABS:
        xor     bl,bl               ;get ST pointer
        call    regptr              ; in BX
        mov     byte [bx+sign],0         ;clear the sign
        jmp     restore_segs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FADD    mem         add memory to ST
;
;       ES:DI is pointer to memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFADD:
        mov     si,Areg      ;load first into the Areg
        mov     bx,FMbits           ;get format mask
        and     bl,ch
  cs    call    [vecFLD+bx]          ;get the input argument
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     di,bx               ;DI is destination, SI is source
;  call to  do_add  returns to  restore_segs
        push    restore_segs
        JMP     do_add


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSUB    mem         ST := ST - mem
;
;       ES:DI is pointer to memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFSUB:
        mov     si,Areg      ;load first into the Areg
        mov     bx,FMbits           ;get format mask
        and     bl,ch
  cs    call    [vecFLD+bx]          ;get the input argument
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     di,bx               ;DI is destination, SI is source
        xor     byte [si+sign],01h       ;invert the sign
;  call to  do_add  returns to  restore_segs
        push    restore_segs
        JMP     do_add


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSUBR   mem         ST := mem - ST
;
;       ES:DI is pointer to memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFSUBR:
        mov     si,Areg      ;load first into the Areg
        mov     bx,FMbits           ;get format mask
        and     bl,ch
  cs    call    [vecFLD+bx]          ;get the input argument
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     di,bx               ;DI is destination, SI is source
        xor     byte [di+sign],01h       ;invert the sign

;  call to  do_add  returns to  restore_segs
        push    restore_segs
        JMP     do_add


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FDECSTP         decrement the stack pointer
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFDECSTP:
        dec     byte [tos]
        and     byte [tos],7           ;mask to 3 bits
        jmp     restore_segs




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FINCSTP         increment the stack pointer
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFINCSTP:
        inc     byte [tos]
        and     byte [tos],7           ;mask to 3 bits
        jmp     restore_segs



        even
%if BIG
ptanCon:
;	ACCUM   <tag_valid, 0, 4, 087c0H, 0, 0, 0>
	db	tag_valid, 0
	dw	4, 087c0H, 0, 0, 0
;       ACCUM   <tag_valid, 1, 3, 0f000H, 0, 0, 0>
	db	tag_valid, 1
	dw	3, 0f000H, 0, 0, 0
;       ACCUM   <tag_valid, 0, 3, 0d000H, 0, 0, 0>
	db	tag_valid, 0
	dw	3, 0d000H, 0, 0, 0
;       ACCUM   <tag_valid, 1, 3, 0b000H, 0, 0, 0>
	db	tag_valid, 1
	dw	3, 0b000H, 0, 0, 0
;       ACCUM   <tag_valid, 0, 3, 09000H, 0, 0, 0>
	db	tag_valid, 0
	dw	3, 09000H, 0, 0, 0
;       ACCUM   <tag_valid, 1, 2, 0e000H, 0, 0, 0>
	db	tag_valid, 1
	dw	2, 0e000H, 0, 0, 0
;       ACCUM   <tag_valid, 0, 2, 0a000H, 0, 0, 0>
	db	tag_valid, 0
	dw	2, 0a000H, 0, 0, 0
;       ACCUM   <tag_valid, 1, 1, 0c000H, 0, 0, 0>
	db	tag_valid, 1
	dw	1, 0c000H, 0, 0, 0
;       ACCUM   <tag_valid, 0, 0, 08000H, 0, 0, 0>
	db	tag_valid, 0
	dw	0, 08000H, 0, 0, 0
%else
ptanCon:
;	ACCUM   <tag_valid, 0, 3, 08f20H, 0>
	db	tag_valid, 0
	dw	3, 08f20H, 0
;       ACCUM   <tag_valid, 1, 2, 0e000H, 0>
	db	tag_valid, 1
	dw	2, 0e000H, 0
;       ACCUM   <tag_valid, 0, 2, 0a000H, 0>
	db	tag_valid, 0
	dw	2, 0a000H, 0
;       ACCUM   <tag_valid, 1, 1, 0c000H, 0>
	db	tag_valid, 1
	dw	1, 0c000H, 0
;       ACCUM   <tag_valid, 0, 0, 08000H, 0>
	db	tag_valid, 0
	dw	0, 08000H, 0
%endif
ptanConLen equ $-ptanCon
%if (ptanConLen > lenCreg)
	%error not enough constant space in Creg
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FPTAN           8087 partial tangent
;
;       use the continued fraction approximation:
;
;       abs(x) <= pi/4
;
;   tan(x)/x = 1/1-xx/3-xx/5-xx/7-xx/9-...
;       where xx = x*x
;
;   Enter with X on the top of the stack.  Leave it there
;   and compute the denominator 1-xx/3-xx/5-... and push it
;   on the stack.  A following FDIV instruction will yield
;   the tangent.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFPTAN:
        mov     cx,ptanConLen/2         ;number of words to move
        mov     si,ptanCon       ;start of constant list
        call    moveconsts              ;address constants from DS

        xor     bl,bl                   ;get ST pointer
        call    regptr                  ;  in BX
        cmp     byte [bx+tag], tag_zero
        ja      PT100                   ;error
%if BIG
        cmp     word [bx+expon], -32
%else
        cmp     word [bx+expon], -16
%endif
        jl      PT070                   ;value is very small

        mov     si,bx                   ;set for multiplication
        mov     di,bx                   ; **
        call    alloc                   ;get new stack location
        mov     [trptr2],bx               ;save XX ptr
        call    do_mul                  ;SI is ptr to  XX
        mov     di,si                   ;DI->XX
        mov     si,[trptr]                ;get constant pointer
        mov     byte [trctr],ptanConLen/lenAccum - 1   ;count thru constants
        jmp     PT030
PT020:
        mov     bx,si                   ;sum to Areg
        call    do_add                  ;SI->denom
        mov     di,[trptr2]               ;DI->XX
PT030:
        mov     bx,Areg          ;
        call    do_div                  ;SI->XX/denom (Areg)
        mov     di,[trptr]
        add     di,lenAccum             ;point at next constant
        mov     [trptr],di
        dec     byte [trctr]
        jnz     PT020

        mov     bx,[trptr2]               ;sum to ST
        call    do_add                  ;DI->denom
PT099:
        jmp     restore_segs

PT070:      ; exponent is so very small
        jmp     gFLD1                   ;

PT100:      ; top of stack is not valid
        call    alloc
        mov     byte [bx+tag], tag_invalid

        push    Iexcept
        call    exception
        jmp     PT099


	even
%if BIG
f2xm1Con:
;	ACCUM	<tag_valid, 1, 6, 0cfbfH, 0828eH, 0879aH, 0eed4H>
	db	tag_valid, 1
	dw	6, 0cfbfH, 0828eH, 0879aH, 0eed4H
;	ACCUM	<tag_valid, 0, 12, 0a3e8H, 0660eH, 063d3H, 01526H>
	db	tag_valid, 0
	dw	12, 0a3e8H, 0660eH, 063d3H, 01526H
;	ACCUM	<tag_valid, 1, 17, 0a292H, 08a64H, 0d703H, 074a4H>
	db	tag_valid, 1
	dw	17, 0a292H, 08a64H, 0d703H, 074a4H
;	ACCUM	<tag_valid, 0, 21, 0dbe2H, 02ee9H, 08949H, 0c206H>
	db	tag_valid, 0
	dw	21, 0dbe2H, 02ee9H, 08949H, 0c206H
;	ACCUM	<tag_valid, 1, 25, 0ce32H, 03827H, 0285dH, 05fdcH>
	db	tag_valid, 1
	dw	25, 0ce32H, 03827H, 0285dH, 05fdcH
;	ACCUM	<tag_valid, 0, 29, 08225H, 08eb0H, 0c7e7H, 09b90H>
	db	tag_valid, 0
	dw	29, 08225H, 08eb0H, 0c7e7H, 09b90H
;	ACCUM	<tag_valid, 1, 31, 0c92cH, 06ff2H, 0ed46H, 050cbH>
	db	tag_valid, 1
	dw	31, 0c92cH, 06ff2H, 0ed46H, 050cbH
;	ACCUM	<tag_valid, 0, 33, 0911dH, 0b676H, 0b025H, 0cdc2H>
	db	tag_valid, 0
	dw	33, 0911dH, 0b676H, 0b025H, 0cdc2H

;	ACCUM	<tag_valid, 0, 10, 0c854H, 0ee83H, 05d90H, 0364bH>
	db	tag_valid, 0
	dw	10, 0c854H, 0ee83H, 05d90H, 0364bH
;	ACCUM	<tag_valid, 0, 18, 0fe16H, 06f19H, 03deeH, 0d4d4H>
	db	tag_valid, 0
	dw	18, 0fe16H, 06f19H, 03deeH, 0d4d4H
;	ACCUM	<tag_valid, 0, 24, 0f7e6H, 00399H, 0de4bH, 07174H>
	db	tag_valid, 0
	dw	24, 0f7e6H, 00399H, 0de4bH, 07174H

%else
f2xm1Con:
;	ACCUM   <tag_valid, 0, 6, 0aed5H, 0c231H>
	db	tag_valid, 0
	dw	6, 0aed5H, 0c231H
;	ACCUM   <tag_valid, 0, 9, 09a7eH, 039aaH>
	db	tag_valid, 0
	dw	9, 09a7eH, 039aaH
;	ACCUM   <tag_valid, 0, -5, 08df4H, 0dff9H>
	db	tag_valid, 0
	dw	-5, 08df4H, 0dff9H
;	ACCUM   <tag_valid, 0, 3, 09f46H, 0063aH>
	db	tag_valid, 0
	dw	3, 09f46H, 0063aH
%endif
f2xm1ConLen equ $-f2xm1Con
%if (f2xm1ConLen > lenCreg)
    %error not enough constant space in Creg
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   F2XM1	2**X - 1
;
;	-1 < X < 1  --  for the 187/387
;
;	Enter with X on the stack top.  Compute 2**X-1, replacing
;	stack top with output.
;
;    Method:
;	To compute  exp(x),  take the Gaussian continued fraction:
;	 x 
;	e  =  1/1 - x/1 + x/2 - x/3 + x/2 - x/5 + x/2 - x/7 + x/2 -+ ...
;
;	and truncate at the ninth term.  Rearrange to:
;
;			    2 	    3    4
;	1680 + 840 x + 180 x  + 20 x  + x
;       -----------------------------------
;			    2 	    3    4
;	1680 - 840 x + 180 x  - 20 x  + x
;
;	which becomes:
;
;	1 + 2x / (b3 * x**2 - x + b4 -  b2 / (x**2 + b1) )
;
;	where b1..b4 are constants.  Finally substitute x = y * ln 2
;	and derive the constants C1..C4.  Compute as above, omitting the
;	" 1 + ".
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FX100:
        push    Iexcept
        call    exception
        jmp     FX099

gF2XM1:
        mov     cx,f2xm1ConLen/2        ;number of words to move
        mov     si,f2xm1Con      ;start of constant list
        call    moveconsts              ;address constants from DS

        xor     bl,bl                   ;get ST pointer
        call    regptr                  ;  in BX
        cmp     byte [bx+tag], tag_zero
        ja      FX100			;error

	mov	[trptr2],bx		;save ST pointer

%if BIG
; 64-bit mantissa version
	mov	si,bx			;SI = X ptr
	mov	bx,Areg
	mov	byte [trctr],8			;count 8 coefficients
; DI has trptr
	jmp	short FX020

FX010:
	mov	bx,si			;point to destination
	mov	di,[trptr2]		;get X pointer
	call	do_mul			; * X
	mov	bx,si			; set to add another Coeff
FX020:
	mov	di,[trptr]		; get next trptr
	call	do_add
	add	word [trptr],lenAccum		;bump the coeff ptr
	dec	byte [trctr]
	jnz	FX010

; now compute X*X to the Breg
	mov	si,[trptr2]		;get ST pointer
	mov	di,si			;copy it
	mov	bx,Breg
	call	do_mul			;Breg is X*X
	mov	bx,Creg + lenAccum*2	;place to put it
	mov	byte [trctr],3			;count 3 coefficients
	jmp	short FX040

FX030:
	mov	bx,si			;point to destination
	mov	di,Breg		;get X pointer
	call	do_mul			; * X
	mov	bx,si			; set to add another Coeff
FX040:
	mov	di,[trptr]		; get next trptr
	call	do_add
	add	word [trptr],lenAccum		;bump the coeff ptr
	dec	byte [trctr]
	jnz	FX030

	mov	di,[trptr2]		;get stack top
	mov	bx,di			;result there
	call	do_mul			;ST = X * num
	mov	bx,si
	mov	di,Creg		;get first coeff ptr
	mov	byte [di+sign],0		;set positive
	call	do_mul			; ST = coeff * X * num
	mov	di,si
	mov	si,Areg		;denominator ptr
	mov	bx,di			;put result in stack top
	call	do_div
	inc	word [si+expon]		;double it
%else
; 32-bit mantissa version
	mov	si,bx			;set to get X*X
	mov	di,bx			; **
	mov	bx,Areg		;put X*X in Areg
	call	do_mul			;SI points at Areg
	mov	di,[trptr]		;get Creg ptr
	mov	bx,di			;result to Creg
	call	do_add			;C1 + X*X in Creg
	mov	di,si			;Creg ptr to DI
	add	di,lenAccum		;C2 ptr to DI
	mov	bx,di
	call	do_div			;C2 = C2/(x*x + C1)
	push	si			;save C2 ptr
	add	si,lenAccum		;get c3 pointer
	mov	di,Areg		;get X*X pointer
	mov	bx,si			;result to C3
	call	do_mul			;C3 = C3 * X*X
	mov	di,si			;
	add	di,lenAccum		;get C4 pointer in DI
	mov	bx,di			;result to C4
	call	do_add
	pop	di			;restore C2 pointer
	push	si			;save C4 pointer
	mov	si,[trptr2]		;get ST pointer
	mov	bx,di			;C2 gets sum
	call	do_add			;C2 = X + C2/()
	xor	byte [si+sign],01		;negate it
	pop	di			;get C4 pointer
	mov	bx,di
	call	do_add			;result to C4
	mov	di,[trptr2]		;get ST pointer again
	mov	bx,di
	call	do_div			;get half of result
	inc	word [si+expon]		;get result
%endif
FX099:
	jmp	restore_segs		;and exit



	even
%if BIG
fl2xCon1:
	db	tag_valid, 1
	dw	1, 0b504H, 0f333H, 0f9deH, 06484H;-sqrt(0.5)
	db	tag_valid, 0
	dw	4, 08076H, 06bf0H, 04010H, 0a778H	;c23
	db	tag_valid, 0
	dw	4, 08cb2H, 07637H, 0e4a4H, 086a8H	;c21
	db	tag_valid, 0
	dw	4, 09b81H, 0e0faH, 0687fH, 0f325H	;c19
	db	tag_valid, 0
	dw	4, 0adcdH, 064dbH, 0a1f8H, 06a1aH	;c17
	db	tag_valid, 0
	dw	4, 0c4f9H, 0d8b4H, 0a67fH, 0efb7H	;c15
	db	tag_valid, 0
	dw	4, 0e347H, 0ab46H, 098bbH, 000e7H	;c13
	db	tag_valid, 0
	dw	3, 0864dH, 0424cH, 0a011H, 06943H	;c11
	db	tag_valid, 0
	dw	3, 0a425H, 089ebH, 0e015H, 047c4H	;c9
	db	tag_valid, 0
	dw	3, 0d30bH, 0b153H, 0d6f6H, 0c9fbH	;c7
	db	tag_valid, 0
	dw	2, 093bbH, 06287H, 07cdfH, 0f3caH	;c5
	db	tag_valid, 0
	dw	2, 0f638H, 04ee1H, 0d01fH, 0eba5H	;c3
	db	tag_valid, 0
	dw	0, 0b8aaH, 03b29H, 05c17H, 0f0bcH	;c1
	db	tag_valid, 0
	dw	1, 08000H, 0H, 0H, 0H		; 1/2

fl2xCon1Len equ $-fl2xCon1
%if (fl2xCon1Len > lenCreg)
    %error not enough constant space in Creg
%endif

fl2xCon2:
	db	tag_valid, 0
	dw	4, 0c4f9H, 0d8b4H, 0a67fH, 0efb7H	;c15
	db	tag_valid, 1
	dw	4, 0d30bH, 0b153H, 0d6f6H, 0c9fbH	;m14
	db	tag_valid, 0
	dw	4, 0e347H, 0ab46H, 098bbH, 000e7H	;c13
	db	tag_valid, 1
	dw	4, 0f638H, 04ee1H, 0d01fH, 0eba5H	;m12
	db	tag_valid, 0
	dw	3, 0864dH, 0424cH, 0a011H, 06943H	;c11
	db	tag_valid, 1
	dw	3, 093bbH, 06287H, 07cdfH, 0f3caH	;m10
	db	tag_valid, 0
	dw	3, 0a425H, 089ebH, 0e015H, 047c4H	;c9
	db	tag_valid, 1
	dw	3, 0b8aaH, 03b29H, 05c17H, 0f0bcH	;m8
	db	tag_valid, 0
	dw	3, 0d30bH, 0b153H, 0d6f6H, 0c9fbH	;c7
	db	tag_valid, 1
	dw	3, 0f638H, 04ee1H, 0d01fH, 0eba5H	;m6
	db	tag_valid, 0
	dw	2, 093bbH, 06287H, 07cdfH, 0f3caH	;c5
	db	tag_valid, 1
	dw	2, 0b8aaH, 03b29H, 05c17H, 0f0bcH	;m4
	db	tag_valid, 0
	dw	2, 0f638H, 04ee1H, 0d01fH, 0eba5H	;c3
	db	tag_valid, 1
	dw	1, 0b8aaH, 03b29H, 05c17H, 0f0bcH	;m2
	db	tag_valid, 0
	dw	0, 0b8aaH, 03b29H, 05c17H, 0f0bcH	;c1
fl2xCon2Len equ $-fl2xCon2
%if (fl2xCon2Len > lenCreg)
    %error not enough constant space in Creg
%endif

%else
fl2xCon1:
	db	tag_valid, 1
	dw	1, 0b504H, 0f334H	; -sqrt(0.5)
	db	tag_valid, 1
	dw	0, 0b2e3H, 03d74H
	db	tag_valid, 1
	dw	0, 0c9a1H, 058dcH
	db	tag_valid, 0
	dw	3, 09f05H, 0d27cH
	db	tag_valid, 0
	dw	0, 0e10eH, 08d9dH
	db	tag_valid, 0
	dw	1, 08000H, 00000H	; 1/2
fl2xCon1Len equ $-fl2xCon1
%if (fl2xCon1Len > lenCreg)
    %error not enough constant space in Creg
%endif

fl2xCon2:
	db	tag_valid, 1
	dw	2, 0b8aaH, 03b29H
	db	tag_valid, 0
	dw	2, 0f638H, 04ee2H
	db	tag_valid, 1
	dw	1, 0b8aaH, 03b29H
	db	tag_valid, 0
	dw	0, 0b8aaH, 03b29H
fl2xCon2Len equ $-fl2xCon2
%if (fl2xCon2Len > lenCreg)
    %error not enough constant space in Creg
%endif
%endif



;
;   exceptions for FYL2X
;
FY200:	je	FY250		;test for zero
FY210:	mov	bl,1		;tag is infinity, invalid, empty, etc.
	call	regptr
	mov	byte [bx+tag], tag_invalid
FY240:
        push    Iexcept
%if BIG
FYexception:
%endif
        call    exception
	mov	bx,[trptr2]
	jmp	FY999

FY250:	 ;tag is zero
	mov	bl,1		;result is - infinity
	call	regptr
	mov	byte [bx+tag], tag_infin
	mov	byte [bx+sign],01	;minus
	mov	word [bx+expon], exp_of_FPinf	;set exponent
	xor	ax,ax
	mov	[bx+mantis],ax
	mov	[bx+mantis+2],ax
%if BIG
	mov	[bx+mantis+4],ax
	mov	[bx+mantis+6],ax
%endif
	jmp	FY240
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    FYL2X	Y times LOG2(X)
;
;	Y multiplier is in ST(1)
;	X argument is at stack top, ST
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFYL2X:
	xor	bx,bx		;get ST pointer
	call	regptr		; in BX
	mov	[trptr2],bx	;save stack top pointer
	cmp	byte [bx+tag], tag_zero	;test for valid tag
	jae	FY200
	cmp	byte [bx+sign],0	;test for +
	jne	FY210

	mov	ax,[bx+expon]	;get X exponent
	inc	ax		;test against 0 or 1
	shr	ax,1
	jnz	FY100		;not zero or 1, do long computation
; exponent is zero or 1, further test needed
	mov	si,Areg	;get -1 in Areg
	mov	byte [si+tag], tag_valid	;tag and sign to zero
	mov	byte [si+sign],01	; minus
	mov	word [si+mantis],8000h	;
	xor	ax,ax
	mov	[si+expon],ax
	mov	[si+mantis+2],ax
%if BIG
	mov	[si+mantis+4],ax
	mov	[si+mantis+6],ax
%endif
	mov	di,bx		; ST is arg
	mov	bx,si		;result to Areg
	call	do_add		;Areg = X - 1.0
	mov	bx,[trptr2]	;restore ST pointer
%if BIG
	cmp	word [si+expon],-5	;test exponent
%else
	cmp	word [si+expon],-8	;test exponent
%endif
	jg	FY100		;larger values go thru long computation
; have Areg is X-1, very near zero
	mov	si,fl2xCon2	;get second set of constants
	mov	cx,fl2xCon2Len/2	;words to move
	call	moveconsts	;put constants in data segment

	mov	bx,[trptr2]	;accumulate in ST
	mov	si,[trptr]
	mov	byte [trctr],fl2xCon2Len/lenAccum	;count 4/15 multiplies
	jmp	short FY030

FY020:
	add	word [trptr],lenAccum	;bump to next constant
	mov	di,[trptr]	;set to add next constant
	mov	bx,si		;accumulate same place
	call	do_add		;add another constant
	mov	bx,si		;
FY030:
	mov	di,Areg	;X-1 is here
	call	do_mul		;multiply
	dec	byte [trctr]		;count thru constants
	jnz	FY020
	jmp	FY150		;multiply ST by ST(1)


FY100:
	mov	si,fl2xCon1	;get source constants
	mov	cx,fl2xCon1Len/2	;get words to move
	call	moveconsts	;move to data segment
	lea	di,[bx+expon]	;get address of integer exponent
	mov	si,Breg	;put it in the Breg
	call	load_I16	;load the integer
	mov	si,[trptr2]	;get X pointer
	mov	word [si+expon],-1	; X in range [0.5 ... 1.0)
	mov	di,[trptr]	;get constant pointer
	mov	bx,Areg	;put sum in Areg
	call	do_add		;do the add
	mov	si,[trptr2]	;get X pointer
	mov	di,[trptr]	;get constant pointer
	mov	byte [di+sign],0	;make constant +
	mov	bx,si		;result to stack top
	call	do_add		;get denominator
	mov	di,Areg	;get numerator pointer
	mov	bx,si		;form Z in stack top
	call	do_div		;ST = Z
	mov	di,si		;set to get Z**2
	mov	bx,Areg	;Z**2 will be in Areg
	call	do_mul		;Areg = Z**2
	add	word [trptr],lenAccum	;bump to C4 or C23
%if BIG
	mov	byte [trctr],fl2xCon1Len/lenAccum-3	;count 11 terms
	mov	di,[trptr]	;get constant pointer
	mov	bx,di		;accumulate in Const area
FY120:
	call	do_mul		; * Z*Z
	add	word [trptr],lenAccum	;bump to next constant
	mov	di,[trptr]	;
	mov	bx,si		;accumulate in const area
	call	do_add		; add on constant
	mov	bx,si
	mov	di,Areg
	dec	byte [trctr]		;count terms
	jnz	FY120

	mov	bx,[trptr2]	;form 2*Z*(c1...) in ST
	inc	word [bx+expon]
%else
	mov	di,[trptr]	;
	mov	bx,di		;accumulate in Const area
	call	do_add		;
	add	word [trptr],lenAccum	;bump to C3
	mov	di,[trptr]
	mov	bx,si		;accumulate at C4 position
	call	do_div
	add	word [trptr],lenAccum	;bump to C2
	push	si		;save C3/...
	mov	si,Areg	;get Z**2 ptr
	mov	di,[trptr]	;get C2 pointer
	mov	bx,si		;accumulate in Areg
	call	do_mul		;Areg = C2 * Z**2
	pop	di
	mov	bx,si		;Add in C3 stuff
	call	do_add		;Areg = C2*Z**2 ...
	add	word [trptr],lenAccum	;bump to C1
	mov	di,[trptr]	;get C1 pointer
	mov	bx,si		;result to Areg
	call	do_add		;add it on
	mov	bx,[trptr2]	;form Z*(c1...) in ST
%endif
	mov	di,bx		;
	call	do_mul		;got part of it in ST
	mov	bx,si		;
	mov	di,[trptr]	;get pointer to 1/2
	add	di,lenAccum	; **
	call	do_add		;got LOG2(x) in ST
	mov	di,Breg	;get extracted exponent
	mov	bx,si		;result to stack top
	call	do_add

FY150:
	mov	bl,1		;get ST(1) pointer
	call	regptr		; in BX
	mov	di,bx		;set for product
	call	do_mul		;do the product
	mov	bx,[trptr2]	;set to pop the stack
FY999:
	jmp	pop_stack	; go do the pop





; end em187c.asm

; em187h.asm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLD     tmpReal         load 10-byte real
;
;       ES:DI points at memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLDtmp:
        call    alloc               ;get ST pointer in BX
  es    mov     ax,[di+8]        ;get sign and exponent
        xor     dx,dx               ;clear DX
        shl     ax,1                ;sign to carry
        rcl     dl,1                ;sign to DL
        mov     byte [bx+sign],dl        ;store sign
        mov     byte [bx+tag], tag_valid ;set up valid tag

        shr     ax,1                ;biased exponent to AX
        cmp     ax,7FFFh            ;check for infinity
        je      LT100               ;it may be
        or      ax,ax               ;test for 0
        jz      LT150               ;may be a DeNormal or zero
        sub     ax,3FFFh            ;get true exponent
LT010:
        mov     word [bx+expon],ax
  es    mov     ax,[di+6]        ;get high mantissa
        mov     [bx+mantis],ax
  es    mov     ax,[di+4]        ;get second mantissa
        mov     [bx+mantis+2],ax
%if BIG
  es    mov     ax,[di+2]        ;get third mantissa
        mov     [bx+mantis+4],ax
  es    mov     ax,[di]          ;get lowest mantissa
        mov     [bx+mantis+6],ax
%endif
LT099:
        jmp     restore_segs

LT100:      ;check for possible infinity
  es    cmp     word [di+6],8000h     ;check for infinity
        jne     LT120
  es    mov     dx,[di+4]        ;rest must be zero
  es    or      dx,[di+2]        ;
  es    or      dx,[di]
        jnz     LT120
        mov     byte [bx+tag], tag_infin
;       mov     ax,exp_of_FPinf
        jmp     LT010               ;copy rest of mantissa
LT120:  mov     byte [bx+tag], tag_invalid
        push    Iexcept             ;invalid operation
        call    exception
        mov     ax,exp_of_FPinf
        jmp     LT010               ;copy rest of mantissa        

LT150:      ;possible zero or denormal
  es    mov     dx,[di+6]        ;get high part of mantissa
  es    or      dx,[di+4]        ;rest must be zero
  es    or      dx,[di+2]        ;
  es    or      dx,[di]
        mov     ax,exp_of_FPzero    ;get exponent of zero
        mov     byte [bx+tag], tag_zero
        jz      LT010

        push    Dexcept             ;we don't try to normalize it
        call    exception
        jmp     LT120


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSTP    tmpReal         store 10-byte real
;
;       ES:DI points at memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FSTPtmp:
        xor     bl,bl               ;get ST(0) pointer to BX
        call    regptr              ; **
        mov     dl,byte [bx+sign]        ;get sign
        ror     dl,1                ;sign to hi bit of DL
        cmp     byte [bx+tag], tag_zero  ;
        jae     STP100              ;may be zero or problem
        mov     ax,word [bx+expon]       ;get exponent
        sub     ax,-16383           ;bias it
        jl      STP095              ;too small
        cmp     ax,7FFFh            ;check for too big
        jae     STP097              ;too big
        or      ah,dl               ;sign bit to AH
  es    mov     [di+8],ax        ;store sign and exponent

        mov     ax,[bx+mantis]
  es    mov     [di+6],ax        ;store mantissa
        mov     ax,[bx+mantis+2]
  es    mov     [di+4],ax
%if BIG
        mov     ax,[bx+mantis+4]
  es    mov     [di+2],ax
        mov     ax,[bx+mantis+6]
  es    mov     [di],ax
%else
        xor     ax,ax
  es    mov     [di+2],ax
  es    mov     [di],ax
%endif
STP090:
        jmp     pop_stack           ;BX is set ok

STP095:
        push    Uexcept             ;underflow
        call    exception           ;
        jmp     short STP105        ;store zero
STP097:
        push    Oexcept             ;overflow
        call    exception
        mov     ax,7FFFh            ;get largest exponent
        jmp     short STP160


; tag is .ge. tag_zero
STP100:
        ja      STP150                  ;jump if problem
; tag is zero
STP105:
        xor     ax,ax
        mov     ah,dl                   ;sign it
  es    mov     [di+8],ax            ;store signed zero
        xor     ah,ah
  es    mov     [di+6],ax
STP130:
  es    mov     [di+4],ax
  es    mov     [di+2],ax
  es    mov     [di],ax
        jmp     STP090
STP150:
        mov     ax,7FFFH                ;get biased infinity exponent
        cmp     byte [bx+tag], tag_infin     ;check for infinity
        jne     STP180
STP160:
        or      ah,dl                   ;sign the infinity
  es    mov     [di+8],ax            ;store sign and exponent
  es    mov     word [di+6],8000h         ;mantissa of infinity
STP175:
        xor     ax,ax
        jmp     STP130                  ;store rest of mantissa
STP180:
        push    Iexcept                 ;tag is empty, or invalid
        call    exception
  es    mov     word [di+8],0FFFFh        ;store indefinite
  es    mov     word [di+6],0C000h        ; **
        jmp     STP175

        even
%if BIG
rndCon:
;	ACCUM   <tag_valid, 0, 0, 3FFFh, 0FFFFh, 0FFFFh, 0FFFFh>
	db	tag_valid, 0
	dw	0, 3FFFh, 0FFFFh, 0FFFFh, 0FFFFh
%else
rndCon:
;	ACCUM   <tag_valid, 0, 0, 3FFFh, 0FFFFh>
	db	tag_valid, 0
	dw	0, 3FFFh, 0FFFFh
%endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FRNDINT             round ST to integer according
;                       to rounding control
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFRNDINT:
        xor     bl,bl                   ;get pointer to ST in BX
        call    regptr                  ; **
        cmp     byte [bx+tag], tag_zero      ;test the tag
        je      RND100
        ja      RND120

%if BIG
        mov     cx,63               ;get max exponent
%else
        mov     cx,31               ;get max exponent
%endif
        sub     cx,word [bx+expon]       ;form shift count
        jle     RND100              ;already an integer
%if BIG
%else
        add     cx,32               ;increase shift count
%endif
        mov     si,bx               ;SI is destination pointer
        call    vloadsh64           ;integerize & compute guard & sticky
        call    round_mag           ;round magnitude
%if BIG
        mov     di,63               ;get max exponent
%else
        mov     di,31               ;get smaller exponent
        mov     ax,cx               ;shift by 32 bits
        mov     bx,dx               ; **
%endif
        push    restore_segs
        jmp     normalize_and_exit



;
; exponent is small, return zero
RND050:
        xor     ax,ax                   ;get zero
        mov     byte [bx+tag], tag_zero      ;set new tag
        mov     word [bx+expon],exp_of_FPzero    ;set special exponent
        mov     [bx+mantis],ax          ;set mantissa
        mov     [bx+mantis+2],ax        ; **
%if BIG
        mov     [bx+mantis+4],ax        ;  **
        mov     [bx+mantis+6],ax        ;   **
%endif
RND100:
        jmp     restore_segs        ;major exit point


; tag is infinity or above
RND120:
        cmp     byte [bx+tag],tag_infin      ;test for infinity
        je      RND100

        push    Iexcept                 ;invalid operation
        call    exception
        jmp     RND100



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSQRT           square root of stack top
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFSQRT:
        xor     bl,bl           ;get ST(0) pointer in BX
        call    regptr          ; **
        cmp     byte [bx+tag], tag_zero  ;test for unusual tags
        jae      SQ100           ;skip if okay
; tag is valid
        cmp     byte [bx+sign],0
        jne     SQ110           ;SQRT of neg. is indefinite        

        mov     ax,word [bx+expon]   ;get exponent of argument
        mov     dx,[bx+mantis]  ;get high order mantissa
        rol     dx,1            ;rotate mantissa
        sar     ax,1            ;divide exponent by 2, odd bit to carry
        rcr     dx,1            ;odd bit to high DX
        rcr     dx,1            ;normal 1 bit to high DX
        mov     [Areg+expon],ax   ;Areg is initial guess
        mov     [Areg+mantis],dx  ; **
        xor     ax,ax
        mov     word [Areg],ax ;clear sign and tag (+, valid)
        mov     [Areg+mantis+2],ax
%if BIG
        mov     [Areg+mantis+4],ax
        mov     [Areg+mantis+6],ax
%endif

        mov     word [trptr],bx         ;save ST pointer
        mov     si,Areg
%if BIG
        mov     byte [trctr],3           ;iterate 4 times with 64-bit mantissa
%else
        mov     byte [trctr],2           ;iterate 3 times with 32-bit mantissa
%endif
SQ040:
        mov     di,word [trptr]
        mov     bx,Breg
        call    do_div          ;arg/guess --> temp

        mov     di,Areg  ;
        mov     bx,di
        call    do_add          ; Areg is new guess * 2
; SI points at Areg
        dec     word [si+expon]      ;divide by 2
        dec     byte [trctr]
        jnz     SQ040

; last iteration has ST as final destination
        mov     di,word [trptr]
        mov     bx,Breg
        call    do_div          ;arg/guess --> temp

        mov     di,Areg  ;
        mov     bx,word [trptr]         ;ST is final destination
        call    do_add          ; Areg is new guess * 2
; SI points at ST
        dec     word [si+expon]      ;divide by 2

SQ099:
        jmp     restore_segs

SQ100:
        je      SQ099               ;+/- 0.0  -->  +/- 0.0
        cmp     byte [bx+tag], tag_infin ;check for an infinity
        jne     SQ110
        cmp     byte [bx+sign],0
        jne     SQ110                   ;-inf --> indefinite
        jmp     SQ099                   ;+inf --> +inf
SQ110:
        mov     byte [bx+tag], tag_invalid ;
        push    errSqrt+Iexcept
        call    exception
        jmp     SQ099




;
; handle FPREM errors here
;
FR200:      ;divisor is zero or otherwise bad
        push    Zexcept
        call    exception
FR300:      ;dividend is infin, empty, or invalid
        push    Iexcept
        call    exception
        mov     byte [si+tag], tag_invalid
FR085:
        and     byte [codes], ~(C3+C2+C1+C0) ;clear condition codes
        jmp     restore_segs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FPREM           remainder of ST / ST(1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFPREM:
        xor     bl,bl               ;get ST(0) pointer
        call    regptr              ; in BX
        mov     si,bx               ;save ST pointer in SI

        mov     bl, 1               ;get ST(1) pointer
        call    regptr              ; in BX
        mov     di,bx               ;save ST(1) pointer in DI

        cmp     byte [di+tag], tag_zero  ;test tag of divisor
        jae     FR200               ; divisor is bad
        cmp     byte [si+tag], tag_zero  ;test tag of dividend
        ja      FR300               ; dividend is funny
; both tags are valid
        mov     byte [ctr],0               ;zero the divide counter
        mov     cx,word [si+expon]       ;get exponent of dividend
        mov     ax,word [di+expon]       ;get exponent of divisor
        sub     cx,ax               ;get difference E.dividend - E.divisor
        jl      FR085               ;dividend exponent is less than divisor
        mov     word [si+expon],ax       ;dividend exponent is updated

        mov     ax,[si+mantis]      ;get dividend in AX:BX[:BP:SI]
        mov     bx,[si+mantis+2]
%if BIG
        mov     bp,[si+mantis+4]    ; **
        push    si                  ;save SI
        mov     si,[si+mantis+6]
%endif
        mov     dx,[di+mantis]      ;get divisor in DX:mem[:mem:mem]
        inc     cx
        jmp     short FR004         ;go do the compare

FR003:
        shl     byte [ctr],1               ;shift the counter
%if BIG
        shl     si,1                ;left shift of the dividend
        rcl     bp,1                ; **
        rcl     bx,1                ;
%else
        shl     bx,1                ; start of short shift
%endif
        rcl     ax,1                ;final shift of dividend
        jc      FR005               ;dividend is considered greater if CF=1
FR004:
        cmp     ax,dx               ;compare dividend to divisor
        ja      FR005
        jb      FR007
        cmp     bx,[di+mantis+2]    ;compare
%if BIG
        ja      FR005
        jb      FR007
        cmp     bp,[di+mantis+4]    ;compare
        ja      FR005
        jb      FR007
        cmp     si,[di+mantis+6]    ;compare
%endif
        jb      FR007
FR005:
%if BIG
        sub     si,[di+mantis+6]    ;subtract
        sbb     bp,[di+mantis+4]
        sbb     bx,[di+mantis+2]
%else
        sub     bx,[di+mantis+2]
%endif
        sbb     ax,dx               ;finish the subtract
        inc     byte [ctr]                 ;count the subtraction
FR007:
        loop    FR003

%if BIG
        mov     dx,si
        pop     si                  ;restore saved destination pointer
%endif
        mov     cl,byte [ctr]              ;get quotient bits
;;;        cmp     byte [si+sign],0
;;;        je      FR050
;;;        neg     cl
FR050:
        and     cl,7                ;mask to 3 bits
        shr     cl,1                ;1's bit to carry
        rcl     ch,1                ;1's bit in b0 of CH
        ror     cl,1                ;4's bit in b0 of CL
        shr     cl,1                ;4's bit in carry, 2's bit in position
        rcl     ch,1                ;1's bit in b1, 4's bit in b0 of CH
        or      ch,cl               ;CH is flag byte
        and     byte [codes], ~(C3+C2+C1+C0) ;clear condition codes
        or      byte [codes],ch            ;set codes as appropriate

%if BIG
        mov     cx,bp
%endif
        mov     di,word [si+expon]       ;get saved exponent

        push    restore_segs
        jmp     normalize_and_exit


;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   moveconsts -- move constants to data segment
;
;   Enter with:
;       ES already points at data segment
;       SI points at code segment offset from which to move
;       CX contains the WORD count to move
;
;   Return with:
;       ES and DS intact
;       AX, DX, CX, SI, DI are trashed
;       'trptr' points at first constant in Creg
;
;;;;;;;;;;;;;;;;;;;;;;;;;;
moveconsts:	;	  proc    near
        mov     di,Creg  ;destination offset
        mov     word [trptr],di        ;set for return

        mov     ax,cs           ;source will be code segment
        mov     dx,ds           ;save DS in DX
        mov     ds,ax           ;set up DS for source DS:SI
    rep     movsw
        mov     ds,dx           ;restore DS

        ret
;moveconsts  endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSTENV   mem         ; store Environment
;
;       ES:DI is the destination address
;		of a 14 byte storage area
;
;	         ; 001 110       14 bytes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;*** gFSTENV:
	mov	ax,[Control]	; get the full Control word
	stosw

	mov	ax,[Status]	; get status word with no TOS
	mov	bh,[tos]	; get TOS bits
	shl	bh,3		; shift to position
	xor	bh,ah
	and	bh,00111000b
	xor	ah,bh		; store the TOS bits
	stosw
	mov	bx,fp7+lenAccum		; address FPAC 7+1
.1:
	sub	bx,lenAccum	; start at fp(7)
	mov	cl,[bx+tag]	; get tag word
	and	cl,3		; mask to 2 bits (insurance)
	shl	ax,1
	shl	ax,1		; make room in AX
	or	al,cl
	cmp	bx,fp0		; done with all of them
	jne	.1
	stosw			; store the composed tag word

	mov	si,save_ip	; DS:SI points at words to save
	movsw		; store IP
	movsw		; store CS
	movsw		; store data offset
	movsw		; store data SEG

        jmp     restore_segs



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FLDENV   mem         ; store Environment
;
;       ES:DI is the destination address
;		of a 14 byte storage area
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;*** gFLDENV:         ; 001 100       14 bytes
        jmp     restore_segs

     
	
; end em187h.asm

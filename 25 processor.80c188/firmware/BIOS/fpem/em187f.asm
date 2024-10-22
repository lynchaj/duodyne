; em187f.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FXAM                examine ST
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFXAM:
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     ah,byte [bx+sign]        ;get sign flag to C1
        shl     ah,1                ; **
        mov     al,byte [bx+tag]         ;get tag value
        cmp     al,tag_valid        ;try valid first
        je      gfx090
        cmp     al,tag_zero         ;try zero next
        je      gfx080
        cmp     al,tag_infin        ;try infinity next
        je      gfx070
        cmp     al,tag_empty        ;try empty next
        je      gfx060

        or      ah,C0               ;C0 flags invalid (NaN)
        jmp     short gfx095
gfx060:
        or      ah,C3+C0            ;C3+C0 for empty
        jmp     short gfx095
gfx070:
        or      ah,C2+C0            ;C2+C0 flags infinity
        jmp     short gfx095
gfx080:
        or      ah,C3               ;C3 flags zero
        jmp     short gfx095
gfx090:
        or      ah,C2               ;C2 flags normal
gfx095:
        and     byte [codes],~(C3+C2+C1+C0)    ;clear Status bits
        or      byte [codes],ah            ;set condition code bits
        jmp     restore_segs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FTST                compare ST to 0.0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFTST:
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     si,bx               ;point SI at stack top
        call    do_test             ;compare [SI] to 0.0

        and     byte [codes],~ (C3+C2+C0)    ;clear Status bits
        or      byte [codes],ah            ;set condition code bits
        jmp     restore_segs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FDIV    mem         ST := ST / mem
;
;       ES:DI is pointer to memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFDIV:
        mov     si,Areg      ;load first into the Areg
        mov     bx,FMbits           ;get format mask
        and     bl,ch
  cs    call    [vecFLD+bx]          ;get the input argument
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     di,bx               ;DI is destination, SI is source
;  call to  do_div  returns to  restore_segs
        push    restore_segs
        JMP     do_div



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FDIVR   mem         ST := mem / ST
;
;       ES:DI is pointer to memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFDIVR:
        mov     si,Areg      ;load first into the Areg
        mov     bx,FMbits           ;get format mask
        and     bl,ch
  cs    call    [vecFLD+bx]          ;get the input argument
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     di,bx               ;DI is destination, SI is source
        xchg    si,di               ;change sense of divide, ST (in BX)
                                    ; still gets the result
;  call to  do_div  returns to  restore_segs
        push    restore_segs
        JMP     do_div

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FDIV    ST,ST(i)        R=0, P=0
;   FDIVR   ST(i),ST        R=1, P=0
;   FDIVRP  ST(i),ST        R=1, P=1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FDIVi:
        mov     bl,cl           ;get ST(i) pointer
        call    regptr          ;BX is ST(i) pointer
        mov     si,bx           ;divisor in SI is ST(i)
        xor     bx,bx           ;get ST pointer
        call    regptr          ;BX is ST pointer
        mov     di,bx           ;dividend pointer in DI is ST
        test    ch,Rbit         ;see who gets the result
        jz      FDIVi01         ;ST will get result
; ST(i) gets the result
        mov     bx,si           ;BX points to destination
        push    test_pop
        jmp     do_div
FDIVi01:    ; ST will get the result, no pop possible
        push    restore_segs
        jmp     do_div


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FDIVR    ST,ST(i)        R=0, P=0
;   FDIV     ST(i),ST        R=1, P=0
;   FDIVP    ST(i),ST        R=1, P=1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FDIV0:
        mov     bl,cl           ;get ST(i) pointer
        call    regptr          ;BX is ST(i) pointer
        mov     di,bx           ;dividend pointer in DI is ST(i)
        xor     bx,bx           ;get ST pointer
        call    regptr          ;BX is ST pointer
        mov     si,bx           ;divisor in SI is ST
        test    ch,Rbit         ;see who gets the result
        jz      FDIV001         ;ST will get result
; ST(i) gets the result
        mov     bx,di           ;BX points to destination
        push    test_pop
        jmp     short do_div

FDIV001:    ; ST will get the result, no pop possible
        push    restore_segs
        jmp     short do_div



; error in tags, handle in FADD for now
FD210:
        pop     si                  ; clean up the stack for now
        mov     byte [si+tag], tag_invalid
        push    Iexcept             ;signal exception
        call    exception
        jmp     FD099


FD220:
        pop     si              ;get result pointer
        cmp     byte [di+tag], tag_zero
        je      FD230           ;jump if zero divided by zero
; have  tag_valid  divided by zero
        push    Zexcept         ;zero divide exception
        call    exception
        mov     al,byte [di+sign]    ;get sign of numerator
        mov     byte [si+sign],al    ;store it
        mov     byte [si+tag], tag_infin ;set infinity
FD225:
        mov     word [si+expon], exp_of_FPinf
        xor     ax,ax           ;get zero
        jmp     short FD250           ;clear mantissa
FD230:
        push    Iexcept         ; 0/0 -- invalid operation
        call    exception
        mov     byte [si+tag], tag_invalid
        jmp     FD225


; exception handling for do_div
FD200:
        test    dh,0FEh         ;check for other than zero
        jnz     FD210           ;have invalid, infinity, or empty
; one or both of the tags is zero
        cmp     byte [si+tag], tag_zero
        je      FD220           ;divisor is zero
;divisor is non-zero, therefore the dividend is zero
        pop     si              ;get result pointer
        mov     byte [si+tag], tag_zero
        xor     ax,ax           ;get zap value
        mov     byte [si+sign],al    ;set to +0.0
        mov     word [si+expon],exp_of_FPzero
FD250:
        mov     [si+mantis],ax  ;zero out the mantissa
        mov     [si+mantis+2],ax
%if BIG
        mov     [si+mantis+4],ax
        mov     [si+mantis+6],ax
%endif
        jmp     FD099           ;go exit from the same point

; underflow subtracting exponents
FD205:
        pop     si                  ; clean up the stack for now
        mov     byte [si+tag], tag_zero
        mov     byte [si+sign], 0
        mov     word [si+expon],exp_of_FPzero

        push    Uexcept             ;signal exception
        call    exception
        jmp     FD099


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Divide accumulator DI by SI
;       SI and DI point to operands
;       BX is place to put result, may be same as SI or DI
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
do_div:		;      proc    near
        push    bx              ;save place to which to move result
        mov     dh,byte [si+tag]     ;get source tag
        or      dh,byte [di+tag]     ;get dest tag
        jnz     FD200           ;if not both valid, something needs checking
; both tags are valid
        mov     al,byte [si+sign]    ;exclusive or the signs
        xor     al,byte [di+sign]    ; **
        mov     byte [bx+sign],al    ;

        mov     ax,word [di+expon]   ;subtract the exponents
        sub     ax,word [si+expon]   ;
        jo      FD205           ;signal underflow
        mov     word [bx+expon],ax   ;store result exponent

%if BIG
        mov     dx,[di+mantis]      ;move fraction to mtemp for the divide
        mov     ax,[di+mantis+2]    ;get 2nd part
        mov     bx,[di+mantis+4]    ;get third part
        mov     cx,[di+mantis+6]    ;get final part

        mov     bp,[si+mantis+2]    ;get high order part
        mov     di,bp               ;copy for test
        or      di,[si+mantis+4]    ;test for divide by integer
        or      di,[si+mantis+6]    ;
        mov     di,[si+mantis]      ;get hi part
        jz      FD010               ;go do fast divide

;not so lucky, must do the entire mess
;  DX:AX:BX:CX / DI:BP:mem:mem
        mov     byte [ctr],64              ;count 64 bits
        jmp     short FD004         ;save a shift
FD003:
        shl     cx,1                ;the long rotate
        rcl     bx,1
        rcl     ax,1
        rcl     dx,1
        jc      FD005               ;go do the subtract
FD004:
        cmp     dx,di
        ja      FD005
        jb      FD007               ;no subtract, but CF=1
        cmp     ax,bp
        ja      FD005
        jb      FD007
        cmp     bx,[si+mantis+4]
        ja      FD005
        jb      FD007
        cmp     cx,[si+mantis+6]
        jb      FD007
FD005:
        sub     cx,[si+mantis+6]
        sbb     bx,[si+mantis+4]
        sbb     ax,bp
        sbb     dx,di
        clc                             ;needed for bullet proofing
FD007:
        cmc
        rcl     word [mtemp+6],1               ;accumulate the result a bit at a time
        rcl     word [mtemp+4],1
        rcl     word [mtemp+2],1
        rcl     word [mtemp],1
        dec     byte [ctr]
        jnz     FD003

; done with division
        mov     bx,word [mtemp]                ;load up the resulting fraction
        mov     cx,word [mtemp+2]              ;in the right place
        mov     bp,word [mtemp+4]
        mov     ax,word [mtemp+6]              ;BX:CX:BP:AX
        jmp     short FD018             ;go round it

; integer division -- the low 3 words of the source are zero
FD010:
;;;        xor     bp,bp               ;get zero at low end of word
        shr     dx,1                ;make sure DX < DI
        rcr     ax,1
        rcr     bx,1
        rcr     cx,1
        rcr     bp,1                ;last bit retained in BP

        div     di
        xchg    ax,bx               ;high quotient to BX
        div     di
        xchg    ax,cx               ;second quotient to CX
        div     di
        xchg    ax,bp               ;third quotient to BP
        div     di                  ;fourth quotient to AX
; round the result
FD018:
        shr     di,1                ;divide by 2
        sub     di,dx               ;borrow if dx is greater (set carry)
        adc     ax,0
        adc     bp,0
        adc     cx,0
        adc     bx,0                ;set the sign flag
        pop     si                  ;get place to store it
        js      FD020               ;no normalization needed
        dec     word [si+expon]          ;adjust exponent
        shl     ax,1
        rcl     bp,1
        rcl     cx,1
        rcl     bx,1
FD020:
        mov     [si+mantis],bx
        mov     [si+mantis+2],cx
        mov     [si+mantis+4],bp
        mov     [si+mantis+6],ax

%else
; implement Knuth algorithm for (A+b)/(C+d)
        mov     cx,[si+mantis]      ;get C in CX
        mov     ax,[si+mantis+2]    ;get d in AX
        mov     si,[di+mantis]      ;get A in SI
        mov     bx,[di+mantis+2]    ;get b in BX
        or      ax,ax               ;test d
        jz      FD010               ;skip correction if d==0
        mul     si                  ;DX:AX is  A*d
        cmp     dx,cx               ;see if overflow occurs
        jb      FD005               ;no it doesn't
; got overflow problem
        sub     dx,cx               ;guarantee no overflow
        div     cx                  ;okay

        sub     bx,ax               ;BX is b-A*d/C
        sbb     si,1                ;correct A if borrow needed
        jmp     short FD010         ;rejoin main line code

FD005:
        div     cx                  ;AX is A*d/C and DX is lower order

        sub     bx,ax               ;BX is b-A*d/C
        sbb     si,0                ;correct A if borrow needed

FD010:
        mov     dx,si               ;DX is now A
        xor     si,si

        mov     ax,bx               ;AX is now B
        shr     dx,1                ;make sure DX is < CX
        rcr     ax,1                ;shift again
        rcr     si,1                ;shift third part
        div     cx                  ;AX is quotient, DX is remainder
        xchg    ax,si               ;SI is hi-part of result
        div     cx                  ;AX is lo-part of result
        shr     cx,1                ;divide by 2
        sub     cx,dx               ;borrow if dx is greater (carry set)
        adc     ax,0                ;round the result
        adc     si,0                ; sets/clears the Sign flag

        mov     dx,si               ;DX:AX is result
        pop     si                  ;get pointer of where to put it

        js      FD060               ;go store it if already normalized
        dec     word [si+expon]          ;adjust exponent
        shl     ax,1                ;normalize
        rcl     dx,1                ;
FD060:
        mov     [si+mantis],dx      ;store hi-part
        mov     [si+mantis+2],ax    ;store lo-part
%endif
        mov     byte [si+tag], tag_valid ;say destination is valid
FD099:
        ret                     ;return to caller
;do_div  endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Name:  do_compare
;
;   compare [DI] to [SI]
;   returns result of comparison in AH
;
;   AH bit settings:
;           7  6  5  4  3  2  1  0
;              Z           P     C  --  80186 flag register
;             C3          C2 C1 C0  --  80187 condition codes
;
;       [DI] = [SI]     returns  C3                 JE
;       [DI] > [SI]     returns all flags clear     JA
;       [DI] < [SI]     returns  C0                 JB
;   [DI] not comparable to [SI] returns  C3+C2+C0
;
;   uses:  AX, DX, SI, DI   (may be trashed)
;   preserves BX, CX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
do_compare:	;	  proc    near
        mov     al,byte [di+tag]         ;get destination tag
        or      al,byte [si+tag]         ;get source tag
        jnz     DC100               ;tags are not both valid
; tags are valid, check signs of operands
        mov     al,byte [si+sign]        ;get sign of source
        cmp     al,byte [di+sign]        ; if sS > sD,  D > S; if sS < sD,  D < S
        jne     DC080               ;done if not equal
; signs are the same, swap source and destination if negative
        or      al,al
        jz      DC010               ;both signs are positive
        xchg    si,di               ;for negative, magnitude 
                                    ; comparison is reversed
DC010:
        mov     ax,word [di+expon]       ;get destination exponent
        mov     dx,word [si+expon]       ;get source exponent
        xor     ah,80h              ;bias for unsigned comparison
        xor     dh,80h              ; **
        cmp     ax,dx               ;unsigned comparison
        jne     DC080               ;if eD > eS,  D > S; and vice versa

; exponents are the same, compare mantissas
        mov     ax,[di+mantis]      ;get high order mantissa
        cmp     ax,[si+mantis]      ;unsigned comparison
        jne     DC080

        mov     ax,[di+mantis+2]      ;get high order mantissa
        cmp     ax,[si+mantis+2]    ;unsigned comparison
%if BIG
        jne     DC080

        mov     ax,[di+mantis+4]    ;get high order mantissa
        cmp     ax,[si+mantis+4]    ;unsigned comparison
        jne     DC080

        mov     ax,[di+mantis+6]    ;get high order mantissa
        cmp     ax,[si+mantis+6]    ;unsigned comparison
%endif

DC080:
        lahf                        ;get flags to AH
        and     ah,C3+C0            ;mask to Zero and Carry
DC099:
        ret
;
; tags are not both zero; i.e., not both (tag_valid)
;
DC100:  test    al,0FEh             ;test for tag_zero as only exception
        jnz     DC150               ;not comparable
        cmp     byte [si+tag], tag_zero  ;test source for tag_zero
        jne     DC110
; source is tag zero
        mov     si,di               ;FTST  [SI]
        JMP     short do_test       ;do_test will do the return

DC110:      ; SI is tag_valid, DI must be tag_zero
        call    do_test             ;FTST  [SI]
        xor     ah,C0               ;invert comparison bit
        jmp     DC099
    
; one of the operands is infinity, or NaN, or empty
DC150:
        mov     ah,C3+C2+C0
        jmp     DC099

;do_compare  endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   do_test     compare [SI] to 0.0
;
;   uses:  AX
;   preserves all other registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
do_test:	;	 proc    near
        cmp     byte [si+tag], tag_zero
        je      DT090
        ja      DT070
; tag_valid
        xor     ax,ax
        cmp     al,byte [si+sign]    ;know AL=0, it is (tag_valid)
        jb      DT090           ; if 0 < sS,  S < 0.0
;;;;      mov     ah,al           ;clear all the flags, S > 0.0
        jmp     short DT099
DT090:
        lahf                    ;get flags to AH
        and     ah,C3+C0        ;mask to required flags
DT099:
        ret                     ;and return to caller

; tag is infinity, NaN, or empty
DT070:
        mov     ah,C3+C2+C0
        jmp     DT099

;do_test endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FCOM    mem         ST : mem
;
;       ES:DI is pointer to memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFCOM:
        mov     si,Areg      ;load first into the Areg
        mov     bx,FMbits           ;get format mask
        and     bl,ch
  cs    call    [vecFLD+bx]          ;get the input argument
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     di,bx               ;DI is destination, SI is source
        call    do_compare          ;return condition codes in AH

        and     byte [codes],~ (C3+C2+C0)    ;clear Status bits
        or      byte [codes],ah            ;set condition code bits
        jmp     restore_segs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FCOMP   mem         ST : mem
;
;       ES:DI is pointer to memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFCOMP:
        mov     si,Areg      ;load first into the Areg
        mov     bx,FMbits           ;get format mask
        and     bl,ch
  cs    call    [vecFLD+bx]          ;get the input argument
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     di,bx               ;DI is destination, SI is source
; tos pointer is in BX
        call    do_compare          ;return condition codes in AH

        and     byte [codes],~ (C3+C2+C0)    ;clear Status bits
        or      byte [codes],ah            ;set condition code bits
        jmp     pop_stack           ;BX is set



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FCOM    ST,ST(i)        R=0, P=0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FCOMrr:
        call    RRsetup         ;get source and destination reg. ptrs

        call    do_compare      ;do the comparison

        and     byte [codes],~ (C3+C2+C0)    ;clear Status bits
        or      byte [codes],ah            ;set condition code bits
; and exit
        jmp     restore_segs



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FCOMP   ST,ST(i)        R=0, P=0
;   FCOMPP  ST,ST(1)        R=1, P=1        watch out for R-bit
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FCOMPrr:
        mov     bl,cl           ;get source register
        call    regptr          ;get pointer to source
        mov     si,bx           ;source ptr to SI
        xor     bx,bx           ;get ST(0)
        call    regptr          ;get pointer to destination
        mov     di,bx           ;dest. ptr to DI
; tos pointer is in BX
        call    do_compare          ;return condition codes in AH
        and     byte [codes],~ (C3+C2+C0)    ;clear Status bits
        or      byte [codes],ah            ;set condition code bits

; pop the tos
        cmp     byte [bx+tag], tag_empty ;test for empty register
        je      under2
pop002:
        mov     byte [bx+tag], tag_empty     ;tag it empty
        inc     byte [tos]                 ;pop the stack
        and     byte [tos],7               ; **

; and exit
        jmp     test_pop        ;test for second pop


; signal stack underflow
under2:
        and     byte [codes],~ C1                ;indicate underflow
        push    errStkUnderflow+Sflag+Iexcept
        call    exception
        jmp     short pop002


; end em187f.asm

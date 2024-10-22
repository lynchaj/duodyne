; em187e.asm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; load IEEE 8-byte real to accumulator
;       es:di   points to value to load
;       si      points to accumulator to receive value
; uses: ax & dx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_R64:	;	    proc    near
  es    mov     dx, word [di+6]     ;get exponent
        xor     ax,ax
        shl     dx,1            ; sign goes to carry
        rcl     al,1            ; sign goes to AL
        mov     byte [si+sign], al
        shr     dx,5            ;dx is biased exponent
        or      dx,dx           ; test for zero
        jz      lr6401
        cmp     dx,2047         ; test for max exponent
        je      lr6411
        mov     byte [si+tag], tag_valid

        sub     dx,1023         ; get correct exponent
        mov     word [si+expon],dx   ;set the exponent
  es    mov     dl,[di+6]    ;get hi-part of mantissa
  es    mov     ax,[di+4]    ;get second 16 bits
  es    mov     bx,[di+2]    ;get third 16 bits
%if BIG
  es    mov     di,[di]      ;get lowest order 16 bits
        xor     bp,bp           ;zap lo-bit receiver
%endif
        mov     cx,4            ;count 4 shifts
lr6493:
        shr     dx,1            ;shift into carry
        rcr     ax,1            ;shift into ax
        rcr     bx,1            ;shift into bx
%if BIG
        rcr     di,1            ;shift into di
        rcr     bp,1            ;shift into bp
%endif
        loop    lr6493
; have mantissa in AX:BX[:DI:BP]
        stc
        rcr     ax,1            ;shift into ax
        rcr     bx,1            ;shift into bx
%if BIG
        rcr     di,1            ;shift into di
        rcr     bp,1            ;shift into bp
        mov     [si+mantis+6],bp
lr6495:
        mov     [si+mantis+4],di
        mov     [si+mantis+2],bx    ; **
        mov     [si+mantis],ax  ;set the internal form
%else
lr6495:
        mov     [si+mantis+2],bx    ; **
        mov     [si+mantis],ax  ;set the internal form
%endif

lr6499:
        ret


; biased exponent was 0
lr6401:
  es    mov     al,[di+6]            ;get highest mantissa
  es    or      ax,[di+4]
  es    or      ax,[di+2]            ;test for real zero
  es    or      ax,[di]
        jnz     lr6402           ; not a real zero
; got real zero
        mov     byte [si+tag], tag_zero
        mov     word [si+expon], exp_of_FPzero
lr64015:
        mov     [si+mantis], ax
        mov     [si+mantis+2], ax
%if  BIG
        mov     [si+mantis+4], ax
        mov     [si+mantis+6], ax
%endif
        jmp     lr6499

; biased exponent was 2047 -- possible infinity
lr6411:
        xor     ax,ax
  es    mov     dl, [di+7]
        and     dx,000Fh            ;check for zero mantissa
  es    or      dx,[di+4]
  es    or      dx,[di+2]
  es    or      dx,[di]
        jnz     lr6415              ; if not zero in packed form, NaN
        mov     byte [si+tag], tag_infin
lr6413:
        mov     word [si+expon], exp_of_FPinf
        jmp     lr64015

lr6415:
        push    Iexcept             ;Invalid operation
        call    exception           ;   exception
        mov     byte [si+tag], tag_invalid
        jmp     lr6413


; not a real zero -- actually a denormal
lr6402:
        push    Dexcept             ;Denormalized operand
        call    exception           ;  exception

  es    mov     ax,[di+5]            ;AH gets 4 highest bits of mantissa
  es    mov     bx,[di+3]
  es    mov     dh,[di]
  es    mov     di,[di+1]            ;destroy ES:DI as pointer
        mov     cx,4                ;shift by 4, trying to normalize
lr6405:
%if BIG
        shl     dh,1
        rcl     di,1
%else
        shl     di,1
%endif
        rcl     bx,1
        rcl     ax,1
        loop    lr6405              ;now it may be normalized
; dl is zero at this point, shift until fraction is normalized
lr6406:
        test    ah,80h              ;test the hi-bit
        jnz     lr6407              ;jump when normalized
%if BIG
        shl     dh,1
        rcl     di,1
%else
        shl     di,1
%endif
        rcl     bx,1
        rcl     ax,1
        inc     dl                  ;count the shifts needed
        jmp     lr6406              ;loop back
lr6407:
%if BIG
        mov     bp,dx               ;save away dx
%endif
        xor     dh,dh               ;clear hi part of dh
        add     dx,1023             ;bias the exponent
        neg     dx                  ;really is negative
        mov     word [si+expon],dx       ;set exponent
%if BIG
        mov     [si+mantis+6],bp    ;set highest part of mantissa
%endif
        jmp     lr6495
;load_R64    endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Store 64-bit real at ES:DI
;   SI points at accumulator to store
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
store_R64:	;	   proc    near
        cmp     byte [si+tag], tag_zero
        jae     sr64100                 ;go check on funny tag
        mov     bp,word [si+expon]           ;get exponent

        mov     ax,[si+mantis]
        mov     bx,[si+mantis+2]        ;get entire mantissa
        mov     dl,byte [si+sign]            ;sign to DL
%if BIG
        mov     dh,byte [si+mantis+7]
        mov     si,[si+mantis+4]        ;mantissa in AX:BX[:SI:DX]
        add     dh,04h                  ;round mantissa
        adc     si,0
        adc     bx,0
        adc     ax,0
        jc      sr64030
%else
        xor     dh,dh
        xor     si,si                   ;zero this word 
%endif

; discard the hidden bit
%if BIG
        shl     dh,1
        rcl     si,1
        rcl     bx,1
%else
        shl     bx,1
%endif
        rcl     ax,1
        clc
sr64030:
        adc     bp,0                    ;possible increment of exponent

        sub     bp,-1023                ;bias the exponent
        jle     sr64190                 ;return zero on underflow
        cmp     bp,2047                 ;test for maximum exponent
        jae     sr64210                 ;return infinity if overflow

;now move 4 bits into the result
        mov     cx,4
sr64060:
%if BIG
        shl     dh,1
        rcl     si,1
        rcl     bx,1
%else
        shl     bx,1
%endif
        rcl     ax,1
        rcl     bp,1
        loop    sr64060

        xor     dh,dh                   ;clear part of fraction
        ror     dx,1                    ;sign bit to hi position in DX
        or      dx,bp                   ;form final hi-word
  es    mov     [di],si              ;store low order
  es    mov     [di+2],bx
  es    mov     [di+4],ax
  es    mov     [di+6],dx            ;store sign & exponent
sr64099:
        ret


; skip to here on not (tag_valid)
sr64100:
        ja      sr64200                 ;further tag checking is needed

; store a real zero, signed if you please
sr64110:
        xor     ax,ax                   ;get a zero
sr64120:
        mov     bl,byte [si+sign]            ;get sign
        shr     bl,1                    ;sign to carry
        rcr     ax,1                    ;sign to hi-bit of word
sr64150:
  es    mov     [di+6],ax            ;store hi-word
        xor     bx,bx                   ;zap again for good measure
  es    mov     [di+4],bx            ;store second word
  es    mov     [di+2],bx
  es    mov     [di],bx
        jmp     sr64099                 ;go exit from one point

; store plus zero
sr64190:
        push    Uexcept                 ;underflow
        call    exception

        xor     ax,ax                   ;get +0.0
        jmp     sr64150

; tag is neither (tag_valid) nor (tag_zero)
sr64200:
        cmp     byte [si+tag], tag_infin     ;test for infinity
        je      sr64220
        jmp     short sr64250           ;return indefinite
; return signed infinity
sr64210:
        push    Oexcept                 ;overflow 
        call    exception
sr64220:
        mov     ax,7FF0h << 1          ;following code will put in sign
        jmp     sr64120
; return signed indefinite
sr64250:
        push    Iexcept                 ;invalid operation
        call    exception

        mov     ax,0FFF8h               ;following code will store value
        jmp     sr64150

;store_R64   endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Store 16-bit integer at ES:DI
;   SI points at accumulator to store
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
store_I16:	;	   proc    near
        cmp     byte [si+tag], tag_zero
        jae     s16100              ;go do further checking
        mov     ax,word [si+expon]       ;get exponent
        cmp     ax,15
        jge     s16150              ;go store indefinite
        mov     cx,63               ;get shift count
        sub     cx,ax               ; shift to lowest order
        mov     bx,si               ;get argument
        call    vloadsh64           ;get AX:BX:CX:DX
        call    round_mag           ;
        cmp     byte [si+sign],0         ;check for plus
        je      s16050              ; **
        neg     dx                  ;negate result
s16050:
  es    mov     [di],dx          ;store low order
        ret

; tag is not (tag_valid), check for other tags
s16100:
        je      s16120              ;tag zero
        push    Iexcept             ;
        jmp     short s16160        ;invalid, empty, or indefinite
; tag is (tag_zero)
s16120:
        xor     dx,dx               ; **
        jmp     s16050              ;store and exit

; exponent is too big
s16150:
        push    Oexcept             ;overflow
s16160:
        call    exception
        mov     dx,08000h           ;indefinite result
        jmp     s16050

;store_I16   endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Store 32-bit integer at ES:DI
;   SI points at accumulator to store
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
store_I32:	;	   proc    near
        cmp     byte [si+tag], tag_zero
        jae     s32100              ;go do further checking
        mov     ax,word [si+expon]       ;get exponent
        cmp     ax,31
        jge     s32150              ;go store indefinite
        mov     cx,63               ;get shift count
        sub     cx,ax               ; shift to lowest order
        mov     bx,si               ;get argument
        call    vloadsh64           ;get AX:BX:CX:DX
        call    round_mag           ;

        cmp     byte [si+sign],0         ;check for plus
        je      s32050              ; **
        not     cx                  ;is negative, negate the result
        neg     dx
        cmc
        adc     cx,0
s32050:
  es    mov     [di],dx          ;store low order
  es    mov     [di+2],cx        ;store high order
        ret

; tag is not (tag_valid), check for other tags
s32100:
        je      s32120              ;tag zero
        push    Iexcept             ;invalid operation
        jmp     short s32160              ;invalid, empty, or indefinite
; tag is (tag_zero)
s32120:
        xor     cx,cx               ;get zero result
        xor     dx,dx               ; **
        jmp     s32050              ;store and exit
s32150:
        push    Oexcept             ;overflow
s32160:
        call    exception
        xor     dx,dx               ;zero low order
        mov     cx,8000h           ;indefinite result
        jmp     s32050

;store_I32   endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FMUL    ST,ST(i)        R=0, P=0
;   FMUL    ST(i),ST        R=1, P=0
;   FMULP   ST(i),ST        R=1, P=1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FMULrr:
        call    RRsetup         ;get source and destination reg. ptrs
        mov     bx,di           ;BX is where final result will go

        push    test_pop ;fake call
        jmp     short do_mul          ;do the register to register MUL



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FMUL    mem         MUL memory to ST
;
;       ES:DI is pointer to memory location
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
genFMUL:
        mov     si,Areg      ;load first into the Areg
        mov     bx,FMbits           ;get format mask
        and     bl,ch
  cs    call    [vecFLD+bx]          ;get the input argument
        xor     bl,bl
        call    regptr              ;get ST pointer in BX
        mov     di,bx               ;DI is destination, SI is source
;  call to  do_mul  returns to  restore_segs
        push    restore_segs
        JMP     short do_mul




; OR of the tags was not 0, meaning both valid and non-zero
FM200:  
        and     cl,0FEh         ;save only hi-part (valid & zero are ok)
        jnz     FM210           ;allow zero
; one or both of the tags says zero
        pop     si
        mov     byte [si+tag], tag_zero  ;tag is tag_zero
        mov     word [si+expon], exp_of_FPzero
        xor     cx,cx           ;mantissa is zero
        xor     bp,bp           ;ditto
%if BIG
        mov     [si+mantis+6],cx
        mov     [si+mantis+4],cx
%endif
        jmp     FM085           ;go store mantissa




; error in tags, invalidate result
FM210:
        pop     si                  ; clean up the stack for now
        mov     byte [si+tag], tag_invalid
        push    Iexcept             ;signal exception
        call    exception
        jmp     FM090

; overflow occurred in adding the exponents
FM220:
        pop     si                  ; clean up the stack for now
        mov     byte [si+tag], tag_infin
        mov     word [si+expon], exp_of_FPinf
        push    Oexcept             ;signal exception
        call    exception
        jmp     FM090


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Multiply register - register
;       SI and DI point to operands
;       BX is place to put result, may be same as SI or DI
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
do_mul:		;	      proc    near
        push    bx              ;save place to which to move result
        mov     al,byte [si+tag]     ;get source tag
        mov     ah,byte [di+tag]     ;get dest tag
        mov     cl,al           ;copy tag
        or      cl,ah           ;or tags together
        jnz     FM200           ;if not both valid, something needs checking
; both tags are valid
        mov     al,byte [si+sign]    ;exclusive or the signs
        xor     al,byte [di+sign]    ; **
        mov     byte [bx+sign],al    ;

        mov     ax,word [si+expon]   ;add the exponents
        stc                     ; plus bias of 1
        adc     ax,word [di+expon]   ;
        jo      FM220           ;infintiy result
        mov     word [bx+expon],ax   ;store result exponent

%if BIG
        lea     si,[si+mantis+6]    ;final mantissa address
        lea     bx,[di+mantis+6]    ; **
        mov     word [mptr],si         ;save starting pointer value
        std
        xor     ax,ax           ;get zero
        mov     cx,8
        mov     di,mtemp+14  ;get final word in temporary
        mov     dx,ds           ;set up ES register
        mov     es,dx           ; **
    rep     stosw               ;clear the temporary
        mov     di,bx           ;
        mov     bx,mtemp+6   ;get address of mantissa temporary
        xor     bp,bp           ;clear carry word
        mov     byte [ctr],4           ;loop 4 times
        even
FM030:
        add     bx,8            ;point at lowest order word
        mov     cx,4            ;loop 4 times
        even
FM040:
        lodsw                   ;get multiplicand
        mul     word [di]   ;form product
        add     [bx],ax         ;add in low order
        dec     bx              ;don't disturb carry
        dec     bx              ; **
        adc     dx,bp           ;carry from this add is possible
        rcr     bp,1            ;save carry, get previous carry
        rol     bp,1            ;to low bit
        add     [bx],dx         ;
        adc     bp,0            ;get carry to next stage
        loop    FM040           ;loop back

; the carry out of this stage (in BP) is always 0

        mov     si,word [mptr]         ;get multiplicand start pointer
        dec     bx
        dec     bx
        dec     di
        dec     di
        dec     byte [ctr]
        jnz     FM030

        pop     si              ;get place to store mantissa
        mov     cx,[mtemp]      ;get mantissa
            mov     bp,word [mtemp+2]
        mov     dx,word [mtemp+4]
        mov     ax,word [mtemp+6]
        test    ch,80H          ;is it normalized?
        jnz     FM060

        dec     word [si+expon]      ;must shift by 1 to normalize
        shl     word [mtemp+8],1       ;get low order bit to carry
        rcl     ax,1            ;do the normalization
        rcl     dx,1            ;
        rcl     bp,1
        rcl     cx,1            ;last of normalization
FM060:
        mov     [si+mantis+6],ax    ;store the result
        mov     [si+mantis+4],dx    ; **
%else
        mov     bx,[si+mantis]  ;get hi-word of source
        mov     ax,[di+mantis]  ;get hi-word of dest
        mul     bx              ;DX:AX is  H*H
        mov     cx,dx           ;
        mov     bp,ax           ;CX:BP is  H*H
        mov     ax,[di+mantis+2]    ;get second word of dest
        mul     bx              ;CX:BP
                                ;   DX:AX
        add     bp,dx           ;CX:BP:AX
        adc     cx,0            ; account for any carry
        mov     bx,[si+mantis+2]    ;get second part of source
        mov     si,ax           ;CX:BP:SI
        mov     ax,[di+mantis]  ;get hi-word of dest
        mul     bx
        add     si,ax           ;align properly
        adc     bp,dx           ; **
        adc     cx,0            ;
        mov     ax,[di+mantis+2]    ;get low word of dest
        mul     bx              ;form low part of product
        add     dx,si           ;CX:BP:DX is now the result
        adc     bp,0            ;
        adc     cx,0            ;CX:BP is the manitssa
        pop     si              ;pointer to where to put it
        test    ch,80H          ;test for normalization
        jnz     FM080           ;go store if normalized
        dec     word [si+expon]      ;adjust the exponent
        shl     dx,1            ;get lowest bit
        rcl     bp,1            ;rotate into low order
        rcl     cx,1            ;rotate into high order
%endif
FM080:
        mov     byte [si+tag], tag_valid ;validate the result
FM085:
        mov     [si+mantis+2],bp    ;store low-part
        mov     [si+mantis],cx      ;store hi-part
FM090:
	cld
        ret


;do_mul  endp


; end em187e.asm

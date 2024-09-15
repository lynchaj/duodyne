; em187g.asm

;
; handle Indefinite input to FBLD
;
BL190:
        push    Iexcept                 ;invalid operation
        call    exception               ;   exception
        mov     byte [si+tag], tag_invalid   ;flag as invalid input
        and     al,01h                  ;mask to low bit
        mov     byte [si+sign],al            ;store the sign as put in
        jmp     restore_segs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FBLD    mem         load Tbyte BCD number
;
;       enter with ES:DI pointing at memory operand
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFBLD:
        call    alloc                   ;get new ST pointer in BX
        mov     si,bx                   ;destination pointer to SI
        add     di,9                    ;point at highest order byte
  es    mov     al,[di]                 ;get sign byte
        shl     al,1                    ;sign to carry flag
        rcl     al,1                    ;sign to low byte
        cmp     al,1                    ;test for indefinite
        ja      BL190                   ;sign is valid only if 0 or 1
        mov     byte [si+sign],al            ;store sign
        mov     byte [si+tag], tag_valid     ;store tag
        mov     byte [ctr],9                   ;count 9 bytes
        xor     ax,ax                   ;clear the result
        xor     bp,bp                   ;
        xor     bx,bx
        xor     cx,cx
        xor     dx,dx
BL010:
        dec     di                      ;get two digits
  es    mov     al,[di]              ; **
        or      al,al                   ;check for both zero
        jnz     BL030                   ;one is above zero
        dec     byte [ctr]                     ;count thru 9 bytes
        jne     BL010                   ;loop back
        je      BL040                   ;all digits are zero

BL020:
        call    times10                 ;result * 10
        dec     di                      ;get next digit
  es    mov     al,[di]              ; **
BL030:
        shr     al,4                    ;use high digit
        add     dx,ax                   ;add it to the result
        adc     cx,0                    ; **
        adc     bx,0                    ;  **
        adc     bp,0                    ;   **

        call    times10                 ;result * 10
  es    mov     al,[di]              ;get low digit
        and     al,0Fh                  ; **
        add     dx,ax                   ;add it to the result
        adc     cx,0                    ;
        adc     bx,0
        adc     bp,0

        dec     byte [ctr]                     ;count thru the bytes
        jne     BL020                   ;loop if some remain

        mov     ax,bp                   ;prepare to normalize
        mov     di,63                   ;exponent
%if BIG
        push    restore_segs     ;simulate call
        jmp     normalize_and_exit      ;will return
%else

BL055:
        or      ax,ax               ;test for hi zero
        jnz     short BL056
        xchg    bx,ax
        xchg    cx,bx
        xchg    dx,cx
        sub     di,16               ;decrease exponent
        jmp     BL055
BL056:
        or      ah,ah               ;test for hi zero byte
        jnz     short   BL057
        xchg    al,ah
        xchg    bh,al
        xchg    bl,bh
        xchg    ch,bl
        xchg    cl,ch
;;;        xchg    dh,cl
;;;        xchg    dl,dh
        sub     di,8                ;adjust exponent
BL057:
        test    ah,80H              ;test for normalized bit
        jnz     BL058

;;;        shl     dx,1                ;normalize a bit at a time
;;;        rcl     cx,1
           shl     ch,1

        rcl     bx,1
        rcl     ax,1
        dec     di                  ;decrease exponent
        jmp     BL057
%endif

BL058:  ; non-zero result
        mov     word [si+expon],di       ;store new exponent
        mov     [si+mantis],ax
        mov     [si+mantis+2],bx
        jmp     restore_segs


BL040:  ; zero result
        mov     byte [si+tag], tag_zero      ;result was zero
        mov     byte [si+sign],al            ;all regs are zero
        mov     di,exp_of_FPzero        ;zero has funny exponent
        jmp     BL058


; internal subroutine to multiply BP:BX:CX:DX by 10

times10:	;	 proc    near
        mov     word [mtemp],dx
        mov     word [mtemp+2],cx
        mov     word [mtemp+4],bx
        mov     word [mtemp+6],bp

        shl     dx,1                    ;times 2 to begin
        rcl     cx,1
        rcl     bx,1
        rcl     bp,1

        shl     dx,1                    ;times 4 to begin
        rcl     cx,1
        rcl     bx,1
        rcl     bp,1

        add     dx,word [mtemp]                ;times 5
        adc     cx,word [mtemp+2]
        adc     bx,word [mtemp+4]
        adc     bp,word [mtemp+6]

        shl     dx,1                    ;times 10
        rcl     cx,1
        rcl     bx,1
        rcl     bp,1
        ret                             ;done
;times10 endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FBSTP   mem         store Tbyte BCD number
;
;       enter with ES:DI pointing at memory destination
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFBSTP:
        push    ds                  ;save DS

        xor     bl,bl               ;ST(0) needed
        call    regptr              ;get BX pointing to stact top
        push    bx                  ;save pointer for later pop

        mov     dh,byte [bx+sign]        ;get sign of operand
        shr     dh,1                ;sign to carry
        rcr     dh,1                ;sign to hi-bit
        push    dx                  ;save sign byte in DH

        mov     al,byte [bx+tag]         ;get tag
        cmp     al,tag_zero         ;test for special tag
        jbe     BS010               ;if okay
; tag is funny, store indefinite
BS005:
        push    Iexcept             ;invalid operation
        jmp     short BS008
BS006:
        push    Iexcept+Oexcept     ;overflow & invalid
BS008:
        call    exception
  es    mov     word [di+8],0FFFFh   ;store indefinite
        jmp     short BS090         ;go do the proper pops

BS010:      ;tag was valid
        mov     cx,63               ;get max. shift
        sub     cx,word [bx+expon]       ;subtract exponent
        jle     BS006               ;signal invalid and overflow

        mov     si,bx               ;point SI at input, for 'round_mag'
        call    vloadsh64           ;load 64 bits, extend if necessary
        call    round_mag           ;round as specified

        push    es
        pop     ds                      

        mov     bp,dx           ;move low order word to BP
        XOR     DX,DX           ;DX = 0
        MOV     si,10000        ;WILL USE THIS CONSTANT QUITE A LOT

; START WITH 63 MAGNITUDE BITS
        DIV     si              ;AX = Q4, DX = R4
; AX MUST BE ZERO AT THIS POINT
        XCHG    AX,BX           ;AX = 3, BX = Q4
        DIV     si              ;DX = R3
        XCHG    AX,CX           ;AX = 2, CX = Q3
        DIV     si              ;DX = R2
        XCHG    AX,BP           ;AX = 1, BP = Q2
        DIV     si              ;DX = R1, AX = Q1
;;;        MOV     ds:[di],DX       ;SAVE LOWEST 4 DIGITS IN BINARY
        MOV     [di],DX       ;SAVE LOWEST 4 DIGITS IN BINARY

;CONTINUE WITH 50 MAGNITUDE BITS
        MOV     DX,BX           ;DX = 2 BITS OR LESS
        XCHG    AX,CX           ;CX = 1
        DIV     si              ;DX = R3
        XCHG    AX,BP           ;BP = Q3
        DIV     si              ;DX = R2
        XCHG    AX,CX           ;CX = Q2
        DIV     si              ;DX = R1, AX = Q1
;;;        MOV     ds:[di]+2,DX     ;SAVE SECOND SET OF 4 DIGITS IN BINARY
        MOV     [di+2],DX     ;SAVE SECOND SET OF 4 DIGITS IN BINARY

;CONTINUE WITH 37 MAGNITUDE BITS
        MOV     DX,BP           ;DX = 5 BITS OR LESS
        XCHG    AX,CX           ;CX = 1
        DIV     si              ;DX = R2
        XCHG    AX,CX           ;CX = Q2
        DIV     si              ;DX = R1, AX = Q1
        MOV     [di+4],DX     ;SAVE THIRD SET OF 4 DIGITS IN BINARY

;CONTINUE WITH 23 MAGNITUDE BITS
        MOV     DX,CX           ;DX = 7 BITS OR LESS
        DIV     si              ;DX = R1
        MOV     [di+6],DX     ;SAVE 4TH SET OF 4 DIGITS IN BINARY

;QUOTIENT IN AX IS 10 BITS OR LESS
        cmp     ax,99           ;must be .le. 99.
        ja      BS006           ;error if above 99

        LEA     SI,[di+6]      ;POINT AT FOURTH WORD AS SOURCE
        LEA     DI,[di+9]      ;POINT AT HIGHEST BYTE (SIGN BYTE)
        STD                     ;SET TO GO FROM HIGH TO LOW
        MOV     CX,5            ;SET FOR 5 WORDS        
        MOV     BP,100          ;DIVISOR OF 100
        MOV     BL,10           ;DIVISOR OF 10
        JMP     SHORT EMFBSTP11 ;ENTER LOOP AFTER LOAD

EMFBSTP10:
        LODSW                   ;GET 4 DIGITS IN BINARY
EMFBSTP11:
        XOR     DX,DX           ;DX = 0 FOR DIVIDE
        DIV     BP              ;DX IS LOW TWO DIGITS, AX IS HI DIGITS

        DIV     BL              ;AH IS LOWEST DIGIT, AL IS HIGH DIGIT
        SHL     AL,4
        OR      AL,AH           ;AL IS TWO DIGITS
        STOSB                   ;STORE DIGIT PAIR

        MOV     AX,DX           ;GET 2 LOWER DIGITS TO AX
        DIV     BL              ;AH IS LOWEST DIGIT, AL IS HIGH DIGIT
        SHL     AL,4
        OR      AL,AH           ;AL IS TWO DIGITS
        STOSB                   ;STORE DIGIT PAIR
        LOOP    EMFBSTP10       ;LOOP BACK
        
        INC     di              ;RESTORE di

; ADD SIGN TO RESULT
BS090:
        POP     DX              ;GET SAVED SIGN
        OR      [di+9],DH       ;SET SIGN BYTE

        pop     bx                  ;restore the tos pointer
        pop     ds                  ;restore DS pointer
        jmp     pop_stack           ;BX is set


        even
rnd_vec dw  nearest,nearest,  chop,up,  up,chop,  chop,chop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Name:  round_mag
;   Desc:  round the magnitude in AX:BX:CX:DX according to
;          the current rounding mode, and the Sign pointed at by
;          SI.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
round_mag:	;	   proc    near
        push    bx
        mov     bx,word [round]        ;get rounding control (0,2,4,6)
        add     bl,byte [si+sign]    ;get dispatch 0..7
        shl     bl,1            ; ** 0,2,4,6,..,14
  cs    jmp     [rnd_vec+bx]     ;dispatch to proper rounding mode

; round magnitude to nearest or even
nearest:
        test    byte [guard],80h       ;see if guard bit is set
        jz      chop            ;do nothing if not set
; guard bit is set
        test    byte [sticky],0FFh     ;see if sticky bit is set
        jnz     RM020           ;must increment if guard and sticky both set
; sticky is not set, round to even
        test    dl,01           ;see if low bit is set
        jnz     RM020           ;must increment to even if odd
        jz      chop            ;must leave even if already there

; round magnitude toward  + infinity
up:         ;increment magnitude if guard or sticky set
        mov     bx,word [guard_sticky] ;get guard and sticky bits
        or      bl,bh           ;see if either set
        jz      chop            ;done if neither set
; must increment the magnitude
RM020:  add     dx,1            ;must use ADD, not INC, to set carry flag
        adc     cx,0
        pop     bx
        adc     bx,0
        adc     ax,0
        jmp     short RM099     ;and exit

; chop means do nothing to the magnitude
chop:
        pop     bx              ;restore register
RM099:
        ret                     ;and return
;round_mag   endp




; shift was so big (>64), zero mantissa is the result
vl64100:
        xor     ax,ax
        xor     bx,bx
        xor     cx,cx
        xor     dx,dx
        mov     word [guard_sticky],00FFh  ;guard of zero, sticky set
        jmp     vl64099

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Name:  vloadsh64
;   Desc:  get the mantissa pointed to by BX, and shift right by
;          the amount in CX.  If 32 bit mantissa, extend to 64 bits.
;       Return result in  AX:BX:CX:DX
;       Compute the 'guard' and 'sticky' bits, also
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vloadsh64:	;	  proc    near
        cmp     cx,64       ;shift of 63 is the max for 64-bit mantissa
        ja      vl64100     ;go return zero

        push    si          ;counter will be here for 64-bit mantissa
        push    di          ;save register DI

%if BIG
%else
        cmp     cx,32       ;test for brief load
        jb      vl64005
        sub     cx,32       ;reduce by 32
        xor     ax,ax
        xor     di,di
        mov     si,[bx+mantis]      ;get first word
        mov     dx,[bx+mantis+2]    ;get the second
        jmp     short vl64007
        
vl64005:
%endif

        mov     ax,[bx+mantis]      ;first word of mantissa
        mov     di,[bx+mantis+2]    ;second word
%if BIG
        mov     si,[bx+mantis+4]    ;third word of mantissa
        mov     dx,[bx+mantis+6]    ;fourth word of mantissa
%else
        xor     si,si               ;third word of mantissa
        xor     dx,dx               ;fourth word of mantissa

vl64007:
%endif

        xor     bx,bx               ;BH is guard bit, BL is sticky bit
        cmp     cl,16               ;compare to 16
        jb      vl64020             ;skip 16 bit shifts if below 16
vl64010:
        or      bl,bh               ;guard into sticky
        shl     dh,1                ;isolate new guard bit in carry
        rcr     bh,1                ;guard bit to BH
        or      dl,dh               ;sticky in DL
        or      bl,dl               ;new sticky in BL
        mov     dx,si               ;shift by 16 bits
        mov     si,di               ;**
        mov     di,ax               ; **
        xor     ax,ax               ;  **
        sub     cl,16
        cmp     cl,16               ;compare if another 16-bit shift is needed
        ja      vl64010             ;loop back if above zero
vl64020:            ; check for 8 bit shift
        cmp     cl,8            
        jb      vl64040

        or      bl,bh           ;guard into sticky
        shl     dl,1            ;isolate new guard bit in carry
        rcr     bh,1            ;guard bit to BH
        or      bl,dl           ;new sticky in BL

        xchg    cx,si           ;do a long 8 bit shift
        mov     dl,dh
        mov     dh,cl
        xchg    bx,di           ;BX has 2 halves
        mov     cl,ch
        mov     ch,bl
        mov     bl,bh           ;do the short portion of an 8-bit shift
        mov     bh,al
        mov     al,ah
        xor     ah,ah
        xchg    cx,si           ;restore the exchanged registers
        xchg    bx,di

        sub     cl,8
vl64040:
        jcxz    vl64090         ;may have been reduced this far
        even
vl64050:
        or      bl,bh           ;guard into sticky
        shr     ax,1            ;short right shift of 1 bit
        rcr     di,1
        rcr     si,1            ;long extension, right shift 1 bit
        rcr     dx,1
        rcr     bh,1            ;new guard bit
        loop    vl64050
vl64090:
        and     bh,80h          ;isolate the real guard bit
        mov     word [guard_sticky],bx ;set guard and sticky bits
        mov     cx,si           ;result goes back in AX:BX:CX:DX
        mov     bx,di           ; **
        pop     di              ;restore saved register
        pop     si              ;restore saved register
vl64099:
        ret

;vloadsh64  endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FXTRACT             ST is operand
;
;       exponent replaces ST and significand is pushed,
;       with exponent of true 0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFXTRACT:
        xor     bl,bl               ;get tos ptr
        call    regptr              ;ST pointer to BX
        mov     si,bx               ;tos ptr to SI
        call    alloc               ;get new ST pointer

        mov     ax,[si]             ;move tag and sign
        mov     [bx],ax
        mov     word [bx+expon],0        ;zero is final exponent

        mov     ax,[si+mantis]      ;move mantissa
        mov     [bx+mantis],ax
        mov     ax,[si+mantis+2]
        mov     [bx+mantis+2],ax
%if BIG
        mov     ax,[si+mantis+4]
        mov     [bx+mantis+4],ax
        mov     ax,[si+mantis+6]
        mov     [bx+mantis+6],ax
%endif
        lea     di,[si+expon]       ; ES:DI points at integer to load
        push    ds                  ; SI points at accumulator to receive
        pop     es                  ;     the resulting value
        call    load_I16            ;
        jmp     restore_segs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSCALE          ST(1) is chopped to an integer
;                   and added to the exponent of ST(0)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFSCALE:
        mov     bl,1                ;get ST(1)
        call    regptr              ; pointer in BX
        mov     si,bx               ;save pointer in SI
%if BIG
        mov     cx,63               ;truncate to integer
%else
        mov     cx,31               ;truncate to integer
%endif
        sub     cx,word [bx+expon]       ;form number to shift by
        call    vloadshift          ;get the magnitude
%if  BIG
        mov     ax,cx               ;magnitude to ax
%endif
        test    byte [si+sign],01h       ;test sign of ST(1)
        jz      FSC10
        neg     ax                  ;value is negative
FSC10:
        xor     bl,bl
        call    regptr              ;get ST(0) pointer in BX
        add     word [bx+expon],ax       ;modify exponent

        jmp     restore_segs




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FSTP        QWORD PTR mem
;
;       ES:DI points at 64 bit integer
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FSTPi64:
        xor     bl,bl               ;get ST(0) pointer in BX
        call    regptr              ; **
        mov     si,bx               ;save pointer in SI
        cmp     byte [bx+tag], tag_zero  ;check the tag
        ja      STI64160            ;problem tag, store indefinite

        mov     cx,63               ;get max shift
        sub     cx,word [bx+expon]       ;get shift count
        jle     STI64150            ;shift is negative or zero, overflow occurs

        call    vloadsh64           ;get 64 bit mantissa, shifted

        call    round_mag           ;round magnitude according to RC bits

        cmp     byte [si+sign],0         ;test for minus
        je      STI64050
; must negate it
        not     ax
        not     bx
        not     cx
        neg     dx
        cmc
        adc     cx,0
        adc     bx,0
        adc     ax,0
; ready to store result
STI64050:
  es    mov     [di+6],ax            ;store high order
  es    mov     [di+4],bx            ;store lower order
  es    mov     [di+2],cx            ;store third part
  es    mov     [di],dx              ;store lowest order part
STI64090:
; pop the tos
        mov     bx,si                   ;set BX for pop
        jmp     pop_stack               ; go do pop


STI64150:   ; exponent too big
        push    Oexcept                 ;overflow
        jmp     short STI64170

STI64160:   ; tag is infin, empty or invalid
        cmp     byte [bx+tag], tag_infin     ;test for infinity
        je      STI64150                ;signal overflow

        push    Iexcept                 ;invalid operation

STI64170:   ;general problem exit, signal exception & store indefinite
        call    exception
  es    mov     word [di+6],8000h         ;integer indefinite
        xor     ax,ax
  es    mov     [di+4],ax
  es    mov     [di+2],ax
  es    mov     [di],ax
        jmp     STI64090                ;go pop and exit



; end em187g.asm

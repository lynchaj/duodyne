; em187.asm -- special emulator for 80186/80187
;
%define ABSLOAD 1
%define even align 2

;;;        .list		; ignored by Watcom ASSembler
;page 64,160
	cpu	186	;        .186


%ifdef   LONG
           ; use BIG=1 to assemble for 64 bit mantissa
%define BIG 1
%else
           ; use BIG=0 to assemble for 32 bit mantissa
%define BIG 0
%endif


 	segment	_TEXT public align=2 class='CODE'
;;;	segment EM187_DATA public align=2 class='DATA'

%include "../config.asm"
%include "../bda.inc"
%include  "em187d.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  The following are handled by "bda.inc"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;bios_data_seg	equ	40h	; BIOS data area segment

;  FPEM_segment	equ	0E6h	; use '../sizer' to determine
;        extrn  FPEM_segment:near


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Offsets in the EM187 data area are all
;    relative to the segment address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;	segment	EM187_DATA
	absolute  0
;
; the order:  Control, then Status may be important in the future
;  for FSTENV, FLDENV
;
;Control label   word
Control:
masks   resb	1               ; interrupt masks (see 'enables', below)
ctrl    resb	1               ; high order control bytes

;Status  label   word
Status:
flags   resb	1               ; error flags
codes   resb	1               ; condition codes

; the Tag word bits are distributed through the Accumulator data structure

save_ip:  resw	1		; IP of instruction causing exception
save_cs:  resw	1		; CS of ditto
data_offset:	resw	1
data_segment:	resw	1	; Data address in full
instruct    resw	1               ; copy of instruction saved here
round       resw	1               ; rounding control bits times 2 (0,2,4,6)
tos     resb	1               ; top of stack ptr
enables resb	1               ;interrupts that are enabled (not 'masks')

nFINIT	equ	($-Status)/2	; number of WORDs to clear

;guard_sticky  label word
guard_sticky:
sticky  resb	1               ;sticky if any bits set
guard   resb	1               ;guard bit in bit7

%if BIG
mptr    resw	1               ;multiplicand pointer
%endif

trptr   resw	1               ;transcendental pointer
trptr2  resw	1

ctr     resb	1               ;loop counter for MUL/DIV and FBLD

trctr   resb	1               ;transcendental counter

;mtemp   dw      8 dup (?)       ;mantissa temporary for 64x64 bit multiplication
mtemp	resw	8


;Areg    ACCUM   <>
Areg	resb	lenACCUM
lenAccum    equ     $-Areg
;Breg    ACCUM   <>
Breg	resb	lenACCUM

%if BIG
   
%define maxcon 19
%else
%define maxcon 11
%endif

;fp0     ACCUM   <>
fp0	resb	lenACCUM
;fp1     ACCUM   <>
fp1	resb	lenACCUM
;fp2     ACCUM   <>
fp2	resb	lenACCUM
;fp3     ACCUM   <>
fp3	resb	lenACCUM
;fp4     ACCUM   <>
fp4	resb	lenACCUM
;fp5     ACCUM   <>
fp5	resb	lenACCUM
;fp6     ACCUM   <>
fp6	resb	lenACCUM
;fp7     ACCUM   <>
fp7	resb	lenACCUM


;Creg    ACCUM   maxcon DUP (<>)
Creg	equ	$
	%rep	maxcon
	resb	lenACCUM
	%endrep
lenCreg     equ     $-Creg

;        public  EM187_DATA_PARAS
	global	EM187_DATA_PARAS
EM187_DATA_PARAS  equ     ($-Control+15)/16

;EM187_DATA   ENDS


;        assume  cs:_TEXT, ds:EM187_DATA


;_TEXT SEGMENT
	segment	_TEXT
;        assume  cs:_TEXT


; vector7 is entered when an ESC trap occurs, for any co-processor
;   instruction

	global  vector7

	even

vector7:	;  proc    far
        sti             ;re-enable interrupts
vector7a:
        pusha           ;save all the registers
        push    es      ; **
        push    ss
        push    ds      ; the order of these push'es is important
        mov     bp,sp   ;establish stack addressability
        mov     ax,ds   ;most used segment
        mov     es,ax   ;for argument address  ES:DI  -- used later
	cld		;will return with IRET

        lds     si,[v7_ip+bp]        ;get instruction stream pointer

%ifdef DEBUG
        mov     bx,[insptr]               ;get trace pointer
        sub     bx,4
;;;        cmp     bx,offset trace
        cmp     bx,trace
        jae     nowrap
;;;        mov     bx,offset tracee-4
        mov     bx,tracee-4
nowrap:
        mov     [insptr],bx               ;restore trace pointer
  cs    mov     word [bx],si      ;save IP of instruction
  cs    mov     word [bx+2],ds    ;save CS of instruction
        mov     [savesp],sp               ;save SP before pop
%endif

; check for segment override prefix

        lodsb
        or      al,al               ;test hi-bit of first byte
        js      vec002              ;not segment override
        mov     bl,al               ;move prefix to BX
        shr     bl,1                ;shift two bits to position
        shr     bl,1                ;**
        and     bx,0006h            ;mask for vectored jump
   cs   jmp     [override+bx]

	even

cs_over:
        mov     ax,ds               ;former CS to AX
        jmp     short vec001a       ;go continue
	even
ss_over:
        mov     ax,ss               ;set up override
        jmp     short vec001
	even
ds_over:
        mov     ax,[v7_ds+bp]        ;get saved DS
        jmp     short vec001a       ;go continue
	even
es_over:
        mov     ax,[v7_es+bp]        ;get saved ES

vec001a:
        mov     [v7_ss+bp],ax        ;set for [bp] addressing
vec001:
        mov     es,ax               ;set up override segment

; get first instruction byte

        lodsb                       ;get first instruction byte
vec002:
;;;;;;;;;;;
;  check for FWAIT
	cmp	al,9Bh		; FWAIT
	je	restore_segs
;;;;;;;;;;;
        mov     ch,al               ;save first instr. byte in ch
        lodsb
        mov     cl,al               ;save second in cl

; fast instruction decode

        mov     bx,cx               ;get mod, op-B, r/m bits
        rol     bl,1                ;
        rol     bl,1                ;get  r/m, mod  in low 5 bits
; may want to save BX at this point
        mov     dx,bx               ;save BX in DX for now
        and     bx,1Fh              ;mask to 5 bits
        shl     bx,1                ;set for word addressing
  cs    jmp     [adrmode+bx]         ;dispatch to proper address mode

mod_0_10:                           ;[bx+si]+d16
        mov     di,[v7_si+bp]
        add     di,[v7_bx+bp]
        jmp     vvw

mod_1_10:                           ;[bx+di]+d16
;;;        mov     di,[v7_di+bp]
        add     di,[v7_bx+bp]
        jmp     vvw

mod_2_10:                           ;[bp+si]+d16
        mov     di,[v7_si+bp]
        add     di,[v7_bp+bp]
        mov     es,[v7_ss+bp]        ;SS is used
        jmp     vvw

mod_0_01:                           ;[bx+si]+d8
        mov     di,[v7_si+bp]
        add     di,[v7_bx+bp]
        lodsb
        cbw
        jmp     vvb

mod_3_10:                           ;[bp+di]+d16
;;;        mov     di,[v7_di+bp]
        add     di,[v7_bp+bp]
        mov     es,[v7_ss+bp]        ;SS is used
        jmp     vvw

mod_1_01:                           ;[bx+di]+d8
;;;        mov     di,[v7_di+bp]
        add     di,[v7_bx+bp]
        lodsb
        cbw
        jmp     vvb

mod_2_01:                           ;[bp+si]+d8
        mov     di,[v7_si+bp]
        add     di,[v7_bp+bp]
        mov     es,[v7_ss+bp]        ;SS is used
        lodsb
        cbw
        jmp     short vvb

mod_3_01:                           ;[bp+di]+d8
;;;        mov     di,[v7_di+bp]
        add     di,[v7_bp+bp]
        mov     es,[v7_ss+bp]        ;SS is used
        lodsb
        cbw
        jmp     short vvb

mod_0_00:                           ;[bx+si]
        mov     di,[v7_si+bp]
        add     di,[v7_bx+bp]
        jmp     short vvv

mod_1_00:                           ;[bx+di]
;;;        mov     di,[v7_di+bp]
        add     di,[v7_bx+bp]
        jmp     short vvv

mod_2_00:                           ;[bp+si]
        mov     di,[v7_si+bp]
        add     di,[v7_bp+bp]
        mov     es,[v7_ss+bp]        ;SS is used
        jmp     short vvv

mod_3_00:                           ;[bp+di]
;;;        mov     di,[v7_di+bp]
        add     di,[v7_bp+bp]
        mov     es,[v7_ss+bp]        ;SS is used
        jmp     short vvv

mod_4_01:                           ;[si]+d8
        mov     di,[v7_si+bp]
        lodsb
        cbw
        jmp     short vvb

mod_5_01:                           ;[di]+d8
;;;        mov     di,[v7_di+bp]
        lodsb
        cbw
        jmp     short vvb

mod_6_01:                           ;[bp]+d8
        mov     di,[v7_bp+bp]
        mov     es,[v7_ss+bp]        ;SS is used
        lodsb
        cbw
        jmp     short vvb

mod_7_01:                           ;[bx]+d8
        mov     di,[v7_bx+bp]
        lodsb
        cbw
        jmp     short vvb

mod_4_10:                           ;[si]+d16
        mov     di,[v7_si+bp]
        jmp     short vvw

mod_5_10:                           ;[di]+d16
;;;        mov     di,[v7_di+bp]
        jmp     short vvw

mod_6_10:                           ;[bp]+d16
        mov     di,[v7_bp+bp]
        mov     es,[v7_ss+bp]        ;SS is used
        jmp     short vvw

mod_7_10:                           ;[bx]+d16
        mov     di,[v7_bx+bp]
        jmp     short vvw

mod_4_00:                           ;[si]
        mov     di,[v7_si+bp]
        jmp     short vvv

mod_5_00:                           ;[di]
;;;        mov     di,[v7_di+bp]
        jmp     short vvv

mod_7_00:                           ;[bx]
        mov     di,[v7_bx+bp]
        jmp     short vvv

mod_6_00:                           ;D16 -- simple variable
        xor     di,di
vvw:
        lodsw
vvb:
        add     di,ax
vvv:

;  ES:DI is pointer to argument

;;;        mov     ax,seg EM187_DATA
	call	get_data_segment	; to AX and DS
;;;
;;;        mov     ds,ax               ;set up addressing
;;;        assume  ds:EM187_DATA

        mov     [instruct],cx       ;save instruction
;;
	mov	bx,dx
	shr	bx,5
	and	bx,0011111b	 ; FSTENV or FSAVE? mask (5bits)
	cmp	bx,0001110b	; one of the above?
	je	bypass_SAV_ENV  ; do not muck up save areas if FSAVE or FSTENV
	mov	[data_offset],di	; save data address
	mov	[data_segment],es	; save data segment
	mov	bx,[v7_ip+bp]	; save instruction IP
	mov	[save_ip],bx
	mov	bx,[v7_cs+bp]	; save instruction CS
	mov	[save_cs],bx
bypass_SAV_ENV:
;;
        mov     [v7_ip+bp],si        ;update return address
        mov     bx,dx               ;move opA-opB to BX
        shr     bx,4                ;get fmt12t dispatch index
        and     bx,7Eh              ;mask to 6 bits, set for word address
  cs    jmp     [fmt12t+bx]          ;dispatch

;
; MOD == 11 --  R/R instructions

mod_x_11:
        mov     [v7_ip+bp],si        ;update return address

;;;        mov     ax,seg EM187_DATA
	call	get_data_segment	; to AX and DS
;;;        mov     ds,ax               ;set up addressing

        mov     es,ax               ; from both DS and ES
        mov     [instruct],cx         ;save instruction


        mov     ax,0720H            ;get special mask
        and     ax,cx               ;mask instruction word
        cmp     ax,0120H            ;test for format 4
        je      fmt04
        cmp     ax,0320H            ;test for format 5
        je      fmt05
fmt03:
        and     ah,01H              ;mask op-A
        shl     ah,1
        mov     bx,38H
        and     bl,cl               ;form op-B
        shr     bx,1
        add     bl,ah               ;form  op-B || op-A
  cs    jmp     [fmt03t+bx]
fmt04:
        mov     bx,001fH            ;5 bit mask
        and     bx,cx               ;form op
        shl     bx,1
  cs    jmp     [fmt04t+bx]
fmt05:
        mov     bx,001fH            ;5 bit mask
        and     bx,cx
        shl     bx,1
  cs    jmp     [fmt05t+bx]


gFYL2XP1:

gFENI:
gFDISI:
gSETPM:
gFLDENV:
gFSTENV:
gFRSTOR:
gFSAVE:
unimplemented:
        push    errUnemulated
        call    exception
        jmp     short restore_segs

underflow:
;;;        and     codes,NOT C1                ;indicate underflow
        and     byte [codes],~C1                ;indicate underflow
        push    errStkUnderflow+Sflag+Iexcept
        call    exception
        jmp     short pop001

test_pop:
        test    byte [instruct+1],Pbit     ;test for pop
        jz      restore_segs
;
;   pop stack, not knowing where ST(0) is
;
pop_the_tos:
        xor     bx,bx               ;use ST(0)
        call    regptr              ;get pointer in BX
;
;   pop stack, assuming FPac pointer is in BX
;
pop_stack:
        cmp     byte [bx+tag], tag_empty
        je      underflow           ;can't pop an empty register
pop001:
        mov     byte [bx+tag], tag_empty     ;tag it empty
        inc     byte [tos]                 ;pop the stack
        and     byte [tos],7               ; **

restore_segs:
%ifdef DEBUG
        cmp     [savesp],sp           ;check sp on exit
        je      rExit
        jmp     short restore_segs
rExit:
%endif
        pop     ds
        add     sp,2    ;skip over ss
        pop     es
        popa            ;pop the rest
vector7z:
        iret            ;and return

;;;vector7 endp



	even
%ifdef DEBUG
insptr      dw      trace
savesp      resw	1
%endif



adrmode dw      mod_0_00, mod_0_01, mod_0_10, mod_x_11
        dw      mod_1_00, mod_1_01, mod_1_10, mod_x_11
        dw      mod_2_00, mod_2_01, mod_2_10, mod_x_11
        dw      mod_3_00, mod_3_01, mod_3_10, mod_x_11
        dw      mod_4_00, mod_4_01, mod_4_10, mod_x_11
        dw      mod_5_00, mod_5_01, mod_5_10, mod_x_11
        dw      mod_6_00, mod_6_01, mod_6_10, mod_x_11
        dw      mod_7_00, mod_7_01, mod_7_10, mod_x_11

%include "em187a.asm"
%include "em187b.asm"
%include "em187c.asm"
%include "em187e.asm"
%include "em187f.asm"
%include "em187g.asm"
%include "em187h.asm"


	even
%if BIG
patanCon:
;	ACCUM   <tag_valid, 0, -2, 08930H, 0a2f4H, 0f66aH, 0b18aH>	; T1=tan(15deg.)
	db	tag_valid, 0
	dw	-2, 08930H, 0a2f4H, 0f66aH, 0b18aH	; T1=tan(15deg.)
;	ACCUM   <tag_valid, 0, -1, 0860aH, 091c1H, 06b9bH, 02c23H>	; pi/6
	db	tag_valid, 0
	dw	-1, 0860aH, 091c1H, 06b9bH, 02c23H	; pi/6
;	ACCUM   <tag_valid, 0,  0, 0ddb3H, 0d742H, 0c265H, 0539eH>	; sqrt(3)
	db	tag_valid, 0
	dw	 0, 0ddb3H, 0d742H, 0c265H, 0539eH	; sqrt(3)
;	ACCUM   <tag_valid, 1,  0, 08000H, 0H, 0H, 0H>			; -1
	db	tag_valid, 1
	dw	 0, 08000H, 0H, 0H, 0H			; -1
;	ACCUM	<tag_valid, 0, -5, 08d3dH, 0cb08H, 0d3dcH, 0b08dH>	; c14
	db	tag_valid, 0
	dw	-5, 08d3dH, 0cb08H, 0d3dcH, 0b08dH	; c14
;	ACCUM	<tag_valid, 0, -5, 097b4H, 025edH, 0097bH, 0425fH>	; c13
	db	tag_valid, 0
	dw	-5, 097b4H, 025edH, 0097bH, 0425fH	; c13
;	ACCUM	<tag_valid, 0, -5, 0a3d7H, 00a3dH, 070a3H, 0d70aH>	; c12
	db	tag_valid, 0
	dw	-5, 0a3d7H, 00a3dH, 070a3H, 0d70aH	; c12
;	ACCUM	<tag_valid, 0, -5, 0b216H, 042c8H, 0590bH, 02164H>	; c11
	db	tag_valid, 0
	dw	-5, 0b216H, 042c8H, 0590bH, 02164H	; c11
;	ACCUM	<tag_valid, 0, -5, 0c30cH, 030c3H, 00c30H, 0c30cH>	; c10
	db	tag_valid, 0
	dw	-5, 0c30cH, 030c3H, 00c30H, 0c30cH	; c10
;	ACCUM	<tag_valid, 0, -5, 0d794H, 035e5H, 00d79H, 0435eH>	; c09
	db	tag_valid, 0
	dw	-5, 0d794H, 035e5H, 00d79H, 0435eH	; c09
;	ACCUM	<tag_valid, 0, -5, 0f0f0H, 0f0f0H, 0f0f0H, 0f0f1H>	; c08
	db	tag_valid, 0
	dw	-5, 0f0f0H, 0f0f0H, 0f0f0H, 0f0f1H	; c08
;	ACCUM	<tag_valid, 0, -4, 08888H, 08888H, 08888H, 08889H>	; c07
	db	tag_valid, 0
	dw	-4, 08888H, 08888H, 08888H, 08889H	; c07
;	ACCUM	<tag_valid, 0, -4, 09d89H, 0d89dH, 089d8H, 09d8aH>	; c06
	db	tag_valid, 0
	dw	-4, 09d89H, 0d89dH, 089d8H, 09d8aH	; c06
;	ACCUM	<tag_valid, 0, -4, 0ba2eH, 08ba2H, 0e8baH, 02e8cH>	; c05
	db	tag_valid, 0
	dw	-4, 0ba2eH, 08ba2H, 0e8baH, 02e8cH	; c05
;	ACCUM	<tag_valid, 0, -4, 0e38eH, 038e3H, 08e38H, 0e38eH>	; c04
	db	tag_valid, 0
	dw	-4, 0e38eH, 038e3H, 08e38H, 0e38eH	; c04
;	ACCUM	<tag_valid, 0, -3, 09249H, 02492H, 04924H, 09249H>	; c03
	db	tag_valid, 0
	dw	-3, 09249H, 02492H, 04924H, 09249H	; c03
;	ACCUM	<tag_valid, 0, -3, 0ccccH, 0ccccH, 0ccccH, 0cccdH>	; c02
	db	tag_valid, 0
	dw	-3, 0ccccH, 0ccccH, 0ccccH, 0cccdH	; c02
;	ACCUM	<tag_valid, 0, -2, 0aaaaH, 0aaaaH, 0aaaaH, 0aaabH>	; c01
	db	tag_valid, 0
	dw	-2, 0aaaaH, 0aaaaH, 0aaaaH, 0aaabH	; c01
;	ACCUM	<tag_valid, 0,  0, 08000H, 0H, 0H, 0H>			; c00
	db	tag_valid, 0
	dw	 0, 08000H, 0H, 0H, 0H			; c00
%else
patanCon:
;       ACCUM   <tag_valid, 0, -2, 08930H, 0a2f5H>	; T1=tan(15deg.)
	db	tag_valid, 0
	dw	-2, 08930H, 0a2f5H	; T1=tan(15deg.)
;	ACCUM   <tag_valid, 0, -1, 0860aH, 091c1H>	; pi/6
	db	tag_valid, 0
	dw	-1, 0860aH, 091c1H	; pi/6
;	ACCUM   <tag_valid, 0,  0, 0ddb3H, 0d743H>	; sqrt(3)
	db	tag_valid, 0
	dw	 0, 0ddb3H, 0d743H	; sqrt(3)
;	ACCUM   <tag_valid, 1,  0, 08000H, 00000H>			; -1
	db	tag_valid, 1
	dw	 0, 08000H, 00000H			; -1
;;;	ACCUM	<tag_valid, 0, -5, 0f0f0H, 0f0f1H>	; c08
;;;	ACCUM	<tag_valid, 0, -4, 08888H, 08889H>	; c07
;	ACCUM	<tag_valid, 0, -4, 09d89H, 0d89eH>	; c06
	db	tag_valid, 0
	dw	-4, 09d89H, 0d89eH	; c06
;	ACCUM	<tag_valid, 0, -4, 0ba2eH, 08ba3H>	; c05
	db	tag_valid, 0
	dw	-4, 0ba2eH, 08ba3H	; c05
;	ACCUM	<tag_valid, 0, -4, 0e38eH, 038e4H>	; c04
	db	tag_valid, 0
	dw	-4, 0e38eH, 038e4H	; c04
;	ACCUM	<tag_valid, 0, -3, 09249H, 02492H>	; c03
	db	tag_valid, 0
	dw	-3, 09249H, 02492H	; c03
;	ACCUM	<tag_valid, 0, -3, 0ccccH, 0cccdH>	; c02
	db	tag_valid, 0
	dw	-3, 0ccccH, 0cccdH	; c02
;	ACCUM	<tag_valid, 0, -2, 0aaaaH, 0aaabH>	; c01
	db	tag_valid, 0
	dw	-2, 0aaaaH, 0aaabH	; c01
;	ACCUM	<tag_valid, 0,  0, 08000H, 00000H>	; c00
	db	tag_valid, 0
	dw	 0, 08000H, 00000H	; c00
%endif
patanConLen 	equ	$-patanCon
%if (patanConLen > lenCreg)
	%error  not enough constant space in Creg
%endif



; ST (X) has problems -- is zero or inf.
;
PAT200:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   FPATAN          8087 partial arctangent
;
;	Compute arctangent (Y / X), where Y is in ST(1) and X is in ST(0).
;
;	Assume  0 <= Y < X < inf.
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gFPATAN:
        mov     cx,patanConLen/2        ;number of words to move
;;;        mov     si,OFFSET patanCon      ;start of constant list
        mov     si,patanCon      ;start of constant list
        call    moveconsts              ;address constants from DS

	xor	bl,bl			;get pointer to ST
	call	regptr			;BX points at X arg
	mov	si,bx			;SI is divisor
	mov	bl,1			;Y is ST(1)
	call	regptr
	mov	di,bx			;DI -> Y, SI -> X
	call	do_div			;ST(1) -> Y/X
	mov	bx,si			;propagate pointer to X arg
	cmp	byte [si+tag],tag_zero
;	jae	PAT90
	jb	PAT01
	jmp	PAT90
PAT01:
; SI and BX point at X input
;;;	mov	di,offset Creg		;DI is tan(15)
	mov	di,Creg			;DI is tan(15)
	call	do_compare		; compare [DI] : [SI]
	xor	si,si			;flag Y=0
	sahf				;set flags
	jae	PAT010
	push	bx			;save ST(1) pointer
	mov	si,bx			;SI -> X
;;;	mov	di,offset Creg + 2 * lenAccum
	mov	di, Creg + 2 * lenAccum
;;;	mov	bx,offset Areg		;destination
	mov	bx, Areg		;destination
	push	si
	push	di			;save argument pointers
	call	do_add			;SI -> X+S3
	pop	di
	pop	si
;;;	mov	bx,offset Breg
	mov	bx, Breg
	call	do_mul			;SI -> X*S3
;;;	mov	di,offset Creg + 3 * lenAccum	; -1
	mov	di, Creg + 3 * lenAccum	; -1
	mov	bx,si			;Breg is dest
	call	do_add
	mov	di,si			;numerator
;;;	mov	si,offset Areg		;denom.
	mov	si, Areg		;denom.
	pop	bx			;restore ST(1) pointer
	call	do_div
	mov	bx,si
;;;	mov	si,offset Creg + lenAccum	;Y=PI/6
	mov	si, Creg + lenAccum	;Y=PI/6
PAT010:				; BX is ST(1) pointer
	mov	[trptr2],si		;save pointer to Y param (0 or address)
	push	bx			;save ST(1) pointer
	mov	si,bx			;set to form X*X
	mov	di,bx
;;;	mov	bx,offset Breg		;XX in Breg
	mov	bx, Breg		;XX in Breg
	call	do_mul			;

;;;	mov	si,offset Creg + 4 * lenAccum	;C14/C06 pointer
	mov	si, Creg + 4 * lenAccum	;C14/C06 pointer
	mov	[trptr],si
%if BIG
	mov	byte [trctr],14
%else
	mov	byte [trctr],6
%endif
pat020:
;;;	mov	bx,offset Areg		;S in SI
	mov	bx, Areg		;S in SI
;;;	mov	di,offset Breg		;XX
	mov	di, Breg		;XX
	call	do_mul			;SI points at Areg
	mov	bx,si
	mov	di,[trptr]
	add	di,lenAccum
	mov	[trptr],di
	xor	byte [si+sign],1		;change sign of XX*S
	call	do_add			;SI points at S (Areg)
	dec	byte [trctr]
	jnz	pat020

	pop	bx			;restore ST(1) pointer
	mov	di,bx
	call	do_mul
	mov	bx,si
	mov	di,[trptr2]		;get possible Y
	or	di,di
	jz	PAT90
	call	do_add			;ST(1) = Y + X*S
PAT90:				; BX contains pointer to result
	jmp	pop_the_tos		;clear input X from stack top






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get FPEM_segment -- get data segment pointer to AX and DS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;	assume	ds:nothing
	global  get_data_segment
get_data_segment:	;	proc	near
	push	bios_data_seg	; get bios data area pointer
	pop	ds
.out0:
	mov	ax,word [FPEM_segment]	; get emulator segment
	or	ax,ax		; Allocated yet?
	jz	.allocate
.done:
	mov	ds,ax
	ret

; Allocate space for the Floating Point Emulator
.allocate:
%if FPEM_USE_EBDA
	mov     ax,[EBDA_paragraph]
        sub     ax,word EM187_DATA_PARAS
	mov     [EBDA_paragraph],ax
	mov     [FPEM_segment],ax
	shr     ax,6
	mov     [memory_size],ax
	jmp	.out0
%else
        mov     ax,bios_data_seg
        sub     ax,word EM187_DATA_PARAS
	mov     [FPEM_segment],ax
	jmp	.done
%endif
;get_data_segment	endp


;;;     assume  ds:EM187_DATA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   exception -- called from anywhere to signal setting
;               of exception flags.  Test for unmasked exceptions
;               should occur here.
;
;   Calling sequence:
;
;       push    FLAGBITS
;       call    exception
;
;
;   Returns with stack already popped.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
exception:		;    proc    near
        push    bp          ;create standard stack frame
        mov     bp,sp

        push    ax          ;save AX
        push    ds          ;save DS
;;;        mov     ax,seg EM187_DATA   ;get data segment
	call	get_data_segment	; to AX and DS
;;;        mov     ds,ax       ;set up DS

        mov     ax,[bp+4]   ;get bits to AX
        or      [flags],al    ;combine to flag word

;;;;;;;;;;;  JMP  EXC010

        test    al,[enables]  ;test for unmasked exceptions
        jnz     EXC010      ;there are unmasked exceptions
EXC005:
        pop     ds          ;restore DS
        pop     ax          ;restore AX
        leave               ;done
        ret     2           ;return, popping the stack


;   handle simple setting of unmasked error flags
EXC010:
        or      ah,ah       ;test for specific hi-bits
        jnz     EXC020      ;specific error flagged

        rol     al,1
        rol     al,1        ;discard hi-2 bits
        mov     ah,7        ;max error code + 1 to AH
EXC011:
        dec     ah          ;count down
        shl     al,1        ;move bit to carry
        jnc     EXC011      ;

        mov     al,ah       ;error code to AL
        jmp     EXC030      ;go call signal routine

EXC020:     ;specific high error flag
        mov     al,6        ;min error code -1 to AL
EXC021:
        inc     al
        shr     ah,1        ;flag bit to carry
        jnc     EXC021
EXC030:
        call    _FPSIGNAL   ;signal error
        jmp     EXC005      ;say nothing for now

;;;exception   endp

%if ABSLOAD
%include  "em187i.asm"
%endif

%ifdef DEBUG
trace       dd      200 dup (0)
tracee      label   dword
%endif

; number of paragraphs needed by the DATA area
	db	EM187_DATA_PARAS	; easy to see in the listing file

;;;_TEXT   ENDS
;;;        END

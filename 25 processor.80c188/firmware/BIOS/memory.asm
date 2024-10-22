;========================================================================
; MEMORY.ASM -- Memory management routines
;========================================================================
;
;   This version is for assembly by  NASM
;
; Copyright (C) 2011   John R. Coffman
; Provided for hobbyist use on the N8VEM SBC-188 board
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;========================================================================

        segment         _TEXT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  get_ramsize
;
;       Return the number of 1k blocks of RAM in AX
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_ramsize:
        push    ds
        push    bx
        push    cx
        xor     ax,ax           ; count of 1k intervals
        mov     bx,ax           ; segment address
.1:
        mov     ds,bx           ; set pointer
        cnop
        mov     cx,word [0]     ; save contents
        mov     word [0],0a56ch ; addressing is [DS:0]
        mov     bx,bx
        mov     ax,ax           ; waste time
        cmp     word [0],0a56ch ; see if it is the same
        jne     .9
        mov     word [0],cx     ; restore
        mov     cx,word [1020]
        mov     word [1020],05a32h  ; address [DS:1020]
        mov     ax,ax
        mov     bx,bx
        cmp     word [1020],05a32h
        jne     .9
        mov     word [1020],cx  ; restore

; Memory test succeeded at the address

        inc     ax              ; count 1k
        add     bx,1024/16      ; increment segment register by paragraphs
        jmp     .1

.9:
        pop     cx
        pop     bx
        pop     ds
        ret
        



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  BIOS_call_11h
;
;       Get Equipment Configuration
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BIOS_call_11h:          
        sti
        push    ds
        push    bios_data_seg
        pop     ds
        mov     ax,[equipment_flag]     ; pick it out of the BDA
        pop     ds
        iret




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  BIOS_call_12h
;
;       Get Conventional Memory Size
;
;  N.B.:  This BIOS call shares the interrupt vector with Timer 1.
;       Thus we need to see if an "int 12h" called us, otherwise
;       we assume this was a Timer 1 interrupt.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; stack
offset_SI	equ	0
offset_DS	equ	offset_SI+2
offset_IP       equ     offset_DS+2
offset_CS       equ     offset_IP+2
offset_FLAGS    equ     offset_CS+2

BIOS_call_12h:
        push    ds
        push    si
        mov     si,sp           ; establish stack addressing
   ss   lds     si,[offset_IP+si]
        cnop
        cmp     word [si-2],12CDh       ; int 12h
        pop     si
        je      .4
        popm	ds
; since the segment is already correct...
	extern	timer1_interrupt
	jmp	timer1_interrupt

.4:     push    bios_data_seg
        pop     ds
        mov     ax,[memory_size]
        pop     ds
        iret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Memory Test
;       Enter with segment to test in AX
;
;       Return: C=1 if error, (DI==loc)
;               C=0 if no error
;
;       AX, CX, DX, BP, DI, ES are all destroyed
;       DS, BX & SI are preserved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
memtest:
        pop     bp              ; save return address in BP
memtest0:                       ; entry to test page 0
        cld                     ; clear the direction flag
        mov     es,ax           ; set segment
        xor     di,di
        mov     ax,0A55Ah       ; alternating bits in alternating bytes
        mov     cx,8000h        ; test 64K (2 x 32K)
        rep stosw               ; 
        mov     ch,80h          ; 32K count of words
        repe scasw
        jne     .3

        xchg    al,ah           ; second pattern
        mov     ch,80h          ; 32K count of words
        rep stosw
        mov     ch,80h          ; 32K count of words
        repe scasw
        jne     .3
%if 1
seed1   equ     47F8h           ; NOT a random value
                                ; Seed values are chosen to have a relatively
                                ; prime cycle length, and to never produce a zero
                                ; Most random values will produce a zero!!!!

        mov     ax,seed1        ; seed value (critical)
                                ; cycle is 111 locations, relative prime to 2**15
        mov     ch,80h          ; 32K words
.t1:
    es  mov     [di],ax         ; store the value
        mul     ax
        inc     di
        mov     al,ah           ; generate the next bit pattern
        inc     di
        mov     ah,dl
%if 0
.t102:  or      ax,ax           ; trap a bad seed value
        jz      .t102
%endif
        loop    .t1             ; fill memory with the pattern

        mov     ax,seed1
        mov     ch,80h          ; 32K words
.t11:
    es  cmp     ax,[di]
        lea     di,[di+2]       ; don't touch the Zero flag
        jne     .3
        mul     ax
        mov     al,ah
        mov     ah,dl
        loop    .t11

%endif
        mov     ax,0FFFFh       ; solid pattern of 1's
        mov     ch,80h          ; 32K count of words
        rep stosw
        mov     ch,80h          ; 32K count of words
        repe scasw
        jne     .3
        
        xor     ax,ax           ; solid pattern of 0's
        mov     ch,80h          ; 32K count of words
        rep stosw
        mov     ch,80h          ; 32K count of words
        repe scasw
        jne     .3
        
        clc                     ; no error
        jmp     bp

.3: ; ERROR in scan string
        dec     di
   es   cmp     ah,[di]
        je      .4
        dec     di
.4:
        stc
        jmp     bp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; POST_memory -- Power On Self Test of Memory
;
;
;  Enter with:
;       AX = memory limit in kilobytes
;	DS = DGROUP
;	SS = bios_data_seg
;
;  Watch out, "memtest" clobbers segment registers
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
POST_memory:
        pushm   ALL,es	; ,ds
    ss	cmp	word [warm_boot],1234h
    ss 	mov	word [warm_boot],5678h	; non-magic value!!!
    	jne	.001
	push	ds
	push	msg_mem_bypass
	jmp	.print
.001:
        shl     ax,6                    ; memory size in paragraphs
        mov     bx,ax                   ; save in BX
.1:
        mov     dx,1000h                ; seg. 0000:xxxx has been tested
        sub     bx,dx
        jz      .8                      ; done if down to zero
        cmp     bx,dx
        jae     .2
        mov     bx,dx
.2:
        push    bx

        push    bx
        push    ds		;DGROUP
        push    msg_mem_test
        call    _cprintf
        add     sp,6 

        pop     bx
        mov     ax,bx                   ; AX is segment tested
        call    memtest

%if 0
;  induce an error to see printout
        mov     di,3465h
        stc
%endif
        jnc     .1
; make an error report

        mov     dx,di           ; copy byte address
        shr     di,4            ; convert to paragraphs
        add     di,bx           ; DI is total paragraphs
        and     dx,0Fh          ; single-byte byte address
        push    dx
        push    di
        push    ds		; DGROUP
        push    msg_mem_error
        call    _cprintf
        add     sp,8

        jmp     .1

.8:
%if SOFT_DEBUG==0
; tested down to 1000:0000
; now do the test at loc. 0  (watch out for the stack)
        push    bx                      ; BX is zero
        push    ds		; DGROUP
        push    msg_mem_test
        call    _cprintf
        add     sp,6 

        pushm   f,ds
        cli                             ; disable interrupts

        push    0
        pop     ds                      ; source is 0000:xxxx
        push    1000h           
        pop     es                      ; dest. is 1000:xxxx (save area)
        xor     si,si
        xor     di,di
        mov     cx,8000h                ; 32k words == 64K bytes
        rep movsw

        xor     ax,ax
        mov     bp,.85
        jmp     memtest0
.85:
%if 0
        stc
        mov     di,8765h                ; force error reporting
%endif
        sbb     dx,dx                   ; grab the returned carry
        mov     bx,di                   ; save error location
        
        push    1000h                   ; source is 1000:xxxx
        pop     ds
        push    0
        pop     es                      ; restore 0000:xxxx
        xor     si,si
        xor     di,di
        mov     cx,8000h                ; 32k words == 64K bytes
        rep movsw

        push    ds
        pop     es
        xor     ax,ax
        mov     ch,80h                  ; re-zero 1000:0000 ...
        rep stosw

        popm    f,ds
%endif
        shr     dx,1                    ; set the carry
        jnc     .89

; make the page 0 error report
        push    bx
        push    ds			; DGROUP
        push    msg_mem_error0
        call    _cprintf
        add     sp,6

.88:    hlt
        jmp     .88

.89:
        push    ds			; DGROUP
        push    msg_mem_done
.print:
        call    _cprintf
        add     sp,4
.9:
        popm    ALL,es ; ,ds
        ret


        segment CONST
msg_mem_test:
        db      CR,"%8aTesting memory at %7a%04x:0",NUL
msg_mem_done:
        db      CR,"%2aP.O.S.T. of memory %10aSUCCESSFUL        "
msg_mem_double:
        db      NL,NL,NUL
msg_mem_bypass:
	db	CR,"%8aP.O.S.T. of memory BYPASSED  ",NL,NL,NUL
msg_mem_error:
        db      BEL,NL,"%14aMemory error at %04x%x",NL,NUL
msg_mem_error0:
        db      BEL,NL,"%14aMemory error at 0%04x",NL,NL
        db      "**************************",NL
        db      "*     CATASTROPHE!!!     *",NL
        db      "**************************",NL,NL
        db      "Halting due to error in segment 0000:xxxx",BEL,NL
        db      NUL
	db	0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       Expanded Memory (EMM/4MEM) support -- LIM EMS
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%if EMM_BOARDS

 %if SBC188<3
; Define the UMB mask; '1' bit means allocate it
UMB_MASK_80     equ     ~(0FFFFh<<((RAM_DOS-RAM)/16))   ; segments 8000,9000
                                                        ; skip A000,B000
UMB_MASK_C0     equ     0FFFFh>>(CHIP/16)                ; segments C000,D000,...
                                                        ; up to start of ROM
 %else
UMB_MASK_80	equ	0000h
UMB_MASK_C0	equ	0000h		; nothing to allocate on v3 board
 %endif        

        segment CONST
emm_board_list:

%assign xemm EMM0
%rep    EMM_BOARDS
        dw      xemm
%assign xemm (xemm+EMM1-EMM0)
%endrep
        dw      -1

        segment _TEXT
EMM_init0:
        pushm   ds,all
;;        cld           ; already done!
        push    DGROUP               ; address CONST segment
        popm    ds
        mov     si,emm_board_list

; clear all of the paging registers
; with no reads, the board(s) remain disabled for now
.0:     lodsw           ; get page data reg I/O code
        inc     ax      ; get address reg I/O code
        jz      .3
        mov     dx,ax
        mov     cx,64   ; number of address reg entries
.1:
        mov     ax,cx
        dec     ax      ; 
        out     dx,al   ; set the address
        dec     dx      ; get page data reg I/O code
        mov     al,EMM_unmapped
        out     dx,al
        inc     dx      ; get address reg I/O code
        loop    .1
        jmp     .0      ; go on to the next board

; assign memory above 512K, usually up to the 640K limit
.3:
        mov     dx,[emm_board_list]
        mov     bx,RAM/16       ; get size of physical RAM chip
 check  (RAM-512)
        mov     cx,UMB_MASK_80 & 0FFFFh  ; bits to allocate
        mov     si,UMB_MASK_C0 & 0FFFFh  ; **
.4:
        mov     di,cx           ; test for done
        or      di,si
        jz      .6

        shr     si,1            ; shift bit into carry
        rcr     cx,1            ; carry is next to allocate
        jnc     .5              ; skip allocation if zero

        inc     dx
        mov     al,bl           ; page address
        out     dx,al           ; set address
        dec     dx
        mov     al,bh
        out     dx,al
        nop
        in      al,dx           ; enable board
        cmp     bh,al
        jne     .9

        inc     bh              ; increment page
.5:     inc     bl              ; increment address
        jmp     .4              ; loop back
; all of the Upper Memory Blocks are allocated (no EMS yet)
.6:
        in      al,dx           ; enable board if not done above
        
        push    bios_data_seg
        pop     ds
        mov     [EMS_start],bh  ; save start page
.9:
        popm    ds,all
        ret
%endif


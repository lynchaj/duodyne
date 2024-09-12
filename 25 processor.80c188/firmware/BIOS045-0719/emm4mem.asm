;========================================================================
; emm4mem.asm
;
;  LIM EMS 3.2 driver for the N8VEM 4MEM board used with the SBC-188
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
;
%define MAJOR_VERSION 2
%define MINOR_VERSION 0
%define VERSION_SUFFIX ""
%define DATE "30-Jan-2013"
;
;
%ifndef SOFT_DEBUG
%define SOFT_DEBUG 0
%endif
%ifndef TRACE
%define TRACE 0
%endif
%include "config.asm"
%include "cpuregs.asm"

FRAME0          equ     (0F000h - (ROM<<6))          ; default Frame segment
NUM_HANDLES     equ     16      ; number of Handles
HANDLE_BASE     equ     3456h   ; base handle #
NUM_MAP_BLKS    equ     32      ; number of memory manager blocks


;
;
; The request block structure
                struc   rq_block
rq_length       resb    1       ; length of request block
rq_unit         resb    1       ; unit number (block devices)
rq_command      resb    1       ; command code
rq_status       resw    1       ; return status
rq_reserved05   resb    8       ; reserved for DOS
rq_ret_units    resb    1       ; number of units (returned)
rq_ret_freemem  resd    1       ; seg:offset of top of free memory
rq_config_sys   resd    1       ; seg:offset of CONFIG.SYS
rq_ret_BPB      equ     rq_config_sys
rq_first_unit   resb    1       ; first unit number
rq_reserved17   resb    9       ; fill to 32 bytes
                endstruc


; The EMM map structure
                struc   emm_map
map_count       resb    1       ; count of contiguous blocks
map_start       resb    1       ; block number of first block
map_link        resw    1       ; index of next block in chain (FFFF=end)
map_board       equ     map_link+1      ; high 4 bits contain board #
map_length      equ     $
                endstruc



DONE    equ     0100h           ; DONE bit
CR      equ     0Dh
LF      equ     0Ah
NUL     equ     00h


; Standard int 13h stack frame layout is 
; created by:   PUSHM  ALL,DS,ES
;               MOV    BP,SP
;
offset_DI       equ     0
offset_SI       equ     offset_DI+2
offset_BP       equ     offset_SI+2
offset_SP       equ     offset_BP+2
offset_BX       equ     offset_SP+2
offset_DX       equ     offset_BX+2
offset_CX       equ     offset_DX+2
offset_AX       equ     offset_CX+2
offset_DS       equ     offset_AX+2
offset_ES       equ     offset_DS+2
offset_IP       equ     offset_ES+2
offset_CS       equ     offset_IP+2
offset_FLAGS    equ     offset_CS+2

; The byte registers in the stack
offset_AL       equ     offset_AX
offset_AH       equ     offset_AX+1
offset_BL       equ     offset_BX
offset_BH       equ     offset_BX+1
offset_CL       equ     offset_CX
offset_CH       equ     offset_CX+1
offset_DL       equ     offset_DX
offset_DH       equ     offset_DX+1


; EMS int 67h error codes
;
FN_GOOD         equ     0

FN_INTERNAL_ERR equ     80h     ; internal software error
FN_HARDWARE_ERR equ     81h     ; EMS hardware error
FN_INVALID_HANDLE  equ  83h     ; invalid handle
FN_UNDEFINED    equ     84h     ; undefined function
FN_NO_HANDLE    equ     85h     ; no more handles available
FN_SAVE_RESTORE equ     86h     ; error in save or restore of mapping context
FN_NO_PHYS_PAGES   equ  87h     ; requested more physical pages than available; none allocated
FN_NO_LOG_PAGES equ     88h     ; requested more logical pages than available; none allocated
FN_ZERO_REQUEST equ     89h     ; zero pages requested
FN_LOG_PAGE_ERR equ     8Ah     ; logical page not assigned to this handle
FN_PHYS_PAGE_ERR   equ  8Bh     ; physical page number invalid
FN_SAVE_AREA_FULL  equ  8Ch     ; mapping hardware state save area full
FN_SAVE_FAILED  equ     8Dh     ; save context failed because context already associated with
                                ;  the current handle
FN_RESTORE      equ     8Eh     ; restore failed; save area has no context for the handle
FN_SUBFN_UNDEF  equ     8Fh     ; sub-function undefined





; beginning of Driver

; The driver Header:
        dd      -1
        dw      8000h                   ; flag as character device
        dw      strategy
        dw      interrupt
        db      "EMMXXXX0"


dispatch:
        dw      fn40    ; Get Manager Status
        dw      fn41    ; Get Page Frame Segment
        dw      fn42    ; Get Number of Pages
        dw      fn43    ; Get Handle and Allocate Memory
        dw      fn44    ; Map Memory
        dw      fn45    ; Release Handle and Memory
        dw      fn46    ; Get EMM Version
        dw      fn47    ; Save Mapping Context
        dw      fn48    ; Restore Mapping Context
        dw      fn49    ; reserved -- old get h/w array
        dw      fn4A    ; reserved -- old get log. to phys. array map
        dw      fn4B    ; Get Number of EMS Handles
        dw      fn4C    ; Get Pages Owned by Handle
        dw      fn4D    ; Get Pages for All Handles
        dw      fn4E    ; Get/Set Page Map

ndispatch       equ     ($-dispatch)/2



bios_call_67h:
;       sti                     ; interrupts on/off        
%if TRACE
        pushm   all,ds,es
        mov     al,'c'
        call    putchar
        mov     al,ah
        call    bout
        popm    all,ds,es
%endif
        pushm   all,ds,es
        mov     bp,sp           ; standard BIOS stack frame
        cld
        pushm   cs
        popm    ds              ; address the Data Base from

        mov     si,ax           ; save AX
        sub     ah,40h          ; base function codes at zero
        cmp     ah,ndispatch    ; check for valid code
        jae     undefined

        mov     al,ah           ; zero based index to AL
        cbw                     ; zap high byte
        xchg    si,ax           ; restore AX, SI is index
        add     si,si           ; index*2 for word table
        jmp     [dispatch + si] ; dispatch to function



internal_error:
        mov     ah,FN_INTERNAL_ERR      ; internal software error
        jmp     error_exit
undefined:
        mov     ah,FN_UNDEFINED         ; undefined function
        jmp     error_exit
good_exit:
        xor     ah,ah
error_exit:
        mov     [bp+offset_AH],ah       ; return error code
%if TRACE
        pushm   ax
        mov     al,ah
        call    bout
        mov     al,'r'
        call    putchar
        popm    ax
%endif
        mov     sp,bp                   ; restore SP
        popm    all,ds,es
        iret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 40h -- Get EMM Manager Status
;
;  Enter With:
;       AH = function code 40h
;
;  Exit With:
;       AH = 0          good return
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn40    equ     good_exit



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 41h -- Get Page Frame Segment
;
;  Enter With:
;       AH = function code 41h
;
;  Exit With:
;       AH = 0          good return
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn41:
        mov     bx,[frame]
        mov     [bp+offset_BX],bx
        jmp     good_exit



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 42h -- Get Number of Pages
;
;  Enter With:
;       AH = function code 42h
;
;  Exit With:
;       AH = 0          good return
;       BX = number of unallocated pages
;       DX = total number of pages in system
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn42:
        mov     ax,[npages]
        mov     [bp+offset_DX],ax
        call    count_avail
        mov     [bp+offset_BX],ax
        jmp     good_exit




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 43h -- Get Handle and Allocate Memory
;
;  Enter With:
;       AH = function code 43h
;       BX = number of logical pages to allocate
;
;  Exit With:
;       AH = 0          good return
;       DX = handle     
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn43:
        cmp     bx,[npages]     ; check against total pages
        mov     ah,FN_NO_PHYS_PAGES     ; 
        ja      error_exit      ; RQ more that physically present

        call    count_avail     ; count pages available
        cmp     ax,bx
        mov     ah,FN_NO_LOG_PAGES
        jb      error_exit      ; RQ more that currently available
        
        or      bx,bx
        mov     ah,FN_ZERO_REQUEST
        jz      error_exit      ; RQ zero pages ????

; find a handle
        mov     cx,NUM_HANDLES
        xor     si,si
.1:
	cmp	word [handle_list + si], -1
	je	.2			; available if == -1

        add     si,size_handle
        loop    .1
; error, no handles are available
        mov     ah,FN_NO_HANDLE
        jmp     error_exit

.2: ; found an available handle; index*2 is in SI
        mov     di,si                   ; zap the save area
        shl     di,2                    ; index*8 is in DI
        lea     di,[handle_save_area + di]      ; prepare to zap the save area
        mov     ax,-1                   ; empty value for save area
        pushm   ds
        popm    es              ; will use ES:DI for the save area pointer
        stosw
        stosw                   ; clear 4 words
        stosw
        stosw

;  index*2 is still in SI
        mov     ax,si                   ; index*2 in AX
        shr     ax,1                    ; index*1 of handle
        add     ax,HANDLE_BASE          ; make the funny Handle
        mov     [bp+offset_DX],ax       ; return handle

        dec     word [handle_count]     ; count the handle

    ; allocate any memory loop
allocate_more:
        or      bx,bx
        jz      good_exit

        mov     di,[map_avail]          ; get index of available memory
        and     di,0FFFh
        shl     di,2                    ; index*4
        mov     al,[map_block_list + di + map_count]
        xor     ah,ah
        cmp     ax,bx                   ; in block :: request remaining
        jb      .4
        mov     cx,bx
        jmp     .41
.4:     mov     cx,ax
.41:            ;               ; CX is the smaller of the two
        sub     bx,cx		; BX is what remains to be allocated (or 0)
        sub     ax,cx           ; AX is remainder on avail list
        mov     ch,[map_block_list + di + map_start]
        mov     dx,[map_block_list + di + map_link]
        jz      got_it_all
; avail list entry has some memory remaining
        add     [map_block_list + di + map_start],cl    ; increment start by count
        mov     [map_block_list + di + map_count],al    ; remaining count
; CH:CL is memory to put on the Handle's chain
        mov     di,[handle_list + si]
        call    add_to_list2     ; DH was set above, CX is good
        cmp     di,-1
        je      .5
        mov     [handle_list + si],di
.5:
        jmp     good_exit

; all of the memory in the block at the head of the avail list is needed
got_it_all:
        and     dh,0Fh
        mov     [map_avail],dx          ; new head of the avail list
; DI is index*4 of the allocated memory piece
        mov     ax,[handle_list + si]
        xor     ax,[map_block_list + di + map_link]
        and     ax,0FFFh
        xor     [map_block_list + di + map_link],ax ; link DI at head of chain
        shr     di,2
        mov     [handle_list + si],di
        jmp     allocate_more



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 44h -- Map Memory
;
;  Enter With:
;       AH = function code 44h
;       AL = physical page [0..3]
;       BX = logical page number:  0...
;       DX = handle
;
;  Exit With:
;       AH = 0          good return
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn44:
        mov     ah,FN_PHYS_PAGE_ERR
        cmp     al,4
        jae     error_exit

        call    unmap           ; use AL as page to unmap

        mov     ah,FN_INVALID_HANDLE
        sub     dx,HANDLE_BASE          ; unbias the handle
        cmp     dx,NUM_HANDLES
        jae     error_exit

        mov     si,dx           ; SI is the unbiased handle index
        add     si,si           ; 
        mov     di,[handle_list + si]   ; get memory chain index

.1:                     ; validate that the chain continues
        shl     di,4
        js      error_exit

        mov     ah,FN_LOG_PAGE_ERR    ; logical page not assigned to this handle
        shr     di,2            ; DI is index*4 into the map_block_list

        mov     cl,[map_block_list + di + map_count]
        xor     ch,ch
        cmp     bx,cx           ; compare count to length of chain
        jb      .4              ; less than, good map

        sub     bx,cx           ; BX is remaining count
        mov     di,[map_block_list + di + map_link]     ; get link index
        jmp     .1

.4:                     ; BL is displacement into page chain
        mov     dh,[map_block_list + di + map_board]
        add     bl,[map_block_list + di + map_start]    ; form logical page #
        mov     ah,bl

        call    remap           ; DH is set; AL is phys page# 0..3
                                ; AH is logical page  (HW page)
        jmp     good_exit


; Unmap the present page in physical page in AL
;
unmap:
        pushm   ax,bx,dx
        mov     dx,[frame]      ; form the block # in DL
        shr     dx,10
        add     dl,al           ; DL is physical page
        mov     bx,ax
        xor     bh,bh           ; BX in index into the map
        add     bx,bx           ; index*2
        mov     dh,[map + bx + 1]   ; get the physical board
        mov     al,255          ; make it invalid
        mov     [map + bx],al
        call    put
        popm    ax,bx,dx
        ret


; Set and record the map
;       AH = hardware page # 0..254
;       AL = physical slot # 0..3
;       DH = board number in high 4 bits
;
remap:
        pushm   ax,bx,dx
        mov     bx,[frame]
        shr     bx,10           ; get board address reg. value
        mov     dl,bl
        add     dl,al           ; offset physical 
        and     dh,0F0h         ; mask off high 4 bits
        mov     bx,ax
        xor     bh,bh           ; BX is index into map array
        add     bx,bx
        mov     al,ah           ;
        xchg    al,dl
        mov     [map + bx],dx   ; record DH (board#), DL page#(0..254)
        xchg    al,dl
        call    put             ; set the HW regs.
        popm    ax,bx,dx
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 45h -- Release Handle and Memory
;
;  Enter With:
;       AH = function code 45h
;       DX = handle
;
;  Exit With:
;       AH = 0          good return
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn45:
        sub     dx,HANDLE_BASE          ; unbias the handle
        mov     ah,FN_INVALID_HANDLE
        cmp     dx,NUM_HANDLES          ; validate handle
        jae     error_exit

        mov     si,dx                   ; use SI as handle index
        add     si,si                   ; index*2
        cmp     word [handle_list + si], -1
        je      error_exit              ; unallocated handle

        mov     di,si                   ; save pointer to DI
        shl     di,2                    ; index*8
        lea     di,[handle_save_area + di]
        mov     ax,-1			;;; 01/12/2013 jrc
	pushm	ds			;;;
	popm	es			;;; for the STOSW  ES:DI
        stosw
        stosw                           ; clear the save area
        stosw
        stosw
;                               ; SI is still index*2
        xchg    [handle_list + si],ax   ; clear the handle
;                               ; AX is now the index to the mem_block_list
free_the_memory:
        mov     bx,ax           ; use it from BX        index*2
        shl     ax,4            ; get sign bit
        js      .9              ; end of chain
;  the continuation of the chain is in AX

	call	free_node	; set up CH:CL, DH, with link in DX
; CX is the memory to free, DH has the board number
	mov	ax,dx		; save link (unmasked)

        mov     di,[map_avail]
	call    add_to_list2
	mov	[map_avail],di

        jmp     free_the_memory         ; loop back with AX

.9:
        inc     word [handle_count]     ; count the handle
        jmp     good_exit




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 46h -- Get EMM Version
;
;  Enter With:
;       AH = function code 46h
;
;  Exit With:
;       AH = 0          good return
;       AL = EMM version number in BCD  (this is LIM EMS 3.2)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn46:
        mov     byte [bp+offset_AL],32h      ; version 3.2
        jmp     good_exit




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 47h -- Save Mapping Context
;
;  Enter With:
;       AH = function code 47h
;       DX = handle
;
;  Exit With:
;       AH = 0          good return
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn47:
        call    check_handle

        inc     ax                      ; must become zero
        mov     ah,FN_SAVE_FAILED
        jnz     error_exit              ; can't do the save

        pushm   ds
        popm    es
        mov     si,map                  ; source pointer to SI
; DI points at the save area
        movsw
        movsw                           ; do the state save
        movsw
        movsw

        jmp     good_exit




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 48h -- Restore Mapping Context
;
;  Enter With:
;       AH = function code 48h
;       DX = handle
;
;  Exit With:
;       AH = 0          good return
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn48:
        call    check_handle

        inc     ax                      ; must become zero
        mov     ah,FN_RESTORE
        jz      error_exit              ; can't do the save

        mov     si,di                   ; restore save area pointer
        xor     al,al
.6:
        mov     dx,[si]                 ; get context to restore
        mov     word [si],-1            ; zap the context
        inc     si
        inc     si
        mov     ah,dl                   ; physical page #
        call    unmap           ; uses only AL
        call    remap           ; uses AL,AH,DH
        inc     al
        cmp     al,4            ; remap pages 0..3
        jb      .6

        jmp     good_exit

;
;  Handle check for Save/Restore functions
;       Enter with biased handle in DX
;
;       Exit with And'ed save area contents in AX
;       Save pointer to Save Area is in DI
;
check_handle:
        sub     dx,HANDLE_BASE          ; unbias the handle
        mov     ah,FN_INVALID_HANDLE
        cmp     dx,NUM_HANDLES          ; validate handle
        jae     error_exit

        mov     si,dx                   ; use SI as handle index
        add     si,si                   ; index*2
        mov     dx,-1
        cmp     [handle_list + si],dx
        je      error_exit              ; unallocated handle

        shl     si,3                    ; index*8
        lea     si,[handle_save_area + si]
        mov     di,si                   ; save pointer to DI
%rep 4
        lodsw                           ; get map word
        and     dx,ax                   
%endrep
        ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 49h -- Reserved
;
;  Enter With:
;       AH = function code 49h
;
;  Exit With:
;       AH = 84h        undefined function
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn49    equ     undefined




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 4Ah -- Reserved
;
;  Enter With:
;       AH = function code 4Ah
;
;  Exit With:
;       AH = 84h        undefined function
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn4A    equ     undefined




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 4Bh -- Get Number of Active EMS Handles
;
;  Enter With:
;       AH = function code 46h
;
;  Exit With:
;       AH = 0          good return
;       BX = number of active Handles (255 is max.)
;               (255 - BX must equal the number of available handles)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn4B:
        mov     cx,NUM_HANDLES
        xor     bx,bx
        mov     si,handle_list
.1:
        cmp     word [si+0],-1
        je      .2
        inc     bx
.2:     lea     si,[si+size_handle]
        loop    .1

        add     bx,255-NUM_HANDLES      ; 3.2 allows 255, so fake the count
        jmp     good_exit



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 4Ch -- Get Pages Owned by Handle
;
;  Enter With:
;       AH = function code 4Ch
;       DX = handle
;
;  Exit With:
;       AH = 0          good return
;       BX = number of logical pages
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn4C    equ     undefined




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 4Dh -- Get Pages for All Handles
;
;  Enter With:
;       AH = function code 4Dh
;
;  Exit With:
;       AH = 0          good return
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn4D    equ     undefined




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function 4Eh -- Get or Set Page Map
;
;  Enter With:
;       AH = function code 4Eh
;       AL = subfunction code
;               00h = get registers into array
;               01h = set registers from array
;               02h = get and set operation
;               03h = return size of page mapping array
;       DS:SI = array pointer from which to set registers
;       ES:DI = pointer to array to receive register information
;
;  Exit With:
;       AH = 0          good return
;       AL = #bytes in page mapping array (subfunction 3)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn4E:
        mov     si,[bp + offset_SI]     ; restore SI
        jmp     undefined



; Get the memory pointer to an empty map block from the empty list
;    Return in DI
get_empty:
        pushm   ax
        mov     di,[map_empty]
        cmp     di,-1
        je      internal_error          ; error if no empty map block
        shl     di,2                    ; index into array
check map_length-4
        add     di,map_block_list
        mov     ax,[di+map_link]
        shl     ax,4
        sar     ax,4                    ; 0FFFh becomes -1
        mov     [map_empty],ax          ; new head of empty list
        mov     word [di+map_link],-1   ; empty block not part of any chain
        popm    ax
        ret                             ; return DI as memory pointer

%if 0
get_empty_index:
        call    get_empty
        sub     di,map_block_list
        ret
%endif

        align   2
; The frame segment of physical EMM page 0
frame:  dw      FRAME0          ; this may be modified during initialization
                                ; of the driver

map_empty:      dw      0       ; first free map block
map_avail:      dw      -1      ; first block of available memory


; The list of EMM map blocks
%assign xemm 0
map_block_list:
%rep    NUM_MAP_BLKS-1
        dw      0,xemm+1
%assign xemm (xemm+1)
%endrep
        dw      0,-1

; The driver request block pointer
request:
        dw      0,0

nboards:  dw      EMM_BOARDS
npages:   dw      0

%assign xemm 0
board_dev_list:
%rep    EMM_BOARDS
        dw      EMM0+xemm+EMM_addr
%assign xemm (xemm+EMM1-EMM0)
%endrep
        dw      -1

handle_count:   dw      NUM_HANDLES
handle_list:
%rep    NUM_HANDLES
        dw      -1
%endrep
size_handle     equ     2       ; for now


map:    
        dw      00FFh   ; hi 4 bits = board number @ frame0
        dw      00FFh
        dw      00FFh
        dw      00FFh
size_save_area  equ     $-map

handle_save_area:
%rep    NUM_HANDLES
        dw      -1, -1, -1, -1
%endrep
check $-handle_save_area - NUM_HANDLES*size_save_area

strategy:
   cs   mov     [request],bx
   cs   mov     [request+2],es
        retf

interrupt:
        pushm   f,all,ds,es
        cld
        push    cs
        pop     ds
        les     bx,[request]            ; get request pointer
    es  cmp     byte [bx+rq_command],0  ; support only "init" command
        jz      initialization
        mov     ax,800Ch                ; general error
finish:
    es  mov     [bx+rq_status],ax
        popm    f,all,ds,es
        retf


; Return the number of available pages by counting the [map_avail] list
;       AX = pages available
;
count_avail:
        pushm   bx,cx
        xor     ax,ax           ; clear the result
        xor     cx,cx           ; zero CH
        mov     bx,[map_avail]
.1:
        shl     bx,4
        js      .9
        shr     bx,2
        mov     cl,[map_block_list + bx + map_count]
        add     ax,cx           ; add to the count
        mov     bx,[map_block_list + bx + map_link]
        jmp     .1
.9:
        popm    bx,cx
        ret



; put
;       DH = board # in hi 4 bits
;       DL = addr [0..3F]
;       AL = page# [0..FE,FF]
;
put:
        push    si              ; SI is where we generate the device code
        mov     si,dx
        shr     si,12           ; SI is board #
        shl     si,1            ; index words
        mov     si,[board_dev_list+si]  ; assume DS==CS
        cmp     si,-1           ; bad device code
        je      internal_error
        push    ax              ; save page frame
        mov     al,dl
        xchg    dx,si
        out     dx,al           ; put out the address
        dec     dx
        pop     ax
        out     dx,al
        mov     dx,si
        pop     si
        ret




; get
;       DH = board # in hi 4 bits
;       DL = addr [0..3F]
;   Returns:
;       AL = page# [0..FE,FF]
;
get:
        push    si              ; SI is where we generate the device code
        mov     si,dx
        shr     si,12           ; SI is board #
        shl     si,1            ; index words
        mov     si,[board_dev_list+si]  ; assume DS==CS
        cmp     si,-1           ; bad device code
        je      internal_error
        mov     al,dl
        xchg    dx,si
        out     dx,al           ; put out the address
        dec     dx
        in      al,dx
        mov     dx,si
        pop     si
        ret


%if 1
; Add a memory chunk (not part of a node) to a list
;   Input:
;	CH:CL	start ; count
;	DH	board number	(in the hi 4 bits)
;	DI	list to scan	(may be null; i.e., 0FFFh)
;   Returns:
;	DI	is new head of list
;
;	AX & BX are preserved
;
add_to_list2:
	pushm	ax,bx

	and	dh,0F0h			; mask to board # only
	and	di,0FFFh		; mask to index only

	cmp	di,0FFFh		; check for NULL list
	je	.new_list
	
	shl	di,2			; DI = index*4
	mov	ah,[map_block_list + di + map_board]	; get board number
	and	ah,0F0h			; make to only board number
	cmp	dh,ah			; arg : board on list
	jb	.make_new		; below
	je	.may_combine		; equal board numbers
; above, we fit in list later
	mov	bx,di			; save index*4 in BX
	mov	di,[map_block_list + di + map_link]	; get rest of chain in DI
	call	add_to_list2		; recursively add to the list
	xor	di,[map_block_list + bx + map_link]	; store DI index only
	and	di,0FFFh		; **
	xor	[map_block_list + bx + map_link],di	; **
	shr	bx,2			; make index*1
	mov	di,bx			; return head of list unaltered
	jmp	.atl_exit		; **

.make_new:
	call	get_node
	shr	di,2			; DI = index*1
	shl	bx,2			; BX = index*4
	and	[map_block_list + bx + map_link],di	; link is FFF, so AND stores link
	or	[map_block_list + bx + map_board],dh	; board is 0FFF, so OR stores board
	shr	bx,2			; BX = index*1
	mov	di,bx
.atl_exit:
	popm	ax,bx			; return
	ret				; new head of list returned

; board numbers are the same
;  CH:CL memory piece may combine with node in DI
;  DI is index*4 of possible combining point
.may_combine:
	mov	ax,[map_block_list + di + map_count]	; AH:AL is  start : count  of node
	add	al,ah			; AH:AL is  start : end+1  of node
	add	cl,ch			; CH:CL is  start : end+1  of chunk
	cmp	cl,ah			; end chunk <> start node
	jb	.before
	jne	.mc2

; end chunk == start node	node grows at the head
	mov	ah,ch			; start node <-- start chunk
;.mc1:
	sub	al,ah			; AH:AL is  start : count of node
	mov	[map_block_list + di + map_count],ax	; update the node
	shr	di,2			; DI is index*1
;;;	xor	cx,cx			; destroy CX, no mem to return
	jmp	.atl_exit

; check for combining at the end
.mc2:	cmp	al,ch			; end node <> start chunk
	jb	.after
	jne	.mc4
; end node == start chunk
	mov	al,cl			; end node <-- start chunk
;;;;;	jmp	.mc1
	sub	al,ah			; AH:AL is  start : count of node
	mov	[map_block_list + di + map_count],ax	; update the node
	mov	bx,[map_block_list + di + map_link]	; get link
	shr	di,2			; DI is index*1
	xchg	bx,di			; BX is combined node, DI is end of list
	call	free_node		; free up BX; sets DH, CH:CL
	call	add_to_list2		; add to the DI list
				; and return the new DI
	jmp	.atl_exit

; chunk and node did not combine, nor were before or after determined
.mc4:	jmp	internal_error

; memory chunk fits in after the current node
.after:
	sub	cl,ch			; CH:CL  start : count  restored
	mov	bx,di			; node pointer to BX  index*4
	mov	di,[map_block_list + bx + map_link]	; node link to DI  index*1
	call	add_to_list2
	xor	di,[map_block_list + bx + map_link]	; store link index*1
	and	di,0FFFh				; **
	xor	[map_block_list + bx + map_link],di	; **
	mov	di,bx			; DI <-- BX   == index*4
	shr	di,2			; make index*1
	jmp	.atl_exit

;memory chunk fits in before the current node
.before:
	sub	cl,ch			; CH:CL  start : count  restored
	call	get_node		; allocate and fill in node
	shr	di,2			; make DI index*1
	shl	bx,2			; new node index*4
	and	[map_block_list + bx + map_link],di	; link is 0FFF, so this stores it
	shr	bx,2			; index*1
	mov	di,bx			; return new node as head
	jmp	.atl_exit

; null list, create a list
.new_list:
	call	get_node		; get a memory node (CH:CL, DH)
	mov	di,bx			; return new index in DI
	jmp	.atl_exit


; Get a memory node and fill it in from CH:CL, and DH
;	return index in BX	(index * 1)
;
;	uses AX
;
get_node:
	pushm	ax

	mov	bx,[map_empty]
	cmp	bx,-1			; check for none available
	je	internal_error

	shl	bx,2			; make index * 4
	mov	ax,[map_block_list + bx + map_link]
	mov	[map_empty],ax		; new head of list
	mov	[map_block_list + bx + map_count],cx	; save CH:CL in start : count
	mov	ah,dh			; board # to AH
	or	ax,0FFFh		; terminate as a single node
	mov	[map_block_list + bx + map_link],ax
	shr	bx,2			; make BX an index

	popm	ax
	ret				; AX was destroyed


; Free the memory node indexed by BX
;   setting CH:CL and DX in the process
;
free_node:
	and	bx,0FFFh		; mask index
	shl	bx,2			; make into  index*4
	xor	cx,cx
	xchg	cx,[map_block_list + bx + map_count]
	mov	dx,[map_empty]		; get head of empty list
	shl	dx,4
	sar	dx,4		; mask, but keep -1
	xchg	dx,[map_block_list + bx + map_link]
	shr	bx,2
	mov	[map_empty],bx
	ret


%endif

        align   2                
;;;***
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  All memory below this point is released after initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%if TRACE==0
free_below_here:
%endif
; Add to list
;   Input:
;       CH:CL = start page# : number of pages
;       DH = board number in high 4 bits
;
;       DI = index of list to scan in low 12 bits (or -1)
;
;    Return:
;       DI = -1 if no new head of list
;       DI = index & 0FFFh of new head of list
;
%if 0
add_to_list:
        pushm   ax,bx,cx,dx,si
        and     dh,0F0h         ; mask to 4 bits == board #
        mov     si,-1           ; former list pointer
        add     cl,ch           ; CL = page beyond end

;  DI is index in low 12 bits
atl_loop:
        cmp     di,-1           ; 
        je      new_entry
; 
        and     di,0FFFh
        shl     di,2            ; index into array
        mov     al,[map_block_list + di + map_board]
        and     al,0F0h
        cmp     al,dh
        ja      new_entry
;;;        je      atl_compare
        jb      atl_next
atl_compare:
        mov     ax,[map_block_list + di + map_count]
        add     al,ah           ; AL is one beyond end
        cmp     ah,cl           ; begin == end
        jne     .1
; tag it at the beginning
        mov     ah,ch
        jmp     .3
.1:     cmp     al,ch           ; end == begin
        jne     atl_next
; tag it onto the end
        mov     al,cl
.3:     ; combining occurred
        sub     al,ah           ; AL = new count
%if TRACE
        call    wout
        call    crlf
%endif
        mov     [map_block_list + di + map_count],ax
        mov     di,-1
        jmp     atl_done
atl_next:
        mov     si,di           ; SI = former index*4
        mov     di,[map_block_list + di + map_link]
        shl     di,4
        sar     di,4
        jmp     atl_loop


        mov     ax,[map_block_list + di + map_count]
        add     al,ah           ; AL = page beyond end

; insert a new entry between SI (lower*4) and DI (higher*4)
new_entry:
        mov     bx,di           ; save in BX
        call    get_empty
        sub     cl,ch           ; CL = count
        mov     [di+map_count],cx       ; save count & start
        sar     bx,2            ; -1 -> -1  or  index*4 -> index
        and     bh,0Fh          ; clear board #
        or      bh,dh           ; include board number
        mov     [di+map_link],bx
        sub     di,map_block_list       ; make into index*4
        shr     di,2            ; make index*1
        cmp     si,-1
        je      .3
        xor     di,[map_block_list + si + map_link]
        and     di,0FFFh
        xor     [map_block_list + si + map_link],di
        mov     di,-1           ; list is linked, and no new head
.3:
atl_done:
        popm    ax,bx,cx,dx,si
        ret
%endif
%if 1
dout:
        pushm   ax,dx
        xor     dx,dx
        div     word [dout_ten]
        or      ax,ax
        jz      .1
        call    dout
.1:     mov     ax,dx
        call    nout
        popm    ax,dx
        ret
dout_ten:   dw      10
%endif
wout:
        xchg    ah,al
        call    bout
        xchg    ah,al
bout:
        push    ax
        shr     ax,4
        call    nout
        pop     ax
nout:
        push    ax
        and     al,00Fh          ; mask 4bits
        daa
        add     al,0F0h
        adc     al,040h
        call    putchar
        pop     ax
        ret

putchar:
        pushm   ax,dx
        mov     dl,al
        mov     ah,2
        int     21h
        popm    ax,dx
        ret

crlf:
        push    fmt_NL
        call    fprint
        inc     sp
        inc     sp
        ret

%if 0
dot:
        pushm   all
        mov     al,'.'
        call    putchar
        popm    all
        ret
%endif

%if TRACE>0
free_below_here:
%endif
initialization:
%if 0
        mov     dx,hello
        mov     ah,9            ; DOS write string
        int     21h
%else
        push    MINOR_VERSION
        push    MAJOR_VERSION
        push    fmt1
        call    fprint
        add     sp,6
%endif
%if TRACE
        pushm   ds
    es  lds     si,[bx+rq_config_sys]
.1:
        lodsb
        cmp     al,20h          ; compare to SPACE
        jb      .2
        call    putchar
        jmp     .1
.2:
        popm    ds

%if 0
        mov     dx,double_space
        mov     ah,9            ; DOS write string
        int     21h
%else
	push	double_space
	call	fprint
	pop	ax
%endif
%endif

; compute the frame segment from the 18h interrupt vector

get_frame_segment:
	pushm	ds
	push	0
	pop	ds
	mov	ax,[18h*4+2]	; get BIOS segment
	sub	ax,1000h
	popm	ds	  	; assume DS==CS
	mov	word [frame],ax

; find the boards that are present

prescence_test:
        mov     dh,0
        xor     si,si
        mov     di,board_dev_list
.3:
TEST_FRAME      equ     0A000h
TEST_PAGE1      equ     5Ch
TEST_PAGE2      equ     0F0h
        cmp     word [di],-1
        je      .7

        mov     dl,TEST_FRAME>>10
        call    get
        mov     cl,al
        mov     al,TEST_PAGE1
        call    put

        inc     dl
        call    get
        mov     ch,al
        mov     al,TEST_PAGE2
        call    put

        dec     dl
        call    get
        sub     al,TEST_PAGE1
        mov     ah,al
        mov     al,cl
        call    put

        inc     dl
        call    get
        sub     al,TEST_PAGE2
        or      ah,al
        mov     al,ch
        call    put

        or      ah,ah
        jnz     .4

; Found a board, add all of its pages to the available list
        call    size_board
        jc      init_error
        push    bx
        mov     bx,ax

        add     bx,map_block_list       ; make into actual pointer
%if TRACE
        call    crlf
        mov     ax,[bx+map_count]
        call    wout
        call    crlf
%endif

        mov     al,[bx+map_count]
        xor     ah,ah
        push    ax
        mov     al,[bx+map_board]
        shr     ax,4
        push    ax
        push    fmt2
        call    fprint
        add     sp,6

        call    reduce_board            ; nop if not board 0

        mov     al,[bx+map_count]
        xor     ah,ah
        push    ax
        push    fmt2a
        call    fprint
        add     sp,4

%if TRACE
        call    crlf
        mov     ax,[bx+map_count]
        call    wout
        call    crlf
%endif

        pop     bx
        jmp     .5

.4:   ; failure to match
        dec     si              ; undo the inc. below
        mov     word [di],-1    ; wipe out the device code
.5: 
        inc     si              ; count board prescence
        inc     di              ; update pointer
        inc     di
        add     dh,10h          ; increment the board number
        jmp     .3
.7:
        mov     ax,si
%if TRACE
        call    bout
        call    crlf
%endif
        mov     [nboards],si
        or      si,si
        jz      init_error

        push    word [handle_count]
        push    word [frame]
        push    fmt3
        call    fprint
        add     sp,6

        mov     ax,DONE
        mov     dx,free_below_here                      ; address of driver end

; DS will not be used beyond this point in the code
; Use DS to set the int 67h vector
        push    0
        popm    ds
        mov     word [67h*4],bios_call_67h
        mov     word [67h*4 + 2],cs
        jmp     save_it

init_error:
        mov     ax,800Ch        ; general failure
        xor     dx,dx           ; don't install the driver
save_it:
    es  mov     word [bx+rq_ret_freemem],dx             ; **
    es  mov     word [bx+rq_ret_freemem+2],cs           ; **
        jmp     finish          ; exit
; note:  DS is not referenced any more at 'finish'


; reduce the size of board 0
;       DH = board number in high 4 bits
;       BX = pointer to the map_block
;
reduce_board:
        test    dh,0F0h         ; is it board 0
        jnz     .99

        pushm   ax,dx,cx
        xor     dl,dl           ; start at address 0
.1:
        call    get             ; get the mapping
%if TRACE
        call    bout
        cmp     dl,32-1
        jne     .11
        call    crlf
.11:
%endif
        cmp     al,255
        je      .4
        cmp     al,[bx+map_start]       ; is it allocated
        jne     .4
        inc     byte [bx+map_start]     ; remove block from available
        dec     byte [bx+map_count]     ; it is allocated
.4:     inc     dl
        cmp     dl,64           ; 64 memory map slots
        jb      .1

%if TRACE
        call    crlf
%endif

%if 1
        mov     ax,[frame]
        shr     ax,10-8           ; get start in AH
        mov     dl,ah
        add     dl,3            ; last slot in frame
.6:
        call    get             ; get mapping
        cmp     al,255          ; is it unassigned
        je      .7
        mov     ch,al           ; page#
        mov     al,255
        call    put             ; make it unavailable
        mov     cl,1            ; count
%if 0
	mov     di,[map_avail]  ; add to list of available pages
        call    add_to_list
        mov     al,ch
        cmp     di,-1
%else
	mov     di,[map_avail]  ; add to list of available pages
        mov     al,ch	      	; save page # in AL
        call    add_to_list2
	mov     [map_avail],di  ; add to list of available pages
%endif
;;;        jne     init_error
.7:     dec     dl

%if 0
        xchg    ah,dl
        call    wout
        xchg    ah,dl
        call    wout
        call    crlf
%endif
        cmp     dl,ah           ; compare to beginning
        jae     .6
%endif

        popm    ax,dx,cx
.99:
        ret


; figure the size of the board (known to be present)
;       DH = board number in the high 4 bits
;
;       C = 0 means no error
;       C = 1 means an error occurred
;
;       AX = index of the memory block (0 .. NUM_MAP_BLKS-1)
;
size_board:
        pushm   di,cx
        mov     al,255                  ; highest page number
        mov     cx,0FF00h               ; 
.1:
        dec     al
        call    page_present            ; is page present
        jnc     .1
;;;        call    dot
        inc     cl
        inc     word [npages]   ; count total pages
        mov     ch,al

        or      al,al           ; set C=0
        jnz     .1              ; loop through all of them
        cmc                     ; set C=1
.6:     cmc
        sbb     ax,ax           ; save the Carry
        mov     di,[map_avail]
%if 0
        push    ax
        mov     ax,di
        call    wout
        pop     ax
%endif
%if 0
        call    add_to_list
%if 0
        push    ax
        mov     ax,di
        call    wout
        pop     ax
%endif
        cmp     di,-1
        je      .8
        mov     [map_avail],di  ;
.8:
%else
        call    add_to_list2
        mov     [map_avail],di  ;
%endif
        shr     ax,1            ; restore the Carry
        mov     ax,di           ; compute the index
        popm    di,cx
        ret

; Return Page Present flag (Carry==1)
;       DH = board number in the high 4 bits
;       AL = page number (0..FE)
;
page_present:
        pushm   ax,dx,cx
        pushm   ds
%if 0
        push    ax
        mov     al,dh
        call    bout
        pop     ax
        call    bout
%endif
        mov     ah,al                   ; save the page to be tested
        mov     dl,TEST_FRAME>>10
        call    get
        xchg    ah,al                   ; save present setting in AH
        call    put                     ; set the map
        push    TEST_FRAME
        popm    ds
.1:
        mov     cx,word [0]     ; save contents
        mov     word [0],0a56ch ; addressing is [DS:0]
        mov     bx,bx
        mov     ax,ax           ; waste time
        cmp     word [0],0a56ch ; see if it is the same
        jne     .8
        mov     word [0],cx     ; restore
        mov     cx,word [1020]
        mov     word [1020],05a32h  ; address [DS:1020]
        mov     ax,ax
        mov     bx,bx
        cmp     word [1020],05a32h
        jne     .8
        mov     word [1020],cx  ; restore
;  if words are equal, the carry is clear because there was no borrow
        clc
        jmp     .9

; Memory test succeeded at the address
.8:
        stc             ; flag not present (C=1; will be complemented C=0)
.9:
        cmc             ; zero Carry on equal (memory present) made C=1
        popm    ds
        sbb     cx,cx
        xchg    ah,al
        call    put
        shr     cx,1
        popm    ax,dx,cx
        ret

;  Formatted string print
;       C-calling convention
;               fprint(fmt, ...)
;       String is NUL terminated
;       Escape character is '$'
;               Escapes are:    $d      decimal value
;                               $X      hex word
;                               $x      hex byte
;                               none others at this time
fprint:
        push    bp
        mov     bp,sp
        pushm   ax,bx,si

        mov     si,[bp+4]       ; get format string pointer
        lea     bx,[bp+6]       ; get argument pointer pointer
.1:
        lodsb                   ; get byte
        or      al,al           ; test for end of string
        jz      .9
        cmp     al,'$'          ; test for escape
        jne     .7

        lodsb                   ; get format character
        cmp     al,'d'          ; decimal value
        jne     .2
; print a decimal value
    ss  mov     ax,word [bx]
        inc     bx
        inc     bx
        call    dout            ; decimal value
        jmp     .1
.2:
        cmp     al,'X'          ; hexadecimal word?
        jne     .3
    ss  mov     ax,word [bx]
        inc     bx
        inc     bx
        call    wout            ; hex word printed
        jmp     .1
.3:
        cmp     al,'x'          ; hexadecimal byte?
        jne     .4
    ss  mov     ax,word [bx]
        inc     bx
        inc     bx
        call    bout            ; hex byte printed
        jmp     .1
.4:
.7:
        call    putchar         ; not special, put out the character
        jmp     .1
.9:
        popm    ax,bx,si
        leave
        ret

fmt1:   db      CR,LF
        db      "4Megabyte Expanded Memory (4MEM / LIM EMS 3.2) manager for the SBC-188"
        db      CR,LF
        db      "             driver version $d.$d", VERSION_SUFFIX
%ifdef __DATE__
%ifdef __TIME__
        db      " (",__DATE__," ",__TIME__,")"
%endif
%else
        db      "  (",DATE,")"
%endif
double_space:
        db      CR,LF
        db      CR,LF,NUL

fmt2:   db      "4MEM board[$d]   $d pages total, ",NUL
fmt2a:  db      "$d available"
fmt_NL: db      CR,LF,NUL

fmt3:   db      "Frame at $X with $d handles"
        db      CR,LF,NUL




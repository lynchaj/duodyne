; disk.inc


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

; FDC error codes (returned in AH)
;
ERR_no_error            equ     0       ; no error (return Carry clear)
;   everything below returns with the Carry set to indicate an error
ERR_invalid_command     equ     1
ERR_address_mark_not_found      equ     2
ERR_write_protect       equ     3
ERR_sector_not_found    equ     4
ERR_disk_removed        equ     6
ERR_dma_overrun         equ     8
ERR_dma_crossed_64k     equ     9
ERR_media_type_not_found        equ     12
ERR_uncorrectable_CRC_error     equ     10h
ERR_controller_failure  equ     20h
ERR_seek_failed         equ     40h
ERR_disk_timeout        equ     80h


; Packet call offsets
;
pkt_size        equ     0       ; byte, size of packet (==16)
pkt_reserved1   equ     1       ; byte, reserved, must be zero
pkt_blocks      equ     2       ; byte, number of blocks to transfer
                                ; max is 127 (7Fh); 0 means no transfer
pkt_reserved3   equ     3       ; byte; reserved, must be zero
pkt_address     equ     4       ; dword; segment:offset of transfer
pkt_LBA         equ     8       ; qword; LBA of transfer
; for convenience:
pkt_LBA0        equ     8       ; word
pkt_LBA1        equ     10      ; word
pkt_LBA2        equ     12      ; word          ; MBZ
pkt_LBA3        equ     14      ; word          ; MBZ

; Parameter Packet returns:
;
;pkt_size       equ     0       ; word
pkt_info        equ     2       ; word, information bits
        ; bit   usage
        ;  0    DMA boundary errors are handled transparently
        ;  1    Geometry valid (bytes 8-12)
        ;  2    Removable device (no)
        ;  3    Supports Write with Verify (no)
        ;  4    change line support (no)
        ;  5    removable & lockable (no)
        ;  6    max. geometry for a removable drive (no)
        ;  7-15  MBZ
pkt_phys_cyl    equ     4       ; dword, physical cylinders
pkt_phys_hds    equ     8       ; dword, physical heads
pkt_phys_spt    equ     12      ; dword, sectors per track
pkt_sectors     equ     16      ; qword, total number of sectors
pkt_bytes       equ     24      ; word, bytes per sector
pkt_ptr         equ     26      ; dword, EDD configuration paramter pointer
                                ; FFFF:FFFF means invalid pointer


				
;------------------------------------------------------------------
;   Specific to the IDE drivers
; More symbolic constants... these should not be changed, unless of
; course the IDE drive interface changes, perhaps when drives get
; to 128G and the PC industry will do yet another kludge.

;IDE Command Constants.  These should never change.
ide_cmd_recal		equ	10H
ide_cmd_read		equ	20H
ide_cmd_write		equ	30H
ide_cmd_init		equ	91H
ide_cmd_dma_read	equ	0C8h
ide_cmd_dma_write	equ	0CAh
ide_cmd_spindown	equ	0E0h
ide_cmd_spinup		equ	0E1h
ide_cmd_ident		equ	0ECh
ide_cmd_set_feature	equ	0EFh


; end disk.inc



;__FPSUP______________________________________________________________________________________________	
;
;  Support for the Front Panel Board by Dan Werner
;  
;  V 0.1 6-18-2017
;
;   This version is for assembly by  NASM 0.98.39 or later
;
;____________________________________________________________________________________________________	




;_FN51_______________________________________________________________________________________________	
;
;  Support for function 51h -- display buffer on the Front Panel Board
;  
;  	DS:DX - address of buffer to display
;
;  
;
;____________________________________________________________________________________________________	
fn51:

    	CALL 	FP_Init 	; Init Front Panel
    	call 	SEGDISPLAY 	; display Segments
    	jmp	clear_carry	; Signal Success



;_FN52______________________________________________________________________________________________	
;
;  Support for function 52h -- display decoded byte on Front Panel Board
;  
;  	DS:DX - address of buffer to display
;   	AL - byte to Display
;  	CL - Location of byte
;
;____________________________________________________________________________________________________	
fn52:
	PUSH CX 		; STORE CX

	PUSH DX 		; STORE DX
    	MOV  DL,AL 		; place byte in DL
    	call ENCODEDISPLAY      ; Call Encode Display (IN=DL, OUT=AX)
    	pop  dx 		; restore DX (Buffer)

    	push ax 		; save encoded Value
    	mov  ax,dx 		; move buffer address to AX
    	xor  ch,ch 		; clear High byte of C

    	add  ax,cx 		; add offset to buffer address
    	add  ax,cx 		; add offset to buffer address (twice, this is for words)
    	pop  cx 		; restore encoded value into CX

    	push BX 		; Store BX
    	mov  BX,AX 		; Park offset address in BX
    	mov  [BX],cx 		; move value into display buffer
    	pop  BX 		; Restore BX
    	
    	pop  CX 		; restore CX

    	CALL 	FP_Init 	; Init Front Panel
    	call 	SEGDISPLAY 	; display Segments
    	jmp	clear_carry	; Signal Success


;_FN53______________________________________________________________________________________________	
;
;  Support for function 53h -- Get key press on Front Panel Board (Wait)
;  
;   	AL - return byte 
;
;____________________________________________________________________________________________________	
fn53:

	CALL	KB_Get			; Get Key from KB
	mov	byte [bp+offset_AX],AL	; RETURN KEY	
    	jmp	clear_carry		; Signal Success	


;_FN54______________________________________________________________________________________________	
;
;  Support for function 54h -- Get key press on Front Panel Board (do not Wait)
;  
;   	AL - return byte 
;
;____________________________________________________________________________________________________	
fn54:

	CALL	KB_Scan			; Get Key from KB
	mov	byte [bp+offset_AX],AL	; RETURN KEY
    	jmp	clear_carry		; Signal Success	







;__FP_Init________________________________________________________________________________________
;
; Initialize MAX7219 on Front Panel Display
;
;  Uses FPPIOCONT,FPPORTC
;  requires MAXOUT
;  returns nothing
;  
;____________________________________________________________________________________________________
FP_Init:
	push	ax		; Store Registers
	push 	dX 		;

     	mov     dx,FPPIOCONT 	;
        mov     al,82h          ; 
        out     dx,al 		;

     	mov     dx,FPPORTC 	;
        mov     al,04h          ; 
        out     dx,al 		;
   
        
        mov    	dx,0900H        ; SET ADDRESS 9 TO 0, NO DECODE
        CALL   	MAXOUT          ; SEND TO MAX7219
        mov    	dx,0A0FH        ; SET ADDRESS A TO 0F, FULL INTENSITY
        CALL   	MAXOUT          ; SEND TO MAX7219
        mov    	dx,0B07H        ; SET ADDRESS B TO 07, DISPLAY ALL DIGITS
        CALL   	MAXOUT          ; SEND TO MAX7219
        mov    	dx,0C01H        ; SET ADDRESS C TO 01, NO SHUTDOWN
        CALL   	MAXOUT          ; SEND TO MAX7219
        mov    	dx,0F00H        ; SET ADDRESS F TO 00, NO SELF-TEST
        CALL   	MAXOUT          ; SEND TO MAX7219    
        
        pop	dx 		; Restore Registers
        pop 	ax 		;
	RET



;__MAXOUT____________________________________________________________________________________________
;
;  Command OUT TO MAX7219
;
;  Send byte to MAX7219 display.
;  Value to Send:  DL
;  Address to Send: DH
;
;  Uses FPPORTC (IO address of port)
;  requires that 7219 be properly initialized prior to calling procedure
;  returns nothing
;  
;     
;____________________________________________________________________________________________________
MAXOUT:
	push 	dx 		; store Registers
	push 	cx		; 
	PUSH 	BX 		; 
	push 	ax 	 	; 
	mov 	bx,dx 		; MOVE DX TO work register	
      	mov	cl,16 		; iterate over 16 bits
MAXOUT_1:   
        rol     bx,1		; get bit

        JC      MAXOUT_1A	; is 1 or 0?

     	mov     dx,FPPORTC 	; output 0
        mov     al,00h          ; 
        out     dx,al 		;
        CALL    PAUSE                
     	mov     dx,FPPORTC 	;
        mov     al,02h          ; 
        out     dx,al		;
        JMP     MAXOUT_1B

MAXOUT_1A:
     	mov     dx,FPPORTC 	; output 1
        mov     al,01h          ; 
        out     dx,al		;
        CALL    PAUSE                
     	mov     dx,FPPORTC 	;
	mov     al,03h          ; 
        out     dx,al		;

MAXOUT_1B:                 
        CALL    PAUSE 		; done with bit
     	mov     dx,FPPORTC 	;
	mov     al,00h          ; 
        out     dx,al		;
        DEC     cl
        Jnz	MAXOUT_1

    	mov      dx,FPPORTC 	; done with sequence
	mov      al,4
        OUT      dx,al

        pop 	ax		; restore registers
        pop 	bx		;
        pop 	cx		;
        POP 	dx		;
        RET    
	





;__ENCODEDISPLAY_____________________________________________________________________________________
;
;  Encode value in dl return LED formatted code in AX
;
;  Value to Encode:  DL
;
;  returns coded value in AX 
;  
;     
;____________________________________________________________________________________________________
ENCODEDISPLAY:
	PUSH	BX			; STORE registers
	push 	DX 			;
	push    DS
	push    DGROUP
	pop     DS
	mov 	bx,dx 			;
	and	bx,000fh		; get low nibble	
	mov	ah,[DS:SEGDECODE+bx]	; GET low VALUE	
	mov 	bx,dx 			;
	and	bx,00f0h		; get high nibble	
	ror 	bx,4 			;
	mov	al,[DS:SEGDECODE+bx]	; GET high VALUE 	
	pop     DS
	pop 	DX 			; restore registers
	POP	BX			; 
	RET


;__SEGDISPLAY________________________________________________________________________________________
;
;  Display contents of buffer TO MAX7219
;
;  Address of buffer: DX
;
;  Refrences MAXOUT
;  requires that 7219 be properly initialized prior to calling procedure
;  returns nothing
;     
;____________________________________________________________________________________________________
SEGDISPLAY:
	push 	ax 			; Store Registers
	push 	bX
	push 	cx
	push 	dx

	mov	ah,08H			; SET DIGIT COUNT
	mov	bx,dx 			; set address
SEGDISPLAY_LP:		
	mov	dl,byte [BX]		; GET DISPLAY DIGIT
	mov     dh,ah	
	CALL    MAXOUT
	INC     bx			; INC POINTER
	DEC     ah
	Jnz     SEGDISPLAY_LP		; LOOP FOR NEXT DIGIT

	pop 	dx 			; restore Registers
	pop 	cx 
	pop 	bx 
	pop 	ax	
	RET

	
	
;__KB_Get____________________________________________________________________________________________
;
;  Get a Single Key and Decode
;
;
;  Refrences KB_Scan
;  Uses FPPORTA,FPPORTB
;  returns key in al
;          
;____________________________________________________________________________________________________
KB_Get:
	push 	bX 			; Store Registers
	push 	DX
	push    DS
	push    DGROUP
	pop     DS

KB_Get_Loop:				;  WAIT FOR KEY
	CALL	KB_Scan			;  Scan KB Once	
	cmp 	al,00
	JZ	KB_Get_Loop		;  Loop while zero	
	MOV     ah,al			;  Store A
	mov 	al,0fh 			;  turn lines on for scan
	mov 	dx,FPPORTA 		;
	OUT 	dx,al 			;  Send to Column Lines
        CALL    PAUSE 			;  Delay to allow lines to stabilize
KB_Clear_Loop:				;  WAIT FOR KEY TO CLEAR
       	mov 	dx,FPPORTB
	IN	al,DX 			;  Get Rows
	AND	AL,01FH			;  Clear Top three Bits
	cmp 	al,00 			;
	Jnz	KB_Clear_Loop		;
	mov	al,ah			;  Restore A
	xor	bx,bX 			;
KB_Get_LLoop:
	cmp     al,[DS:KB_Decode+bX] 	;  
	Jz	KB_Get_Done		;  Found, Done
	INC	bx 			;
	cmp	bx,19			;  
	Jnz	KB_Get_LLoop		;  Not Found, Loop until EOT			
KB_Get_Done:
	mov	Al,bl			;  Result Into A
	pop  	DS
	pop 	DX 			; restore Registers
	pop 	bx 	
	RET



;__KB_Scan____________________________________________________________________________________________
;
;  Scan Keyboard Matrix for an input
;
;
;  Refrences PAUSE
;  Uses FPPORTA,FPPORTB
;  returns key in AL

;     
;____________________________________________________________________________________________________
KB_Scan:
	push 	bX 			; store Registers
	push 	cx
	push 	dx


	mov     ah,00H
	mov	Al,01H			;  Scan Col One
	mov 	dx,FPPORTA
	OUT 	dx,al 			;  Send to Column Lines
        CALL    PAUSE 			;  Delay to allow lines to stabilize
        mov 	dx,FPPORTB
	IN	al,DX 			;  Get Rows
	AND	al,01FH			;  Clear Top three Bits
	JNZ	KB_Scan_Found		;  Yes, Exit.

	mov     ah,20H
	mov	Al,02H	
	mov 	dx,FPPORTA		;  Scan Col Two
	OUT 	dx,al 			;  Send to Column Lines
        CALL    PAUSE			;  Delay to allow lines to stabilize
        mov 	dx,FPPORTB
	IN	AL,dx 			;  Get Rows
	AND	AL,01FH			;  Clear Top three Bits
	JNZ	KB_Scan_Found		;  Yes, Exit.

	mov     AH,40H
	mov	AL,04H			;  Scan Col Three
	mov 	dx,FPPORTA		;  
	OUT 	dx,al 			;  Send to Column Lines
        CALL    PAUSE			;  Delay to allow lines to stabilize
        mov 	dx,FPPORTB
	IN	AL,dx 			;  Get Rows
	AND	AL,01FH			;  Clear Top three Bits
	JNZ	KB_Scan_Found		;  Yes, Exit.

	mov     ah,80H			;
	mov	Al,08H			;  Scan Col Four
	mov 	dx,FPPORTA		;  
	OUT 	dx,al 			;  Send to Column Lines
        CALL    PAUSE			;  Delay to allow lines to stabilize
        mov 	dx,FPPORTB
	IN	AL,dx 			;  Get Rows
	AND	AL,01FH			;  Clear Top three Bits
	JNZ	KB_Scan_Found		;  Yes, Exit.

	xor	Al,al			;  Turn off All Columns
	mov 	dx,FPPORTA		;  
	OUT 	dx,al 			;  Send to Column Lines

	pop 	DX
	pop 	cx
	pop 	bx
	RET				;  Exit

KB_Scan_Found:
	OR	ah,al			;  Add in Row Bits 
	xor	al,al			;  Turn off All Columns
	mov 	dx,FPPORTA		;  
	OUT 	dx,al 			;  Send to Column Lines
	mov	Al,ah			;  Restore Value
	xor 	Ah,ah 			;
	pop 	DX 			; restore Registers
	pop 	cx
	pop 	bx
	RET				;  Exit



PAUSE:
	PUSHm all
	popm  all
	ret



	SEGMENT CONST

;_Constants_______________________________________________________________________________________________________
; 
SEGDECODE:	DB	07EH,030H,06DH,079H,033H,05BH,05FH,070H,07FH,073H,077H,01FH,04EH,03DH,04FH,047H,000H,080H
;
KB_Decode:
;              		0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
		DB	81H,41H,42H,44H,21H,22H,24H,01H,02H,04H,48H,50H,28H,30H,08H,10H
;	                CL  EN  .  
		DB	88H,90H,84H
;
; F-Keys,
; CL = Clear
; EN = Enter
; . = .
	SEGMENT	_TEXT
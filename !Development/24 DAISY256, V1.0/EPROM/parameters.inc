; user defined parameters table (0FFH means no change)
parameters: db 0FFH                 ; number of bytes of 50% external buffer (MSB)
            db 0FFH                 ; number of bytes of 50% external buffer (LSB)
            db 0FFH                 ; number of bytes of 12.5% external buffer (MSB)
            db 0FFH                 ; number of bytes of 12.5% external buffer (LSB)
            db 0FFH                 ; external RAM start address (MSB)
            db 0FFH                 ; external RAM start address (LSB)
            db 0FFH                 ; external RAM end address-100H (MSB)
            db 0FFH                 ; external RAM end address-100H (LSB)
            db 0FFH                 ; external RAM start address-1 (MSB)
            db 0FFH                 ; external RAM start address-1 (LSB)
            db 0FFH                 ; external RAM end address-FFH (MSB)
            db 0FFH                 ; external RAM end address-FFH (LSB)
            db 0FFH                 ; external RAM end address+1 (MSB)
            db 0FFH                 ; external RAM end address+1 (LSB)
            db 0FFH                 ; address of SP0256A ALD (MSB)
            db 0FFH                 ; address of SP0256A ALD (LSB)
            db 0FFH                 ; address of 74LS374 parallel port latch (MSB)
            db 0FFH                 ; address of 74LS374 parallel port latch (LSB)
            db 0FFH                 ; not user definable
            db 0FFH                 ; total number of bytes in input buffer (MSB)
            db 0FFH                 ; total number of bytes in input buffer (LSB)
            db 0FFH                 ; not user definable
            db 0FFH                 ; not user definable

            db 04FH                 ; SMODE value  - no parity, 8 data bits, 1 stop bit (N-8-1)
            db 0C0H                 ; SCTL1 value  - run Timer 3, specify internal SCLK from Timer 3
            db baudrate             ; T3DATA value - Timer 3 Reload Register value for baud rate

; register addresses for user defined parameters above
addresses:  db 01EH                 ; R30 address of number of bytes of 50% external buffer (MSB) parameter
            db 01FH                 ; R31 address of number of bytes of 50% external buffer (LSB) parameter
            db 020H                 ; R32 address of number of bytes of 12.5% external buffer (MSB) parameter
            db 021H                 ; R33 address of number of bytes of 12.5% external buffer (LSB parameter
            db 028H                 ; R40 address of external RAM start address (MSB) parameter
            db 029H                 ; R41 address of external RAM start address (LSB) parameter
            db 024H                 ; R36 address of external RAM end address-100H (MSB) parameter
            db 025H                 ; R37 address of external RAM end address-100H (LSB) parameter
            db 022H                 ; R34 address of external RAM start address-1 (MSB) parameter
            db 023H                 ; R35 address of external RAM start address-1 (LSB) parameter
            db 02AH                 ; R42 address of external RAM end address-FFH (MSB) parameter
            db 02BH                 ; R43 address of external RAM end address-FFH (LSB)  parameter
            db 026H                 ; R38 address of external RAM end address+1 (MSB) parameter
            db 027H                 ; R39 address of external RAM end address+1 (LSB) parameter
            db 02CH                 ; R44 address of address decode of SP0256A ALD (MSB) parameter
            db 02DH                 ; R45 address of address decode of SP0256A ALD (LSB) parameter
            db 02EH                 ; R46 address of address decode of 74LS374 parallel port latch (MSB) parameter
            db 02FH                 ; R47 address of address decode of 74LS374 parallel port latch (LSB) parameter
            db 032H                 ; not user definable
            db 033H                 ; R51 address of total number of bytes in input buffer (MSB) parameter
            db 034H                 ; R52 address of total number of bytes in input buffer (LSB) parameter
            db 035H                 ; not user definable
            db 036H                 ; not user definable

exceptword: jmp exception

; user defined parameters initialization routine            
newparams:  add %02,R49
            call @0F143H            ; initialize buffer pointers and registers
            
            clr B                   ; B serves as the index into the tables
            lda @parameters(B)      ; load the MSB of the parameter from the table
            cmp %0FFH,A             ; is the value from the table FFH?
            jeq init4               ; skip initialization if parameter is FFH
            push A                  ; else, save the MSB value from the parameters pable
            lda @addresses(B)       ; load corresponding value from addresses table
            clr R18                 ; R18 is the MSB of the address 
            mov A,R19               ; move the address into R19
            pop A                   ; restore the parameter value
            sta *R19                ; store the parameter at the address in R18,R19 (register file indirect addressing)
            
init3:      inc B                   ; increment index to point to next parameter
            lda @parameters(B)      ; load LSB of the parameter from the table
            cmp %0FFH,A             ; is the value from the table FFH?
            jeq init4               ; skip initialization if parameter is FFH
            push A                  ; else, save the LSB value from the parameters pable
            lda @addresses(B)       ; load corresponding value from addresses table
            clr R18                 ; R18 is the MSB of the address
            mov A,R19               ; move the LSB of the address from the addresses table
            pop A                   ; restore A
            sta *R19                ; store the parameter
init4:      cmp %16H,B              ; is the index pointing to the last parameter?
            jne init3               ; go back for the next parameter if not at the end
            
            inc B                   ; else, increment the index
            lda @parameters(B)      ; load the serial port mode register parameter
            cmp %0FFH,A             ; is the value from the table FFH?
            jeq init5               ; skip serial port initialization if parameter is FFH

; serial port initialization            
            movp %40H,SCTL0         ; reset the serial port
            movp A,SMODE            ; configure serial port mode
            movp %15H,SCTL0         ; reset error flags, enable receive, enable transmit
            inc B                   ; next parameter
            lda @parameters(B)      ; serial port control register parameter
            movp A,SCTL1            ; configure serial port control
            inc B                   ; next parameter
            lda @parameters(B)      ; serial port timer data register parameter
            movp A,T3DATA           ; configure serial port timer data
            
init5:      movd R41,F1LO           ; initialize input buffer addresses
            movd R43,F2LO           ; initialize output buffer addresses
            mov %20H,A
            sta *F1LO
            call 0F72BH
            sta *F1LO
            eint                    ; enable interrupts
            movd F2LO,R2LO          ; initalize output buffer write pointer
            movd F1LO,R25

            PAGE 0          ; suppress page headings in ASW listing file

; exception EPROM for General Instrument CTS256A-AL2 text-to-speech processor
;
; Syntax is for the Macro Assembler AS V1.42 http://john.ccac.rwth-aachen.de:8000/as/
;
; after a reset, if the jumper connected to pin 7 is closed, the CTS256 looks for user input from the
; serial port (38400 bps, 8 data bits, no parity, 1 stop bit) to implement a primitive sort of monitor.
;
; the following monitor commands are supported:
; C - Call subroutine
; D - Display memory
; E - Examine/modify RAM
; F - Fill external RAM
; H - download Intel Hex file
; J - Jump to address
; P - display Peripheral memory
; R - display Register file
; S - display Status register
; Control X exits monitor to Text-to-Speech function

            cpu tms70C00                     ; TMS7000 family

            include allophones.inc
            include functions.inc

; addresses within the text-to-speech code in the masked ROM...
AUDIBLE     equ 0F1ACH                       ; say "OK"
GISPEECH    equ 0F3E7H                       ; encode text as allophones
SAVE        equ 0F1E2H                       ; store character in input buffer
ESCAPE      equ 0F1F0H                       ; clear buffers and reinitialize

; registers used by the text-to-speech code in the masked ROM...
F1HI        equ R2                           ; input buffer read pointer MSB
F1LO        equ R3                           ; input buffer read pointer LSB
R1HI        equ R4                           ; input buffer write pointer MSB
R1LO        equ R5                           ; input buffer write pointer LSB
F2LO        equ R7                           ; output buffer read pointer LSB
R2LO        equ R9                           ; output buffer write pointer LSB
F2          equ R11                          ; flags
BUFBVALU    equ R50                          ; output buffer high water mark
WORDCNTH    equ R56                          ; number of bytes in input buffer MSB
WORDCNTL    equ R57                          ; number of bytes in input buffer LSB

; registers used by "usercode"...
addresshi   equ R118                         ; high byte of address pointer
addresslo   equ R119                         ; low byte of address pointer
count       equ R120                         ; used by decimal print function
errorcount  equ R120                         ; number of checksum errors in hex download
recordlen   equ R121                         ; record length for hex download function
checksum    equ R122                         ; checksum for hex download function
lengthhi    equ R121                         ; high byte of length for fill function
lengthlo    equ R122                         ; low byte of length for fill function
texthi      equ R123                         ; high byte of pointer to text to be printed
textlo      equ R124                         ; high byte of pointer to text to be printed
loopcounthi equ R125                         ; high byte of the loop counter for flashing LED
loopcountlo equ R126                         ; low byte of the loop counter for flashing LED
flags       equ R127                         ; bit flags

; I/O ports...
IOCNT0      equ P0                           ; I/O Control register 0
APORT       equ P4                           ; Port A
BPORT       equ P6                           ; Port B
IOCNT1      equ P16                          ; I/O Control register 1
SMODE       equ P17                          ; 1st write - Serial port Mode
SSTAT       equ P17                          ; read - Serial port Status
SCTL0       equ P17                          ; 2nd and subsequent writes - Serial port Control register 0
T3DATA      equ P20                          ; Timer 3 Data
SCTL1       equ P21                          ; Serial Control register 1
RXBUF       equ P22                          ; Serial Receive Buffer
TXBUF       equ P23                          ; Serial Transmit Buffer

baudrate    equ 00H                          ; Timer 3 Reload Register value for determining baud rate:
                                             ; 00H=38400 bps, 01H=19200 bps, 03H=9600 bps, 07H=4800 bps, 0FH=2400 bps

            org 4000H                        ; exception EPROM starts here

            db 080H,048H,028H,058H,085H      ; exception EPROM identification sequence

            jmp newparams                    ; initialize new parameters in EPROM
            jmp exceptword                   ; EPROM exception word routine

            include parameters.inc           ; user defined parameters and parameter initialization routine

            br @EPROM                        ; branch to the replacement Main Control Program in EPROM

            include exceptions.inc           ; exception words and exception word routine

;---------- this initiation code is run once upon reset -------------
EPROM:      movp IOCNT0,A                    ; read interrupt status bits
            and %00100000B,A                 ; mask out everything except the INT3 flag
            sta flags                        ; save it as the 'run monitor' flag ('1' means jumper closed, run monitor)
            mov %20H,loopcounthi             ; pre-set the high byte of the loop counter
            call @AUDIBLE                    ; say "OK"
            jmp ANYSTART                     ; jump to the polling loop below
;---------- end of initialization code ------------------------------

; this code is from General Instrument Application Note AN-0505 Revision D dated 12/10/1986 page 26
;---------- this loop is run when the CTS256 is waiting for input ---
SPEAK:      btjo %01H,F2,ANYSTART
            and %0EFH,F2
CRWAIT:     btjz %10H,F2,CRWAIT
ANYSTART:   cmp F1LO,R1LO
            jne HOLEWORD
            cmp F1HI,R1HI
            jne HOLEWORD
            br @usercode                     ; branch to 'usercode' if the input buffer is empty

HOLEWORD:   cmp %00,WORDCNTH
            jne BFULTEST
            cmp %00,WORDCNTL
            jeq HOLEWORD

BFULTEST:   btjz %08H,F2,PROCESS
LOCKUP:     cmp %01,BUFBVALU
            jne BFULHOLD
            br @ESCAPE

BFULHOLD    btjo %08H,F2,BFULHOLD
PROCESS:    call @GISPEECH                   ; encode text to allophones
MAINROUT:   cmp F2LO,R2LO                    ; output buffer empty?
            jeq ANYSTART
            orp %01H,IOCNT0                  ; enable INT1 (LRQ from SP0256)
            jmp ANYSTART
;---------- end of loop ---------------------------------------------

;***********************************************************************
; user code here is executed when the CTS256 is idle
; flash the green LED connected to B2 (pin 5) at about 2Hz as a 'heartbeat' indicator
;***********************************************************************
usercode:   decd loopcountlo                 ; decrement the loop counter
            jc usercode1                     ; jump if the count has not rolled over
            xorp %00000100B,BPORT            ; else, the loop counter has rolled over from zero. toggle the green LED
            mov %20H,loopcounthi             ; pre-set the high byte of the loop counter for next time

usercode1:  btjo %00100000B,flags,usercode2  ; branch if the 'run monitor' flag is set
            br @ANYSTART                     ; else, branch to the main control above

usercode2:  andp %11111110B,IOCNT1           ; disable interrupt 4 (serial interrupt)
            orp %00000001B,BPORT		         ; set BUSY (pin 3) high (BUSY=false)
            mov %hi(bannertxt),texthi
            mov %lo(bannertxt),textlo
            call @putstr                     ; display the sign-on banner

usercode4:  mov %hi(menutxt),texthi          ; texthi and textlo point to the menu text
            mov %lo(menutxt),textlo
            call @putstr                     ; display the menu
usercode5:  call @return
            mov %'>',A
            call @putchar                    ; monitor prompt
            call @putchar
            call @getchar                    ; wait for a character from RXBUF
            call @toupper                    ; convert to upper case
            call @return                     ; start on a new line

            cmp %'D',A                       ; is it 'D'?
            jne usercode6
            call @display                    ; memory display function
            jmp usercode5                    ; go back for another character when finished

usercode6:  cmp %'F',A                       ; is it 'F'?
            jne usercode7
            call @fill                       ; memory fill function
            jmp usercode5                    ; go back for another character when finished

usercode7:  cmp %'R',A                       ; is it 'R'?
            jne usercode8
            call @registers                  ; registers display function
            jmp usercode5                    ; go back for another character when finished

usercode8:  cmp %'P',A                       ; is it 'P'?
            jne usercode9
            call @peripheral                 ; peripherial file display function
            jmp usercode5                    ; go back for another character when finished

usercode9:  cmp %'S',A                       ; is it 'S'?
            jne usercode10
            call @status                     ; status register display function
            jmp usercode5                    ; go back for another character when finished

usercode10: cmp %'E',A                       ; is it 'E'?
            jne usercode11
            call @examine                    ; examine/modify memory function
            jmp  usercode5                   ; go back for another character when finished

usercode11: cmp %'C',A                       ; is it 'C'?
            jne usercode12
            call @callsub                    ; call subroutine function
            jmp usercode5                    ; go back for another character when finished

usercode12: cmp %'H',A                       ; is it 'H'?
            jne usercode13
            call @download                   ; hex download function
            jmp usercode5                    ; go back for another character when finished

usercode13: cmp %'J',A                       ; is it 'J'?
            jne usercode14
            br @jump                         ; jump to address function

usercode14: cmp %':',A                       ; is it ':'?
            jne usercode15
            clr count                        ; clear checksum error count
            call @dnload3                    ; ':' triggers hex download function
            br @usercode5                    ; go back for another character when finished

usercode15: cmp %18H,A                       ; is it control X?
            jz usercode16                    ; if so, disable monitor and exit the usercode loop
            br @usercode4                    ; else, back to the top of the usercode loop

usercode16: and %11011111B,flags             ; clear the monitor flag
            mov %lo(exittxt),textlo
            mov %hi(exittxt),texthi
            call @putstr                     ; print "Exiting Monitor. Goodbye"

            mov %lo(exittxt),textlo
            mov %hi(exittxt),texthi
            call @say                        ; speak "Exiting Monitor. Goodbye"

            orp %00000001B,IOCNT1            ; enable interrupt 4 (serial interrupt)
            br @ANYSTART                     ; jump to the main control program

;------------------------------------------------------------------------
; display the status register as eight binary digits
;------------------------------------------------------------------------
status:     push ST                          ; save the status register
            mov %hi(flagstxt),texthi
            mov %lo(flagstxt),textlo
            call @putstr
            pop A                            ; retrieve the status register from the stack
            call @binary                     ; print the status register (now in A) as binary
            call @return
            rets

;------------------------------------------------------------------------
; fill RAM with value
;------------------------------------------------------------------------
fill:       mov %hi(addresstxt),texthi
            mov %lo(addresstxt),textlo
            call @putstr                     ; prompt for the staring address
            call @get4hex
            jnc fill3                        ; jump if a valid hex address
            call @return
            rets                             ; else return if enter,escape, space or backspace

fill3:      mov A,addresshi                  ; MSB of address
            mov B,addresslo                  ; LSB of address
            mov %09,A
            call @putchar                    ; tab
            mov %hi(lengthtxt),texthi
            mov %lo(lengthtxt),textlo
            call @putstr                     ; prompt for the length
            call @get4hex
            jnc fill4                        ; jump if a valid 4 digit hex length
            rets                             ; else return if enter,escape, space or backspace

fill4:      mov A,lengthhi                   ; MSB of length
            mov B,lengthlo                   ; LSB of length
            decd lengthlo                    ; decrement the number of bytes to fill
            call @space
            mov %09,A                        ; tab
            call @putchar
            mov %hi(valuetxt),texthi
            mov %lo(valuetxt),textlo
            call @putstr                     ; prompt for the fill byte
            call @get2hex
            jnc fill5                        ; jump if a valid hex byte
            rets                             ; else return if enter,escape, space or backspace

fill5:      push A                           ; save the fill byte in A
            call @return                     ; start on a new line
            pop A                            ; restore the fill byte
fill6:      sta *addresslo                   ; store the fill byte at the address
            decd lengthlo                    ; decrement the number of bytes to fill
            jc fill7                         ; jump if lengthhi has not rolled over from 00 to FF
            rets                             ; else, return when finished

fill7:      add %01H,addresslo               ; next address
            adc %00H,addresshi
            jmp fill6

;------------------------------------------------------------------------
; display contents of one page of external RAM pointed to by registers
; addresshi and addresslo in both hex and ASCII
;------------------------------------------------------------------------
display:    mov %hi(addresstxt),texthi
            mov %lo(addresstxt),textlo
            call @putstr                     ; prompt for 4 digit address
            call @get4hex                    ; get 4 digit hex address
            jnc display1                     ; jump if a valid 4 digit hex address
            jmp display6                     ; else return if enter,escape, space or backspace

display1:   call @return                     ; start on a new line
            mov A,addresshi                  ; MSB of starting address
            mov B,addresslo                  ; LSB of starting address
            and %0F0H,addresslo              ; mask least significant bits
display2:   call @return                     ; start on a new line
            mov %20H,A
            call @putchar                    ; print a space
            call @putchar                    ; print another space
            mov %hi(columnstxt),texthi
            mov %lo(columnstxt),textlo
            call @putstr                     ; print column headingsprompt for 4 digit address

display3:   mov addresshi,A
            call @hexbyte                    ; print the MSB of the address
            mov addresslo,A
            call @hexbyte                    ; print the LSB of the address
            call @space
            push addresslo                   ; save the address LSB for the ASCII display later

display4:   lda *addresslo                   ; retrieve the byte at the address
            call @hexbyte                    ; print the hex value of the byte at the address
            call @space
            inc addresslo                    ; next address
            mov addresslo,A
            and %0FH,A
            jnz display4

            call @space
            pop addresslo
display5:   lda *addresslo
            call @ascii
            inc addresslo
            mov addresslo,A
            and %0FH,A
            jnz display5

            call @return
            cmp %0,addresslo
            jne display3
            call @return
            mov %hi(pressspctxt),texthi
            mov %lo(pressspctxt),textlo
            call @putstr
            call @getchar
            cmp %20H,A
            jne display6
            call @return
            inc addresshi
            jmp display2

display6:   call @return
            rets

;------------------------------------------------------------------------
; call a subroutine, return to monitor
;------------------------------------------------------------------------
callsub:    mov %hi(addresstxt),texthi
            mov %lo(addresstxt),textlo
            call @putstr                     ; prompt for 4 digit address
            call @get4hex                    ; get 4 digit hex address
            jnc callsub1                     ; jump if a valid 4 digit hex address
            call @return
            rets
            
callsub1:   mov A,addresshi
            mov B,addresslo
            call @return
            call *addresslo
            call @return
            rets

;------------------------------------------------------------------------
; jump to a memory address
;------------------------------------------------------------------------
jump:       mov %hi(addresstxt),texthi
            mov %lo(addresstxt),textlo
            call @putstr                     ; prompt for 4 digit address
            call @get4hex                    ; get 4 digit hex address
            jnc jump1                        ; jump if a valid 4 digit hex address
            call @return            
            br @usercode5                    ; else, go back for another character

jump1:      mov A,addresshi
            mov B,addresslo
            call @return
            br *addresslo                    ; jump to address in addresslo, addresshi

;------------------------------------------------------------------------
; display contents of the Register File (00-127) in both hex and ASCII
;------------------------------------------------------------------------
registers:  mov %hi(regcoltxt),texthi
            mov %lo(regcoltxt),textlo
            call @putstr                     ; print the column headings
            clr addresshi                    ; MSB of register file starting address
            clr addresslo                    ; LSB of register file starting address

; print the decimal address of the first register in this row
registers1: mov addresslo,A
            cmp %00,addresslo
            jne registers2
            call @space
            jmp registers3
registers2: cmp %100,addresslo
            jhs registers4
registers3: call @space
registers4: call @space
            mov %'R',A
            call putchar
            mov addresslo,A
            call @decimal8
            call @space

; print in hex the contents of the next ten registers
            push addresslo
            mov %10,count
registers5: lda *addresslo                   ; retrieve the byte at the address
            call @hexbyte                    ; print the hex value of the byte at the address
            call @space
            inc addresslo                    ; next address
            cmp %128,addresslo
            jnz registers6
            mov %6,count
            call @space
            djnz count,$-3
            jmp registers7                  ; R127, skip the next and go to the ASCII displat

registers6: djnz count,registers5

; print in ASCII the contents of the next ten registers
registers7: pop addresslo
            mov %10, count
            call @space
registers8: lda *addresslo
            call @ascii
            inc addresslo
            cmp %128,addresslo
            jz registers9                    ; R127, exit
            djnz count,registers8
            call @return
            jmp registers1

registers9: call @return
            rets

;------------------------------------------------------------------------
; display contents of the Peripheral File (0100H-0117H) in hex
;------------------------------------------------------------------------
peripheral: mov %hi(portstxt),texthi
            mov %lo(portstxt),textlo
            call @putstr                     ; print the column headings
            mov %01,addresshi                ; MSB of starting peripheral file address
            clr addresslo                    ; LSB of starting peripheral file address
            call @oneline
            call @return
            mov %10H,addresslo               ; LSB of next line of peripheral file addresses
            call @oneline
            call @return
            rets

oneline:    mov addresshi,A
            call @hexbyte                    ; print the MSB of the peripheral file address
            mov addresslo,A
            call @hexbyte                    ; print the LSB of the peripheral file address
            call @space
oneline1:   cmp %01,addresslo                ; print spaces for "reserved" peripheral file address 0101
            jeq oneline4
            cmp %07,addresslo                ; print spaces for "reserved" peripheral file address 0107
            jeq oneline4
oneline2:   lda *addresslo                   ; retrieve the byte at the peripheral file address
            call @hexbyte                    ; print the hex value of the byte
oneline3:   call @space
            inc addresslo                    ; next peripheral file address
            mov addresslo,A
            and %07H,A
            jnz oneline1
            rets

oneline4:   call @space                      ; print spaces for the "reserved" peripheral file addresses
            call @space
            jmp oneline3

;------------------------------------------------------------------------
; examine/modify RAM contents
;------------------------------------------------------------------------
examine:    mov %hi(addresstxt),texthi
            mov %lo(addresstxt),textlo
            call @putstr                     ; prompt for 4 digit RAM address
            call @get4hex                    ; get four digit hex address
            jnc examine1
examine0:   call @return
            rets

examine1:   mov A,addresshi
            mov B,addresslo
examine2:   call @return
            mov addresshi,A                  ; print MSB of address
            call @hexbyte
            mov addresslo,A                  ; print LSB of address
            call @hexbyte
            mov %hi(arrowtxt),texthi
            mov %lo(arrowtxt),textlo
            call @putstr
            lda *addresslo
            call @hexbyte
            mov %hi(newvaluetxt),texthi
            mov %lo(newvaluetxt),textlo
            call @putstr
            call @get2hex                    ; get 2 hex digits
            jnc examine3
            cmp %20H,A
            jne examine0
            lda *addresslo
            call @hexbyte
examine3:   sta *addresslo                   ; store the new value at the address
examine4:   add %01,addresslo
            adc %00,addresshi
            jmp examine2

;------------------------------------------------------------------------
; Download Intel HEX file:
; A record (line of text) consists of six fields that appear in order from left to right:
;   1. Start code, one character, an ASCII colon ':'.
;   2. Byte count, two hex digits, indicating the number of bytes in the data field.
;   3. Address, four hex digits, representing the 16-bit beginning memory address offset of the data.
;   4. Record type, two hex digits (00=data, 01=end of file), defining the meaning of the data field.
;   5. Data, a sequence of n bytes of data, represented by 2n hex digits.
;   6. Checksum, two hex digits, a computed value (starting with the byte count) used to verify record data.
;------------------------------------------------------------------------
; 'recordlen' holds the number of data bytes per record,
; 'checksum' holds the computed checksum for the record,
; 'errorcount' holds the total checksum error count.
;
; Note: when using Teraterm to "send" a hex file, make sure that Teraterm
; is configured for a transmit delay of 1 msec/char and 10 msec/line.
;------------------------------------------------------------------------
download:   mov %hi(dnloadtxt),texthi
            mov %lo(dnloadtxt),textlo
            call @putstr
            clr errorcount                   ; initialize the checksum error count to zero
dnload1:    call @getchar                    ; get a character from the serial port
            cmp %':',A                       ; start of record??
            jeq dnload3                      ; continue
            cmp %1BH,A                       ; escape?
            jne dnload1
            rets                             ; escape exits back to the main loop

; start of record character ':' found...
dnload3:    call @putchar                    ; echo the start of record ':'
            call @get2hex                    ; get the record length
            cmp %0,A                         ; is the record length zero? (last record)
            jeq dnload7                      ; yes, go download the remainder of the last record
            mov A,recordlen                  ; else, initialize the record length
            mov A,checksum                   ; and initialize the checksum

            call @get2hex                    ; get the address hi byte
            mov A,addresshi
            add checksum,A                   ; add the computed checksum to the address hi byte
            mov A,checksum                   ; save the sum in A as the new checksum

            call @get2hex                    ; get the address lo byte
            mov A,addresslo
            add checksum,A                   ; add the computed checksum to the address low byte
            mov A,checksum                   ; save the sum in A as the new checksum

            call @get2hex                    ; get the record type
            add checksum,A                   ; add the computed checksum to the record type byte
            mov A,checksum                   ; save the sum in A as the new checksum

; download and store data bytes...
dnload4:    call @get2hex                    ; get a data byte
            sta *addresslo                   ; store the data byte at the address
            add %01,addresslo                    ; next address
            adc %00,addresshi
            add checksum,A                   ; add the computed checksum to the data byte
            mov A,checksum                   ; save the sum in A as the new checksum
            djnz recordlen,dnload4           ; decrement the record length if not zero, go back for another record data byte

; since the record's checksum byte is the two's complement and therefore the additive inverse
; of the data checksum, the verification process can be reduced to summing all decoded byte
; values, including the record's checksum, and verifying that the LSB of the sum is zero.
            call @get2hex                    ; get the record's checksum
            add checksum,A                   ; add the computed checksum to the record's checksum in A
            jz dnload6                       ; zero means the checksum is correct
            inc errorcount                   ; else increment checksum error count
            mov %'-',A
            call @putchar
            mov %'E',A                       ; 'E' indicates a checksum error for this recoed
            call @putchar
dnload6:    call @getchar                    ; get the carriage return at the end of the line
            call @putchar                    ; echo the carriage return at the end of the line
            jmp dnload1                      ; go back for the next record

; last record
dnload7:    call @get2hex                    ; get the last address hi byte
            mov A,addresshi                  ; save it in addresshi
            call @get2hex                    ; get the last address lo byte
            mov A,addresslo                  ; save it in addresslo
            call @get2hex                    ; get the last record type
            call @get2hex                    ; get the last checksum
            call @getchar                    ; get the last carriage return
            call @putchar                    ; echo the carriage return
            call @putchar
            mov errorcount,A                 ; get the error count into A
            jnz dnload9                      ; jump if there are checksum errors
            mov %hi(noerrstxt),texthi
            mov %lo(noerrstxt),textlo
            call @putstr                     ; print "No checksum errors"
            mov addresshi,A
            or addresslo,A
            jz dnload8                       ; jump if the address in the last record is zero
            call *addresslo                  ; else, call the function at the address in the last record
dnload8:    rets                             ; return to monitor  

; checksum errors
dnload9:    call @decimal8                   ; print the checksum error count
            mov %hi(errorstxt),texthi
            mov %lo(errorstxt),textlo
            call @putstr
            rets

            db 4B00H-$ dup (0FFH)            ; fill the empty space with 'FF'

            org 4B00H
            
            ; functions in the exception EPROM...
            br @ascii                        ; print the contents of A as an ASCII character
            br @binary                       ; print the contents of A as eight binary digits
            br @decimal8                     ; print the unsigned 8 bit binary number in A as three decimal digits
            br @get1hex                      ; get one hex digit 0-F from the serial port in A.
            br @get2hex                      ; get two hex digits 00-FF from the serial port in A.
            br @get4hex                      ; get four hex digits 0000-FFFF from the serial port in registers A (MSB) and B (LSB).
            br @getchar                      ; wait for a character from the serial port, return it in A
            br @hexbyte                      ; print the contents of A as a 2 digit hex number
            br @putchar                      ; transmit the character in A through the serial port.
            br @putstr                       ; transmit a null terminated string pointed to by registers texthi (MSB) and textlo (LSB)
            br @return                       ; print (to the serial port) CR (0DH)
            br @say                          ; speak a null terminated string pointed to by registers texthi (MSB) and textlo (LSB)
            br @space                        ; print (to the serial port) space (20H)
            br @toupper                      ; convert the ASCII code in A to uppercase

;------------------------------------------------------------------------
; speak the null terminated string pointed to by registers texthi (MSB) and textlo (LSB)
;------------------------------------------------------------------------
say:        push ST
            push A
say1:       lda *textlo                      ; retrieve the character at the address
            jeq say2                         ; zero means end of string
            call @SAVE                       ; save the character in A into the speech input buffer
            add %01H,textlo                  ; increment LSB of the pointer
            adc %00H,texthi                  ; increment MSB of the pointer
            jmp say1                         ; go back for the next character

say2:       pop A
            pop ST
            call @SPEAK                      ; pronounce the phrase
            rets

;------------------------------------------------------------------------
; prints (to the serial port) the unsigned 8 bit binary number in A as
; three decimal digits. leading zeros are suppressed.
;------------------------------------------------------------------------
decimal8:   push A                           ; save the number
            and %01111111B,flags             ; clear suppress zero flag
            mov %100,B                       ; power of 10, starts as 100
decimal8a:  mov %'0'-1,count                 ; counter (starts at 1 less than ASCII zero)
decimal8b:  inc count
            sub B,A                          ; subtract power of 10
            jc decimal8b                     ; go back for another subtraction if the difference is still positive
            add B,A                          ; else , add back the power of 10
            push A
            mov count,A
            cmp %'0',A
            jne decimal8c
            btjz %80H,flags,decimal8d
decimal8c:  call @putchar                    ; print the (hundreds or tens) digit
            or %10000000B,flags              ; now that we've printed a digit, set the flag
decimal8d:  pop A
            sub %90,B                        ; reduce power of ten from 100 to 10
            jc decimal8a                     ; jump if the tens digit is not yet done
            add %30H,A                       ; else, convert the ones digit to ASCII
            call @putchar                    ; print the units digit
            pop A
            rets

;------------------------------------------------------------------------
; prints (to the serial port) carriage return (0DH)
;------------------------------------------------------------------------
return:     push A
            mov %0DH,A
            call @putchar
            pop A
            rets

;------------------------------------------------------------------------
; prints (to the serial port) space (20H)
;------------------------------------------------------------------------
space:      push A
            mov %' ',A
            call @putchar
            pop A
            rets

;------------------------------------------------------------------------
; prints (to the serial port) the byte in A as an ASCII character if between 20H and 7FH, else prints '.'
;------------------------------------------------------------------------
ascii:      push A
            cmp %80H,A
            jhs ascii1                       ; jump if A is 80H or higher
            cmp %20H,A
            jhs ascii2                       ; jump if the character in A is 20H or higher
ascii1:     mov %'.',A
ascii2:     call @putchar
            pop A
            rets

;------------------------------------------------------------------------
; prints (to the serial port) the contents of A as a 2 digit hex number
;------------------------------------------------------------------------
hexbyte:    push A
            push A
            swap A                           ; swap nibbles to print most significant digit first
            call @hex2asc                    ; convert the digit to ASCII
            call @putchar
            pop A                            ; restore the original contents of A
            call @hex2asc                    ; convert the digit to ASCII
            call @putchar
            pop A
            rets

;------------------------------------------------------------------------
; prints (to the serial port) the contents of A as eight binary digits
;------------------------------------------------------------------------
binary:     mov %10000000B,B
binary0:    push A
            btjz B,A,binary1
            mov %'1',A
            jmp binary2
binary1:    mov %'0',A
binary2:    call @putchar
            pop A
            rrc B
            jnc binary0
            rets

;------------------------------------------------------------------------
; converts the lower nibble in A into an ASCII character returned in A
;------------------------------------------------------------------------
hex2asc:    and %0FH,A
            push A
            clrc                             ; clear the carry bit
            sbb %9,A                         ; subtract 9 from the nibble in A
            jl  hex2asc1                     ; jump if A is 0-9
            pop A                            ; else, A is A-F
            add %7,A                         ; add 7 to convert A-F
            jmp hex2asc2
hex2asc1:   pop A
hex2asc2:   add %30H,A                       ; convert to ASCII number
            rets

;------------------------------------------------------------------------
; wait for a character from the serial port, return it in A
; while waiting, flash the green LED at about 2Hz
;------------------------------------------------------------------------
getchar:    btjzp %02H,SSTAT,getchar1        ; jump if RXBUF is empty
            movp RXBUF,A                     ; else, retrieve the character from RXBUF
            rets

getchar1:   decd loopcountlo                 ; decrement the loop counter
            jc getchar                       ; jump if the count has not rolled over
            xorp %00000100B,BPORT            ; else, the loop counter has rolled over to zero. toggle the green LED
            mov %50H,loopcounthi             ; pre-set the high byte of the loop counter for next time
            jmp getchar                      ; go back and check if a character is available at the serial port            

;------------------------------------------------------------------------
; transmit the character in A through the serial port.
;------------------------------------------------------------------------
putchar:    btjzp %00000001B,SSTAT,$         ; wait here until TXBUF is ready for a character
            movp A,TXBUF                     ; transmit it
            btjzp %00000100B,SSTAT,$         ; wait here until the transmitter is empty
            rets

;------------------------------------------------------------------------
; get one hex digit 0-F from the serial port into A. echo the character.
; returns with carry set for escape, space, enter and backspace
;------------------------------------------------------------------------
get1hex:    call @getchar                    ; get a character from the serial port
            cmp %08H,A                       ; backspace?
            jeq get1hex2                     ; return with carry set if backspace
            cmp %0DH,A                       ; enter?
            jeq get1hex2                     ; return with carry set if enter
            cmp %1BH,A                       ; escape?
            jeq get1hex2                     ; return with carry set if escape
            cmp %20H,A                       ; space?
            jeq get1hex2                     ; return with carry set if space
            call @toupper                    ; convert a-f to A-F
            cmp %41H,A
            jl get1hex1                      ; jump if 41H is lower than A (A is equal or greater than 41H)
            sub %07,A
get1hex1:   sub %30H,A
            cmp %10H,A
            jhs get1hex
            push A
            call @hex2asc
            call @putchar
            pop A
            clrc
            rets

get1hex2:   setc                             ; return with carry set for escape, enter, space and backspace
            rets

;------------------------------------------------------------------------
; get two hex digits 00-FF from the serial port into A.
; returns with carry set for escape, space and enter
;------------------------------------------------------------------------
;-----------first digit
get2hex:    call @get1hex                    ; get the first hex digit
            jc get2hex6
            mov A,B                          ; save the first hex digit in B
;-----------second digit
get2hex1:   call @get1hex                    ; get the second hex digit
            jnc get2hex4                     ; jump if not escape, enter, space or backspace
            cmp %08H,A                       ; is it backspace?
            jne get2hex2
            call @putchar
            jmp get2hex                      ; go back for first digit
get2hex2:   cmp %0DH,A                       ; is it enter?
            jne get2hex3
            mov B,A                          ; recall @the first digit from B
            jmp get2hex5                     ; return with carry cleared and first digit in A

get2hex3:   cmp %1BH,A                       ; is it escape?
            jeq get2hex6                     ; exit with carry set
            jmp get2hex1                     ; else go back for the second hex digit

get2hex4:   swap B                           ; swap the nibbles of the first hex digit
            and %0F0H,B                      ; mask out the lower 4 bits
            or B,A                           ; combine the two hex digits
get2hex5:   clrc
            rets                             ; return with carry cleared and two digits in A

get2hex6:   setc                             ; return with carry set if escape
            rets

;------------------------------------------------------------------------
; get four hex digits 0000-FFFF from the serial port into registers A (MSB) and B (LSB).
; returns with carry set for escape, space and enter
;------------------------------------------------------------------------
;-----------first digit
get4hex:    call @get1hex                    ; get the first digit
            jc get4hex18                     ; jump if enter, escape, space or backspace
            push A                           ; save the first digit on the stack

;-----------second digit
get4hex2:   call @get1hex                    ; get the second digit
            jnc get4hex5
            cmp %08H,A                       ; is it backspace?
            jne get4hex3
            call @putchar                    ; print the backspace
            pop A
            jmp get4hex                      ; go back for the first digit
get4hex3:   cmp %0DH,A                       ; is it enter?
            jne get4hex4
            clr A
            pop B                            ; recall the first digit from the stack
            clrc
            rets

get4hex4:   cmp %1BH,A                       ; is it escape?
            jeq get4hex17                    ; return with carry set if escape
            jmp get4hex2                     ; else go back for the second digit

get4hex5:   pop B                            ; recall @the first digit from the stack
            swap B                           ; swap the nibbles of the first digit
            and %0F0H,B                      ; mask out the lower 4 bits
            or B,A                           ; combine the first digit in B with the second digit in A
            push A                           ; save the most significant byte on the stack

;-----------third digit
get4hex6:   call @get1hex                    ; get the third digit
            jnc get4hex9
            cmp %08H,A                       ; backspace?
            jne get4hex7
            call @putchar                    ; print the backspace
            pop A                            ; recall @the first byte from the stack
            swap A                           ; swap the nibbles
            and %0FH,A                       ; mask out the second digit
            push A                           ; save the first byte on the stack
            jmp get4hex2                     ; go back for the second digit
get4hex7:   cmp %0DH,A                       ; enter?
            jne get4hex8
            clr A
            pop B                            ; recall the first byte from the stack
            clrc
            rets                             ; return with the first two digits in B and carry clear
get4hex8:   cmp %1BH,A                       ; escape
            jeq get4hex17
            jmp get4hex6                     ; go back for the third digit
get4hex9:   push A                           ; save the third digit on the stack

;-----------fourth digit
get4hex10:  call @get1hex                    ; get the fourth digit
            jnc get4hex16
            cmp %08H,A                       ; backspace?
            jne get4hex11
            call @putchar                    ; print the backspace
            pop A
            jmp get4hex6                     ; go back for the third digit

get4hex11:  cmp %0DH,A                       ; enter?
            jne get4hex15
            pop B                            ; third digit in B
            pop A                            ; most significant byte in A
            mov %4,count

get4hex12:  clrc
            rrc A
            rrc B
            jnc get4hex13
            or %00001000B,B
get4hex13:  djnz count,get4hex12
            clrc
            rets

get4hex15:  cmp %1BH,A                       ; escape?
            jne get4hex10                    ; go back for the fourth cdigit if not escape
            pop B
            jmp get4hex17                    ; exit with carry set

get4hex16:  pop B                            ; recall the third digit from the stack
            swap B                           ; swap nibbles
            and %0F0H,B                      ; mask out the lower 4 bits
            or B,A                           ; combine the third and fourth digits to form the least significant byte
            mov A,B                          ; move the least significant byte into B
            pop A                            ; recall the most significant byte from the stack
            clrc
            rets                             ; return with MSB in A, LSB in B and carry cleared

get4hex17:  pop B
get4hex18:  setc                             ; return with carry set if escape
            rets

;------------------------------------------------------------------------
; convert the ASCII code in A to uppercase, if it is lowercase
;------------------------------------------------------------------------
toupper:    cmp %'a',A                       ; 'a' or 61H
            jl toupper1                      ; jump if the character in A is less than 61H
            cmp %'{',A                       ; '{' or 7BH
            jhs toupper1                     ; jump if the character in A is greater than 7AH
            sub %20H,A                       ; the ASCII character is 'a'-'z', subtract 20H to conver to upper case
toupper1:   rets

;------------------------------------------------------------------------
; transmit a null terminated string pointed to by registers texthi (MSB) and textlo (LSB)
;------------------------------------------------------------------------
putstr:     lda *textlo                      ; retrieve the character at the address
            jeq putstr1                      ; zero means end of string
            call @putchar                    ; else, print it
            add %01,textlo                   ; increment pointer to next character
            adc %00,texthi
            jmp putstr
putstr1:    rets


bannertxt:  db 0DH,0AH,0AH
            db "CTS256A-AL2 Monitor Version 2.1",0DH
            db "Copyright 2021 by Jim Loos",0DH
            db "Assembled ",DATE," at ",TIME,0DH,0
menutxt:    db 0DH,0AH
            db "C - Call subroutine",0DH
            db "D - Display memory",0DH
            db "E - Examine/modify RAM",0DH
            db "F - Fill external RAM",0DH
            db "H - download Intel Hex file",0DH
            db "J - Jump to address",0DH
            db "P - display Peripheral file",0DH
            db "R - display Register file",0DH
            db "S - display Status register",0DH,0AH,0AH
            db "Control X exits monitor to Text-to-Speech function.",0DH,0AH,0
flagstxt:   db 0DH,"CNZI----",0DH,0
pressspctxt:db "Press Space key for next page...",0
arrowtxt:   db " --> ",0
newvaluetxt:db " New value: ",0
addresstxt: db 0DH,"Address: ",0
lengthtxt:  db "Length: ",0
valuetxt:   db "Value: ",0
columnstxt: db "   00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F",0DH,0
regcoltxt:  db 0DH,"      00 01 02 03 04 05 06 07 08 09",0DH,0
portstxt:   db 0DH,"     00 01 02 03 04 05 06 07",0DH,0
dnloadtxt:  db 0DH,"Waiting for HEX download...",0DH,0
noerrstxt:  db "No checksum errors",0DH,0
errorstxt:  db " checksum errors.",0DH,0
exittxt:    db "Exiting monitor. Goodbye.",0DH,0

            db 5000H-$ dup (0FFH)            ; fill the empty space with 'FF'

            end
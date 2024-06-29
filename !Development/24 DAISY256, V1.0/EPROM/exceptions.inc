exception:  jmp except   ; jump to exception word routine
            
            ; alphabetized exception word index
index:      dw A_words  ; MSB,LSB of pointer to exception words beginning with "A"
            dw B_words  ; MSB,LSB of pointer to exception words beginning with "B"
            dw C_words  ; MSB,LSB of pointer to exception words beginning with "C"
            dw D_words  ; MSB,LSB of pointer to exception words beginning with "D"
            dw E_words  ; MSB,LSB of pointer to exception words beginning with "E"
            dw F_words  ; MSB,LSB of pointer to exception words beginning with "F"
            dw G_words  ; MSB,LSB of pointer to exception words beginning with "G"
            dw H_words  ; MSB,LSB of pointer to exception words beginning with "H"
            dw I_words  ; MSB,LSB of pointer to exception words beginning with "I"
            dw J_words  ; MSB,LSB of pointer to exception words beginning with "J"
            dw K_words  ; MSB,LSB of pointer to exception words beginning with "K"
            dw L_words  ; MSB,LSB of pointer to exception words beginning with "L"
            dw M_words  ; MSB,LSB of pointer to exception words beginning with "M"
            dw N_words  ; MSB,LSB of pointer to exception words beginning with "N"
            dw O_words  ; MSB,LSB of pointer to exception words beginning with "O"
            dw P_words  ; MSB,LSB of pointer to exception words beginning with "P"
            dw Q_words  ; MSB,LSB of pointer to exception words beginning with "Q"
            dw R_words  ; MSB,LSB of pointer to exception words beginning with "R"
            dw S_words  ; MSB,LSB of pointer to exception words beginning with "S"
            dw T_words  ; MSB,LSB of pointer to exception words beginning with "T"
            dw U_words  ; MSB,LSB of pointer to exception words beginning with "U"
            dw V_words  ; MSB,LSB of pointer to exception words beginning with "V"
            dw W_words  ; MSB,LSB of pointer to exception words beginning with "W"
            dw X_words  ; MSB,LSB of pointer to exception words beginning with "X"
            dw Y_words  ; MSB,LSB of pointer to exception words beginning with "Y"
            dw Z_words  ; MSB,LSB of pointer to exception words beginning with "Z"
            dw Symbols  ; MSB,LSB of pointer to symbols exception words
            
            ; exception word routine
except:     push F1HI
            push F1LO                                                              
            movd F1LO,R17
            call @0F74BH
            call @0F70FH
            btjz %01,R10,except1
            or %080H,F2
            jmp except2
except1:    and %7FH,F2
except2:    call 0F3AFH
            btjo %20H,R10,except3
            mov %52,B
            lda @index(B)
            mov A,R20
            lda @index+1(B)
            mov A,R21
            jmp except4
except3:    clr B
            sub %41H,A
            mpy %02,A
            lda @index(B)
            mov A,R20
            lda @index+1(B)
            mov A,R21
except4:    mov %01,B
            call 0F488H
except4a:   call 0F4C2H
            btjo %10H,R10,except6
            cmp %0FFH,A
            jz except8
            movd R17,R29
            and %0BFH,R10
            call 0F564H
            btjo %10H,R10,except6
            call 0F47EH
            or %40H,R10
            call 0F564H
            btjo %10H,R10,except7
            add R55,R52
            adc %00,R51
            clr R55
            and %0FDH,F2
            mov %02,B
            call 0F488H
            call 0F49EH
            movd R15,F1LO
            movd F1LO,R17
            call 0F74BH
            btjz %80H,F2,except5
            decd WORDCNTL
            call 0F347H
            pop B                  
            pop B
            br @0F136H
except5:    pop B 
            pop B
            br @0F3F4H
except6:    inc R21
            jnc except6a
            inc R20
except6a:   mov %02,B
except6b:   call 0F488H
            mov %01,R55
            and %0FDH,F2
            jmp except4a
except7:    mov %03,B
            jmp except6b
except8:    pop F1LO
            pop F1HI
            clr R55
            and %0FDH,F2
            br @0F3EEH
            
            db  0FFH
            
; Exception-Word Encoding Scheme:
; 
; To store a unique word or symbol and its corresponding allophone address string 
; in an efficient and flexible manner, the following encoding format was derived:
; 
;    <[encoded word or symbol]< = [encoded allophone address(es)]
; 
;    where < equals 13H
;          [ equals 40H
;          ] equals 80H
; 
; The first and last bytes is 13H. This informs the code-to-speech algorithm 
; that the word or symbol is not a prefix or suffix.
; If the word or symbol is an individual letter, then the representation of it 
; between the brackes is an FFH; this includes the value of the left and right
; brackets. If it is a number or punctuation, then it is represented by its 
; value from TABLE-1 plus the value of the left and right brackets.
; 
; Otherwise.
; (1) The first letter in the word or symbol is always to be ignored; this does 
;     not apply to numbers or punctuation.
; (2) The next letter in the word is represented by the value of the letter from 
;     TABLE-1, plus the value of the left bracket "[" which is 40H.
; (3) The following letter(s), if and only if it is not the last letter in the 
;     word or symbol, is represented solely by its value from TABLE-1.
; (4) The last letter in the word or symbol is represented by the value of the 
;     letter from TABLE-1, plus the value of the right bracket "]" which is 80H.
;
; NOTE: the values from TABLE-1 are represented in the source code as the ASCII values of the letter or number - 20H
;
; The allophone address string is encoded in a similar manner:
; 
; If only one allophone is used for the pronounciation, it is represented by 
; its value from TABLE-2, plus the value of the left "[" and right "]" 
; brackets which are 40H and 80H respectively.
; 
; Otherwise:
; 
; (1) The first allophone is represented by its value from TABLE-2, plus the 
;     value of the left bracket "[" which is 40H.
; (2) The following allophone(s), if and only if it is not the last allophone in
;     the string, is represented by its value from TABLE-2.
; (3) The last allophone is represented by its value from TABLE-2 
;      plus the value of the right bracket "]" which is 80H.
; 
; Example: To encode "Au" to pronounce as "GOLD"
;          <[Au]< = [GG2 OW LL DD1]
;          13, F5, 13, 7D, 35, 2D, 95 <--This line is ready to store in
;              ^                         EXCEPTION-WORD EPROM under the
;              |                         "A" category. (The encoded string
;              |                         is shown in Hex notation.)
;              |
;              +--Remember, throw away the first letter (in this case an "A"), 
;                 then find the value of the next letter in TABLE-1 and add 
;                 40H plus 80H to it so as to represent the left "[" and right "]" brackets.
; 
; For words, the leading "<" (which marks the start of a word) is mandatory. 
; The trailing "<" (which marks the end of the word) is optional, and if it's 
; left off it marks the word as a prefix form. This allows constructs such as:
; 
;    <[CAP]A=[KK1 EY PP] ; CAPABILITY, CAPABLE
; 
; Without this, "capable" would be pronounced "cap-able", whereas it ought to 
; be "cape-able".
; 
; For symbols, both the leading and trailing "<"s are optional. This allows symbols
; to occur in the middle of a word (e.g. "up&down" would become "up and down" with 
; the example exception list).        
            
            ; encoded exception words
A_words:    db  13H,'N'-20H+40H,'S'-20H,'I'-20H+80H,13H                          ; ANSI
            db  AE+40H,NN1,SS,IY+80H
            db  13H,'N'-20H+40H,'S'-20H,'W'-20H,'E'-20H,'R'-20H+80H,13H          ; ANSWER
            db  AE+40H,NN1,SS,ER1+80H
            db  0FFH    ; end of A words
B_words:    db  0FFH    ; end of B words
C_words:    db  13H,'A'-20H+40H,'P'-20H+80H,'A'-20H                              ; CAPA note: no ending '13H' since it's the first part of a word. i.e. 'capability' or 'capable'
            db  KK1+40H,EY,PP+80H
            db  0FFH    ; end of C words
D_words:    db  0FFH    ; end of D words
E_words:    db  0FFH    ; end of E words
F_words:    db  0FFH    ; end of F words
G_words:    db  13H,'O'-20H+40H,'O'-20H,'D'-20H,'B'-20H,'Y'-20H,'E'-20H+80H,13H  ; GOODBYE
            db  GG2+40H,UH,UH,DD1,PA3,BB2,AY+80H
            db  0FFH    ; end of G words
H_words:    db  0FFH    ; end of H words
I_words:    db  13H,'D'-20H+40H+80H,13H                                          ; ID pronounced as 'IDENTIFICATION'
            db  AY+40H,DD2,EH,NN1,PA3,TT2,IH,FF,IH,PA3,KK1,EY,SH,AX,NN1+80H      
            db  13H,'S'-20H+40H,'L'-20H,'E'-20H+80H,13H                          ; ISLE
            db  AY+40H,PA2,EL+80H
            db  13H,'S'-20H+40H,'L'-20H,'A'-20H,'N'-20H,'D'-20H+80H,13H          ; ISLAND   
            db  AY+40H,PA2,EL,AE,NN1,DD1+80H       
            db  0FFH    ; end of I words
J_words:    db  0FFH    ; end of J words
K_words:    db  0FFH    ; end of K words
L_words:    db  13H,'I'-20H+40H,'V'-20H,'E'-20H,'D'-20H+80H,13H                  ; LIVED
            db  LL+40H,IH,VV,PA4,DD1+80H
            db  0FFH    ; end of L words
M_words:    db  13H,'O'-20H+40H,'N'-20H,'I'-20H,'T'-20H,'O'-20H,'R'-20H+80H,13H  ; MONITOR
            db  MM+40H,AA,AA,PA1,NN1,IH,PA1,TT2,ER1+80H
            db  0FFH    ; end of M words
N_words:    db  0FFH    ; end of N words
O_words:    db  0FFH    ; end of O words
P_words:    db  13H,'U'-20H+40H,'R'-20H,'P'-20H,'O'-20H,'S'-20H,'E'-20H+80H,13H  ; PURPOSE
            db  PP+40H,ER1,PP,AX,SS,SS+80H
            db  0FFH    ; end of P words
Q_words:    db  0FFH    ; end of Q words
R_words:    db  13H,'E'-20H+40H,'A'-20H,'D'-20H,'Y'-20H+80H,13H                  ; READY
            db  RR1+40H,EH,EH,PA1,DD2,IY+80H
            db  0FFH    ; end of R words
S_words     db  0FFH    ; end of S words
T_words:    db  13H,'O'-20H+40H,'T'-20H,'A'-20H,'L'-20H+80H,13H                  ; TOTAL
            db  TT2+40H,OW,TT1,PA1,AX,EL+80H
            db  0FFH    ; end of T words
U_words:    db  13H,'S'-20H+40H,'E'-20H,'R'-20H,'I'-20H,'D'-20H+80H,13H          ; USERID  pronounced as 'USER IDENTIFICATION'
            db  YY1+40H,UW1,ZZ,ER1,PA1,AY,PA1,DD2,EH,NN1,PA3,TT2,IH,FF,IH,PA3,KK1,EY,SH,AX,NN1+80H  
            db  0FFH    ; end of U words
V_words:    db  0FFH    ; end of V words
W_words:    db  13H,'E'-20H+40H,'\''-20H,'R'-20H,'E'-20H+80H,13H                 ; WE'RE
            db  WW+40H,IY,ER2+80H      
            db  0FFH    ; end of W words
X_words:    db  0FFH    ; end of X words
Y_words:    db  13H,'O'-20H+40H,'U'-20H,'\''-20H,'R'-20H,'E'-20H+80H,13H         ; YOU'RE
            db  YY2+40H,OR+80H
            db  0FFH    ; end of Y words
Z_words:    db  0FFH    ; end of Z words
Symbols:    db  '#'-20H+40H+80H                                                  ; '#' pronounced as 'HASHTAG'
            db  HH1+40H,AE,SH,PA3,TT2,AE,GG3,PA1+80H
            db  '&'-20H+40H+80H                                                  ; '&' pronounced as 'AND'
            db  AE+40H,NN1,DD1,PA1+80H
            db  '/'-20H+40H+80H                                                  ; '/' pronounced as 'SLASH'
            db  SS+40H,LL,AE,SH,PA1+80H             
            db  '+'-20H+40H+80H                                                  ; '+' pronounced as 'PLUS'
            db  PP+40H,LL,AX,AX,SS,SS,PA1+80H
            db  '@'-20H+40H+80H                                                  ; '@' pronounced as 'AT'
            db  AE+40H,TT2,PA1+80H
            db  0FFH    ; end of Symbols

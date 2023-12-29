;___________________________________________________________________________________________________
;
;	USEFUL 65186 MACROS
;__________________________________________________________________________________________________

.macro       STORECONTEXT             ; Store Complete Context at the beginning of a Sub
        PHX
        phy
        pha
        php
.endmacro

.macro       RESTORECONTEXT                 ; Restore Complete Context at the end of a Sub
        plp
        pla
        ply
        plx
.endmacro

.macro       INDEX16                         ; Set 16bit Index Registers
		REP #$10 		; 16 bit Index registers
		.I16
.endmacro
.macro       INDEX8                          ; Set 8bit Index Registers
		SEP #$10 		; 8 bit Index registers
		.I8
.endmacro

.macro       ACCUMULATOR16                  ; Set 16bit Index Registers
		REP #$20 		; 16 bit Index registers
		.A16
.endmacro

.macro       ACCUMULATOR8                   ; Set 8bit Index Registers
		SEP #$20 		; 8 bit Index registers
		.A8
.endmacro

.macro       ACCUMULATORINDEX16             ; Set 16bit Index Registers
		REP #$30 		; 16 bit Index registers
		.A16
                .I16
.endmacro

.macro       ACCUMULATORINDEX8              ; Set 8bit Index Registers
		SEP #$30 		; 8 bit Index registers
		.A8
                .I8
.endmacro



.macro    cr                      ; Restore Complete Context at the end of a Sub
        SEP #$20 		; 8 bit accum
		.A8
.endmacro

;
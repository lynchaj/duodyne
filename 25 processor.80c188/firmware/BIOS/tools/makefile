!ifdef __UNIX__
CC=gcc
OUTPUT=-o
RM=rm -f
CP=cp
EXE2ROM=exe2rom
HEX2BIN=hex2bin
BIN2HEX=bin2hex
!else
CC=wcl386 -DMSDOS=1
OUTPUT=-fo=
RM=del
CP=copy
EXE2ROM=exe2rom.exe
HEX2BIN=hex2bin.exe
BIN2HEX=bin2hex.exe
!endif

all:    $(EXE2ROM) $(HEX2BIN) $(BIN2HEX)

$(EXE2ROM): exe2rom.c mytypes.h
	$(CC) $(OUTPUT)$@ $*.c

$(HEX2BIN): hex2bin.c mytypes.h
	$(CC) $(OUTPUT)$@ $*.c

$(BIN2HEX): $(HEX2BIN)
	$(CP) $(HEX2BIN) $(BIN2HEX)
	
	    
clean:	.SYMBOLIC
	$(RM) $(EXE2ROM)
	$(RM) $(HEX2BIN)
	$(RM) $(BIN2HEX)

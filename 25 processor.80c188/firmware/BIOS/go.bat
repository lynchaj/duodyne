set appl=minix86
setdos /U1 /M1 /V0
set 4help=C:\4dos\help.exe
PATH=F:\WINNT\system32;F:\WINNT;F:\WINNT\System32\Wbem;tools;C:\util\unix
PATH=%PATH%;C:\BIN;C:\DOS;C:\4DOS;C:\UTIL;C:\BRIEF;C:\;C:\CPMTOOLS
set INCLUDE=
set TEMP=F:\TEMP
set TMP=F:\TEMP
set CPMTOOLS=C:\cpmtools
alias /r c:\util\aliases
ANSI SLOW /B 60
CALL BRIEF
CALL GRN
CLS
echo off
if not "%1"=="" goto %1
if not %APPL == "" goto %APPL
REM goto SBC188
REM goto DMAIDE
REM goto TBASIC
REM goto M68k
REM goto HC
REM goto CVDU
REM goto SDCARD
REM goto PALASM4
goto MARKIV
REM goto MC6809

REM
REM   for SBC-188 BIOS development
REM  
:SBC188
CDD D:\SBC188
CDD C:\SBC188\BIOS
PATH=C:\SBC188;%PATH%
echo on
ccomp wcc
goto exit

REM
REM   for DMAIDE development
REM  
:DMAIDE
CDD D:\SBC188
CDD C:\SBC188\DMAIDE
SET PALASM=D:\PALASM\
echo on
ccomp c700
goto exit

REM
REM   for uPD7220 v2 testing
REM
:UPD
CDD D:\SBC188
CDD C:\SBC188\D7220
ECHO ON
CCOMP C700
goto exit

REM
REM   for TBASIC testing
REM
:TBASIC
CDD D:\SBC188
CDD C:\SBC188\tbasic
ECHO ON
CCOMP wcc
alias make=wmake
goto exit

REM
REM   for HC development
REM
:HC
CDD C:\N8VEM\HC
ECHO ON
CCOMP sdcc
goto exit

REM
REM   for baby M68k development
REM
:M68k
CDD C:\M68K\BIOS
echo ON
CCOMP M68K
goto exit

REM
REM   for Minix68 (Minix 1.5) development
REM
:MINIX68
set ARCH=M68k
set PREFIX=\Minix\15
CDD D:%PREFIX
echo ON
CCOMP M68K
ALIAS gcc=M65E09~1.EXE
goto exit

REM   for Minix86 (Minix 1.7.5) development
REM
:MINIX86
set ARCH=i86
set PREFIX=\Minix175
CDD D:%PREFIX\SRC
echo ON
CCOMP WCC
alias make=c:\bin\nmake
set MAKE=c:\bin\nmake
goto exit

REM
REM   for ColorVDU work
REM
:CVDU
REM CDD C:\ColorVDU
CDD C:\ColorVDU\EGA
echo ON
CCOMP C700
goto exit

REM
REM   for SDcard work
REM
:SDCARD
CDD D:\SDcard
CDD C:\SDcard
echo ON
CCOMP C700
goto exit

REM
REM   for working with PALASM
REM
:PALASM4
REM D:\PALASM4\ PALASM4 Environment Setup
SET PALASM=D:\PALASM4\
PPATH D:\PALASM4\EXE
goto exit

REM
REM   for SBC Mark IV
REM
:MARKIV
CDD C:\N8VEM\UNA_SRC
CDD D:\MARKIV
echo ON
CCOMP sdcc
goto exit

REM
REM   for MC6809
REM
:MC6809
CDD C:\N8VEM\MC6809
CDD D:\MC6809
echo ON
CCOMP none
goto exit

REM
REM	for dev86-0.16.21 development
REM
:DEV86
:BCC21
CDD F:\dev86-~1.21
echo ON
CCOMP GCC
goto exit


:exit
alias make=foo


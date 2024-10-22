@echo off
REM   save only source files so that we can transmit through
REM   gmail.com -- no good files are:  *.bin *.bat *.exe *.com &c.
REM
dir *.zip > %tmp%\foo
sort < %tmp%\foo
if "%1"=="" goto err2
if exist %1.zip goto err1
pkzip -P %1.zip *.lib *.asm *. *.inc *.c *.h *.doc *.txt *.baa
pkzip -Pa -xtools\exe2rom. %1.zip fpem\*.asm unasm\*.asm tools\*.?
echo .
copy %1.zip D:\sbc188
echo .
echo Place backup diskette in Drive A:
pause
chkdsk A:
dir %1.zip
pause
xcopy %1.zip A: /v
dir A:
goto end
:err1
echo %1.zip ALREADY EXISTS
goto end
:err2
echo .
echo Usage:  GMAIL/SAVE  filename
:end

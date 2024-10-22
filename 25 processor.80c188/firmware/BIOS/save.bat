echo off

set USBdrv=E
dir *.zip > %tmp%\foo
sort < %tmp%\foo
if "%1"=="" goto err2
if exist %1.zip goto err1
REM  make roms
pkzip -P %1.zip *.lib *.cfg *.asm *. *.inc *.b* e*.sys *.c *.h *.doc *.txt
pkzip -Pa %1.zip fpem\*.asm fpem\make*.* unasm\*.* tools\*.*
echo .
copy %1.zip D:\sbc188
echo .
echo Please mount flash drive in USB port
pause
REM chkdsk %USBdrv%:
REM pause
xcopy %1.zip %USBdrv%:\SBC188\ZIPPO /v
dir %USBdrv%:\SBC188\ZIPPO
goto end
:err1
echo %1.zip ALREADY EXISTS
goto end
:err2
echo .
echo Usage:  SAVE  filename
:end
set USBdrv

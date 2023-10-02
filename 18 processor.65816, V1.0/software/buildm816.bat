cls
c:\wdc\tools\bin\wdc816as -L sbc65816\rom816.asm -O sbc65816\rom816.obj
c:\wdc\tools\bin\wdcln -V -HI -T  sbc65816\rom816.obj  -O sbc65816\rom816.hex
hex2bin -R32K -d 0 -s 32768 -osbc65816\rom816.bin sbc65816\rom816.hex
pause
cls
c:\wdc\tools\bin\wdc816as -L sbc65816\scrm816.asm -O sbc65816\scrm816.obj
c:\wdc\tools\bin\wdcln -V -HI -T  sbc65816\scrm816.obj  -O sbc65816\scrm816.hex
hex2bin -R32K -d 0 -s 32768 -osbc65816\scrm816.bin sbc65816\scrm816.hex
pause
cls
c:\wdc\tools\bin\wdc816as -L sbc65816\testfp.asm -O sbc65816\testfp.obj
c:\wdc\tools\bin\wdcln -V -HM19 -T  sbc65816\testfp.obj  -O sbc65816\testfp.s19
pause
cls
c:\wdc\tools\bin\wdc816as -L sbc65816\testbus.asm -O sbc65816\testbus.obj
c:\wdc\tools\bin\wdcln -V -HM19 -T  sbc65816\testbus.obj  -O sbc65816\testbus.s19



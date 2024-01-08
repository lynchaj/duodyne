#!/bin/sh
as99 -o bs.o bootsel.s
ld99 -a 0x1500 bs.o
mv a.out menu.out

as99 -o mb.o mdexboot.s
ld99 -a 0x7800 mb.o
strip99 a.out
mv a.out mdexldr.out

as99 -o ub.o unixboot.s
ld99 -a 0x7b00 ub.o
strip99 a.out
mv a.out unixldr.out

gcc -o makebin makebin.c
./makebin

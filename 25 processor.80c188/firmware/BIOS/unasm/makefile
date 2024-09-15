# Makefile for _unasm
#
#  Test.C requires MSC 7.00  (C700)
#
#
unasm.obj:	unasm.asm cutmacs.asm
	masm /L /MX /P /ZI unasm;

test:	test.exe

test.exe:	test.obj unasm.obj
	link /co /ma /st:4096 $**;

test.obj:	test.c
	cl /c /AC /Zi /G2s  test.c

tidy:
        del *.lst
        del foo*.*

clean:
	del *.obj

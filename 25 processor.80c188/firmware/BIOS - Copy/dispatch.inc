; dispatch table macros
;


%macro	YYY 2.nolist		; code, address
%if _DISPATCH==1
	db	%1
%elif _DISPATCH==2
	dw	%2
%endif
%endmacro


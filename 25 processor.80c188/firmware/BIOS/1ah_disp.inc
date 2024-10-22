; 1Ah_disp.inc -- dispatch the timer functions
;
YYY	0, get_tick_count
YYY	1, set_tick_count
YYY	2, get_time
YYY	3, set_time
YYY	4, get_date
YYY	5, set_date
YYY	6, set_alarm
YYY	7, reset_alarm

YYY	20h, ds_read		; 20h
YYY	21h, ds_write		; 21h
YYY	22h, wr_protect		; 22h
YYY	23h, ds_set_charge	; 23h
YYY	24h, ds_get_charge	; 24h

; end 1Ah_disp.inc


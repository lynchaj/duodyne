vlog -work work U:/_Data/Design/Altera/Quartus/First/simulation/modelsim/Waveform.vwf.vt
vsim -novopt -c -t 1ps -L max7000s_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.First_vlg_vec_tst
onerror {resume}
add wave {First_vlg_vec_tst/i1/Out_0}
add wave {First_vlg_vec_tst/i1/Out_1}
add wave {First_vlg_vec_tst/i1/Out_2}
add wave {First_vlg_vec_tst/i1/Out_3}
add wave {First_vlg_vec_tst/i1/Out_4}
add wave {First_vlg_vec_tst/i1/Out_5}
add wave {First_vlg_vec_tst/i1/Out_6}
add wave {First_vlg_vec_tst/i1/Out_7}
add wave {First_vlg_vec_tst/i1/pin_name1}
add wave {First_vlg_vec_tst/i1/pin_name2}
add wave {First_vlg_vec_tst/i1/pin_name3}
add wave {First_vlg_vec_tst/i1/pin_name4}
add wave {First_vlg_vec_tst/i1/pin_name5}
add wave {First_vlg_vec_tst/i1/pin_name6}
add wave {First_vlg_vec_tst/i1/pin_name7}
add wave {First_vlg_vec_tst/i1/pin_name8}
add wave {First_vlg_vec_tst/i1/Clock}
add wave {First_vlg_vec_tst/i1/CP}
add wave {First_vlg_vec_tst/i1/Div_100}
add wave {First_vlg_vec_tst/i1/Div_1000}
add wave {First_vlg_vec_tst/i1/Div_10}
run -all

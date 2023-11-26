vlog -work work U:/_Data/Design/Altera/Quartus/First/simulation/modelsim/Waveform2.vwf.vt
vsim -novopt -c -t 1ps -L max7000s_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.First_vlg_vec_tst
onerror {resume}
add wave {First_vlg_vec_tst/i1/K0/LPM_CONSTANT_component/result}
add wave {First_vlg_vec_tst/i1/K0/LPM_CONSTANT_component/result[7]}
add wave {First_vlg_vec_tst/i1/K0/LPM_CONSTANT_component/result[6]}
add wave {First_vlg_vec_tst/i1/K0/LPM_CONSTANT_component/result[5]}
add wave {First_vlg_vec_tst/i1/K0/LPM_CONSTANT_component/result[4]}
add wave {First_vlg_vec_tst/i1/K0/LPM_CONSTANT_component/result[3]}
add wave {First_vlg_vec_tst/i1/K0/LPM_CONSTANT_component/result[2]}
add wave {First_vlg_vec_tst/i1/K0/LPM_CONSTANT_component/result[1]}
add wave {First_vlg_vec_tst/i1/K0/LPM_CONSTANT_component/result[0]}
run -all

onerror {quit -f}
vlib work
vlog -work work First.vo
vlog -work work First.vt
vsim -novopt -c -t 1ps -L max7000s_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.First_vlg_vec_tst
vcd file -direction First.msim.vcd
vcd add -internal First_vlg_vec_tst/*
vcd add -internal First_vlg_vec_tst/i1/*
add wave /*
run -all

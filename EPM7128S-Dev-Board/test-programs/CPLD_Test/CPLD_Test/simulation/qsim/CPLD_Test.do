onerror {quit -f}
vlib work
vlog -work work CPLD_Test.vo
vlog -work work CPLD_Test.vt
vsim -novopt -c -t 1ps -L max7000s_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.CPLD_Test_vlg_vec_tst
vcd file -direction CPLD_Test.msim.vcd
vcd add -internal CPLD_Test_vlg_vec_tst/*
vcd add -internal CPLD_Test_vlg_vec_tst/i1/*
add wave /*
run -all

onerror {quit -code 1}

set test aes_smoke_test
if {[info exists env(TEST)]} {
    set test $env(TEST)
}

set seed 1
if {[info exists env(SEED)]} {
    set seed $env(SEED)
}

if {[info exists env(AES_PROJECT_ROOT)]} {
    set root $env(AES_PROJECT_ROOT)
} else {
    set root [file normalize [file join [file dirname [info script]] ..]]
}

file mkdir $root/sim/reports
vmap work $root/sim/work

set run_log $root/sim/reports/${test}_${seed}.log
set run_ucdb $root/sim/reports/${test}_${seed}.ucdb

vsim -coverage -voptargs=+acc \
    -sv_lib C:/questasim/uvm-1.1d/win64/uvm_dpi \
    work.tb_top +UVM_TESTNAME=$test -sv_seed $seed -l $run_log

coverage save -onexit $run_ucdb
run -all

onerror {quit -code 1}

if {![info exists env(UVM_HOME)]} {
    set env(UVM_HOME) C:/questasim/verilog_src/uvm-1.1d
}

if {[info exists env(AES_PROJECT_ROOT)]} {
    set root $env(AES_PROJECT_ROOT)
} else {
    set root [file normalize [file join [file dirname [info script]] ..]]
}

set root [string map {\\ /} $root]
set env(UVM_HOME) [string map {\\ /} $env(UVM_HOME)]

if {[file exists $env(UVM_HOME)/uvm_pkg.sv]} {
    set uvm_src $env(UVM_HOME)
} else {
    set uvm_src $env(UVM_HOME)/src
}

set rtl_dir $root/rtl
set tb_dir $root/tb
set worklib $root/sim/work
set tb_incdirs "+incdir+$uvm_src+$tb_dir/packages+$tb_dir/env+$tb_dir/sequences+$tb_dir/tests"

if {[file exists $worklib]} {
    vdel -lib $worklib -all
}

vlib $worklib
vmap work $worklib

# Compile the configured UVM library before the project packages.
vlog -sv -work work +incdir+$uvm_src $uvm_src/uvm_pkg.sv

# Compile synthesizable RTL in package and module dependency order.
vlog -sv -cover bcesft -work work $rtl_dir/aes128_pkg.sv
vlog -sv -cover bcesft -work work $rtl_dir/aes128_key_expand.sv
vlog -sv -cover bcesft -work work $rtl_dir/aes128_block_engine.sv
vlog -sv -cover bcesft -work work $rtl_dir/aes128_core.sv

# Compile the independent oracle and interface before the UVM package.
vlog -sv -cover bcesft -work work $tb_dir/models/aes_ref_pkg.sv
vlog -sv -cover bcesft -work work $tb_dir/testbench/aes_if.sv

# aes_uvm_pkg includes component, sequence, and test fragments by dependency.
vlog -sv -cover bcesft -work work $tb_incdirs $tb_dir/packages/aes_uvm_pkg.sv
vlog -sv -cover bcesft -work work $tb_dir/testbench/aes_assertions.sv
vlog -sv -cover bcesft -work work $tb_dir/testbench/tb_top.sv

quit -code 0

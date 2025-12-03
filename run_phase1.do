vlib work
vmap work work

vlog prog_count.v
vlog instruction_memory.v
vlog instruction_reg.v
vlog controller_fsm.v
vlog cpu_phase1.v
vlog tb_cpu_phase1.v

vsim tb_cpu_phase1

add wave -r sim:/tb_cpu_phase1/DUT/*

run -all

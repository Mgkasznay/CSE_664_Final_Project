# ======================================================
# ModelSim Do File for Accumulator Testbench
# ======================================================

vlib work
vmap work work

vlog accumulator.v
vlog tb_accumulator.v

vsim tb_accumulator

add wave -position end sim:/tb_accumulator/*

run -all

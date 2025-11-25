# ======================================================
# ModelSim Do File for ALU Testbench
# ======================================================

# Create work library
vlib work
vmap work work

# Compile source files
vlog alu.v
vlog tb_alu.v

# Load simulation
vsim tb_alu

# Add signals to waveform
add wave -position end sim:/tb_alu/*

# Run simulation
run -all

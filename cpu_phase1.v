//=====================================================================
//  CPU TOP-LEVEL ? INTEGRATION PHASE 1
//=====================================================================
//  Components Connected:
//      ? Program Counter (PC)
//      ? Instruction Memory (IMEM)
//      ? Instruction Register (IR)
//      ? Controller FSM
//
//  What Works in Phase 1:
//      ? PC increments every FETCH cycle
//      ? IMEM outputs instruction at PC address
//      ? IR latches instruction on loadIR
//      ? Controller FSM cycles FETCH ? EXEC ? FETCH ? EXEC
//      ? HALT instruction stops the FSM (state = HALT)
// 
//  What Is NOT Included Yet:
//      ? ALU
//      ? ACC
//      ? Register File
//      ? Branch MUX
//      ? Data path connections
//
//=====================================================================

module cpu_phase1 (
    input clk
);

    // ---------------------------
    // Internal wiring
    // ---------------------------
    wire [7:0] pc_out;        // Program Counter ? Instruction Memory address
    wire [7:0] instr_word;    // Instruction Memory ? IR input
    wire [3:0] opcode;        // IR output (upper 4 bits)
    wire [3:0] operand;       // IR output (lower 4 bits)

    // Control signals from Controller FSM
    wire loadIR, incPC, loadPC, loadAcc, loadReg, selPC, halt;
    wire [1:0] selACC;
    wire [3:0] aluOp;

    // Temporary (ALU not connected yet)
    wire flagZ = 1'b0;
    wire flagN = 1'b0;

    //=================================================================
    //  PROGRAM COUNTER
    //  tells you whether to increment to the next instruction number in the program (in the Instruction Memory), or jump to a specific instruction (in the Instruction Memory) when loadPC = 1
    //=================================================================
    prog_count PC (
	// output of Program Counter
        .ins_mem(pc_out), // 4 bit, what instruction number do we want? ranges from instruction #0 to #15, goes to Instruction Memory
        
	// inputs of Program Counter
        .clk(clk),
        .incPC(incPC), // 1 bit, tells you whether to incrememnt to the next instruction in Instruction Memory, comes from the Controller
        .loadPC(loadPC), // 1 bit, tells you whether to load a specific instruction number from the Instruction Memory, comes from the Controller
	.selPC({4'b0000, operand})   // TEMPORARY: Use operand as immediate; 8 bit, if loadPC = 1, this is the instruction number we want to load from Instruction Memory, comes from the Controller
    );

    //=================================================================
    //  INSTRUCTION MEMORY
    //  stores the sequence of isntructions that make up a program, ranging from instruction #0 to #15. Is told by the Program Counter what instruction number we want, then outputs the specified instruction
    //=================================================================
    ins_register_file IMEM (
	// output of Instruction Memory
        .ins_val(instr_word), // 8 bit, what is the instruction? goes to the Instruction Register
	
	// input of Instruction Memory
        .prog_count(pc_out) // 4 bit, which instruction number do we want to read? ranges from instruction #0 to #15, comes from the Program Counter
    );

    //=================================================================
    //  INSTRUCTION REGISTER
    //  if loadIR = 1, decodes an instruction (coming from the Instruction Memory) and outputs the opcode and immediate/register value
    //=================================================================
    ins_reg IR (
	// output of Instruction Register
        .opcode(opcode), // 4 bit, if loadIR = 1, our opcode is bits [7:4] of ins_reg, goes to the Controller
        .imed_reg(operand), // 4 bit, if loadIR = 1, our immediate or register number is bits [3:0] of ins_reg, goes to the Register File

	// input of Instruction Register
        .clk(clk),
        .loadIR(loadIR), // 1 bit, loadIR = 1 indicates we want to load an instruction and decode it, otherwise we're not doing anything, comes from the Controller
        .ins_reg(instr_word) // 8 bit, what is the instruction that we want to decode? comes from the Instruction Memory
    );

    //=================================================================
    //  REGISTER FILE
    //  contains 16 8 bit registers where values can be stored. Can write/load a value to a scpefied register if loadReg = 1. 
    //  Always outputs the value at the specfied register (regardless of whether we're writing/loading a value
    //=================================================================
    register_file REG(
	// output of Register File
	.data_out(), // 8 bit, the value we're reading from a register specified by regAdd, goes to the Accumulator (via the ALU?) or Program Counter

	// input of Register File
	.clk(clk),
	.loadReg(loadReg), // 1 bit, if loadReg = 1, that indicates that we want to write/load a value to the register specified by regAdd, comes from the Controller
	.regAdd(operand), // 4 bit, the register we want to write a value to (if loadReg = 1), and also the register we want to read from (regardless of whether loadReg = 1 or not. ranges from Register #0-#15, comes from Instruction Register
	.data_in() // 8 bit, the value we are writing to the register specified by regAdd (if loadReg = 1), comes from the Accumulator
    );
    //=================================================================
    //  CONTROLLER FSM
    //=================================================================
    controller_fsm CONTROL (
	// output of Controller

        .loadIR(loadIR), // 1 bit, indicates whether to load an instruction from the Instruction Memory into the Instruction Register (so that the Instruction Register can decode the isntruction); goes to the Instruction Register
        .incPC(incPC), // 1 bit, indicates whether the Program Counter should increment, goes to the Program Counter
        .loadPC(loadPC), // 1 bit, indicates whether we want to load a specific instruction number to the Program Counter, goes to the Program Counter
        .loadAcc(loadAcc),   // not used yet, 1 bit, indicates whether we want to store an immediate ALU result within the ACC
        .loadReg(loadReg),   // 1 bit, indicates whether we want to write/load a value to the Register File
        .selPC(selPC), // 1 bit, THIS DOES NOT MATCH THE 8-bit selPC IN THE PROGRAM COUNTER; 0 = Reg -> PC, 1 = Imm -> PC
        .selACC(selACC), // 2 bit, 00 = ALU -> ACC, 01 = Reg -> ACC, 10 = Imm -> ACC
        .aluOp(aluOp), // 4 bit, indicates an ALU opcode corresponding to 0001: ADD, 0010: SUB, 0011: NOR, 1011: SHIFT LEFT, 1100: SHIFT RIGHT
        .halt(halt), // 1 bit, halt = 1 indicates we should halt our program

	// input of Controller
        .clk(clk),
        //.instr(instr_word),  // Controller sees the full instruction byte, 8 bit, the instruction, comes from Instruction Register
	.opcode(opcode), // 4 bit, comes from the Instruction Register (LZ - replacing previous line with this due to modification I made to the controller_fsm.v file. We don't need to read the full instruction, the Instruction Register already decodes the instruction so we can directly input the opcode from the Instruction Register)
        .flagZ(flagZ),	// 1 bit, ALU zero flag
        .flagN(flagN)	// ALU negative flag, ACC[7] = 1
    );

endmodule

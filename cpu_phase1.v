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
    //=================================================================
    prog_count PC (
        .pc_out(pc_out),
        .selPC({4'b0000, operand}),   // TEMPORARY: Use operand as immediate
        .clk(clk),
        .incPC(incPC),
        .loadPC(loadPC)
    );

    //=================================================================
    //  INSTRUCTION MEMORY
    //=================================================================
    instruction_memory IMEM (
        .ins_val(instr_word),
        .prog_count(pc_out)
    );

    //=================================================================
    //  INSTRUCTION REGISTER
    //=================================================================
    instruction_reg IR (
        .opcode(opcode),
        .operand(operand),
        .clk(clk),
        .loadIR(loadIR),
        .instr_in(instr_word)
    );

    //=================================================================
    //  CONTROLLER FSM
    //=================================================================
    controller_fsm CONTROL (
        .clk(clk),
        .instr(instr_word),  // Controller sees the full instruction byte
        .flagZ(flagZ),
        .flagN(flagN),
        .loadIR(loadIR),
        .incPC(incPC),
        .loadPC(loadPC),
        .loadAcc(loadAcc),   // not used yet
        .loadReg(loadReg),   // not used yet
        .selPC(selPC),
        .selACC(selACC),
        .aluOp(aluOp),
        .halt(halt)
    );

endmodule

module MPTB;
// ---------------------------
// Internal wiring
// ---------------------------
reg clk; //Clock signal used by multiple modules
wire [3:0] opcode; //First 4 bits of instructions output from instruction register. Determines what instruction will be executed.
wire [3:0] immediate; //Last 4 bits of instruction output from instruction register. Gives immediate value or register address for certain instructions.
wire [7:0] instr; //Wire to represent the 8-bit instruction
assign instr = {opcode, immediate}; //instr wire is the concatenation of opcode and immediate and is the input to the controller FSM module
wire loadIR, incPC, selPC, loadPC, loadReg, loadAcc, halt; //Control outputs of the controller FSM
wire [1:0] selACC; //Output from controller FSM. Determines if ACC input is the ALU result, output from the register file, or the instruction immediate value
wire [3:0] aluOp; //Output from controller FSM. Determines the ALU operation performed
wire flagZ, flagN, flagC; //Output flags from ALU, Z=>Zero N=>Negative C=>Carry
wire [7:0] PCinput; //Instruction memory address value that will become the next instruction if loadPC is 1
wire [7:0] RFoutput; //Output of the register determined by the read address which is always the immediate value of the instruction
wire [7:0] ACCinput; //Stores the input to the accumulator determined by selACC. This value is loaded into the ACC if loadACC is 1
wire [7:0] ACCoutput; //Once a new input is loaded into the ACC, it is output to ACCouput, which provides operand value to ALU and value to be stored in the register file
wire [7:0] ACC1MUXinput; //Output of the mux that selected either the output from the register file and the immediate value.
wire [7:0] ALUresult; //Once the specified operation is performed by the ALU, outputs to this wire which could potentially be the input to the accumulator
wire [3:0] mem_address; //The address of the instruction that will be exectued next. It is output from the program counter.
wire [7:0] IRinput; //Once the next instruction memory address is determined, this value represents that new 8-bit instruction

//Once all modules have been instantiated and the instruction memory has the instructions of the desired program,
//the only value required to drive the microprocessory is the clock signal
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//=================================================================
//  CONTROLLER FSM
//  Receives instruction and flag values and controls flow of data by sending control outputs to most of the other modules
//=================================================================
controller_fsm CTR (
    .clk(clk),

    //Instruction value input
    .instr(instr),

    //Input flags from ALU
    .flagZ(flagZ),
    .flagN(flagN),

    //Output control values
    .loadIR(loadIR),
    .incPC(incPC),
    .loadPC(loadPC),
    .loadAcc(loadAcc),
    .loadReg(loadReg),
    .selPC(selPC),
    .selACC(selACC),
    .aluOp(aluOp),
    .halt(halt)
);

//=================================================================
//  PCMUX
//  This MUX is used to select between the immediate value from the instruction register and the passed in register value to determine the alternate program counter
//=================================================================
mux PCMUX (
    //Output
    .out(PCinput),

    //Inputs
    .a(RFoutput),
    .b({4'b0000, immediate}),

    //Control
    .sel(selPC)
);

//=================================================================
//  ACC1MUX
//  Selects between output of ALU and the output of ACC0MUX. This output is the input to the accumulator
//=================================================================
mux ACC1MUX (
    //Output
    .out(ACCinput),

    //Inputs
    .a(ACC1MUXinput),
    .b(ALUresult),

    //Control
    .sel(selACC[1])
);

//=================================================================
//  ACC0MUX
//  Selects between register data value and immediate value of instruction and sends output to the ACC1MUX
//=================================================================
mux ACC0MUX (
    //Output
    .out(ACC1MUXinput),

    //Inputs
    .a({4'b0000, immediate}),
    .b(RFoutput),

    //Control
    .sel(selACC[0])
);

//=================================================================
//  ACCUMULATOR
//  Register to temporarily store ALU outputs, data from registers, or immediate values
//=================================================================
accumulator ACM (
    .clk(clk),

    //Control
    .loadAcc(loadAcc),

    //Input
    .dataIn(ACCinput),

    //Output
    .accOut(ACCoutput)
);

//=================================================================
//  ALU
//  Arithmetic Logic Unit supports the following operations: ADD, SUB, NOR, ShiftLeft, ShiftRight
//=================================================================
alu ALU (
    //Operand inputs
    .A(RFoutput),
    .B(ACCoutput),

    //Control
    .aluOp(aluOp),

    //Output
    .result(ALUresult),

    //Flags
    .Z(flagZ),
    .C(flagC),
    .N(flagN)
);

//=================================================================
//  REGISTER FILE
//  Contains 16 8-bit registers to store values. Reads from and writes to registers specified by immediate value
//  Input values to be stored in the registers come from the accumulator
//=================================================================
register_file RF (
    //Register output value
    .read_data(RFoutput),

    .clk(clk),

    //Control
    .write_enable(loadReg),

    //Input address value
    .write_address(immediate),

    //Output
    .write_data(ACCoutput),

    //Input address value
    .read_address(immediate)
);

//=================================================================
//  Program Counter
//  Determines the address of the next instruction to be used from instruction memory
//  Normally memory address is the next sequential memory address, but can be the PCinput value if there is a branch instruction performed
//=================================================================
prog_count PC (
    //Output
    .ins_mem(mem_address),

    .clk(clk),

    //Controls
    .incPC(incPC),
    .loadPC(loadPC),

    //Input
    .PCinput(PCinput)
);

//=================================================================
//  INSTRUCTION MEMORY
//  Stores 16 8-bit instructions to be executed by the microprocessor
//  Outputs instruction determined by memory address value
//=================================================================
ins_memory IM (
    //Output instruction value
    .ins_val(IRinput),

    //Input instruction memory address
    .prog_count(mem_address)
);

//=================================================================
//  INSTRUCTION REGISTER
//  Register that stores incoming instruction values and outputs immediate and opcode values based on the instruction
//=================================================================
ins_reg IR (
    //4-bit outputs of the split instruction value
    .imed_reg(immediate),
    .opcode(opcode),

    .clk(clk),

    //Control
    .loadIR(loadIR),

    //Instruction value input from instruction memory
    .ins_reg(IRinput)
);


endmodule
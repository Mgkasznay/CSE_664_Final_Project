module micro_controller_tb;

    reg  [7:0] A;
    reg  [3:0] aluOp;
    wire [7:0] result;
    wire Z, C, N;

    parameter word_size  = 8; // each register is 8 bits, or 256 words
    parameter num_reg    = 16; // 16 total registers in file
    parameter index_size = 4; // 4 bits = 16 decimal, because we have 16 registers to choose from

    //input
    reg write_enable;
    reg [index_size-1:0] write_address;
    reg [word_size-1:0] write_data;

    reg [index_size-1:0] read_address1;
    reg[index_size-1:0] read_address2;

	//output
    wire [word_size-1:0] read_data1;
    wire [word_size-1:0] read_data2;

    reg clk;
    reg loadAcc;
    reg [7:0] dataIn;
    wire [7:0] accOut;

    reg [7:0] instr;
    reg flagZ, flagN;

    wire loadIR, incPC, loadPC, loadReg;
    wire selPC;
    wire [1:0] selACC;
    wire halt;

    wire selectedPC[7:0];
    wire selectedInsLoc[3:0];
    wire selectedInsData[7:0];
    wire regImed[3:0];

    wire selAcc0Out[7:0];
    wire selAcc1Out[7:0];


    // Instantiate ALU
    alu ALU (
        .A(A), //FROM Registers or ACC maybe add a mux here?
        .B(read_data2), 
        .aluOp(aluOp),
        .result(result),
        .Z(Z),
        .C(C), //Where does this go???
        .N(N)
    );


    // Instantiate ACC
    accumulator ACC (
        .clk(clk),
        .loadAcc(loadAcc),
        .dataIn(selAcc1Out),
        .accOut(accOut) //Going to regsiter memory somehow need a moderator in here
    );

    // Instantiate the FSM
    controller_fsm FSM (
        .clk(clk),
        .instr(instr),
        .flagZ(flagZ),
        .flagN(flagN),
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


	//Instantiate the REG
	register_file REG (
		.read_data1(read_data1),  //Need a moderator here to take inputs in a format given by other modules
		.read_data2(read_data2), 
		.clk(clk),
		.write_enable(write_enable),
		.write_address(write_address),
		.write_data(write_data),
		.read_address1(read_address1),
		.read_address2(read_address2)
	);
	
	//MUX 1 selects which program counter value to use
	mux MUX1 (
		.out(selectedPC), 
		.a(read_data1), 
		.b(regImed), 
		.sel(selPC)
	);

	//MUX 2 selects which sel ACC 0
	mux MUX2 (
		.out(selAcc0Out), 
		.a(regImed), 
		.b(read_data2), 
		.sel(selACC[0])
	);

	//MUX 3 selects which sel ACC 1
	mux MUX3 (
		.out(selAcc1Out), 
		.a(selAcc0Out), 
		.b(result), 
		.sel(selACC[1])
	);

	// Instantiate the PROG
	prog_count PROG(
		.ins_mem(selectedInsLoc), 
		.clk(clk), 
		.incPC(incPC), 
		.loadPC(loadPC), 
		.selPC(selectedPC)
	);
		

	ins_reg INS (
		.imed_reg(regImed), //THIS IS HANDLED SLIGHTLY DIFFERENETLY THAN DIAGRAM for output to register memory
		.opcode(aluOp), 
		.clk(clk), 
		.loadIR(loadIR), 
		.ins_reg(selectedInsData)
	);

	ins_register_file MEM (
		.ins_val(selectedInsData), 
		.prog_count(selectedInsLoc)
	);


endmodule

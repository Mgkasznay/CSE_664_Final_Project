module MPTB;
reg clk;
wire [3:0] opcode;
wire [3:0] immediate;
wire [7:0] instr;
assign instr = {opcode, immediate};
wire loadIR, incPC, selPC, loadPC, loadReg, loadAcc, halt;
wire [1:0] selACC;
wire [3:0] aluOp;
wire flagZ, flagN, flagC;
wire [7:0] PCinput;
wire [7:0] RFoutput;
wire [7:0] ACCinput;
wire [7:0] ACCoutput;
wire [7:0] ACC1MUXinput;
wire [7:0] ALUresult;
wire [3:0] mem_address;
wire [7:0] IRinput;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

controller_fsm CTR (
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

mux PCMUX (
    .out(PCinput),
    .a(RFoutput),
    .b({4'b0000, immediate}),
    .sel(selPC)
);

mux ACC1MUX (
    .out(ACCinput),
    .a(ACC1MUXinput),
    .b(ALUresult),
    .sel(selACC[1])
);

mux ACC0MUX (
    .out(ACC1MUXinput),
    .a({4'b0000, immediate}),
    .b(RFoutput),
    .sel(selACC[0])
);

accumulator ACM (
    .clk(clk),
    .loadAcc(loadAcc),
    .dataIn(ACCinput),
    .accOut(ACCoutput)
);

alu ALU (
    .A(ACCoutput),
    .B(RFoutput),
    .aluOp(aluOp),
    .result(ALUresult),
    .Z(flagZ),
    .C(flagC),
    .N(flagN)
);

register_file RF (
    .read_data(RFoutput),
    .clk(clk),
    .write_enable(loadReg),
    .write_address(immediate),
    .write_data(ACCoutput),
    .read_address(immediate)
);

prog_count PC (
    .ins_mem(mem_address),
    .clk(clk),
    .incPC(incPC),
    .loadPC(loadPC),
    .PCinput(PCinput)
);

ins_memory IM (
    .ins_val(IRinput),
    .prog_count(mem_address)
);

ins_reg IR (
    .imed_reg(immediate),
    .opcode(opcode),
    .clk(clk),
    .loadIR(loadIR),
    .ins_reg(IRinput)
);

initial begin
    wait (halt==1);
    #20
    $finish;
end


endmodule
// 16 8-bit registers, store data
// 256 words
// inputs: Accumulator output, Immediate from Instruction Register
// output: ALU input, ACC input, program counter input
// value only updated if instruction is to move ACC to register

// register file needs 16 8-bit registers
module register_file (data_out, clk, loadReg, regAdd, data_in);

parameter word_size  = 8; // each register is 8 bits, or 256 words
parameter num_reg    = 16; // 16 total registers in file
parameter index_size = 4; // 4 bits = 16 decimal, because we have 16 registers to choose from


// [MSB:LSB], most significant bit, least significant bit
// data_out is word_size bits wide (in this case, 8 bits or 256 words)
output	[word_size-1:0] data_out;

input	clk;

input	loadReg; // indicates whether we're writing to a register
input	[index_size-1:0] regAdd; // indicates which register we want to write to (if loadReg = 1) and/or read from (ranging from register 0 - 15)
input	[word_size-1:0] data_in; // indicates what data we want to write (if loadReg = 1) (max size 8 bits or 256 words)

reg [word_size-1:0] regs[num_reg-1:0]; // create 16 registers (num_reg 0 through 15), each 8 bits wide (word_size)

always @(posedge clk)
begin
	if (loadReg) // if loadReg == 1, we are writing data to the specified address
	begin
	regs[regAdd] <= data_in;
	end
end

assign data_out = regs[regAdd]; // regardless of whether we are writing data, output the value at the specified address

endmodule

// test bench
module register_file_tb ();

parameter word_size  = 8; // each register is 8 bits, or 256 words
parameter num_reg    = 16; // 16 total registers in file
parameter index_size = 4; // 4 bits = 16 decimal, because we have 16 registers to choose from

	//input
	reg clk;
	reg loadReg;
	reg [index_size-1:0] regAdd;
	reg [word_size-1:0] data_in;

	//output
	wire [word_size-1:0] data_out;

	register_file MUT (data_out, clk, loadReg, regAdd, data_in);
	initial clk = 0;
	initial loadReg = 0;
	initial regAdd = 0;
	initial data_in = 0;

	//every 5 second, clk changes between 0 and 1.
	//every 10 seconds is a positive edge
	always #5 clk = ~clk;
	
	initial
	begin
		// write 7 to register 2, read register 2
		loadReg = 1;
		regAdd = 2;
		data_in = 7;
		#20;
	
		// write 15 to register 2, read register 2
		loadReg = 1;
		regAdd = 2;
		data_in = 15;
		#20;

		// write 255 to register 0, read register 0
		loadReg = 1;
		regAdd = 0;
		data_in = 255;
		#20;		

		// don't write anything (should ignore write_data), read register 2
		loadReg = 0;
		regAdd = 2;
		data_in = 4;
		#20;

		// write 4 to register 2, read register 2
		loadReg = 1;
		regAdd = 2;
		data_in = 4;
		#20;
	end
endmodule
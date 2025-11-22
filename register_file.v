// 16 8-bit registers, store data
// 256 words
// inputs: Accumulator output, Immediate from Instruction Register
// output: ALU input, ACC input, program counter input
// value only updated if instruction is to move ACC to register

// register file needs 16 8-bit registers
module register_file (read_data1, read_data2, clk, write_enable, write_address, write_data, read_address1, read_address2);

parameter word_size  = 8; // each register is 8 bits, or 256 words
parameter num_reg    = 16; // 16 total registers in file
parameter index_size = 4; // 4 bits = 16 decimal, because we have 16 registers to choose from


// [MSB:LSB], most significant bit, least significant bit
// readData1 is word_size bits wide (in this case, 8 bits or 256 words)
output	[word_size-1:0] read_data1;
output	[word_size-1:0] read_data2;

input	clk;

input	write_enable; // indicates whether we're writing to a register
input	[index_size-1:0] write_address; // indicates which register we want to write to (register 1-16)
input	[word_size-1:0] write_data; // indicates what data we want to write (max size 8 bits or 256 words)

input	[index_size-1:0] read_address1; // indicates which register we want to read the contents of (register 1-16)
input	[index_size-1:0] read_address2; // indicates which register we want to read the contents of (register 1-16)


reg [word_size-1:0] regs[num_reg-1:0]; // create 16 registers (num_reg 0 through 15), each 8 bits wide (word_size)

always @(posedge clk)
begin
	if (write_enable) // if write_enable == 1, we are writing data to a specified address
	begin
	regs[write_address] <= write_data;
	end
end


assign read_data1 = regs[read_address1];
assign read_data2 = regs[read_address2];

endmodule

// test bench
module register_file_tb ();

parameter word_size  = 8; // each register is 8 bits, or 256 words
parameter num_reg    = 16; // 16 total registers in file
parameter index_size = 4; // 4 bits = 16 decimal, because we have 16 registers to choose from

	//input
	reg clk;
	reg write_enable;
	reg [index_size-1:0] write_address;
	reg [word_size-1:0] write_data;

	reg [index_size-1:0] read_address1;
	reg[index_size-1:0] read_address2;

	//output
	wire [word_size-1:0] read_data1;
        wire [word_size-1:0] read_data2;

	register_file MUT (read_data1, read_data2, clk, write_enable, write_address, write_data, read_address1, read_address2);
	initial clk = 0;

	//every 5 second, clk changes between 0 and 1.
	//every 10 seconds is a positive edge
	always #5 clk = ~clk;
	
	initial
	begin
		write_enable = 1;
		write_address = 2;
		write_data = 16;
		read_address1 = 2;
		read_address2 = 0;
		#20;
	
		write_enable = 1;
		write_address = 2;
		write_data = 32;
		read_address1 = 2;
		read_address2 = 0;

	end
endmodule
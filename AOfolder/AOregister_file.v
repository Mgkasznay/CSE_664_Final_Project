// 16 8-bit registers, store data
// 256 words
// inputs: Accumulator output, Immediate from Instruction Register
// output: ALU input, ACC input, program counter input
// value only updated if instruction is to move ACC to register

// register file needs 16 8-bit registers
module register_file (read_data, clk, write_enable, write_address, write_data, read_address);

parameter word_size  = 8; // each register is 8 bits, or 256 words
parameter num_reg    = 16; // 16 total registers in file
parameter index_size = 4; // 4 bits = 16 decimal, because we have 16 registers to choose from


// [MSB:LSB], most significant bit, least significant bit
// readData is word_size bits wide (in this case, 8 bits or 256 words)
output	[word_size-1:0] read_data;

input	clk;

input	write_enable; // indicates whether we're writing to a register
input	[index_size-1:0] write_address; // indicates which register we want to write to (register 1-16)
input	[word_size-1:0] write_data; // indicates what data we want to write (max size 8 bits or 256 words)

input	[index_size-1:0] read_address; // indicates which register we want to read the contents of (register 1-16)


reg [word_size-1:0] regs[num_reg-1:0]; // create 16 registers (num_reg 0 through 15), each 8 bits wide (word_size)

always @(posedge clk)
begin
	if (write_enable) // if write_enable == 1, we are writing data to a specified address
	begin
	regs[write_address] <= write_data;
	end
end


assign read_data = regs[read_address];

endmodule
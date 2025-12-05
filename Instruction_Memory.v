// 16 8-bit instructions, store data
// input: program counter
// output: Instruction value

//Instruction memory provides the instruction at the program counter address
module ins_register_file (ins_val, prog_count);

parameter word_size  = 8; // each instruction is 8 bits, or 256 words
parameter num_ins    = 16; // 16 total instruction in file
parameter index_size = 4; // index of total number of instructions

// Output of the instruction value
output	[word_size-1:0] ins_val;

input	[index_size-1:0] prog_count; // indicates which instruction we want to read

reg [word_size-1:0] ins[num_ins-1:0]; // create 16 instructions

//assign instruction values (LZ - I changed from hexadecimal to binary representation of 8 bits)
assign ins[0] = 8'b00000000;
assign ins[1] = 8'b00000000;
assign ins[2] = 8'b00000000;
assign ins[3] = 8'b00000000;
assign ins[4] = 8'b00000000;
assign ins[5] = 8'b00000000;
assign ins[6] = 8'b00000000;
assign ins[7] = 8'b00000000;
assign ins[8] = 8'b00000000;
assign ins[9] = 8'b00000000;
assign ins[10] = 8'b00000000;
assign ins[11] = 8'b00000000;
assign ins[12] = 8'b00000000;
assign ins[13] = 8'b00000000;
assign ins[14] = 8'b00000000;
assign ins[15] = 8'b00000000;

assign ins_val = ins[prog_count]; //assign instruction value to requested value

endmodule

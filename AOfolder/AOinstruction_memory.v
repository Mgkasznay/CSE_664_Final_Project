// 16 8-bit instructions, store data
// input: program counter
// output: Instruction value

//Instruction memory provides the instruction at the program counter address
module ins_memory (ins_val, prog_count);

parameter word_size  = 8; // each instruction is 8 bits, or 256 words
parameter num_ins    = 16; // 16 total instruction in file
parameter index_size = 4; // index of total number of instructions

// Output of the instruction value
output	[word_size-1:0] ins_val;

input	[index_size-1:0] prog_count; // indicates which instruction we want to read

reg [word_size-1:0] ins[num_ins-1:0]; // create 16 instructions

//assign instruction values (LZ - I changed from hexadecimal to binary representation of 8 bits)
initial begin
    ins[0] = 8'b11011000;
    ins[1] = 8'b01010001;
    ins[2] = 8'b11010101;
    ins[3] = 8'b01010010;
    ins[4] = 8'b01000001;
    ins[5] = 8'b00010010;
    ins[6] = 8'b00100001;
    ins[7] = 8'b11010101;
    ins[8] = 8'b00110010;
    ins[9] = 8'b10110000;
    ins[10] = 8'b11000000;
    ins[11] = 8'b00000000;
    ins[12] = 8'b11110000;
    ins[13] = 8'b00000000;
    ins[14] = 8'b00000000;
    ins[15] = 8'b00000000;
end

assign ins_val = ins[prog_count]; //assign instruction value to requested value

endmodule

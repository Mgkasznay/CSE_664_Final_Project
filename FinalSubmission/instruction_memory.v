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

initial begin
    //3 Different sets of instructions to show full functionality
    //Uncomment the set to perform those instructions and comment out sets not being used
    
    //First set of instructions shows register/ACC loads, all ALU operations, NOP, and HALT
    ins[0] = 8'b11011000; // 8 -> ACC
    ins[1] = 8'b01010001; // ACC (8) -> R1
    ins[2] = 8'b11010101; // 5 -> ACC
    ins[3] = 8'b01010010; // ACC (5) -> R2
    ins[4] = 8'b01000001; // R1 (8) -> ACC
    ins[5] = 8'b00010010; // ACC (8) + R2 (5) -> ACC
    ins[6] = 8'b00100001; // R1 (8) - ACC (13) -> ACC
    ins[7] = 8'b11010101; // 5 -> ACC
    ins[8] = 8'b00110010; // R2 (5) NOR ACC (5) -> ACC
    ins[9] = 8'b10110000; // ACC ShiftLeft
    ins[10] = 8'b11000000; // ACC ShiftRight
    ins[11] = 8'b00000000; // NOP
    ins[12] = 8'b11110000; // HALT
    ins[13] = 8'b00000000; // Remaining instructions not performed because of HALT
    ins[14] = 8'b00000000;
    ins[15] = 8'b00000000;

    //Second set of instructions shows branch instructions for when ACC=0
    /*
    ins[0] = 8'b11010101; // 5 -> ACC
    ins[1] = 8'b01010111; // ACC (5) -> R7
    ins[2] = 8'b00100111; // R7 (5) - ACC (5) -> ACC
    ins[3] = 8'b01100111; // If ACC=0, J R7 (5)
    ins[4] = 8'b11110000; // HALT (should be skipped)
    ins[5] = 8'b11011010; // 10 -> ACC
    ins[6] = 8'b01011000; // ACC (10) -> R8
    ins[7] = 8'b00101000; // R8 (10) - ACC (10) -> ACC 
    ins[8] = 8'b01111010; // If ACC=0, J 10 
    ins[9] = 8'b11110000; // HALT (should be skipped)
    ins[10] = 8'b11011111; // 15 -> ACC
    ins[11] = 8'b11110000; // HALT
    ins[12] = 8'b00000000; // Remaining instructions not performed because of HALT
    ins[13] = 8'b00000000;
    ins[14] = 8'b00000000;
    ins[15] = 8'b00000000;
    */

    //Third set of instructions shows branch instructions for when ACC<0
    /*
    ins[0] = 8'b11010110; // 6 -> ACC
    ins[1] = 8'b01011010; // ACC (6) -> R10
    ins[2] = 8'b11010111; // 7 -> ACC
    ins[3] = 8'b00101010; // R10 (6) - ACC (7) -> ACC
    ins[4] = 8'b10001010; // If ACC<0, J R10 (6)
    ins[5] = 8'b11110000; // HALT (should be skipped)
    ins[6] = 8'b11011000; // 8 -> ACC
    ins[7] = 8'b01011011; // ACC (8) -> R11
    ins[8] = 8'b11011001; // 9 -> ACC
    ins[9] = 8'b00101011; // R11 (8) - ACC (9) -> ACC
    ins[10] = 8'b10101100; // If ACC<0, J 12
    ins[11] = 8'b11110000; // HALT (should be skipped)
    ins[12] = 8'b11011111; // 15 -> ACC
    ins[13] = 8'b11110000; // HALT
    ins[14] = 8'b00000000; // Remaining instructions not performed because of HALT
    ins[15] = 8'b00000000;
    */

end

assign ins_val = ins[prog_count]; //assign instruction value to requested value

endmodule

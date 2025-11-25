//========================================================
// 8-bit ALU for Microcontroller Project
// Supports: ADD, SUB, NOR, SHIFT LEFT, SHIFT RIGHT
//========================================================
module alu (
    input  [7:0] A,        // Operand 1 (usually Register File output)
    input  [7:0] B,        // Operand 2 (usually ACC)
    input  [3:0] aluOp,    // Function select
    output reg [7:0] result,
    output reg       Z,    // Zero flag
    output reg       C,    // Carry/borrow flag (for add/sub)
    output reg       N     // Negative flag (MSB of result)
);

    always @(*) begin
        result = 8'h00;
        C      = 1'b0;

        case (aluOp)

            4'b0001: {C, result} = A + B;      // ADD

            4'b0010: {C, result} = A - B;      // SUB

            4'b0011: result = ~(A | B);        // NOR

            4'b1011: result = B << 1;          // SHIFT LEFT ACC

            4'b1100: result = B >> 1;          // SHIFT RIGHT ACC

            default: result = 8'h00;

        endcase

        Z = (result == 8'h00);
        N = result[7];

    end

endmodule


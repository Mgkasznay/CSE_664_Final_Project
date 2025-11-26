`timescale 1ns/1ps

module tb_alu;

    reg  [7:0] A, B;
    reg  [3:0] aluOp;
    wire [7:0] result;
    wire Z, C, N;

    // Instantiate ALU
    alu DUT (
        .A(A),
        .B(B),
        .aluOp(aluOp),
        .result(result),
        .Z(Z),
        .C(C),
        .N(N)
    );

    initial begin
        // Test ADD
        A = 8'd10; B = 8'd5; aluOp = 4'b0001;
        #10 $display("ADD: A=%0d B=%0d result=%0d C=%b Z=%b N=%b", A, B, result, C, Z, N);

        // Test SUB
        A = 8'd20; B = 8'd30; aluOp = 4'b0010;
        #10 $display("SUB: A=%0d B=%0d result=%0d C=%b Z=%b N=%b", A, B, result, C, Z, N);

        // Test NOR
        A = 8'b10101010; B = 8'b11000011; aluOp = 4'b0011;
        #10 $display("NOR: A=%b B=%b result=%b Z=%b N=%b", A, B, result, Z, N);

        // Test SHIFT LEFT
        A = 8'd00; B = 8'b01010101; aluOp = 4'b1011;
        #10 $display("SHL: B=%b result=%b", B, result);

        // Test SHIFT RIGHT
        A = 8'd00; B = 8'b10000001; aluOp = 4'b1100;
        #10 $display("SHR: B=%b result=%b", B, result);

        $stop;
    end

endmodule

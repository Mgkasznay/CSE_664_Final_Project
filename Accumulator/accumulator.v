//========================================================
// 8-bit Accumulator Register (ACC)
//========================================================
module accumulator (
    input        clk,
    input        loadAcc,
    input  [7:0] dataIn,
    output reg [7:0] accOut
);

    always @(posedge clk) begin
        if (loadAcc)
            accOut <= dataIn;
    end

endmodule

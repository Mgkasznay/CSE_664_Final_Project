`timescale 1ns/1ps

module tb_accumulator;

    reg clk;
    reg loadAcc;
    reg [7:0] dataIn;
    wire [7:0] accOut;

    // Instantiate DUT
    accumulator DUT (
        .clk(clk),
        .loadAcc(loadAcc),
        .dataIn(dataIn),
        .accOut(accOut)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initial values
        loadAcc = 0;
        dataIn  = 8'h00;

        // Wait a cycle
        #10;

        // Test 1: Load 0xAA
        dataIn  = 8'hAA;
        loadAcc = 1;
        #10;   // one CLK edge

        // Test 2: load disabled (ACC must hold value)
        loadAcc = 0;
        dataIn  = 8'h55;
        #20;

        // Test 3: Load 0x3C
        dataIn  = 8'h3C;
        loadAcc = 1;
        #10;

        // Stop
        $stop;
    end

endmodule

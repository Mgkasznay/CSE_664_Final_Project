`timescale 1ns/1ps

module tb_cpu_phase1;

    reg clk;

    cpu_phase1 DUT (.clk(clk));

    // 10ns clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        #300;
        $stop;
    end

endmodule

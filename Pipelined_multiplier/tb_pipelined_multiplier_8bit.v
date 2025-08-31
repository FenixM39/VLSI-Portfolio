`timescale 1ns/1ps
module tb_pipelined_multiplier_8bit;

    reg clk, rst;
    reg [7:0] A, B;
    wire [15:0] P;

    // Instantiate DUT
    pipelined_multiplier_8bit dut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .P(P)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test procedure
    initial begin
        rst = 1; A = 0; B = 0;
        #12 rst = 0;

        // Apply some test cases
        #10 A = 8'd15; B = 8'd10;   // 150
        #10 A = 8'd25; B = 8'd12;   // 300
        #10 A = 8'd50; B = 8'd20;   // 1000
        #10 A = 8'd100; B = 8'd5;   // 500
        #10 A = 8'd200; B = 8'd3;   // 600

        #100 $stop;
    end

endmodule

`timescale 1ns / 1ps

module tb_alu16;

    // Testbench signals
    reg  [15:0] a, b;
    reg  [3:0]  opcode;
    wire [15:0] y;
    wire zero, carry, overflow, negative;

    // Instantiate DUT
    alu16 uut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .y(y),
        .zero(zero),
        .carry(carry),
        .overflow(overflow),
        .negative(negative)
    );

    // Task for printing results
    task display_result;
        begin
            $display("Time=%0t | opcode=%b | a=%h | b=%h | y=%h | zero=%b | carry=%b | overflow=%b | neg=%b",
                     $time, opcode, a, b, y, zero, carry, overflow, negative);
        end
    endtask

    initial begin
        // Dump waveform
        $dumpfile("alu16_tb.vcd");
        $dumpvars(0, tb_alu16);

        // Initialize
        a = 16'h0000; b = 16'h0000; opcode = 4'b0000;
        #10;

        // ADD
        a = 16'h1234; b = 16'h1111; opcode = 4'b0000; #10; display_result();
        a = 16'h7FFF; b = 16'h0001; opcode = 4'b0000; #10; display_result(); // Overflow

        // SUB
        a = 16'h8000; b = 16'h0001; opcode = 4'b0001; #10; display_result();
        a = 16'h0001; b = 16'h0002; opcode = 4'b0001; #10; display_result();

        // Logic ops
        a = 16'hAAAA; b = 16'h5555; opcode = 4'b0010; #10; display_result(); // AND
        opcode = 4'b0011; #10; display_result(); // OR
        opcode = 4'b0100; #10; display_result(); // XOR
        opcode = 4'b0101; #10; display_result(); // NOR

        // Shifts
        a = 16'h00FF; b = 16'h0004; opcode = 4'b0110; #10; display_result(); // SLL
        opcode = 4'b0111; #10; display_result(); // SRL
        a = 16'hF0F0; b = 16'h0004; opcode = 4'b1000; #10; display_result(); // SRA

        // Comparisons
        a = 16'h8000; b = 16'h7FFF; opcode = 4'b1001; #10; display_result(); // SLT signed
        a = 16'h0001; b = 16'hFFFF; opcode = 4'b1010; #10; display_result(); // SLT unsigned

        // MOV
        a = 16'h1234; b = 16'h5678; opcode = 4'b1011; #10; display_result(); // MOVA
        opcode = 4'b1100; #10; display_result(); // MOVB

        // End simulation
        #20;
        $finish;
    end

endmodule

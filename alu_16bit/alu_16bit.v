`timescale 1ns / 1ps

// -------------------------------------------------
// 16-bit ALU for Physical Design Project
// Supported Ops:
//   0000 : ADD
//   0001 : SUB
//   0010 : AND
//   0011 : OR
//   0100 : XOR
//   0101 : NOR
//   0110 : Shift Left Logical (SLL)
//   0111 : Shift Right Logical (SRL)
//   1000 : Shift Right Arithmetic (SRA)
//   1001 : Set Less Than (Signed)
//   1010 : Set Less Than (Unsigned)
//   1011 : Move A
//   1100 : Move B
// -------------------------------------------------

module alu16 (
    input      [15:0] a, b,        // Operands
    input      [3:0]  opcode,      // Operation selector
    output reg [15:0] y,           // Result
    output reg        zero,        // Zero flag
    output reg        carry,       // Carry flag (for add/sub)
    output reg        overflow,    // Overflow flag (for add/sub)
    output reg        negative     // Negative flag (MSB of result)
);

    // Internal signals for arithmetic
    wire [16:0] add_ext;  // 17 bits for carry
    wire [16:0] sub_ext;

    assign add_ext = {1'b0, a} + {1'b0, b};
    assign sub_ext = {1'b0, a} - {1'b0, b};

    always @(*) begin
        // Default outputs
        y        = 16'h0000;
        carry    = 1'b0;
        overflow = 1'b0;

        case (opcode)
            // ADD
            4'b0000: begin
                y        = add_ext[15:0];
                carry    = add_ext[16];
                overflow = (a[15] == b[15]) && (y[15] != a[15]);
            end

            // SUB
            4'b0001: begin
                y        = sub_ext[15:0];
                carry    = ~sub_ext[16]; // Borrow = NOT carry
                overflow = (a[15] != b[15]) && (y[15] != a[15]);
            end

            // AND
            4'b0010: y = a & b;

            // OR
            4'b0011: y = a | b;

            // XOR
            4'b0100: y = a ^ b;

            // NOR
            4'b0101: y = ~(a | b);

            // Shift Left Logical
            4'b0110: y = a << b[3:0];

            // Shift Right Logical
            4'b0111: y = a >> b[3:0];

            // Shift Right Arithmetic
            4'b1000: y = $signed(a) >>> b[3:0];

            // Set Less Than (Signed)
            4'b1001: y = ($signed(a) < $signed(b)) ? 16'd1 : 16'd0;

            // Set Less Than (Unsigned)
            4'b1010: y = (a < b) ? 16'd1 : 16'd0;

            // Move A
            4'b1011: y = a;

            // Move B
            4'b1100: y = b;

            // Default
            default: y = 16'h0000;
        endcase

        // Flags update
        negative = y[15];
        zero     = (y == 16'h0000);
    end

endmodule

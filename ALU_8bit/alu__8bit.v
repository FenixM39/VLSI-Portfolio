// 8-bit ALU with rich opcode set and flags
// Ops:
// 0000 ADD      : Y = A + B
// 0001 SUB      : Y = A - B
// 0010 AND      : Y = A & B
// 0011 OR       : Y = A | B
// 0100 XOR      : Y = A ^ B
// 0101 NOT      : Y = ~A
// 0110 SLL1     : Y = A << 1 (logical)
// 0111 SRL1     : Y = A >> 1 (logical)
// 1000 ROL1     : Y = {A[6:0], A[7]}
// 1001 ROR1     : Y = {A[0], A[7:1]}
// 1010 INC      : Y = A + 1
// 1011 DEC      : Y = A - 1
// 1100 NAND     : Y = ~(A & B)
// 1101 NOR      : Y = ~(A | B)
// 1110 XNOR     : Y = ~(A ^ B)
// 1111 CMP      : Y = 0, flags from (A - B)

module alu_8bit (
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] SEL,
    output reg [7:0] Y,
    output reg       CARRY,     // Carry-out for ADD / bit shifted out for shifts
    output reg       BORROW,    // Borrow for SUB/CMP
    output reg       OVERFLOW,  // Signed overflow
    output           ZERO,      // Y == 0
    output           NEGATIVE   // Y[7]
);

    // Convenience localparams for readability
    localparam OP_ADD  = 4'b0000;
    localparam OP_SUB  = 4'b0001;
    localparam OP_AND  = 4'b0010;
    localparam OP_OR   = 4'b0011;
    localparam OP_XOR  = 4'b0100;
    localparam OP_NOT  = 4'b0101;
    localparam OP_SLL1 = 4'b0110;
    localparam OP_SRL1 = 4'b0111;
    localparam OP_ROL1 = 4'b1000;
    localparam OP_ROR1 = 4'b1001;
    localparam OP_INC  = 4'b1010;
    localparam OP_DEC  = 4'b1011;
    localparam OP_NAND = 4'b1100;
    localparam OP_NOR  = 4'b1101;
    localparam OP_XNOR = 4'b1110;
    localparam OP_CMP  = 4'b1111;

    // Extended add/sub wires for flag computation
    reg [8:0] addx;  // {carry, sum}
    reg [8:0] subx;  // {carry_from_2's_add, diff}

    // Combinational ALU
    always @(*) begin
        // sensible defaults (avoid inferred latches)
        Y        = 8'h00;
        CARRY    = 1'b0;
        BORROW   = 1'b0;
        OVERFLOW = 1'b0;
        addx     = 9'h000;
        subx     = 9'h000;

        case (SEL)
            OP_ADD: begin
                addx     = {1'b0, A} + {1'b0, B};
                Y        = addx[7:0];
                CARRY    = addx[8];
                OVERFLOW = (~(A[7] ^ B[7])) & (Y[7] ^ A[7]);
            end

            OP_SUB: begin
                // A - B = A + (~B + 1)
                subx     = {1'b0, A} + {1'b0, ~B} + 9'd1;
                Y        = subx[7:0];
                BORROW   = ~subx[8];            // borrow = NOT carry in 2's add
                OVERFLOW = (A[7] ^ B[7]) & (Y[7] ^ A[7]);
            end

            OP_AND:  Y = A & B;
            OP_OR :  Y = A | B;
            OP_XOR:  Y = A ^ B;
            OP_NOT:  Y = ~A;

            OP_SLL1: begin
                Y     = A << 1;
                CARRY = A[7];                  // bit shifted out
            end

            OP_SRL1: begin
                Y     = A >> 1;
                CARRY = A[0];                  // bit shifted out
            end

            OP_ROL1: begin
                Y     = {A[6:0], A[7]};
                CARRY = A[7];
            end

            OP_ROR1: begin
                Y     = {A[0], A[7:1]};
                CARRY = A[0];
            end

            OP_INC: begin
                addx  = {1'b0, A} + 9'd1;
                Y     = addx[7:0];
                CARRY = addx[8];
                OVERFLOW = (~A[7]) & Y[7];     // +1 overflow from 0111_1111 -> 1000_0000
            end

            OP_DEC: begin
                subx  = {1'b0, A} + 9'h1FF;    // +(-1) == +0x1FF in 9 bits
                Y     = subx[7:0];
                BORROW= ~subx[8];
                OVERFLOW = A[7] & ~Y[7];       // -1 overflow from 1000_0000 -> 0111_1111
            end

            OP_NAND: Y = ~(A & B);
            OP_NOR : Y = ~(A | B);
            OP_XNOR: Y = ~(A ^ B);

            OP_CMP: begin
                subx     = {1'b0, A} + {1'b0, ~B} + 9'd1; // A - B
                Y        = 8'h00;               // common for CMP
                BORROW   = ~subx[8];
                OVERFLOW = (A[7] ^ B[7]) & (subx[7] ^ A[7]);
            end

            default: Y = 8'h00;
        endcase
    end

    assign ZERO     = (Y == 8'h00);
    assign NEGATIVE = Y[7];

endmodule

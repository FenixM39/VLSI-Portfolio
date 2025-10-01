// 16-bit ALU
module alu_16bit (
    input  [15:0] A, B,       // operands
    input  [3:0]  opcode,     // control signal
    output reg [15:0] result, // ALU output
    output reg carry, zero, overflow, negative // flags
);

always @(*) begin
    // default values
    result = 16'b0;
    carry = 0;
    zero = 0;
    overflow = 0;
    negative = 0;

    case (opcode)
        4'b0000: {carry, result} = A + B;           // ADD
        4'b0001: {carry, result} = A - B;           // SUB
        4'b0010: result = A & B;                    // AND
        4'b0011: result = A | B;                    // OR
        4'b0100: result = A ^ B;                    // XOR
        4'b0101: result = ~A;                       // NOT
        4'b0110: result = A << 1;                   // SHL
        4'b0111: result = A >> 1;                   // SHR
        4'b1000: {carry, result} = A + 1;           // INC
        4'b1001: {carry, result} = A - 1;           // DEC
        4'b1010: result = A - B;                    // CMP
        4'b1011: result = {A[14:0], A[15]};         // ROL
        4'b1100: result = {A[0], A[15:1]};          // ROR
        4'b1101: result = A;                        // PASS A
        4'b1110: result = B;                        // PASS B
        4'b1111: result = 16'b0;                    // ZERO
        default: result = 16'b0;
    endcase

    // flags
    zero = (result == 16'b0);
    negative = result[15];
    // overflow flag (simple for add/sub)
    if (opcode == 4'b0000) // ADD
        overflow = (A[15] == B[15]) && (result[15] != A[15]);
    else if (opcode == 4'b0001) // SUB
        overflow = (A[15] != B[15]) && (result[15] != A[15]);
end

endmodule

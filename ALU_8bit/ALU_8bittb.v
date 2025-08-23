// ---------------- TESTBENCH ----------------
module ALU_8bit_tb;
reg [7:0] A, B;
reg [3:0] ALU_Sel;
wire [7:0] ALU_Out;
wire CARRY, BORROW, OVERFLOW, ZERO, NEGATIVE;


ALU_8bit uut (
.A(A), .B(B), .ALU_Sel(ALU_Sel),
.ALU_Out(ALU_Out), .CARRY(CARRY), .BORROW(BORROW),
.OVERFLOW(OVERFLOW), .ZERO(ZERO), .NEGATIVE(NEGATIVE)
);


initial begin
$dumpfile("alu_8bit.vcd");
$dumpvars(0, ALU_8bit_tb);


A = 8'h0A; B = 8'h03; // Example values


// Sweep through all operations
for (ALU_Sel = 0; ALU_Sel < 16; ALU_Sel = ALU_Sel + 1) begin
#10;
$display("time=%0t | Sel=%b | A=%h | B=%h | Out=%h | C=%b B=%b O=%b Z=%b N=%b",
$time, ALU_Sel, A, B, ALU_Out, CARRY, BORROW, OVERFLOW, ZERO, NEGATIVE);
end


$finish;
end
endmodule
module test_alu_4bit;
  reg [3:0] a, b;
  reg [2:0] op;
  wire [3:0] result;
  wire carry;

  alu_4bit uut (.a(a), .b(b), .op(op), .result(result), .carry(carry));

  initial begin
    $display("A    B    OP  | RESULT CARRY");
    a = 4'b0011; b = 4'b0001;

    op = 3'b000; #10;
    $display("%b %b  %b  |   %b    %b", a, b, op, result, carry);

    op = 3'b001; #10;
    $display("%b %b  %b  |   %b    %b", a, b, op, result, carry);

    op = 3'b010; #10;
    op = 3'b011; #10;
    op = 3'b100; #10;
    $finish;
  end
endmodule

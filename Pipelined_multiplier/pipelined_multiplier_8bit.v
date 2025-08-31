module pipelined_multiplier_8bit (
    input  wire clk,
    input  wire rst,
    input  wire [7:0] A,
    input  wire [7:0] B,
    output reg  [15:0] P
);

    // Stage 1 registers (input latch)
    reg [7:0] A_reg1, B_reg1;

    // Stage 2 registers (partial products)
    reg [15:0] pp_low, pp_high;

    // Stage 3 registers (sum of partials)
    reg [15:0] sum_reg;

    // Stage 4 (final output product)
    reg [15:0] P_reg;

    // Pipeline stages
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg1   <= 8'd0;
            B_reg1   <= 8'd0;
            pp_low   <= 16'd0;
            pp_high  <= 16'd0;
            sum_reg  <= 16'd0;
            P_reg    <= 16'd0;
            P        <= 16'd0;
        end else begin
            // Stage 1: Register inputs
            A_reg1 <= A;
            B_reg1 <= B;

            // Stage 2: Compute partial products
            pp_low  <= A_reg1[3:0] * B_reg1;       // lower 4 bits
            pp_high <= A_reg1[7:4] * B_reg1;       // upper 4 bits

            // Stage 3: Combine partials (shift high part by 4 bits)
            sum_reg <= pp_low + (pp_high << 4);

            // Stage 4: Register final result
            P_reg <= sum_reg;
            P     <= P_reg;
        end
    end

endmodule

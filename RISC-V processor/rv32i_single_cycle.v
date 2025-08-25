// ----------------------------------------------------------------------------
// RV32I Single-Cycle Processor (Educational)
// - Implements a usable subset of RV32I in a single clock cycle per instr.
// - Suitable for simulation and FPGA labs (small memories, simple I/O).
// - NOT timing-accurate to real SRAM/BRAM; data memory read is combinational.
// ----------------------------------------------------------------------------
// Supported instructions (RV32I):
//  R-type : ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA
//  I-type : ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI, LW, JALR
//  S-type : SW
//  B-type : BEQ, BNE, BLT, BGE, BLTU, BGEU
//  U-type : LUI, AUIPC
//  J-type : JAL
//
// Files can be preloaded via $readmemh for instruction/data memories.
// ----------------------------------------------------------------------------

`timescale 1ns/1ps

module rv32i_single_cycle (
    input  wire        clk,
    input  wire        reset_n,     // active-low reset
    // Optional simple GPIO for demo
    output wire [31:0] dbg_pc,
    output wire [31:0] dbg_instr,
    output wire [31:0] dbg_reg_x10  // a0 register for convenience
);
    // -------------------- Fetch --------------------
    wire [31:0] pc, pc_next, pc_plus4;
    pc_reg u_pc(.clk(clk), .reset_n(reset_n), .pc_next(pc_next), .pc(pc));
    assign pc_plus4 = pc + 32'd4;

    // Instruction memory
    wire [31:0] instr;
    instr_mem #(.DEPTH_WORDS(1024), .MEMFILE("prog.hex")) u_imem(
        .addr(pc[31:2]),
        .rdata(instr)
    );

    // -------------------- Decode --------------------
    wire [6:0]  opcode = instr[6:0];
    wire [2:0]  funct3 = instr[14:12];
    wire [6:0]  funct7 = instr[31:25];
    wire [4:0]  rs1    = instr[19:15];
    wire [4:0]  rs2    = instr[24:20];
    wire [4:0]  rd     = instr[11:7];

    // Control
    wire RegWrite, MemRead, MemWrite, MemToReg, ALUSrc;
    wire Branch, BranchUnsigned, JAL, JALR, LUI, AUIPC;
    wire [1:0] ALUOp;

    control u_ctrl(
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), .MemToReg(MemToReg), .ALUSrc(ALUSrc),
        .Branch(Branch), .BranchUnsigned(BranchUnsigned), .JAL(JAL), .JALR(JALR), .LUI(LUI), .AUIPC(AUIPC),
        .ALUOp(ALUOp)
    );

    // Register file
    wire [31:0] rs1_data, rs2_data;
    regfile u_regs(
        .clk(clk), .we(RegWrite), .rs1(rs1), .rs2(rs2), .rd(rd),
        .wd(writeback_data), .rs1_d(rs1_data), .rs2_d(rs2_data)
    );

    // Immediate generator
    wire [31:0] imm;
    immgen u_imm(.instr(instr), .imm(imm));

    // -------------------- Execute --------------------
    wire [3:0] alu_sel;
    alu_control u_aluctrl(
        .ALUOp(ALUOp), .funct3(funct3), .funct7_5(instr[30]),
        .alu_sel(alu_sel)
    );

    wire [31:0] alu_in_b = (ALUSrc ? imm : rs2_data);
    wire [31:0] alu_y;
    wire        alu_carry;

    alu32 u_alu(
        .a(rs1_data), .b(alu_in_b), .sel(alu_sel),
        .y(alu_y), .carry_out(alu_carry)
    );

    // Branch compare (signed/unsigned based on funct3 and BranchUnsigned)
    wire take_branch;
    branch_compare u_bcmp(
        .rs1(rs1_data), .rs2(rs2_data), .funct3(funct3), .unsigned_cmp(BranchUnsigned),
        .take(take_branch)
    );

    // Next PC logic
    wire [31:0] pc_branch = pc + imm; // B-type immediate already shifted <<1 in immgen
    wire [31:0] pc_jal    = pc + imm; // J-type
    wire [31:0] pc_jalr   = (rs1_data + imm) & 32'hFFFF_FFFE;

    assign pc_next = JAL  ? pc_jal  :
                     JALR ? pc_jalr :
                     (Branch && take_branch) ? pc_branch :
                     pc_plus4;

    // -------------------- Memory --------------------
    wire [31:0] dmem_rdata;
    data_mem #(.DEPTH_WORDS(1024), .MEMFILE("data.hex")) u_dmem(
        .clk(clk), .addr(alu_y[31:2]), .we(MemWrite), .re(MemRead),
        .wdata(rs2_data), .rdata(dmem_rdata)
    );

    // -------------------- Writeback --------------------
    wire [31:0] lui_val   = {imm[31:12], 12'b0};
    wire [31:0] auipc_val = pc + {imm[31:12], 12'b0};
    wire [31:0] wb_core   = MemToReg ? dmem_rdata : alu_y;
    wire [31:0] wb_jal    = pc_plus4;

    wire [31:0] writeback_data = LUI    ? lui_val   :
                                 AUIPC  ? auipc_val :
                                 (JAL | JALR) ? wb_jal :
                                 wb_core;

    // Debug
    assign dbg_pc    = pc;
    assign dbg_instr = instr;
    assign dbg_reg_x10 = u_regs.regs[10]; // a0
endmodule

// ----------------------------------------------------------------------------
// PC Register
// ----------------------------------------------------------------------------
module pc_reg(
    input  wire        clk,
    input  wire        reset_n,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) pc <= 32'h0000_0000;
        else          pc <= pc_next;
    end
endmodule

// ----------------------------------------------------------------------------
// Simple Instruction Memory (ROM-like via $readmemh)
// addr is word index (PC[31:2])
// ----------------------------------------------------------------------------
module instr_mem #(parameter DEPTH_WORDS=1024, parameter MEMFILE="prog.hex") (
    input  wire [$clog2(DEPTH_WORDS)-1:0] addr,
    output wire [31:0] rdata
);
    reg [31:0] mem [0:DEPTH_WORDS-1];
    initial begin
        if (MEMFILE != "") $readmemh(MEMFILE, mem);
    end
    assign rdata = mem[addr];
endmodule

// ----------------------------------------------------------------------------
// Simple Data Memory (combinational read, sync write)
// addr is word index (byte-addressed addr[31:2])
// ----------------------------------------------------------------------------
module data_mem #(parameter DEPTH_WORDS=1024, parameter MEMFILE="") (
    input  wire        clk,
    input  wire [$clog2(DEPTH_WORDS)-1:0] addr,
    input  wire        we,
    input  wire        re,
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);
    reg [31:0] mem [0:DEPTH_WORDS-1];
    initial begin
        if (MEMFILE != "") $readmemh(MEMFILE, mem);
    end

    // Combinational read (word-aligned)
    assign rdata = re ? mem[addr] : 32'h0000_0000;

    // Synchronous write (full word write enable only)
    always @(posedge clk) begin
        if (we) mem[addr] <= wdata;
    end
endmodule

// ----------------------------------------------------------------------------
// Register File (32 x 32-bit). x0 hardwired to 0.
// ----------------------------------------------------------------------------
module regfile(
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] wd,
    output wire [31:0] rs1_d,
    output wire [31:0] rs2_d
);
    reg [31:0] regs [0:31];

    // async read
    assign rs1_d = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
    assign rs2_d = (rs2 == 5'd0) ? 32'b0 : regs[rs2];

    // sync write (ignore writes to x0)
    always @(posedge clk) begin
        if (we && (rd != 5'd0)) regs[rd] <= wd;
    end
endmodule

// ----------------------------------------------------------------------------
// Immediate Generator (RV32I)
//  - I  : imm[31:20] sign-extended
//  - S  : imm[31:25|11:7]
//  - B  : imm[31|7|30:25|11:8] << 1
//  - U  : imm[31:12] << 12
//  - J  : imm[31|19:12|20|30:21] << 1
// ----------------------------------------------------------------------------
module immgen(
    input  wire [31:0] instr,
    output reg  [31:0] imm
);
    wire [6:0] opc = instr[6:0];
    always @(*) begin
        case (opc)
            7'b0010011, // I-type ALU
            7'b0000011, // LOAD
            7'b1100111: // JALR
                imm = {{20{instr[31]}}, instr[31:20]};

            7'b0100011: // S-type (STORE)
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            7'b1100011: // B-type (BRANCH), note <<1 later via concat
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

            7'b0110111, // LUI (U-type)
            7'b0010111: // AUIPC (U-type)
                imm = {instr[31:12], 12'b0};

            7'b1101111: // JAL (J-type)
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

            default: imm = 32'b0;
        endcase
    end
endmodule

// ----------------------------------------------------------------------------
// Control Unit (simplified)
// Produces high-level controls + ALUOp (00=ADD-like, 01=BR, 10=R-type, 11=I-ALU)
// ----------------------------------------------------------------------------
module control(
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  RegWrite,
    output reg  MemRead,
    output reg  MemWrite,
    output reg  MemToReg,
    output reg  ALUSrc,
    output reg  Branch,
    output reg  BranchUnsigned,
    output reg  JAL,
    output reg  JALR,
    output reg  LUI,
    output reg  AUIPC,
    output reg  [1:0] ALUOp
);
    always @(*) begin
        // defaults
        RegWrite = 0; MemRead = 0; MemWrite = 0; MemToReg = 0; ALUSrc = 0;
        Branch = 0; BranchUnsigned = 0; JAL = 0; JALR = 0; LUI = 0; AUIPC = 0; ALUOp = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type
                RegWrite = 1; ALUSrc = 0; ALUOp = 2'b10;
            end
            7'b0010011: begin // I-type (ALU imm)
                RegWrite = 1; ALUSrc = 1; ALUOp = 2'b11;
            end
            7'b0000011: begin // LOAD (LW)
                RegWrite = 1; MemRead = 1; MemToReg = 1; ALUSrc = 1; ALUOp = 2'b00; // ADD base+imm
            end
            7'b0100011: begin // STORE (SW)
                MemWrite = 1; ALUSrc = 1; ALUOp = 2'b00; // ADD base+imm
            end
            7'b1100011: begin // BRANCH
                Branch = 1; ALUSrc = 0; ALUOp = 2'b01; // compare
                // unsigned branches for BLTU/BGEU (funct3 110/111)
                BranchUnsigned = (funct3[2:1] == 2'b11);
            end
            7'b1101111: begin // JAL
                RegWrite = 1; JAL = 1;
            end
            7'b1100111: begin // JALR (I-type)
                RegWrite = 1; JALR = 1; ALUSrc = 1; // base + imm
            end
            7'b0110111: begin // LUI
                RegWrite = 1; LUI = 1;
            end
            7'b0010111: begin // AUIPC
                RegWrite = 1; AUIPC = 1;
            end
            default: ;
        endcase
    end
endmodule

// ----------------------------------------------------------------------------
// ALU Control: maps ALUOp + funct to specific ALU operation
// sel encoding:
// 0000 ADD/ADDI/AUIPC/LW/SW/JALR base calc
// 0001 SUB
// 0010 AND
// 0011 OR
// 0100 XOR
// 0101 SLL/SLLI
// 0110 SRL/SRLI
// 0111 SRA/SRAI
// 1000 SLT/SLTI
// 1001 SLTU/SLTIU
// ----------------------------------------------------------------------------
module alu_control(
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire       funct7_5, // instr[30]
    output reg  [3:0] alu_sel
);
    always @(*) begin
        case (ALUOp)
            2'b00: alu_sel = 4'b0000; // default ADD (loads/stores)
            2'b01: begin // branch compares use SUB/SLT flavors via compare unit; keep SUB here
                alu_sel = 4'b0001; // SUB (not strictly used by branch unit)
            end
            2'b10: begin // R-type
                case (funct3)
                    3'b000: alu_sel = (funct7_5 ? 4'b0001 : 4'b0000); // SUB : ADD
                    3'b111: alu_sel = 4'b0010; // AND
                    3'b110: alu_sel = 4'b0011; // OR
                    3'b100: alu_sel = 4'b0100; // XOR
                    3'b001: alu_sel = 4'b0101; // SLL
                    3'b101: alu_sel = (funct7_5 ? 4'b0111 : 4'b0110); // SRA : SRL
                    3'b010: alu_sel = 4'b1000; // SLT
                    3'b011: alu_sel = 4'b1001; // SLTU
                    default: alu_sel = 4'b0000;
                endcase
            end
            2'b11: begin // I-type ALU immediates
                case (funct3)
                    3'b000: alu_sel = 4'b0000; // ADDI
                    3'b111: alu_sel = 4'b0010; // ANDI
                    3'b110: alu_sel = 4'b0011; // ORI
                    3'b100: alu_sel = 4'b0100; // XORI
                    3'b001: alu_sel = 4'b0101; // SLLI  (alias to 0101)
                    3'b101: alu_sel = (funct7_5 ? 4'b0111 : 4'b0110); // SRAI : SRLI
                    3'b010: alu_sel = 4'b1000; // SLTI
                    3'b011: alu_sel = 4'b1001; // SLTIU (alias to 1001)
                    default: alu_sel = 4'b0000;
                endcase
            end
            default: alu_sel = 4'b0000;
        endcase
    end
endmodule

// ----------------------------------------------------------------------------
// 32-bit ALU
// ----------------------------------------------------------------------------
module alu32(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  sel,
    output reg  [31:0] y,
    output wire        carry_out
);
    wire [32:0] add_w = {1'b0, a} + {1'b0, b};
    wire [32:0] sub_w = {1'b0, a} + {1'b0, ~b} + 33'd1;

    assign carry_out = (sel==4'b0000) ? add_w[32] :
                       (sel==4'b0001) ? ~sub_w[32] : 1'b0;

    always @(*) begin
        case (sel)
            4'b0000: y = add_w[31:0];               // ADD
            4'b0001: y = sub_w[31:0];               // SUB
            4'b0010: y = a & b;                     // AND
            4'b0011: y = a | b;                     // OR
            4'b0100: y = a ^ b;                     // XOR
            4'b0101: y = a << b[4:0];               // SLL/SLLI
            4'b0110: y = a >> b[4:0];               // SRL/SRLI
            4'b0111: y = $signed(a) >>> b[4:0];     // SRA/SRAI
            4'b1000: y = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT/SLTI
            4'b1001: y = (a < b) ? 32'd1 : 32'd0;   // SLTU/SLTIU
            default: y = 32'h0000_0000;
        endcase
    end
endmodule

// ----------------------------------------------------------------------------
// Branch comparator (funct3 selects condition)
// funct3: 000=BEQ, 001=BNE, 100=BLT, 101=BGE, 110=BLTU, 111=BGEU
// ----------------------------------------------------------------------------
module branch_compare(
    input  wire [31:0] rs1,
    input  wire [31:0] rs2,
    input  wire [2:0]  funct3,
    input  wire        unsigned_cmp,
    output reg         take
);
    wire eq  = (rs1 == rs2);
    wire lt  = unsigned_cmp ? (rs1 < rs2) : ($signed(rs1) < $signed(rs2));
    wire ge  = ~lt;

    always @(*) begin
        case (funct3)
            3'b000: take =  eq;  // BEQ
            3'b001: take = ~eq;  // BNE
            3'b100: take =  lt;  // BLT
            3'b101: take =  ge;  // BGE
            3'b110: take =  lt;  // BLTU
            3'b111: take =  ge;  // BGEU
            default: take = 1'b0;
        endcase
    end
endmodule

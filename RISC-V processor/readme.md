# RISC-V Single Cycle Processor (RV32I Subset)

This project implements a **single-cycle RISC-V RV32I processor** in Verilog.  
It is capable of executing a subset of RV32I instructions, including arithmetic, logic, load/store, and control-flow operations.

---

## Features

- **ISA Support (RV32I subset)**:
  - Arithmetic & Logic: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLT`, `SLTU`, `SLL`, `SRL`, `SRA`
  - Immediate Instructions: `ADDI`, `ORI`, `ANDI`, `XORI`, `SLTI`, etc.
  - Memory: `LW`, `SW`
  - Branches: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
  - Jump & Upper: `JAL`, `JALR`, `LUI`, `AUIPC`

- **Single Cycle Execution**: Every instruction completes in one clock cycle.
- **Memory Initialization**: Instruction and data memory can be preloaded from `.hex` files using `$readmemh`.
- **Modular Design**:
  - Program Counter (PC)
  - Instruction Memory
  - Register File
  - Immediate Generator
  - ALU
  - Control Unit
  - Branch Comparator
  - Data Memory
- **Debug Ports**: Exposes current PC, instruction, and register `x10 (a0)` for easy simulation monitoring.

---



## Simulation

### Requirements
- [Icarus Verilog](http://iverilog.icarus.com/)
- [GTKWave](http://gtkwave.sourceforge.net/) (for waveform viewing)

### Run
```bash
# Compile
iverilog -o cpu.out sim/tb_rv32i.v src/*.v

# Run
vvp cpu.out

# View waveform
gtkwave dump.vcd
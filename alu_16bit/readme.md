# 16-bit ALU (ASIC-Ready) 🔧

This project implements a **16-bit Arithmetic Logic Unit (ALU)** in synthesizable **Verilog**, verified with a **testbench**, and prepared for **RTL-to-GDSII flow** using open-source EDA tools (OpenLane, yosys, OpenROAD, Magic, KLayout, OpenSTA) on the **SkyWater SKY130 PDK**.

---

## ✨ Features
- 16-bit datapath
- Supported operations:
  - **Arithmetic**: ADD, SUB
  - **Logic**: AND, OR, XOR, NOR
  - **Shifts**: SLL, SRL, SRA
  - **Comparison**: SLT (signed/unsigned)
  - **Pass-through**: MOV A, MOV B
- Status flags: **Zero, Carry, Overflow, Negative**
- Fully **combinational** (no clock needed, but can be pipelined later)

---


---

## ▶️ Simulation
1. Install [Icarus Verilog](http://iverilog.icarus.com/) or [Verilator](https://www.veripool.org/wiki/verilator).
2. Run:
   ```bash
   iverilog -o alu16_tb rtl/alu16.v sim/tb_alu16.v
   vvp alu16_tb
   gtkwave alu16_tb.vcd

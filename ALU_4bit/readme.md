# 🔢 8-bit ALU (Arithmetic Logic Unit) in Verilog

This project implements an **8-bit ALU (Arithmetic Logic Unit)** using Verilog HDL.  
The ALU is capable of performing **arithmetic, logical, shift, and comparison operations** based on a control signal.

---

## ✨ Features
- Supports **8-bit inputs (A, B)** and produces an **8-bit result (Result)**.
- Provides **Carry Out** and **Zero Flag** for status checks.
- Operations include:
  - Addition
  - Subtraction
  - Bitwise AND, OR, XOR
  - Logical Shift Left, Logical Shift Right
  - Greater/Less than comparison
  - Equality check

---

## 📁 Project Structure


---

## ⚙️ ALU Control Signals
The operation is selected using a **3-bit control input (`ALU_Sel`)**:

| ALU_Sel | Operation        | Description                  |
|---------|-----------------|------------------------------|
| 000     | Addition        | Result = A + B               |
| 001     | Subtraction     | Result = A - B               |
| 010     | AND             | Result = A & B               |
| 011     | OR              | Result = A \| B              |
| 100     | XOR             | Result = A ^ B               |
| 101     | Shift Left      | Result = A << 1              |
| 110     | Shift Right     | Result = A >> 1              |
| 111     | Compare Equal   | Result = (A == B) ? 1 : 0    |

---

## 🧪 Testbench
The testbench (`alu_tb.v`) simulates all ALU operations by applying different inputs and control signals.  
It also generates a **VCD file** for waveform visualization in tools like **GTKWave**.

Example snippet:
```verilog
initial begin
  A = 8'b00001111; 
  B = 8'b00000101; 
  ALU_Sel = 3'b000; // Addition
  #10 ALU_Sel = 3'b001; // Subtraction
  #10 ALU_Sel = 3'b010; // AND
  ...
end

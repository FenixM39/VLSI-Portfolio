# 8-bit Pipelined Multiplier (Verilog)  

This project implements an **8-bit pipelined multiplier** in **Verilog**, targeting FPGA/ASIC RTL design practice. The design uses a **4-stage pipeline** to improve throughput compared to a purely combinational multiplier.  

---

## 🔹 Features  
- **4-stage pipeline**: Input latch → Partial product generation → Addition → Final result.  
- Achieves **high throughput** (1 result per cycle after pipeline fill).  
- Fully **synthesizable** and compatible with FPGA/ASIC flows.  
- Includes a **Verilog testbench** with sample test vectors.  

---

## 🔧 Tools Used  
- **Xilinx Vivado** – RTL simulation and synthesis  
- **ModelSim/iverilog** (optional) – testbench verification  

---


---

## 📊 Results  
- Correctly computes multiplication of 8-bit operands.  
- Demonstrates **pipeline latency = 4 cycles**, but **throughput = 1 result/cycle**.  
- Sample test vectors:  
  - 15 × 10 = 150  
  - 25 × 12 = 300  
  - 50 × 20 = 1000  
  - 100 × 5 = 500  
  - 200 × 3 = 600  

*(Simulation waveforms can be added as images here)*  

---

## 📝 How to Run  
1. Open `pipelined_multiplier_8bit.v` and `tb_pipelined_multiplier_8bit.v` in your simulator (Vivado, ModelSim, or iverilog).  
2. Compile and run the testbench.  
3. Observe product `P` with latency of 4 cycles.  

---

## 📌 References  
- Harris & Harris, *Digital Design and Computer Architecture*  
- NPTEL – Digital IC Design (IIT Madras)  


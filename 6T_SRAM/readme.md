# 6T SRAM Cell Design & Simulation  

This project demonstrates the design and simulation of a **6T SRAM (Static Random Access Memory) cell** using **LTspice** with built-in NMOS/PMOS models. The focus is on verifying functional behavior (read/write operations) and evaluating **static noise margin (SNM)** under different transistor sizing ratios.  

---

## 🔹 Features  
- Implemented a standard **6-transistor SRAM cell** (cross-coupled inverters + access transistors).  
- Verified **write and read operations** using precharged bitlines and wordline control.  
- Measured **Static Noise Margin (SNM)** using butterfly curves.  
- Analyzed effect of **transistor sizing ratios** (pull-up, pull-down, access) on cell stability.  

---

## 🔧 Tools Used  
- **LTspice XVII** (built-in NMOS/PMOS models)  
- **Python/Excel** (optional) for SNM curve analysis and sizing plots  

---

## 📂 Repository Structure  
-netlist/ # LTspice netlist files for 6T SRAM
    -sram_6t_write.cir # Write operation testbench
    -sram_6t_read.cir # Read operation testbench
    -sram_6t_snm.cir # SNM butterfly curve setup
-results/ # Plots and outputs
    -write_waveform.png
    -read_waveform.png
    -butterfly_snm.png
-README.md # Project documentation


---

## 📊 Results  
- **Write Operation:** Successfully stores data when WL is high and bitlines driven.  
- **Read Operation:** Precharged bitlines show correct discharge without state flipping.  
- **SNM Analysis:** Extracted butterfly curves; stability improves with higher pull-down sizing.  

*(Example plots can be added here as images)*  

---

## 📝 How to Run  
1. Open `.cir` or `.asc` file in LTspice.  
2. For **write test**, uncomment BL/BLB sources; for **read test**, keep precharge resistors active.  
3. Run transient simulation (`.tran`) to verify waveforms.  
4. For SNM, run `.dc` sweep and plot inverter transfer characteristics to generate butterfly curve.  

---

## 📌 References  
- R. Jacob Baker, *CMOS Circuit Design, Layout, and Simulation*  
- David Harris & Sarah Harris, *Digital Design and Computer Architecture*  

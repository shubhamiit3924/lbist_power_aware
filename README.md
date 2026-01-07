# Power-Aware Logic Built-In Self Test (LBIST)

This project implements a **power-controlled Logic Built-In Self Test (LBIST)** architecture that reduces excessive switching activity during scan-based testing without sacrificing fault coverage or increasing test time. The design is verified on a **MIPS32-based processor core** and demonstrates significant energy savings through precise toggle-rate control.

---

## 📌 Project Overview

During conventional LBIST, scan shift operations can consume **2–3× higher power** than functional mode due to excessive flip-flop toggling. This project addresses that issue by introducing a **toggle-aware pattern generation mechanism** that allows **exact control over the number of bit transitions per scan pattern**.

Key objectives:
- Control scan-shift power to arbitrary levels  
- Maintain high fault coverage  
- Avoid test-time penalties  
- Ensure scalability to large scan chains  

---

## 🧠 Key Concepts Used

- Low-power DFT and scan-based testing  
- Toggle-rate–controlled pattern generation  
- Activity factor–based power modeling  
- Signature compaction using MISR  
- FSM-based test controller  

---

## 🏗️ Architecture Overview

The LBIST system consists of the following major blocks:

1. **LFSR (Linear Feedback Shift Register)**  
   - Generates pseudo-random test patterns  
   - 32-bit maximum-length polynomial  
   - Programmable seed and enable control  

2. **Toggle Controller**  
   - Precisely limits the number of bit toggles per scan shift  
   - Uses XOR-based toggle masking  
   - Supports toggle rates from 0 to 100%  

3. **MIPS32 Simple Processor (CUT)**  
   - Serves as the circuit under test  
   - Contains multiple scan flip-flops and control logic  

4. **MISR (Multiple Input Signature Register)**  
   - Compacts test responses into a signature  
   - Enables fault detection with low hardware overhead  

5. **Test Controller (FSM)**  
   - Manages scan enable, toggle scheduling, and test completion  
   - Dynamically adjusts toggle rates during the test session  

6. **Top-Level Integration**  
   - Integrates all modules into a complete LBIST system  

## 📊 Results & Performance

- Exact toggle-rate control achieved for all configurations  
- Dynamic toggle scheduling: `32 → 16 → 8 → 4` toggles  
- **Up to 53.1% total energy savings** over full test session  
- No increase in test time  
- Correct MISR signature generation verified via simulation  

---

## 🧪 Verification

- Functional verification performed using simulation waveforms  
- Toggle count verified at every scan shift  
- FSM behavior validated for correct test sequencing  
- Power reduction analytically verified using activity-factor models  

---

## 🛠️ Tools & Technologies

- **HDL**: VHDL  
- **Simulation**: Vivado Simulator  
- **Design Domain**: DFT, Low-Power VLSI  
- **Processor Model**: MIPS32 (simplified)  

---

## 📂 Repository Structure

├── src/
│   ├── lbist_top.vhd
│   ├── lfsr.vhd
│   ├── mips32_simple.vhd
│   ├── misr.vhd
│   ├── test_controller.vhd
│   └── toggle_controller.vhd
│
├── README.md
├── project_report.pdf
├── simulations/
└── waveforms/


## 📈 Key Takeaways

- Demonstrates practical **low-power DFT techniques**
- Shows strong understanding of **scan power challenges**
- Applicable to real-world industrial LBIST flows
- Scalable and modular design

---

## 👤 Author

**Shubham Meena**  
B.Tech, Microelectronics and VLSI Engineering  
Indian Institute of Technology Mandi  

---

## 📜 License

This project is intended for **academic and learning purposes**.  
Feel free to fork and modify with attribution.











# FPGA & 555 Timer Project Series

Welcome to the repository for the **The Boolean Academy** series exploring the intersection of analog electronics (SA555/NE555 Timer) and modern digital logic (FPGA). 

This repository contains all the Verilog code, Python scripts, schematics, and constraints used in the video series.

## 📺 The Projects

### [Project 01: The Hardware Frequency Counter](./01_Frequency_Counter)
We bridge the analog and digital worlds by wiring an astable 555 timer to an FPGA. The FPGA safely crosses the clock domains, measures the exact period of the analog signal using a 50MHz clock, and streams the raw data via a custom UART transmitter to a PC for real-time decoding in Python.
* **Concepts:** Clock Domain Crossing, Verilog Counters, UART Transmission, Python Serial.

### [Project 02: Coming Soon...]
*(Description of your next video)*

---

## 🛠️ Hardware Used in this Series
* **FPGA Board:** Edge A7 from Invent logic [AMD-Xilinx Artix7 FPGA] (50 MHz Clock)
* **Analog IC:** SA555 / NE555 Precision Timer
* **Serial Bridge:** 7semi USB-to-TTL UART Module
* **Misc:** Breadboards, jumper wires, assorted capacitors/resistors.

## ⚠️ Important Safety Note
In all of these projects, the 555 Timer is powered by a 5V source. **FPGA GPIO pins are typically 3.3V (LVCMOS33).** Do not connect the 555 output directly to your FPGA. Every project in this repository utilizes a 2kΩ / 3.3kΩ voltage divider to safely step the 5V signal down to 3.11V. 

See the individual project documentation for wiring diagrams.

## 📜 License
All code and schematics are open-source under the [MIT License](LICENSE).

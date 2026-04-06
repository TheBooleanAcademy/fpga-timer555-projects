# Project 01: Hardware Frequency Counter

This project demonstrates how to interface an analog 555 Timer circuit with an FPGA, measure its frequency entirely in hardware using a 50 MHz clock, and stream the raw data to a PC via UART.

![Hardware Setup](docs/hardware_setup.jpg) *(Replace with a photo of your actual setup!)*

## 📖 How It Works
Instead of doing heavy division math in Verilog (which consumes massive amounts of logic gates), the FPGA acts as a highly precise stopwatch. 
1. The 555 Timer square wave enters the FPGA and passes through a **2-Flip-Flop Synchronizer** to safely cross into the 50 MHz clock domain.
2. A hardware counter measures the exact number of 50 MHz clock ticks between the rising edges of the 555 signal.
3. A custom state machine translates that 32-bit count into an 8-character Hexadecimal string and transmits it over UART at 115200 baud.
4. A Python script on the PC reads the serial data, decodes the hex, and calculates the final frequency: `f = 50,000,000 / Clock_Cycles`.

## ⚠️ The Voltage Divider (Crucial!)
**DO NOT plug the 5V output of a 555 timer directly into a 3.3V FPGA pin!** You must use a voltage divider to step the 5V square wave down to a safe ~3.11V logic level for the FPGA's LVCMOS33 pin.

* **555 Pin 3** -> 2kΩ Resistor -> **FPGA Pin N14**
* **FPGA Pin N14** -> 3.3kΩ Resistor -> **GND**  

## 🔌 UART Wiring
Connect your USB-to-Serial module to the FPGA:
* **FPGA Pin T12 (TX)** -> **Serial Module RX Pin**
* **FPGA GND** -> **Serial Module GND**

## 🚀 Quick Start Guide

### 1. Build the FPGA Bitstream
Create a new project in Vivado and add the following source files:
* `rtl/top_555_freq.v` (The main project logic)
* `rtl/uart_tx.v` (The UART transmitter)
* `constraints/pins.xdc` (Your board constraints)

Generate the bitstream and flash it to your board.

### 2. Run the Python Decoder
Ensure you have the `pyserial` library installed on your PC:
```bash
pip install pyserial

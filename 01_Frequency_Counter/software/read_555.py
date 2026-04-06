
import serial
import sys
from datetime import datetime

COM_PORT = 'COM12'
BAUD_RATE = 115200
FPGA_CLOCK = 50_000_000

def main():
    try:
        ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=1)
        print(f"Connected to {COM_PORT} at {BAUD_RATE} baud.")
        print("Press Ctrl+C to stop.\n")
        print("-" * 80)
        print(f"{'Time':<12} | {'Raw Hex':<10} | {'Clock Cycles':<15} | {'Frequency (Hz)':<15}")
        print("-" * 80)

        while True:
            if ser.in_waiting > 0:
                raw_data = ser.readline().decode('utf-8', errors='ignore').strip()
                if len(raw_data) == 8:
                    try:
                        clock_cycles = int(raw_data, 16)
                        if clock_cycles > 0:
                            frequency = FPGA_CLOCK / clock_cycles
                            ts = datetime.now().strftime("%H:%M:%S.%f")[:12]
                            print(f"{ts:<12} | {raw_data:<10} | {clock_cycles:<15,d} | {frequency:.2f} Hz")
                    except ValueError:
                        print(f"Malformed: {raw_data}")

    except serial.SerialException as e:
        print(f"\n[ERROR] Could not open {COM_PORT}: {e}")
    except KeyboardInterrupt:
        print("\nStopped by user.")
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("Port closed.")

if __name__ == '__main__':
    main()

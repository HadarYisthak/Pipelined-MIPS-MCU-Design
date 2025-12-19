Project Name: Pipelined MIPS MCU
Short Description

![MIPS MCU Architecture](Pipelined_MIPS_top_entity.png)

A complete MIPS-based microcontroller (MCU) design in VHDL, featuring single-cycle and 5-stage pipelined cores, memory-mapped I/O, interrupts, and serial communication. Designed for FPGA deployment, with full testing and debugging support.

Main Components
MCU (MCU.vhd)
Top-level microcontroller unit integrating CPU cores, memory-mapped peripherals, and debugging features.

BTIMER (BTIMER.vhd)
8-bit timer supporting output compare, basic interrupts, and timing functionalities.

GPIO (GPIO.vhd)
Memory-mapped General Purpose Input/Output module connected to LEDs, switches, and 7-segment displays.

Interrupt Controller (InterruptController.vhd)
Manages and prioritizes external and internal interrupts for CPU execution.

Address Decoder (OptAddrDecoder.vhd)
Maps memory addresses to the correct peripheral modules.

Input/Output Peripherals
Modules connecting the CPU to external inputs (switches) and outputs (LEDs, displays).

Seven-Segment Decoder (SevenSegDecoder.vhd)
Decodes 4-bit inputs into 7-segment display outputs for user interaction and debugging.

MIPS CPU Modules
MIPS.vhd – Top entity, includes pipeline registers and debugging interfaces
ALU.vhd / ALU_CONTROL.vhd – Performs arithmetic and logic operations
CONTROL.vhd – Generates control signals for instruction execution
IFETCH.vhd / IDECODE.vhd / EXECUTE.vhd / DMEMORY.vhd / WRITE_BACK.vhd – Standard CPU pipeline stages
Hazard_Unit.vhd – Manages pipeline hazards, stalls, and flushes

Inputs and Outputs
Single-cycle / Pipeline inputs:
clk_i – 50 MHz clock
rst_i – Reset signal
BPADDER_i – Breakpoint address input (pipeline only)
Outputs:
Program counter (PC)
ALU results
Instruction codes
Memory/Register write signals
Counters: instruction, stall, and flush

Hardware Testing
Tested on DE10-Standard FPGA board with switches and keys for reset, breakpoint, and debug control.

Purpose
This project demonstrates the design, implementation, and testing of a MIPS-based MCU with modular peripherals, supporting single-cycle and pipelined CPU cores, suitable for FPGA applications and hands-on VHDL learning.

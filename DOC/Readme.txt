# MIPS-Based MCU Architecture – Final Project

This project involves the development of two MIPS CPU cores:
- **Single-cycle architecture**
- **Pipelined (5-stage) architecture**

Each processor supports:
- Memory-Mapped I/O
- Interrupts
- Serial communication (UART)

The goal is to implement a complete MIPS-based Microcontroller Unit (MCU) suitable for FPGA deployment.

---

## Main Components Overview

### MCU (`MCU.vhd`)
Top-level microcontroller unit integrating the CPU core, memory-mapped peripherals, and debugging support.

### BTIMER (`BTIMER.vhd`)
An 8-bit up-counter timer module that supports output compare mode in continuous operation. It allows the processor to:
- Measure execution time
- Trigger interrupts
- Handle basic timing functionalities like toggling pins or capturing time between events

### GPIO (`GPIO.vhd`)
General Purpose Input/Output module connected to switches, LEDs, and 7-segment displays. Operates as a memory-mapped peripheral with decoder and buffer logic.

### Interrupt Controller (`InterruptController.vhd`)
Handles external and internal interrupts and prioritizes them for the CPU.

### Address Decoder (`OptAddrDecoder.vhd`)
Optional decoder used to map different address ranges to respective peripherals (e.g., timer, GPIO, UART).

### OutputPeripheral / InputPeripheral
I/O modules used to connect the CPU to output (e.g., LEDs) and input (e.g., switches) devices.

### Seven Segment Decoder (`SevenSegDecoder.vhd`)
Decodes 4-bit input values into 7-segment display control outputs.

### UART (`UART.vhd`, `UART_TX.vhd`, `UART_RX.vhd`)
Full-duplex Universal Asynchronous Receiver/Transmitter interface for serial communication.

---

## MIPS CPU Components

### Top Entity (`MIPS.vhd`)
The pipelined MIPS top entity that includes:
- Pipeline registers
- Debugging interfaces (e.g., IPC counters, breakpoint logic)

### ALU (`ALU.vhd`)
Performs arithmetic and logic operations during the Execute stage.

### ALU Control (`ALU_CONTROL.vhd`)
Generates the appropriate ALU control signals based on opcode and function fields.

### Control Unit (`CONTROL.vhd`)
Decodes instruction opcodes and generates control signals such as RegWrite, MemRead, Branch, etc.

### Instruction Fetch (`IFETCH.vhd`)
- Fetches instructions from Instruction Memory
- Calculates `PC + 4`, jump, and branch addresses

### Instruction Decode (`IDECODE.vhd`)
- Parses instruction fields
- Reads register file
- Prepares operands for execution
- Computes branch conditions

### Execute (`EXECUTE.vhd`)
Performs actual execution of ALU operations and calculates memory addresses.

### Data Memory (`DMEMORY.vhd`)
Implements read/write logic for data memory. The memory size is `2^12` words.

### Write Back (`WRITE_BACK.vhd`)
Handles writing the result of an instruction back to the register file. Determines if the value comes from memory or the ALU.

### Hazard Unit (`Hazard_Unit.vhd`)
Manages pipeline hazards by forwarding data or inserting stalls and flushes when needed.

---

## Inputs and Outputs
Single cycle:
### Inputs:
- clk_i: 50 MHz clock
- rst_i: Reset signal (e.g., from switch SW[0])

### Outputs:
- pc_o: Current Program Counter
- alu_result_o: Result from ALU
- read_data1_o, read_data2_o: Register file read values
- write_data_o: Data written to memory or registers
- instruction_top_o: Current fetched instruction
- Branch_ctrl_o, Jump_ctrl_o: Branch and jump control signals
- Zero_o: ALU zero flag
- MemWrite_ctrl_o, RegWrite_ctrl_o: Memory and register write enable signals
- mclk_cnt_o: Master clock cycle counter
- inst_cnt_o: Instruction counter

Pipeline:
### Inputs:
- clk_i: 50 MHz clock
- rst_i: Reset signal (e.g., from switch SW[0])
- BPADDER_i: Breakpoint address input

### Outputs:
- IFpc_o: program counter
- IDpc_o: program counter
- EXpc_o: program counter
- MEMpc_o: program counter
- WBpc_o: program counter
- IFinstruction_o: instruction hex code
- IDinstruction_o: instruction hex code
- EXinstruction_o: instruction hex code
- MEMinstruction_o: instruction hex code
- WBinstruction_o: instruction hex code
- CLKCNT_o: Master clock cycle counter
- INSTCNT_o: Instruction counter
- STRIGGER_o: Breakpoint address
- STCNT_o: Stall counter 
- FHCNT_o: Flush counter 
---

## Hardware Testing

The system is tested on the **D10-Standard FPGA board**:
- SW[0]: Used for reset
- SW[7:0]: Used to set the breakpoint address
- `Keys`: Used for enable/debug control

---

## Debugging Features

To support instruction-per-clock (IPC) calculation and effective debugging:
- STCNT_o: Stall counter (8-bit) – increments on every cycle a stall occurs
- FHCNT_o: Flush counter (8-bit) – increments when a pipeline flush occurs
- BPADDR_i: Breakpoint address input – allows triggering SignalTap on a specific PC value

---

> This project showcases a complete design, implementation, and testing flow of a MIPS-based microcontroller architecture with both single-cycle and pipelined core designs.

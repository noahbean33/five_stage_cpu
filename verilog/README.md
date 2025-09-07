
# Verilog Processor Design

This document provides a technical overview of the Verilog-based processor design, detailing its architecture, modules, and core functionalities.

## 1. Processor Architecture

The processor is a 16-bit custom CPU featuring a modular design. It includes a register file, an arithmetic and logical unit (ALU), a memory system, and control logic for instruction processing. The architecture is built around a set of distinct modules, each responsible for a specific aspect of the processor's operation.

### Key Components:
- **Register File:** 32 general-purpose registers (GPRs), each 16 bits wide.
- **Special Register (SGPR):** A 16-bit register to store the most significant bits (MSB) of a multiplication result.
- **Instruction Register (IR):** A 32-bit register to hold the current instruction being executed.
- **Program Counter (PC):** An integer register that holds the address of the next instruction to be fetched.

## 2. Core Modules

The processor's functionality is partitioned into the following key Verilog modules:

### a. `logical_unit.v`
This module implements the core arithmetic and logical operations. It decodes instructions and performs the corresponding computation.
- **Supported Arithmetic Operations:** `add`, `sub`, `mul`.
- **Data Movement:** `mov` (register/immediate), `movsgpr` (move from special register).
- **Functionality:** It takes instruction details as input and executes the specified operation on the GPRs. For multiplication, the 32-bit result is split between a destination GPR (LSB) and the SGPR (MSB).

### b. `memory.v`
This module manages the processor's memory system, which is divided into instruction memory and data memory.
- **Instruction Memory:** A 16x32-bit register array to store the program, loaded from `inst_data.mem`.
- **Data Memory:** A 16x16-bit register array for data storage.
- **Memory Operations:**
  - `storereg`: Stores a GPR value into data memory.
  - `storedin`: Stores data from an input port (`din`) into data memory.
  - `senddout`: Sends data from memory to an output port (`dout`).
  - `sendreg`: Loads data from memory into a GPR.

### c. `branching.v`
This module contains the main control logic, including a Finite State Machine (FSM) that orchestrates the instruction cycle.
- **FSM States:**
  1. `idle`: Initial state.
  2. `fetch_inst`: Fetches the next instruction from instruction memory using the PC.
  3. `dec_exec_inst`: Decodes the instruction and executes it.
  4. `delay_next_inst`: A delay state.
  5. `next_inst`: Increments the PC or updates it for a jump.
  6. `sense_halt`: Checks for a halt instruction.
- **Control Flow:** Implements `jump` and `halt` instructions to manage the program flow.

### d. `condition_flag.v`
This module is responsible for calculating and updating the processor's status flags based on the results of arithmetic and logical operations.
- **Flags:**
  - `sign (S)`: Set if the result is negative (MSB is 1).
  - `zero (Z)`: Set if the result is zero.
  - `carry (C)`: Set on carry-out in an addition.
  - `overflow (V)`: Set if an arithmetic operation results in an overflow.
- **Functionality:** The logic for each flag is determined by the operation type and its outcome. For example, the carry flag is only affected by the `add` operation.

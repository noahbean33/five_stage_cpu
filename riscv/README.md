# README for `riscv/`

## Overview

This folder contains a RISC-V RV32I-style CPU core, a program memory, a top-level wrapper, and a testbench for simulation. The design is FSM-based and intended for learning. Firmware is provided in `firmware.hex` and is loaded into the program memory at simulation/synthesis time.

## Contents

-   `cpu.v`: FSM-based RV32I-like CPU core (R/I/branch/jump, shifts, loads/stores, AUIPC/LUI). Exposes a simple memory interface and a cycle counter.
-   `progmem.v`: 32-bit wide, word-addressed program/data memory that loads `firmware.hex`. Supports byte-lane writes.
-   `top.v`: SoC wrapper that wires `cpu.v` to `progmem.v`. Exposes `rst`, `clk`, and a `cycle` count for observation.
-   `testbench.v`: Simple testbench that drives reset/clock, runs, dumps a VCD, prints register file contents and peeks memory.
-   `firmware.hex`: Program image loaded by `progmem.v` using `$readmemh`.

## High-level Architecture

`top.v` instantiates:

-   `cpu cpu0(...)` — issues instruction fetches and data accesses via a unified memory port.
-   `progmem mem0(...)` — synchronous memory that serves reads and supports byte-lane writes.

### Execution flow:

-   `cpu.v` advances through `RESET` → `WAIT` → `FETCH` → `DECODE` → `EXECUTE` → (`BYTE`) → `WAIT_LOADING` → `WAIT` depending on instruction type.
-   PC increments by 4 on sequential flow or updates by immediate for branches/jumps.
-   Register file writes occur at `EXECUTE` (ALU/jump/LUI/AUIPC) or after loads.

## Interfaces

### `cpu.v` ports

-   `input rst, clk`
-   `input  [31:0] mem_rdata` — 32-bit read data from memory
-   `output [31:0] mem_addr` — byte address
-   `output [31:0] mem_wdata` — write data
-   `output        mem_rstrb` — read strobe (asserts during fetch/loads)
-   `output [3:0]  mem_wstrb` — byte write enable (per-lane store)
-   `output reg [31:0] cycle` — cycles since reset (halts increment in `HLT`)

### `progmem.v` ports

-   `input rst, clk`
-   `input  [31:0] addr` — byte address; internally uses `addr[31:2]` (word index)
-   `input  [31:0] data_in`
-   `input         rd_strobe`
-   `input  [3:0]  wr_strobe`
-   `output reg [31:0] data_out`

**Notes:**

-   Memory is modeled as `reg [31:0] PROGMEM[0:MEM_SIZE-1]` with `MEM_SIZE=1024` words.
-   `$readmemh("firmware.hex", PROGMEM);` preloads the image at time 0.
-   Writes are synchronous, with lane enables mapped to `[7:0]`, `[15:8]`, `[23:16]`, `[31:24]`.

## CPU Design Summary (`cpu.v`)

-   **FSM states**: `RESET`, `WAIT`, `FETCH`, `DECODE`, `EXECUTE`, `BYTE`, `WAIT_LOADING`, `HLT`.
-   **Decoding**:
    -   R-type, I-type, B-type, S-type (store), L-type (load), JAL, JALR, LUI, AUIPC.
    -   Immediate formats: I/S/B/J/U constructed per RV32I.
-   **ALU ops**:
    -   `ADD`, `SUB`, `XOR`, `OR`, `AND`, compare (signed/unsigned), `SLL`, `SRL`, `SRA`.
-   **Branch/jump**:
    -   Branch taken based on comparisons; JAL uses `J_data`; AUIPC/LUI supported.
-   **Loads/stores**:
    -   Byte/half/word accesses with sign/zero extension handled in load path.
    -   `mem_wstrb` generated per access size and address alignment.
-   **Register writeback**:
    -   ALU/jump/LUI/AUIPC at `EXECUTE`; load at `WAIT_LOADING`.
    -   `x0` writes are ignored.

## Testbench (`testbench.v`)

-   Includes `top.v` and instantiates `top dut(rst, clk, cycle)`.
-   **Sequence**:
    1.  Generates VCD: `test.vcd` with `$dumpvars`.
    2.  Resets for 50 time units, releases, runs for 5000 time units by default.
    3.  **Prints**:
        -   Registers `x0..x6`: `dut.cpu0.regfile[i]`
        -   Cycle count: `cycle`
        -   Memory word at `loc = 1000` (uses `dut.mem0.PROGMEM[loc[10:2]]`).
-   **Clock**: `always #5 clk = ~clk;` (100 MHz equivalent timebase in sim units).

## How to Simulate

### Using Icarus Verilog:

```sh
iverilog -g2012 -o simv testbench.v
vvp simv
# View waves: open test.vcd in your preferred viewer (e.g., GTKWave)
```

### Using Verilator (example):

```sh
verilator --cc --exe --build -Wall --trace -CFLAGS "-std=gnu++17" \
  testbench.v top.v cpu.v progmem.v \
  -o simv
./obj_dir/simv
```

> **Note**: Ensure `firmware.hex` is present in the working directory so `$readmemh` can find it.

## Firmware Notes

-   `progmem.v` expects a hex file with one 32-bit word per line (most common `$readmemh` format).
-   To change the program, replace `firmware.hex` and rerun the simulation.

## Extending

-   **Add data memory or memory-mapped peripherals by**:
    -   Introducing an address decoder in `top.v` to split `mem_*` onto multiple memories/IP.
    -   Connecting device-specific modules (e.g., GPIO/UART) and handling read/write strobes.
-   **Add CSR/system instructions** by decoding `opcode == 11100` and implementing CSR file and side effects.
-   **Add multiply/divide** by extending ALU and writeback, or by a separate M-extension unit.


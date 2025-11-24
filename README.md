# RISC-V RV32I Processor

A hardware implementation of a RISC-V 32-bit integer processor written in Verilog, featuring an FSM-based design verified for FPGA synthesis.

## Features

### Supported Instruction Set (RV32I Base)
- ✅ **R-type**: ADD, SUB, XOR, OR, AND, SLT, SLTU, SLL, SRL, SRA
- ✅ **I-type**: ADDI, XORI, ORI, ANDI, SLTI, SLTIU, SLLI, SRLI, SRAI
- ✅ **Load**: LW, LH, LB, LHU, LBU
- ✅ **Store**: SW, SH, SB
- ✅ **Branch**: BEQ, BNE, BLT, BGE, BLTU, BGEU
- ✅ **Jump**: JAL, JALR
- ✅ **Upper Immediate**: LUI, AUIPC
- ✅ **System**: ECALL (halt)

### Architecture
- **Design Style**: 5-stage FSM (RESET → WAIT → FETCH → DECODE → EXECUTE)
- **Register File**: 32 general-purpose registers (x0-x31)
- **Memory**: 1024-word program memory with byte-addressable load/store
- **ALU**: Full arithmetic, logic, comparison, and shift operations
- **Cycle Counter**: Built-in performance monitoring

## Project Structure

```
verilog_processor/
├── src/
│   └── cpu/
│       ├── cpu.v          # Main CPU module (FSM, ALU, control logic)
│       ├── progmem.v      # Program memory (1024 x 32-bit)
│       ├── top.v          # Top-level module connecting CPU and memory
│       ├── testbench.v    # Simulation testbench
│       └── firmware.hex   # Example program (hex format)
├── docs/                  # RISC-V reference materials
└── requirements.txt       # Python dependencies for testing
```

## Quick Start

### Prerequisites
- **Icarus Verilog** (or another Verilog simulator)
- **GTKWave** (optional, for viewing waveforms)

### Simulation

1. **Compile and run the testbench:**
   ```bash
   cd src/cpu
   iverilog -o testbench.v.out testbench.v
   vvp testbench.v.out
   ```

2. **View results:**
   The simulation will print register contents and cycle count:
   ```
   *** Printing register content ***
   X[0] = 0
   X[1] = 12
   X[2] = 4096
   ...
   Clock cycle=XXX
   ```

3. **View waveforms (optional):**
   ```bash
   gtkwave test.vcd
   ```

### Loading Custom Programs

Edit `firmware.hex` with RISC-V machine code (hex format, one 32-bit instruction per line):
```
40000093    # addi x1, x0, 1024
00c09113    # addi x2, x1, 12
...
```

You can generate firmware using a RISC-V toolchain:
```bash
riscv32-unknown-elf-as -o program.o program.s
riscv32-unknown-elf-objcopy -O binary program.o program.bin
hexdump -v -e '1/4 "%08x\n"' program.bin > firmware.hex
```

## Design Details

### State Machine
1. **RESET**: Initialize registers and program counter
2. **WAIT**: Memory read strobe assertion (1-cycle delay)
3. **FETCH**: Latch instruction from memory
4. **DECODE**: Decode instruction and read register file
5. **EXECUTE**: Perform ALU operation and update PC
6. **BYTE**: Memory address calculation for load/store
7. **WAIT_LOADING**: Complete load/store operation
8. **HLT**: Halt state (triggered by ECALL)

### Memory Interface
- **Address Bus**: 32-bit byte-addressable
- **Data Bus**: 32-bit bidirectional
- **Control Signals**: 
  - `mem_rstrb`: Read strobe
  - `mem_wstrb[3:0]`: Write strobe mask (byte-level granularity)

### ALU Operations
All standard RISC-V ALU operations with proper signed/unsigned handling:
- Arithmetic: ADD, SUB
- Logic: XOR, OR, AND
- Comparison: SLT, SLTU
- Shifts: SLL, SRL, SRA (logical left, logical right, arithmetic right)

## Known Limitations

- ⚠️ **LBU/LHU**: Load byte/halfword unsigned implemented but not extensively tested
- ⚠️ **No Pipeline**: Single-cycle-per-stage design (lower performance)
- ⚠️ **No Cache**: Direct memory access only
- ⚠️ **Limited Memory**: 1024-word (4KB) program memory
- ⚠️ **No Interrupts/Exceptions**: Beyond ECALL for halt

## Testing

Python-based testing with cocotb is configured but not yet fully implemented. See `docs/TESTING.md` for details.

```bash
# Install test dependencies
pip install -r requirements.txt

# Run tests (when implemented)
pytest -q
```

## FPGA Synthesis

This design has been verified for FPGA synthesis. Key considerations:
- Avoids dual-port RAM generation in memory module
- Single clock domain design
- Synchronous reset
- Registered outputs

Synthesis-ready for most FPGA families (Xilinx, Intel/Altera, Lattice).

## Performance

Typical instruction timing:
- **R-type/I-type**: 5 cycles (WAIT → FETCH → DECODE → EXECUTE → WAIT)
- **Branch taken**: 5 cycles
- **Load/Store**: 7 cycles (includes BYTE and WAIT_LOADING states)
- **Jump**: 5 cycles

## References

- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/)
- Load/store logic adapted from [FEMTORV32](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV) by Bruno Levy

## License

See `LICENSE` file for details.



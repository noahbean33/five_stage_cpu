# VHDL Processor Implementation

This directory contains the VHDL source code for a custom processor, designed as part of the "Building a Processor with Verilog HDL from Scratch" course on Udemy. The design is implemented and tested using Xilinx Vivado 2020.2.

## Processor Architecture

The processor is a 16-bit architecture with 32 general-purpose registers (GPRs). It supports a variety of arithmetic, logical, and data movement instructions. The design also includes a set of condition flags to enable conditional branching and other control flow operations.

### Instruction Set Architecture (ISA)

The processor supports the following instructions:

**Data Movement:**
- `mov`: Move data between registers or from an immediate value to a register.
- `movsgpr`: Move data from the special GPR (used for multiplication results) to a GPR.

**Arithmetic:**
- `add`: Addition
- `sub`: Subtraction
- `mul`: Multiplication

**Logical:**
- `lor`: Logical OR
- `land`: Logical AND
- `lxor`: Logical XOR
- `lxnor`: Logical XNOR
- `lnand`: Logical NAND
- `lnor`: Logical NOR
- `lnot`: Logical NOT

### Register File

The processor has 32 general-purpose registers (GPRs), each 16 bits wide. There is also a special 16-bit register (`SGPR`) that holds the most significant 16 bits of a multiplication result.

### Instruction Format

The instructions are 32 bits wide and follow the format below:

`IR[31:27]` - Opcode
`IR[26:22]` - Destination Register (rdest)
`IR[21:17]` - Source Register 1 (rsrc1)
`IR[16]` - Mode Select (0 for register, 1 for immediate)
`IR[15:11]` - Source Register 2 (rsrc2)
`IR[15:0]` - Immediate Data

### Condition Flags

The processor has four condition flags:

- **Zero Flag (Z):** Set if the result of an operation is zero.
- **Sign Flag (S):** Set if the result of an operation is negative.
- **Carry Flag (C):** Set if an addition operation results in a carry-out.
- **Overflow Flag (V):** Set if an arithmetic operation results in an overflow.

## Files

- `proc_top.vhd`: The top-level VHDL file for the processor.
- `proc_tb.vhd`: The testbench for the processor.

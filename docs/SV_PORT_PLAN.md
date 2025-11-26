# SystemVerilog Port Plan - Basic Syntax Changes

**Estimated Time**: 1-2 hours  
**Complexity**: Low  
**Goal**: Convert Verilog to SystemVerilog using modern syntax while maintaining exact functionality

---

## Overview

This plan covers a **minimal syntax-only port** from Verilog to SystemVerilog. No architectural changes, no new features—just modernizing the syntax to be idiomatic SystemVerilog.

### Files to Modify
1. `src/cpu/cpu.v` → `cpu.sv` (240 lines)
2. `src/cpu/progmem.v` → `progmem.sv` (48 lines)
3. `src/cpu/top.v` → `top.sv` (31 lines)
4. `src/cpu/testbench.v` → `testbench.sv` (34 lines)

---

## Phase 1: Preparation (5 min)

### 1.1 Create Backup
```bash
git checkout -b systemverilog-port
git add .
git commit -m "Pre-port checkpoint"
```

### 1.2 Verify Current Functionality
```bash
cd src/cpu
iverilog -o testbench.v.out testbench.v
vvp testbench.v.out
# Save output for comparison
```

---

## Phase 2: cpu.v → cpu.sv (30-40 min)

### 2.1 Rename File
- Rename `cpu.v` to `cpu.sv`

### 2.2 Replace `reg`/`wire` with `logic`

**Lines to change:**
- Line 26: `reg [31:0] regfile[0:31]` → `logic [31:0] regfile[0:31]`
- Line 27: `reg [31:0] addr, data_rs1, data_rs2` → `logic [31:0] addr, data_rs1, data_rs2`
- Line 28: `reg [31:0] data` → `logic [31:0] data`
- Line 30: `reg [3:0] state` → `logic [3:0] state`
- Line 22: `output reg [31:0] cycle` → `output logic [31:0] cycle`

**Rationale**: SystemVerilog `logic` type replaces both `reg` and `wire`, simplifying type management.

### 2.3 Update FSM State Encoding

**Before (Lines 31-32):**
```verilog
parameter RESET=0, WAIT=1, FETCH=2, DECODE=3, EXECUTE=4, BYTE=5, WAIT_LOADING=6, HLT=7;
```

**After:**
```systemverilog
typedef enum logic [3:0] {
    RESET       = 4'd0,
    WAIT        = 4'd1,
    FETCH       = 4'd2,
    DECODE      = 4'd3,
    EXECUTE     = 4'd4,
    BYTE        = 4'd5,
    WAIT_LOADING = 4'd6,
    HLT         = 4'd7
} state_t;

state_t state;
```

**Note**: Remove line 30's `logic [3:0] state` declaration (moved into enum).

### 2.4 Convert Always Blocks

**Line 155 - Sequential logic:**
```verilog
always @(posedge clk)
```
→
```systemverilog
always_ff @(posedge clk)
```

**Line 210 - Cycle counter:**
```verilog
always @(posedge clk)
```
→
```systemverilog
always_ff @(posedge clk)
```

**Line 232 - Register writeback:**
```verilog
always @(posedge clk)
```
→
```systemverilog
always_ff @(posedge clk)
```

### 2.5 Update Header Comment
Add SystemVerilog notice:
```systemverilog
/* CPU Version 5.0 - SystemVerilog Port
Support RV-32I extension only
Ported to SystemVerilog syntax (basic conversion)
... (keep existing comments)
*/
```

---

## Phase 3: progmem.v → progmem.sv (15 min)

### 3.1 Rename File
- Rename `progmem.v` to `progmem.sv`

### 3.2 Replace Data Types

**Line 11:**
```verilog
output reg [31:0] data_out
```
→
```systemverilog
output logic [31:0] data_out
```

**Line 15:**
```verilog
reg [31:0] PROGMEM[0:MEM_SIZE-1];
```
→
```systemverilog
logic [31:0] PROGMEM[0:MEM_SIZE-1];
```

### 3.3 Convert Always Blocks

**Line 21:**
```verilog
always @(posedge clk)
```
→
```systemverilog
always_ff @(posedge clk)
```

**Line 29:**
```verilog
always @(posedge clk)
```
→
```systemverilog
always_ff @(posedge clk)
```

---

## Phase 4: top.v → top.sv (10 min)

### 4.1 Rename File
- Rename `top.v` to `top.sv`

### 4.2 Update Include Directives

**Lines 1-2:**
```verilog
`include "cpu.v"
`include "progmem.v"
```
→
```systemverilog
`include "cpu.sv"
`include "progmem.sv"
```

### 4.3 Replace Wire Declarations

**Lines 7-9:**
```verilog
wire [31:0] mem_rdata, mem_wdata, addr;
wire rstrb;
wire [3:0] wr_strobe;
```
→
```systemverilog
logic [31:0] mem_rdata, mem_wdata, addr;
logic rstrb;
logic [3:0] wr_strobe;
```

---

## Phase 5: testbench.v → testbench.sv (10 min)

### 5.1 Rename File
- Rename `testbench.v` to `testbench.sv`

### 5.2 Update Include Directive

**Line 1:**
```verilog
`include "top.v"
```
→
```systemverilog
`include "top.sv"
```

### 5.3 Replace Register Declarations

**Lines 3-6:**
```verilog
reg rst, clk;
wire [31:0] cycle;
integer i;
reg [10:0] loc = 1000;
```
→
```systemverilog
logic rst, clk;
logic [31:0] cycle;
int i;
logic [10:0] loc = 1000;
```

### 5.4 Update Always Block

**Line 32:**
```verilog
always #5 clk=~clk;
```
→
```systemverilog
always #5 clk = ~clk;
```
(Already correct, no change needed—just verify)

---

## Phase 6: Verification (10-15 min)

### 6.1 Update Simulation Commands

**For Icarus Verilog (with SV support):**
```bash
cd src/cpu
iverilog -g2012 -o testbench.sv.out testbench.sv
vvp testbench.sv.out
```

**Note**: `-g2012` enables SystemVerilog-2012 features.

**Alternative (if using other simulators):**
- **Verilator**: `verilator --sv --lint-only -Wall testbench.sv`
- **Modelsim/Questa**: `vlog -sv testbench.sv`
- **Vivado**: Just use `.sv` extension, tools auto-detect

### 6.2 Compare Outputs
```bash
# Compare against pre-port output
diff old_output.txt new_output.txt
# Should be identical
```

### 6.3 Waveform Verification
```bash
gtkwave test.vcd
# Visually verify FSM transitions, register values
```

### 6.4 Regression Tests
Run any existing test programs through the processor and verify:
- Register final values match
- Cycle counts match
- Memory contents match

---

## Phase 7: Documentation Updates (5 min)

### 7.1 Update README.md

**Line 3:**
```markdown
A hardware implementation of a RISC-V 32-bit integer processor written in Verilog...
```
→
```markdown
A hardware implementation of a RISC-V 32-bit integer processor written in SystemVerilog...
```

**Lines 30-34 (Project Structure):**
```markdown
├── cpu.v          # Main CPU module (FSM, ALU, control logic)
├── progmem.v      # Program memory (1024 x 32-bit)
├── top.v          # Top-level module connecting CPU and memory
├── testbench.v    # Simulation testbench
```
→
```markdown
├── cpu.sv         # Main CPU module (FSM, ALU, control logic)
├── progmem.sv     # Program memory (1024 x 32-bit)
├── top.sv         # Top-level module connecting CPU and memory
├── testbench.sv   # Simulation testbench
```

**Line 48 (Simulation section):**
```markdown
iverilog -o testbench.v.out testbench.v
```
→
```markdown
iverilog -g2012 -o testbench.sv.out testbench.sv
```

### 7.2 Add Migration Note
Add new section in README:
```markdown
## SystemVerilog Features

This design uses SystemVerilog-2012 syntax:
- `logic` type instead of `reg`/`wire`
- `always_ff` for sequential logic
- Enumerated types for FSM states
- Maintains full backward compatibility with synthesis tools
```

---

## Phase 8: Final Checklist

### Before Committing:
- [ ] All `.v` files renamed to `.sv`
- [ ] All `reg`/`wire` → `logic` conversions complete
- [ ] All `always @(posedge clk)` → `always_ff` conversions complete
- [ ] FSM states converted to enum
- [ ] Include directives updated
- [ ] Testbench runs successfully
- [ ] Output matches pre-port results
- [ ] README.md updated
- [ ] No synthesis warnings introduced

### Git Commit:
```bash
git add src/cpu/*.sv
git commit -m "Port to SystemVerilog: basic syntax changes only

- Renamed all .v files to .sv
- Replaced reg/wire with logic type
- Converted always blocks to always_ff
- Added enum for FSM states
- Updated documentation

Verification: testbench output matches original
"
```

---

## Common Pitfalls to Avoid

### ❌ Don't Change:
- Module interfaces (port lists)
- Signal widths or timing
- FSM state values
- ALU logic or calculations
- Memory initialization (`$readmemh`)

### ✅ Do Verify:
- Enum state values match original parameters exactly
- All `integer` types that should be `int` are changed
- Include paths are correct after renaming
- Simulator flags support SystemVerilog features

---

## Rollback Plan

If issues arise:
```bash
git checkout main
git branch -D systemverilog-port
# Start over or investigate specific issues
```

---

## Time Breakdown

| Phase | Task | Time |
|-------|------|------|
| 1 | Preparation | 5 min |
| 2 | cpu.sv conversion | 30-40 min |
| 3 | progmem.sv conversion | 15 min |
| 4 | top.sv conversion | 10 min |
| 5 | testbench.sv conversion | 10 min |
| 6 | Verification | 10-15 min |
| 7 | Documentation | 5 min |
| 8 | Final review | 5 min |
| **Total** | | **90-105 min** |

---

## Next Steps (Future Enhancements)

After this basic port, consider:
1. **Interfaces**: Create memory bus interface
2. **Assertions**: Add SVA for protocol checking
3. **Packages**: Extract opcodes/constants to package
4. **Coverage**: Add functional coverage groups
5. **Constraints**: Add randomization for verification

These are **NOT** part of this basic port but could be future improvements.

---

## Success Criteria

✅ Port is complete when:
1. All files use `.sv` extension
2. All SystemVerilog syntax changes applied
3. Testbench produces identical results
4. No new synthesis warnings
5. Documentation updated
6. Code committed to version control

---

**Last Updated**: Nov 26, 2025  
**Author**: Automated migration plan  
**Target**: SystemVerilog-2012 compliance

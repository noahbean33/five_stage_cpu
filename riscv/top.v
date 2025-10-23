// Top-level SoC wrapper: instantiates CPU and program memory
`include "cpu.v"
`include "progmem.v"
module top(
    input rst, clk,
    output [31:0] cycle
  );
  // Shared instruction/data memory interface
  wire [31:0] mem_rdata, mem_wdata, addr; // read data from memory, write data to memory, and address bus
  wire rstrb;                             // memory read strobe from CPU
  wire [3:0] wr_strobe;                   // byte write-enable mask to memory
  
  // Instantiate CPU core: issues instruction fetches and optional data writes
  cpu cpu0(
        .rst(rst), .clk(clk),
        .mem_rdata(mem_rdata),
        .mem_addr(addr),
        .cycle(cycle),
        .mem_rstrb(rstrb),
        .mem_wdata(mem_wdata),
        .mem_wstrb(wr_strobe)
      );

  // Program memory: loads firmware.hex and services CPU reads/writes
  progmem mem0(
            .rst(rst), .clk(clk),
            .addr(addr),
            .data_in(mem_wdata),
            .rd_strobe(rstrb),
            .wr_strobe(wr_strobe),
            .data_out(mem_rdata)
          );
endmodule

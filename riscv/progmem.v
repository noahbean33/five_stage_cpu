//Verilog code for program memory
//Revised version of Memory to avoid DPB generation during synthesis
//Revised on 16/04/2025
//Author: Prof. Subir Kr. Maity
module progmem(
    input rst, clk,
    input [31:0] addr,              // byte address from CPU (word-aligned internally)
    input [31:0] data_in,           // must match data_out width to keep single-port RAM inference
    input rd_strobe,                // read enable
    input [3:0] wr_strobe,          // byte write enables: bit[0] -> lowest byte, bit[3] -> highest
    output reg [31:0] data_out      // synchronous read data

  );
  parameter MEM_SIZE = 1024;
  reg [31:0] PROGMEM[0:MEM_SIZE-1]; // 1024 x 32-bit program memory
  wire [29:0] mem_loc = addr[31:2]; // word index (ignore addr[1:0])
  initial
  begin
    $readmemh("firmware.hex", PROGMEM); // preload program from hex file
  end
  always @(posedge clk)
  begin
    if(rst)
      data_out <= 32'h0;              // clear output on reset
    else if(rd_strobe)                // synchronous read
      data_out <= PROGMEM[mem_loc];
  end

  always @(posedge clk)
  begin
    // byte-lane writes when enabled by wr_strobe
    if(wr_strobe[0]) PROGMEM[mem_loc][7:0]    <= data_in[7:0];
    if(wr_strobe[1]) PROGMEM[mem_loc][15:8]   <= data_in[15:8];
    if(wr_strobe[2]) PROGMEM[mem_loc][23:16]  <= data_in[23:16];
    if(wr_strobe[3]) PROGMEM[mem_loc][31:24]  <= data_in[31:24];

  end






endmodule

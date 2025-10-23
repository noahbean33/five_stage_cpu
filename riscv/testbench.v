// Simple testbench to simulate the SoC
`include "top.v"
module top_test;
  reg rst, clk;             // stimulus signals
  wire [31:0] cycle;        // observe CPU cycle counter
  integer i;
  reg [10:0] loc = 1000;    // memory location to peek (byte address)
  // Instantiate DUT
  top dut (rst, clk, cycle);
  initial
  begin
    $dumpfile("test.vcd"); // waveform dump
    $dumpvars;
    rst=1;  // hold reset
    clk=0;  // start clock low
    #50;    // allow some time under reset
    rst=0;  // release reset
    #5000;  // run simulation

    // Print register content
    $display("*** Printing register content ***");
    for(i=0; i<7; i=i+1)
      $display("X[%0d] = %0d ",i,$signed(dut.cpu0.regfile[i]));
    $display("Clock cycle=%0d", cycle);
    // Show a word from program memory (word index derived from byte address)
    $display("Data at location %d = %d",loc, dut.mem0.PROGMEM[loc[10:2]]);
    $finish;
  end
  /*
  initial begin
  $monitor("Time=%0d, X[0]=%0d, X[1]=%0d, X[2]=%0d, X[3]=%0d, X[4]=%0d,  X[5]=%0d, Cycle=%0d",$time, dut.cpu0.regfile[0],dut.cpu0.regfile[1],dut.cpu0.regfile[2],dut.cpu0.regfile[3],dut.cpu0.regfile[4],dut.cpu0.regfile[5], cycle);
  end
  */
  always #5 clk=~clk; //clock generator
endmodule

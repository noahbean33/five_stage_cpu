`timescale 1ns / 1ps

///////////fields of IR
`define oper\_type IR\[31:27\]
`define rdst      IR\[26:22\]
`define rsrc1     IR\[21:17\]
`define imm\_mode  IR\[16\]
`define rsrc2     IR\[15:11\]
`define isrc      IR\[15:0\]


////////////////arithmetic operation
`define movsgpr        5'b00000
`define mov            5'b00001
`define add            5'b00010
`define sub            5'b00011
`define mul            5'b00100

////////////////logical operations : and or xor xnor nand nor not

`define ror            5'b00101
`define rand           5'b00110
`define rxor           5'b00111
`define rxnor          5'b01000
`define rnand          5'b01001
`define rnor           5'b01010
`define rnot           5'b01011

/////////////////////// load & store instructions

`define storereg       5'b01101   //////store content of register in data memory
`define storedin       5'b01110   ////// store content of din bus in data memory
`define senddout       5'b01111   /////send data from DM to dout bus
`define sendreg        5'b10001   ////// send data from DM to register



module top(
input clk,sys\_rst,
input \[15:0\] din,
output reg \[15:0\] dout
);

////////////////adding program and data memory
reg \[31:0\] inst\_mem \[15:0\]; ////program memory
reg \[15:0\] data\_mem \[15:0\]; ////data memory





reg \[31:0\] IR;            ////// instruction register  \<--ir\[31:27\]--\>\<--ir\[26:22\]--\>\<--ir\[21:17\]--\>\<--ir\[16\]--\>\<--ir\[15:11\]--\>\<--ir\[10:0\]--\>
                         //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  rsrc2 \--\>\<--unused  \--\>
                         //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  immediate\_date      \--\>   2^15

reg \[15:0\] GPR \[31:0\] ;   ///////general purpose register gpr\[0\] ....... gpr\[31\]



reg \[15:0\] SGPR ;      ///// msb of multiplication \--\> special register

reg \[31:0\] mul\_res;








task decode\_inst();
begin
case(`oper\_type)
///////////////////////////////
`movsgpr: begin

  GPR\[`rdst\] \= SGPR;

end

/////////////////////////////////
`mov : begin
  if(`imm\_mode)
       GPR\[`rdst\]  \= `isrc;
  else
      GPR\[`rdst\]   \= GPR\[`rsrc1\];
end

////////////////////////////////////////////////////

`add : begin
     if(`imm\_mode)
       GPR\[`rdst\]   \= GPR\[`rsrc1\] \+ `isrc;
    else
       GPR\[`rdst\]   \= GPR\[`rsrc1\] \+ GPR\[`rsrc2\];
end

/////////////////////////////////////////////////////////

`sub : begin
     if(`imm\_mode)
       GPR\[`rdst\]  \= GPR\[`rsrc1\] \- `isrc;
    else
      GPR\[`rdst\]   \= GPR\[`rsrc1\] \- GPR\[`rsrc2\];
end

/////////////////////////////////////////////////////////////

`mul : begin
     if(`imm\_mode)
       mul\_res   \= GPR\[`rsrc1\] \* `isrc;
    else
       mul\_res   \= GPR\[`rsrc1\] \* GPR\[`rsrc2\];

    GPR\[`rdst\]   \=  mul\_res\[15:0\];
    SGPR         \=  mul\_res\[31:16\];
end

///////////////////////////////////////////////////////////// bitwise or

`ror : begin
     if(`imm\_mode)
       GPR\[`rdst\]  \= GPR\[`rsrc1\] | `isrc;
    else
      GPR\[`rdst\]   \= GPR\[`rsrc1\] | GPR\[`rsrc2\];
end

////////////////////////////////////////////////////////////bitwise and

`rand : begin
     if(`imm\_mode)
       GPR\[`rdst\]  \= GPR\[`rsrc1\] & `isrc;
    else
      GPR\[`rdst\]   \= GPR\[`rsrc1\] & GPR\[`rsrc2\];
end

//////////////////////////////////////////////////////////// bitwise xor

`rxor : begin
     if(`imm\_mode)
       GPR\[`rdst\]  \= GPR\[`rsrc1\] ^ `isrc;
    else
      GPR\[`rdst\]   \= GPR\[`rsrc1\] ^ GPR\[`rsrc2\];
end

//////////////////////////////////////////////////////////// bitwise xnor

`rxnor : begin
     if(`imm\_mode)
       GPR\[`rdst\]  \= GPR\[`rsrc1\] \~^ `isrc;
    else
       GPR\[`rdst\]   \= GPR\[`rsrc1\] \~^ GPR\[`rsrc2\];
end

//////////////////////////////////////////////////////////// bitwisw nand

`rnand : begin
     if(`imm\_mode)
       GPR\[`rdst\]  \= \~(GPR\[`rsrc1\] & `isrc);
    else
      GPR\[`rdst\]   \= \~(GPR\[`rsrc1\] & GPR\[`rsrc2\]);
end

////////////////////////////////////////////////////////////bitwise nor

`rnor : begin
     if(`imm\_mode)
       GPR\[`rdst\]  \= \~(GPR\[`rsrc1\] | `isrc);
    else
      GPR\[`rdst\]   \= \~(GPR\[`rsrc1\] | GPR\[`rsrc2\]);
end

////////////////////////////////////////////////////////////not

`rnot : begin
     if(`imm\_mode)
       GPR\[`rdst\]  \= \~(`isrc);
    else
       GPR\[`rdst\]   \= \~(GPR\[`rsrc1\]);
end

////////////////////////////////////////////////////////////

`storedin: begin
  data\_mem\[`isrc\] \= din;
end

/////////////////////////////////////////////////////////////

`storereg: begin
  data\_mem\[`isrc\] \= GPR\[`rsrc1\];
end

/////////////////////////////////////////////////////////////


`senddout: begin
  dout  \= data\_mem\[`isrc\];
end

/////////////////////////////////////////////////////////////

`sendreg: begin
 GPR\[`rdst\] \=  data\_mem\[`isrc\];
end

/////////////////////////////////////////////////////////////
endcase
end
endtask



///////////////////////logic for condition flag
reg sign \= 0, zero \= 0, overflow \= 0, carry \= 0;
reg \[16:0\] temp\_sum;

task decode\_condflag();
begin

/////////////////sign bit
if(`oper\_type \== `mul)
 sign \= SGPR\[15\];
else
 sign \= GPR\[`rdst\]\[15\];

////////////////carry bit

if(`oper\_type \== `add)
  begin
     if(`imm\_mode)
        begin
        temp\_sum \= GPR\[`rsrc1\] \+ `isrc;
        carry    \= temp\_sum\[16\];
        end
     else
        begin
        temp\_sum \= GPR\[`rsrc1\] \+ GPR\[`rsrc2\];
        carry    \= temp\_sum\[16\];
        end   end
  else
   begin
       carry  \= 1'b0;
   end

///////////////////// zero bit

zero \=  ( \~(|GPR\[`rdst\]) | \~(|SGPR\[15:0\]) )  ;


//////////////////////overflow bit

if(`oper\_type \== `add)
    begin
      if(`imm\_mode)
        overflow \= ( (\~GPR\[`rsrc1\]\[15\] & \~IR\[15\] & GPR\[`rdst\]\[15\] ) | (GPR\[`rsrc1\]\[15\] & IR\[15\] & \~GPR\[`rdst\]\[15\]) );
      else
        overflow \= ( (\~GPR\[`rsrc1\]\[15\] & \~GPR\[`rsrc2\]\[15\] & GPR\[`rdst\]\[15\]) | (GPR\[`rsrc1\]\[15\] & GPR\[`rsrc2\]\[15\] & \~GPR\[`rdst\]\[15\]));
    end
 else if(`oper\_type \== `sub)
   begin
      if(`imm\_mode)
        overflow \= ( (\~GPR\[`rsrc1\]\[15\] & IR\[15\] & GPR\[`rdst\]\[15\] ) | (GPR\[`rsrc1\]\[15\] & \~IR\[15\] & \~GPR\[`rdst\]\[15\]) );
      else
        overflow \= ( (\~GPR\[`rsrc1\]\[15\] & GPR\[`rsrc2\]\[15\] & GPR\[`rdst\]\[15\]) | (GPR\[`rsrc1\]\[15\] & \~GPR\[`rsrc2\]\[15\] & \~GPR\[`rdst\]\[15\]));
   end
 else
    begin
    overflow \= 1'b0;
    end

end
endtask





////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////
///////////reading program

initial begin
$readmemb("C:/Users/kumar/proc\_part2/proc\_part2.srcs/sources\_1/new/inst\_data.mem",inst\_mem);
end

////////////////////////////////////////////////////
//////////reading instructions one after another
reg \[2:0\] count \= 0;
integer PC \= 0;

always@(posedge clk)
begin
 if(sys\_rst)
  begin
    count \<= 0;
    PC    \<= 0;
  end
  else
  begin
    if(count \< 4\)
    begin
    count \<= count \+ 1;
    end
    else
    begin
    count \<= 0;
    PC    \<= PC \+ 1;
    end
end
end
////////////////////////////////////////////////////
/////////reading instructions

always@(\*)
begin
if(sys\_rst \== 1'b1)
IR \= 0;
else
begin
IR \= inst\_mem\[PC\];
decode\_inst();
decode\_condflag();
end
end

////////////////////////////////////////////////////


endmodule
module tb;


integer i \= 0;

reg clk \= 0,sys\_rst \= 0;
reg \[15:0\] din \= 0;
wire \[15:0\] dout;


top dut(clk, sys\_rst, din, dout);

always \#5 clk \= \~clk;

initial begin
sys\_rst \= 1'b1;
repeat(5) @(posedge clk);
sys\_rst \= 1'b0;
\#800;
$stop;
end

endmodule

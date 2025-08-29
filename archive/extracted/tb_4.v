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


module top();






reg \[31:0\] IR;            ////// instruction register  \<--ir\[31:27\]--\>\<--ir\[26:22\]--\>\<--ir\[21:17\]--\>\<--ir\[16\]--\>\<--ir\[15:11\]--\>\<--ir\[10:0\]--\>
                         //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  rsrc2 \--\>\<--unused  \--\>
                         //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  immediate\_date      \--\>

reg \[15:0\] GPR \[31:0\] ;   ///////general purpose register gpr\[0\] ....... gpr\[31\]



reg \[15:0\] SGPR ;      ///// msb of multiplication \--\> special register

reg \[31:0\] mul\_res;



always@(\*)
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

endcase
end



///////////////////////logic for condition flag
reg sign \= 0, zero \= 0, overflow \= 0, carry \= 0;
reg \[16:0\] temp\_sum;

always@(\*)
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
if(`oper\_type \== `mul)
 zero \=  \~((|SGPR\[15:0\]) | (|GPR\[`rdst\]));
else
 zero \=  \~(|GPR\[`rdst\]);


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



endmodule

////////////////////////////////////////////////////////////////////////////

module tb;


integer i \= 0;

top dut();

///////////////updating value of all GPR to 2
initial begin
for( i \= 0; i \< 32; i \= i \+ 1\)
begin
dut.GPR\[i\] \= 2;
end
end



initial begin
//////// immediate add op
$display("-----------------------------------------------------------------");
dut.IR \= 0;
dut.`imm\_mode \= 1;
dut.`oper\_type \= 2;
dut.`rsrc1 \= 2;///gpr\[2\] \= 2
dut.`rdst  \= 0;///gpr\[0\]
dut.`isrc \= 4;
\#10;
$display("OP:ADI Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[2\], dut.`isrc, dut.GPR\[0\]);
$display("-----------------------------------------------------------------");
////////////register add op
dut.IR \= 0;
dut.`imm\_mode \= 0;
dut.`oper\_type \= 2;
dut.`rsrc1 \= 4;
dut.`rsrc2 \= 5;
dut.`rdst  \= 0;
\#10;
$display("OP:ADD Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[4\], dut.GPR\[5\], dut.GPR\[0\] );
$display("-----------------------------------------------------------------");

//////////////////////immediate mov op
dut.IR \= 0;
dut.`imm\_mode \= 1;
dut.`oper\_type \= 1;
dut.`rdst \= 4;///gpr\[4\]
dut.`isrc \= 55;
\#10;
$display("OP:MOVI Rdst:%0d  imm\_data:%0d",dut.GPR\[4\],dut.`isrc  );
$display("-----------------------------------------------------------------");

//////////////////register mov
dut.IR \= 0;
dut.`imm\_mode \= 0;
dut.`oper\_type \= 1;
dut.`rdst \= 4;
dut.`rsrc1 \= 7;//gpr\[7\]
\#10;
$display("OP:MOV Rdst:%0d  Rsrc1:%0d",dut.GPR\[4\],dut.GPR\[7\] );
$display("-----------------------------------------------------------------");





//////////////////////logical and imm
dut.IR \= 0;
dut.`imm\_mode \= 1;
dut.`oper\_type \= 6;
dut.`rdst \= 4;
dut.`rsrc1 \= 7;//gpr\[7\]
dut.`isrc \= 56;
\#10;
$display("OP:ANDI Rdst:%8b  Rsrc1:%8b imm\_d :%8b",dut.GPR\[4\],dut.GPR\[7\],dut.`isrc );
$display("-----------------------------------------------------------------");

///////////////////logical xor imm
dut.IR \= 0;
dut.`imm\_mode \= 1;
dut.`oper\_type \= 7;
dut.`rdst \= 4;
dut.`rsrc1 \= 7;//gpr\[7\]
dut.`isrc \= 56;
\#10;
$display("OP:XORI Rdst:%8b  Rsrc1:%8b imm\_d :%8b",dut.GPR\[4\],dut.GPR\[7\],dut.`isrc );
$display("-----------------------------------------------------------------");

/////////////////////////// zero flag
dut.IR  \= 0;
dut.GPR\[0\] \= 0;
dut.GPR\[1\] \= 0;
dut.`imm\_mode \= 0;
dut.`rsrc1 \= 0;//gpr\[0\]
dut.`rsrc2 \= 1;//gpr\[1\]
dut.`oper\_type \= 2;
dut.`rdst \= 2;
\#10;
$display("OP:Zero Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[0\], dut.GPR\[1\], dut.GPR\[2\] );
$display("-----------------------------------------------------------------");

//////////////////////////sign flag
dut.IR \= 0;
dut.GPR\[0\] \= 16'h8000; /////1000\_0000\_0000\_0000
dut.GPR\[1\] \= 0;
dut.`imm\_mode \= 0;
dut.`rsrc1 \= 0;//gpr\[0\]
dut.`rsrc2 \= 1;//gpr\[1\]
dut.`oper\_type \= 2;
dut.`rdst \= 2;
\#10;
$display("OP:Sign Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[0\], dut.GPR\[1\], dut.GPR\[2\] );
$display("-----------------------------------------------------------------");

////////////////////////carry flag
dut.IR \= 0;
dut.GPR\[0\] \= 16'h8000; /////1000\_0000\_0000\_0000   \<0
dut.GPR\[1\] \= 16'h8002; /////1000\_0000\_0000\_0010   \<0
dut.`imm\_mode \= 0;
dut.`rsrc1 \= 0;//gpr\[0\]
dut.`rsrc2 \= 1;//gpr\[1\]
dut.`oper\_type \= 2;
dut.`rdst \= 2;    //////// 0000\_0000\_0000\_0010  \>0
\#10;

$display("OP:Carry & Overflow Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[0\], dut.GPR\[1\], dut.GPR\[2\] );
$display("-----------------------------------------------------------------");

\#20;
$finish;
end

endmodule

module tb;


reg clk \= 0, wea \= 0;
reg \[10:0\] addr;
reg \[31:0\] din;
wire \[31:0\] dout;



blk\_mem\_gen\_0 dut (clk, wea, addr, din, dout);

reg \[31:0\] IR;

always \#5 clk \= \~clk;

integer count \= 0;

integer delay \= 0;

always@(posedge clk)
begin
if(delay \< 4\)
begin
addr \<= count;
IR   \<= dout;
delay \<= delay \+ 1;
end
else
begin
count \<= count \+ 1;
delay \<= 0;
end
end

endmodule

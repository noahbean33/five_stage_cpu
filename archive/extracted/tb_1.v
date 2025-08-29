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

/////////////////////////////////////////////////////////////
endcase
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


end

endmodule

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
endmodule

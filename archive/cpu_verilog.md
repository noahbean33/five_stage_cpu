* \`timescale 1ns / 1ps  
*    
* ///////////fields of IR  
* \`define oper\_type IR\[31:27\]  
* \`define rdst      IR\[26:22\]  
* \`define rsrc1     IR\[21:17\]  
* \`define imm\_mode  IR\[16\]  
* \`define rsrc2     IR\[15:11\]  
* \`define isrc      IR\[15:0\]  
*    
*    
* ////////////////arithmetic operation  
* \`define movsgpr        5'b00000  
* \`define mov            5'b00001  
* \`define add            5'b00010  
* \`define sub            5'b00011  
* \`define mul            5'b00100  
*    
*    
*    
*    
* module top();  
*    
*    
*    
*    
*    
*    
* reg \[31:0\] IR;            ////// instruction register  \<--ir\[31:27\]--\>\<--ir\[26:22\]--\>\<--ir\[21:17\]--\>\<--ir\[16\]--\>\<--ir\[15:11\]--\>\<--ir\[10:0\]--\>  
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  rsrc2 \--\>\<--unused  \--\>              
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  immediate\_date      \--\>       
*    
* reg \[15:0\] GPR \[31:0\] ;   ///////general purpose register gpr\[0\] ....... gpr\[31\]  
*    
*    
*    
* reg \[15:0\] SGPR ;      ///// msb of multiplication \--\> special register  
*    
* reg \[31:0\] mul\_res;  
*    
*    
*    
* always@(\*)  
* begin  
* case(\`oper\_type)  
* ///////////////////////////////  
* \`movsgpr: begin  
*    
*   GPR\[\`rdst\] \= SGPR;  
*    
* end  
*    
* /////////////////////////////////  
* \`mov : begin  
*   if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \`isrc;  
*   else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\];  
* end  
*    
* ////////////////////////////////////////////////////  
*    
* \`add : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ \`isrc;  
*     else  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////  
*    
* \`sub : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] \- \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \- GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`mul : begin  
*      if(\`imm\_mode)  
*        mul\_res   \= GPR\[\`rsrc1\] \* \`isrc;  
*     else  
*        mul\_res   \= GPR\[\`rsrc1\] \* GPR\[\`rsrc2\];  
*         
*     GPR\[\`rdst\]   \=  mul\_res\[15:0\];  
*     SGPR         \=  mul\_res\[31:16\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
* endcase  
* end  
* endmodule  
*    
* ////////////////////////////////////////////////////////////////////////////  
*    
* module tb;  
*    
*    
* integer i \= 0;  
*    
* top dut();  
*    
* ///////////////updating value of all GPR to 2  
* initial begin  
* for( i \= 0; i \< 32; i \= i \+ 1\)  
* begin  
* dut.GPR\[i\] \= 2;  
* end  
* end  
*    
*    
*    
* initial begin  
* //////// immediate add op  
* $display("-----------------------------------------------------------------");  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 2;  
* dut.\`rsrc1 \= 2;///gpr\[2\] \= 2  
* dut.\`rdst  \= 0;///gpr\[0\]  
* dut.\`isrc \= 4;  
* \#10;  
* $display("OP:ADI Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[2\], dut.\`isrc, dut.GPR\[0\]);  
* $display("-----------------------------------------------------------------");  
* ////////////register add op  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 0;  
* dut.\`oper\_type \= 2;  
* dut.\`rsrc1 \= 4;  
* dut.\`rsrc2 \= 5;  
* dut.\`rdst  \= 0;  
* \#10;  
* $display("OP:ADD Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[4\], dut.GPR\[5\], dut.GPR\[0\] );  
* $display("-----------------------------------------------------------------");  
*    
* //////////////////////immediate mov op  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 1;  
* dut.\`rdst \= 4;///gpr\[4\]  
* dut.\`isrc \= 55;  
* \#10;  
* $display("OP:MOVI Rdst:%0d  imm\_data:%0d",dut.GPR\[4\],dut.\`isrc  );  
* $display("-----------------------------------------------------------------");  
*    
* //////////////////register mov  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 0;  
* dut.\`oper\_type \= 1;  
* dut.\`rdst \= 4;  
* dut.\`rsrc1 \= 7;//gpr\[7\]  
* \#10;  
* $display("OP:MOV Rdst:%0d  Rsrc1:%0d",dut.GPR\[4\],dut.GPR\[7\] );  
* $display("-----------------------------------------------------------------");  
*    
*    
* end  
*    
* endmodule

* \`timescale 1ns / 1ps  
*    
* ///////////fields of IR  
* \`define oper\_type IR\[31:27\]  
* \`define rdst      IR\[26:22\]  
* \`define rsrc1     IR\[21:17\]  
* \`define imm\_mode  IR\[16\]  
* \`define rsrc2     IR\[15:11\]  
* \`define isrc      IR\[15:0\]  
*    
*    
* ////////////////arithmetic operation  
* \`define movsgpr        5'b00000  
* \`define mov            5'b00001  
* \`define add            5'b00010  
* \`define sub            5'b00011  
* \`define mul            5'b00100  
*    
* ////////////////logical operations : and or xor xnor nand nor not  
*    
* \`define ror            5'b00101  
* \`define rand           5'b00110  
* \`define rxor           5'b00111  
* \`define rxnor          5'b01000  
* \`define rnand          5'b01001  
* \`define rnor           5'b01010  
* \`define rnot           5'b01011  
*    
*    
* module top();  
*    
*    
*    
*    
*    
*    
* reg \[31:0\] IR;            ////// instruction register  \<--ir\[31:27\]--\>\<--ir\[26:22\]--\>\<--ir\[21:17\]--\>\<--ir\[16\]--\>\<--ir\[15:11\]--\>\<--ir\[10:0\]--\>  
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  rsrc2 \--\>\<--unused  \--\>              
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  immediate\_date      \--\>       
*    
* reg \[15:0\] GPR \[31:0\] ;   ///////general purpose register gpr\[0\] ....... gpr\[31\]  
*    
*    
*    
* reg \[15:0\] SGPR ;      ///// msb of multiplication \--\> special register  
*    
* reg \[31:0\] mul\_res;  
*    
*    
*    
* always@(\*)  
* begin  
* case(\`oper\_type)  
* ///////////////////////////////  
* \`movsgpr: begin  
*    
*   GPR\[\`rdst\] \= SGPR;  
*    
* end  
*    
* /////////////////////////////////  
* \`mov : begin  
*   if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \`isrc;  
*   else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\];  
* end  
*    
* ////////////////////////////////////////////////////  
*    
* \`add : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ \`isrc;  
*     else  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////  
*    
* \`sub : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] \- \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \- GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`mul : begin  
*      if(\`imm\_mode)  
*        mul\_res   \= GPR\[\`rsrc1\] \* \`isrc;  
*     else  
*        mul\_res   \= GPR\[\`rsrc1\] \* GPR\[\`rsrc2\];  
*         
*     GPR\[\`rdst\]   \=  mul\_res\[15:0\];  
*     SGPR         \=  mul\_res\[31:16\];  
* end  
*    
* ///////////////////////////////////////////////////////////// bitwise or  
*    
* \`ror : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] | \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] | GPR\[\`rsrc2\];  
* end  
*    
* ////////////////////////////////////////////////////////////bitwise and  
*    
* \`rand : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] & \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] & GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwise xor  
*    
* \`rxor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] ^ \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] ^ GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwise xnor  
*    
* \`rxnor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] \~^ \`isrc;  
*     else  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \~^ GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwisw nand  
*    
* \`rnand : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(GPR\[\`rsrc1\] & \`isrc);  
*     else  
*       GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\] & GPR\[\`rsrc2\]);  
* end  
*    
* ////////////////////////////////////////////////////////////bitwise nor  
*    
* \`rnor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(GPR\[\`rsrc1\] | \`isrc);  
*     else  
*       GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\] | GPR\[\`rsrc2\]);  
* end  
*    
* ////////////////////////////////////////////////////////////not  
*    
* \`rnot : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(\`isrc);  
*     else  
*        GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\]);  
* end  
*    
* ////////////////////////////////////////////////////////////  
*    
* endcase  
* end  
* endmodule  
*    
* ////////////////////////////////////////////////////////////////////////////  
*    
* module tb;  
*    
*    
* integer i \= 0;  
*    
* top dut();  
*    
* ///////////////updating value of all GPR to 2  
* initial begin  
* for( i \= 0; i \< 32; i \= i \+ 1\)  
* begin  
* dut.GPR\[i\] \= 2;  
* end  
* end  
*    
*    
*    
* initial begin  
* //////// immediate add op  
* $display("-----------------------------------------------------------------");  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 2;  
* dut.\`rsrc1 \= 2;///gpr\[2\] \= 2  
* dut.\`rdst  \= 0;///gpr\[0\]  
* dut.\`isrc \= 4;  
* \#10;  
* $display("OP:ADI Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[2\], dut.\`isrc, dut.GPR\[0\]);  
* $display("-----------------------------------------------------------------");  
* ////////////register add op  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 0;  
* dut.\`oper\_type \= 2;  
* dut.\`rsrc1 \= 4;  
* dut.\`rsrc2 \= 5;  
* dut.\`rdst  \= 0;  
* \#10;  
* $display("OP:ADD Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[4\], dut.GPR\[5\], dut.GPR\[0\] );  
* $display("-----------------------------------------------------------------");  
*    
* //////////////////////immediate mov op  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 1;  
* dut.\`rdst \= 4;///gpr\[4\]  
* dut.\`isrc \= 55;  
* \#10;  
* $display("OP:MOVI Rdst:%0d  imm\_data:%0d",dut.GPR\[4\],dut.\`isrc  );  
* $display("-----------------------------------------------------------------");  
*    
* //////////////////register mov  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 0;  
* dut.\`oper\_type \= 1;  
* dut.\`rdst \= 4;  
* dut.\`rsrc1 \= 7;//gpr\[7\]  
* \#10;  
* $display("OP:MOV Rdst:%0d  Rsrc1:%0d",dut.GPR\[4\],dut.GPR\[7\] );  
* $display("-----------------------------------------------------------------");  
*    
* //////////////////////logical and imm  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 6;  
* dut.\`rdst \= 4;  
* dut.\`rsrc1 \= 7;//gpr\[7\]  
* dut.\`isrc \= 56;  
* \#10;  
* $display("OP:ANDI Rdst:%8b  Rsrc1:%8b imm\_d :%8b",dut.GPR\[4\],dut.GPR\[7\],dut.\`isrc );  
* $display("-----------------------------------------------------------------");  
*    
* ///////////////////logical or imm  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 7;  
* dut.\`rdst \= 4;  
* dut.\`rsrc1 \= 7;//gpr\[7\]  
* dut.\`isrc \= 56;  
* \#10;  
* $display("OP:XORI Rdst:%8b  Rsrc1:%8b imm\_d :%8b",dut.GPR\[4\],dut.GPR\[7\],dut.\`isrc );  
* $display("-----------------------------------------------------------------");  
*    
*    
* end  
*    
* endmodule  
* \`timescale 1ns / 1ps  
*    
* ///////////fields of IR  
* \`define oper\_type IR\[31:27\]  
* \`define rdst      IR\[26:22\]  
* \`define rsrc1     IR\[21:17\]  
* \`define imm\_mode  IR\[16\]  
* \`define rsrc2     IR\[15:11\]  
* \`define isrc      IR\[15:0\]  
*    
*    
* ////////////////arithmetic operation  
* \`define movsgpr        5'b00000  
* \`define mov            5'b00001  
* \`define add            5'b00010  
* \`define sub            5'b00011  
* \`define mul            5'b00100  
*    
* ////////////////logical operations : and or xor xnor nand nor not  
*    
* \`define ror            5'b00101  
* \`define rand           5'b00110  
* \`define rxor           5'b00111  
* \`define rxnor          5'b01000  
* \`define rnand          5'b01001  
* \`define rnor           5'b01010  
* \`define rnot           5'b01011  
*    
*    
* module top();  
*    
*    
*    
*    
*    
*    
* reg \[31:0\] IR;            ////// instruction register  \<--ir\[31:27\]--\>\<--ir\[26:22\]--\>\<--ir\[21:17\]--\>\<--ir\[16\]--\>\<--ir\[15:11\]--\>\<--ir\[10:0\]--\>  
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  rsrc2 \--\>\<--unused  \--\>              
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  immediate\_date      \--\>       
*    
* reg \[15:0\] GPR \[31:0\] ;   ///////general purpose register gpr\[0\] ....... gpr\[31\]  
*    
*    
*    
* reg \[15:0\] SGPR ;      ///// msb of multiplication \--\> special register  
*    
* reg \[31:0\] mul\_res;  
*    
*    
*    
* always@(\*)  
* begin  
* case(\`oper\_type)  
* ///////////////////////////////  
* \`movsgpr: begin  
*    
*   GPR\[\`rdst\] \= SGPR;  
*    
* end  
*    
* /////////////////////////////////  
* \`mov : begin  
*   if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \`isrc;  
*   else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\];  
* end  
*    
* ////////////////////////////////////////////////////  
*    
* \`add : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ \`isrc;  
*     else  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////  
*    
* \`sub : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] \- \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \- GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`mul : begin  
*      if(\`imm\_mode)  
*        mul\_res   \= GPR\[\`rsrc1\] \* \`isrc;  
*     else  
*        mul\_res   \= GPR\[\`rsrc1\] \* GPR\[\`rsrc2\];  
*         
*     GPR\[\`rdst\]   \=  mul\_res\[15:0\];  
*     SGPR         \=  mul\_res\[31:16\];  
* end  
*    
* ///////////////////////////////////////////////////////////// bitwise or  
*    
* \`ror : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] | \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] | GPR\[\`rsrc2\];  
* end  
*    
* ////////////////////////////////////////////////////////////bitwise and  
*    
* \`rand : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] & \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] & GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwise xor  
*    
* \`rxor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] ^ \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] ^ GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwise xnor  
*    
* \`rxnor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] \~^ \`isrc;  
*     else  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \~^ GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwisw nand  
*    
* \`rnand : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(GPR\[\`rsrc1\] & \`isrc);  
*     else  
*       GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\] & GPR\[\`rsrc2\]);  
* end  
*    
* ////////////////////////////////////////////////////////////bitwise nor  
*    
* \`rnor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(GPR\[\`rsrc1\] | \`isrc);  
*     else  
*       GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\] | GPR\[\`rsrc2\]);  
* end  
*    
* ////////////////////////////////////////////////////////////not  
*    
* \`rnot : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(\`isrc);  
*     else  
*        GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\]);  
* end  
*    
* ////////////////////////////////////////////////////////////  
*    
* endcase  
* end  
*    
*    
*    
* ///////////////////////logic for condition flag  
* reg sign \= 0, zero \= 0, overflow \= 0, carry \= 0;  
* reg \[16:0\] temp\_sum;  
*    
* always@(\*)  
* begin  
*    
* /////////////////sign bit  
* if(\`oper\_type \== \`mul)  
*  sign \= SGPR\[15\];  
* else  
*  sign \= GPR\[\`rdst\]\[15\];  
*    
* ////////////////carry bit  
*    
* if(\`oper\_type \== \`add)  
*   begin  
*      if(\`imm\_mode)  
*         begin  
*         temp\_sum \= GPR\[\`rsrc1\] \+ \`isrc;  
*         carry    \= temp\_sum\[16\];  
*         end  
*      else  
*         begin  
*         temp\_sum \= GPR\[\`rsrc1\] \+ GPR\[\`rsrc2\];  
*         carry    \= temp\_sum\[16\];  
*         end   end  
*   else  
*    begin  
*        carry  \= 1'b0;  
*    end  
*    
* ///////////////////// zero bit  
* if(\`oper\_type \== \`mul)  
*  zero \=  \~((|SGPR\[15:0\]) | (|GPR\[\`rdst\]));  
* else  
*  zero \=  \~(|GPR\[\`rdst\]);  
*    
*    
* //////////////////////overflow bit  
*    
* if(\`oper\_type \== \`add)  
*     begin  
*       if(\`imm\_mode)  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & \~IR\[15\] & GPR\[\`rdst\]\[15\] ) | (GPR\[\`rsrc1\]\[15\] & IR\[15\] & \~GPR\[\`rdst\]\[15\]) );  
*       else  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & \~GPR\[\`rsrc2\]\[15\] & GPR\[\`rdst\]\[15\]) | (GPR\[\`rsrc1\]\[15\] & GPR\[\`rsrc2\]\[15\] & \~GPR\[\`rdst\]\[15\]));  
*     end  
*  else if(\`oper\_type \== \`sub)  
*    begin  
*       if(\`imm\_mode)  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & IR\[15\] & GPR\[\`rdst\]\[15\] ) | (GPR\[\`rsrc1\]\[15\] & \~IR\[15\] & \~GPR\[\`rdst\]\[15\]) );  
*       else  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & GPR\[\`rsrc2\]\[15\] & GPR\[\`rdst\]\[15\]) | (GPR\[\`rsrc1\]\[15\] & \~GPR\[\`rsrc2\]\[15\] & \~GPR\[\`rdst\]\[15\]));  
*    end  
*  else  
*     begin  
*     overflow \= 1'b0;  
*     end  
*    
* end  
*    
*    
*    
* endmodule  
*    
* ////////////////////////////////////////////////////////////////////////////  
*    
* module tb;  
*    
*    
* integer i \= 0;  
*    
* top dut();  
*    
* ///////////////updating value of all GPR to 2  
* initial begin  
* for( i \= 0; i \< 32; i \= i \+ 1\)  
* begin  
* dut.GPR\[i\] \= 2;  
* end  
* end  
*    
*    
*    
* initial begin  
* //////// immediate add op  
* $display("-----------------------------------------------------------------");  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 2;  
* dut.\`rsrc1 \= 2;///gpr\[2\] \= 2  
* dut.\`rdst  \= 0;///gpr\[0\]  
* dut.\`isrc \= 4;  
* \#10;  
* $display("OP:ADI Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[2\], dut.\`isrc, dut.GPR\[0\]);  
* $display("-----------------------------------------------------------------");  
* ////////////register add op  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 0;  
* dut.\`oper\_type \= 2;  
* dut.\`rsrc1 \= 4;  
* dut.\`rsrc2 \= 5;  
* dut.\`rdst  \= 0;  
* \#10;  
* $display("OP:ADD Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[4\], dut.GPR\[5\], dut.GPR\[0\] );  
* $display("-----------------------------------------------------------------");  
*    
* //////////////////////immediate mov op  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 1;  
* dut.\`rdst \= 4;///gpr\[4\]  
* dut.\`isrc \= 55;  
* \#10;  
* $display("OP:MOVI Rdst:%0d  imm\_data:%0d",dut.GPR\[4\],dut.\`isrc  );  
* $display("-----------------------------------------------------------------");  
*    
* //////////////////register mov  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 0;  
* dut.\`oper\_type \= 1;  
* dut.\`rdst \= 4;  
* dut.\`rsrc1 \= 7;//gpr\[7\]  
* \#10;  
* $display("OP:MOV Rdst:%0d  Rsrc1:%0d",dut.GPR\[4\],dut.GPR\[7\] );  
* $display("-----------------------------------------------------------------");  
*    
*    
*    
*    
*    
* //////////////////////logical and imm  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 6;  
* dut.\`rdst \= 4;  
* dut.\`rsrc1 \= 7;//gpr\[7\]  
* dut.\`isrc \= 56;  
* \#10;  
* $display("OP:ANDI Rdst:%8b  Rsrc1:%8b imm\_d :%8b",dut.GPR\[4\],dut.GPR\[7\],dut.\`isrc );  
* $display("-----------------------------------------------------------------");  
*    
* ///////////////////logical xor imm  
* dut.IR \= 0;  
* dut.\`imm\_mode \= 1;  
* dut.\`oper\_type \= 7;  
* dut.\`rdst \= 4;  
* dut.\`rsrc1 \= 7;//gpr\[7\]  
* dut.\`isrc \= 56;  
* \#10;  
* $display("OP:XORI Rdst:%8b  Rsrc1:%8b imm\_d :%8b",dut.GPR\[4\],dut.GPR\[7\],dut.\`isrc );  
* $display("-----------------------------------------------------------------");  
*    
* /////////////////////////// zero flag  
* dut.IR  \= 0;  
* dut.GPR\[0\] \= 0;  
* dut.GPR\[1\] \= 0;  
* dut.\`imm\_mode \= 0;  
* dut.\`rsrc1 \= 0;//gpr\[0\]  
* dut.\`rsrc2 \= 1;//gpr\[1\]  
* dut.\`oper\_type \= 2;  
* dut.\`rdst \= 2;  
* \#10;  
* $display("OP:Zero Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[0\], dut.GPR\[1\], dut.GPR\[2\] );  
* $display("-----------------------------------------------------------------");  
*    
* //////////////////////////sign flag  
* dut.IR \= 0;  
* dut.GPR\[0\] \= 16'h8000; /////1000\_0000\_0000\_0000  
* dut.GPR\[1\] \= 0;  
* dut.\`imm\_mode \= 0;  
* dut.\`rsrc1 \= 0;//gpr\[0\]  
* dut.\`rsrc2 \= 1;//gpr\[1\]  
* dut.\`oper\_type \= 2;  
* dut.\`rdst \= 2;  
* \#10;  
* $display("OP:Sign Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[0\], dut.GPR\[1\], dut.GPR\[2\] );  
* $display("-----------------------------------------------------------------");  
*    
* ////////////////////////carry flag  
* dut.IR \= 0;  
* dut.GPR\[0\] \= 16'h8000; /////1000\_0000\_0000\_0000   \<0  
* dut.GPR\[1\] \= 16'h8002; /////1000\_0000\_0000\_0010   \<0  
* dut.\`imm\_mode \= 0;  
* dut.\`rsrc1 \= 0;//gpr\[0\]  
* dut.\`rsrc2 \= 1;//gpr\[1\]  
* dut.\`oper\_type \= 2;  
* dut.\`rdst \= 2;    //////// 0000\_0000\_0000\_0010  \>0  
* \#10;  
*    
* $display("OP:Carry & Overflow Rsrc1:%0d  Rsrc2:%0d Rdst:%0d",dut.GPR\[0\], dut.GPR\[1\], dut.GPR\[2\] );  
* $display("-----------------------------------------------------------------");  
*    
* \#20;  
* $finish;  
* end  
*    
* endmodule

* module tb;  
*    
*    
* reg clk \= 0, wea \= 0;  
* reg \[10:0\] addr;  
* reg \[31:0\] din;  
* wire \[31:0\] dout;  
*    
*    
*    
* blk\_mem\_gen\_0 dut (clk, wea, addr, din, dout);  
*    
* reg \[31:0\] IR;  
*    
* always \#5 clk \= \~clk;  
*    
* integer count \= 0;  
*    
* integer delay \= 0;  
*    
* always@(posedge clk)  
* begin  
* if(delay \< 4\)  
* begin  
* addr \<= count;  
* IR   \<= dout;  
* delay \<= delay \+ 1;  
* end  
* else  
* begin  
* count \<= count \+ 1;  
* delay \<= 0;  
* end  
* end  
*    
* endmodule

memory\_initialization\_radix=2;

memory\_initialization\_vector=

00000000000000010000000000001111,

00000000010000010000000011111111,

00100000100000000000100000000000,

01101000000000000001000000000000,

00101000100000000000100000000000,

01101000000000010001000000000000,

00110000100000000000100000000000,

01101000000000100001000000000000,

01011000000000010001100000000000;

* module tb;  
*    
*    
* reg clk \= 0, wea \= 0;  
* reg \[10:0\] addr;  
* reg \[31:0\] din;  
* wire \[31:0\] dout;  
*    
* reg \[31:0\] mem \[15:0\];  
*    
*    
*    
* initial begin  
* $readmemh("data.mem",mem);  
* ////$readmemb("", mem);  
* end  
*    
*    
* reg \[31:0\] IR;  
*    
* always \#5 clk \= \~clk;  
*    
* integer count \= 0;  
*    
* integer delay \= 0;  
*    
* always@(posedge clk)  
* begin  
* if(delay \< 4\)  
* begin  
* delay \<= delay \+ 1;  
* end  
* else  
* begin  
* count \<= count \+ 1;  
* delay \<= 0;  
* end  
* end  
*    
* always@(\*)  
* begin  
* IR \= mem\[count\];  
* end  
* endmodule  
* \`timescale 1ns / 1ps  
*    
* ///////////fields of IR  
* \`define oper\_type IR\[31:27\]  
* \`define rdst      IR\[26:22\]  
* \`define rsrc1     IR\[21:17\]  
* \`define imm\_mode  IR\[16\]  
* \`define rsrc2     IR\[15:11\]  
* \`define isrc      IR\[15:0\]  
*    
*    
* ////////////////arithmetic operation  
* \`define movsgpr        5'b00000  
* \`define mov            5'b00001  
* \`define add            5'b00010  
* \`define sub            5'b00011  
* \`define mul            5'b00100  
*    
* ////////////////logical operations : and or xor xnor nand nor not  
*    
* \`define ror            5'b00101  
* \`define rand           5'b00110  
* \`define rxor           5'b00111  
* \`define rxnor          5'b01000  
* \`define rnand          5'b01001  
* \`define rnor           5'b01010  
* \`define rnot           5'b01011  
*    
* /////////////////////// load & store instructions  
*    
* \`define storereg       5'b01101   //////store content of register in data memory  
* \`define storedin       5'b01110   ////// store content of din bus in data memory  
* \`define senddout       5'b01111   /////send data from DM to dout bus  
* \`define sendreg        5'b10001   ////// send data from DM to register  
*    
*    
*    
* module top(  
* input clk,sys\_rst,  
* input \[15:0\] din,  
* output reg \[15:0\] dout  
* );  
*    
* ////////////////adding program and data memory  
* reg \[31:0\] inst\_mem \[15:0\]; ////program memory  
* reg \[15:0\] data\_mem \[15:0\]; ////data memory  
*    
*    
*    
*    
*    
* reg \[31:0\] IR;            ////// instruction register  \<--ir\[31:27\]--\>\<--ir\[26:22\]--\>\<--ir\[21:17\]--\>\<--ir\[16\]--\>\<--ir\[15:11\]--\>\<--ir\[10:0\]--\>  
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  rsrc2 \--\>\<--unused  \--\>              
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  immediate\_date      \--\>   2^15    
*    
* reg \[15:0\] GPR \[31:0\] ;   ///////general purpose register gpr\[0\] ....... gpr\[31\]  
*    
*    
*    
* reg \[15:0\] SGPR ;      ///// msb of multiplication \--\> special register  
*    
* reg \[31:0\] mul\_res;  
*    
*    
*    
*    
*    
*    
*    
*    
* task decode\_inst();  
* begin  
* case(\`oper\_type)  
* ///////////////////////////////  
* \`movsgpr: begin  
*    
*   GPR\[\`rdst\] \= SGPR;  
*    
* end  
*    
* /////////////////////////////////  
* \`mov : begin  
*   if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \`isrc;  
*   else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\];  
* end  
*    
* ////////////////////////////////////////////////////  
*    
* \`add : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ \`isrc;  
*     else  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////  
*    
* \`sub : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] \- \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \- GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`mul : begin  
*      if(\`imm\_mode)  
*        mul\_res   \= GPR\[\`rsrc1\] \* \`isrc;  
*     else  
*        mul\_res   \= GPR\[\`rsrc1\] \* GPR\[\`rsrc2\];  
*         
*     GPR\[\`rdst\]   \=  mul\_res\[15:0\];  
*     SGPR         \=  mul\_res\[31:16\];  
* end  
*    
* ///////////////////////////////////////////////////////////// bitwise or  
*    
* \`ror : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] | \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] | GPR\[\`rsrc2\];  
* end  
*    
* ////////////////////////////////////////////////////////////bitwise and  
*    
* \`rand : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] & \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] & GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwise xor  
*    
* \`rxor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] ^ \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] ^ GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwise xnor  
*    
* \`rxnor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] \~^ \`isrc;  
*     else  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \~^ GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwisw nand  
*    
* \`rnand : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(GPR\[\`rsrc1\] & \`isrc);  
*     else  
*       GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\] & GPR\[\`rsrc2\]);  
* end  
*    
* ////////////////////////////////////////////////////////////bitwise nor  
*    
* \`rnor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(GPR\[\`rsrc1\] | \`isrc);  
*     else  
*       GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\] | GPR\[\`rsrc2\]);  
* end  
*    
* ////////////////////////////////////////////////////////////not  
*    
* \`rnot : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(\`isrc);  
*     else  
*        GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\]);  
* end  
*    
* ////////////////////////////////////////////////////////////  
*    
* \`storedin: begin  
*   data\_mem\[\`isrc\] \= din;  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`storereg: begin  
*   data\_mem\[\`isrc\] \= GPR\[\`rsrc1\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
*    
* \`senddout: begin  
*   dout  \= data\_mem\[\`isrc\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`sendreg: begin  
*  GPR\[\`rdst\] \=  data\_mem\[\`isrc\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
* endcase  
* end  
* endtask  
*    
*    
*    
* ///////////////////////logic for condition flag  
* reg sign \= 0, zero \= 0, overflow \= 0, carry \= 0;  
* reg \[16:0\] temp\_sum;  
*    
* task decode\_condflag();  
* begin  
*    
* /////////////////sign bit  
* if(\`oper\_type \== \`mul)  
*  sign \= SGPR\[15\];  
* else  
*  sign \= GPR\[\`rdst\]\[15\];  
*    
* ////////////////carry bit  
*    
* if(\`oper\_type \== \`add)  
*   begin  
*      if(\`imm\_mode)  
*         begin  
*         temp\_sum \= GPR\[\`rsrc1\] \+ \`isrc;  
*         carry    \= temp\_sum\[16\];  
*         end  
*      else  
*         begin  
*         temp\_sum \= GPR\[\`rsrc1\] \+ GPR\[\`rsrc2\];  
*         carry    \= temp\_sum\[16\];  
*         end   end  
*   else  
*    begin  
*        carry  \= 1'b0;  
*    end  
*    
* ///////////////////// zero bit  
*    
* zero \=  ( \~(|GPR\[\`rdst\]) | \~(|SGPR\[15:0\]) )  ;  
*    
*    
* //////////////////////overflow bit  
*    
* if(\`oper\_type \== \`add)  
*     begin  
*       if(\`imm\_mode)  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & \~IR\[15\] & GPR\[\`rdst\]\[15\] ) | (GPR\[\`rsrc1\]\[15\] & IR\[15\] & \~GPR\[\`rdst\]\[15\]) );  
*       else  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & \~GPR\[\`rsrc2\]\[15\] & GPR\[\`rdst\]\[15\]) | (GPR\[\`rsrc1\]\[15\] & GPR\[\`rsrc2\]\[15\] & \~GPR\[\`rdst\]\[15\]));  
*     end  
*  else if(\`oper\_type \== \`sub)  
*    begin  
*       if(\`imm\_mode)  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & IR\[15\] & GPR\[\`rdst\]\[15\] ) | (GPR\[\`rsrc1\]\[15\] & \~IR\[15\] & \~GPR\[\`rdst\]\[15\]) );  
*       else  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & GPR\[\`rsrc2\]\[15\] & GPR\[\`rdst\]\[15\]) | (GPR\[\`rsrc1\]\[15\] & \~GPR\[\`rsrc2\]\[15\] & \~GPR\[\`rdst\]\[15\]));  
*    end  
*  else  
*     begin  
*     overflow \= 1'b0;  
*     end  
*    
* end  
* endtask  
*    
*    
*    
*    
*    
* ////////////////////////////////////////////////////////////////////////////////////////////////////////////  
*    
* /////////////////////////////////////////////  
* ///////////reading program  
*    
* initial begin  
* $readmemb("C:/Users/kumar/proc\_part2/proc\_part2.srcs/sources\_1/new/inst\_data.mem",inst\_mem);  
* end  
*    
* ////////////////////////////////////////////////////  
* //////////reading instructions one after another  
* reg \[2:0\] count \= 0;  
* integer PC \= 0;  
*    
* always@(posedge clk)  
* begin  
*  if(sys\_rst)  
*   begin  
*     count \<= 0;  
*     PC    \<= 0;  
*   end  
*   else  
*   begin  
*     if(count \< 4\)  
*     begin  
*     count \<= count \+ 1;  
*     end  
*     else  
*     begin  
*     count \<= 0;  
*     PC    \<= PC \+ 1;  
*     end  
* end  
* end  
* ////////////////////////////////////////////////////  
* /////////reading instructions  
*    
* always@(\*)  
* begin  
* if(sys\_rst \== 1'b1)  
* IR \= 0;  
* else  
* begin  
* IR \= inst\_mem\[PC\];  
* decode\_inst();  
* decode\_condflag();  
* end  
* end  
*    
* ////////////////////////////////////////////////////  
*    
*    
* endmodule  
* module tb;  
*    
*    
* integer i \= 0;  
*    
* reg clk \= 0,sys\_rst \= 0;  
* reg \[15:0\] din \= 0;  
* wire \[15:0\] dout;  
*    
*    
* top dut(clk, sys\_rst, din, dout);  
*    
* always \#5 clk \= \~clk;  
*    
* initial begin  
* sys\_rst \= 1'b1;  
* repeat(5) @(posedge clk);  
* sys\_rst \= 1'b0;  
* \#800;  
* $stop;  
* end  
*    
* endmodule  
* \`timescale 1ns / 1ps  
*    
* ///////////fields of IR  
* \`define oper\_type IR\[31:27\]  
* \`define rdst      IR\[26:22\]  
* \`define rsrc1     IR\[21:17\]  
* \`define imm\_mode  IR\[16\]  
* \`define rsrc2     IR\[15:11\]  
* \`define isrc      IR\[15:0\]  
*    
*    
* ////////////////arithmetic operation  
* \`define movsgpr        5'b00000  
* \`define mov            5'b00001  
* \`define add            5'b00010  
* \`define sub            5'b00011  
* \`define mul            5'b00100  
*    
* ////////////////logical operations : and or xor xnor nand nor not  
*    
* \`define ror            5'b00101  
* \`define rand           5'b00110  
* \`define rxor           5'b00111  
* \`define rxnor          5'b01000  
* \`define rnand          5'b01001  
* \`define rnor           5'b01010  
* \`define rnot           5'b01011  
*    
* /////////////////////// load & store instructions  
*    
* \`define storereg       5'b01101   //////store content of register in data memory  
* \`define storedin       5'b01110   ////// store content of din bus in data memory  
* \`define senddout       5'b01111   /////send data from DM to dout bus  
* \`define sendreg        5'b10001   ////// send data from DM to register  
*    
* ///////////////////////////// Jump and branch instructions  
* \`define jump           5'b10010  ////jump to address  
* \`define jcarry         5'b10011  ////jump if carry  
* \`define jnocarry       5'b10100  
* \`define jsign          5'b10101  ////jump if sign  
* \`define jnosign        5'b10110  
* \`define jzero          5'b10111  //// jump if zero  
* \`define jnozero        5'b11000  
* \`define joverflow      5'b11001 ////jump if overflow  
* \`define jnooverflow    5'b11010  
*    
* //////////////////////////halt  
* \`define halt           5'b11011  
*    
*    
*    
* module top(  
* input clk,sys\_rst,  
* input \[15:0\] din,  
* output reg \[15:0\] dout  
* );  
*    
* ////////////////adding program and data memory  
* reg \[31:0\] inst\_mem \[15:0\]; ////program memory  
* reg \[15:0\] data\_mem \[15:0\]; ////data memory  
*    
*    
*    
*    
*    
* reg \[31:0\] IR;            ////// instruction register  \<--ir\[31:27\]--\>\<--ir\[26:22\]--\>\<--ir\[21:17\]--\>\<--ir\[16\]--\>\<--ir\[15:11\]--\>\<--ir\[10:0\]--\>  
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  rsrc2 \--\>\<--unused  \--\>              
*                          //////fields                 \<---  oper  \--\>\<--   rdest \--\>\<--   rsrc1 \--\>\<--modesel--\>\<--  immediate\_date      \--\>       
*    
* reg \[15:0\] GPR \[31:0\] ;   ///////general purpose register gpr\[0\] ....... gpr\[31\]  
*    
*    
*    
* reg \[15:0\] SGPR ;      ///// msb of multiplication \--\> special register  
*    
* reg \[31:0\] mul\_res;  
*    
*    
* reg sign \= 0, zero \= 0, overflow \= 0, carry \= 0; ///condition flag  
* reg \[16:0\] temp\_sum;  
*    
* reg jmp\_flag \= 0;  
* reg stop \= 0;  
*    
* task decode\_inst();  
* begin  
*    
* jmp\_flag \= 1'b0;  
* stop     \= 1'b0;  
*   
* case(\`oper\_type)  
* ///////////////////////////////  
* \`movsgpr: begin  
*    
*   GPR\[\`rdst\] \= SGPR;  
*    
* end  
*    
* /////////////////////////////////  
* \`mov : begin  
*   if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \`isrc;  
*   else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\];  
* end  
*    
* ////////////////////////////////////////////////////  
*    
* \`add : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ \`isrc;  
*     else  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \+ GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////  
*    
* \`sub : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] \- \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \- GPR\[\`rsrc2\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`mul : begin  
*      if(\`imm\_mode)  
*        mul\_res   \= GPR\[\`rsrc1\] \* \`isrc;  
*     else  
*        mul\_res   \= GPR\[\`rsrc1\] \* GPR\[\`rsrc2\];  
*         
*     GPR\[\`rdst\]   \=  mul\_res\[15:0\];  
*     SGPR         \=  mul\_res\[31:16\];  
* end  
*    
* ///////////////////////////////////////////////////////////// bitwise or  
*    
* \`ror : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] | \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] | GPR\[\`rsrc2\];  
* end  
*    
* ////////////////////////////////////////////////////////////bitwise and  
*    
* \`rand : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] & \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] & GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwise xor  
*    
* \`rxor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] ^ \`isrc;  
*     else  
*       GPR\[\`rdst\]   \= GPR\[\`rsrc1\] ^ GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwise xnor  
*    
* \`rxnor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= GPR\[\`rsrc1\] \~^ \`isrc;  
*     else  
*        GPR\[\`rdst\]   \= GPR\[\`rsrc1\] \~^ GPR\[\`rsrc2\];  
* end  
*    
* //////////////////////////////////////////////////////////// bitwisw nand  
*    
* \`rnand : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(GPR\[\`rsrc1\] & \`isrc);  
*     else  
*       GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\] & GPR\[\`rsrc2\]);  
* end  
*    
* ////////////////////////////////////////////////////////////bitwise nor  
*    
* \`rnor : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(GPR\[\`rsrc1\] | \`isrc);  
*     else  
*       GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\] | GPR\[\`rsrc2\]);  
* end  
*    
* ////////////////////////////////////////////////////////////not  
*    
* \`rnot : begin  
*      if(\`imm\_mode)  
*        GPR\[\`rdst\]  \= \~(\`isrc);  
*     else  
*        GPR\[\`rdst\]   \= \~(GPR\[\`rsrc1\]);  
* end  
*    
* ////////////////////////////////////////////////////////////  
*    
* \`storedin: begin  
*   data\_mem\[\`isrc\] \= din;  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`storereg: begin  
*   data\_mem\[\`isrc\] \= GPR\[\`rsrc1\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
*    
* \`senddout: begin  
*   dout  \= data\_mem\[\`isrc\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`sendreg: begin  
*  GPR\[\`rdst\] \=  data\_mem\[\`isrc\];  
* end  
*    
* /////////////////////////////////////////////////////////////  
*    
* \`jump: begin  
* jmp\_flag \= 1'b1;  
* end  
*    
* \`jcarry: begin  
*  if(carry \== 1'b1)  
*     jmp\_flag \= 1'b1;  
*   else  
*     jmp\_flag \= 1'b0;  
* end  
*    
* \`jsign: begin  
*  if(sign \== 1'b1)  
*     jmp\_flag \= 1'b1;  
*   else  
*     jmp\_flag \= 1'b0;  
* end  
*    
* \`jzero: begin  
*  if(zero \== 1'b1)  
*     jmp\_flag \= 1'b1;  
*   else  
*     jmp\_flag \= 1'b0;  
* end  
*    
*    
* \`joverflow: begin  
*  if(overflow \== 1'b1)  
*     jmp\_flag \= 1'b1;  
*   else  
*     jmp\_flag \= 1'b0;  
* end  
*    
* \`jnocarry: begin  
*  if(carry \== 1'b0)  
*     jmp\_flag \= 1'b1;  
*   else  
*     jmp\_flag \= 1'b0;  
* end  
*    
* \`jnosign: begin  
*  if(sign \== 1'b0)  
*     jmp\_flag \= 1'b1;  
*   else  
*     jmp\_flag \= 1'b0;  
* end  
*    
* \`jnozero: begin  
*  if(zero \== 1'b0)  
*     jmp\_flag \= 1'b1;  
*   else  
*     jmp\_flag \= 1'b0;  
* end  
*    
*    
* \`jnooverflow: begin  
*  if(overflow \== 1'b0)  
*     jmp\_flag \= 1'b1;  
*   else  
*     jmp\_flag \= 1'b0;  
* end  
*    
* ////////////////////////////////////////////////////////////  
* \`halt : begin  
* stop \= 1'b1;  
* end  
*    
* endcase  
*    
* end  
* endtask  
*    
*    
*    
* ///////////////////////logic for condition flag  
*    
*    
* task decode\_condflag();  
* begin  
*    
* /////////////////sign bit  
* if(\`oper\_type \== \`mul)  
*  sign \= SGPR\[15\];  
* else  
*  sign \= GPR\[\`rdst\]\[15\];  
*    
* ////////////////carry bit  
*    
* if(\`oper\_type \== \`add)  
*   begin  
*      if(\`imm\_mode)  
*         begin  
*         temp\_sum \= GPR\[\`rsrc1\] \+ \`isrc;  
*         carry    \= temp\_sum\[16\];  
*         end  
*      else  
*         begin  
*         temp\_sum \= GPR\[\`rsrc1\] \+ GPR\[\`rsrc2\];  
*         carry    \= temp\_sum\[16\];  
*         end   end  
*   else  
*    begin  
*        carry  \= 1'b0;  
*    end  
*    
*    
* ///////////////////// zero bit  
*    
* zero \=   ( \~(|GPR\[\`rdst\]) \~(|SGPR\[15:0\]) );  
*    
*    
* //////////////////////overflow bit  
*    
* if(\`oper\_type \== \`add)  
*     begin  
*       if(\`imm\_mode)  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & \~IR\[15\] & GPR\[\`rdst\]\[15\] ) | (GPR\[\`rsrc1\]\[15\] & IR\[15\] & \~GPR\[\`rdst\]\[15\]) );  
*       else  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & \~GPR\[\`rsrc2\]\[15\] & GPR\[\`rdst\]\[15\]) | (GPR\[\`rsrc1\]\[15\] & GPR\[\`rsrc2\]\[15\] & \~GPR\[\`rdst\]\[15\]));  
*     end  
*  else if(\`oper\_type \== \`sub)  
*    begin  
*       if(\`imm\_mode)  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & IR\[15\] & GPR\[\`rdst\]\[15\] ) | (GPR\[\`rsrc1\]\[15\] & \~IR\[15\] & \~GPR\[\`rdst\]\[15\]) );  
*       else  
*         overflow \= ( (\~GPR\[\`rsrc1\]\[15\] & GPR\[\`rsrc2\]\[15\] & GPR\[\`rdst\]\[15\]) | (GPR\[\`rsrc1\]\[15\] & \~GPR\[\`rsrc2\]\[15\] & \~GPR\[\`rdst\]\[15\]));  
*    end  
*  else  
*     begin  
*     overflow \= 1'b0;  
*     end  
*    
* end  
* endtask  
*    
*    
*    
*    
*    
* ////////////////////////////////////////////////////////////////////////////////////////////////////////////  
*    
* /////////////////////////////////////////////  
* ///////////reading program  
*    
* initial begin  
* $readmemb("inst\_data.mem",inst\_mem);  
* end  
*    
* ////////////////////////////////////////////////////  
* //////////reading instructions one after another  
* reg \[2:0\] count \= 0;  
* integer PC \= 0;  
* /\*  
* always@(posedge clk)  
* begin  
*  if(sys\_rst)  
*   begin  
*     count \<= 0;  
*     PC    \<= 0;  
*   end  
*   else  
*   begin  
*     if(count \< 4\)  
*     begin  
*     count \<= count \+ 1;  
*     end  
*     else  
*     begin  
*     count \<= 0;  
*     PC    \<= PC \+ 1;  
*     end  
* end  
* end  
* \*/  
* ////////////////////////////////////////////////////  
* /////////reading instructions  
* /\*  
* always@(\*)  
* begin  
* if(sys\_rst \== 1'b1)  
* IR \= 0;  
* else  
* begin  
* IR \= inst\_mem\[PC\];  
* decode\_inst();  
* decode\_condflag();  
* end  
* end  
* \*/  
* ////////////////////////////////////////////////////  
* ////////////////////////////////// fsm states  
* parameter idle \= 0, fetch\_inst \= 1, dec\_exec\_inst \= 2, next\_inst \= 3, sense\_halt \= 4, delay\_next\_inst \= 5;  
* //////idle : check reset state  
* ///// fetch\_inst : load instrcution from Program memory  
* ///// dec\_exec\_inst : execute instruction \+ update condition flag  
* ///// next\_inst : next instruction to be fetched  
* reg \[2:0\] state \= idle, next\_state \= idle;  
* ////////////////////////////////// fsm states  
*    
* ///////////////////reset decoder  
* always@(posedge clk)  
* begin  
* if(sys\_rst)  
*   state \<= idle;  
* else  
*   state \<= next\_state;  
* end  
*    
*    
* //////////////////next state decoder \+ output decoder  
*    
* always@(\*)  
* begin  
*  case(state)  
*   idle: begin  
*     IR         \= 32'h0;  
*     PC         \= 0;  
*     next\_state \= fetch\_inst;  
*   end  
*    
*  fetch\_inst: begin  
*    IR          \=  inst\_mem\[PC\];    
*    next\_state  \= dec\_exec\_inst;  
*  end  
*   
*  dec\_exec\_inst: begin  
*    decode\_inst();  
*    decode\_condflag();  
*    next\_state  \= delay\_next\_inst;    
*  end  
*   
*   
*  delay\_next\_inst:begin  
*  if(count \< 4\)  
*       next\_state  \= delay\_next\_inst;        
*     else  
*       next\_state  \= next\_inst;  
*  end  
*   
*  next\_inst: begin  
*      next\_state \= sense\_halt;  
*      if(jmp\_flag \== 1'b1)  
*        PC \= \`isrc;  
*      else  
*        PC \= PC \+ 1;  
*  end  
*   
*   
* sense\_halt: begin  
*    if(stop \== 1'b0)  
*      next\_state \= fetch\_inst;  
*    else if(sys\_rst \== 1'b1)  
*      next\_state \= idle;  
*    else  
*      next\_state \= sense\_halt;  
* end  
*   
*  default : next\_state \= idle;  
*   
*  endcase  
*   
* end  
*    
*    
* ////////////////////////////////// count update  
*    
* always@(posedge clk)  
* begin  
* case(state)  
*   
* idle : begin  
*    count \<= 0;  
* end  
*   
* fetch\_inst: begin  
*   count \<= 0;  
* end  
*   
* dec\_exec\_inst : begin  
*   count \<= 0;     
* end   
*    
* delay\_next\_inst: begin  
*   count  \<= count \+ 1;  
* end  
*    
*  next\_inst : begin  
*    count \<= 0;  
* end  
*   
*  sense\_halt : begin  
*    count \<= 0;  
* end  
*   
* default : count \<= 0;  
*   
*   
* endcase  
* end  
*    
*    
*    
* endmodule  
* module tb;  
*    
*    
* integer i \= 0;  
*    
* reg clk \= 0,sys\_rst \= 0;  
* reg \[15:0\] din \= 0;  
* wire \[15:0\] dout;  
*    
*    
* top dut(clk, sys\_rst, din, dout);  
*    
* always \#5 clk \= \~clk;  
*    
* initial begin  
* sys\_rst \= 1'b1;  
* repeat(5) @(posedge clk);  
* sys\_rst \= 1'b0;  
* \#800;  
* $stop;  
* end  
*    
* endmodule

00001\_00000\_00000\_1\_0000\_0000\_0000\_0101

00001\_00001\_00000\_1\_0000\_0000\_0000\_0110

00001\_00010\_00000\_1\_0000\_0000\_0000\_0000

00001\_00011\_00000\_1\_0000\_0000\_0000\_0110

00010\_00010\_00010\_0\_0000\_0000\_0000\_0000

00011\_00011\_00011\_1\_0000\_0000\_0000\_0001

11000\_00000\_00000\_0\_0000\_0000\_0000\_0100

00001\_00100\_00010\_0\_0000\_0000\_0000\_0000

11011\_00000\_00000\_0\_0000\_0000\_0000\_0000  

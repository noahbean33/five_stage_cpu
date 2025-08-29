library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
 
entity proc_top is
port(
IR : in std_logic_vector(31 downto 0)
);
end proc_top;
 
architecture Behavioral of proc_top is
 
-------------------Different operation processor support
 
constant mov     : std_logic_vector(4 downto 0) := "00001";
 
--------------------- arithmetic operations
 
constant add     : std_logic_vector(4 downto 0) := "00010";
constant sub     : std_logic_vector(4 downto 0) := "00011";
constant mul     : std_logic_vector(4 downto 0) := "00100";
constant movsgpr : std_logic_vector(4 downto 0) := "00000";
 
------------------ logical operations
 
constant lor     : std_logic_vector(4 downto 0) := "00101";
constant land    : std_logic_vector(4 downto 0) := "00110";
constant lxor    : std_logic_vector(4 downto 0) := "00111";
constant lxnor   : std_logic_vector(4 downto 0) := "01000";
constant lnand   : std_logic_vector(4 downto 0) := "01001";
constant lnor    : std_logic_vector(4 downto 0) := "01010";
constant lnot    : std_logic_vector(4 downto 0) := "01011";
 
 
 
 
----------------------------------------------------------------------------------
---------------Instruction Register Declaration
 
--signal IR : std_logic_vector(31 downto 0); 
 
-- instruction register <--ir[31:27]--><--ir[26:22]--><--ir[21:17]--><--ir[16]--><--ir[15:11]--><--ir[10:0]-->
-- <--- oper --><-- rdest --><-- rsrc1 --><--modesel--><-- rsrc2 --><--unused --> 
-- <--- oper --><-- rdest --><-- rsrc1 --><--modesel--><-- immediate_date --> 
 
 
-----------------------------------------------------------------------------------------------
-------------------Handling Multiplication of 16-bit
signal mul_res : std_logic_vector(31 downto 0);
signal SGPR : std_logic_vector(15 downto 0); ----msb of multiplication
------------------------------------------------------------------------------------------------
signal add_res : std_logic_vector(16 downto 0);
-----------------------------------------------------------------
 
 
---------------- General Purpose Register
 
type GPR_ARR is array (31 downto 0) of std_logic_vector(15 downto 0);
---------------------Initialization of GPR
signal GPR : GPR_ARR := (others => (others => '0')); 
 
begin
 
 
 
 
------------------decode and execute instruction
 
inst_decode: process(all)
begin
 
case(IR(31 downto 27)) is
              
             
             --------Mov register to register
             when mov =>
             if(IR(16) = '1') then
             GPR(to_integer(unsigned(IR(26 downto 22)))) <= IR(15 downto 0);
             else
             GPR(to_integer(unsigned(IR(26 downto 22)))) <= GPR(to_integer(unsigned(IR(21 downto 17))));
             end if;
             
             -----------addition 
             when add => 
             
             
             if(IR(16) = '1') then
             add_res <= ('0' & GPR(to_integer(unsigned(IR(21 downto 17))))) + ('0' & IR(15 downto 0));
             else
             add_res <= ('0' & GPR(to_integer(unsigned(IR(21 downto 17))))) + ('0' & GPR(to_integer(unsigned(IR(15 downto 11))))); 
             end if; 
             
             GPR(to_integer(unsigned(IR(26 downto 22)))) <= add_res(15 downto 0); ------- storing result in dest GPR without carry
             
             ---------------subtraction 
             when sub => 
             if(IR(16) = '1') then
             GPR(to_integer(unsigned(IR(26 downto 22)))) <= GPR(to_integer(unsigned(IR(21 downto 17)))) - IR(15 downto 0);
             else
             GPR(to_integer(unsigned(IR(26 downto 22)))) <= GPR(to_integer(unsigned(IR(21 downto 17)))) - GPR(to_integer(unsigned(IR(15 downto 11)))); 
             end if; 
             ----------------multiplication 
             when mul =>
             
            
             
             if(IR(16) = '1') then
             mul_res <= GPR(to_integer(unsigned(IR(21 downto 17)))) * IR(15 downto 0);
             else
             mul_res <= GPR(to_integer(unsigned(IR(21 downto 17)))) * GPR(to_integer(unsigned(IR(15 downto 11)))); 
             
             GPR(to_integer(unsigned(IR(26 downto 22)))) <= mul_res(15 downto 0);
             SGPR <= mul_res(31 downto 16);
             
             end if; 
            
                    ---------mov special register to GPR
             when movsgpr => 
             GPR(to_integer(unsigned(IR(26 downto 22)))) <= SGPR;
                 
                 ------------- Logical OR
 
              when lor =>       
               if(IR(16) = '1') then
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) OR IR(15 downto 0);
               else
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) OR GPR(to_integer(unsigned(IR(15 downto 11))));  
               end if;           
           ---------------Logical AND           
              when land =>       
               if(IR(16) = '1') then
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) AND IR(15 downto 0);
               else
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) AND GPR(to_integer(unsigned(IR(15 downto 11))));  
               end if;           
           ---------------Logical XOR           
             when lxor =>       
               if(IR(16) = '1') then
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) XOR  IR(15 downto 0);
               else
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) XOR GPR(to_integer(unsigned(IR(15 downto 11))));  
               end if;           
             -------------logical XNOR                 
             when lxnor =>       
               if(IR(16) = '1') then
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) XNOR IR(15 downto 0);
               else
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) XNOR GPR(to_integer(unsigned(IR(15 downto 11))));  
               end if;  
               
             ------------logical NAND           
                when lnand =>       
               if(IR(16) = '1') then
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) NAND IR(15 downto 0);
               else
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) NAND GPR(to_integer(unsigned(IR(15 downto 11))));  
               end if;           
            --------------logical NOR   
               when lnor =>       
               if(IR(16) = '1') then
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) NOR IR(15 downto 0);
               else
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) NOR GPR(to_integer(unsigned(IR(15 downto 11))));  
               end if;           
            -------------Logical NOT     
               when lnot =>       
               if(IR(16) = '1') then
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  NOT IR(15 downto 0);
               else
                 GPR(to_integer(unsigned(IR(26 downto 22)))) <=  NOT GPR(to_integer(unsigned(IR(21 downto 17))));  
               end if;           
                          
             
 when others => 
 null;
 
end case;
end process;
 
 
end Behavioral;
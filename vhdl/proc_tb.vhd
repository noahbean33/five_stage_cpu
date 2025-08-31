library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
 
 
entity proc_top is
port(
IR : in std_logic_vector(31 downto 0)
);
end proc_top;
 
architecture Behavioral of proc_top is
 
-------------------Different operation processor support
------------------mov instruction
constant movsgpr : std_logic_vector(4 downto 0) := "00000";
constant mov     : std_logic_vector(4 downto 0) := "00001";
----------------- arithmetic instructions
constant add     : std_logic_vector(4 downto 0) := "00010";
constant sub     : std_logic_vector(4 downto 0) := "00011";
constant mul     : std_logic_vector(4 downto 0) := "00100";
----------------- logical instructions
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
 
-- instruction register  <--ir[31:27]--><--ir[26:22]--><--ir[21:17]--><--ir[16]--><--ir[15:11]--><--ir[10:0]-->
--                       <---  oper  --><--   rdest --><--   rsrc1 --><--modesel--><--  rsrc2 --><--unused  -->             
--                       <---  oper  --><--   rdest --><--   rsrc1 --><--modesel--><--  immediate_date      -->      
 
 
 
-----------------------------------------------------------------------------------------------
-------------------Handling Multiplication of 16-bit
signal mul_res : std_logic_vector(31 downto 0);
signal SGPR    : std_logic_vector(15 downto 0);  ----msb of multiplication
------------------------------------------------------------------------------------------------
signal add_res : std_logic_vector(16 downto 0);
-----------------------------------------------------------------
 
 
---------------- General Purpose Register
 
type GPR_ARR is array (31 downto 0) of std_logic_vector(15 downto 0);
signal GPR : GPR_ARR := (others => (others => '0'));
-------------------------------------------------------------------
 
 
-------------------------------------- Instruction_decode + fectch
 
procedure decode_execute (signal IR : in std_logic_vector(31 downto 0); signal GPR : inout GPR_ARR; signal add_res : out std_logic_Vector(16 downto 0); signal mul_res :out std_logic_vector(31 downto 0); signal SGPR : out std_logic_Vector(15 downto 0) ) is
begin
 
case(IR(31 downto 27)) is
  
  ---------mov special register to GPR
  when movsgpr => 
         GPR(to_integer(unsigned(IR(26 downto 22)))) <= SGPR;
  
  
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
         add_res <=  ('0' & GPR(to_integer(unsigned(IR(21 downto 17))))) + ('0' & IR(15 downto 0));
       else
         add_res <=  ('0' & GPR(to_integer(unsigned(IR(21 downto 17))))) + ('0' & GPR(to_integer(unsigned(IR(15 downto 11)))));  
       end if;  
        
       GPR(to_integer(unsigned(IR(26 downto 22)))) <= add_res(15 downto 0);  ------- storing result in dest GPR without carry
    
   ---------------subtraction         
   when sub =>       
       if(IR(16) = '1') then
         GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) - IR(15 downto 0);
       else
         GPR(to_integer(unsigned(IR(26 downto 22)))) <=  GPR(to_integer(unsigned(IR(21 downto 17)))) - GPR(to_integer(unsigned(IR(15 downto 11))));  
       end if;   
  ----------------multiplication  
    when mul =>
          GPR(to_integer(unsigned(IR(26 downto 22)))) <= mul_res(15 downto 0);
          SGPR                             <= mul_res(31 downto 16);
          
       if(IR(16) = '1') then
         mul_res <=  GPR(to_integer(unsigned(IR(21 downto 17)))) * IR(15 downto 0);
       else
         mul_res <= GPR(to_integer(unsigned(IR(21 downto 17))))  * GPR(to_integer(unsigned(IR(15 downto 11))));  
       end if;   
   ----------------logical OR         
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
                                      
                             
              
    when others  => 
        null;
        
end case;
end procedure;
 
 
 
--------------------------Condition Flags
 
 
 
signal zero_o, sign_o, overflow_o, carry_o : std_logic := '0';
 
impure function condition_flag (IR: in std_logic_vector(31 downto 0); SGPR : in std_logic_Vector(15 downto 0); add_res :in std_logic_vector(16 downto 0)) return std_logic_vector is
variable flag: std_logic_vector(3 downto 0) := "0000"; -- overflow zero carry sign 
begin
-------sign flag logic
 if (IR(31 downto 27) = mul) then
    flag(0) := SGPR(15);
 else
    flag(0) :=  GPR(to_integer(unsigned(IR(26 downto 22))))(15);
 end if;
 
 -- ------ carry flag logic
 if (IR(31 downto 27) = add) then
      flag(1) := add_res(16);
 else
      flag(1) := '0';
 end if;
 
  ------------------zero flag logic
  
  if(IR(31 downto 27) = mul) then 
       flag(2) :=  NOT (  or_reduce(SGPR) or or_reduce( GPR(to_integer(unsigned(IR(26 downto 22))))) );
  else
       flag(2) :=  NOT ( or_reduce( GPR(to_integer(unsigned(IR(26 downto 22))))) );
  end if;
  
-- ------------overflow flag logic
 
 if (IR(31 downto 27) = add) then
      if(IR(16) = '1') then
          flag(3) :=  ( ( NOT GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND (NOT IR(15)) AND ( GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) ) OR  ( ( GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND (IR(15)) AND ( NOT GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) ); 
      else
          flag(3) :=  ( ( NOT GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND (NOT GPR(to_integer(unsigned(IR(15 downto 11))))(15)) AND ( GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) ) OR ( (  GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND ( GPR(to_integer(unsigned(IR(15 downto 11))))(15)) AND ( NOT GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) );
      end if;
      
 elsif (IR(31 downto 27) = sub) then
       if(IR(16) = '1') then
          flag(3) :=  ( ( NOT GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND ( IR(15)) AND ( GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) ) OR  ( ( GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND (NOT IR(15)) AND ( NOT GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) ); 
      else
          flag(3) :=  ( ( NOT GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND ( GPR(to_integer(unsigned(IR(15 downto 11))))(15)) AND ( GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) ) OR ( (  GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND ( NOT GPR(to_integer(unsigned(IR(15 downto 11))))(15)) AND ( NOT GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) );
      end if;
 else
          flag(3) := '0';         
 
 end if;
 
return flag;
 
end function;
 
 
 
 
 
 
begin
 
 
------------------decode and execute instruction
 
inst_decode: process(all)
variable flag_s : std_logic_vector(3 downto 0):= "0000";
begin
  decode_execute(IR, GPR, add_res, mul_res, SGPR);
  flag_s := condition_flag(IR, SGPR, add_res);
  sign_o <= flag_s(0);
  carry_o <= flag_s(1);
  zero_o <= flag_s(2);
  overflow_o <= flag_s(3);
end process;
 
 
end Behavioral;
 
 
-----------------------------------------------------------------------------------------------
 
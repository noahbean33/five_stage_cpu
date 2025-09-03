library IEEE;
--------- logical operator 
use IEEE.STD_LOGIC_1164.ALL;
----------numeric operator
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
--------- logical reduction operator
use ieee.std_logic_misc.all;
--------- file i/o
use IEEE.std_logic_textio.ALL;
use std.textio.all;
 
 
entity proc_top is
port(
sys_rst, clk : in std_logic;
din : in std_logic_vector(15 downto 0); ---outside data to proc
dout : out std_logic_Vector(15 downto 0)--- proc to outside world
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
 
----------------  load and store instructions
constant storereg   : std_logic_vector(4 downto 0) := "01100"; ---store reg in data memory
constant storedin   : std_logic_vector(4 downto 0) := "01101"; ---store din in data memory
constant storeimm   : std_logic_vector(4 downto 0) := "01110"; ---store imm_data in data memory
constant senddm   : std_logic_vector(4 downto 0) := "01111";   ----send data memory to dout
constant sendreg    : std_logic_vector(4 downto 0) := "10000"; ----send reg to dout
constant sendimm    : std_logic_vector(4 downto 0) := "10001"; ----send imm to dout
 
 
 
 
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
----------------- data memory
 
type data_memory is array (63 downto 0) of std_logic_vector(15 downto 0);
signal data_mem : data_memory := (others => (others => '0'));
 
 
 
-------------------------------------- Instruction_decode + fectch
 
procedure decode_execute (signal IR : in std_logic_vector(31 downto 0); signal dout : out std_logic_Vector(15 downto 0); signal data_mem : inout data_memory; signal din : in std_logic_Vector(15 downto 0); signal GPR : inout GPR_ARR; signal add_res : out std_logic_Vector(16 downto 0); signal mul_res :out std_logic_vector(31 downto 0); signal SGPR : out std_logic_Vector(15 downto 0) ) is
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
                                      
      ------------------- store reg (addr : src1) in data memory (addr : rdst)
      when storereg =>
         data_mem(to_integer(unsigned(IR(26 downto 22)))) <= GPR(to_integer(unsigned(IR(21 downto 17))));
            
     ----------------- store din in data memory (addr : rdst) 
     when storedin =>        
         data_mem(to_integer(unsigned(IR(26 downto 22)))) <= din;
         
     ----------------  store imm data in data memory (addr : rdst) 
     
     when storeimm =>
          data_mem(to_integer(unsigned(IR(26 downto 22)))) <= IR(15 downto 0);
       
      ------------------ send data memory (addr : rdst) to dout
      
      when senddm  =>      
           dout <=   data_mem(to_integer(unsigned(IR(26 downto 22))));
           
      -------------- send GPR ( addr : rdst) to dout      
      when sendreg  =>
           
           dout <= GPR(to_integer(unsigned(IR(26 downto 22))));
     
     ------------- send imm data to dout   
      when sendimm  =>
           
           dout <= IR(15 downto 0);
  
  
  
  
  
                             
              
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
          flag(3) :=  ( ( NOT GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND (NOT IR(15)) AND ( GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) ) 
                       OR
                      ( ( GPR(to_integer(unsigned(IR(21 downto 17))))(15)) AND (IR(15)) AND ( NOT GPR(to_integer(unsigned(IR(26 downto 22))))(15) ) ); 
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
 
 
------------------------------Adding Program Memory
 
----------------program memory
 
type program_memory is array (0 to 63) of std_logic_vector(31 downto 0);
 
impure function load_program (file_loc : in string) return program_memory is
file mem_file : text open read_mode is file_loc;
variable rline : line;
variable pdata: program_memory;
begin
 
for i in 0 to 63 loop
readline(mem_file, rline);
read(rline, pdata(i));
end loop;
 
return pdata;
end function;
 
signal inst_mem : program_memory := load_program("C:/Users/kumar/project_23/project_23.srcs/sim_1/new/program.txt");
 
 
-------------------- program counter and delay counter
 
signal PC : integer := 0;
signal delay_count : integer := 0;
signal IR : std_logic_vector(31 downto 0) := (others => '0');
 
begin
 
 
 
----------------------control fsm
---------------- program counter logic
 
process(clk)
begin
if(sys_rst = '1') then
  PC <= 0;  -----pc will store address of next instruction to be executed
  delay_count <= 0; -----delay_count delay reading of next instruction
elsif (rising_edge(clk)) then
  if(delay_count < 6) then
       delay_count <= delay_count + 1;
   else
       delay_count <= 0;
       PC <= PC + 1;
   end if;
end if;
 
end process;
 
--------------------
 
process(all)
variable flag_s : std_logic_vector(3 downto 0):= "0000";
begin
if (sys_rst = '1') then
   IR <= (others => '0');
else
      IR <= inst_mem(PC);
      decode_execute(IR, dout, data_mem, din, GPR, add_res, mul_res, SGPR);
      flag_s := condition_flag(IR, SGPR, add_res); 
      sign_o <= flag_s(0);
      carry_o <= flag_s(1);
      zero_o <= flag_s(2);
      overflow_o <= flag_s(3);
 
end if;
end process;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
end Behavioral;
 
 
-----------------------------------------------------------------------------------------------
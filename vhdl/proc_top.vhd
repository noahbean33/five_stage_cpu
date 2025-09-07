library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use IEEE.std_logic_textio.ALL;
use std.textio.all;
 
 
entity proc_top is
port(
sys_rst, clk : in std_logic;
din : in std_logic_vector(15 downto 0);
dout : out std_logic_Vector(15 downto 0)
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
 
------------------load store inst
constant storereg   : std_logic_vector(4 downto 0) := "01100"; ---store reg in data memory
constant storedin   : std_logic_vector(4 downto 0) := "01101"; ---store din in data memory
constant storeimm   : std_logic_vector(4 downto 0) := "01110"; ---store din in data memory
constant senddm   : std_logic_vector(4 downto 0) := "01111"; ----send data memory to dout
constant sendreg    : std_logic_vector(4 downto 0) := "10000";  ----send reg to dout
constant sendimm    : std_logic_vector(4 downto 0) := "10001";  ----send imm to dout
 
----------------------jump and branch inst
constant jump       : std_logic_vector(4 downto 0) := "10010";
constant jcarry     : std_logic_vector(4 downto 0) := "10011";
constant jnocarry   : std_logic_vector(4 downto 0) := "10100";
constant jsign      : std_logic_vector(4 downto 0) := "10101";
constant jnosign    : std_logic_vector(4 downto 0) := "10110";
constant jzero      : std_logic_vector(4 downto 0) := "10111";
constant jnozero    : std_logic_vector(4 downto 0) := "11000";
constant joverflow  : std_logic_vector(4 downto 0) := "11001";
constant jnooverflow  : std_logic_vector(4 downto 0) := "11010";
constant halt      : std_logic_vector(4 downto 0) := "11011";
 
--------------------------------------------------------------
signal jump_f, stop_f : std_logic := '0';
 
 
 
 
----------------------------------------------------------------------------------
---------------Instruction Register Declaration
 
signal IR : std_logic_vector(31 downto 0); 
 
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
 
----------------------Initialization of GPR
 
signal GPR : GPR_ARR := (others => (others => '0'));
-------------------------------------------------------------------
 
-----------------condition flags
 
 
 
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
 
signal inst_mem : program_memory := load_program("C:/Users/kumar/file_io_vhdl/file_io_vhdl.srcs/sim_1/new/data.txt");
 
-------------------adding data memory
 
type data_memory is array (63 downto 0) of std_logic_vector(15 downto 0);
signal data_mem : data_memory := (others => (others => '0'));
 
 
 
 
------------------------- procedure for condition flag
 
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
 
 
-------------------------------------- Instruction_decode + fectch
 
procedure decode_execute (signal IR : in std_logic_vector(31 downto 0);signal c, s,z,o : in std_logic ; signal jump_f, stop_f : out std_logic; signal dout : out std_logic_Vector(15 downto 0); signal GPR : inout GPR_ARR; signal data_mem : inout data_memory; signal add_res : out std_logic_Vector(16 downto 0); signal mul_res :out std_logic_vector(31 downto 0); signal SGPR : out std_logic_Vector(15 downto 0) ) is
begin
         jump_f   <= '0';
         stop_f    <= '0';
 
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
         GPR(to_integer(unsigned(IR(26 downto 22))))   <=  GPR(to_integer(unsigned(IR(21 downto 17)))) + IR(15 downto 0);
       else
          GPR(to_integer(unsigned(IR(26 downto 22))))  <=  GPR(to_integer(unsigned(IR(21 downto 17)))) + GPR(to_integer(unsigned(IR(15 downto 11))));  
      end if;  
        
 
       if(IR(16) = '1') then
         add_res <=  ('0' & GPR(to_integer(unsigned(IR(21 downto 17))))) + ('0' & IR(15 downto 0));
       else
         add_res <=  ('0' & GPR(to_integer(unsigned(IR(21 downto 17))))) + ('0' & GPR(to_integer(unsigned(IR(15 downto 11)))));  
       end if;  
        
          
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
    
       when jump    => 
             jump_f <= '1';
             
       when jcarry   =>
            if(c = '1') then
              jump_f <= '1';
            else
              jump_f <= '0';
            end if;
            
       when jsign   =>
            if(s = '1') then
              jump_f <= '1';
            else
              jump_f <= '0';  
             end if;
           
       when jzero   =>
            if(z = '1') then
              jump_f <= '1';
            else
              jump_f <= '0';  
             end if;  
             
        when joverflow   =>
            if(o = '1') then
              jump_f <= '1';
            else
              jump_f <= '0';  
             end if;  
             
             
                 
       when jnocarry   =>
            if(c = '0') then
              jump_f <= '1';
            else
              jump_f <= '0';
            end if;
            
       when jnosign   =>
            if(s = '0') then
              jump_f <= '1';
            else
              jump_f <= '0';  
             end if;
           
       when jnozero   =>
            if(z = '0') then
              jump_f <= '1';
            else
              jump_f <= '0';  
             end if;  
             
        when jnooverflow   =>
            if(o = '0') then
              jump_f <= '1';
            else
              jump_f <= '0';  
             end if;      
                   
       when halt =>
            stop_f  <= '1';         
           
            
    when others  => 
        null;
        
end case;
end procedure;
 
 
-------------------- program counter and delay counter
 
signal PC : integer := 0;
signal delay_count : integer := 0;
 
-----------------------------state_type
 
type state_type is (idle,fetch, execute_inst,flag_status, delay, sense_jump, sense_halt);
signal state, next_state : state_type := idle;
 
begin
 
 
------------------decode and execute instruction
 
--inst_decode: process(all)
--begin
--decode_execute(IR, GPR, add_res, mul_res, SGPR);
--end process;
 
 
 
--------------------- two process fsm 
 
----------------sense reset
process(clk) 
begin
if(rising_edge(clk) ) then
    if(sys_rst = '1') then
       state <= idle;
     else
       state <= next_state;
     end if;
end if;
end process;
 
------------------next state decoder
 
process(state, delay_count)
variable flag_s : std_logic_vector(3 downto 0):= "0000";
begin
case(state) is
when idle =>
  IR  <= (others => '0');
  PC  <= 0;
  next_state <= fetch;
  
when fetch =>
  IR         <= inst_mem(PC);
  next_state <= execute_inst;  
 
when execute_inst =>
  decode_execute(IR, carry_o, sign_o, zero_o, overflow_o, jump_f, stop_f, dout,GPR, data_mem,  add_res, mul_res, SGPR);
  next_state <= flag_status;
  
  
when flag_status =>  
  flag_s := condition_flag(IR, SGPR, add_res);
  sign_o <= flag_s(0);
  carry_o <= flag_s(1);
  zero_o <= flag_s(2);
  overflow_o <= flag_s(3); 
  next_state <= delay;
  
when delay  =>
  if(delay_count = 4) then
       next_state <= sense_jump;
   else
       next_state <= delay;
  end if;
 
when sense_jump =>
      next_state <= sense_halt;
      if (jump_f = '1') then
          PC <= to_integer(unsigned(IR(15 downto 0)));
      else
          PC <= PC + 1;
      end if;
 
when sense_halt => 
      if (stop_f = '0') then
         next_state <= fetch;
       elsif (sys_rst = '1') then
         next_state <= idle;
       else
        next_state <= sense_halt;
      end if;
     
when others   =>
       next_state <= idle;
           
end case;
end process;
 
------------------------- logic for delay_counter
 
process(clk)
begin
if(rising_edge(clk) ) then
case(state) is
when idle         => delay_count <= 0;
when fetch        => delay_count <= 0;
when execute_inst => delay_count <= 0;
when flag_status  => delay_count <= 0; 
when delay        => delay_count <= delay_count + 1;
when sense_jump   => delay_count <= 0;
when sense_halt   => delay_count <= 0;
when others       => delay_count <= 0;
end case;
end if;
 
end process;
 
 
end Behavioral;
 
 
-----------------------------------------------------------------------------------------------
 
 
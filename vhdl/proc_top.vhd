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
 
 
 
----------------------------------------------------------------------------------
---------------Instruction Register Declaration
 
--signal IR : std_logic_vector(31 downto 0); 
 
-- instruction register <--ir[31:27]--><--ir[26:22]--><--ir[21:17]--><--ir[16]--><--ir[15:11]--><--ir[10:0]-->
-- <--- oper --><-- rdest --><-- rsrc1 --><--modesel--><-- rsrc2 --><--unused --> 
-- <--- oper --><-- rdest --><-- rsrc1 --><--modesel--><-- immediate_date --> 
 
 
---------------- General Purpose Register
 
type GPR_ARR is array (31 downto 0) of std_logic_vector(15 downto 0);
----------------------Initialization of GPR
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
             
             
             
             -----------------default state
             when others => 
             null;
             
    end case;
end process;
 
 
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.env.stop;
 
 
 
entity proc_tb is
end proc_tb;
 
architecture Behavioral of proc_tb is
 
component proc_top is
port(
sys_rst, clk : in std_logic;
din : in std_logic_vector(15 downto 0);
dout : out std_logic_Vector(15 downto 0)
);
end component;
 
signal sys_rst, clk : std_logic;
signal din  : std_logic_vector(15 downto 0);
signal dout : std_logic_Vector(15 downto 0);
begin
 
proc_inst: proc_top port map (sys_rst, clk, din, dout);
 
 
process
begin
clk <= '1';
wait for 10 ns;
clk <= '0';
wait for 10 ns;
end process;
 
 
process
begin
sys_rst <= '0';
wait for 30 ns;
end process;
 
 
 
 
---------------------Trigger Carry Flag
----report "--------------------------------";
----report "Register add : GPR14 -> GPR12 + GPR13";
----IR <= "00001" & "01100" & "00000" & '1' & x"8001"; ---mov r12 = 8001
----wait for 20 ns;
----IR <= "00001" & "01101" & "00000" & '1' & x"8002"; ---mov r13 = 8002
----wait for 20 ns;
----IR <= "00010" & "01110" & "01100" & '0' & "01101" & "00000000000";-- r14 = r12 + r13
----wait for 20 ns;
 
 
 
-------------------- store result of r14 in DM @ 0
 
--IR  <= "01100" & "00000" & "01110" & '0' & "00000" &  "00000000000" ;
 
--------------------- send dm content to dout
 
--IR <= "01111" & "00000" & "00000" & '0' & "00000" &  "00000000000" ;
 
--------------------  
 
 
 
end Behavioral;
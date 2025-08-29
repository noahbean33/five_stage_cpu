library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.env.stop;
 
 
entity proc_tb is
end proc_tb;
 
architecture Behavioral of proc_tb is
 
component proc_top is
port(
IR : in std_logic_vector(31 downto 0)
);
end component;
 
signal IR : std_logic_vector(31 downto 0) := (others => '0');
 
begin
 
proc_inst: proc_top port map (IR => IR);
--------------------
 
process 
begin
-- instruction register <--ir[31:27]--><--ir[26:22]--><--ir[21:17]--><--ir[16]--><--ir[15:11]--><--ir[10:0]-->
-- <--- oper --><-- rdest --><-- rsrc1 --><--modesel--><-- rsrc2 --><--unused --> 
 
 
-------- movi gpr(0) = 3
report "--------------------------------";
report "Immediate Move : GPR0 -> 3";
IR <= "00001" & "00000" & "00000" & '1' & "00000" & "00000000011";
wait for 20 ns;
 
 
--------- mov gpr(1) = 5
report "--------------------------------";
report "Immediate Move : GPR1 -> 1";
IR <= "00001" & "00001" & "00000" & '1' & "00000" & "00000000001";
wait for 20 ns;
 
 
stop;
end process;
 
end behavioral;
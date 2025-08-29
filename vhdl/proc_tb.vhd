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
 
 
--------- perform addition of gpr0 and gpr1, store result in gpr2
--------- gpr2 = gpr1 + gpr0
report "--------------------------------";
report "Register Addition : GPR2 -> GPR0 + GPR1";
IR <= "00010" & "00010" & "00001" & '0' & "00000" & "00000000000";
wait for 20 ns;
 
--------- perform addition of gpr0 and immediate data, store result in gpr2
--------- gpr3 = gpr0 + imm_data
report "--------------------------------";
report "Immediate Addition : GPR3 -> GPR0 + IMM_DATA";
IR <= "00010" & "00011" & "00000" & '1' & "00000" & "00000000111";
wait for 20 ns;
 
 
--------- perform logical OR of gpr0 and gpr1 and store result in gp3
--------- gpr4 = gpr1 | gpr0
report "--------------------------------";
report "Register OR : GPR4 -> GPR0 | GPR1";
IR <= "00101" & "00100" & "00000" & '0' & "00001" & "00000000000";
wait for 20 ns;
 
 
--------- perform logical AND of gpr0 and imm_data and store result in gp4
--------- gpr5 = gpr0 & imm_data
report "--------------------------------";
report "Immediate and : GPR5 -> GPR0 & imm_data";
IR <= "00110" & "00101" & "00000" & '1' & "00000" & "00000111111";
wait for 20 ns;
 
--------- mov gpr(6) = 0101010101010101
report "--------------------------------";
report "Immediate Move : GPR6 -> 21845";
IR <= "00001" & "00110" & "00000" & '1' & "01010" & "10101010101";
wait for 20 ns;
 
--------- perform logical XOR of gpr6 and imm_data and store result in gp8
--------- gpr8 = gpr6 | imm_data
report "--------------------------------";
report "Immediate XOR : GPR8 -> GPR6 ^ imm_data";
IR <= "00111" & "01000" & "00110" & '1' & "01100" & "00000111111";
wait for 20 ns;
 
 
 
stop;
end process;
 
 
end behavioral;
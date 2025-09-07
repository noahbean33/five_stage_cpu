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
--------------------
 
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
sys_rst <= '0';
end process;
 
 
 
 
end Behavioral;
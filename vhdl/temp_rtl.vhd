library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
 
 
entity temp_rtl is
end temp_rtl;
 
architecture Behavioral of temp_rtl is
signal a, b : std_logic_vector(3 downto 0):= "0000";
signal yout : std_logic_vector(3 downto 0):= "0000";
 
procedure add ( a,b : in std_logic_vector(3 downto 0); signal y : out std_logic_Vector(3 downto 0)) is
begin
y <= a + b;
end procedure;
 
begin
 
add(a,b,yout);
 
end Behavioral;
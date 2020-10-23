----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2020 11:10:35 AM
-- Design Name: 
-- Module Name: tester - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tester is
  Port ( 
  		x: in std_logic_vector(7 downto 0);
  		z: in std_logic;
  		o: out std_logic_vector(7 downto 0)
	  	);
end tester;

architecture Behavioral of tester is

begin

process(x,z)
begin
if z='1' then
	o<= x;
else
	o<= x"00";
end if;

end process;


end Behavioral;

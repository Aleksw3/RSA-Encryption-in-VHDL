----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/20/2020 06:06:03 PM
-- Design Name: 
-- Module Name: ripple_adder - Behavioral
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

entity ripple_adder is
  generic(width: integer:=7);
  Port (x: in std_logic_vector(width downto 0); 
  		y: in std_logic_vector(width downto 0);
  		sum: out std_logic_vector(width+1 downto 0)  
  	);
end ripple_adder;

architecture Behavioral of ripple_adder is

begin


end Behavioral;

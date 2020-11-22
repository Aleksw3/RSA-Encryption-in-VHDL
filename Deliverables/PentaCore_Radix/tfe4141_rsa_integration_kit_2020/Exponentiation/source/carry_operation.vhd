----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2020 04:21:52 PM
-- Design Name: 
-- Module Name: carry_operation - Behavioral
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

entity carry_operation is
  Port (i_g1, i_g2 : in std_logic;
        i_p1, i_p2 : in std_logic;
        o_g, o_p : out std_logic);
end carry_operation;

architecture Behavioral of carry_operation is

begin
    o_g <= i_g2 OR (i_g1 AND i_p2);
	o_p <= i_p2 AND i_p1;

end Behavioral;

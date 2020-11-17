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

entity gp_generator is
  Port (i_x, i_y : in std_logic;
        o_g, o_p : out std_logic );
end gp_generator;

architecture Behavioral of gp_generator is

begin
    o_g <= i_x AND i_y;
	o_p <= i_x XOR i_y;

end Behavioral;

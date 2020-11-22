----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/20/2020 05:36:55 PM
-- Design Name: 
-- Module Name: CSA_multiplier - Behavioral
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
use IEEE.numeric_std.ALL;


entity CSA_adder_for_mult is
	Generic(width: integer:=7
			);
	Port ( 
			x: IN unsigned(width downto 0);
			y: IN unsigned(width downto 0);
			carry_in: IN unsigned(width downto 0);
			sum: OUT unsigned(width downto 0);
			carry: OUT unsigned(width downto 0)
		);
end CSA_adder_for_mult;

architecture Behavioral of CSA_adder_for_mult is
	signal carry_shift: unsigned(width downto 0);
begin

	sum <= ((x xor y)) XOR carry_in;
	carry_shift <= ((x and y) or (x and carry_in) or (y and carry_in));
	carry <= carry_shift(width-1 downto 0) & '0'; --The most significant bit of the carry will never be 1 for multiplication

end Behavioral;

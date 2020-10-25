----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/25/2020 05:28:52 PM
-- Design Name: 
-- Module Name: MonPro - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;

entity MonPro is
	generic(bit_width: integer := 256);
	port(
		N, X, Y : 	in std_logic_vector(bit_width - 1 downto 0);
		R		:	in std_logic_vector(bit_width downto 0);
		Done	:	in std_logic;
		Z		:	out std_logic_vector(bit_width - 1 downto 0));
end MonPro;

architecture structural of MonPro is

	--Structural components
	
	
	
	
	begin

	

	
	end architecture;
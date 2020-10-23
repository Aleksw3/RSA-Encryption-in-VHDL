----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/20/2020 05:41:32 PM
-- Design Name: 
-- Module Name: csa_mult_tb - Behavioral
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
use IEEE.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity csa_mult_tb is
--  Port ( );
end csa_mult_tb;

architecture Behavioral of csa_mult_tb is
--CSA_multiplier ports
	--A: IN unsigned(width_A downto 0);
	--B: IN unsigned(width_B downto 0);
	--carry_out: OUT unsigned(width_A+width_B downto 0);
	--sum_out: OUT unsigned(width_A+width_B downto 0)

constant width_A: 	integer:=16; --bit vector length so 8 bit is 7  downto 0
constant width_B: 	integer:=8; --smaller bit vector
signal A: 			unsigned(width_A-1 downto 0);
signal B: 			unsigned(width_B-1 downto 0);
signal carry_out: 	unsigned(width_A+width_B-1 downto 0);
signal sum_out: 	unsigned(width_A+width_B-1 downto 0);


begin
CSA_comp1: entity work.CSA_multiplier generic map(width_A => width_A,width_B => width_B)
						  port map(A=>A,B=>B,sum_out=>sum_out,carry_out=>carry_out);

	process
	begin
		for i in 0 to ((2**width_B) - 1) loop
			B <= to_unsigned(i, B'length);

			for j in 0 to ((2**width_A)-1) loop
				A <= to_unsigned(j, A'length);
				wait for 1 ns;
				assert ((i*j) = (to_integer(carry_out)+to_integer(sum_out)))
						report "Error multiplication failed: i = "&integer'image(i)&" j = "&integer'image(j)
						severity Warning;
				wait for 5 ns;
			end loop;
		end loop;
		wait;
	end process;


end Behavioral;

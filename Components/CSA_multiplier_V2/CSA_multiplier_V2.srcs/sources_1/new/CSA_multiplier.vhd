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


entity CSA_multiplier is
	Generic(width_A: integer:=257; --longer bit length
			width_B: integer:=2  --smaller bit length
		);
	Port ( 
			A: IN unsigned(width_A-1 downto 0);
			B: IN unsigned(width_B-1 downto 0);
			carry_out: OUT unsigned(width_A+width_B-1 downto 0);
			sum_out: OUT unsigned(width_A+width_B-1 downto 0)
		);
end CSA_multiplier;

 architecture Behavioral of CSA_multiplier is
--signal P0,P1,P2,P3: unsigned(width_A+width_B-1 downto 0);
--signal sum,sum0,sum1: unsigned(width_A+width_B-1 downto 0);
--signal carry,carry0,carry1: unsigned(width_A+width_B-1 downto 0);

type ps is array (integer range<>) of unsigned((width_A+width_B-1) downto 0);
signal P: ps(0 to (width_A-1));
--signal sum,carry: ps(0 to (width_A-1));


begin

process(A,B)
begin
	multiplication: for i in 0 to (width_B-1) loop
		if B(i) = '1' then
			P(i) <= unsigned(shift_left(resize(A,P(i)'length),i));
		else
			P(i) <= (others => '0');
		end if;
	end loop multiplication;
end process;

--

first_adder: entity work.CSA_adder_for_mult 
				generic map(width => width_A+width_B-1)
				port map(x=>P(0),y=>P(1),carry_in=>(others => '0'),sum=>sum_out,carry=>carry_out);

end Behavioral;

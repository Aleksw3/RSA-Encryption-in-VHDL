----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2020 05:17:43 PM
-- Design Name: 
-- Module Name: critical_path_test - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity critical_path_test is
	Generic(width_A: integer:=257; --longer bit length
			width_B: integer:=16  --smaller bit length
		);
	Port ( 
	       clk: in std_logic;
	       reset_n: in std_logic;
			A: IN unsigned(width_A-1 downto 0);
			B: IN unsigned(width_B-1 downto 0);
			carry_out: OUT unsigned(width_A+width_B-1 downto 0);
			sum_out: OUT unsigned(width_A+width_B-1 downto 0)
		);
end critical_path_test;

architecture Behavioral of critical_path_test is

Signal A_reg: unsigned(width_A-1 downto 0);
Signal B_reg: unsigned(width_B-1 downto 0);
Signal carry_out_reg,carry_out_s: unsigned(width_A+width_B-1 downto 0);
Signal sum_out_reg,sum_out_s: unsigned(width_A+width_B-1 downto 0);
begin
cpt: entity work.CSA_multiplier
        generic map(
            width_A => width_A,
            width_B => width_B
        )
        port map ( 
			A=>A_reg,
			B=>B_reg,
			carry_out=>carry_out_s,
			sum_out=>sum_out_s
		);
	carry_out<=carry_out_reg;
	sum_out<=sum_out_reg;
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                A_reg <= (others=>'0');
                B_reg <= (others=>'0');
                carry_out_reg <= (others=>'0');
                sum_out_reg <= (others=>'0');
            else
                A_reg <= A;
                B_reg <= B;
                carry_out_reg <= carry_out_s;
                sum_out_reg <= sum_out_s;
            end if;
        end if;
    end process;


end Behavioral;

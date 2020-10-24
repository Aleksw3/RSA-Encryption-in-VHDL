----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/23/2020 05:55:07 PM
-- Design Name: 
-- Module Name: RL_exponentiation - Behavioral
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

entity RL_exponentiation is
	Generic(
			bit_width: integer:= 255
		);
	Port ( 
			clk:	      in std_logic;
			reset_n:	  in std_logic;
			key:  	      in std_logic_vector(bit_width downto 0);
			n:     	      in std_logic_vector(bit_width downto 0);
			r_squared:    in std_logic_vector(bit_width+1 downto 0); --Pre calculate in different register
			message:      in std_logic_vector(bit_width downto 0);
			mux_select:   in std_logic_vector(1 downto 0);
			MonPro_done:  out std_logic_vector(1 downto 0);
			shift_signal: in std_logic;

			output_message: out std_logic_vector(bit_width downto 0)
		);
end RL_exponentiation;

architecture Behavioral of RL_exponentiation is

signal C, S: std_logic_vector(bit_width downto 0); 		   -- Outputs from MonPro modules

signal shift_signal_d: std_logic:='0';

signal key_shift_reg: std_logic_vector(bit_width downto 0);
signal MonPro_C_input_rdy, MonPro_S_input_rdy: std_logic :='0';

begin
	key_shift_reg:process(clk)
	begin
		if rising_edge(clk) then
			shift_signal_d <= shift_signal; 
			if shift_signal and not shift_signal_d then
				key_shift_reg <= key_shift_reg(bit_width-1 downto 1) & '0';
			end if;
		end if;
	end process key_shift_reg;

	-- Multiplexers infront of MonPro blocks
	MonPro_inputs: process()
	begin
		case(mux_select) is
			when "00" =>
				MonPro_C_A <= std_logic_vector(resize(1,bit_width));
				MonPro_C_B <= r_squared;

				MonPro_S_A <= message_reg;
				MonPro_S_B <= r_squared;
			when "01" =>
				MonPro_C_A <= C_reg;
				MonPro_C_B <= S_reg

				MonPro_S_A <= S_reg;
				MonPro_S_B <= S_reg;
			when "10" =>
				MonPro_C_A <= std_logic_vector(resize(1,bit_width));
				MonPro_C_B <= C_reg;

				MonPro_S_A <= (others => '0');
				MonPro_S_B <= (others => '0');
			when "11" => -- should never get in this state but in case, DC. Set to zero so we can see the error in simulation
				MonPro_C_A <= (others => '0');
				MonPro_C_B <= (others => '0');
				MonPro_S_A <= (others => '0');
				MonPro_S_B <= (others => '0');
		end case;

	end process MonPro_inputs;



	-- Enable and write C-reg value to output_message
	output_message:process(C_reg) 
	begin
		if output_enable = '1' then
			output_message <= C_reg;
		end if;

	end process output_message;




end Behavioral;

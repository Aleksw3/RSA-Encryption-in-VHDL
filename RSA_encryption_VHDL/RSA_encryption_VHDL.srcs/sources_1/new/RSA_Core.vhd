----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/24/2020 03:29:21 PM
-- Design Name: 
-- Module Name: RSA_Core - Behavioral
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
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RSA_Core is
	Generic(
			bit_width: integer:=255
	);
	Port ( 
		clk: 	 in std_logic;
		reset_n: in std_logic;

		--Left side block diagram
		msgin_valid: in std_logic;
		msgin_ready: out std_logic;
		msgin_last:  in std_logic;
		msgin_data:  in std_logic_vector(bit_width downto 0);

		--Right side block diagram
		msgout_valid: out std_logic;
		msgout_ready: in std_logic;
		msgout_last:  out std_logic;
		msgout_data:  out std_logic_vector(bit_width downto 0);

		--Top side block diagram
		key_n: in std_logic_vector(bit_width downto 0);
		key_e: in std_logic_vector(bit_width downto 0);
		rsa_status: out std_logic_vector(31 downto 0);
		-- Additional value/constant saved in rsa_regio
		r_squared: in std_logic_vector(bit_width downto 0) -- Need to figure out this length
	);
end RSA_Core;

architecture Behavioral of RSA_Core is

signal input_message, output_message: std_logic_vector(bit_width downto 0);
signal multiple_in, multiple_out: std_logic;
signal start: std_logic :='0';
signal counter_val: unsigned (7 downto 0);
begin



message_in:process(clk)
begin
	if reset_n='0' then
		-- reset something dunno
	else
		if rising_edge(clk) then
			if msgin_valid and msgin_ready then
				input_message <= msgin_data;
				start <= '1';

				if multiple_in ='0' then
					multiple_in <= '1';
				else
					msgin_last <= multiple_in;
				end if;

			else
				msgin_last <= '0';
			end if;
		end if;
	end if;

end process message_in;

message_out:process(clk)
begin
	if reset_n='0' then
		-- reset something dunno
	else
		if msgout_valid and msgout_ready then
			msgout_data <= output_message;

				if multiple_out ='0' then
					multiple_out <= '1';
				else
					msgout_last <= multiple_out;
				end if;

			else
				msgout_last <= '0';
		end if;
	end if;
end process message_out;

cnt: process(clk)
begin
	if reset_n = '0' then

	elsif rising_edge(clk) then
		if start then
			counter_val <= counter_val + 1;
		end if;
	end if;
end process cnt;
counter <= std_logic_vector(counter_val);



RL_exp: entity work.RL_exponentiation
			generic map(bit_width => bit_width)
			port map(clk=>clk,reset_n=>reset_n, key_e => key, key_n => n,
					 r_squared => r_squared, input_message => message,
					 output_message => output_message);
end Behavioral;

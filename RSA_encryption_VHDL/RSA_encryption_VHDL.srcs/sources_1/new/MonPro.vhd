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
use ieee.numeric_std.all;  

entity MonPro is
	generic(bit_width: integer := 256);
	port(
		clk, nrst, EN	:	in std_logic;
		N, X, Y 		: 	in std_logic_vector(bit_width - 1 downto 0);
		busy			:	out std_logic;
		Z				:	out std_logic_vector(bit_width - 1 downto 0));
end MonPro;

architecture structural of MonPro is

	--Structural components
	
	component CompressorTree is
	generic(n : integer := 256);
	port(
		A 		: in unsigned(n-1 downto 0);
		B 		: in unsigned(n-1 downto 0);
		C 		: in unsigned(n-1 downto 0);
		D		: in unsigned(n-1 downto 0);
		Sum 	: out unsigned(n-1 downto 0);
		Cout	: out unsigned (0 downto 0);
		Carry 	: out unsigned(n-1 downto 0));
	end Component;
	
	type state is (IDLE, INIT, COMPUTE, DONE);
	signal curr_state, next_state : state;
	
	--Counter for computing Z
	signal cnt : integer range 0 to bit_width-1 := 0;
	
	--Control signals
	signal done_s : std_logic := '0';
	
	--Intermediate signals
	signal Q, SumLSB, Cout : std_logic := '0';
	signal A, B, C, D : std_logic_vector(bit_width-1 downto 0);
	signal Sum, Carry : std_logic_vector(bit_width-1 downto 0);
	
	--Inputs and outputs stored in registers
	signal X_s, Y_s, N_s, Z_s : std_logic_vector(bit_width-1 downto 0);
	
	
	
	begin
		
		--Component mapping
		Cprs : CompressorTree 
					generic map(n => bit_width)
					port map(A => A, B => B, C => C, D => D,
					Sum => Sum, Carry => Carry, Cout => Cout);
					
		--Multibit AND operations that are inputs to compressor
		AndOperations : for i in 0 to bit_width-1 generate
			C(i) <= N_s(i) and Q;
			D(i) <= Y_s(i) and X_s(0);
		end generate;
		
		
		
		SynchProc : process(clk)
		begin
			if rising_edge(clk) then	
				if nrst = '0' then
					curr_state <= idle;
				else
					--If EN is high, perform Monpro, otherwise IDLE
					if EN = '1' then
						--Store input vectors in registers
						if curr_state = INIT then
							X_s <= X;
							Y_s <= Y;
							N_S <= N;
						--Compute the MonPro: Compressor, shift, store carry and save in registers.
						elsif curr_state = COMPUTE then
							if cnt = bit_width - 1 then
								cnt <= 0;
								done_s <= '1';
							else
								A <= 0 & Carry(bit_width-1 downto 1);
								B <= 0 & Sum(bit_width-1 downto 1);
								X_s <= shift_right(unsigned(X_s), 1);
								cnt <= cnt + 1;
							end if;
						--When finished computing, perform CPA and output to Z
						elsif curr_state = DONE then
						
						end if;
						curr_state <= next_state;
					else
						curr_state <= idle;
					end if;
				end if;
			end if;
		end process;
		
		CombProc : process(clk)
		begin
			case(curr_state) is
				when IDLE =>
					Z <= (others => '0');
					busy <= '0';
					done <= '0';
					if EN = '1' then
						next_state <= INIT;
					else
						next_state <= IDLE;
					end if;
				when INIT =>
					busy <= '1';
					next_state <= COMPUTE;
				when COMPUTE =>
					if done_s = '1' then
						next_state <= DONE;
					else
						SumLSB <= Sum(0);
					end if;
				when DONE =>
					
				when others =>
					next_state <= IDLE;
				end case;
					
		end process;
		
		
		
		
	
	end architecture;
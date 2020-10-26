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
		clk, reset_n, EN	:	in std_logic;
		N, X, Y 		: 	in std_logic_vector(bit_width - 1 downto 0);
		busy			:	out std_logic;
		Z				:	out std_logic_vector(bit_width - 1 downto 0));
end MonPro;

architecture structural of MonPro is

	--Structural components
	
	component CompressorTree is
	generic(n : integer := 256);
	port(
		A 		: in std_logic_vector(n-1 downto 0);
		B 		: in std_logic_vector(n-1 downto 0);
		C 		: in std_logic_vector(n-1 downto 0);
		D		: in std_logic_vector(n-1 downto 0);
		Cout	: out std_logic;
		Sum 	: out std_logic_vector(n-1 downto 0);
		Carry 	: out std_logic_vector(n-1 downto 0));
	end Component;
	
	component Full_Adder is
	port(
		A : in std_logic;
		B : in std_logic;
		C_in : in std_logic;
		S : out std_logic;
		C_out : out std_logic);
	end component;
	
	component Half_Adder is
	port(
		A : in std_logic;
		B : in std_logic;
		S : out std_logic;
		C : out std_logic);
	end component;
	
	type state is (IDLE, INIT, COMPUTE, DONE);
	signal curr_state, next_state : state;
	
	--Counter for computing Z
	signal cnt : integer range 0 to bit_width-1 := 0;
	
	--Control signals
	signal done_s, initialized, busy_s : std_logic := '0';
	
	--Intermediate signals
	signal Q, Cout : std_logic := '0';
	signal A, B, C, D : std_logic_vector(bit_width-1 downto 0);
	signal Sum, Carry : std_logic_vector(bit_width-1 downto 0);
	
	--Inputs and outputs stored in registers
	signal X_s, Y_s, N_s, Z_s : std_logic_vector(bit_width-1 downto 0);
	
	--CPA input and output signals
	signal CPA_C, CPA_S : std_logic_vector(bit_width-2 downto 0);
	signal CPA_A, CPA_B : std_logic_vector(bit_width-2 downto 0);
	
	
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
		
		--Generating CPA block for calculating Z
		HA_RC_0 : Half_Adder port map(A => CPA_A(0), B => CPA_B(0), S => CPA_S(0), C => CPA_C(0));
	
		FA_RC_f : for i in 1 to bit_width-2 generate
			FA_RC_i : Full_Adder port map(A => CPA_A(i), B => CPA_B(i), C_in => CPA_C(i-1), S => CPA_S(i), C_out => CPA_C(i));
		end generate;
		
		--Signal connections to port
		Z <= Z_s;
		busy <= busy_s;
		
		
		SynchProc : process(clk)
			--variable cnt : integer range 0 to bit_width-1 := 0;
		begin
			if rising_edge(clk) then	
				if reset_n = '0' then
					curr_state <= IDLE;
					X_s <= (others => '0');
					Y_s <= (others => '0');
					N_s <= (others => '0');
					Z_s <= (others => '0');
				else
					--If EN is high, perform Monpro, otherwise IDLE
					if EN = '1' then
					
						--Store input vectors in registers
						if curr_state = INIT then
							X_s <= X;
							Y_s <= Y;
							N_S <= N;
							Z_s <= (others => '0');
							initialized <= '1';
							
						--Compute the MonPro: Compressor, shift, store carry and save in registers.
						elsif curr_state = COMPUTE then
							--Check whether computation is done
							if cnt = bit_width - 1 then
								done_s <= '1';
								cnt <= 0;
							--Computation is still being performed
							else
								--Update Compressor input registers with new values
								--1 bit Right shift inputs to registers A, B and X_s
								A <= '0' & Carry(bit_width-2 downto 0);
								B <= '0' & Sum(bit_width-2 downto 0);
								X_s <= '0' & X_s(bit_width-1 downto 1);
								Q <= Sum(0) xor D(0);
								--Update counter
								cnt <= cnt + 1;
							end if;
						--When finished computing, perform CPA and output to Z
						elsif curr_state = DONE then
							--Throw away carry and sumMSB of CPA and store result in Z
							Z_s <= CPA_S(bit_width-2 downto 0) & Sum(0);
							busy_s <= '0';
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
					--Reset signals in case of undesired values
					Z <= (others => '0');
					busy_s <= '0';
					done_s <= '0';
					cnt <= 0;
					initialized <= '0';
					if EN = '1' then
						next_state <= INIT;
					else
						next_state <= IDLE;
					end if;
				when INIT =>
					busy_s <= '1';
					if initialized = '1' then
						next_state <= COMPUTE;
					else
						next_state <= INIT;
					end if;
				when COMPUTE =>
					--Computation finished
					if done_s = '1' then
						next_state <= DONE;
					--Computation still being performed
					else
						next_state <= COMPUTE;
					end if;
				when DONE =>
					--CPA finished and output ready
					if busy_s = '0' then
						next_state <= IDLE;
					--CPA computation still being performed
					else
						--CPA inputs of bit_width - 1 bits
						CPA_A <= Carry(bit_width - 2 downto 0); 
						CPA_B <= Sum(bit_width - 2 downto 0);
						next_state <= DONE;
					end if;
				when others =>
					next_state <= IDLE;
				end case;
					
		end process;
			
	end architecture;
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
	generic(C_block_size: integer := 256);
	port(
		clk, reset_n, EN	:	in std_logic;
		N, X, Y 		: 	in std_logic_vector(C_block_size - 1 downto 0);
		busy			:	out std_logic;
		Z				:	out std_logic_vector(C_block_size - 1 downto 0));
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
	
	component CarryPropagateAdder is
	generic(n : integer := 256);
	port(
			A 			: in std_logic_vector(n-1 downto 0);
			B 			: in std_logic_vector(n-1 downto 0);
			Sum 		: out std_logic_vector(n-1 downto 0);
			Cout 		: out std_logic);
	end component;
	
	type state is (INIT, COMPUTE);
	signal curr_state, next_state : state;
	
	--Counter for computing Z
--	signal cnt : integer range 0 to C_block_size-1 := 0;
	
	--Control signals
	signal done_s, busy_s : std_logic := '0';
	
	--Intermediate signals
	signal Q : std_logic; 
	signal Cprs_Cout : std_logic;
	signal A, B, C, D : std_logic_vector(C_block_size-1 downto 0);
	signal Cprs_Carry : std_logic_vector(C_block_size-1 downto 0) := (others => '0');
	signal Cprs_Sum : std_logic_vector(C_block_size - 1 downto 0) := (others => '0');
	signal Cprs_Sum_s : std_logic_vector(C_block_size-1 downto 0) := (others => '0'); --shifted signal
	signal Sum : std_logic_vector(C_block_size-1 downto 0);
	
	--Inputs and outputs stored in registers
	signal X_s, Y_s, N_s : std_logic_vector(C_block_size-1 downto 0);
	signal Z_s : std_logic_vector(C_block_size-1 downto 0) := (others => '0');
	
	--CPA input and output signals
	signal CPA_Sum : std_logic_vector(C_block_size-1 downto 0);
	signal CPA_B : std_logic_vector(C_block_size-1 downto 0);
	signal CPA_Cout : std_logic;
	
	
	begin
		
		--Component mapping
		Cprs : CompressorTree 
					generic map(n => C_block_size)
					port map(A => A, B => B, C => C, D => D,
					Sum => Cprs_Sum, Carry => Cprs_Carry, Cout => Cprs_Cout);
					 
		--Multibit AND operations that are inputs to compressor
		AndOperations : for i in 0 to C_block_size-1 generate
			C(i) <= N_s(i) AND Q;
			D(i) <= Y_s(i) AND X_s(0);
		end generate;
		
		Summation	: CarryPropagateAdder 
					generic map(n => C_block_size)
					port map(A => Cprs_Carry, B => Cprs_Sum_s, Sum => Sum,
					Cout => CPA_Cout);
	
	    Q <= B(0) XOR (X_s(0) AND Y_s(0));
		Cprs_Sum_s <= std_logic_vector(shift_right(unsigned(Cprs_Sum),1));
		--Signal connections to port
		Z <= Z_s;
		busy <= busy_s;
		
		
		SynchProc : process(clk)
			variable cnt : integer range 0 to C_block_size-1 := 0;
		begin
			if rising_edge(clk) then	
				if reset_n = '0' then
					curr_state <= INIT;
					X_s <= (others => '0');
					Y_s <= (others => '0');
					N_s <= (others => '0');
				else
					--If EN is high, perform Monpro, otherwise IDLE
					if EN = '1' then
						case(curr_state) is
						when INIT =>
							--Store inputs in registers
							cnt := 0;
							X_s <= X;
                            Y_s <= Y;
                            N_S <= N;
							--Reset output and intermediate registers
							A <= (others => '0');
							B <= (others => '0');
							Z_s <= (others => '0');
							--Set busy_s bit high, indicating computation ongoing
							done_s <= '0';
							busy_s <= '1';
						when COMPUTE =>
						    if (cnt < C_block_size-1) then
								
								A <= Cprs_Carry;
								B <= Cprs_Sum_s;
								
								X_s <=  std_logic_vector(shift_right(unsigned(X_s),1));
								cnt := cnt + 1;
								if(cnt = C_block_size-1) then
								    done_s <= '1';
								else
								    done_s <= '0';
								end if;
							else
							    Z_s <= Sum;
							    busy_s <= '0';
								cnt := 0;
							end if;
						end case;
						curr_state <= next_state;
					end if;
				end if;
			end if;
		end process;
		
		CombProc : process(curr_state, EN, busy_s, done_s)
		begin
		    if EN = '1' then
                case(curr_state) is
                when INIT =>
                --When busy_s is 1, the MonPro is finished initializing
                    if busy_s = '1' then
                        next_state <= COMPUTE;
                    else
                        next_state <= INIT;
                    end if;
                when COMPUTE =>
                --When done_s is 1, the MonPro computation is finished
                    if done_s = '1' then
                        next_state <= INIT;
                    else
                        next_state <= COMPUTE;
                    end if;
                when others =>
                    next_state <= INIT;
                end case;
            else
                next_state <= INIT;
            end if;
		end process;
			
	end architecture;
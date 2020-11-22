library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

entity MonPro is
	generic(C_block_size: integer := 256);
	port(
		clk, reset_n, EN: in std_logic;
		N, X, Y 		: in std_logic_vector(C_block_size downto 0);
		busy			: out std_logic;
		Carry, Sum		: out std_logic_vector(C_block_size-1 downto 0));
end MonPro;

architecture structural of MonPro is

	--Structural components
	component CompressorMultiBit_4to2 is
	generic(bit_width : integer);
	port( 
		   A 		        : in std_logic_vector(C_block_size downto 0);
		   B 		        : in std_logic_vector(C_block_size downto 0);
		   C 		        : in std_logic_vector(C_block_size downto 0);
		   D		        : in std_logic_vector(C_block_size downto 0);
		   Sum 	            : out std_logic_vector(C_block_size downto 0);
		   Cout	            : out std_logic;
		   Carry 	        : out std_logic_vector(C_block_size downto 0));
    end component;	
	
	type state is (INIT, COMPUTE);
	signal curr_state_MP, next_state_MP : state;
	
	--Control Logic
    signal done_s : std_logic       := '0';
    signal busy_s : std_logic       := '0';

    --Intermediate Signals
    signal isODD                    : std_logic;
    signal compressor_cout          : std_logic;
    signal C, D                     : std_logic_vector(C_block_size downto 0);

--	signal C_s, D_s                 : std_logic_vector(C_block_size-1 downto 0);
    signal compressor_sum           : std_logic_vector(C_block_size downto 0) := (others => '0');
    signal compressor_carry         : std_logic_vector(C_block_size downto 0) := (others => '0');
    signal compressor_sum_shifted   : std_logic_vector(C_block_size downto 0);
	
    --Registers
    signal X_r, Y_r, N_r, Z_r       : std_logic_vector(C_block_size downto 0);
    signal A_r, B_r                 : std_logic_vector(C_block_size downto 0);
    signal KSA_sum_input_r          : std_logic_vector(C_block_size - 1 downto 0);
    signal KSA_carry_input_r        : std_logic_vector(C_block_size - 1 downto 0);
    
    --CarryLookAheadAdder Signals
    signal KSA_carry_input          : std_logic_vector(C_block_size-1 downto 0) := (others => '0');
    signal KSA_sum_input            : std_logic_vector(C_block_size-1 downto 0) := (others => '0');
    signal KSA_result               : std_logic_vector(C_block_size downto 0) := (others => '0');
	
	--Counter
    signal count                    : integer range 0 to C_block_size+2 := 0;
	
	begin
		
		--Component mapping
		Cprs_Inst : CompressorMultiBit_4to2 
            generic map(bit_width => C_block_size)
            port map(A => A_r, B => B_r, 
            C => C, D => D, 
            Sum => Compressor_Sum, 
            Carry => Compressor_Carry, 
            Cout => Compressor_Cout);
					 
		--Multibit AND operations that are inputs to compressor
		AndOperations : for i in 0 to C_block_size generate
			C(i) <= N_r(i) AND isODD;
			D(i) <= Y_r(i) AND X_r(0);
		end generate;
		
--        KSA_Inst : KoggeStoneAdder32Bit
--            port map(i_x => KSA_Carry_Input, 
--            i_y => KSA_Sum_Input, o_result => KSA_Result);
	
	
--		C <= '0' & C_s;
--		D <= '0' & D_s;
	    isODD <= B_r(0) XOR (X_r(0) AND Y_r(0));
		Compressor_Sum_Shifted <= std_logic_vector(shift_right(unsigned(Compressor_Sum),1));

		--Signal connections to port
		busy <= busy_s;
		KSA_Carry_Input <= KSA_Carry_Input_r;
		KSA_Sum_Input	<= KSA_Sum_Input_r;
		
		SynchProc : process(clk)
		begin
			if rising_edge(clk) then	
				if reset_n = '0' then   
					curr_state_MP <= INIT;
					X_r <= (others => '0');
					Y_r <= (others => '0');
					N_r <= (others => '0');
				else
					--If EN is high, perform Monpro, otherwise IDLE
					if EN = '1' then
					    curr_state_MP <= next_state_MP;
						case(curr_state_MP) is
						when INIT =>
							--Store inputs in registers
							count       <= 0;
							X_r <= X;
                            Y_r <= Y;
                            N_r <= N;
							--Reset output and intermediate registers
							A_r <= (others => '0');
							B_r <= (others => '0');
							KSA_Sum_Input_r      <= (others => '0');
							KSA_Carry_Input_r    <= (others => '0');
							--Set busy_s bit high, indicating computation ongoing
							done_s <= '0';
							busy_s <= '1';
						when COMPUTE =>
						    if (count < C_block_size) then
								count <= count + 1;
								A_r   <= Compressor_Carry;
								B_r   <= Compressor_Sum_Shifted;
								X_r   <= std_logic_vector(shift_right(unsigned(X_r),1));
							elsif count <= C_block_size then
							    count <= count + 1;
								KSA_Sum_Input_r     <= Compressor_Sum_Shifted(C_block_size-1 downto 0);
                                KSA_Carry_Input_r   <= Compressor_Carry(C_block_size-1 downto 0);
							else
							    if done_s = '0' then
							        done_s <= '1';
                                else
                                    count  <= 0;
                                    busy_s <= '0';
                                    Sum    <= KSA_Sum_Input_r;
                                    Carry  <= KSA_Carry_Input_r;
                                end if;
							end if;
						end case;
					end if;
				end if;
			end if;
		end process;
		
		CombProc : process(curr_state_MP, EN, busy_s, done_s)
		begin
		    if EN = '1' then
                case(curr_state_MP) is
                when INIT =>
                --When busy_s is 1, the MonPro is finished initializing
                    if busy_s = '1' then
                        next_state_MP <= COMPUTE;
                    else
                        next_state_MP <= INIT;
                    end if;
                when COMPUTE =>
                --When done_s is 1, the MonPro computation is finished
                    if done_s = '1' then
                        next_state_MP <= INIT;
                    else
                        next_state_MP <= COMPUTE;
                    end if;
                when others =>
                    next_state_MP <= INIT;
                end case;
            else
                next_state_MP <= INIT;
            end if;
		end process;
			
	end architecture;
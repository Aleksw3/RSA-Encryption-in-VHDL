library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

entity MonPro is
	generic(C_block_size: integer := 256;
	        radix :       integer := 2);
	port(
		clk, reset_n, EN: in std_logic;
		N, X, Y 		: in std_logic_vector(C_block_size downto 0);
		N_inv           : in std_logic_vector(radix - 1 downto 0);
		busy			: out std_logic;
		Carry, Sum		: out std_logic_vector(C_block_size - 1 downto 0));
end MonPro;

architecture structural of MonPro is
	--Structural components
	component CompressorMultiBit_6to2 is
	generic(C_block_size : integer := 256;
	       radix : integer := 16);
	port(
		A 		: in std_logic_vector(C_block_size + radix downto 0);
		B 		: in std_logic_vector(C_block_size + radix downto 0);
		C 		: in std_logic_vector(C_block_size + radix downto 0);
		D		: in std_logic_vector(C_block_size + radix downto 0);
		E       : in std_logic_vector(C_block_size + radix downto 0);
		F       : in std_logic_vector(C_block_size + radix downto 0);
		Sum 	: out std_logic_vector(C_block_size + radix + 2 downto 0);
		Carry 	: out std_logic_vector(C_block_size + radix + 2 downto 0));
    end component;	
    
    component CSA_multiplier is
	Generic(width_A: integer:=257; --Larger
			width_B: integer:=2);  --Smaller
	Port ( 
			A: IN unsigned(width_A-1 downto 0);
			B: IN unsigned(width_B-1 downto 0);
			carry_out: OUT unsigned(width_A+width_B-1 downto 0);
			sum_out: OUT unsigned(width_A+width_B-1 downto 0));
    end component;
    
    component ModularMultiplication is
    Port(
        x : in std_logic_vector(1 downto 0);
        y : in std_logic_vector(1 downto 0);
        compressor_sum : in std_logic_vector(1 downto 0);
        N_inv : in std_logic_vector(1 downto 0);
        o_result : out std_logic_vector(1 downto 0));
    end component;
    
    component Half_Adder is
    port(
        A : in std_logic;
        B : in std_logic;
        S : out std_logic;
        C : out std_logic);
    end component;

    component Full_Adder is
    port(
        A : in std_logic;
        B : in std_logic;
        C_in : in std_logic;
        S : out std_logic;
        C_out : out std_logic);
    end component;
    
	----- Signals
	type state is (INIT, COMPUTE);
	signal curr_state_MP, next_state_MP : state;
	
	--Control Logic
    signal done_s : std_logic       := '0';
    signal busy_s : std_logic       := '0';

    --Intermediate Signals
    signal C, D                     : std_logic_vector(C_block_size+radix downto 0);
    signal E, F                     : std_logic_vector(C_block_size+radix downto 0);
    signal unsigned_E, unsigned_F   : unsigned(C_block_size + radix downto 0);
    signal unsigned_C, unsigned_D   : unsigned(C_block_size + radix downto 0);
    signal ModMult_Result           : std_logic_vector(radix-1 downto 0);
    signal modmult_input1           : std_logic_vector(1 downto 0);
    signal LSB_carry, LSB_sum       : std_logic_vector(1 downto 0);
    signal LSB_cout : std_logic; 
    signal compressor_sum           : std_logic_vector(C_block_size + radix + 2 downto 0) := (others => '0');
    signal compressor_carry         : std_logic_vector(C_block_size + radix + 2 downto 0) := (others => '0');
    signal compressor_sum_shifted   : std_logic_vector(C_block_size + radix + 2 downto 0);
	signal compressor_carry_shifted : std_logic_vector(C_block_size + radix + 2 downto 0);
	signal result_Monpro            : std_logic_vector(C_block_size + radix + 2 downto 0);
	
	
    --Registers
    signal X_r, Y_r, N_r            : std_logic_vector(C_block_size downto 0);
    signal A_r, B_r                 : std_logic_vector(C_block_size+radix downto 0);
    signal KSA_sum_input_r          : std_logic_vector(C_block_size-1 downto 0);
    signal KSA_carry_input_r        : std_logic_vector(C_block_size-1 downto 0);
    signal N_inv_r                  : std_logic_vector(radix-1 downto 0);
    
	
	--Counter
    signal count                    : integer range 0 to C_block_size := 0;
	
	begin
		
		--Component mapping
		Cprs_Inst : CompressorMultiBit_6to2 
            generic map(C_block_size => C_block_size, radix => radix)
            port map(A => A_r, B => B_r, 
            C => C, D => D, E => E, F => F,
            Sum => Compressor_Sum, 
            Carry => Compressor_Carry);
					 
					 
		CSA_Multiplier_EF : CSA_multiplier
		      generic map(width_A => C_block_size + 1, width_B => radix)
		      port map(A => unsigned(Y_r), B => unsigned(X_r(radix-1 downto 0)),
		              carry_out => unsigned_E, sum_out => unsigned_F); 
		              
		              
		CSA_Multiplier_CD : CSA_multiplier
		      generic map(width_A => C_block_size + 1, width_B => radix)
		      port map(A => unsigned(N_r), B => unsigned(ModMult_Result(radix-1 downto 0)),
		              carry_out => unsigned_C, sum_out => unsigned_D); 
		              
		              
        ModularMultiplication_inst : ModularMultiplication
              port map(x => x_r(radix-1 downto 0), y => y_r(radix-1 downto 0),
                       compressor_sum => modmult_input1, N_inv => N_inv_r,
                       o_result => ModMult_Result);
        
        LSB0_CarrySum_Inst : Half_Adder
              port map(A => LSB_sum(0), B => LSB_carry(0),
                       S => modmult_input1(0), C => LSB_cout);
	
        LSB1_CarrySum_Inst : Full_Adder port map(A => LSB_sum(1), B => LSB_carry(1),
                                        C_in => LSB_cout, S => modmult_input1(1), C_out => open);
	
	
	    
		Compressor_Sum_Shifted <= std_logic_vector(shift_right(unsigned(Compressor_Sum),radix));
        Compressor_Carry_Shifted <= std_logic_vector(shift_right(unsigned(Compressor_Carry),radix-1));
        
        result_Monpro <= std_logic_vector(unsigned(Compressor_Sum_Shifted) + unsigned(Compressor_Carry_Shifted));
        
		busy <= busy_s;
		
		LSB_sum <= B_r(1 downto 0);
		LSB_carry <= A_r(1 downto 0);
		
		C <= std_logic_vector(unsigned_C);
		D <= std_logic_vector(unsigned_D);
		E <= std_logic_vector(unsigned_E);
		F <= std_logic_vector(unsigned_F);
		
		Sum    <= KSA_Sum_Input_r;
        Carry  <= KSA_Carry_Input_r;

-----------------------------------------------------------------------------------------------
--------------------------- FSM for entire Monpro----------------------------------------------
------------------------------Synchronous stage------------------------------------------------
-----------------------------------------------------------------------------------------------
--Init: Resets all the necessary registers and stores the input values in registers.
--Busy is pulled high, indicating that the monpro is occupied with calculations
--Compute: Performs the MonPro calculations, pulling busy low when the monpro is finished

		SynchProc : process(clk)
		begin
			if rising_edge(clk) then	
				if reset_n = '0' then   
					curr_state_MP <= INIT;
					X_r <= (others => '0');
					Y_r <= (others => '0');
					N_r <= (others => '0');
					N_inv_r <= "00";
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
                            N_inv_r <= N_inv;
							--Reset output and intermediate registers
							A_r <= (others => '0');
							B_r <= (others => '0');
							KSA_Sum_Input_r      <= (others => '0');
							KSA_Carry_Input_r    <= (others => '0');
							--Set busy_s bit high, indicating computation ongoing
							done_s <= '0';
							busy_s <= '1';
						when COMPUTE =>
						    if count < (C_block_size/radix) then
								count <= count + 1;
								A_r   <= Compressor_Carry_Shifted(C_block_size+radix downto 0);
								B_r   <= Compressor_Sum_Shifted(C_block_size+radix downto 0);
								X_r   <= std_logic_vector(shift_right(unsigned(X_r),radix));
							elsif count <= (C_block_size/radix) then
							    count <= count + 1;
								KSA_Sum_Input_r     <= Compressor_Sum_Shifted(C_block_size-1 downto 0);
                                KSA_Carry_Input_r   <= Compressor_Carry_Shifted(C_block_size-1 downto 0);
							else
							    if done_s = '0' then
							        done_s <= '1';
                                else
                                    count  <= 0;
                                    busy_s <= '0';
                                end if;
							end if;
						end case;
					end if;
				end if;
			end if;
		end process;
-----------------------------------------------------------------------------------------------
--------------------- Combinational FSM Stage--------------------------------------------------
-----------------------------------------------------------------------------------------------
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
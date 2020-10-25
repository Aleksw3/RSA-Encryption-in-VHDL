library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity RL_exponentiation is
	Generic(
			bit_width: integer:= 256
		);
	Port ( 
			clk:	      	in std_logic;
			reset_n:	  	in std_logic;
			init:		  	in std_logic;
			key:  	      	in std_logic_vector(bit_width-1 downto 0);
			N:     	      	in std_logic_vector(bit_width-1 downto 0);
			r_squared:    	in std_logic_vector(bit_width downto 0); --Pre calculate in different register
			message:     	in std_logic_vector(bit_width-1 downto 0);
			mux_select:     in std_logic_vector(1 downto 0);
			
			MonPro_busy:    out std_logic_vector(1 downto 0);
			
			shift_enable: 	in std_logic;
			output_message: out std_logic_vector(bit_width downto 0)
		);
end RL_exponentiation;

architecture Behavioral of RL_exponentiation is

signal C_reg, S_reg, N_reg: std_logic_vector(bit_width-1 downto 0); 		   -- Outputs from MonPro modules
signal message_reg, modulus_N: std_logic_vector(bit_width-1 downto 0);
signal MonPro_C_X, MonPro_C_Y, MonPro_S_X, MonPro_S_Y: std_logic_vector(bit_width-1 downto 0);

signal key_shift_reg: std_logic_vector(bit_width-1 downto 0);
--signal MonPro_C_input_rdy, MonPro_S_input_rdy: std_logic :='0';
signal MonPro_C_busy, MonPro_S_busy: std_logic;
signal MonPro_C_en, MonPro_S_en: std_logic;


type state is (IDLE, CS, S);
signal curr_state, next_state: state;

signal MonPro_rdy: std_logic;
constant one: signed(1 downto 0) := "01";


begin
MonPro_C: entity work.MonPro 
			port map(clk => clk, reset_n => reset_n,
					  EN => MonPro_S_en, N=>N_reg,
					  X => MonPro_C_X, Y=> MonPro_C_Y,
					  Done => MonPro_C_done, 
					  Busy => MonPro_C_busy, Z => C_reg);

MonPro_S: entity work.MonPro 
			port map(clk => clk, reset_n => reset_n,
					  EN => MonPro_S_en, N=>N_reg,
					  X => MonPro_S_X, Y=> MonPro_S_Y,
					  Done => MonPro_S_done, 
					  Busy => MonPro_C_busy,Z => S_reg);

MonPro_S_en <= MonPro_rdy;
MonPro_C_en <= MonPro_rdy and key_shift_reg(0);

MonPro_busy <= MonPro_C_busy & MonPro_S_busy; 

	initialize:process(clk)
	begin
		if rising_edge(clk) then
			if init = '1' then
				key_shift_reg <= key;
				message_reg <= message;
				modulus_N <= N;
			end if;
		end if;	
	end process initialize;

	key_shift_reg_process:process(clk)
	begin
		if rising_edge(clk) then
			if shift_enable = '1' and  MonPro_C_busy = '0' and MonPro_S_busy = '0' then
				key_shift_reg <= key_shift_reg(bit_width-1 downto 1) & '0';
			end if;
		end if;
	end process key_shift_reg_process;

	-- Multiplexers infront of MonPro blocks
	MonPro_inputs: process(mux_select)
	begin
		case(mux_select) is
			when "00" =>
				MonPro_C_X <= std_logic_vector(resize(one,bit_width-1)); -- 1
				MonPro_C_Y <= r_squared;

				MonPro_S_X <= message_reg;
				MonPro_S_Y <= r_squared;
			when "01" =>
				MonPro_C_X <= C_reg;
				MonPro_C_Y <= S_reg;

				MonPro_S_X <= S_reg;
				MonPro_S_Y <= S_reg;
			when "10" =>
				MonPro_C_X <= std_logic_vector(resize(one,bit_width-1)); -- 1
				MonPro_C_Y <= C_reg;

				MonPro_S_X <= (others => '0');
				MonPro_S_Y <= (others => '0');
			when "11" => -- should never get in this state but in case, DC. Set to zero so we can see the error in simulation
				MonPro_C_X <= (others => '0');
				MonPro_C_Y <= (others => '0');
				MonPro_S_X <= (others => '0');
				MonPro_S_Y <= (others => '0');
		end case;
	end process MonPro_inputs;

	process(MonPro_C_busy,MonPro_S_busy)
	begin
		if MonPro_S_busy = '0' and MonPro_C_busy ='0' then
			MonPro_rdy <= '1';
		else 
			MonPro_rdy <= '0';
		end if;

	end process;

end Behavioral;

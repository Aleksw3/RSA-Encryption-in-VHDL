library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity RL_exponentiation is
    Generic(
            bit_width: integer:= 256
        );
    Port ( 
            clk:            in std_logic;
            reset_n:        in std_logic;
            KEY:            in std_logic_vector(bit_width-1 downto 0);
            N:              in std_logic_vector(bit_width-1 downto 0);
            R:      		in std_logic_vector(bit_width-1 downto 0); --Pre calculate in different register
            MESSAGE:        in std_logic_vector(bit_width-1 downto 0);

            busy: 			out std_logic;
            init: 			in  std_logic;
            done: 			out std_logic;
            
            output_message: out std_logic_vector(bit_width-1 downto 0)
        );
end RL_exponentiation;

architecture Behavioral of RL_exponentiation is

-- Registers for inputs
signal C_reg, S_reg, N_reg: std_logic_vector(bit_width-1 downto 0);            -- Outputs from MonPro modules
signal message_reg: std_logic_vector(bit_width-1 downto 0);

--Signals informing and showing the status of the MonPro
signal MonPro_C_busy, MonPro_S_busy: std_logic;
signal MonPro_C_en, MonPro_S_en: std_logic;
signal MonPro_C_en_start, MonPro_S_en_start: std_logic:='0';


-- State machine for the MonPro exponential
type state_exp is (IDLE,INITIAL,LOOP_EXP,LAST,DATA_OUT);
signal curr_state_exp, next_state_exp: state_exp;

-- State machine for the MonPro calculation
type state_mp is (IDLE,LOAD,START,BUSY_WAIT,DONE);
signal curr_state_mp, next_state_mp: state;

-- shift register
signal key_shift_reg: std_logic_vector(bit_width-1 downto 0);
signal counter:       unsigned (8 downto 0);





signal MP_busy: std_logic_vector(1 downot 0);

constant one: signed(1 downto 0) := "01";
begin

MonPro_C: entity work.MonPro 
            generic map(bit_width => bit_width)
            port map (clk => clk, reset_n => reset_n,
                      EN => MonPro_C_en, N=>N_reg,
                      X => MonPro_C_X, Y=> MonPro_C_Y,
                      Busy => MonPro_C_busy, Z => C_s);

MonPro_S: entity work.MonPro 
            generic map(bit_width => bit_width)
            port map (clk => clk, reset_n => reset_n,
                      EN => MonPro_S_en, N=>N_reg,
                      X => MonPro_S_X, Y=> MonPro_S_Y,
                      Busy => MonPro_S_busy,Z => S_s);

MP_busy <= MonPro_C_busy & MonPro_S_busy;

MonPro_S_en <= MonPro_S_en_start or MonPro_S_busy;
MonPro_C_en <= MonPro_C_en_start or MonPro_C_busy;


	synchrounous_fsm_exp: process(clk, reset_n)
	begin
		if rising_edge(clk) then
			curr_state_exp <= next_state_exp;
			case(curr_state_exp) is
				when IDLE =>
				when INITIAL =>
				when LOOP_EXP =>
				when LAST =>
				when DATA_OUT =>
					done <= '1';
			end case;
		end if;

	end process synchrounous_fsm_exp;

	combinational_fsm_exp: process(init, MP_done)
	begin
		case(curr_state_exp) is
			when IDLE =>
				if init = '1' then
					next_state_exp <= INITIAL;
				else
					next_state_exp <= IDLE;
				end if;
			when INITIAL =>
				if MP_done = '1' then
					next_state_exp <= LOOP_EXP;
				else
					next_state_exp <= INITIAL;
				end if;
			when LOOP_EXP =>
				if MP_done = '1' then
					next_state_exp <= LAST;
				else
					next_state_exp <= LOOP_EXP;
				end if;
			when LAST =>
				if MP_done = '1' then
					next_state_exp <= DATA_OUT;
				else
					next_state_exp <= LAST;
				end if;
			when DATA_OUT =>
				next_state_exp <= IDLE;
		end case;
	end process combinational_fsm_exp;


	synchrounous_fsm_MP: process(clk, reset_n)
	begin
		if rising_edge(clk) then
			curr_state_mp <= next_state_mp;

			case(curr_state_exp) is
				when IDLE =>
					MP_done <= '0';
				when LOAD =>
					if curr_state_exp = INITIAL then
						MonPro_S_X <= R;
						MonPro_S_Y <= R;
						MonPro_C_X <= M;
						MonPro_C_Y <= R;

					elsif curr_state_exp = LOOP_EXP then
						MonPro_S_X <= S_reg;
						MonPro_S_Y <= S_reg;
						MonPro_C_X <= C_reg;
						MonPro_C_Y <= S_reg;

						key_shift_reg <= KEY;
						counter <= (others => '0');

					else -- curr_state_exp = LAST
						MonPro_C_X <= std_logic_vector(resize(one,MonPro_C_X'length));
						MonPro_C_Y <= S_reg;
					end if;

				when START =>
					if curr_state_exp = INITIAL then
						MonPro_S_en_start <= '1';
						MonPro_C_en_start <= '1';
					elsif curr_state_exp = LOOP_EXP then
						MonPro_S_en_start <= '1';
						MonPro_C_en_start <= key_shift_reg(bit_width-1);
					else -- curr_state_exp = LAST
						MonPro_C_en_start <= '1';
						MonPro_C_en_start <= '0';
					end if;
				when BUSY_WAIT =>
					if curr_state_exp = LOOP_EXP and busy = "00" then
						key_shift_reg <= std_logic_vector(shift_left(unsigned(key_shift_reg(bit_width-2 downto 0)),1));
						counter       <= counter+1;
						MonPro_S_en_start <= '1';
						MonPro_C_en_start <= key_shift_reg(bit_width-1);
					else
						MonPro_S_en_start <= '0';
						MonPro_C_en_start <= '0';
					end if;
				when DONE =>
					MP_done <= '1';
			end case;
		end if;

	end process synchrounous_fsm_MP;

	combinational_fsm_monpro: process(curr_state_mp, busy, counter)
	begin
		next_state_mp <= next_state_mp;
		case(curr_state_mp) is
			when IDLE =>
			when LOAD =>
				next_state_mp<=START;
			when START =>
				if MonPro_S_busy = '1' or MonPro_C_busy = '1' then
					next_state_mp<=BUSY_WAIT;
				end if;
			when BUSY_WAIT =>
				if busy = "00" then
					if curr_state_exp = LOOP_EXP then
						if counter = 255 then
							next_state_mp <= DONE;
						end if;
					else
						next_state_mp <= DONE;
					end if;
				end if;
			when DONE =>
				next_state_mp <= IDLE;
		end case;
	end process combinational_fsm_monpro;



end Behavioral;
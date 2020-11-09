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
            MESSAGE:        in std_logic_vector(bit_width-1 downto 0);

            busy:           out std_logic;
            init:           in  std_logic;
            done:           out std_logic;
            R2N:            in std_logic_vector(bit_width-1 downto 0);
            
            output_message: out std_logic_vector(bit_width-1 downto 0)
        );
end RL_exponentiation;

architecture Behavioral of RL_exponentiation is

-- Registers for inputs
signal C_reg, S_reg, N_reg, R_reg, R2N_reg: std_logic_vector(bit_width-1 downto 0);            -- Outputs from MonPro modules
signal message_reg: std_logic_vector(bit_width-1 downto 0);

--Signals informing and showing the status of the MonPro
signal MonPro_C_busy, MonPro_S_busy: std_logic;
signal MonPro_C_en, MonPro_S_en: std_logic;
signal MonPro_C_en_start, MonPro_S_en_start: std_logic:='0';
signal MP_done: std_logic:= '0';
signal MP_start: std_logic:='0';

--MonPro inputs
signal MonPro_C_X,MonPro_C_Y: std_logic_vector(bit_width-1 downto 0);
signal MonPro_S_X,MonPro_S_Y: std_logic_vector(bit_width-1 downto 0);

signal S_s, C_s: std_logic_vector(bit_width-1 downto 0);

-- State machine for the MonPro exponential
type state_exp is (IDLE,INITIAL,LOOP_EXP,LAST,DATA_OUT);
signal curr_state_exp, next_state_exp: state_exp;

-- State machine for the MonPro calculation
type state_mp is (IDLE,LOAD,BUSY_WAIT,MP_DONE_FSM);
signal curr_state_mp, next_state_mp: state_mp;

-- shift register
signal key_shift_reg: std_logic_vector(bit_width-1 downto 0);
signal key_reg: std_logic_vector(bit_width-1 downto 0);
signal counter:       unsigned (8 downto 0);
signal MonPro_S_busy_f, MonPro_C_busy_f: std_logic:='0';





signal MP_busy: std_logic_vector(1 downto 0);

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
                    done <='1';
                    if next_state_exp = INITIAL then
                        MP_start<='1';
                    else
                        MP_start<='0';
                    end if;
                when INITIAL =>
                    done <= '0';
                    N_reg <= N;
                    R2N_reg <= R2N; -- R^2 % n, input constant
                    message_reg <= MESSAGE;
                    key_reg <= KEY;
                    if next_state_exp = LOOP_EXP then
                        MP_start<='1';
                    else
                        MP_start<='0';
                    end if;
                when LOOP_EXP =>
                    if next_state_exp = LAST then
                        MP_start<='1';
                    else
                        MP_start<='0';
                    end if;
                when LAST =>
                    MP_start<='0';
                when DATA_OUT =>
                    done <= '1';
                    MP_start<='0';
                    output_message <= C_reg;
            end case;
        end if;

    end process synchrounous_fsm_exp;

    combinational_fsm_exp: process(init, MP_done,curr_state_exp)
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
            if reset_n = '0' then
                curr_state_mp <= IDLE;
            else
                curr_state_mp <= next_state_mp;
                case(curr_state_mp) is
                    when IDLE =>
                        MP_done <= '0';
                        busy <='0';
                        MonPro_S_en_start <= '0';
                        MonPro_C_en_start <= '0';
                        MonPro_C_X <= (others=>'0');
                        MonPro_C_Y <= (others=>'0');
                        MonPro_S_X <= (others=>'0');
                        MonPro_S_Y <= (others=>'0');
                    when LOAD =>
                        busy <='1';
                        if curr_state_exp = INITIAL then
                            MonPro_C_X <= std_logic_vector(resize(one,MonPro_C_X'length));
                            MonPro_C_Y <= R2N_reg;
                            MonPro_S_X <= message_reg;
                            MonPro_S_Y <= R2N_reg;
                            
                            MonPro_S_en_start <= '1';
                            MonPro_C_en_start <= '1';
    
                        elsif curr_state_exp = LOOP_EXP then
                            MonPro_S_X <= S_reg;
                            MonPro_S_Y <= S_reg;
                            MonPro_C_X <= C_reg;
                            MonPro_C_Y <= S_reg;
                            
                            MonPro_S_en_start <= '1';
                            MonPro_C_en_start <= key_reg(0);
                            key_shift_reg <= '0'&key_reg(bit_width-1 downto 1);
                        else -- curr_state_exp = LAST
                            MonPro_C_X <= std_logic_vector(resize(one,MonPro_C_X'length));
                            MonPro_C_Y <= C_reg;
                            MonPro_S_X <= (others=>'0');
                            MonPro_S_Y <= (others=>'0');
                            MonPro_C_en_start <= '1';
                            MonPro_S_en_start <= '0';
                            
                        end if;
   
                    when BUSY_WAIT =>
                        busy <='1';
                        if curr_state_exp = LOOP_EXP and MP_busy = "00" then
                            if MonPro_S_en ='1' then
                                key_shift_reg <= std_logic_vector(shift_right(unsigned(key_shift_reg),1));
                            end if;
                            MonPro_S_X <= S_reg;
                            MonPro_S_Y <= S_reg;
                            MonPro_C_X <= C_reg;
                            MonPro_C_Y <= S_reg;
                            MonPro_S_en_start <= '1';
                            MonPro_C_en_start <= key_shift_reg(0); -- msb or lsb?? confused face
                        elsif curr_state_exp = LAST and MP_busy = "00" and next_state_mp/=MP_DONE_FSM then
                            MonPro_C_en_start <= '1';
                            MonPro_S_en_start <= '0';
                        else
                            MonPro_S_en_start <= '0';
                            MonPro_C_en_start <= '0';
                        end if;
                    when MP_DONE_FSM =>
                        busy <='1';
                        MP_done <= '1';
                        MonPro_S_en_start <= '0';
                        MonPro_C_en_start <= '0';
                end case;
            end if;
        end if;

    end process synchrounous_fsm_MP;

    combinational_fsm_monpro: process(curr_state_mp, MP_busy, counter, MP_start, MonPro_S_busy, MonPro_C_busy, curr_state_exp)
    begin
        case(curr_state_mp) is
            when IDLE =>
                if MP_start ='1' then
                    next_state_mp <= LOAD;
                else
                    next_state_mp <= IDLE;
                end if;
            when LOAD =>
                if MonPro_S_busy = '1' or MonPro_C_busy = '1' then
                    next_state_mp<=BUSY_WAIT;
                else
                    next_state_mp <= LOAD;
                end if;
            when BUSY_WAIT =>
                if MP_busy = "00" then
                    if curr_state_exp = LOOP_EXP then
                        if counter = bit_width then
                            next_state_mp <= MP_DONE_FSM;
                        else
                            next_state_mp <= BUSY_WAIT;
                        end if;
                    else
                        next_state_mp <= MP_DONE_FSM;
                    end if;
                else
                    next_state_mp <= BUSY_WAIT;
                end if;
            when MP_DONE_FSM =>
                next_state_mp <= IDLE;
        end case;
    end process combinational_fsm_monpro;
    
    falling_edge_busy: process(reset_n, clk)
    begin
        if rising_edge(clk) then
            MonPro_S_busy_f <= MonPro_S_busy;
            MonPro_C_busy_f <= MonPro_C_busy;
            if curr_state_exp = LOOP_EXP then
                if MonPro_S_busy_f='1' and MonPro_S_busy='0' then
                     counter <= counter+1;
                end if;
            else
                counter<=(others=>'0');
            end if;
--            if next_state_exp = INITIAL then
--                C_reg <= (others=>'0');
--                S_reg <= (others=>'0');
--            else
                if MonPro_S_busy_f='1' and MonPro_S_busy='0' then
                    S_reg <= S_s;
                end if;
                if MonPro_C_busy_f='1' and MonPro_C_busy='0' then
                    C_reg <= C_s;
                end if;
--            end if;
        end if;
    end process falling_edge_busy;



end Behavioral;
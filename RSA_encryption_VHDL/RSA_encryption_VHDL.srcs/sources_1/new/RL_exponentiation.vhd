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
            init:           in std_logic;
            key:            in std_logic_vector(bit_width-1 downto 0);
            N:              in std_logic_vector(bit_width-1 downto 0);
            r_squared:      in std_logic_vector(bit_width-1 downto 0); --Pre calculate in different register
            message:        in std_logic_vector(bit_width-1 downto 0);
            mux_select:     in std_logic_vector(1 downto 0);
            
            MonPro_busy:    out std_logic_vector(1 downto 0);
            MonPro_rdy:     in std_logic;
            MonPro_en_non_loop: in std_logic;

            Exp_done: in std_logic;
            
            shift_enable:   in std_logic;
            output_message: out std_logic_vector(bit_width-1 downto 0)
        );
end RL_exponentiation;

architecture Behavioral of RL_exponentiation is

signal C_reg, S_reg, N_reg: std_logic_vector(bit_width-1 downto 0);            -- Outputs from MonPro modules
signal C_s, S_s: std_logic_vector(bit_width-1 downto 0);           -- Outputs from MonPro modules
signal message_reg: std_logic_vector(bit_width-1 downto 0);
signal MonPro_C_X, MonPro_C_Y, MonPro_S_X, MonPro_S_Y: std_logic_vector(bit_width-1 downto 0);

signal key_shift_reg: std_logic_vector(bit_width-1 downto 0);
signal MonPro_C_busy, MonPro_S_busy,MonPro_C_busy_s, MonPro_S_busy_s: std_logic;
signal MonPro_C_en, MonPro_S_en: std_logic;


type state is (IDLE,START, MP, LOAD);
signal curr_state, next_state: state;

constant one: signed(1 downto 0) := "01";


begin
MonPro_C: entity work.MonPro 
            Generic(bit_width => bit_width);
            port map(clk => clk, reset_n => reset_n,
                      EN => MonPro_C_en, N=>N_reg,
                      X => MonPro_C_X, Y=> MonPro_C_Y,
                      Busy => MonPro_C_busy, Z => C_s);

MonPro_S: entity work.MonPro 
            Generic(bit_width => bit_width);
            port map(clk => clk, reset_n => reset_n,
                      EN => MonPro_S_en, N=>N_reg,
                      X => MonPro_S_X, Y=> MonPro_S_Y,
                      Busy => MonPro_S_busy,Z => S_s);

MonPro_busy <= MonPro_C_busy & MonPro_S_busy; 
output_message <= C_reg;


    -- Multiplexers infront of MonPro blocks
    MonPro_inputs: process(mux_select, C_reg,S_reg, message_reg, r_squared)
    begin
        case(mux_select) is
            when "00" =>
                MonPro_C_X <= std_logic_vector(resize(one,MonPro_C_X'length)); -- 1
                MonPro_C_Y <= r_squared;

                MonPro_S_X <= message_reg;
                MonPro_S_Y <= r_squared;
            when "01" =>
                MonPro_C_X <= C_reg;
                MonPro_C_Y <= S_reg;

                MonPro_S_X <= S_reg;
                MonPro_S_Y <= S_reg;
            when "10" =>
                MonPro_C_X <= std_logic_vector(resize(one,MonPro_C_X'length)); -- 1
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

    
    synch: process(clk, reset_n)
    begin
        if rising_edge(clk) then
            curr_state <= next_state;
            case(next_state) is
                when IDLE =>
                    MonPro_C_en   <= '0';
                    MonPro_S_en   <= '0';
                    message_reg   <= (others => '0');
                    N_reg         <= (others => '0');
                    C_reg         <= (others => '0');
                    S_reg         <= (others => '0');
                    key_shift_reg <= (others => '0');

                when START =>
                    message_reg <= message;
                    N_reg <= N;
                    key_shift_reg <= key;
                when MP =>
                    MonPro_C_en <= key_shift_reg(0) or MonPro_en_non_loop;
                    MonPro_S_en <= '1';
                when LOAD =>
                    C_reg <= C_s;
                    S_reg <= S_s;
                    MonPro_C_en <= '0';
                    MonPro_S_en <= '0';

                    if shift_enable = '1' then
                        key_shift_reg <= '0' & key_shift_reg(bit_width-1 downto 1);
                    end if;
            end case;
        end if;

    end process synch;

    comb: process(curr_state, MonPro_S_busy,MonPro_C_busy, init, Exp_done)
    begin
        case(curr_state) is
            when IDLE =>
                if init = '1' then
                    next_state <= START;
                else
                    next_state <= IDLE;
                end if;
            when START =>
                next_state <= MP;
            when MP =>
                if MonPro_S_busy = '0' and MonPro_C_busy = '0' then
                    next_state <= LOAD;
                else
                    next_state <= MP;
                end if;
            when LOAD =>
                if Exp_done ='1' then
                    next_state <= IDLE;
                else
                    next_state <= MP;
                end if;
        end case;

    end process comb;
end Behavioral;

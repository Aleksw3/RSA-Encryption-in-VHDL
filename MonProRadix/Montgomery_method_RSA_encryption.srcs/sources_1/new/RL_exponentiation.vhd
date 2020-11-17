library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity exponentiation is
    generic (
        C_block_size : integer := 256
    );
    port (
         -- basic important
         clk:            in std_logic;
         reset_n:        in std_logic;
         -- input values
         KEY:            in std_logic_vector(C_block_size-1 downto 0);
         N:              in std_logic_vector(C_block_size-1 downto 0);
         MESSAGE:        in std_logic_vector(C_block_size-1 downto 0);
         R2N:            in std_logic_vector(C_block_size-1 downto 0);
         N_inv:          in std_logic_vector(1 downto 0);
         
         output_message: out std_logic_vector(C_block_size-1 downto 0);
         
         -- control logic
         init:           in  std_logic;
         busy:           out std_logic;
         done:           out std_logic
         
    );
end exponentiation;


architecture expBehave of exponentiation is

-- Registers for inputs
signal C_reg, S_reg, N_reg, R_reg, R2N_reg: std_logic_vector(C_block_size downto 0);            -- Outputs from MonPro modules
signal message_reg: std_logic_vector(C_block_size downto 0);

--Signals informing and showing the status of the MonPro
signal MonPro_C_busy, MonPro_S_busy: std_logic;
signal MonPro_C_en, MonPro_S_en: std_logic;
signal MonPro_C_en_start, MonPro_S_en_start: std_logic:='0';
signal MP_done: std_logic:= '0';
signal MP_start: std_logic:='0';

--MonPro inputs
signal MonPro_C_X,MonPro_C_Y: std_logic_vector(C_block_size downto 0);
signal MonPro_S_X,MonPro_S_Y: std_logic_vector(C_block_size downto 0);
signal MonPro_C_Carry_out,MonPro_C_Sum_out: std_logic_vector(C_block_size-1 downto 0);
signal MonPro_C_Carry_out_reg,MonPro_C_Sum_out_reg: std_logic_vector(C_block_size-1 downto 0);
signal MonPro_S_Carry_out,MonPro_S_Sum_out: std_logic_vector(C_block_size-1 downto 0);
signal MonPro_S_Carry_out_reg,MonPro_S_Sum_out_reg: std_logic_vector(C_block_size-1 downto 0);
signal MonPro_S_out_rdy: std_logic:= '0';
signal MonPro_C_out_rdy: std_logic:= '0';
signal KSA_enable: std_logic:='0';
signal MonPro_C_EN_f, MonPro_S_EN_f: std_logic;
signal KSA_input_X, KSA_input_Y: std_logic_vector(C_block_size-1 downto 0);
signal KSA_output: std_logic_vector(C_block_size downto 0); 

signal KSA_counter: unsigned(1 downto 0):="00";


signal S_s, C_s: std_logic_vector(C_block_size downto 0);

-- State machine for the MonPro exponential
type state_exp is (IDLE,INITIAL,LOOP_EXP,LAST,DATA_OUT);
signal curr_state_exp, next_state_exp: state_exp;

-- State machine for the MonPro calculation
type state_mp is (IDLE,LOAD,BUSY_WAIT,MP_DONE_FSM);
signal curr_state_mp, next_state_mp: state_mp;

-- shift register
signal key_shift_reg: std_logic_vector(C_block_size-1 downto 0);
signal key_reg:       std_logic_vector(C_block_size-1 downto 0);
signal counter:       unsigned (8 downto 0);
signal MonPro_S_busy_f, MonPro_C_busy_f: std_logic:='0';

signal MP_busy: std_logic_vector(1 downto 0);
constant one: signed(1 downto 0) := "01";

begin

-----------------------------------------------------------------------------------------------
---------------- Port man for 2 Montgomery multiplication blocks-------------------------------
-----------------------------------------------------------------------------------------------
MonPro_C: entity work.MonPro 
            generic map(C_block_size => C_block_size)
            port map (clk => clk, reset_n => reset_n,
                      EN => MonPro_C_en, N=>N_reg,
                      N_inv => N_inv,
                      X => MonPro_C_X, Y=> MonPro_C_Y,
                      Busy => MonPro_C_busy, 
                      Carry => MonPro_C_Carry_out,
                      Sum => MonPro_C_Sum_out);

MonPro_S: entity work.MonPro 
            generic map(C_block_size => C_block_size)
            port map (clk => clk, reset_n => reset_n,
                      EN => MonPro_S_en, N=>N_reg,
                      N_inv => N_inv,
                      X => MonPro_S_X, Y=> MonPro_S_Y,
                      Busy => MonPro_S_busy,
                      Carry => MonPro_S_Carry_out,
                      Sum => MonPro_S_Sum_out);
KSA_adder: entity work.KoggeStoneAdder
            port map(
                i_x => KSA_input_X,
                i_y => KSA_input_Y,
                o_result => KSA_output
            );



--  Port (i_x, i_y : in std_logic_vector(255 downto 0);
--        o_result   : out std_logic_vector(256 downto 0));

MP_busy <= MonPro_C_busy & MonPro_S_busy;

MonPro_S_en <= MonPro_S_en_start or MonPro_S_busy;
MonPro_C_en <= MonPro_C_en_start or MonPro_C_busy;

-----------------------------------------------------------------------------------------------
--------------------- FSM for entire exponentiation--------------------------------------------
---------------------------Synchronous stage---------------------------------------------------
-----------------------------------------------------------------------------------------------
-- INITIAL calculates the first MP(1,r*r%n) and MP(M,r*r%n)
-- LOOP_EXP loops through each bit in the key and performs RL-montogmery algorithm
-- LAST performs the last calculation of MP(1,C)
-- DATA_OUT makes sure data is sent out of the 

    synchrounous_fsm_exp: process(clk, reset_n)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                curr_state_exp  <=IDLE;
                done            <='0';
                MP_start        <='0';
                N_reg           <=(others =>'0');
                R2N_reg         <=(others =>'0');
                message_reg     <=(others =>'0');
                key_reg         <=(others =>'0');
                output_message  <=(others =>'0');
            else
                curr_state_exp <= next_state_exp;
                case(curr_state_exp) is
                    when IDLE =>
                        done <='1';
                        busy<= '0';
                        if next_state_exp = INITIAL then
                            MP_start<='1';
                        else
                            MP_start<='0';
                        end if;
                    when INITIAL =>
                        busy<= '1';
                        done <= '0';
                        N_reg <= '0'&N;
                        R2N_reg <= '0'&R2N; -- R^2 % n, input constant
                        message_reg <= '0'&MESSAGE;
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
                        busy<= '1'; 
                        done <= '1';
                        MP_start<='0';
                        output_message <= C_reg(C_block_size-1 downto 0);
                end case;
            end if;
        end if;

    end process synchrounous_fsm_exp;

-----------------------------------------------------------------------------------------------
--------------------- Combinational FSM Stage--------------------------------------------------
-----------------------------------------------------------------------------------------------
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


-----------------------------------------------------------------------------------------------
---------------- FSM for each calculation step of the exponentiation---------------------------
---------------------------Synchronous stage---------------------------------------------------
-----------------------------------------------------------------------------------------------

    synchrounous_fsm_MP: process(clk, reset_n)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                curr_state_mp     <= IDLE;
                MP_done           <= '0';
--                busy              <= '0';                
                MonPro_C_X        <= (others=>'0');
                MonPro_C_Y        <= (others=>'0');
                MonPro_S_X        <= (others=>'0');
                MonPro_S_Y        <= (others=>'0');
                MonPro_S_en_start <= '0';
                MonPro_C_en_start <= '0';
            else
                curr_state_mp <= next_state_mp;
                case(curr_state_mp) is
                    when IDLE =>
                        MP_done           <= '0';
--                        busy              <= '0';                
                        MonPro_C_X        <= (others=>'0');
                        MonPro_C_Y        <= (others=>'0');
                        MonPro_S_X        <= (others=>'0');
                        MonPro_S_Y        <= (others=>'0');
                        MonPro_S_en_start <= '0';
                        MonPro_C_en_start <= '0';
                    when LOAD =>
--                        busy <='1';
                        if curr_state_exp = INITIAL then
                            MonPro_C_X <= std_logic_vector(resize(one,MonPro_C_X'length));
                            MonPro_C_Y <= R2N_reg;
                            MonPro_S_X <= message_reg;
                            MonPro_S_Y <= R2N_reg;
                            
                            MonPro_S_en_start <= '1';
                            MonPro_C_en_start <= '1';
    
                        elsif curr_state_exp = LOOP_EXP then
                            MonPro_C_X <= C_reg;
                            MonPro_C_Y <= S_reg;
                            
                            MonPro_S_X <= S_reg;
                            MonPro_S_Y <= S_reg;
                            
                            MonPro_S_en_start <= '1';
                            MonPro_C_en_start <= key_reg(0);
                            key_shift_reg <= '0'&key_reg(C_block_size-1 downto 1);
                        else -- curr_state_exp = LAST
                            MonPro_C_X <= std_logic_vector(resize(one,MonPro_C_X'length));
                            MonPro_C_Y <= C_reg;
                            MonPro_S_X <= (others=>'0');
                            MonPro_S_Y <= (others=>'0');
                            MonPro_C_en_start <= '1';
                            MonPro_S_en_start <= '0';
                            
                        end if;
   
                    when BUSY_WAIT =>
--                        busy <='1';
                        if curr_state_exp = LOOP_EXP and MP_busy = "00" then
                            if MonPro_S_out_rdy = '0' and MonPro_C_out_rdy = '0' then
                                if MonPro_S_en ='1' then
                                    key_shift_reg <= std_logic_vector(shift_right(unsigned(key_shift_reg),1));
                                end if;
                                MonPro_C_X <= C_reg;
                                MonPro_C_Y <= S_reg;     
                                MonPro_S_X <= S_reg;
                                MonPro_S_Y <= S_reg;      
                                                      
                                MonPro_S_en_start <= '1';
                                MonPro_C_en_start <= key_shift_reg(0);
                            else
                                MonPro_S_en_start <= '0';
                                MonPro_C_en_start <= '0';
                            end if;
                        elsif curr_state_exp = LAST and MP_busy = "00" and next_state_mp/=MP_DONE_FSM then
                            MonPro_C_en_start <= '1';
                            MonPro_S_en_start <= '0';
                        else
                            MonPro_S_en_start <= '0';
                            MonPro_C_en_start <= '0';
                        end if;
                    when MP_DONE_FSM =>
                        MonPro_S_en_start <= '0';
                        MonPro_C_en_start <= '0';
                        if MonPro_S_out_rdy = '0' and MonPro_C_out_rdy = '0' then --Wait for KSA to finish
                            MP_done <= '1';
                        end if;
                end case;
            end if;
        end if;

    end process synchrounous_fsm_MP;

-----------------------------------------------------------------------------------------------
-----------------------Combinational stage for calculation FSM---------------------------------
-----------------------------------------------------------------------------------------------

    combinational_fsm_monpro: process(curr_state_mp, MP_busy, counter, MP_start, MonPro_S_busy, MonPro_C_busy, curr_state_exp, MonPro_S_out_rdy,MonPro_C_out_rdy)
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
                        if MonPro_S_out_rdy = '0' and MonPro_C_out_rdy = '0' then
                            if counter = C_block_size-1 then
                                next_state_mp <= MP_DONE_FSM;
                            else
                                next_state_mp <= BUSY_WAIT;
                            end if;
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
                if MonPro_S_out_rdy = '0' and MonPro_C_out_rdy = '0' then
                    next_state_mp <= IDLE;
                else
                    next_state_mp <= MP_DONE_FSM;
                end if;
        end case;
    end process combinational_fsm_monpro;
   
-----------------------------------------------------------------------------------------------
--------------Update C and S registers in falling flank of busy--------------------------------
-----------------------------------------------------------------------------------------------

    falling_edge_busy: process(reset_n, clk)
    begin
        if rising_edge(clk) then
            MonPro_S_busy_f <= MonPro_S_busy; 
            MonPro_C_busy_f <= MonPro_C_busy;
            
            MonPro_S_EN_f <= MonPro_S_EN; 
            MonPro_C_EN_f <= MonPro_C_EN;

            if curr_state_exp = LOOP_EXP then
                if MonPro_S_busy_f='1' and MonPro_S_busy='0' then
                     counter <= counter+1; -- Update counter used in LOOP_EXP on falling flank for MP_S_busy which is always used in the loop
                end if;
            else
                counter<=(others=>'0');
            end if;
            if (MonPro_S_EN_f = '0' and MonPro_S_EN = '1') or (MonPro_C_EN_f = '0' and MonPro_C_EN = '1') then
                if MonPro_C_EN_f = '0' and MonPro_C_EN = '1' then --Check for rising flank
                    MonPro_C_out_rdy <= '1';
                end if;
                if MonPro_S_EN_f='0' and MonPro_S_EN='1' then
                    MonPro_S_out_rdy <= '1';
                end if;
            elsif (MonPro_S_busy_f='1' and MonPro_S_busy='0') or (MonPro_C_busy_f='1' and MonPro_C_busy='0') then
                if MonPro_S_busy_f='1' and MonPro_S_busy='0' then --Check for falling flank
                    MonPro_S_Carry_out_reg <= MonPro_S_Carry_out;
                    MonPro_S_Sum_out_reg   <= MonPro_S_Sum_out;
                    MonPro_S_out_rdy <= '1';
                    --S_reg <= S_s;
                end if;
                if MonPro_C_busy_f='1' and MonPro_C_busy='0' then
                    MonPro_C_Carry_out_reg <= MonPro_C_Carry_out;
                    MonPro_C_Sum_out_reg   <= MonPro_C_Sum_out;
                    MonPro_C_out_rdy <= '1';
                    --C_reg <= C_s;
                end if;
            else
                -- This only happens after a monpro finishes
                if MonPro_S_out_rdy = '1' and MonPro_S_EN = '0' then
                    if KSA_enable = '0' then
                        KSA_enable<='1';
                        KSA_counter <= (others=>'0');
                        KSA_input_X <= MonPro_S_Carry_out_reg;
                        KSA_input_Y <= MonPro_S_Sum_out_reg;
                    else
                        if KSA_counter = 3 then
                            KSA_enable <= '0';
                            MonPro_S_out_rdy <= '0';
                            S_reg <= KSA_output;
                        else
                            KSA_counter <= KSA_counter + 1;
                        end if;
                    end if;
                elsif MonPro_C_out_rdy = '1' and MonPro_C_EN = '0' then
                    if KSA_enable = '0' then
                        KSA_enable<='1';
                        KSA_counter <= (others=>'0');
                        KSA_input_X <= MonPro_C_Carry_out_reg;
                        KSA_input_Y <= MonPro_C_Sum_out_reg;
                    else
                        if KSA_counter = 3 then
                            KSA_enable <= '0';
                            MonPro_C_out_rdy <= '0';
                            C_reg <= KSA_output;
                        else
                            KSA_counter <= KSA_counter + 1;
                        end if;
                    end if;
                end if;
            end if;

        end if;
    end process falling_edge_busy;

end expBehave;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity RSA_Core is
    Generic(
            C_BLOCK_SIZE: integer:=256;
            radix:        integer:=2
    );
    Port ( 
        -----------------------------------------------------------------------------
        -- Clocks and reset
        -----------------------------------------------------------------------------
        clk:     in std_logic;
        reset_n: in std_logic;

        -----------------------------------------------------------------------------
        -- Slave msgin interface
        -----------------------------------------------------------------------------
        -- Message that will be sent out is valid
        msgin_valid: in std_logic;
        -- Slave ready to accept a new message
        msgin_ready: out std_logic;
        -- Indicates boundary of last packet
        msgin_last:  in std_logic;
        -- Message that will be sent out of the rsa_msgin module
        msgin_data:  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        
        

        -----------------------------------------------------------------------------
        -- Master msgout interface
        -----------------------------------------------------------------------------
        -- Slave ready to accept a new message
        msgout_valid: out std_logic;
        -- Message that will be sent out is valid
        msgout_ready: in std_logic;
        -- Indicates boundary of last packet
        msgout_last:  out std_logic;
        -- Message that will be sent out of the rsa_msgin module        
        msgout_data:  out std_logic_vector(C_BLOCK_SIZE-1 downto 0);

        -----------------------------------------------------------------------------
        -- Interface to the register block
        -----------------------------------------------------------------------------
        key_n:      in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        key_e_d:    in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        rsa_status: out std_logic_vector(31 downto 0);

        -- Additional value/constant saved in rsa_regio
        R2N:        in std_logic_vector(C_BLOCK_SIZE-1 downto 0); --r^2 % n
        mod_inv:    in std_logic_vector(radix-1 downto 0)
    );
end RSA_Core;

architecture Behavioral of RSA_Core is
signal multiple_out:     std_logic := '0';
signal init: std_logic:='0';
signal last_input_msg:   std_logic:='0';
signal msgout_data_reg:  std_logic_vector(C_BLOCK_SIZE-1 downto 0);
signal msgin_data_reg0,msgin_data_reg1,msgin_data_reg2,msgin_data_reg3,msgin_data_reg4:   std_logic_vector(C_BLOCK_SIZE-1 downto 0);

signal key_n_reg, key_e_d_reg, R2N_reg: std_logic_vector(C_BLOCK_SIZE-1 downto 0);
signal mod_inv_reg: std_logic_vector(radix-1 downto 0);
signal msgin_valid_reg, msgin_last_reg, msgout_ready_reg, msgout_valid_reg: std_logic;
signal msgin_data_reg: std_logic_vector(C_BLOCK_SIZE-1 downto 0);

type msgin_state  is (IDLE_IN,Exp_in_0,Exp_in_1,Exp_in_2,Exp_in_3,Exp_in_4);
type msgout_state is (IDLE_OUT,Exp_out_0,Exp_out_1,Exp_out_2,Exp_out_3,Exp_out_4);
signal curr_msgin_exp, next_msgin_exp: msgin_state;
signal curr_msgout_exp, next_msgout_exp, last_msgout_exp: msgout_state;

signal exp_0_busy,exp_1_busy,exp_2_busy,exp_3_busy,exp_4_busy: std_logic;
signal exp_0_init,exp_1_init,exp_2_init,exp_3_init,exp_4_init: std_logic:='0';
signal exp_0_done,exp_1_done,exp_2_done,exp_3_done,exp_4_done: std_logic; 
signal last_input_msg_exp0,last_input_msg_exp1,last_input_msg_exp2,last_input_msg_exp3,last_input_msg_exp4:   std_logic:='0';

signal exp_0_output,exp_1_output,exp_2_output,exp_3_output,exp_4_output: std_logic_vector(C_BLOCK_SIZE-1 downto 0);
signal msgout_valid_0_s, msgout_valid_1_s, msgout_valid_2_s, msgout_valid_3_s, msgout_valid_4_s:   std_logic;

signal msgin_ready_s: std_logic:='0';

begin

-----------------------------------------------------------------------------------------------
--------------------- Exponentiation component port map ---------------------------------------
-----------------------------------------------------------------------------------------------
    --rl_exp: entity work.RL_Exponentiation 
    Exp_0_port_map: entity work.exponentiation 
                generic map(C_BLOCK_SIZE => C_BLOCK_SIZE)
                port map(clk => clk, 
                         reset_n => reset_n, 
                         KEY => key_e_d_reg, 
                         N => key_n_reg,
                         mod_inv => mod_inv_reg,
                         MESSAGE => msgin_data_reg0,
                         busy => exp_0_busy,
                         init => exp_0_init,
                         done => exp_0_done,
                         R2N => R2N_reg,
                         output_message => exp_0_output);
    Exp_1_port_map: entity work.exponentiation 
                generic map(C_BLOCK_SIZE => C_BLOCK_SIZE)
                port map(clk => clk, 
                         reset_n => reset_n, 
                         KEY => key_e_d_reg, 
                         N => key_n_reg,
                         mod_inv => mod_inv_reg,
                         MESSAGE => msgin_data_reg1,
                         busy => exp_1_busy,
                         init => exp_1_init,
                         done => exp_1_done,
                         R2N => R2N_reg,
                         output_message => exp_1_output);
    Exp_2_port_map: entity work.exponentiation 
                generic map(C_BLOCK_SIZE => C_BLOCK_SIZE)
                port map(clk => clk, 
                         reset_n => reset_n, 
                         KEY => key_e_d_reg, 
                         N => key_n_reg,
                         mod_inv => mod_inv_reg,
                         MESSAGE => msgin_data_reg2,
                         busy => exp_2_busy,
                         init => exp_2_init,
                         done => exp_2_done,
                         R2N => R2N_reg,
                         output_message => exp_2_output);
    Exp_3_port_map: entity work.exponentiation 
                generic map(C_BLOCK_SIZE => C_BLOCK_SIZE)
                port map(clk => clk, 
                         reset_n => reset_n, 
                         KEY => key_e_d_reg, 
                         N => key_n_reg,
                         mod_inv => mod_inv_reg,
                         MESSAGE => msgin_data_reg3,
                         busy => exp_3_busy,
                         init => exp_3_init,
                         done => exp_3_done,
                         R2N => R2N_reg,
                         output_message => exp_3_output);
     Exp_4_port_map: entity work.exponentiation 
                generic map(C_BLOCK_SIZE => C_BLOCK_SIZE)
                port map(clk => clk, 
                         reset_n => reset_n, 
                         KEY => key_e_d_reg, 
                         N => key_n_reg,
                         mod_inv => mod_inv_reg,
                         MESSAGE => msgin_data_reg4,
                         busy => exp_4_busy,
                         init => exp_4_init,
                         done => exp_4_done,
                         R2N => R2N_reg,
                         output_message => exp_4_output);

    

-----------------------------------------------------------------------------------------------
--------------------- Message In Signalling----------------------------------------------------
-----------------------------------------------------------------------------------------------
    -- ready to receive if exponentiation function is not busy
    msgin_ready  <= msgin_ready_s; 
    msgout_data  <= msgout_data_reg;
    msgout_valid <= msgout_valid_0_s or msgout_valid_1_s or msgout_valid_2_s or msgout_valid_3_s or msgout_valid_4_s;
    rsa_status   <= R2N(C_BLOCK_SIZE-1 downto C_BLOCK_SIZE-32);



    input_registers:process(clk,reset_n)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                msgin_valid_reg <= '0';
                msgin_last_reg <= '0';
                msgout_ready_reg <= '0';
                msgin_data_reg <= (others =>'0');
                key_n_reg <= (others =>'0');
                key_e_d_reg <= (others =>'0');
                R2N_reg <= (others =>'0');
                mod_inv_reg <= (others =>'0');
            else
                msgin_valid_reg <= msgin_valid;
                msgin_last_reg <= msgin_last;
                msgin_data_reg <= msgin_data;
                key_n_reg <= key_n;
                key_e_d_reg <= key_e_d;
                R2N_reg <= R2N;
                mod_inv_reg <= mod_inv;
            end if;
        end if;
    end process input_registers;


    message_in_synchonous_FSM:process(reset_n, clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
            else
                curr_msgin_exp <= next_msgin_exp;
                case(curr_msgin_exp) is
                    when IDLE_IN =>
                        -- Waiting for msgout to finish before a new message starts
                    when Exp_in_0 =>
                        if msgin_valid_reg = '1' and exp_0_busy = '0' and curr_msgout_exp /= Exp_out_0 then
                            if init = '0' then
                                init <= '1';
                                exp_0_init<= '1';
                                msgin_ready_s <= '1';
                                msgin_data_reg0 <= msgin_data_reg;
                                if msgin_last_reg = '1' then    -- Check if this is the last message or not
                                    last_input_msg_exp0 <= '1'; 
                                else
                                    last_input_msg_exp0 <= '0';
                                end if;
                            else
                                msgin_ready_s <= '0';
                            end if;
                        else
                            init <= '0';
                            msgin_ready_s <= '0';
                            exp_0_init<= '0';
                        end if;
                    when Exp_in_1 =>
                        last_msgout_exp <= Exp_out_1;
                        if msgin_valid_reg = '1' and exp_1_busy = '0' and curr_msgout_exp /= Exp_out_1 then
                            if init = '0' then
                                init <= '1';
                                exp_1_init<= '1';
                                msgin_ready_s <= '1';
                                msgin_data_reg1 <= msgin_data_reg;
                                if msgin_last_reg = '1' then    -- Check if this is the last message or not
                                    last_input_msg_exp1 <= '1'; 
                                else
                                    last_input_msg_exp1 <= '0';
                                end if;
                            else
                                msgin_ready_s <= '0';
                            end if;
                        else
                            init <= '0';
                            exp_1_init<= '0';
                            msgin_ready_s <= '0';
                        end if;
                    when Exp_in_2 =>
                        if msgin_valid_reg = '1' and exp_2_busy = '0' and curr_msgout_exp /= Exp_out_2 then
                            if init = '0' then
                                init <= '1';
                                exp_2_init<= '1';
                                msgin_ready_s <= '1';
                                msgin_data_reg2 <= msgin_data_reg;
                                if msgin_last_reg = '1' then    -- Check if this is the last message or not
                                    last_input_msg_exp2 <= '1'; 
                                else
                                    last_input_msg_exp2 <= '0';
                                end if;
                            else
                                msgin_ready_s <= '0';
                            end if;
                        else
                            init <= '0';
                            exp_2_init<= '0';
                            msgin_ready_s <= '0';
                        end if;
                    when Exp_in_3 =>
                        if msgin_valid_reg = '1' and exp_3_busy = '0' and curr_msgout_exp /= Exp_out_3 then
                            if init = '0' then
                                init <= '1';
                                exp_3_init<= '1';
                                msgin_ready_s <= '1';
                                msgin_data_reg3 <= msgin_data_reg;
                                if msgin_last_reg = '1' then    -- Check if this is the last message or not
                                    last_input_msg_exp3 <= '1'; 
                                else
                                    last_input_msg_exp3 <= '0';
                                end if;
                            else
                                msgin_ready_s <= '0';
                            end if;
                        else
                            init <= '0';
                            exp_3_init<= '0';
                            msgin_ready_s <= '0';
                        end if;
                     when Exp_in_4 =>
                        if msgin_valid_reg = '1' and exp_4_busy = '0' and curr_msgout_exp /= Exp_out_4 then
                            if init = '0' then
                                init <= '1';
                                exp_4_init<= '1';
                                msgin_ready_s <= '1';
                                msgin_data_reg4 <= msgin_data_reg;
                                if msgin_last_reg = '1' then    -- Check if this is the last message or not
                                    last_input_msg_exp4 <= '1'; 
                                else
                                    last_input_msg_exp4 <= '0';
                                end if;
                            else
                                msgin_ready_s <= '0';
                            end if;
                        else
                            init <= '0';
                            exp_4_init<= '0';
                            msgin_ready_s <= '0';
                        end if;
                end case;
            end if;
        end if;
    end process message_in_synchonous_FSM;


    message_in_combinational_FSM:process(curr_msgin_exp,curr_msgout_exp,exp_0_busy,exp_1_busy,exp_2_busy,exp_3_busy,exp_4_busy,last_input_msg_exp0,last_input_msg_exp1,last_input_msg_exp2,last_input_msg_exp3,last_input_msg_exp4)
    begin
        case(curr_msgin_exp) is
            WHEN IDLE_IN =>
                if curr_msgout_exp = IDLE_OUT then
                    next_msgin_exp <= Exp_in_0;
                else
                    next_msgin_exp <= IDLE_IN;
                end if;
            when Exp_in_0 =>
                if curr_msgout_exp /= Exp_out_0 then
                    if exp_0_busy = '1' then
                        if last_input_msg_exp0 = '0' then
                            next_msgin_exp <= Exp_in_1;
                        else
                            next_msgin_exp <= IDLE_IN;
                        end if;
                    else
                        next_msgin_exp <= Exp_in_0;
                    end if;
                else
                    next_msgin_exp <= Exp_in_0;
                end if;
            when Exp_in_1 =>
                if curr_msgout_exp /= Exp_out_1 then
                    if exp_1_busy = '1' then
                        if last_input_msg_exp1 = '0' then
                            next_msgin_exp <= Exp_in_2;
                        else
                            next_msgin_exp <= IDLE_IN;
                        end if;
                    else
                        next_msgin_exp <= Exp_in_1;
                    end if;
                else
                    next_msgin_exp <= Exp_in_1;
                end if;
            when Exp_in_2 =>
                if curr_msgout_exp /= Exp_out_2 then
                    if exp_2_busy = '1'  then
                        if last_input_msg_exp2 = '0' then
                            next_msgin_exp <= Exp_in_3;
                        else
                            next_msgin_exp <= IDLE_IN;
                        end if;
                    else
                        next_msgin_exp <= Exp_in_2;
                    end if;
                else
                    next_msgin_exp <= Exp_in_2;
                end if;
            when Exp_in_3 =>
                if curr_msgout_exp /= Exp_out_3 then
                    if exp_3_busy = '1' then
                        if last_input_msg_exp3 = '0' then
                            next_msgin_exp <= Exp_in_4;
                        else
                            next_msgin_exp <= IDLE_IN;
                        end if;
                    else
                        next_msgin_exp <= Exp_in_3;
                    end if;
                else
                    next_msgin_exp <= Exp_in_3;
                end if;
            when Exp_in_4 =>
                if curr_msgout_exp /= Exp_out_4 then
                    if exp_4_busy = '1' then
                        if last_input_msg_exp4 = '0' then
                            next_msgin_exp <= Exp_in_0;
                        else
                            next_msgin_exp <= IDLE_IN;
                        end if;
                    else
                        next_msgin_exp <= Exp_in_4;
                    end if;
                else
                    next_msgin_exp <= Exp_in_4;
                end if;
        end case;
    end process message_in_combinational_FSM;


    message_out_synchonous_FSM:process(reset_n, clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
            else
                curr_msgout_exp <= next_msgout_exp;
                case(curr_msgout_exp) is
                    when IDLE_OUT =>
                    -- Idle state, waiting for message in to start processing 
                        msgout_last <= '0';
                        msgout_valid_0_s <= '0';
                        msgout_valid_1_s <= '0';
                        msgout_valid_2_s <= '0';
                        msgout_valid_3_s <= '0';
                        msgout_valid_4_s <= '0';
                    when Exp_out_0 =>
                        msgout_valid_1_s <= '0';
                        msgout_valid_2_s <= '0';
                        msgout_valid_3_s <= '0';
                        msgout_valid_4_s <= '0';
                         if exp_0_busy = '0' then
                              if msgout_valid_0_s = '0' then
                                msgout_valid_0_s <= '1';
                                if last_input_msg_exp0 = '1' then
                                    msgout_last <= '1';
                                else
                                    msgout_last <= '0';
                                end if;
                            elsif msgout_ready = '1'  then
                                msgout_valid_0_s <= '0';
                                msgout_last <= '0';
                            end if;
                        end if;

                        msgout_data_reg  <= exp_0_output;

                        if last_input_msg_exp0 = '1' then
                            msgout_last <= '1';
                        else
                            msgout_last <= '0';
                        end if;
                    when Exp_out_1 =>
                        msgout_valid_0_s <= '0';
                        msgout_valid_2_s <= '0';
                        msgout_valid_3_s <= '0';
                        msgout_valid_4_s <= '0';
                        if exp_1_busy = '0' then
                            if msgout_valid_1_s = '0' then
                                msgout_valid_1_s <= '1';
                                if last_input_msg_exp1 = '1' then
                                    msgout_last <= '1';
                                else
                                    msgout_last <= '0';
                                end if;
                            elsif msgout_ready = '1'  then
                                msgout_valid_1_s <= '0';
                                msgout_last <= '0';
                            end if;
                        end if;
                        msgout_data_reg  <= exp_1_output;
                        if last_input_msg_exp1 = '1' then
                            msgout_last <= '1';
                        else
                            msgout_last <= '0';
                        end if;
                    when Exp_out_2 =>
                        msgout_valid_0_s <= '0';
                        msgout_valid_1_s <= '0';
                        msgout_valid_3_s <= '0';
                        msgout_valid_4_s <= '0';
                         if exp_2_busy = '0' then
                            if msgout_valid_2_s = '0' then
                                msgout_valid_2_s <= '1';
                                if last_input_msg_exp2 = '1' then
                                    msgout_last <= '1';
                                else
                                    msgout_last <= '0';
                                end if;
                            elsif msgout_ready = '1'  then
                                msgout_valid_2_s <= '0';
                                msgout_last <= '0';
                            end if;
                        end if;
                        msgout_data_reg  <= exp_2_output;
                        if last_input_msg_exp2 = '1' then
                            msgout_last <= '1';
                        else
                            msgout_last <= '0';
                        end if;
                    when Exp_out_3 =>
                        msgout_valid_0_s <= '0';
                        msgout_valid_1_s <= '0';
                        msgout_valid_2_s <= '0';
                        msgout_valid_4_s <= '0';
                        if exp_3_busy = '0' then
                            if msgout_valid_3_s = '0' then
                                msgout_valid_3_s <= '1';
                                if last_input_msg_exp3 = '1' then
                                    msgout_last <= '1';
                                else
                                    msgout_last <= '0';
                                end if;
                            elsif msgout_ready = '1'  then
                                msgout_valid_3_s <= '0';
                                msgout_last <= '0';
                            end if;
                        else
                            msgout_valid_3_s <= '0';
                        end if;
                        msgout_data_reg  <= exp_3_output;
                   when Exp_out_4 =>
                        msgout_valid_0_s <= '0';
                        msgout_valid_1_s <= '0';
                        msgout_valid_2_s <= '0';
                        msgout_valid_3_s <= '0';
                        if exp_4_busy = '0' then
                            if msgout_valid_4_s = '0' then
                                msgout_valid_4_s <= '1';
                                if last_input_msg_exp4 = '1' then
                                    msgout_last <= '1';
                                else
                                    msgout_last <= '0';
                                end if;
                            elsif msgout_ready = '1'  then
                                msgout_valid_4_s <= '0';
                                msgout_last <= '0';
                            end if;
                        else
                            msgout_valid_4_s <= '0';
                        end if;
                        msgout_data_reg  <= exp_4_output;
                end case;
            end if;
        end if;
    end process message_out_synchonous_FSM;

    MSGOUT_combinational_FSM:process(curr_msgout_exp, init, msgout_valid_0_s,msgout_valid_1_s,msgout_valid_2_s,msgout_valid_3_s,msgout_valid_3_s, last_input_msg_exp0, last_input_msg_exp1, last_input_msg_exp2,last_input_msg_exp3 ,last_input_msg_exp4,msgout_ready, exp_0_busy, exp_1_busy, exp_2_busy, exp_3_busy, exp_4_busy)
    begin
        case(curr_msgout_exp) is
            when IDLE_OUT =>
                if exp_0_busy = '1' then
                    next_msgout_exp <= Exp_out_0;
                else
                    next_msgout_exp <= IDLE_OUT;
                end if;
            when Exp_out_0 =>
                if msgout_ready = '1' and msgout_valid_0_s = '1' then
                    if last_input_msg_exp0 = '0' then
                        next_msgout_exp <= Exp_out_1;
                    else
                        next_msgout_exp <= IDLE_OUT;
                    end if;
                else
                    next_msgout_exp <= Exp_out_0;
                end if;
            when Exp_out_1 =>
                if msgout_ready = '1' and msgout_valid_1_s = '1' then
                    if last_input_msg_exp1 = '0' then
                        next_msgout_exp <= Exp_out_2;
                    else
                        next_msgout_exp <= IDLE_OUT;
                    end if;
                else
                    next_msgout_exp <= Exp_out_1;
                end if;
            when Exp_out_2 =>
                if msgout_ready = '1' and msgout_valid_2_s = '1' then
                    if last_input_msg_exp2 = '0' then
                        next_msgout_exp <= Exp_out_3;
                    else
                        next_msgout_exp <= IDLE_OUT;
                    end if;
                else
                    next_msgout_exp <= Exp_out_2;
                end if;
            when Exp_out_3 =>
                if msgout_ready = '1' and msgout_valid_3_s = '1' then
                    if last_input_msg_exp3 = '0' then
                        next_msgout_exp <= Exp_out_4;
                    else
                        next_msgout_exp <= IDLE_OUT;
                    end if;
                else
                    next_msgout_exp <= Exp_out_3;
                end if;
            when Exp_out_4 =>
                if msgout_ready = '1' and msgout_valid_4_s = '1' then
                    if last_input_msg_exp4 = '0' then
                        next_msgout_exp <= Exp_out_0;
                    else
                        next_msgout_exp <= IDLE_OUT;
                    end if;
                else
                    next_msgout_exp <= Exp_out_4;
                end if;
        end case;
    end process MSGOUT_combinational_FSM;

end Behavioral;

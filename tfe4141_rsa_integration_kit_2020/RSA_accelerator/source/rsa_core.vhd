library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity RSA_Core is
    Generic(
            C_BLOCK_SIZE: integer:=256
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
        key_n: in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        key_e_d: in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
        rsa_status: out std_logic_vector(31 downto 0);

        -- Additional value/constant saved in rsa_regio
        R2N:  in std_logic_vector(C_BLOCK_SIZE-1 downto 0) --r^2 % n
    );
end RSA_Core;

architecture Behavioral of RSA_Core is
signal multiple_out:     std_logic := '0';
signal done, busy, init: std_logic;
signal last_input_msg:   std_logic:='0';
signal msgout_data_reg:  std_logic_vector(C_BLOCK_SIZE-1 downto 0);
signal output_message:   std_logic_vector(C_BLOCK_SIZE-1 downto 0);
signal msgin_data_reg:   std_logic_vector(C_BLOCK_SIZE-1 downto 0);
type msg_state is (MSGIN,WAIT_FOR_BUSY, MSGOUT);
signal state_msg, next_state_msg, prev_state: msg_state:=MSGIN;

begin
-----------------------------------------------------------------------------------------------
--------------------- Exponentiation component port map ---------------------------------------
-----------------------------------------------------------------------------------------------
    --rl_exp: entity work.RL_Exponentiation 
    rl_exp: entity work.exponentiation 
                generic map(C_BLOCK_SIZE => C_BLOCK_SIZE)
                port map(clk => clk, 
                         reset_n => reset_n, 
                         KEY => key_e_d, 
                         N => key_n,
                         MESSAGE => msgin_data_reg,
                         busy => busy,
                         init => init,
                         done => done,
                         R2N => R2N,
                         output_message => output_message);
    

-----------------------------------------------------------------------------------------------
--------------------- Message In Signalling----------------------------------------------------
-----------------------------------------------------------------------------------------------
    -- ready to receive if exponentiation function is not busy
    msgin_ready <= init; 
    msgout_data <= msgout_data_reg;

    process(reset_n, clk)
    begin
        if rising_edge(clk) then
            state_msg <= next_state_msg;
            
            case(state_msg) is
                when MSGIN =>
                    if msgin_valid = '1' then
                        msgout_valid <='0';
                        if busy = '0' and init='0' then
                            init <= '1';
                            msgin_data_reg <= msgin_data;
                            if msgin_last = '1' then    -- Check if this is the last message or not
                                last_input_msg <= '1'; 
                            else
                                last_input_msg <= '0';
                            end if;
                            if last_input_msg = '1' then
                                last_input_msg <='0';
                            else 
                                last_input_msg <='0';
                            end if;
                        else
                            init<='0';
                        end if;
                    else
                        init<='0';
                    end if;
                when WAIT_FOR_BUSY=>

                when MSGOUT =>
                    init <= '0';
                    if done = '1' then --- and done ='1'
                        msgout_data_reg <= output_message;
                        msgout_valid <='1';
                        if last_input_msg = '1' then
                            msgout_last <= '1';
                        else
                            msgout_last <= '0';
                        end if;
                    else
                        msgout_valid <='0';
                        msgout_last <= '0';
                    end if;
            end case ;
        end if;

    end process;

    process(state_msg, msgout_ready, msgin_ready,busy)
    begin
        case(state_msg) is
            when MSGIN =>
                if msgin_ready = '1' then
                    next_state_msg <=WAIT_FOR_BUSY;
                    prev_state <= MSGIN;
                else
                    next_state_msg <=MSGIN;
                end if;
            when WAIT_FOR_BUSY =>
            
                if prev_state = MSGIN then
                    if busy = '1' then
                        next_state_msg <= MSGOUT;
                    end if;
                else 
                    if msgout_ready = '1' then
                        next_state_msg <= MSGIN;
                    end if;
                end if;
                    
                if busy = '1' then
                    
                else
                    next_state_msg <= WAIT_FOR_BUSY;
                end if;
            when MSGOUT =>
                if done='1' then
                    next_state_msg <=WAIT_FOR_BUSY;
                    prev_state <= MSGOUT;
                else
                    next_state_msg <=MSGOUT;
                end if;
        end case ;

    end process;


    
-----------------------------------------------------------------------------------------------
--------------------- Message Out signalling---------------------------------------------------
-----------------------------------------------------------------------------------------------


end Behavioral;

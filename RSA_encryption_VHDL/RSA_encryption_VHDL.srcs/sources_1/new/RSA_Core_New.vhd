library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity RSA_Core is
    Generic(
            bit_width: integer:=256
    );
    Port ( 
        clk:     in std_logic;
        reset_n: in std_logic;

        --Left side block diagram
        msgin_valid: in std_logic;
        msgin_ready: out std_logic;
        msgin_last:  in std_logic;
        msgin_data:  in std_logic_vector(bit_width-1 downto 0);

        --Right side block diagram
        msgout_valid: out std_logic;
        msgout_ready: in std_logic;
        msgout_last:  out std_logic;
        msgout_data:  out std_logic_vector(bit_width-1 downto 0);

        --Top side block diagram
        key_n: in std_logic_vector(bit_width-1 downto 0);
        key_e: in std_logic_vector(bit_width-1 downto 0);
--      rsa_status: out std_logic_vector(31 downto 0);

        -- Additional value/constant saved in rsa_regio
        R: in std_logic_vector(bit_width-1 downto 0) -- Need to figure out this length
    );
end RSA_Core;

architecture Behavioral of RSA_Core is
signal multiple_out: std_logic := '0';
signal done:         std_logic;
signal msgout_data_reg: std_logic_vector(bit_width-1 downto 0);

begin
    rl_exp: entity work.RL_Exponentiation 
                generic map(bit_width => bit_width)
                port map(clk => clk, 
                         reset_n => reset_n, 
                         KEY => key_e, 
                         N => key_n,
                         R => R,
                         MESSAGE => msgin_data,
                         busy => busy,
                         init => init,
                         done => done,
                         output_message => output_message);
    
    -- ready to receive if rl_exp not working
    msgin_ready <= not busy; 

    -- Message in handshake
    message_in:process(clk, reset_n) -- Acquire message and initialize exponentiation
    begin
        if reset_n='0' then
            start <= '0';
        else
            if rising_edge(clk) then
                if msgin_valid = '1' and busy = '0' then
                    init <= '1';
                else
                    init <= '0';
                end if;
            end if;
        end if;
    
    end process message_in;
    

    msgout_data <= msgout_data_reg;
    message_out:process(clk, reset_n) -- Send out message, give signal that process is done
    begin
        if reset_n='0' then
            msgout_data  <= (others => '0');
            msgout_last  <= '0';
            multiple_out <= '0';
            msgout_data_reg <= '0';
        else
            if rising_edge(clk) then
                if done = '1' and msgout_ready = '1' then --- and done ='1'
                    msgout_data_reg <= output_message;
                    msgout_valid <='1';
                    if multiple_out ='0' then
                        multiple_out <= '1';
                        msgout_last <= '0';
                    else
                        msgout_last <= '1';
                    end if;
                else
                    msgout_valid <='0';
                    msgout_last <= '0';
                end if;
            end if;
        end if;
    end process message_out;
    
    
end Behavioral;

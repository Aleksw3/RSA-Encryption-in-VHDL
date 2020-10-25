library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity RSA_Core is
	Generic(
			bit_width: integer:=255
	);
	Port ( 
		clk: 	 in std_logic;
		reset_n: in std_logic;

		--Left side block diagram
		msgin_valid: in std_logic;
		msgin_ready: out std_logic;
		msgin_last:  in std_logic;
		msgin_data:  in std_logic_vector(bit_width downto 0);

		--Right side block diagram
		msgout_valid: out std_logic;
		msgout_ready: in std_logic;
		msgout_last:  out std_logic;
		msgout_data:  out std_logic_vector(bit_width downto 0);

		--Top side block diagram
		key_n: in std_logic_vector(bit_width downto 0);
		key_e: in std_logic_vector(bit_width downto 0);
		rsa_status: out std_logic_vector(31 downto 0);
		-- Additional value/constant saved in rsa_regio
		r_squared: in std_logic_vector(bit_width downto 0) -- Need to figure out this length
	);
end RSA_Core;

architecture Behavioral of RSA_Core is

signal input_message, output_message: std_logic_vector(bit_width downto 0);
signal multiple_in, multiple_out: 	  std_logic;
signal start: 						  std_logic :='0';
signal counter_val: 				  unsigned (7 downto 0);

type state is (IDLE, INIT_EXP, LOOP_EXP, LAST_EXP, OUTPUT_DATA);
signal curr_state, next_state: state;

signal mux_select:    std_logic_vector(1 downto 0);
signal MonPro_busy:   std_logic_vector(1 downto 0);
signal shift_enable:  std_logic := '0';
signal busy:          std_logic:= '0';
signal init:          std_logic:= '0';
signal done:          std_logic:= '0';
signal start_counter: std_logic:= '0';


begin
    rl_exp: entity work.RL_Exponentiation 
                port map(clk => clk, reset_n => reset_n, 
                         init => init, key => key_e, 
                         N => key_n, r_squared => r_squared,
                         message => input_message, 
                         mux_select => mux_select,
                         MonPro_busy => MonPro_busy, 
                         shift_enable => shift_enable,
                         output_message => output_message);
    msgin_ready <= busy;
    
    message_in:process(clk) -- Acquire message and initialize exponentiation
    begin
        if reset_n='0' then
            -- rese something dunno
        else
            if rising_edge(clk) then
                if msgin_valid = '1' and busy = '1' then
                    input_message <= msgin_data;
                    start <= '1';
                end if;
            end if;
        end if;
    
    end process message_in;
    
    message_out:process(clk) -- Send out message, give signal that process is done
    begin
        if reset_n='0' then
            -- reset something dunno
        else
            if done = '1' and msgout_ready = '1' then
                msgout_data <= output_message;
    
                    if multiple_out ='0' then
                        multiple_out <= '1';
                    else
                        msgout_last <= multiple_out;
                    end if;
    
                else
                    msgout_last <= '0';
            end if;
        end if;
    end process message_out;
    
    control_fsm_synch: process(reset_n, clk) --Synchronous process for control. 
    begin
        if reset_n = '0' then
            curr_state <= IDLE;
            counter_val <= (others => '0');
        elsif rising_edge(clk) then
            if MonPro_busy = "00" then
                curr_state <= next_state;
            end if;
    
            if next_state = INIT_EXP and curr_state = IDLE then
                init <= '1';
            elsif next_state = LOOP_EXP and curr_state = INIT_EXP then
                start_counter<= '1';
            elsif next_state = LAST_EXP and curr_state = LOOP_EXP then
                counter_val<= (others => '0');
            elsif next_state = IDLE and curr_state = OUTPUT_DATA then
                msgout_data <= output_message;
            end if;
    
            case(curr_state) is
                when IDLE =>
                    mux_select   <= "00";
                    start_counter<= '0';
                    shift_enable <= '0';
                    busy <= '0';
                when INIT_EXP =>
                    init <= '0';
                    mux_select   <= "00";
                    shift_enable <= '0';
                    busy <= '1';
                    if next_state /= LOOP_EXP then	
                        start_counter<= '0';
                    end if;
                when LOOP_EXP =>
                    busy <= '1';
                    mux_select   <= "01";
                    shift_enable <= '1';
                    start_counter<= '1';
                when LAST_EXP =>
                    busy <= '1';
                    mux_select   <= "10";
                    shift_enable <= '0';
                    start_counter<= '0';
                when OUTPUT_DATA =>
                    busy <= '1';
                    mux_select  <=  "00";
                    shift_enable<=  '0';
                    start_counter<= '0';
                    done <= '1';
            end case;
    
            if start_counter='1' then
                counter_val <= counter_val + 1;
            else
                counter_val<= (others=>'0');
            end if;
        end if;
    end process control_fsm_synch;
    
    control_fsm: process(counter_val, curr_state, start, start_counter,init)
    begin
        case (curr_state) is
            when IDLE =>
                if start='1' then
                    next_state <= INIT_EXP;
                end if;
    
            when INIT_EXP =>
                next_state  <= LOOP_EXP;
    
            when LOOP_EXP =>
                
                if counter_val = 255 then
                    next_state <= LAST_EXP;
                end if;
            when LAST_EXP =>
                next_state <= OUTPUT_DATA;
            when OUTPUT_DATA =>
                next_state <= IDLE;
        end case;
    end process control_fsm;
    
end Behavioral;

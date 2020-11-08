library IEEE;
library STD; use STD.TEXTIO.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;


entity RL_exp_tb is
--  Port ( );
end RL_exp_tb;

architecture Behavioral of RL_exp_tb is
constant bit_width: integer:=32;

--etc
signal clk:std_logic:='0';
constant period: time:=20 ns;
signal done, start,reset_n: std_logic;


--- Keys and additional connections
signal n_key,d_key,e_key,message, cipher: std_logic_vector(bit_width-1 downto 0);
signal key: std_logic_vector(bit_width-1 downto 0);
signal r: std_logic_vector(bit_width-1 downto 0);
signal id: integer range 0 to 100:=33;

--- message in
signal msgin_valid,msgin_ready,msgin_last: std_logic;
signal mess: std_logic_vector(bit_width-1 downto 0);

-- message out
signal msgout_valid,msgout_ready,msgout_last: std_logic;
signal msgout_data: std_logic_vector(bit_width-1 downto 0);

-- extra constants we might save, have to figure out
signal R2:  std_logic_vector(bit_width-1 downto 0):="00011111011100001110011100100101";
signal R2M: std_logic_vector(bit_width-1 downto 0):="00000000001000110111011100111101";


begin


core: entity work.RSA_Core generic map(bit_width=>bit_width)
						   port map(clk=>clk,reset_n=>reset_n,
						   			msgin_valid=>msgin_valid,
						   			msgin_ready=>msgin_ready,msgin_last=>msgin_last,
						   			msgin_data=>mess,
						   			msgout_valid=>msgout_valid,msgout_ready=>msgout_ready,
						   			msgout_last=>msgout_last,msgout_data=>msgout_data,
						   			R2 => R2,
                                    R2M => R2M,
						   			key_n=>n_key,key_e=>key,r=>r);


clk <= not clk after period/2;
reset_n<='1';
msgin_valid <= '1' ,'0' after 2*period;
msgin_last  <='0';
msgout_last <= '0';

msgout_ready <='1';



process(clk)
begin
	if rising_edge(clk) then
		if msgout_valid = '1' then
			done<='1';
		else
			done<='0';
		end if;
		if msgin_valid = '1' and msgin_ready = '1' then
			start <='1';
		else
			start <='0';
		end if;
	end if;

end process;

process(message, e_key, msgin_last, d_key, msgout_last)
begin
	if msgout_last ='1' then
		mess<=cipher;
		key <= d_key;
	else
		mess<=message;
		key <= e_key;
	end if;
	
end process;





read_file:process
	variable v_line: line;
	variable n_key_v,d_key_v,e_key_v,message_v, cipher_v: bit_vector(31 downto 0);
	variable r_v: bit_vector(31 downto 0);
	variable id_v: integer range 0 to 100;
	variable v_space: character;

	file vectors: text open read_mode is "test_data.txt";
begin
	while not endfile(vectors) loop
		wait on start until start='1';
		readline(vectors, v_line);
		read(v_line, id_v);
		read(v_line, v_space);
		read(v_line, e_key_v);
		read(v_line, v_space);
		read(v_line, d_key_v);
		read(v_line, v_space);
		read(v_line, n_key_v);
		read(v_line, v_space);
		read(v_line, message_v);
		read(v_line, v_space);
		read(v_line, cipher_v);
		read(v_line, v_space);
		read(v_line, r_v);
		id<=id_v;
		e_key <=     to_StdLogicVector(e_key_v);
		d_key <=     to_StdLogicVector(d_key_v);
		--key <=     to_StdLogicVector(d_key_v);
		n_key <=     to_StdLogicVector(n_key_v);
		message <=   to_StdLogicVector(message_v);
		cipher <=    to_StdLogicVector(cipher_v);
		R <= to_StdLogicVector(r_v);

		report "id is: "& integer'image(id);--&"e_key is: "& integer'image(to_integer(unsigned(e_key)));		
		wait on done until done='1'; -- Done goes high when message is deciphered
		assert msgout_data = message
			report "Deciphered data not equal to message at id="&integer'image(id)
			severity Warning; 
	end loop; 

end process read_file;



end Behavioral;

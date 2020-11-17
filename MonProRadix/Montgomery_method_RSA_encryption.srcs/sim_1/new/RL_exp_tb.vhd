library IEEE;
library STD; use STD.TEXTIO.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;


entity RL_exp_tb is
--  Port ( );
end RL_exp_tb;

architecture Behavioral of RL_exp_tb is
constant bit_width: integer:=256;

--etc
signal clk:std_logic:='0';
constant period: time:=5 ns;
signal done, start,reset_n: std_logic;


--- Keys and additional connections
signal n_key,d_key,e_key,message, cipher, r2n: std_logic_vector(bit_width-1 downto 0);
signal key: std_logic_vector(bit_width-1 downto 0);
signal r: std_logic_vector(bit_width-1 downto 0);
signal id: integer range 0 to 100:=33;

--- message in
signal msgin_valid,msgin_ready,msgin_last: std_logic;
signal mess: std_logic_vector(bit_width-1 downto 0);

-- message out
signal msgout_valid,msgout_ready,msgout_last: std_logic;
signal msgout_data: std_logic_vector(bit_width-1 downto 0);



begin


core: entity work.RSA_Core generic map(bit_width=>bit_width)
						   port map(clk=>clk,reset_n=>reset_n,
						   			msgin_valid=>msgin_valid,
						   			msgin_ready=>msgin_ready,msgin_last=>msgin_last,
						   			msgin_data=>mess,
						   			msgout_valid=>msgout_valid,msgout_ready=>msgout_ready,
						   			msgout_last=>msgout_last,msgout_data=>msgout_data,
						   			R2N => r2n,
						   			key_n=>n_key,key_e=>key);


clk <= not clk after period/2;
reset_n<='1';
msgin_last  <='0';
msgout_last <= '0';

msgout_ready <='1';


done <= msgout_valid;
start <='1';


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

e_key <=     x"0000000000000000000000000000000000000000000000000000000000010001";
--d_key <=     to_StdLogicVector(d_key_v);
r2n   <=     x"56ddf8b43061ad3dbcd1757244d1a19e2e8c849dde4817e55bb29d1c20c06364";
n_key <=     x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
message <=   x"0a23232323232323232323232323232323232323232323232323232323232323";
msgin_valid <= '1';


--read_file:process
--	variable v_line: line;
--	variable n_key_v,d_key_v,e_key_v,message_v, cipher_v,r2n_key_v: bit_vector(31 downto 0);
--	variable r_v: bit_vector(31 downto 0);
--	variable id_v: integer range 0 to 100;
--	variable v_space: character;

--	file vectors: text open read_mode is "test_data.txt";
--begin
--	while not endfile(vectors) loop
--		msgin_valid <= '0';
--		readline(vectors, v_line);
--		read(v_line, id_v);
--		read(v_line, v_space);
--		read(v_line, e_key_v);
--		read(v_line, v_space);
--		read(v_line, d_key_v);
--		read(v_line, v_space);
--		read(v_line, n_key_v);
--		read(v_line, v_space);
--		read(v_line, r2n_key_v);
--		read(v_line, v_space);
--		read(v_line, message_v);
--		read(v_line, v_space);
--		read(v_line, cipher_v);
--		id<=id_v;
--		e_key <=     to_StdLogicVector(e_key_v);
--		d_key <=     to_StdLogicVector(d_key_v);
--		r2n   <=     to_StdLogicVector(r2n_key_v);
--		n_key <=     to_StdLogicVector(n_key_v);
--		message <=   to_StdLogicVector(message_v);
--		cipher <=    to_StdLogicVector(cipher_v);
--        msgin_valid <= '1';
--        wait for 1 ns;
--		report "id is: "& integer'image(id)&"  - key is: " & integer'image(to_integer(unsigned(e_key)));--&"e_key is: "& integer'image(to_integer(unsigned(e_key)));		
--		wait on done until done='1'; -- Done goes high when message is deciphered
--		assert msgout_data = cipher
--			report "Deciphered data not equal to message at id="&integer'image(id)
--			severity Warning; 
--	end loop; 

--end process read_file;



end Behavioral;

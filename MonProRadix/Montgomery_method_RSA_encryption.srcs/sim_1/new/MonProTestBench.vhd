----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/28/2020 05:28:10 PM
-- Design Name: 
-- Module Name: MonProTb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity MonProTb is
end MonProTb;

architecture Behavioral of MonProTb is
	--Component declarations:
	component MonPro is
	generic(C_block_size: integer := 256);
	port(
		clk, reset_n, EN	:	in std_logic;
		N, X, Y 			: 	in std_logic_vector(C_block_size downto 0);
		N_inv               :   in std_logic_vector(1 downto 0);
		busy				:	out std_logic;
		Carry, Sum		    :  out std_logic_vector(C_block_size-1 downto 0));
	end component;

	--Constants
	constant period 	: time := 8 ns;
	constant bit_width 	: integer := 256;

	--Signal Declarations:	
	file vectors: text;
	
	--Stimuli ID
	signal ID : integer range 0 to 50 := 0;
	
	
	--Input signals of Monpro
	signal clk : std_logic := '0';
	signal EN : std_logic := '1';
	signal reset_n : std_logic := '1';
	signal N_inv : std_logic_vector(1 downto 0) := "11";
	signal N            : std_logic_vector(bit_width downto 0) := (others => '0');	
	signal X            : std_logic_vector(bit_width downto 0) := (others => '0');	
	signal Y 			: std_logic_vector(bit_width downto 0) := (others => '0');	
	--Output signals of Monpro
	signal busy, busy_s 			  : std_logic := '0';
	signal Carry : std_logic_vector(bit_width-1 downto 0) := (others => '0');
	signal Sum		:  std_logic_vector(bit_width-1 downto 0) := (others => '0');
	signal Z				          : std_logic_vector(bit_width-1 downto 0) := (others => '0');
	signal Z_expected : std_logic_vector(bit_width+3 downto 0) := (others => '0'); 
--	signal Z_holder       : std_logic_vector(bit_width - 1 downto 0) := (others => '0');
	

begin
    busy_s <= busy when rising_edge(clk);
    Z <= std_logic_vector(unsigned(Carry) + unsigned(Sum));
    
	DUT : MonPro 
				generic map(C_block_size => bit_width)
				port map(clk => clk, reset_n => reset_n, EN => EN, N_inv => N_inv,
						N => N, X => X, Y => Y, busy => busy, Carry => Carry, sum => sum);

clk_process : process
begin
    wait for period/2;
    clk <= not clk;
end process;

N <= '0' & x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";
X <= '0' & x"ee5279c61dc177d39b873a8488544e5e4a19411713c81616103660f57922a05c";
Y <= '0' & x"ee5279c61dc177d39b873a8488544e5e4a19411713c81616103660f57922a05c";
Z_expected <= x"101d74e7ea7dbd9469e02bd65cf8b1c791632d0573e6246c2243d98125458a99c";
		
--reset_proc : process
--    begin
    
--        reset_n <= '1';
--        EN <= '1';
--        wait for 0 ns;
----        EN <= '0' after 70 ns, '1' after 80 ns;
--        wait;
--    end process reset_proc;


    
--read_file:process
--   variable v_line: line;
--   variable X_v, Y_v, N_v, Z_v : bit_vector(bit_width - 1 downto 0); 
--   variable id_v: integer range 0 to 100;
--   variable v_space: character;
   
----   file vectors: text open write_mode is "stimulus.txt";
--begin
    
--   file_open(vectors, "stimulus.txt", read_mode);
--   while not endfile(vectors) loop
--        readline(vectors, v_line);
----        Check whether an empty line or comment
--        if v_line.all'length = 0 or v_line.all(1) = '#' then
--            next;
--        end if;
----        Read each word and store in a variable
--        read(v_line, id_v);
--        read(v_line, v_space);
--        read(v_line, X_v);
--        read(v_line, v_space);
--        read(v_line, Y_v);
--        read(v_line, v_space);
--        read(v_line, N_v);
--        read(v_line, v_space);
--        read(v_line, Z_v);
--        ID <= id_v;
--        X <= to_stdlogicvector(X_v);
--        Y <= to_stdlogicvector(Y_v);
--        N <= to_stdlogicvector(N_v);
--        Z_holder <= to_stdlogicvector(Z_v);
--        report "id is: "& integer'image(id);
        
----        N <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";		
--        wait until busy = '0' and busy_s = '1';
        
--    end loop; 
--    file_close(vectors);

--end process read_file;
   
monpro_proc : process
begin
    wait for 1 ns;
    if busy = '0' and EN = '1' then
        assert Z = Z_expected(bit_width downto 0)
            report "The MonPro is broken!"
            severity ERROR;
--    else
--        Z_expected <= Z_holder;
    end if;
    
end process monpro_proc;

end Behavioral;

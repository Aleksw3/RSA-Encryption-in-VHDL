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
	generic(bit_width: integer := 256);
	port(
		clk, reset_n, EN	:	in std_logic;
		N, X, Y 			: 	in std_logic_vector(bit_width - 1 downto 0);
		busy				:	out std_logic;
		Z					:	out std_logic_vector(bit_width - 1 downto 0));
	end component;
	
	
	
--	function to_slv(bv : bit_vector) return std_logic_vector is
--        variable slv : std_logic_vector(bv'range);
--    begin
--        for i in bv'range loop
--            if bv(i) = '1' then
--                slv(i) := '1';
--            else
--                slv(i) := '0';
--            end if;
--        end loop;
--        return slv;
--    end;	

	--Constants
	constant period 	: time := 1 ns;
	constant bit_width 	: integer := 32;

	--Signal Declarations:	
	file vectors: text;
	
	--Stimuli ID
	signal ID : integer range 0 to 50 := 0;
	
	--Input signals of Monpro
	signal clk : std_logic := '0';
	signal EN : std_logic := '0';
	signal reset_n : std_logic;
	signal N, X, Y 			: std_logic_vector(bit_width - 1 downto 0) := (others => '0');
	
	--Output signals of Monpro
	signal busy, busy_s 			          : std_logic := '0';
	signal Z				          : std_logic_vector(bit_width - 1 downto 0) := (others => '0');
	signal Z_expected, Z_holder       : std_logic_vector(bit_width - 1 downto 0) := (others => '0');
	

begin
    busy_s <= busy when rising_edge(clk);
    
	DUT : MonPro 
				generic map(bit_width => bit_width)
				port map(clk => clk, reset_n => reset_n, EN => EN, 
						N => N, X => X, Y => Y, busy => busy, Z => Z);

	clk_process : process
	begin
		wait for 1 ns;
		clk <= not clk;
	end process;
		
	reset_proc : process
		begin
		
			reset_n <= '1';
			EN <= '1';
			wait for 100 ns;
			reset_n <= '0';
--			X <= std_logic_vector(to_unsigned(413343538,X'length));
--            Y <= std_logic_vector(to_unsigned(1400488832,Y'length));
--            N <= std_logic_vector(to_unsigned(1825920369,N'length));
--            Z_expected <= std_logic_vector(to_unsigned(1108506787,Z_expected'length));
--			wait for period*2;
--			assert to_integer(unsigned(Z)) = (cnt_X*cnt_Y)mod(cnt_N)
--                report "The MonPro is broken!"
--                severity ERROR;
		end process reset_proc;
		
read_file:process
   variable v_line: line;
   variable X_v, Y_v, N_v, Z_v : bit_vector(bit_width - 1 downto 0); 
   variable id_v: integer range 0 to 100;
   variable v_space: character;
   
--   file vectors: text open write_mode is "stimulus.txt";
begin
   file_open(vectors, "stimulus.txt", read_mode);
   while not endfile(vectors) loop
        readline(vectors, v_line);
--        Check whether an empty line or comment
        if v_line.all'length = 0 or v_line.all(1) = '#' then
            next;
        end if;
--        Read each word and store in a variable
        read(v_line, id_v);
        read(v_line, v_space);
        read(v_line, X_v);
        read(v_line, v_space);
        read(v_line, Y_v);
        read(v_line, v_space);
        read(v_line, N_v);
        read(v_line, v_space);
        read(v_line, Z_v);
        ID <= id_v;
        X <= to_stdlogicvector(X_v);
        Y <= to_stdlogicvector(Y_v);
        N <= to_stdlogicvector(N_v);
        Z_holder <= to_stdlogicvector(Z_v);
        report "id is: "& integer'image(id);		
        wait until busy = '0' and busy_s = '1';
        
    end loop; 
	file_close(vectors);

end process read_file;
   
monpro_proc : process
begin
    wait for 1 ns;
    if busy = '0' then
        assert Z = Z_expected
            report "The MonPro is broken!"
            severity ERROR;
    else
        Z_expected <= Z_holder;
    end if;
    
end process monpro_proc;

end Behavioral;

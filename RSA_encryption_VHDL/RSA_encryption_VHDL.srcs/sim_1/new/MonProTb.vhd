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

	--Constants
	constant period 	: time := 1 ns;
	constant bit_width 	: integer := 8;
	
	--Counters
	--signal cnt_X : integer range 0 to (2**bit_width)-1 := 0;
	--signal cnt_Y : integer range bit_width to (2**bit_width)-1 := 8;
	--signal cnt_N : integer range bit_width to (2**bit_width)-1 := 8;

	--Test signals
	--signal x_Test : integer range 0 to (2**bit_width)-1 := 0;

	--Signal Declarations:	
	
	--Input signals of Monpro
	signal clk : std_logic := '0';
	signal EN : std_logic := '0';
	signal reset_n : std_logic;
	signal N, X, Y 			: std_logic_vector(bit_width - 1 downto 0) := (others => '0');
	
	--Output signals of Monpro
	signal busy 			: std_logic := '0';
	signal Z				: std_logic_vector(bit_width - 1 downto 0) := (others => '0');
	
	--signal holder : std_logic_vector(bit_width - 1 downto 0);

begin
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
			X <= std_logic_vector(to_unsigned(53,X'length));
            Y <= std_logic_vector(to_unsigned(69,Y'length));
            N <= std_logic_vector(to_unsigned(117,N'length));
			wait for period*2;
--			assert to_integer(unsigned(Z)) = (cnt_X*cnt_Y)mod(cnt_N)
--                report "The MonPro is broken!"
--                severity ERROR;
		end process reset_proc;

	-- monpro_proc : process
	-- begin
      -- if EN = '1' then
        -- for cnt_N in bit_width to (2**bit_width) - 1 loop
            -- for cnt_Y in bit_width to (2**bit_width) - 1 loop
                -- for cnt_X in 0 to (2**bit_width) - 1 loop
                    -- x_Test <= (cnt_X*cnt_Y)mod(cnt_N);
                    -- X <= std_logic_vector(to_unsigned(cnt_X,X'length));
                    -- Y <= std_logic_vector(to_unsigned(cnt_Y,Y'length));
                    -- N <= std_logic_vector(to_unsigned(cnt_N,N'length));
                    -- wait for 1 ns;
                    -- holder <= std_logic_vector(to_unsigned(x_Test,holder'length));
                    -- wait for 1 ns;
                    -- assert to_integer(unsigned(Z)) = (cnt_X*cnt_Y)mod(cnt_N)
                        -- report "The MonPro is broken!"
                        -- severity ERROR;
                -- end loop;
            -- end loop;
        -- end loop;
    -- else
        -- wait for period;
    -- end if;
	-- end process monpro_proc;

end Behavioral;

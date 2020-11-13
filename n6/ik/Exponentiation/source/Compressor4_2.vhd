library ieee;
use ieee.std_logic_1164.all;

entity Compressor42 is
	port(
		i 		: 	in std_logic_vector(3 downto 0);
		cin		: 	in std_logic;
		cout 	:	out std_logic;
		output1 :	out std_logic;
		output2	:	out std_logic);
end Compressor42;

architecture structural of Compressor42 is

	--Structural components
	
	component Full_Adder is
	port(
		A : in std_logic;
		B : in std_logic;
		C_in : in std_logic;
		S : out std_logic;
		C_out : out std_logic);
	end component;
	
	--Internal signals
	signal FA0_S, FA0_C, FA1_S, FA1_C : std_logic := '0';
	
	begin
		FA0 : Full_Adder port map(A => i(3), B => i(2), C_in => i(1), S => FA0_S, C_out => FA0_C);
		FA1 : Full_Adder port map(A => FA0_S, B => i(0), C_in => cin, S => FA1_S, C_out => FA1_C);
		
		cout <= FA0_C;
		output1 <= FA1_S;
		output2 <= FA1_C;
	
	end architecture;
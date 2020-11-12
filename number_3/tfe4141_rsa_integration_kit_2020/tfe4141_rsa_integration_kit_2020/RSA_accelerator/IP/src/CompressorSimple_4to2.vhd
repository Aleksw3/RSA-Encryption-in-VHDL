library ieee;
use ieee.std_logic_1164.all;

entity CompressorSimple_4to2 is
	port(
		Input 		: 	in std_logic_vector(3 downto 0);
		cin		    : 	in std_logic;
		cout 	    :	out std_logic;
		Sum         :	out std_logic;
		Carry	    :	out std_logic);
end CompressorSimple_4to2;

architecture structural of CompressorSimple_4to2 is
	
	component Full_Adder is
	port(
		A : in std_logic;
		B : in std_logic;
		C_in : in std_logic;
		S : out std_logic;
		C_out : out std_logic);
	end component;

	signal FA0_S, FA0_C, FA1_S, FA1_C : std_logic := '0';
	
	begin
		FA0 : Full_Adder port map(A => Input(3), B => Input(2), C_in => Input(1), S => FA0_S, C_out => FA0_C);
		FA1 : Full_Adder port map(A => FA0_S, B => Input(0), C_in => cin, S => FA1_S, C_out => FA1_C);
		
		cout <= FA0_C;
		Sum <= FA1_S;
		Carry <= FA1_C;
	
	end architecture;
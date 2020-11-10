library ieee;
use ieee.std_logic_1164.all;

--Entity
entity CarryPropagateAdder is
	generic(n : integer := 256);
	port(
		A 			: in std_logic_vector(n-1 downto 0);
		B 			: in std_logic_vector(n-1 downto 0);
		Sum 		: out std_logic_vector(n-1 downto 0);
		Cout 		: out std_logic);
end CarryPropagateAdder;

--Architecture
architecture dataflow of CarryPropagateAdder is

	component Full_Adder is
	port(
		A : in std_logic;
		B : in std_logic;
		C_in : in std_logic;
		S : out std_logic;
		C_out : out std_logic);
	end component;
	
	component Half_Adder is
	port(
		A : in std_logic;
		B : in std_logic;
		S : out std_logic;
		C : out std_logic);
	end component;
	
	signal B_s, A_s	: std_logic_vector(n-1 downto 0);
	signal RC_C, RC_S : std_logic_vector(n-1 downto 0);
	
begin
	
	HA_RC_0 : Half_Adder port map(A => A_s(0), B => B_s(0), S => RC_S(0), C => RC_C(0));
	
	FA_RC_f : for i in 1 to n-1 generate
		FA_RC_i : Full_Adder port map(A => A_s(i), B => B_s(i), C_in => RC_C(i-1), S => RC_S(i), C_out => RC_C(i));
	end generate;

	A_s <= A;
	B_s <= B;
	Sum <= RC_S;
	cout <= RC_C(n-1);

	
end dataflow;
library ieee;
use ieee.std_logic_1164.all;

entity Compressor6_to_2 is
	port(
		Input	: 	in std_logic_vector(5 downto 0);
		cin0    : 	in std_logic;
		cin1    :   in std_logic;
		cout0 	:	out std_logic;
		cout1   :   out std_logic;
		out0    :   out std_logic;
		out1    :   out std_logic);
	end Compressor6_to_2;

architecture structural of Compressor6_to_2 is

	--Structural components
	
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
	
	--Internal signals
	signal w_Carry1, w_Carry2, w_Carry3, w_Carry4, w_Carry5 : std_logic;
	signal w_Sum1, w_Sum2, w_Sum3, w_Sum4, w_Sum5 : std_logic;	
	
	
	begin
		FA1 : Full_Adder port map(A => Input(0), B => Input(1), C_in => Input(2), S => w_Sum1, C_out => w_Carry1);
		FA2 : Full_Adder port map(A => Input(3), B => Input(4), C_in => Input(5), S => w_Sum2, C_out => w_Carry2);
		FA3 : Full_Adder port map(A => w_Carry1, B => w_Carry2, C_in => w_Carry5, S => w_Sum3, C_out => w_Carry3);
		FA4 : Full_Adder port map(A => w_Sum5, B => cin0, C_in => cin1, S => w_Sum4, C_out => w_Carry4);
		HA	: Half_Adder port map(A => w_Sum1, B => w_Sum2, S => w_Sum5, C => w_Carry5);
        
        
        cout0 <= w_Sum3;
        cout1 <= w_Carry3;
        out0 <= w_Sum4;
        out1 <= w_Carry4;
	
	end architecture;
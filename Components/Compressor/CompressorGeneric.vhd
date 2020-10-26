library ieee;
use ieee.std_logic_1164.all;

--Entity
entity CompressorTree is
	generic(n : integer := 256);
	port(
		A 		: in std_logic_vector(n-1 downto 0);
		B 		: in std_logic_vector(n-1 downto 0);
		C 		: in std_logic_vector(n-1 downto 0);
		D		: in std_logic_vector(n-1 downto 0);
		Sum 	: out std_logic_vector(n-1 downto 0);
		Cout	: out std_logic;
		Carry 	: out std_logic_vector(n-1 downto 0));
end CompressorTree;

--Architecture
architecture dataflow of CompressorTree is

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
	
	component Compressor42 is
	port(
		i 		: 	in std_logic_vector(3 downto 0);
		cin		: 	in std_logic;
		cout 	:	out std_logic;
		output1 :	out std_logic;
		output2	:	out std_logic);
	end component;
	
	signal cinComp, coutComp 		: std_logic_vector(n-1 downto 0);
	signal outputComp1, outputComp2	: std_logic_vector(n-1 downto 0);
	
begin
	Comp_0 : Compressor42 port map(i(0) => A(0), i(1) => B(0), i(2) => C(0), i(3) => D(0),
									cin => '0', cout => coutComp(0), output1 => outputComp1(0), output2 => outputComp2(0));
	Comp_f : for i in 1 to n-1 generate
		Comp_i : Compressor42 port map(i(0) => A(i), i(1) => B(i), i(2) => C(i), i(3) => D(i),
										cin => coutComp(i-1), cout => coutComp(i), output1 => outputComp1(i), output2 => outputComp2(i));
	end generate;

	Sum <= outputComp1;
	Cout <= coutComp(n-1);
	Carry <= outputComp2;
	
end dataflow;
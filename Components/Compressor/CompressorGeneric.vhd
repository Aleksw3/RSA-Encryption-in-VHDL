library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Entity
entity CompressorTree is
	generic(n : integer := 256);
	port(
		A 		: in unsigned(n-1 downto 0);
		B 		: in unsigned(n-1 downto 0);
		C 		: in unsigned(n-1 downto 0);
		D		: in unsigned(n-1 downto 0);
		Sum 	: out unsigned(n-1 downto 0);
		Cout	: out unsigned (0 downto 0);
		Carry 	: out unsigned(n-1 downto 0));
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
	
	signal A_s, B_s, C_s, D_s : std_logic_vector(n-1 downto 0);
	signal cinComp, coutComp 		: std_logic_vector(n-1 downto 0);
	signal outputComp1, outputComp2	: std_logic_vector(n-1 downto 0);
	
begin
	Comp_0 : Compressor42 port map(i(0) => A_s(0), i(1) => B_s(0), i(2) => C_s(0), i(3) => D_s(0),
									cin => '0', cout => coutComp(0), output1 => outputComp1(0), output2 => outputComp2(0));
	Comp_f : for i in 1 to n-1 generate
		Comp_i : Compressor42 port map(i(0) => A_s(i), i(1) => B_s(i), i(2) => C_s(i), i(3) => D_s(i),
										cin => coutComp(i-1), cout => coutComp(i), output1 => outputComp1(i), output2 => outputComp2(i));
	end generate;
		
	A_s <= std_logic_vector(A);
	B_s <= std_logic_vector(B);
	C_s <= std_logic_vector(C);
	D_s <= std_logic_vector(D);
	Sum <= unsigned(outputComp1);
	Cout <= unsigned(coutComp(n-1 downto n-1));
	Carry <= unsigned(outputComp2);

	
end dataflow;
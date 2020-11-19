library ieee;
use ieee.std_logic_1164.all;

--Entity
entity CompressorMultiBit_4to2 is
	generic(bit_width : natural);
	port(
		A 		: in std_logic_vector(bit_width downto 0);
		B 		: in std_logic_vector(bit_width downto 0);
		C 		: in std_logic_vector(bit_width downto 0);
		D		: in std_logic_vector(bit_width downto 0);
		Sum 	: out std_logic_vector(bit_width downto 0);
		Cout	: out std_logic;
		Carry 	: out std_logic_vector(bit_width downto 0));
end CompressorMultiBit_4to2;

--Architecture
architecture dataflow of CompressorMultiBit_4to2 is
	
	component CompressorSimple_4to2 is
	port(
		Input 		: 	in std_logic_vector(3 downto 0);
		cin		    : 	in std_logic;
		cout 	    :	out std_logic;
		Sum         :	out std_logic;
		Carry	    :	out std_logic);
	end component;
	
	signal cinComp, coutComp 		: std_logic_vector(bit_width downto 0);
	signal outputComp1, outputComp2	: std_logic_vector(bit_width downto 0);
	
begin
	Comp_inst : CompressorSimple_4to2 port map(Input(0) => A(0), Input(1) => B(0), Input(2) => C(0), Input(3) => D(0),
									cin => '0', cout => coutComp(0), Sum => outputComp1(0), Carry => outputComp2(0));
	CompGen : for i in 1 to bit_width generate
		Comp_inst : CompressorSimple_4to2 port map(Input(0) => A(i), Input(1) => B(i), Input(2) => C(i), Input(3) => D(i),
										cin => coutComp(i-1), cout => coutComp(i), Sum => outputComp1(i), Carry => outputComp2(i));
	end generate;

	Sum <= outputComp1;
	Cout <= coutComp(bit_width);
	Carry <= outputComp2;
	
end dataflow;
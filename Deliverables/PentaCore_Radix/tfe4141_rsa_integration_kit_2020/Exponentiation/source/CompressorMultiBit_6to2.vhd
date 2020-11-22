library ieee;
use ieee.std_logic_1164.all;

--Entity
entity CompressorMultiBit_6to2 is
	generic(C_block_size : integer := 256;
	       radix : integer := 16);
	port(
--	   clk : in std_logic;
--	   reset_n : in std_logic;
		A 		: in std_logic_vector(C_block_size + radix downto 0);
		B 		: in std_logic_vector(C_block_size + radix downto 0);
		C 		: in std_logic_vector(C_block_size + radix downto 0);
		D		: in std_logic_vector(C_block_size + radix downto 0);
		E       : in std_logic_vector(C_block_size + radix downto 0);
		F       : in std_logic_vector(C_block_size + radix downto 0);
		Sum 	: out std_logic_vector(C_block_size + radix + 2 downto 0);
		Carry 	: out std_logic_vector(C_block_size + radix + 2 downto 0));
end CompressorMultiBit_6to2;

--Architecture
architecture dataflow of CompressorMultiBit_6to2 is
	
	component Compressor6_to_2 is
	port(
		Input	: 	in std_logic_vector(5 downto 0);
		cin0    : 	in std_logic;
		cin1    :   in std_logic;
		cout0 	:	out std_logic;
		cout1   :   out std_logic;
		out0    :   out std_logic;
		out1    :   out std_logic);
	end component;
	
	signal s_Sum, s_Carry	: std_logic_vector(C_block_size + radix + 2 downto 0);
	signal w_cin0 : std_logic := '0';
	signal w_cin1 : std_logic_vector(1 downto 0) := "00";
	signal w_cout0 : std_logic_vector(C_block_size + radix + 2 downto 0);
	signal w_cout1 : std_logic_vector(C_block_size + radix + 2 downto 0);
	signal A_s : std_logic_vector(1 downto 0) := "00";
	signal B_s : std_logic_vector(1 downto 0) := "00";
	signal C_s : std_logic_vector(1 downto 0) := "00";
	signal D_s : std_logic_vector(1 downto 0) := "00";
	signal E_s : std_logic_vector(1 downto 0) := "00";
	signal F_s : std_logic_vector(1 downto 0) := "00";
	
begin
	Comp_inst0 : Compressor6_to_2 port map(Input(0) => A(0), Input(1) => B(0), Input(2) => C(0), Input(3) => D(0),
	                                Input(4) => E(0), Input(5) => F(0), cin0 => w_cin0, cin1 => w_cin1(0),
	                                cout0 => w_cout0(0), cout1 => w_cout1(0), out0 => s_Sum(0), out1 => s_Carry(0));
	Comp_inst1 : Compressor6_to_2 port map(Input(0) => A(1), Input(1) => B(1), Input(2) => C(1), Input(3) => D(1),
	                                Input(4) => E(1), Input(5) => F(1), cin0 => w_cout0(0), cin1 => w_cin1(0),
	                                cout0 => w_cout0(1), cout1 => w_cout1(1), out0 => s_Sum(1), out1 => s_Carry(1));
	                                
	CompGen : for i in 2 to C_block_size + radix generate
		Comp_inst : Compressor6_to_2 port map(Input(0) => A(i), Input(1) => B(i), Input(2) => C(i), Input(3) => D(i),
	                                Input(4) => E(i), Input(5) => F(i), cin0 => w_cout0(i-1), cin1 => w_cout1(i-2),
	                                cout0 => w_cout0(i), cout1 => w_cout1(i), out0 => s_Sum(i), out1 => s_Carry(i));
	end generate;
	Comp_instN0 : Compressor6_to_2 port map(Input(0) => '0', Input(1) => '0', Input(2) => '0', Input(3) => '0',
	                                Input(4) => '0', Input(5) => '0', cin0 => w_cout0(C_block_size + radix), cin1 => w_cout1(C_block_size + radix - 1),
	                                cout0 => w_cout0(C_block_size + radix + 1), cout1 => w_cout1(C_block_size + radix + 1),
	                                out0 => s_Sum(C_block_size + radix + 1), out1 => s_Carry(C_block_size + radix + 1));
	Comp_instN1 : Compressor6_to_2 port map(Input(0) => '0', Input(1) => '0', Input(2) => '0', Input(3) => '0',
	                                Input(4) => '0', Input(5) => '0', cin0 => w_cout0(C_block_size + radix + 1), cin1 => w_cout1(C_block_size + radix),
	                                cout0 => w_cout0(C_block_size + radix + 2), cout1 => w_cout1(C_block_size + radix + 2), 
	                                out0 => s_Sum(C_block_size + radix + 2), out1 => s_Carry(C_block_size + radix + 2));
	                                                                
	                                
--	cout <= w_cout1(C_block_size + radix + 2)&w_cout1(C_block_size + radix +1)&w_cout0(C_block_size+2);
	sum <= s_Sum;
    carry <= s_Carry;
	
--    clk_proc : process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset_n = '0' then
--              
--            end if;
--        end if;
--    end process;

	
end dataflow;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Entity
entity Full_Adder is
	port(
		A : in std_logic;
		B : in std_logic;
		C_in : in std_logic;
		S : out std_logic;
		C_out : out std_logic);
end Full_Adder;

--Architecture
architecture dataflow of Full_Adder is
begin

	C_out <= (A AND B) OR (C_in AND (A XOR B));
	S <= (A XOR B) XOR C_in;

end dataflow;
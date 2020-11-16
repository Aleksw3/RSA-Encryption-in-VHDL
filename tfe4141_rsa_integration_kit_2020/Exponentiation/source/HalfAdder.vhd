library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Entity
entity Half_Adder is
	port(
		A : in std_logic;
		B : in std_logic;
		S : out std_logic;
		C : out std_logic);
end Half_Adder;

--Architecture
architecture dataflow of Half_Adder is
begin

	S <= A XOR B;
	C <= A AND B;

end dataflow;
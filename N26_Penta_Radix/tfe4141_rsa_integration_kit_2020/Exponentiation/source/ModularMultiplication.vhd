library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ModularMultiplication is
  Port (x : in std_logic_vector(1 downto 0);
        y : in std_logic_vector(1 downto 0);
        compressor_sum : in std_logic_vector(1 downto 0);
        N_inv : in std_logic_vector(1 downto 0);
        o_result : out std_logic_vector(1 downto 0));
end ModularMultiplication;

architecture Behavioral of ModularMultiplication is
    signal mult_result : std_logic_vector(1 downto 0) := "00";
    signal adder_result : std_logic_vector(1 downto 0) := "00";
    signal w_adder_cout : std_logic := '0';
    signal mod_mult_result : std_logic_vector(1 downto 0) := "00";
    
    
component Half_Adder is
port(
    A : in std_logic;
    B : in std_logic;
    S : out std_logic;
    C : out std_logic);
end component;

component Full_Adder is
port(
    A : in std_logic;
    B : in std_logic;
    C_in : in std_logic;
    S : out std_logic;
    C_out : out std_logic);
end component;
begin
-----------------------------------------------------
-----------------Multiplication----------------------
-----------------------------------------------------
    mult_result(0) <= x(0) AND y(0);
    mult_result(1) <= (x(1) AND y(0) AND (NOT(x(0)) OR NOT(y(1))))
        OR (x(0) AND y(1) AND (NOT(x(1)) OR NOT(y(0)))); 
-----------------------------------------------------
--------------------Addition-------------------------
-----------------------------------------------------
    HalfAdder_Inst : Half_Adder port map(A => mult_result(0), B => compressor_sum(0),
                                        S => adder_result(0), C => w_adder_cout);
    FullAdder_Inst : Full_Adder port map(A => mult_result(1), B => compressor_sum(1),
                                        C_in => w_adder_cout, S => adder_result(1), C_out => open);
-----------------------------------------------------
-------Modular Multiplication---------
-----------------------------------------------------  

	mod_mult_result(0) <= adder_result(0) AND N_inv(0);
	mod_mult_result(1) <= (adder_result(1) AND N_inv(0) AND (NOT(adder_result(0)) OR NOT(N_inv(1))))
        OR (adder_result(0) AND N_inv(1) AND (NOT(adder_result(1)) OR NOT(N_inv(0)))); 

    
    -- mod_mult_result(1) <= (adder_result(1) AND adder_result(0) AND N_inv(1)) OR 
         -- (adder_result(0) AND N_inv(1) AND NOT(N_inv(0))) OR
         -- (adder_result(1) AND NOT(adder_result(0)) AND N_inv(0)) OR
         -- (adder_result(1) AND N_inv(1) AND N_inv(0)) OR
         -- (NOT(adder_result(1)) AND adder_result(0) AND NOT(N_inv(1)) AND N_inv(0));
-----------------------------------------------------
-----------------Output the result-------------------
----------------------------------------------------- 
    o_result <= mod_mult_result;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity KoggeStoneAdder is
  Port (i_x, i_y : in std_logic_vector(255 downto 0);
        o_result   : out std_logic_vector(256 downto 0));
end KoggeStoneAdder;

architecture Behavioral of KoggeStoneAdder is

--Component Declarations
----------------------------------------------------------------------------------
component gp_generator is
  Port (i_x, i_y : in std_logic;
        o_g, o_p : out std_logic );
end component;

component carry_operation is
  Port (i_g1, i_g2 : in std_logic;
        i_p1, i_p2 : in std_logic;
        o_g, o_p : out std_logic);
end component;
----------------------------------------------------------------------------------
--Signal Declarations
----------------------------------------------------------------------------------

signal s_g_in, s_p_in : std_logic_vector(255 downto 0);

--output signals of KS stages

--stage 1
signal s_g_1 : std_logic_vector(255 downto 0);
signal s_p_1 : std_logic_vector(255 downto 0);
--stage 2
signal s_g_2 : std_logic_vector(255 downto 0);
signal s_p_2 : std_logic_vector(255 downto 0);
--stage 3
signal s_g_3 : std_logic_vector(255 downto 0);
signal s_p_3 : std_logic_vector(255 downto 0);
--stage 4
signal s_g_4 : std_logic_vector(255 downto 0);
signal s_p_4 : std_logic_vector(255 downto 0);
--stage 5
signal s_g_5 : std_logic_vector(255 downto 0);
signal s_p_5 : std_logic_vector(255 downto 0);
--stage 6
signal s_g_6 : std_logic_vector(255 downto 0);
signal s_p_6 : std_logic_vector(255 downto 0);
--stage 7
signal s_g_7 : std_logic_vector(255 downto 0);
signal s_p_7 : std_logic_vector(255 downto 0);
--stage 8
signal s_g_8 : std_logic_vector(255 downto 0);
signal s_p_8 : std_logic_vector(255 downto 0);

--Carry
signal s_carry : std_logic_vector(255 downto 0);

signal sum : std_logic_vector(255 downto 0);
signal cout : std_logic;
----------------------------------------------------------------------------------


begin
--Stage 0
    gp_generation : for i in 0 to 255 generate
        gp_inst : gp_generator port map(i_x => i_x(i), i_y => i_y(i), o_g => s_g_in(i), o_p => s_p_in(i));
    end generate;
--Carry Operations

--Stage 1
        s_g_1(0) <= s_g_in(0);
        s_p_1(0) <= s_p_in(0);
    carry_stage1 : for i in 0 to 254 generate
        carry_inst : carry_operation port map(i_g1 => s_g_in(i), i_g2 => s_g_in(i+1), 
        i_p1 => s_p_in(i), i_p2 => s_p_in(i+1), o_g => s_g_1(i+1), o_p => s_p_1(i+1));
    end generate;

--Stage 2
    buffa1 : for i in 0 to 1 generate
        s_g_2(i) <= s_g_1(i);
        s_p_2(i) <= s_p_1(i);
    end generate;
    carry_stage2 : for i in 0 to 253 generate
        carry_inst : carry_operation port map(i_g1 => s_g_1(i), i_g2 => s_g_1(i+2), 
        i_p1 => s_p_1(i), i_p2 => s_p_1(i+2), o_g => s_g_2(i+2), o_p => s_p_2(i+2));
    end generate;

--Stage 3
    buffa2 : for i in 0 to 3 generate
        s_g_3(i) <= s_g_2(i);
        s_p_3(i) <= s_p_2(i);
    end generate;
    carry_stage3 : for i in 0 to 251 generate
        carry_inst : carry_operation port map(i_g1 => s_g_2(i), i_g2 => s_g_2(i+4), 
        i_p1 => s_p_2(i), i_p2 => s_p_2(i+4), o_g => s_g_3(i+4), o_p => s_p_3(i+4));
    end generate;
    
--Stage 4
    buffa3 : for i in 0 to 7 generate
        s_g_4(i) <= s_g_3(i);
        s_p_4(i) <= s_p_3(i);
    end generate;
    carry_stage4 : for i in 0 to 247 generate
        carry_inst : carry_operation port map(i_g1 => s_g_3(i), i_g2 => s_g_3(i+8), 
        i_p1 => s_p_3(i), i_p2 => s_p_3(i+8), o_g => s_g_4(i+8), o_p => s_p_4(i+8));
    end generate;
    
--Stage 5
    buffa4 : for i in 0 to 15 generate
        s_g_5(i) <= s_g_4(i);
        s_p_5(i) <= s_p_4(i);
    end generate;
    carry_stage5 : for i in 0 to 239 generate
        carry_inst : carry_operation port map(i_g1 => s_g_4(i), i_g2 => s_g_4(i+16), 
        i_p1 => s_p_4(i), i_p2 => s_p_4(i+16), o_g => s_g_5(i+16), o_p => s_p_5(i+16));
    end generate;
 
--Stage 6
    buffa5 : for i in 0 to 31 generate
        s_g_6(i) <= s_g_5(i);
        s_p_6(i) <= s_p_5(i);
    end generate;
    carry_stage6 : for i in 0 to 223 generate
        carry_inst : carry_operation port map(i_g1 => s_g_5(i), i_g2 => s_g_5(i+32), 
        i_p1 => s_p_5(i), i_p2 => s_p_5(i+32), o_g => s_g_6(i+32), o_p => s_p_6(i+32));
    end generate;
    
--Stage 7
    buffa6 : for i in 0 to 63 generate
        s_g_7(i) <= s_g_6(i);
        s_p_7(i) <= s_p_6(i);
    end generate;
    carry_stage7 : for i in 0 to 191 generate
        carry_inst : carry_operation port map(i_g1 => s_g_6(i), i_g2 => s_g_6(i+64), 
        i_p1 => s_p_6(i), i_p2 => s_p_6(i+64), o_g => s_g_7(i+64), o_p => s_p_7(i+64));
    end generate;
    
--Stage 8
    buffa7 : for i in 0 to 127 generate
        s_g_8(i) <= s_g_7(i);
        s_p_8(i) <= s_p_7(i);
    end generate;
    carry_stage8 : for i in 0 to 127 generate
        carry_inst : carry_operation port map(i_g1 => s_g_7(i), i_g2 => s_g_7(i+128), 
        i_p1 => s_p_7(i), i_p2 => s_p_7(i+128), o_g => s_g_8(i+128), o_p => s_p_8(i+128));
    end generate;

--Carry Stage
    s_carry <= s_g_8;
    cout <= s_carry(255);
    sum(0) <= s_p_in(0);

--Addition stage
    adderInst : for i in 1 to 255 generate
        sum(i) <= s_carry(i-1) xor s_p_in(i); 
    end generate;
    
--Output value
   
    o_result <= cout & sum;
    
end Behavioral;

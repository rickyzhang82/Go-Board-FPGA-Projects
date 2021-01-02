library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Segment_Display is
    port (
        i_Clk         : in  std_logic;
        i_Switch_1    : in  std_logic;
        -- Segment2 is lower digit, Segment1 is upper digit
        o_Segment2_A  : out std_logic;
        o_Segment2_B  : out std_logic;
        o_Segment2_C  : out std_logic;
        o_Segment2_D  : out std_logic;
        o_Segment2_E  : out std_logic;
        o_Segment2_F  : out std_logic;
        o_Segment2_G  : out std_logic
    );
end entity Segment_Display;

architecture RTL of Segment_Display is

    constant    c_COUNT_LIMIT   : integer := 9;
    signal      r_Switch_1      : std_logic := '0';
    signal      w_Switch_1      : std_logic;
    signal      r_Count         : integer range 0 to c_COUNT_LIMIT := 0;
    signal      w_Segment_A     : std_logic; 
    signal      w_Segment_B     : std_logic; 
    signal      w_Segment_C     : std_logic; 
    signal      w_Segment_D     : std_logic; 
    signal      w_Segment_E     : std_logic; 
    signal      w_Segment_F     : std_logic; 
    signal      w_Segment_G     : std_logic; 

begin
    
    -- call debounce switch logic for input i_Switch_1
    Debounce_Inst : entity work.Debounce_Switch
        port map (
            i_Clk       => i_Clk,
            i_Switch    => i_Switch_1,
            o_Switch    => w_Switch_1
        );
    
    p_Register : process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            
            r_Switch_1 <= w_Switch_1;

            -- if the switch is on the falling edge
            if r_Switch_1 = '0' and w_Switch_1 = '1' then

                -- increase internal r_Count
                if r_Count = 9 then
                    r_Count <= 0;
                else
                    r_Count <= r_Count + 1;
                end if;
                
            end if;

        end if;

    end process p_Register;

    -- call binaty to 7 segment logic for r_Count
    Binary_To_7Segment_Inst : entity work.Binary_To_7Segment
        port map (
            i_Clk           => i_Clk,
            i_Binary_Num    => std_logic_vector(to_unsigned(r_Count, 4)),
            o_Segment_A     => w_Segment_A,
            o_Segment_B     => w_Segment_B,
            o_Segment_C     => w_Segment_C,
            o_Segment_D     => w_Segment_D,
            o_Segment_E     => w_Segment_E,
            o_Segment_F     => w_Segment_F,
            o_Segment_G     => w_Segment_G
        );

    -- Go board special 0 -> activate 7 segment
    o_Segment2_A <= not w_Segment_A;
    o_Segment2_B <= not w_Segment_B;
    o_Segment2_C <= not w_Segment_C;
    o_Segment2_D <= not w_Segment_D;
    o_Segment2_E <= not w_Segment_E;
    o_Segment2_F <= not w_Segment_F;
    o_Segment2_G <= not w_Segment_G;

end architecture RTL;
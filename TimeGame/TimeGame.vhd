-- Time Game
-- 1. Press switch 1 to start count down from 60 seconds.
-- 2. Press switch 2 when you feel count down to 0.
-- 3. Show the end result of the count down. If it has passed 0, show the letter 'E'
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Segment_Display is
    port (
        i_Clk         : in  std_logic;
        i_Switch_1    : in  std_logic;
         -- Segment2 is lower digit, Segment1 is upper digit
        o_Segment1_A  : out std_logic;
        o_Segment1_B  : out std_logic;
        o_Segment1_C  : out std_logic;
        o_Segment1_D  : out std_logic;
        o_Segment1_E  : out std_logic;
        o_Segment1_F  : out std_logic;
        o_Segment1_G  : out std_logic;
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

    constant    c_COUNT_LIMIT    : integer := 60;
    constant    c_DECIMIAL_LIMIT : integer := 2;
    constant    c_INPUT_WIDTH    : integer := 6;
    constant    c_BCD_WIDTH      : integer := 8;
    signal      r_Switch_1       : std_logic := '0';
    signal      w_Switch_1       : std_logic;
    signal      r_Count          : integer range 1 to c_COUNT_LIMIT := 1;
    signal      w_Count_BCD      : std_logic_vector(c_BCD_WIDTH - 1 downto 0) := (others => '0');
    signal      w_BCD_Done       : std_logic;
    signal      w_Segment1_A     : std_logic; 
    signal      w_Segment1_B     : std_logic; 
    signal      w_Segment1_C     : std_logic; 
    signal      w_Segment1_D     : std_logic; 
    signal      w_Segment1_E     : std_logic; 
    signal      w_Segment1_F     : std_logic; 
    signal      w_Segment1_G     : std_logic; 
    signal      w_Segment2_A     : std_logic; 
    signal      w_Segment2_B     : std_logic; 
    signal      w_Segment2_C     : std_logic; 
    signal      w_Segment2_D     : std_logic; 
    signal      w_Segment2_E     : std_logic; 
    signal      w_Segment2_F     : std_logic; 
    signal      w_Segment2_G     : std_logic;


begin
    
    -- call debounce switch logic for input i_Switch_1
    Debounce_Inst : entity work.Debounce_Switch
        port map (
            i_Clk       => i_Clk,
            i_Switch    => i_Switch_1,
            o_Switch    => w_Switch_1
        );
    
    -- Convert r_Count from binary to BCD
    Binary_to_BCD_Inst : entity work.Binary_to_BCD
        generic map (
            g_INPUT_WIDTH   => c_INPUT_WIDTH,
            g_DECIMAL_DIGITS=> c_DECIMIAL_LIMIT
        )
        port map (
            i_Clock         => i_Clk,
            i_Start         => '1',
            i_Binary        => std_logic_vector(to_unsigned(r_Count, 6)),
            o_BCD           => w_Count_BCD,
            o_DV            => w_BCD_Done
        );

    -- get higher decimal segment display
    Binary_To_7Segment1_Inst : entity work.Binary_To_7Segment
        port map (
            i_Clk           => i_Clk,
            i_Binary_Num    => w_Count_BCD(7 downto 4),
            o_Segment_A     => w_Segment1_A,
            o_Segment_B     => w_Segment1_B,
            o_Segment_C     => w_Segment1_C,
            o_Segment_D     => w_Segment1_D,
            o_Segment_E     => w_Segment1_E,
            o_Segment_F     => w_Segment1_F,
            o_Segment_G     => w_Segment1_G
        );

    -- get lower decimal segment display
    Binary_To_7Segment2_Inst : entity work.Binary_To_7Segment
        port map (
            i_Clk           => i_Clk,
            i_Binary_Num    => w_Count_BCD(3 downto 0),
            o_Segment_A     => w_Segment2_A,
            o_Segment_B     => w_Segment2_B,
            o_Segment_C     => w_Segment2_C,
            o_Segment_D     => w_Segment2_D,
            o_Segment_E     => w_Segment2_E,
            o_Segment_F     => w_Segment2_F,
            o_Segment_G     => w_Segment2_G
        );

    p_Register : process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            
            r_Switch_1 <= w_Switch_1;

            -- if the switch is on the falling edge
            if r_Switch_1 = '0' and w_Switch_1 = '1' then

                -- increase internal r_Count
                if r_Count = c_COUNT_LIMIT then
                    r_Count <= 1;
                else
                    r_Count <= r_Count + 1;
                end if;
                
            end if;

            if w_BCD_Done = '1' then
                -- Activate higher segment
                o_Segment1_A <= not w_Segment1_A;
                o_Segment1_B <= not w_Segment1_B;
                o_Segment1_C <= not w_Segment1_C;
                o_Segment1_D <= not w_Segment1_D;
                o_Segment1_E <= not w_Segment1_E;
                o_Segment1_F <= not w_Segment1_F;
                o_Segment1_G <= not w_Segment1_G;
                -- Activate lower segment
                o_Segment2_A <= not w_Segment2_A;
                o_Segment2_B <= not w_Segment2_B;
                o_Segment2_C <= not w_Segment2_C;
                o_Segment2_D <= not w_Segment2_D;
                o_Segment2_E <= not w_Segment2_E;
                o_Segment2_F <= not w_Segment2_F;
                o_Segment2_G <= not w_Segment2_G;
            end if;

        end if;

    end process p_Register;


end architecture RTL;
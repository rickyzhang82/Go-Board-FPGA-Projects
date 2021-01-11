-- Time Game
-- 1. Press the switch 1 to start count down from (c_COUNT_LIMIT) seconds.
-- 2. Close your eyes. Press the switch 2 when you feel count down to 0.
-- 3. Show the end result of the count down. If it has passed 0, light up the LED 1.
-- 4. The one with the lowest seconds wins the game.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Time_Game is
    port (
        i_Clk         : in  std_logic;
        -- Switch 1 count down start button
        i_Switch_1    : in  std_logic;
        -- Switch 2 count down stop button
        i_Switch_2    : in  std_logic;
        -- LED1 show error
        o_LED_1       : out std_logic; 
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
end entity Time_Game;

architecture RTL of Time_Game is

    --
    -- Constant
    --
    -- the count down upper limit in seconds
    constant    c_COUNT_LIMIT    : integer := 10;
    -- the decimial digit upper limit
    constant    c_DECIMIAL_LIMIT : integer := 2;
    -- the binary digit width 60 < 2^6 = 64
    constant    c_INPUT_WIDTH    : integer := 6;
    -- the BCD number width. Each decimal digit cost 4 bits
    constant    c_BCD_WIDTH      : integer := 8;
    -- the default clock cycle
    constant    c_CLOCK_CYCLE    : integer := 25000000;

    --
    -- Registers
    --
    signal      r_Switch_1       : std_logic := '0';
    signal      r_Switch_2       : std_logic := '0';
    signal      r_Count          : integer range 0 to c_COUNT_LIMIT := c_COUNT_LIMIT;
    signal      r_Sec_Ticks      : integer range 0 to c_CLOCK_CYCLE-1 := 0;
    signal      r_Count_Down     : std_logic := '0';

    --
    -- Wires
    --
    signal      w_Switch_1       : std_logic;
    signal      w_Switch_2       : std_logic;
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
    Debounce_S1_Inst : entity work.Debounce_Switch
        port map (
            i_Clk       => i_Clk,
            i_Switch    => i_Switch_1,
            o_Switch    => w_Switch_1
        );
 
    -- call debounce switch logic for input i_Switch_2
    Debounce_S2_Inst : entity work.Debounce_Switch
        port map (
            i_Clk       => i_Clk,
            i_Switch    => i_Switch_2,
            o_Switch    => w_Switch_2
        );
    
    -- Convert r_Count from binary to BCD
    Binary_to_BCD_Inst : entity work.Binary_to_BCD
        generic map (
            g_INPUT_WIDTH   => c_INPUT_WIDTH,
            g_DECIMAL_DIGITS=> c_DECIMIAL_LIMIT
        )
        port map (
            i_Clock         => i_Clk,
            -- always ready to start
            i_Start         => '1',
            i_Binary        => std_logic_vector(to_unsigned(r_Count, 6)),
            o_BCD           => w_Count_BCD,
            o_DV            => w_BCD_Done
        );

    -- get higher decimal segment display
    Binary_To_7Segment1_Inst : entity work.Binary_To_7Segment
        port map (
            i_Clk           => i_Clk,
            -- slice w_Count_BCD from 7th to 4th
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
            -- slice w_Count_BCD from 3rd to 0
            i_Binary_Num    => w_Count_BCD(3 downto 0),
            o_Segment_A     => w_Segment2_A,
            o_Segment_B     => w_Segment2_B,
            o_Segment_C     => w_Segment2_C,
            o_Segment_D     => w_Segment2_D,
            o_Segment_E     => w_Segment2_E,
            o_Segment_F     => w_Segment2_F,
            o_Segment_G     => w_Segment2_G
        );

    p_TimeGame : process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            -- create registers
            r_Switch_1 <= w_Switch_1;
            r_Switch_2 <= w_Switch_2;

            -- if the switch 1 is on the falling edge
            -- start to count down
            if r_Switch_1 = '0' and w_Switch_1 = '1' then
                o_LED_1 <= '0';
                r_Count_Down <= '1';
                r_Sec_Ticks <= 0;
                r_Count <= c_COUNT_LIMIT;
            end if;

            -- if the switch 2 is on the falling edge
            -- stop counting down
            if r_Switch_2 = '0' and w_Switch_2 = '1' then
                r_Count_Down <= '0';
            end if;
            
            -- when count down starts
            if r_Count_Down = '1' then
                -- bump up second ticks
                if r_Sec_Ticks = c_CLOCK_CYCLE - 1 then
                    r_Sec_Ticks <= 0;
                    r_Count <= r_Count - 1;
                else
                    r_Sec_Ticks <= r_Sec_Ticks + 1;
                end if;

                -- count down reach 0
                if r_Count = 0 then
                    -- show error
                    o_LED_1 <= '1';
                    -- stop count down
                    r_Count_Down <= '0';
                end if;
            end if;

            -- show two decimial digits when BCD done signal is ready
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

    end process p_TimeGame;


end architecture RTL;
library ieee;
use ieee.std_logic_1164.all;

entity UART_RX_To_7_Seg_Top is
    port (
        -- clock at 25Mhz
        i_Clk         : in  std_logic;
        -- UART RX dat
        i_UART_RX     : in  std_logic;

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
end entity UART_RX_To_7_Seg_Top;

architecture rtl of UART_RX_To_7_Seg_Top is

    -- 25 Mhz / 115200 Baud = 217 clock per bit
    constant    c_CLKS_PER_BIT      : integer           := 217;
    constant    c_START_BIT         : std_logic         := '0';
    constant    c_STOP_BIT          : std_logic         := '1';
    constant    c_NUM_DATA_BITS     : integer           := 8;

    signal      w_RX_DV             : std_logic         := '0';
    signal      w_RX_Byte           : std_logic_vector(7 downto 0);
    signal      w_BCD_Done          : std_logic;
    signal      w_Segment1_A        : std_logic; 
    signal      w_Segment1_B        : std_logic; 
    signal      w_Segment1_C        : std_logic; 
    signal      w_Segment1_D        : std_logic; 
    signal      w_Segment1_E        : std_logic; 
    signal      w_Segment1_F        : std_logic; 
    signal      w_Segment1_G        : std_logic; 
    signal      w_Segment2_A        : std_logic; 
    signal      w_Segment2_B        : std_logic; 
    signal      w_Segment2_C        : std_logic; 
    signal      w_Segment2_D        : std_logic; 
    signal      w_Segment2_E        : std_logic; 
    signal      w_Segment2_F        : std_logic; 
    signal      w_Segment2_G        : std_logic;

begin

    UART_RX_INST : entity work.UART_RX
        generic map (
            g_CLKS_PER_BIT  => c_CLKS_PER_BIT,
            g_START_BIT     => c_START_BIT,
            g_STOP_BIT      => c_STOP_BIT,
            g_NUM_DATA_BITS => c_NUM_DATA_BITS
        )
        port map (
            i_Clk           => i_Clk,
            i_RX_Serial     => i_UART_RX,
            o_RX_DV         => w_RX_DV,
            o_RX_Byte       => w_RX_Byte
        );

    -- get higher digit segment display
    Binary_To_7Segment_INST1 : entity work.Binary_To_7Segment
    port map (
        i_Clk           => i_Clk,
        -- slice w_Count_BCD from 7th to 4th
        i_Binary_Num    => w_RX_Byte(7 downto 4),
        o_Segment_A     => w_Segment1_A,
        o_Segment_B     => w_Segment1_B,
        o_Segment_C     => w_Segment1_C,
        o_Segment_D     => w_Segment1_D,
        o_Segment_E     => w_Segment1_E,
        o_Segment_F     => w_Segment1_F,
        o_Segment_G     => w_Segment1_G
    );

    -- get lower digit segment display
    Binary_To_7Segment2_Inst : entity work.Binary_To_7Segment
    port map (
        i_Clk           => i_Clk,
        -- slice w_Count_BCD from 3rd to 0
        i_Binary_Num    => w_RX_Byte(3 downto 0),
        o_Segment_A     => w_Segment2_A,
        o_Segment_B     => w_Segment2_B,
        o_Segment_C     => w_Segment2_C,
        o_Segment_D     => w_Segment2_D,
        o_Segment_E     => w_Segment2_E,
        o_Segment_F     => w_Segment2_F,
        o_Segment_G     => w_Segment2_G
    );
   
    p_RX: process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            -- show two decimial digits when BCD done signal is ready
            if w_RX_DV = '1' then
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
    end process;

end architecture rtl;
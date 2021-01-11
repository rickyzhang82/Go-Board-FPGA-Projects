--
-- This file contains the UART Transmitter.  This transmitter is able
-- to transmit 8 bits of serial data, one start bit, one stop bit,
-- and no parity bit.  When transmit is complete o_TX_Done will be
-- driven high for one clock cycle.
--
-- Set Generic g_CLKS_PER_BIT as follows:
-- g_CLKS_PER_BIT = (Frequency of i_Clk)/(Frequency of UART)
-- Example: 25 MHz Clock, 115200 baud UART
-- (25000000)/(115200) = 217
--
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_TX is
    generic (
        -- 25 Mhz, 115200 baud UART
        -- 25 * 10^6 / 115200 = 217 cycle per bit
        g_CLKS_PER_BIT  : integer                       := 217;
        -- start bit indicator
        g_START_BIT     : std_logic                     := '0';
        -- stop bit indicator
        g_STOP_BIT      : std_logic                     := '1';
        -- number of data bits to receive
        g_NUM_DATA_BITS : integer                       := 8
    );
    port (
        -- clock signal
        i_Clk           : in  std_logic;
        -- input TX byte signal
        i_TX_Byte       : in  std_logic_vector(g_NUM_DATA_BITS-1 downto 0);
        -- one clock cycle wide sent data active signal
        o_TX_Active     : out std_logic;
        -- one clock cycle wide sent data done signal
        o_TX_Done       : out std_logic;
        -- output serial signal
        o_TX_Serial     : out std_logic
    );
end entity UART_TX;

-- TODO add arch
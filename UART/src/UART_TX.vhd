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
        -- input byte data valid signal
        i_TX_DV         : in  std_logic;
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

architecture rtl of UART_TX is

    -- state type of state machine
    type t_UART_STATE is (s_IDLE, s_START_BIT, s_DATA_BIT, s_STOP_BIT, s_CLEANUP);
    -- register for UART state machine
    signal r_State              : t_UART_STATE                                  := s_IDLE;
    -- register for clock counter
    signal r_Clock_Count        : integer range 0 to g_CLKS_PER_BIT-1           := 0;
    -- register for bit index
    signal r_Bit_Index          : integer range 0 to g_NUM_DATA_BITS-1          := 0;
    -- register for TX data byte
    signal r_TX_Byte            : std_logic_vector(g_NUM_DATA_BITS-1 downto 0);
    -- register for send activeness
    signal r_TX_Active          : std_logic                                     := '0';
    -- register for send done
    signal r_TX_Done            : std_logic                                     := '0';
    -- register for output serial
    signal r_TX_Serial          : std_logic                                     := '1';
    -- for simulation purpose to display internal state
    signal w_State              : std_logic_vector(2 downto 0);

begin

    p_UART_TX : process (i_Clk)
    begin
        if rising_edge(i_Clk) then

            case r_State is
                -- idle state
                when s_IDLE =>
                    r_Clock_Count <= 0;
                    r_Bit_Index   <= 0;
                    r_TX_Active   <= '0';
                    r_TX_Done     <= '0';
                    r_TX_Serial   <= g_STOP_BIT;
                    
                    -- send data valid
                    if i_TX_DV = '1' then
                        r_State   <= s_START_BIT;
                        r_TX_Byte <= i_TX_Byte;
                   end if;
                    
                when s_START_BIT =>
                    r_TX_Active <= '1';
                    r_TX_Serial <= g_START_BIT;
                    if r_Clock_Count = g_CLKS_PER_BIT-1 then
                        r_State       <= s_DATA_BIT;
                        r_Clock_Count <= 0;
                    else
                        r_Clock_Count <= r_Clock_Count + 1;
                    end if;
                
                when s_DATA_BIT =>
                    r_TX_Serial <= r_TX_Byte(r_Bit_Index);
                    if r_Clock_Count = g_CLKS_PER_BIT-1 then
                        r_Clock_Count <= 0;
                        if r_Bit_Index = g_NUM_DATA_BITS-1 then
                            r_State <= s_STOP_BIT;
                        else
                            r_Bit_Index <= r_Bit_Index + 1;
                        end if;
                    else
                        r_Clock_Count <= r_Clock_Count + 1;
                    end if;
                
                when s_STOP_BIT =>
                    r_TX_Serial <= g_STOP_BIT;
                    if r_Clock_Count = g_CLKS_PER_BIT-1 then
                        r_Clock_Count <= 0;
                        r_State <= s_CLEANUP;
                    else
                        r_Clock_Count <= r_Clock_Count + 1;
                    end if;
                
                -- stay here for 1 clock cycle
                when s_CLEANUP =>
                    r_TX_Active <= '0';
                    r_TX_Done <= '1';
                    r_State <= s_IDLE;
                
                when others =>
                    r_State <= s_IDLE;

            end case;
        end if; -- end if rising_edge(i_Clk)
    end process p_UART_TX;

-- assign the registers to the output
o_TX_Active     <= r_TX_Active;
o_TX_Done       <= r_TX_Done;
o_TX_Serial     <= r_TX_Serial;

-- for simulation purpose
-- Create a signal for simulation purposes (allows waveform display)
w_State <= "000" when r_State = s_Idle else
           "001" when r_State = s_START_BIT else
           "010" when r_State = s_DATA_BIT else
           "011" when r_State = s_STOP_BIT else
           "100" when r_State = s_CLEANUP else
           "101"; -- should never get here

end architecture rtl;
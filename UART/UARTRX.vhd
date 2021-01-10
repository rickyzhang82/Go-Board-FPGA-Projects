--
-- This file contains the UART Receiver.  This receiver is able to
-- receive 8 bits of serial data, one start bit, one stop bit,
-- and no parity bit.  When receive is complete o_rx_dv will be
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

entity UART_RX is
    generic (
        -- 25 Mhz, 115200 baud UART
        -- 25 * 10^6 / 115200 = 217 cycle per bit
        g_CLKS_PER_BIT  : integer                       := 217;
        -- start bit indicator
        g_START_BIT     : std_logic                     := '0';
        -- stop bit indicator
        g_STOP_BIT      : std_logic                     := '1';
        -- number of bits to receive
        g_NUM_BITS      : integer                       := 8
    );
    port (
        i_Clk           : in  std_logic;
        i_RX_Serial     : in  std_logic;
        o_RX_DV         : out std_logic;
        o_RX_Byte       : out std_logic_vector(7 downto 0)
    );
end entity UART_RX;

architecture rtl of UAR_TRX is
    
    -- state type of state machine
    type t_UART_STATE is (s_IDLE, s_START_BIT, s_DATA_BIT, s_STOP_BIT, s_CLEANUP);
    -- register for UART state machine
    signal r_State              : t_UART_STATE                              := s_IDLE;
    -- register for clock counter
    signal r_Clock_Count        : unsigned range 0 to g_CLKS_PER_BIT-1      := 0;
    -- register for bit index
    signal r_Bit_Index          : unsigned range 0 to g_NUM_BITS-1          := 0;
    -- register for received byte
    signal r_RX_Byte            : std_logic_vector(g_NUM_BITS-1 downto 0)   := (others => '0');
    -- register for receive readiness
    signal r_RX_DV              : std_logic                                 := '0';

begin
    
   p_RX: process(i_Clk)
   begin

       if  rising_edge(i_Clk) then

            -- in idle state
            case r_State is

                -- idel state
                when s_IDLE =>
                    r_RX_DV <= '0';
                    r_Clock_Count <= 0;
                    r_Bit_Index <= 0;
                    if i_RX_Serial = g_START_BIT then
                        -- found start bit
                        r_State <= s_START_BIT;
                    else
                        -- reset
                        r_State <= s_IDLE;
                    end if;
            
                -- check the middle of start bit and make sure it is still low
                when s_START_BIT =>
                    r_Clock_Count <= r_Clock_Count + 1;
                    if r_Clock_Count = g_CLKS_PER_BIT / 2 then
                        -- reset clock count
                        r_Clock_Count <= 0;
                        if i_RX_Serial = 0 then
                            r_State <= s_DATA_BIT;
                        else
                            -- invalid start bit
                            r_State <= s_IDLE;
                        end if;
                    end if;
               
                -- sample data bit in the middle
                when s_DATA_BIT =>
                    r_Clock_Count <= r_Clock_Count + 1;
                    -- reach the middle 
                    if r_Clock_Count = g_CLKS_PER_BIT then
                        r_Bx_Byte[r_Bit_Index] <= i_RX_Serial;
                        r_Clock_Count <= 0;
                        r_Bit_Index <= r_Bit_Index + 1;
                    end if;
                    -- all 8 data bit has sampled
                    if r_Bit_Index = g_NUM_BITS then
                        r_State <= s_STOP_BIT;
                    end if;

                when s_STOP_BIT =>
                    r_Clock_Count <= r_Clock_Count + 1;
                    -- reach the middle 
                    if r_Clock_Count = g_CLKS_PER_BIT then
                        if i_RX_Serial = g_STOP_BIT then
                            r_RX_DV <= 1;
                            r_Clock_Count <= 0;
                            r_State <= s_CLEANUP;
                        else
                            r_State <= s_IDLE;
                        end if;
                    end if;
                
                -- stay here for one clock cycle
                when s_CLEANUP =>
                    r_RX_DV <= 0;
                    r_State <= s_IDLE;

            end case;
       end if; -- end if rising_eduge(i_Clk)

   end process p_RX;

-- assign the registers to the output
o_RX_Byte <= r_RX_Byte;
o_RX_DV <= r_RX_DV;

end architecture rtl;
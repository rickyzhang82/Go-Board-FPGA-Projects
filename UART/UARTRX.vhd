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
        g_CLKS_PER_BIT : integer := 217
    );
    port (
        i_Clk           : in  std_logic;
        i_RX_Serial     : in  std_logic;
        o_RX_DV         : out std_logic;
        o_RX_Byte       : out std_logic_vector(7 downto 0)
    );
end entity UART_RX;

architecture rtl of UAR_TRX is
    
    type t_UART_STATE is (s_IDLE, s_START_BIT, s_DATA_BIT, s_STOP_BIT, s_ERR);
    -- register for UART state machine
    signal r_State : t_UART_STATE := s_IDLE;


begin
    
   p_RX: process(i_Clk)
   begin

       if  rising_edge(clk) then
           
       end if;

   end process p_RX;
    
end architecture rtl;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debounce_Switch is
    port (
        i_Clk       : in  std_logic;
        i_Switch    : in  std_logic;
        o_Switch    : out std_logic
    );
end entity Debounce_Switch;

architecture RTL of Debounce_Switch is
    
    -- Set for 250,000 clock ticks of 25Mhz clock (10ms)
    -- 10ms / 40ns = 10 * 10^-3 / (40 * 10^-9) = 250,000
    constant c_DEBOUNCE_LIMIT : integer := 250000;

    signal r_Count : integer range 0 to c_DEBOUNCE_LIMIT := 0;
    signal r_State : std_logic := '0';

begin
    
    p_Debounce: process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            
            if (i_Switch /= r_State and r_Count < c_DEBOUNCE_LIMIT) then
                r_Count <= r_Count + 1;
            elsif r_Count = c_DEBOUNCE_LIMIT then
                r_Count <= 0;
                r_State <= i_Switch;
            else
                r_Count <= 0;
            end if;

        end if;
    end process p_Debounce;
    
    o_Switch <= r_State;

end architecture RTL;
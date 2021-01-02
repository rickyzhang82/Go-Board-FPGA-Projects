-- Project: This project should toggle the state of LED 1, only when Switch 1 is released.
--  We need a register to store the previous state of Switch 1. 
--- Also we need another register to store the previous state of LED to toggle.

library IEEE;
use IEEE.std_logic_1164.all;

entity Debounce_Project_Top is
    port (
        i_Clk       : in  std_logic;
        i_Switch_1  : in  std_logic;
        o_LED_1     : out std_logic);
end entity Debounce_Project_Top;

architecture RTL of Debounce_Project_Top is
    
    signal r_LED_1      : std_logic := '1';
    signal r_Switch_1   : std_logic := '0';
    signal w_Switch_1   : std_logic;

begin

    -- Instantiate Debounce Filter
    -- map inner port on the right to outer port on the right
    Debounce_Inst : entity work.Debounce_Switch
        port map (
            i_Clk       => i_Clk,
            i_Switch    => i_Switch_1,
            o_Switch    => w_Switch_1);

   p_Register : process(i_Clk) is
    begin
        if rising_edge(i_Clk) then
            -- Create a register
            r_Switch_1 <= w_Switch_1;

            -- look for fallin edge of filtered version w_Switch_1.
            -- When the current value w_Switch_1 is low and the previous value
            -- r_Swtich_1 is high, toggle LED
            if w_Switch_1 = '0' and r_Switch_1 = '1' then
                r_LED_1 <= not r_LED_1;
            end if;

            -- Ricky's comment: 
            -- HDL is a hardware description language.
            -- r_Switch_1 at line 29 means r_Switch_1 is the output of a flip-flop with w_Switch_1 as input.
            -- Prior to the rising edge of clock, r_Switch_1 is still the previous state of w_Switch_1.
            -- r_Switch_1 at line 34 means r_Switch_1 is the current state prior to the rising edge of clock.
        end if;
    end process p_Register; 
    
    o_LED_1 <= r_LED_1;

end architecture RTL;
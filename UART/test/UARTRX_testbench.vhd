--
-- Test Bench for UARTRX.vhd
--
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity UART_RX_TB is
end entity UART_RX_TB;

architecture Behave of UART_RX_TB is

    -- Test Bench at 25 Mhz clock
    constant c_CLK_PERIOD       : time              :=  40 ns;
    -- 25 Mhz / 115200 Baud = 217 clock per bit
    constant c_CLKS_PER_BIT     : integer           := 217;
    -- 1 / 115200 Baud = 8680 ns
    constant c_BIT_PERIOD       : time              := 8680 ns;

    -- simulated clock
    signal r_Clock              : std_logic                     := '0';
    -- wire to output byte
    signal w_RX_Byte            : std_logic_vector(7 downto 0)        ;
    -- wire to output data valid
    signal w_RX_DV              : std_logic                           ;
    -- input serial data
    signal r_RX_Serial          : std_logic                     := '1';

    -- Simulate UART writes a byte to o_Serial
    -- at 115200 Baud with one stop bit
    procedure UART_WRITE_BYTE (
        i_Data_In                   : in  std_logic_vector(7 downto 0);
        signal      o_Serial        : out std_logic
    ) is
    begin
        -- send start bit low
        o_Serial <= '0';
        wait for c_BIT_PERIOD;

        -- send data byte
        for ii in 0 to 7 loop
            o_Serial <= i_Data_In(ii);
            wait for c_BIT_PERIOD;
        end loop;

        -- send stop bit high
        o_Serial <= '1';
        wait for c_BIT_PERIOD;
    end procedure UART_WRITE_BYTE;

begin

    -- Instantiate UART Receiver
    UART_RX_INST : entity work.UART_RX
        generic map (
            g_CLKS_PER_BIT  => c_CLKS_PER_BIT,
            g_START_BIT     => '0',
            g_STOP_BIT      => '1',
            g_NUM_DATA_BITS => 8
        )
        port map (
            i_Clk           => r_Clock,
            i_RX_Serial     => r_RX_Serial,
            o_RX_DV         => w_RX_DV,
            o_RX_Byte       => w_RX_Byte
        );

    -- create clock signal
    r_Clock <= not r_Clock after c_CLK_PERIOD/2;

    test_bench : process
    begin
        -- send a command to UART
        wait until rising_edge(r_Clock);
        
        assert w_RX_DV = '0' report "Test Failed -- Incorrect data valid. Expect 0." severity failure;
        
        UART_WRITE_BYTE(X"37", r_RX_Serial);
        wait until rising_edge(r_Clock);
        assert w_RX_Byte = X"37" report "Test Failed -- Incorrect Byte Received" severity failure;

        assert false report "Test Passed!" severity failure;

    end process test_bench;

end architecture Behave;
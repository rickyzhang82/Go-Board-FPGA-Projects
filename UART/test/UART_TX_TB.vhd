--
-- Test Bench for UART_RX.vhd
--
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity UART_TX_TB is
end entity UART_TX_TB;

architecture rtl of UART_TX_TB is

    -- Test Bench at 25 Mhz clock
    constant c_CLK_PERIOD       : time                          :=  40 ns;
    -- 25 Mhz / 115200 Baud = 217 clock per bit
    constant c_CLKS_PER_BIT     : integer                       := 217;
    -- 1 / 115200 Baud = 8680 ns
    constant c_BIT_PERIOD       : time                          := 8680 ns;

    -- simulated clock
    signal r_Clock              : std_logic                     := '0';
    -- input data valid
    signal r_TX_DV              : std_logic                     := '0';
    -- input TX byte
    signal r_TX_Byte            : std_logic_vector(7 downto 0)        ;
    -- wiret to output TX active
    signal w_TX_Active          : std_logic;
    -- wire to output TX done
    signal w_TX_Done            : std_logic;
    -- wrie to output TX serial
    signal w_TX_Serial          : std_logic;

begin

    -- initiate UART TX module
    UART_TX_INST : entity work.UART_TX
        generic map (
            g_CLKS_PER_BIT  => c_CLKS_PER_BIT,
            g_START_BIT     => '0',
            g_STOP_BIT      => '1',
            g_NUM_DATA_BITS => 8
        )
        port map (
            i_Clk           => r_Clock,
            i_TX_DV         => r_TX_DV,
            i_TX_Byte       => r_TX_Byte,
            o_TX_Active     => w_TX_Active,
            o_TX_Done       => w_TX_Done,
            o_TX_Serial     => w_TX_Serial
        );

        -- create clock signal
        r_Clock <= not r_Clock after c_CLK_PERIOD/2;
        -- Keeps the UART Receive input high (default) when
        test_bench : process
        begin
            wait until rising_edge(r_Clock);

            assert w_TX_Active = '0' report "Test Failed -- Incorrect TX Active. Expect 0." severity failure;
            assert w_TX_Done = '0' report "Test Failed -- Incorrect TX Done. Expect 0." severity failure;

            r_TX_Byte <= X"37";
            r_TX_DV <= '1';
            -- wait till enter s_IDLE
            wait until rising_edge(r_Clock);
            -- wait till enter s_START_BIT
            wait until rising_edge(r_Clock);
            r_TX_DV <= '0';

            wait until rising_edge(r_Clock);
            assert w_TX_Active = '1' report "Test Failed -- Incorrect TX Active. Expect 1." severity failure;

            wait for c_BIT_PERIOD/2;
            assert w_TX_Serial = '0' report "Test Failed -- expect start bit." severity failure;

            -- sample data in the middel
            for ii in 0 to 7 loop
                wait for c_BIT_PERIOD;
                assert w_TX_Serial = r_TX_Byte(ii) report "Test Failed -- expect TX Serial match: "& integer'image(ii) severity failure;
            end loop;

            wait until w_TX_Done = '1';
           
            wait for c_BIT_PERIOD;
            assert w_TX_Serial = '1' report "Test Failed -- expect stop bit." severity failure;
            
            assert false report "Test Passed!" severity failure;

        end process test_bench;

end architecture rtl;


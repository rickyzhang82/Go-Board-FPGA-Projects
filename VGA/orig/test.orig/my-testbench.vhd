library ieee;
use ieee.std_logic_1164.all;

entity VGA_Test_Patterns_TB is
end entity VGA_Test_Patterns_TB;

architecture Behave of VGA_Test_Patterns_TB is 

  component VGA_Sync_Pulses is
    generic (
      g_TOTAL_COLS  : integer;
      g_TOTAL_ROWS  : integer;
      g_ACTIVE_COLS : integer;
      g_ACTIVE_ROWS : integer
      );
    port (
      i_Clk       : in  std_logic;
      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Col_Count : out std_logic_vector(9 downto 0);
      o_Row_Count : out std_logic_vector(9 downto 0)
      );
  end component VGA_Sync_Pulses;
  
  component Test_Pattern_Gen is
    generic (
      g_VIDEO_WIDTH : integer := 3;
      g_TOTAL_COLS  : integer := 800;
      g_TOTAL_ROWS  : integer := 525;
      g_ACTIVE_COLS : integer := 640;
      g_ACTIVE_ROWS : integer := 480
      );
    port (
      i_Clk       : in  std_logic;
      i_Pattern   : in  std_logic_vector(3 downto 0);
      i_HSync     : in  std_logic;
      i_VSync     : in  std_logic;
      --
      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Red_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
      o_Grn_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
      o_Blu_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0)
      );
  end component Test_Pattern_Gen;

  component VGA_Sync_Porch is
    generic (
      g_VIDEO_WIDTH : integer;
      g_TOTAL_COLS  : integer;
      g_TOTAL_ROWS  : integer;
      g_ACTIVE_COLS : integer;
      g_ACTIVE_ROWS : integer
      );
    port (
      i_Clk       : in std_logic;
      i_HSync     : in std_logic;
      i_VSync     : in std_logic;
      i_Red_Video : in std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
      i_Grn_Video : in std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
      i_Blu_Video : in std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
      --
      o_HSync     : out std_logic;
      o_VSync     : out std_logic;
      o_Red_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
      o_Grn_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
      o_Blu_Video : out std_logic_vector(g_VIDEO_WIDTH-1 downto 0)    
      );
  end component VGA_Sync_Porch;



  constant c_CLK_PERIOD  : time    := 40 ns; -- 25 MHz clock
  constant c_VIDEO_WIDTH : integer := 3;     -- 3 bits per pixel
  constant c_TOTAL_COLS  : integer := 800;
  constant c_TOTAL_ROWS  : integer := 525;
  constant c_ACTIVE_COLS : integer := 640;
  constant c_ACTIVE_ROWS : integer := 480;

  signal r_Clk : std_logic := '0';
  
  signal w_HSync_TP,    w_VSync_TP    : std_logic;
  
  signal w_Red_Video_TP    : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_TP    : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_TP    : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  
  -- Common VGA Signals
  signal w_HSync_VGA       : std_logic;
  signal w_VSync_VGA       : std_logic;
  signal w_HSync_Porch     : std_logic;
  signal w_VSync_Porch     : std_logic;
  signal w_Red_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
 
begin

  r_Clk <= not r_Clk after c_CLK_PERIOD/2;
 
  -- Generates Sync Pulses to run VGA
  VGA_Sync_Pulses_Inst : VGA_Sync_Pulses
    generic map (
      g_Total_Cols  => c_TOTAL_COLS,
      g_Total_Rows  => c_TOTAL_ROWS,
      g_Active_Cols => c_ACTIVE_COLS,
      g_Active_Rows => c_ACTIVE_ROWS)
    port map (
      i_Clk       => r_Clk,
      o_HSync     => w_HSync_VGA,
      o_VSync     => w_VSync_VGA,
      o_Col_Count => open,
      o_Row_Count => open);
  
  
  -- Drives Red/Grn/Blue video
  Test_Pattern_Gen_Inst : Test_Pattern_Gen
    generic map (
      g_VIDEO_WIDTH => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS)
    port map (
      i_Clk       => r_Clk,
      i_Pattern   => "0111",    -- black dots and white dots
      i_HSync     => w_HSync_VGA,
      i_VSync     => w_VSync_VGA,
      o_HSync     => w_HSync_TP,
      o_VSync     => w_VSync_TP,
      o_Red_Video => w_Red_Video_TP,
      o_Grn_Video => w_Grn_Video_TP,
      o_Blu_Video => w_Blu_Video_TP);
   
  -- setup Porch module 
  VGA_Sync_Porch_Inst : VGA_Sync_Porch
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS 
      )
    port map (
      i_Clk       => r_Clk,
      i_HSync     => w_HSync_VGA,
      i_VSync     => w_VSync_VGA,
      i_Red_Video => w_Red_Video_TP,
      i_Grn_Video => w_Blu_Video_TP,
      i_Blu_Video => w_Grn_Video_TP,
      --
      o_HSync     => w_HSync_Porch,
      o_VSync     => w_VSync_Porch,
      o_Red_Video => w_Red_Video_Porch,
      o_Grn_Video => w_Blu_Video_Porch,
      o_Blu_Video => w_Grn_Video_Porch
      );
     
  process is
  begin
    wait for 33600 us;
    assert false report "Test Complete" severity failure;
  end process;
    
end Behave;

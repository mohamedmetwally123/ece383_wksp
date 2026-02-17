library ieee;
use ieee.std_logic_1164.all;

entity lab2_tb is
end entity;

architecture tb of lab2_tb is
  signal clk      : std_logic := '0';
  signal reset_n  : std_logic := '0';

  signal ac_mclk      : std_logic;
  signal ac_adc_sdata : std_logic := '0';
  signal ac_dac_sdata : std_logic;
  signal ac_bclk      : std_logic;
  signal ac_lrclk     : std_logic;

  signal scl : std_logic;
  signal sda : std_logic;

  signal tmds  : std_logic_vector(3 downto 0);
  signal tmdsb : std_logic_vector(3 downto 0);

  signal switch : std_logic_vector(3 downto 0) := (others => '0');
  signal btn    : std_logic_vector(4 downto 0) := (others => '0');
  
  
 component lab2 is
     Port ( clk : in  STD_LOGIC;
            reset_n : in  STD_LOGIC;
		    ac_mclk : out STD_LOGIC;
		    ac_adc_sdata : in STD_LOGIC;
		    ac_dac_sdata : out STD_LOGIC;
		    ac_bclk : out STD_LOGIC;
		    ac_lrclk : out STD_LOGIC;
            scl : inout STD_LOGIC;
            sda : inout STD_LOGIC;
		    tmds : out  STD_LOGIC_VECTOR (3 downto 0);
            tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
		    switch: in	STD_LOGIC_VECTOR(3 downto 0);
		    btn: in	STD_LOGIC_VECTOR(4 downto 0));
 end component;
begin

  -- 100 MHz clock (10 ns period)
  clk <= not clk after 5 ns;

  -- reset pulse
  process
  begin
    reset_n <= '0';
    wait for 10 ns;
    reset_n <= '1';
    wait;
  end process;

  -- enable CH1/CH2 (optional)
  process
  begin
    wait for 20 ns;
    switch(0) <= '1';  -- ch1 enable
    switch(1) <= '1';  -- ch2 enable
    switch(2) <= '0';  -- exSel off
    switch(3) <= '0';  -- sim_live off (but your datapath already forces is_live='0')
    wait;
  end process;

  uut: lab2
    port map (
      clk => clk,
      reset_n => reset_n,
      ac_mclk => ac_mclk,
      ac_adc_sdata => ac_adc_sdata,
      ac_dac_sdata => ac_dac_sdata,
      ac_bclk => ac_bclk,
      ac_lrclk => ac_lrclk,
      scl => scl,
      sda => sda,
      tmds => tmds,
      tmdsb => tmdsb,
      switch => switch,
      btn => btn
    );

end architecture;

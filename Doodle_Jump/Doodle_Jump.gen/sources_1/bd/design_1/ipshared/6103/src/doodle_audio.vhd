----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026 11:06:41 AM
-- Design Name: 
-- Module Name: doodle_audio - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
library UNISIM;
use UNISIM.VComponents.all;
use work.graphicsParts.all;	


entity doodle_audio is
  Port (
           clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           Audio_type: in std_logic_vector (3 downto 0);
           Audio_play_request: in std_logic;
           ac_mclk : out STD_LOGIC;
           ac_adc_sdata : in STD_LOGIC;
           ac_dac_sdata : out STD_LOGIC;
           ac_bclk : out STD_LOGIC;
           ac_lrclk : out STD_LOGIC;
           scl : inout STD_LOGIC;
           sda : inout STD_LOGIC   
            );
end doodle_audio;

architecture Behavioral of doodle_audio is
    signal cw: std_logic_vector(1 downto 0);
    signal sw: std_logic_vector(2 downto 0);
    signal output_signal: std_logic_vector(17 downto 0);
    signal data_out: std_logic_vector(15 downto 0);

    
    component Audio_Codec_Wrapper 
    port ( clk : in STD_LOGIC;
        reset_n : in STD_LOGIC;
        ac_mclk : out STD_LOGIC;
        ac_adc_sdata : in STD_LOGIC;
        ac_dac_sdata : out STD_LOGIC;
        ac_bclk : out STD_LOGIC;
        ac_lrclk : out STD_LOGIC;
        ready : out STD_LOGIC;
        L_bus_in : in std_logic_vector(17 downto 0); -- left channel input to DAC
        R_bus_in : in std_logic_vector(17 downto 0); -- right channel input to DAC
        L_bus_out : out  std_logic_vector(17 downto 0); -- left channel output from ADC
        R_bus_out : out  std_logic_vector(17 downto 0); -- right channel output from ADC
        scl : inout STD_LOGIC;
        sda : inout STD_LOGIC;
        sim_live : in STD_LOGIC);   --  '0' simulate audio; '1' live audio
	end component;
begin
  sw(1) <= Audio_play_request;
  datapath: doodle_audio_datapath Port Map (
           clk => clk,
           reset_n => reset_n,
           cw      => cw,  -- control word
           sw      => sw(2 downto 2), -- status word
           Audio_type => Audio_type,
           data_out => data_out
   );
   cu: doodle_audio_cu Port Map (
        clk     => clk,
        reset_n  => reset_n,
        cw      => cw,  -- control word
        sw      => sw --    
   );
   
    -- Instantiate Audio Codec
    -- Audio Codec
    Audio_Codec : Audio_Codec_Wrapper
        port map ( clk => clk,
            reset_n => reset_n, 
            ac_mclk => ac_mclk,
            ac_adc_sdata => ac_adc_sdata,
            ac_dac_sdata => ac_dac_sdata,
            ac_bclk => ac_bclk,
            ac_lrclk => ac_lrclk,
            ready => sw(0),
            L_bus_in => output_signal, -- left channel input to DAC
            R_bus_in => output_signal, -- right channel input to DAC
            L_bus_out => OPEN, -- left channel output from ADC
            R_bus_out => OPEN, -- right channel output from ADC
            scl => scl,
            sda => sda,
            sim_live => '1');  --  '0' simulate audio; '1' live audio
        output_signal <= data_out & "00";


end Behavioral;

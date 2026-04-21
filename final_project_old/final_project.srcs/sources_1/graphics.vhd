----------------------------------------------------------------------------------
-- Name:	George York
-- Date:	Spring 2020
-- File:    graphics.vhd
-- HW:	    2D-Array Grid MEMORY example: 16 bits per grid block, 64x32 grid, for 640x480 display
-- Pupr:	need to update!!!!.  
--
-- Doc:	Adapted from Dr Coulston's Lab exercise
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
library UNISIM;
use UNISIM.VComponents.all;
use work.graphicsParts.all;		


entity graphics is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
  		   tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
           ac_mclk : out STD_LOGIC;
           ac_adc_sdata : in STD_LOGIC;
           ac_dac_sdata : out STD_LOGIC;
           ac_bclk : out STD_LOGIC;
           ac_lrclk : out STD_LOGIC;
           scl : inout STD_LOGIC;
           sda : inout STD_LOGIC          
           --flagQ: out STD_LOGIC
           --flagClear: in STD_LOGIC
           );
end graphics;

architecture behavior of graphics is
	

	signal fsmCol_sig : std_logic_vector(6 downto 0);
    signal fsmRow_sig : std_logic_vector(5 downto 0);
    signal fsmWen_sig : std_logic;
    signal fsmData_sig: std_logic_vector(15 downto 0);
	signal exSel_sig: std_logic;
    signal fsmWrAddr: std_logic_vector(4 downto 0);
    signal fsmSpriteStatus: sprite_status_t;
    signal fsmAudio_play_request_sig : std_logic;
    signal fsmAudio_type_sig: std_logic_vector (3 downto 0);
    signal cw: std_logic_vector(1 downto 0);  -- control word
    signal sw: std_logic_vector(2 downto 0); -- status word
    signal data_out: std_logic_vector(15 downto 0);
    signal output_signal: std_logic_vector(17 downto 0);
    signal exSpriteStatus : sprite_status_t := (
    row         => (others => '0'),
    col         => (others => '0'),
    sprite_type => (others => '0'),
    active      => '0'
    );
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
	component doodle_audio_cu is
        port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cw      : out std_logic_vector(1 downto 0);  -- control word
        sw      : in std_logic_vector(2 downto 0) -- status word
        );
    end component;
begin
    exSel_sig <= '0';
    
	datapath: graphics_datapath port map(
		clk => clk,
		reset_n => reset_n,
		tmds => tmds,
		tmdsb => tmdsb,
        fsmSpriteStatus => fsmSpriteStatus,
        fsmWrAddr => fsmWrAddr,
        fsmWen => fsmWen_sig,
        exWrAddr => "00000",
        exSpriteStatus => exSpriteStatus,
		exWen => '0',
		exSel => exSel_sig,
		flagQ => OPEN,
        flagClear => '0',
        exAudio_play_request => '0',
        exAudio_type => "0000", 
        fsmAudio_play_request => fsmAudio_play_request_sig,
        fsmAudio_type => fsmAudio_type_sig,
        data_out => data_out,
        cw => cw,
        sw => sw   
        );		
			  
	control: graphics_fsm port  map( 
		clk => clk,
		reset_n => reset_n,
        fsmWrAddr => fsmWrAddr,
        fsmSpriteStatus => fsmSpriteStatus,
        fsmWen => fsmWen_sig
      );
       CU: doodle_audio_cu
        port map (
            clk     => clk,
            reset_n => reset_n,
            cw      => cw,
            sw      => sw
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
end behavior;
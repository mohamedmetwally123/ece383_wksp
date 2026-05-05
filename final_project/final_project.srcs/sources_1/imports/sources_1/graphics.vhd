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
use IEEE.NUMERIC_STD.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
library UNISIM;
use UNISIM.VComponents.all;
use work.graphicsParts.all;		


entity final_project is
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
           sda : inout STD_LOGIC;
           NES_latch : out std_logic;
           NES_clk   : out std_logic;
           NES_data  : in  std_logic; 
           NES_scan  : out std_logic_vector(7 downto 0)        
           --flagQ: out STD_LOGIC
           --flagClear: in STD_LOGIC
           );
end final_project;

architecture behavior of final_project is
	
    
    signal fsmWrAddr: std_logic_vector(4 downto 0);
    signal fsmWen : std_logic;
    signal fsmSpriteStatus: sprite_status_t;
    signal fsmAudio_play_request: std_logic;
    signal fsmAudio_type: std_logic_vector (3 downto 0);

    
    signal WrAddr: std_logic_vector(4 downto 0);
    signal Wen: std_logic;
    signal spriteStatus: sprite_status_t;
    signal Audio_play_request: std_logic;
    signal Audio_type: std_logic_vector(3 downto 0);
    
    signal exSel: std_logic;
    signal exWrAddr: std_logic_vector(4 downto 0):= "00000";
    signal exWen: std_logic:= '0';
    signal exSpriteStatus : sprite_status_t := (
    row         => (others => '0'),
    col         => (others => '0'),
    sprite_type => (others => '0'),
    active      => '0'
    );
    signal exAudioPlayRequest: std_logic:= '0';
    signal exAudio_type: std_logic_vector(3 downto 0):= "0000";
    signal score_sig: unsigned(16 downto 0);

begin
    exSel <= '0';
    WrAddr <= exWrAddr when exSel = '1' else fsmWrAddr;
    Wen <= exWen when exSel = '1' else fsmWen;
    spriteStatus <= exSpriteStatus when exSel = '1' else fsmSpriteStatus;
    Audio_play_request <= exAudioPlayRequest when exSel = '1' else fsmAudio_play_request;
    Audio_type <= exAudio_type when exSel = '1' else fsmAudio_type;
    -- for now but this needs to be changed when we have external stuff
	datapath: graphics_datapath port map(
		clk => clk,
		reset_n => reset_n,
		tmds => tmds,
		tmdsb => tmdsb,
        WrAddr => WrAddr,
        Wen => Wen,
        spriteStatus => spriteStatus,
		flagQ => OPEN,
        flagClear => '0', 
        score => score_sig
        );		
			  
	control: graphics_fsm port  map( 
		clk => clk,
		reset_n => reset_n,
        fsmWrAddr => fsmWrAddr,
        fsmWen => fsmWen,
        fsmSpriteStatus => fsmSpriteStatus,
        fsmAudio_play_request => fsmAudio_play_request,
        fsmAudio_type => fsmAudio_type, 
        score=> score_sig
      );
    doodleAudio: doodle_audio Port map(
       clk => clk,
       reset_n => reset_n,
       Audio_play_request => Audio_play_request,
       Audio_type => Audio_type,
       ac_mclk => ac_mclk,
       ac_adc_sdata => ac_adc_sdata,
       ac_dac_sdata => ac_dac_sdata,
       ac_bclk => ac_bclk,
       ac_lrclk => ac_lrclk, 
       scl => scl,
       sda => sda  
        );
        
       NEScontroller: NES_Controller Port map(
        clk  => clk,
        reset_n  => reset_n,
        NES_data => NES_data,
        NES_clk => NES_clk,
        NES_latch => NES_latch,
        NES_scan => NES_scan
        );

end behavior;
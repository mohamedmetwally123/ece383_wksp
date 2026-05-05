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
use IEEE.NUMERIC_STD.ALL;

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
           NES_scan  : out std_logic_vector(7 downto 0);       
           flagQ: out STD_LOGIC;
           flagClear: in STD_LOGIC;
           exWrAddr: in std_logic_vector(4 downto 0);
           exWen: in std_logic;
           sprite_type: in std_logic_vector (4 downto 0);
           sprite_row: in unsigned(9 downto 0);
           sprite_col: in unsigned(9 downto 0);
           sprite_active: in std_logic;
           exAudioPlayRequest: in std_logic;
           exAudio_type: in std_logic_vector(3 downto 0);
           score: in unsigned(16 downto 0)
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
    signal exSpriteStatus: sprite_status_t;
    signal exSel: std_logic;


begin
    exSpriteStatus.row <= sprite_row;
    exSpriteStatus.col <= sprite_col;
    exSpriteStatus.active <= sprite_active;
    exSpriteStatus.sprite_type <= sprite_type;
    exSel <= '1';
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
		flagQ => flagQ,
        flagClear => flagClear,
        score => score
        );		
			  
	control: graphics_fsm port  map( 
		clk => clk,
		reset_n => reset_n,
        fsmWrAddr => fsmWrAddr,
        fsmWen => fsmWen,
        fsmSpriteStatus => fsmSpriteStatus,
        fsmAudio_play_request => fsmAudio_play_request,
        fsmAudio_type => fsmAudio_type
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
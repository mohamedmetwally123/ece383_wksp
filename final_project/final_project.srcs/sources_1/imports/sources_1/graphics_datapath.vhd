----------------------------------------------------------------------------------
-- Name:	George York
-- Date:	Spring 2020
-- File:    graphics_datapath.vhd
-- HW:	    2Darray MEMORY example: 2 bits per grid cell (really has 16 bits), for a 64 x 32 grid of 8x8 pixel cells
-- Pupr:	need to update!!!!.  
--
-- Doc:	Adapted from Dr Coulston's Lab exercise
-- 	
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
use work.GraphicsParts.all;		
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.


entity graphics_datapath is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);

           signal WrAddr: in std_logic_vector(4 downto 0);
           signal Wen: in std_logic;
           signal spriteStatus: in sprite_status_t;
           flagQ: out STD_LOGIC;
           flagClear: in STD_LOGIC);
end graphics_datapath;

architecture Behavioral of graphics_datapath is
	

	signal ch2 : std_logic;
	signal row, column: unsigned(9 downto 0);	

	
	signal sprite_status_array: oneDarray;
    
    signal pixel_type: sprite_status_t;
	type  TwoDarray is array(0 to 79, 0 to 59) of std_logic_vector(15 downto 0);
	signal TwoDarray_Grid : TwoDarray;
  
	signal v_synch : std_logic;
	


begin

  
    

    ----------------------------------------------------
	-- Write to the 2Darray_Grid (by FSM or Microblaze)
	-- Added stuff, write to the 1-D array
	---------------------------------------------------- 
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				--2Darray_Grid(muxCol, muxRow) <= "0000000000000000"; 
                -- add code to initialize all 64x32 grid locations here?				
			else 
				if Wen = '1' then

					sprite_status_array(to_integer(unsigned(WrAddr))) <= SpriteStatus;
				end if;
			end if;
		end if;
	end process;


    
    -------------------------------------------------------------------------------
	-- Instantiate the pixel classifer to determine what the current pixel type
	-------------------------------------------------------------------------------
	pix_classifer: pixel_classifier port map(
	   row => row,
	   col => column,
	   sprite_status_array => sprite_status_array,
	   pixel_type => pixel_type
	);
	-------------------------------------------------------------------------------
	-- Instantiate the video driver from Lab1 - should integrate smoothly
	-------------------------------------------------------------------------------
	video_inst: video port map( 
		clk =>clk,
		reset_n => reset_n,
        tmds => tmds,
		tmdsb => tmdsb,
		row => row,
		column => column,
		pixel_type => pixel_type,
		ch1_enb => '1',
		ch2 => ch2,
		ch2_enb => ch2,
		v_synch => v_synch,
	    flagQ => flagQ,
        flagClear => flagClear);



end Behavioral;


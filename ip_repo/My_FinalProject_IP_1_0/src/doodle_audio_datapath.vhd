----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026 10:58:48 AM
-- Design Name: 
-- Module Name: doodle_audio_datapath - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
use work.GraphicsParts.all;		
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.


entity doodle_audio_datapath is
  Port (
           clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           cw      : in std_logic_vector(1 downto 0);  -- control word
           sw      : out std_logic_vector(0 downto 0); -- status word
           Audio_type: in std_logic_vector (3 downto 0);
           data_out: out std_logic_vector(15 downto 0)
   );
end doodle_audio_datapath;

architecture Behavioral of doodle_audio_datapath is
	
		-- audio stuff
    signal au_sample_length: unsigned(16 downto 0);
    signal sample_index: unsigned(16 downto 0);
    
    --What actually goes into the BRAM
    alias is_playing : std_logic is cw(0);
    alias inc_address_en : std_logic is cw(1);
    

    alias sw_au_sample_done : std_logic is sw(0);

    

    --TBD
    type length_table_t is array (0 to 2) of unsigned(16 downto 0);
    constant audio_sample_length : length_table_t := (
    0 => to_unsigned(4096, 17),  -- hit platform
    1 => to_unsigned(28306, 17),  -- hit spring
    2 => to_unsigned(66978, 17)  -- game over 
    );
begin

          
    au_sample_length <= audio_sample_length(TO_INTEGER(unsigned(Audio_type))); 
    

    sw_au_sample_done <= '1' when (sample_index > au_sample_length) else '0';
        ----------------------------------------------------
	-- sample index register: gets added to the start address
	-- to determine the sample location in the BRAM
	----------------------------------------------------
    process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
                 sample_index <= (others => '0');   				
			else 
			    -- need to reset_n sample_index before playing the sound
				if is_playing = '0' then
			         sample_index <= (others => '0');   				
                elsif(is_playing = '1' and inc_address_en = '1') then
                    sample_index <= sample_index + TO_UNSIGNED(1, sample_index'length);
				end if;
			end if;
		end if;
	end process;

     -------------------------------------------------------------------------------
	-- Instantiate the read from bram to determine the current audio sample outputted to the audio codex
	-------------------------------------------------------------------------------
	read_bram: read_from_bram port map(
         clk => clk, 
         reset_n => reset_n,
         is_playing => is_playing,
         audio_type => Audio_type,
         sample_index => sample_index,
         data_out => data_out
	);



end Behavioral;

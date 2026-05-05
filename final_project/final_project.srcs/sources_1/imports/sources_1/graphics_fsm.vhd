----------------------------------------------------------------------------------
-- Name:	George York
-- Date:	Spring 2020
-- File:    graphics_fsm.vhd
-- HW:	    State Machine to test the graphics memory
--          2D_Array GRID MEMORY example: 16 bits per grid cell, for a 64 x 32 grid of 8x8 pixel cells
-- Pupr:	need to update!!!!.  
--
-- Doc:	Adapted from Dr Coulston's Lab exercise
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
use work.GraphicsParts.all;	

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity graphics_fsm is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           fsmWrAddr: out std_logic_vector(4 downto 0);
           fsmSpriteStatus: out sprite_status_t;
           fsmWen : out std_logic;
           fsmAudio_type: out std_logic_vector (3 downto 0);
           fsmAudio_play_request: out std_logic;
           score: out unsigned(16 downto 0));
end graphics_fsm;

architecture Behavioral of graphics_fsm is

	type state_type is (SWAP, DELAY, CHANGE_DATA, SET, CLEAR, INCADDR );
	signal state: state_type;
	signal writeCntr: unsigned(25 downto 0);
	--signal col : unsigned(6 downto 0);
    --signal row : unsigned(5 downto 0);
    signal WrAddr: unsigned(4 downto 0):= "11111";
	signal Data, Old_Data: std_logic_vector(15 downto 0);
	signal Wen: std_logic;
	signal score_sig: unsigned(16 downto 0):= (others => '0');
	signal audio_type: std_logic_vector (3 downto 0);
	signal audio_play_request: std_logic;
	constant LAST_COL : integer := 80;
    constant LAST_ROW : integer := 60;
    
begin
    --fsmCol <= std_logic_vector(col);
    --fsmRow <= std_logic_vector(row);
    fsmWrAddr <= std_logic_vector(WrAddr);
    --fsmData <= Data;
    fsmWen <= Wen;
    fsmAudio_type <= audio_type;
    fsmAudio_play_request <= audio_play_request;
	-------------------------------------------------------------------------------
	-- Long delay counter
	-------------------------------------------------------------------------------	
	writeCounter: process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				writeCntr <= (others => '0');  -- change for graphics memory test
			else 
			    writeCntr <= writeCntr+1;
			end if;
		end if;
	end process;
		
	state_proces: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then 
				state <= SWAP;
				--row <= "000000";
				--col <= "0000000"; 
				wrAddr <= "00000";                            
				fsmSpriteStatus.active <= '0';
				fsmSpriteStatus.row <= "0000000000";
				fsmSpriteStatus.col <= "0000000000";

				Wen <= '0';
			else 
			    -- defaults every clock
                audio_play_request <= '0';
				case state is
					when SWAP =>
						state <= DELAY;    		
					when DELAY => 
						if (writeCntr = "00000000000000000000000000") then state <= CHANGE_DATA; end if;
                    when CHANGE_DATA => 
--                             if (audio_type = "0000") then 
--                                audio_type <= "0001";
--                                audio_play_request <= '1';
--                             elsif(audio_type = "0001") then 
--                                audio_type <= "0010";
--                                audio_play_request <= '1';
--                             elsif(audio_type = "0010") then
--                                audio_type <= "0000";
--                                audio_play_request <= '1';
--                             end if;  
                                 audio_type <= "0011";
                                 audio_play_request <= '1';                          
                             -- right facing doodle
                             if (wrAddr = "00000") then 				
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(100, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(100, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "000000";
				             -- left facing doodle
				             elsif (wrAddr = "00001") then 				
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(150, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(150, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "000001";
				            -- Jetpack
                            elsif (wrAddr = "00011") then 				
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(26, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(26, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "000011";
				            elsif(wrAddr = "00010") then 
				                 fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(300, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(300, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "000010";
				            -- green platform
				             elsif (wrAddr = "01100") then 				
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(250, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(250, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "001100";
				            -- blue platform
                            elsif(wrAddr = "01101") then 
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(400, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(400, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "001101";
				            -- Play again
				             elsif(wrAddr = "001000") then 
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(300, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(500, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "001000";
				            -- play
				            elsif(wrAddr = "000111") then 
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(100, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(500, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "000111";
				            -- GAME OVER
				             elsif(wrAddr = "000110") then 
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(200, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(500, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "000110";
				             
				            --brown beam
				             elsif(wrAddr = "001110") then 
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(250, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(450, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "001110";
				             --broken beam
				             elsif(wrAddr = "011101") then 
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(260, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(450, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "011101";
				             elsif(wrAddr = "011110") then 
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(260, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(500, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "011101";
				            else 
				                fsmSpriteStatus.active <= '0';
				                fsmSpriteStatus.row <= TO_UNSIGNED(0, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(0, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "011111";

                            end if;
                            state <= SET;
                            score_sig <= score_sig + 1;
					when SET =>
						state <= CLEAR;
						Wen <= '1';
					when CLEAR =>
						state <= INCADDR;
                        Wen <= '0';
                    when INCADDR =>
						state <= Delay;
                        wrAddr <= wrAddr + 1;					

				end case;
			end if;
		end if;
	end process;

    Old_Data <= Data;
    score <= score_sig;

end Behavioral;


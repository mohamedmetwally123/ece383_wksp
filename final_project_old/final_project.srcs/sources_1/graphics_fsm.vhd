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
           fsmWen : out std_logic);
end graphics_fsm;

architecture Behavioral of graphics_fsm is

	type state_type is (SWAP, DELAY, CHANGE_DATA, SET, CLEAR, INCADDR );
	signal state: state_type;
	signal writeCntr: unsigned(17 downto 0);
	--signal col : unsigned(6 downto 0);
    --signal row : unsigned(5 downto 0);
    signal WrAddr: unsigned(4 downto 0);
	signal Data, Old_Data: std_logic_vector(15 downto 0);
	signal Wen: std_logic;
	
	constant LAST_COL : integer := 80;
    constant LAST_ROW : integer := 60;
begin
    --fsmCol <= std_logic_vector(col);
    --fsmRow <= std_logic_vector(row);
    fsmWrAddr <= std_logic_vector(WrAddr);
    --fsmData <= Data;
    fsmWen <= Wen;
	-------------------------------------------------------------------------------
	-- Long delay counter
	-------------------------------------------------------------------------------	
	writeCounter: process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				writeCntr <= "000000000000000000";  -- change for graphics memory test
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
				case state is
					when SWAP =>
						state <= DELAY;    		
					when DELAY => 
						if (writeCntr = "000000000000000000") then state <= CHANGE_DATA; end if;
                    when CHANGE_DATA => 
                            --draw a green platform
                            
                             -- right facing doodle
                             if (wrAddr = "00000") then 				
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(100, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(100, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "0010";
				             -- left facing doodle
				             elsif (wrAddr = "00001") then 				
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(150, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(150, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "0011";
				            -- blue platform
                            elsif (wrAddr = "00010") then 				
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(24, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(24, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "0100";
				            -- green platform
				             elsif (wrAddr = "00100") then 				
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(150, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(150, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "0001";
                            elsif(wrAddr = "11111") then 
                                fsmSpriteStatus.active <= '1';
				                fsmSpriteStatus.row <= TO_UNSIGNED(20, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(20, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "0000";
				            else 
				                fsmSpriteStatus.active <= '0';
				                fsmSpriteStatus.row <= TO_UNSIGNED(0, fsmSpriteStatus.row'length);
				                fsmSpriteStatus.col <= TO_UNSIGNED(0, fsmSpriteStatus.col'length);
				                fsmSpriteStatus.sprite_type <= "1011";

                            end if;
                            state <= SET;
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


end Behavioral;


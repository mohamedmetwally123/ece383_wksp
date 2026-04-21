----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2026 01:25:50 PM
-- Design Name: 
-- Module Name: pixel_classifier - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pixel_classifier is
    Port (row: in unsigned(9 downto 0);
          col: in unsigned(9 downto 0);
          sprite_status_array: in oneDarray;
          pixel_type: out sprite_status_t
          );
end pixel_classifier;
         
architecture Behavioral of pixel_classifier is
    -- add more
  
begin
    --Assume for now that the doodle is stored at the first position, 5 positions for the platforms, and one position for 
    -- the background, which is assumed to be the last position in the array

pixel_type <= 
         -- draw right facing doodle
         sprite_status_array(0) when sprite_status_array(0).active = '1' and
         row >= sprite_status_array(0).row and
         row <= sprite_status_array(0).row + to_unsigned(doodle_height, row'length) and
         col >= sprite_status_array(0).col and
         col <=  sprite_status_array(0).col + to_unsigned(doodle_width, col'length) and
         doodle_sym_to_pix(doodle_right(to_integer(row - sprite_status_array(0).row)) (to_integer(col - sprite_status_array(0).col))) /= doodle_BG 
         
    else
    --draw left facing doodle
    sprite_status_array(1) 
    when sprite_status_array(1).active = '1' and
         row >= sprite_status_array(1).row and
         row <= sprite_status_array(1).row + to_unsigned(doodle_height, row'length) and
         col >= sprite_status_array(1).col and
         col <=  sprite_status_array(1).col + to_unsigned(doodle_width, col'length) and 
        doodle_sym_to_pix(doodle_right(to_integer(row - sprite_status_array(1).row)) (to_integer(TO_UNSIGNED(doodle_width, col'length) - (col - sprite_status_array(1).col)))) /= doodle_BG

    else 
    -- draw blue platform
    sprite_status_array(2)
    when sprite_status_array(2).active = '1' and
         row >= sprite_status_array(2).row and
         row <= sprite_status_array(2).row + to_unsigned(platform_height, row'length) and
         col >= sprite_status_array(2).col and
         col <=  sprite_status_array(2).col + to_unsigned(platform_width, col'length)
    else
    -- draw blue platform
    sprite_status_array(3)
    when sprite_status_array(3).active = '1' and
         row >= sprite_status_array(3).row and
         row <=  sprite_status_array(3).row + to_unsigned(platform_height, row'length) and
         col >= sprite_status_array(3).col and
         col <=  sprite_status_array(3).col + to_unsigned(platform_width, col'length)
    else

    --draw green platform
    sprite_status_array(4)
    when sprite_status_array(4).active = '1' and
         row >= sprite_status_array(4).row and
         row <=  sprite_status_array(4).row + to_unsigned(platform_height, row'length) and
         col >= sprite_status_array(4).col and
         col <=  sprite_status_array(4).col + to_unsigned(platform_width, col'length)
    else
    --draw green platform
    sprite_status_array(5)
    when sprite_status_array(5).active = '1' and
         row >= sprite_status_array(5).row and
         row <=  sprite_status_array(5).row + to_unsigned(platform_height, row'length) and
         col >= sprite_status_array(5).col and
         col <=  sprite_status_array(5).col + to_unsigned(platform_width, col'length)
    else

    sprite_status_array(6)
    when sprite_status_array(6).active = '1' and
         row >= sprite_status_array(6).row and
         row <=  sprite_status_array(6).row + to_unsigned(platform_height, row'length) and
         col >= sprite_status_array(6).col and
         col <=  sprite_status_array(6).col + to_unsigned(platform_width, col'length)
    else

    sprite_status_array(31);                                                       
end Behavioral;

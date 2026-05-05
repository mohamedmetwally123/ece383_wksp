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
    -- draw jetpack with doodle
    sprite_status_array(2) 
    when sprite_status_array(2).active = '1' and
         row >= sprite_status_array(2).row and
         row <= sprite_status_array(2).row + to_unsigned(JETPACK_AND_DOODLE_HEIGHT, row'length) and
         col >= sprite_status_array(2).col and
         col <=  sprite_status_array(2).col + to_unsigned(JETPACK_AND_DOODLE_WIDTH, col'length) and 
         jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - sprite_status_array(2).row)) (to_integer(col - sprite_status_array(2).col))) /= doodle_BG_jd 


    
    else
    -- draw a jetpack
    sprite_status_array(3)
    when sprite_status_array(3).active = '1' and
         row >= sprite_status_array(3).row and
         row <=  sprite_status_array(3).row + to_unsigned(JETPACK_HEIGHT, row'length) and
         col >= sprite_status_array(3).col and
         col <=  sprite_status_array(3).col + to_unsigned(JETPACK_WIDTH, col'length)
and jetpack_sym_to_pix(
    jetpack(to_integer(row - sprite_status_array(3).row))
    (to_integer(col - sprite_status_array(3).col))) /= jetpack_BG    else
    
    --game over
     sprite_status_array(6)
    when sprite_status_array(6).active = '1' and
         row >= sprite_status_array(6).row and
         row <=  sprite_status_array(6).row + to_unsigned(GAME_OVER_HEIGHT, row'length) and
         col >= sprite_status_array(6).col and
         col <=  sprite_status_array(6).col + to_unsigned(GAME_OVER_WIDTH, col'length)
and game_over_sym_to_pix(
    game_over_sprite(to_integer(row - sprite_status_array(6).row))
    (to_integer(col - sprite_status_array(6).col))) /= GAME_OVER_BK 
     else 
    --play
     sprite_status_array(7)
    when sprite_status_array(7).active = '1' and
         row >= sprite_status_array(7).row and
         row <=  sprite_status_array(7).row + to_unsigned(PLAY_HEIGHT, row'length) and
         col >= sprite_status_array(7).col and
         col <=  sprite_status_array(7).col + to_unsigned(PLAY_WIDTH, col'length)
         and play_again_sym_to_pixel(
    play_sprite(to_integer(row - sprite_status_array(7).row))
    (to_integer(col - sprite_status_array(7).col))) /= TEXT_BG
     else 
    --play again
        sprite_status_array(8)
    when sprite_status_array(8).active = '1' and
         row >= sprite_status_array(8).row and
         row <=  sprite_status_array(8).row + to_unsigned(PLAYAGAIN_HEIGHT, row'length) and
         col >= sprite_status_array(8).col and
         col <=  sprite_status_array(8).col + to_unsigned(PLAYAGAIN_WIDTH, col'length)
and play_again_sym_to_pixel(
    play_again_sprite(to_integer(row - sprite_status_array(8).row))
    (to_integer(col - sprite_status_array(8).col))) /= TEXT_BG
    
    else
    
        -- green platform slot 9
    sprite_status_array(9) when sprite_status_array(9).active = '1' and
        row >= sprite_status_array(9).row and
        row <=  sprite_status_array(9).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(9).col and
        col <=  sprite_status_array(9).col + to_unsigned(platform_width, col'length)

else
    -- green platform slot 10
    sprite_status_array(10) when sprite_status_array(10).active = '1' and
        row >= sprite_status_array(10).row and
        row <=  sprite_status_array(10).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(10).col and
        col <=  sprite_status_array(10).col + to_unsigned(platform_width, col'length)

else
        --brown beam 11
   sprite_status_array(11) when sprite_status_array(11).active = '1' and
        row >= sprite_status_array(11).row and
        row <=  sprite_status_array(11).row + to_unsigned(BROWN_BEAM_HEIGHT, row'length) and
        col >= sprite_status_array(11).col and
        col <=  sprite_status_array(11).col + to_unsigned(BROWN_BEAM_WIDTH, col'length)
        else 
    -- green platform slot 12
    sprite_status_array(12) when sprite_status_array(12).active = '1' and
        row >= sprite_status_array(12).row and
        row <=  sprite_status_array(12).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(12).col and
        col <=  sprite_status_array(12).col + to_unsigned(platform_width, col'length)

else
    -- blue platform slot 13
    sprite_status_array(13) when sprite_status_array(13).active = '1' and
        row >= sprite_status_array(13).row and
        row <=  sprite_status_array(13).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(13).col and
        col <=  sprite_status_array(13).col + to_unsigned(platform_width, col'length)
else
    -- blue platform slot 14
    sprite_status_array(14) when sprite_status_array(14).active = '1' and
        row >= sprite_status_array(14).row and
        row <=  sprite_status_array(14).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(14).col and
        col <=  sprite_status_array(14).col + to_unsigned(platform_width, col'length)
else

        
            -- green platform slot 15
    sprite_status_array(15) when sprite_status_array(15).active = '1' and
        row >= sprite_status_array(15).row and
        row <=  sprite_status_array(15).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(15).col and
        col <=  sprite_status_array(15).col + to_unsigned(platform_width, col'length)

else

    -- green platform slot 16
    sprite_status_array(16) when sprite_status_array(16).active = '1' and
        row >= sprite_status_array(16).row and
        row <=  sprite_status_array(16).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(16).col and
        col <=  sprite_status_array(16).col + to_unsigned(platform_width, col'length)

else

    --brown beam 17
   sprite_status_array(17) when sprite_status_array(17).active = '1' and
        row >= sprite_status_array(17).row and
        row <=  sprite_status_array(17).row + to_unsigned(BROWN_BEAM_HEIGHT, row'length) and
        col >= sprite_status_array(17).col and
        col <=  sprite_status_array(17).col + to_unsigned(BROWN_BEAM_WIDTH, col'length)
        else 

    -- green platform slot 18
    sprite_status_array(12) when sprite_status_array(18).active = '1' and
        row >= sprite_status_array(18).row and
        row <=  sprite_status_array(18).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(18).col and
        col <=  sprite_status_array(18).col + to_unsigned(platform_width, col'length)

else

    -- green platform slot 19
    sprite_status_array(19) when sprite_status_array(19).active = '1' and
        row >= sprite_status_array(19).row and
        row <=  sprite_status_array(19).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(19).col and
        col <=  sprite_status_array(19).col + to_unsigned(platform_width, col'length)

else

    -- blue platform slot 20
    sprite_status_array(20) when sprite_status_array(20).active = '1' and
        row >= sprite_status_array(20).row and
        row <=  sprite_status_array(20).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(20).col and
        col <=  sprite_status_array(20).col + to_unsigned(platform_width, col'length)
else
    -- green platform slot 21
    sprite_status_array(21) when sprite_status_array(21).active = '1' and
        row >= sprite_status_array(21).row and
        row <=  sprite_status_array(21).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(21).col and
        col <=  sprite_status_array(21).col + to_unsigned(platform_width, col'length)

else

    -- green platform slot 22
    sprite_status_array(22) when sprite_status_array(22).active = '1' and
        row >= sprite_status_array(22).row and
        row <=  sprite_status_array(22).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(22).col and
        col <=  sprite_status_array(22).col + to_unsigned(platform_width, col'length)



else
    --brown beam 23
   sprite_status_array(23) when sprite_status_array(23).active = '1' and
        row >= sprite_status_array(23).row and
        row <=  sprite_status_array(23).row + to_unsigned(BROWN_BEAM_HEIGHT, row'length) and
        col >= sprite_status_array(23).col and
        col <=  sprite_status_array(23).col + to_unsigned(BROWN_BEAM_WIDTH, col'length)
        else 
    -- blue platform slot 24
    sprite_status_array(24) when sprite_status_array(24).active = '1' and
        row >= sprite_status_array(24).row and
        row <=  sprite_status_array(24).row + to_unsigned(platform_height, row'length) and
        col >= sprite_status_array(24).col and
        col <=  sprite_status_array(24).col + to_unsigned(platform_width, col'length)
else
 --broken brown beam 25
   sprite_status_array(25) when sprite_status_array(25).active = '1' and
        row >= sprite_status_array(25).row and
        row <=  sprite_status_array(25).row + to_unsigned(BROKEN_BROWN_BEAM_HEIGHT, row'length) and
        col >= sprite_status_array(25).col and
        col <=  sprite_status_array(25).col + to_unsigned(BROKEN_BROWN_BEAM_WIDTH, col'length)
        else
        
         --broken brown beam 26
   sprite_status_array(26) when sprite_status_array(26).active = '1' and
        row >= sprite_status_array(26).row and
        row <=  sprite_status_array(26).row + to_unsigned(BROKEN_BROWN_BEAM_HEIGHT, row'length) and
        col >= sprite_status_array(26).col and
        col <=  sprite_status_array(26).col + to_unsigned(BROKEN_BROWN_BEAM_WIDTH, col'length)
        else
        
         --broken brown beam 27
   sprite_status_array(27) when sprite_status_array(27).active = '1' and
        row >= sprite_status_array(27).row and
        row <=  sprite_status_array(27).row + to_unsigned(BROKEN_BROWN_BEAM_HEIGHT, row'length) and
        col >= sprite_status_array(27).col and
        col <=  sprite_status_array(27).col + to_unsigned(BROKEN_BROWN_BEAM_WIDTH, col'length)
        else
        
         --broken brown beam 28
   sprite_status_array(28) when sprite_status_array(28).active = '1' and
        row >= sprite_status_array(28).row and
        row <=  sprite_status_array(28).row + to_unsigned(BROKEN_BROWN_BEAM_HEIGHT, row'length) and
        col >= sprite_status_array(28).col and
        col <=  sprite_status_array(28).col + to_unsigned(BROKEN_BROWN_BEAM_WIDTH, col'length)
        else
 
   --broken brown beam 29
   sprite_status_array(29) when sprite_status_array(29).active = '1' and
        row >= sprite_status_array(29).row and
        row <=  sprite_status_array(29).row + to_unsigned(BROKEN_BROWN_BEAM_HEIGHT, row'length) and
        col >= sprite_status_array(29).col and
        col <=  sprite_status_array(29).col + to_unsigned(BROKEN_BROWN_BEAM_WIDTH, col'length)
        else
    --broken brown beam
     sprite_status_array(30) when sprite_status_array(30).active = '1' and
        row >= sprite_status_array(30).row and
        row <=  sprite_status_array(30).row + to_unsigned(BROKEN_BROWN_BEAM_HEIGHT, row'length) and
        col >= sprite_status_array(30).col and
        col <=  sprite_status_array(30).col + to_unsigned(BROKEN_BROWN_BEAM_WIDTH, col'length)
    else 
    sprite_status_array(31);                                                       
end Behavioral;

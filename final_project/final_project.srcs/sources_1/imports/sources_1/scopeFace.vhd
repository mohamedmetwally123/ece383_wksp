----------------------------------------------------------------------------------
-- Name:	George York
-- Date:	Spring 2020
-- File: scopeFace.vhd
-- HW:	Lab 1 
-- Pupr:	Scope Face component entity description for Lab 1.  This component sweeps
--			acrossthe display from full to full, and then return to the full side of 
--			the next lower row. The VGA interface determines the color of each pixel
--			on this journey with the help of the scopeFace component.
-- Doc:	Adapted from Dr Coulston's Lab exercise
-- 	


--		Total scope display is 640x480

--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

use work.GraphicsParts.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scopeFace is
    Port ( row : in  unsigned (9 downto 0);
           column : in  unsigned (9 downto 0);
           r : out  std_logic_vector(7 downto 0);
           g : out  std_logic_vector(7 downto 0);
           b : out  std_logic_vector(7 downto 0);
		   pixel_type : in   sprite_status_t;
           ch1_enb : in  STD_LOGIC;
           ch2 : in  STD_LOGIC;
           ch2_enb : in  STD_LOGIC);
end scopeFace;

architecture Behavioral of scopeFace is
    signal graphics_on, BK_paper_pixel, BK_grid_pixel, greenPlatform_OUTLINE_pixel, greenPlatform_GREEN_pixel, greenPlatform_LIGHT_pixel,  greenPlatform_pixel, 
    doodle_outline_pixel, doodle_body_pixel, doodle_light_pixel, doodle_stripe_pixel, bluePlatform_OUTLINE_pixel, bluePlatform_GREEN_pixel,
     bluePlatform_LIGHT_pixel: std_logic;
    
    signal r_BK_paper, g_BK_paper, b_BK_paper, r_BK_grid, g_BK_grid, b_BK_grid, 
    r_greenPlatform_outline, g_greenPlatform_outline, b_greenPlatform_outline, r_greenPlatform_green, g_greenPlatform_green, b_greenPlatform_green, r_greenPlatform_light, g_greenPlatform_light, b_greenPlatform_light, r_greenPlatform, g_greenPlatform, b_greenPlatform, 
    r_doodle_outline, g_doodle_outline, b_doodle_outline, r_doodle_body,    g_doodle_body,    b_doodle_body, r_doodle_light,   g_doodle_light,   b_doodle_light,
    r_doodle_stripe, g_doodle_stripe, b_doodle_stripe, r_bluePlatform_outline, g_bluePlatform_outline,
    b_bluePlatform_outline, r_bluePlatform_blue, g_bluePlatform_blue, b_bluePlatform_blue,
    r_bluePlatform_light, g_bluePlatform_light, b_bluePlatform_light, r_bluePlatform_dark, g_bluePlatform_dark,
    b_bluePlatform_dark  : std_logic_vector(7 downto 0);

 





	
begin


-- color map for each object
--object 1 is the background
r_BK_paper <= "11110101"; -- 245
g_BK_paper <= "11101011"; -- 235
b_BK_paper <= "11010010"; -- 210

r_BK_grid  <= "11011100"; -- 220
g_BK_grid  <= "11010010"; -- 210
b_BK_grid  <= "10111001"; -- 185

r_greenPlatform_outline <= "01010000"; -- ~80
g_greenPlatform_outline <= "01010000";
b_greenPlatform_outline <= "01010000";

r_greenPlatform_green <= "01010110"; -- ~86
g_greenPlatform_green <= "11011100"; -- ~220
b_greenPlatform_green <= "01000110"; -- ~70

r_greenPlatform_light <= "10011100"; -- ~156
g_greenPlatform_light <= "11111111"; -- 255
b_greenPlatform_light <= "10010000"; -- ~144


r_greenPlatform <= "11111111";
g_greenPlatform <= "00000000";
b_greenPlatform <= "11111111"; 

r_doodle_outline <= "00100000"; -- ~32
g_doodle_outline <= "00100000"; -- ~32
b_doodle_outline <= "00100000"; -- ~32

r_doodle_body <= "11011000"; -- ~216
g_doodle_body <= "11100000"; -- ~224
b_doodle_body <= "00110000"; -- ~48

r_doodle_light <= "11110000"; -- ~240
g_doodle_light <= "11111000"; -- ~248
b_doodle_light <= "01110000"; -- ~112

r_doodle_stripe <= "01100000"; -- ~96
g_doodle_stripe <= "11000000"; -- ~192
b_doodle_stripe <= "01010000"; -- ~80

r_bluePlatform_outline <= "00100000";
g_bluePlatform_outline <= "00100000";
b_bluePlatform_outline <= "00100000";

r_bluePlatform_blue <= "00100000";
g_bluePlatform_blue <= "10000000";
b_bluePlatform_blue <= "11110000";

r_bluePlatform_light <= "01000000";
g_bluePlatform_light <= "10100000";
b_bluePlatform_light <= "11111000";

r_bluePlatform_dark <= "00010000";
g_bluePlatform_dark <= "01100000";
b_bluePlatform_dark <= "11000000";

--sprite type so far
-- BK -> 0000
-- green platform -> 01
-- doodle facring right -> 10
-- doodle facing left -> 11 
-- blue platform -> 100
graphics_on <= '1' when (column < 640) and (row < 480) else '0';

r <= r_doodle_outline when ((graphics_on = '1') and (doodle_outline_pixel = '1')) else
     r_doodle_body when ((graphics_on = '1') and (doodle_body_pixel = '1')) else
     r_doodle_light when ((graphics_on = '1') and (doodle_light_pixel = '1')) else
     r_doodle_stripe when ((graphics_on = '1') and (doodle_stripe_pixel = '1')) else

     r_greenPlatform_outline when ((graphics_on = '1') and (greenPlatform_OUTLINE_pixel = '1')) else
     r_greenPlatform_green when ((graphics_on = '1') and (greenPlatform_GREEN_pixel = '1')) else
     r_greenPlatform_light when ((graphics_on = '1') and (greenPlatform_LIGHT_pixel = '1')) else
     
     r_bluePlatform_outline when ((graphics_on = '1') and (bluePlatform_OUTLINE_pixel = '1')) else
     r_bluePlatform_BLUE when ((graphics_on = '1') and (bluePlatform_GREEN_pixel = '1')) else
     r_bluePlatform_light when ((graphics_on = '1') and (bluePlatform_LIGHT_pixel = '1')) else
     
     r_BK_grid when ((graphics_on = '1') and (BK_grid_pixel = '1')) else
     r_BK_paper when ((graphics_on = '1') and (BK_paper_pixel = '1')) else
     "00000000";
g <= g_doodle_outline when ((graphics_on = '1') and (doodle_outline_pixel = '1')) else
     g_doodle_body when ((graphics_on = '1') and (doodle_body_pixel = '1')) else
     g_doodle_light when ((graphics_on = '1') and (doodle_light_pixel = '1')) else
     g_doodle_stripe when ((graphics_on = '1') and (doodle_stripe_pixel = '1')) else

     g_greenPlatform_outline when ((graphics_on = '1') and (greenPlatform_OUTLINE_pixel = '1')) else
     g_greenPlatform_green when ((graphics_on = '1') and (greenPlatform_GREEN_pixel = '1')) else
     g_greenPlatform_light when ((graphics_on = '1') and (greenPlatform_LIGHT_pixel = '1')) else
     
     g_bluePlatform_outline when ((graphics_on = '1') and (bluePlatform_OUTLINE_pixel = '1')) else
     g_bluePlatform_BLUE when ((graphics_on = '1') and (bluePlatform_GREEN_pixel = '1')) else
     g_bluePlatform_light when ((graphics_on = '1') and (bluePlatform_LIGHT_pixel = '1')) else
     
     g_BK_grid when ((graphics_on = '1') and (BK_grid_pixel = '1')) else
     g_BK_paper when ((graphics_on = '1') and (BK_paper_pixel = '1')) else

     g_greenPlatform when ((graphics_on = '1') and (greenPlatform_pixel = '1')) else
     "00000000";
b <= b_doodle_outline when ((graphics_on = '1') and (doodle_outline_pixel = '1')) else
     b_doodle_body when ((graphics_on = '1') and (doodle_body_pixel = '1')) else
     b_doodle_light when ((graphics_on = '1') and (doodle_light_pixel = '1')) else
     b_doodle_stripe when ((graphics_on = '1') and (doodle_stripe_pixel = '1')) else

     b_BK_grid when ((graphics_on = '1') and (BK_grid_pixel = '1')) else
     b_BK_paper when ((graphics_on = '1') and (BK_paper_pixel = '1')) else
     b_greenPlatform_outline when ((graphics_on = '1') and (greenPlatform_OUTLINE_pixel = '1')) else
     b_greenPlatform_green when ((graphics_on = '1') and (greenPlatform_GREEN_pixel = '1')) else
     b_greenPlatform_light when ((graphics_on = '1') and (greenPlatform_LIGHT_pixel = '1')) else
     
     b_bluePlatform_outline when ((graphics_on = '1') and (bluePlatform_OUTLINE_pixel = '1')) else
     b_bluePlatform_BLUE when ((graphics_on = '1') and (bluePlatform_GREEN_pixel = '1')) else
     b_bluePlatform_light when ((graphics_on = '1') and (bluePlatform_LIGHT_pixel = '1')) else
     --ignore this one
     b_greenPlatform when ((graphics_on = '1') and (greenPlatform_pixel = '1')) else
     "00001100";

-- draw object shapes 
-- make object1 the background
BK_paper_pixel <= '1' when 
                            (
                                (pixel_type.sprite_type = "0000") 
                                 or (pixel_type.sprite_type = "0001" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_BG) 
                                 or  (pixel_type.sprite_type = "0100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_BG)   
                                 or (pixel_type.sprite_type = "0011" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_BG) or 
                                 (pixel_type.sprite_type = "0010" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_BG)
                             
                             )
                                and (row (2 downto 0) /= "000" and column(2 downto 0) /= "000")

                         else '0';
BK_grid_pixel  <= '1' when   
                            (
                                (pixel_type.sprite_type = "0000") 
                                 or (pixel_type.sprite_type = "0001" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_BG) 
                                 or  (pixel_type.sprite_type = "0100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_BG)   
                                 or (pixel_type.sprite_type = "0011" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_BG) or 
                                 (pixel_type.sprite_type = "0010" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_BG)
                                    
                            )
                                and (row (2 downto 0) = "000" or column(2 downto 0) = "000")

                         else '0';

--object2: the green platform
greenPlatform_OUTLINE_pixel <= '1' when ((pixel_type.sprite_type = "0001" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_OUTLINE)) else '0';

greenPlatform_GREEN_pixel <= '1' when (pixel_type.sprite_type = "0001" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_GREEN) else '0';

greenPlatform_LIGHT_pixel <= '1' when (pixel_type.sprite_type = "0001" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_LIGHT) else '0';

doodle_LIGHT_pixel <= '1' when (pixel_type.sprite_type = "0011" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_LIGHT) or (pixel_type.sprite_type = "0010" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row))(to_integer(column - pixel_type.col))) = doodle_LIGHT) else '0';
doodle_BODY_pixel <= '1' when (pixel_type.sprite_type = "0011" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_BODY) or (pixel_type.sprite_type = "0010" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_BODY) else '0';
doodle_OUTLINE_pixel <= '1' when (pixel_type.sprite_type = "0011" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_OUTLINE) or (pixel_type.sprite_type = "0010" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_OUTLINE) else '0';
doodle_stripe_pixel <= '1' when (pixel_type.sprite_type = "0011" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_stripe) or (pixel_type.sprite_type = "0010" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_stripe) else '0';

bluePlatform_OUTLINE_pixel <= '1' when ((pixel_type.sprite_type = "0100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_OUTLINE)) else '0';

bluePlatform_GREEN_pixel <= '1' when (pixel_type.sprite_type = "0100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_BLUE) else '0';

bluePlatform_LIGHT_pixel <= '1' when (pixel_type.sprite_type = "0100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_LIGHT) else '0';


end Behavioral;


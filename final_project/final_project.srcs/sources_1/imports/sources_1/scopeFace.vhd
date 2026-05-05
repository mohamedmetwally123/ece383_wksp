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
    Port ( clk: in std_logic;
    row : in  unsigned (9 downto 0);
           column : in  unsigned (9 downto 0);
           r : out  std_logic_vector(7 downto 0);
           g : out  std_logic_vector(7 downto 0);
           b : out  std_logic_vector(7 downto 0);
		   pixel_type : in   sprite_status_t;
           ch1_enb : in  STD_LOGIC;
           ch2 : in  STD_LOGIC;
           ch2_enb : in  STD_LOGIC;
           score: in unsigned(16 downto 0));
end scopeFace;

architecture Behavioral of scopeFace is
    signal graphics_on, BK_paper_pixel, BK_grid_pixel, greenPlatform_OUTLINE_pixel, greenPlatform_GREEN_pixel, greenPlatform_LIGHT_pixel,  greenPlatform_pixel, 
    doodle_outline_pixel, doodle_body_pixel, doodle_light_pixel, doodle_stripe_pixel, bluePlatform_OUTLINE_pixel, bluePlatform_GREEN_pixel,
     bluePlatform_LIGHT_pixel: std_logic;
     
     signal digits_pixel, tens_pixel, hundreds_pixel, thousands_pixel, ten_thousands_pixel: std_logic;
     signal digit_num, tens_num, hundreds_num, thousands_num, ten_thousands_num: std_logic_vector(3 downto 0);
    
    signal r_BK_paper, g_BK_paper, b_BK_paper, r_BK_grid, g_BK_grid, b_BK_grid, 
    r_greenPlatform_outline, g_greenPlatform_outline, b_greenPlatform_outline, r_greenPlatform_green, g_greenPlatform_green, b_greenPlatform_green, r_greenPlatform_light, g_greenPlatform_light, b_greenPlatform_light, r_greenPlatform, g_greenPlatform, b_greenPlatform, 
    r_doodle_outline, g_doodle_outline, b_doodle_outline, r_doodle_body,    g_doodle_body,    b_doodle_body, r_doodle_light,   g_doodle_light,   b_doodle_light,
    r_doodle_stripe, g_doodle_stripe, b_doodle_stripe, r_bluePlatform_outline, g_bluePlatform_outline,
    b_bluePlatform_outline, r_bluePlatform_blue, g_bluePlatform_blue, b_bluePlatform_blue,
    r_bluePlatform_light, g_bluePlatform_light, b_bluePlatform_light, r_bluePlatform_dark, g_bluePlatform_dark,
    b_bluePlatform_dark  : std_logic_vector(7 downto 0);

    --added stuff
    signal jetpack_outline_pixel,
    jetpack_body_pixel,
    jetpack_yellow_pixel,
    jetpack_stripe_pixel,
    jetpack_darkblue_pixel,
    jetpack_brown_pixel : std_logic;
    signal r_jetpack_outline, g_jetpack_outline, b_jetpack_outline,
r_jetpack_body, g_jetpack_body, b_jetpack_body,
r_jetpack_yellow, g_jetpack_yellow, b_jetpack_yellow,
r_jetpack_stripe, g_jetpack_stripe, b_jetpack_stripe,
r_jetpack_darkblue, g_jetpack_darkblue, b_jetpack_darkblue,
r_jetpack_brown, g_jetpack_brown, b_jetpack_brown : std_logic_vector(7 downto 0);

signal r_brown_beam_outline, g_brown_beam_outline, b_brown_beam_outline : std_logic_vector(7 downto 0);
signal r_brown_beam_body,    g_brown_beam_body,    b_brown_beam_body    : std_logic_vector(7 downto 0);
signal r_brown_beam_light,   g_brown_beam_light,   b_brown_beam_light   : std_logic_vector(7 downto 0);

signal r_text_outline, g_text_outline, b_text_outline, r_text_shadow, g_text_shadow, b_text_shadow: std_logic_vector(7 downto 0);
signal text_outline_pixel, text_shadow_pixel: std_logic;
signal game_over_letters_pixel: std_logic;

signal r_flame_red,    g_flame_red,    b_flame_red    : std_logic_vector(7 downto 0);
signal r_flame_orange, g_flame_orange, b_flame_orange : std_logic_vector(7 downto 0);
signal r_game_over_letters, b_game_over_letters, g_game_over_letters: std_logic_vector(7 downto 0); 
signal flame_red_pixel    : std_logic;
signal flame_orange_pixel : std_logic;

signal brown_beam_outline_pixel : std_logic;
signal brown_beam_body_pixel    : std_logic;
signal brown_beam_light_pixel   : std_logic;

signal pixel: std_logic_vector(3 downto 0);
signal row_address_digits, row_address_tens, row_address_hundreds, row_address_thousands, row_address_ten_thousands: unsigned(3 downto 0);
signal col_address_digits, col_address_tens, col_address_hundreds, col_address_thousands, col_address_ten_thousands: unsigned(3 downto 0);
signal pixel_digits_out, pixel_tens_out, pixel_hundreds_out, pixel_thousands_out, pixel_ten_thousands_out: std_logic_vector(3 downto 0); 
signal r_blue_margin, g_blue_margin, b_blue_margin: std_logic_vector(7 downto 0);
signal margin_pixel: std_logic;
component doodle_digits is
    port (
        clk      : in  std_logic;
        en       : in  std_logic;
        row_addr : in  unsigned(3 downto 0);  -- 0 to 15
        col_addr : in  unsigned(3 downto 0);  -- 0 to 15
        digit    : in  std_logic_vector(3 downto 0);  -- 4 bit digit (0 through 9) to display.  Defaults to 0 for A through F.
        pixel    : out std_logic_vector(3 downto 0)   -- 4 bit output (0-F)  Default color palette is grayscale where 0 = Black, E = white, and F = transparent
    );
end component;

	
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

--added stuff
r_jetpack_outline <= "00100000";
g_jetpack_outline <= "00100000";
b_jetpack_outline <= "00100000";

r_jetpack_body <= "10110000";
g_jetpack_body <= "11010000";
b_jetpack_body <= "11011000";

r_jetpack_yellow <= "11110000";
g_jetpack_yellow <= "11010000";
b_jetpack_yellow <= "00100000";

r_jetpack_stripe <= "11000000";
g_jetpack_stripe <= "11001000";
b_jetpack_stripe <= "11001000";

r_jetpack_darkblue <= "00010000";
g_jetpack_darkblue <= "01100000";
b_jetpack_darkblue <= "10000000";

r_jetpack_brown <= "01100000";
g_jetpack_brown <= "00110000";
b_jetpack_brown <= "00010000";

r_flame_red <= "11000000";     -- 192
g_flame_red <= "00000000";     -- 0
b_flame_red <= "00000000";     -- 0

r_flame_orange <= "11111111";  -- 255
g_flame_orange <= "01100000";  -- 96
b_flame_orange <= "00000000";  -- 0

-- play again button colors

r_text_outline <= "00100000"; -- ~32
g_text_outline <= "00100000"; -- ~32
b_text_outline <= "00100000"; -- ~32

r_text_shadow <= "11001000"; -- ~200
g_text_shadow <= "10011100"; -- ~156
b_text_shadow <= "01001100"; -- ~76

r_game_over_letters <= "10100000"; -- 160
g_game_over_letters <= "00011001"; -- 25
b_game_over_letters <= "00011001"; -- 25

r_brown_beam_outline <= "00101000"; -- 40
g_brown_beam_outline <= "00011001"; -- 25
b_brown_beam_outline <= "00001111"; -- 15

r_brown_beam_body <= "10010110"; -- 150
g_brown_beam_body <= "01010000"; -- 80
b_brown_beam_body <= "00101000"; -- 40

r_brown_beam_light <= "11010010"; -- 210
g_brown_beam_light <= "10010110"; -- 150
b_brown_beam_light <= "01011010"; -- 90

r_blue_margin <= "01100000"; -- 96
g_blue_margin <= "01101000"; -- 104
b_blue_margin <= "01110000"; -- 112

--sprite type so far
-- right doodle 0
-- left doodle 1
-- doodle with a jetpack 2
-- jetpack 3
-- spring contracted 4
-- spring expanded 5
-- game over 6
-- play 7
-- play again 8
-- score: 9
--score 10
-- monster 11
--green beam 12
-- blue beam 13
-- brown bream 14
-- green platform 15
-- broken beam 29
-- broken beam 29(but exist in array 30)
-- BK 31

margin_pixel <= '1' when (column >= 0 and column <= 639) and (row >= 0 and row <= 60) else '0';
digit_num         <= std_logic_vector(to_unsigned((to_integer(score)/ 1)mod 10, 4));
tens_num          <= std_logic_vector(to_unsigned((to_integer(score)/ 10) mod 10, 4));
hundreds_num      <= std_logic_vector(to_unsigned((to_integer(score)/ 100) mod 10, 4));
thousands_num     <= std_logic_vector(to_unsigned((to_integer(score)/ 1000) mod 10, 4));
ten_thousands_num <= std_logic_vector(to_unsigned((to_integer(score)/ 10000) mod 10, 4));

ten_thousands_pixel <= '1' when (column >= 16 and column <= 31) and (row >= 40 and row <= 55) else '0';
thousands_pixel <= '1' when (column >= 32 and column <= 47) and (row >= 40 and row <= 55) else '0';
hundreds_pixel <= '1' when (column >= 48 and column <= 63) and (row >= 40 and row <= 55) else '0';
tens_pixel <= '1' when (column >= 64 and column <= 79) and (row >= 40 and row <= 55) else '0';
digits_pixel <= '1' when (column >= 80 and column <= 95) and (row >= 40 and row <= 55) else '0';

row_address_digits <= resize(row - 40, 4);
row_address_tens <= resize(row - 40, 4);
row_address_hundreds <= resize(row - 40, 4);
row_address_thousands <= resize(row - 40, 4);
row_address_ten_thousands <= resize(row - 40, 4);

col_address_digits <= resize(column - 80, 4);
col_address_tens <= resize(column - 64, 4);
col_address_hundreds <= resize(column - 48, 4);
col_address_thousands <= resize(column - 32, 4);
col_address_ten_thousands <= resize(column - 16, 4);


doodleDigits: doodle_digits port map
(
    clk => clk,
    en  => digits_pixel,
    row_addr => row_address_digits,
    col_addr => col_address_digits,
    digit    => digit_num,
    pixel   => pixel_digits_out
);

doodletens: doodle_digits port map
(
    clk => clk,
    en  => tens_pixel,
    row_addr => row_address_tens,
    col_addr => col_address_tens,
    digit    => tens_num,
    pixel   => pixel_tens_out
);

doodlehundreds: doodle_digits port map
(
    clk => clk,
    en  => hundreds_pixel,
    row_addr => row_address_hundreds,
    col_addr => col_address_hundreds,
    digit    => hundreds_num,
    pixel   => pixel_hundreds_out
);

doodlethousands: doodle_digits port map
(
    clk => clk,
    en  => thousands_pixel,
    row_addr => row_address_thousands,
    col_addr => col_address_thousands,
    digit    => thousands_num,
    pixel   => pixel_thousands_out
);

doodleTenThousands: doodle_digits port map
(
    clk => clk,
    en  => ten_thousands_pixel,
    row_addr => row_address_ten_thousands,
    col_addr => col_address_ten_thousands,
    digit    => ten_thousands_num,
    pixel   => pixel_ten_thousands_out
);

graphics_on <= '1' when (column < 640) and (row < 480) else '0';

r <= (pixel_ten_thousands_out & pixel_ten_thousands_out) when ((graphics_on = '1') and (ten_thousands_pixel = '1') and (pixel_ten_thousands_out /= x"F")) else
      (pixel_thousands_out & pixel_thousands_out) when ((graphics_on = '1') and (thousands_pixel = '1') and (pixel_thousands_out /= x"F")) else
      (pixel_hundreds_out & pixel_hundreds_out) when ((graphics_on = '1') and (hundreds_pixel = '1') and (pixel_hundreds_out /= x"F")) else
      (pixel_tens_out & pixel_tens_out) when ((graphics_on = '1') and (tens_pixel = '1') and (pixel_tens_out /= x"F")) else
      (pixel_digits_out & pixel_digits_out) when ((graphics_on = '1') and (digits_pixel = '1') and (pixel_digits_out /= x"F")) else
       r_blue_margin when ((graphics_on = '1') and (margin_pixel = '1')) else 
r_doodle_outline when ((graphics_on = '1') and (doodle_outline_pixel = '1')) else
     r_doodle_body when ((graphics_on = '1') and (doodle_body_pixel = '1')) else
     r_doodle_light when ((graphics_on = '1') and (doodle_light_pixel = '1')) else
     r_doodle_stripe when ((graphics_on = '1') and (doodle_stripe_pixel = '1')) else

     r_jetpack_outline when ((graphics_on = '1') and (jetpack_outline_pixel = '1')) else
    r_jetpack_body    when ((graphics_on = '1') and (jetpack_body_pixel = '1')) else
    r_jetpack_yellow  when ((graphics_on = '1') and (jetpack_yellow_pixel = '1')) else
    r_jetpack_stripe  when ((graphics_on = '1') and (jetpack_stripe_pixel = '1')) else
    r_jetpack_darkblue when ((graphics_on = '1') and (jetpack_darkblue_pixel = '1')) else
    r_jetpack_brown   when ((graphics_on = '1') and (jetpack_brown_pixel = '1')) else
    r_flame_orange when ((graphics_on = '1') and (flame_orange_pixel = '1')) else
    r_flame_red    when ((graphics_on = '1') and (flame_red_pixel = '1')) else
    
         r_text_outline when ((graphics_on = '1') and (text_outline_pixel = '1')) else
         r_text_shadow when ((graphics_on = '1') and (text_shadow_pixel = '1')) else
         r_game_over_letters when ((graphics_on = '1') and (game_over_letters_pixel = '1')) else

    
    r_brown_beam_outline when ((graphics_on = '1') and (brown_beam_outline_pixel = '1')) else
    r_brown_beam_body when ((graphics_on = '1') and (brown_beam_body_pixel = '1')) else
    r_brown_beam_light when ((graphics_on = '1') and (brown_beam_light_pixel = '1')) else

     r_greenPlatform_outline when ((graphics_on = '1') and (greenPlatform_OUTLINE_pixel = '1')) else
     r_greenPlatform_green when ((graphics_on = '1') and (greenPlatform_GREEN_pixel = '1')) else
     r_greenPlatform_light when ((graphics_on = '1') and (greenPlatform_LIGHT_pixel = '1')) else
     
     r_bluePlatform_outline when ((graphics_on = '1') and (bluePlatform_OUTLINE_pixel = '1')) else
     r_bluePlatform_BLUE when ((graphics_on = '1') and (bluePlatform_GREEN_pixel = '1')) else
     r_bluePlatform_light when ((graphics_on = '1') and (bluePlatform_LIGHT_pixel = '1')) else

     
     r_BK_grid when ((graphics_on = '1') and (BK_grid_pixel = '1')) else
     r_BK_paper when ((graphics_on = '1') and (BK_paper_pixel = '1')) else
     r_BK_paper;
g <= (pixel_ten_thousands_out & pixel_ten_thousands_out) when ((graphics_on = '1') and (ten_thousands_pixel = '1') and (pixel_ten_thousands_out /= x"F")) else
      (pixel_thousands_out & pixel_thousands_out) when ((graphics_on = '1') and (thousands_pixel = '1') and (pixel_thousands_out /= x"F")) else
      (pixel_hundreds_out & pixel_hundreds_out) when ((graphics_on = '1') and (hundreds_pixel = '1') and (pixel_hundreds_out /= x"F")) else
      (pixel_tens_out & pixel_tens_out) when ((graphics_on = '1') and (tens_pixel = '1') and (pixel_tens_out /= x"F")) else
      (pixel_digits_out & pixel_digits_out) when ((graphics_on = '1') and (digits_pixel = '1') and (pixel_digits_out /= x"F")) else
       g_blue_margin when ((graphics_on = '1') and (margin_pixel = '1')) else 

g_doodle_outline when ((graphics_on = '1') and (doodle_outline_pixel = '1')) else
     g_doodle_body when ((graphics_on = '1') and (doodle_body_pixel = '1')) else
     g_doodle_light when ((graphics_on = '1') and (doodle_light_pixel = '1')) else
     g_doodle_stripe when ((graphics_on = '1') and (doodle_stripe_pixel = '1')) else

     g_jetpack_outline when ((graphics_on = '1') and (jetpack_outline_pixel = '1')) else
    g_jetpack_body    when ((graphics_on = '1') and (jetpack_body_pixel = '1')) else
    g_jetpack_yellow  when ((graphics_on = '1') and (jetpack_yellow_pixel = '1')) else
    g_jetpack_stripe  when ((graphics_on = '1') and (jetpack_stripe_pixel = '1')) else
    g_jetpack_darkblue when ((graphics_on = '1') and (jetpack_darkblue_pixel = '1')) else
    g_jetpack_brown   when ((graphics_on = '1') and (jetpack_brown_pixel = '1')) else
     g_flame_orange when ((graphics_on = '1') and (flame_orange_pixel = '1')) else
     g_flame_red    when ((graphics_on = '1') and (flame_red_pixel = '1')) else

         g_text_outline when ((graphics_on = '1') and (text_outline_pixel = '1')) else
         g_text_shadow when ((graphics_on = '1') and (text_shadow_pixel = '1')) else
         g_game_over_letters when ((graphics_on = '1') and (game_over_letters_pixel = '1')) else

    g_brown_beam_outline when ((graphics_on = '1') and (brown_beam_outline_pixel = '1')) else
    g_brown_beam_body when ((graphics_on = '1') and (brown_beam_body_pixel = '1')) else
    g_brown_beam_light when ((graphics_on = '1') and (brown_beam_light_pixel = '1')) else
    
     g_greenPlatform_outline when ((graphics_on = '1') and (greenPlatform_OUTLINE_pixel = '1')) else
     g_greenPlatform_green when ((graphics_on = '1') and (greenPlatform_GREEN_pixel = '1')) else
     g_greenPlatform_light when ((graphics_on = '1') and (greenPlatform_LIGHT_pixel = '1')) else
     
     g_bluePlatform_outline when ((graphics_on = '1') and (bluePlatform_OUTLINE_pixel = '1')) else
     g_bluePlatform_BLUE when ((graphics_on = '1') and (bluePlatform_GREEN_pixel = '1')) else
     g_bluePlatform_light when ((graphics_on = '1') and (bluePlatform_LIGHT_pixel = '1')) else
     

     g_BK_grid when ((graphics_on = '1') and (BK_grid_pixel = '1')) else
     g_BK_paper when ((graphics_on = '1') and (BK_paper_pixel = '1')) else
     

     g_greenPlatform when ((graphics_on = '1') and (greenPlatform_pixel = '1')) else
     g_BK_paper;
b <= (pixel_ten_thousands_out & pixel_ten_thousands_out) when ((graphics_on = '1') and (ten_thousands_pixel = '1') and (pixel_ten_thousands_out /= x"F")) else
      (pixel_thousands_out & pixel_thousands_out) when ((graphics_on = '1') and (thousands_pixel = '1') and (pixel_thousands_out /= x"F")) else
      (pixel_hundreds_out & pixel_hundreds_out) when ((graphics_on = '1') and (hundreds_pixel = '1') and (pixel_hundreds_out /= x"F")) else
      (pixel_tens_out & pixel_tens_out) when ((graphics_on = '1') and (tens_pixel = '1') and (pixel_tens_out /= x"F")) else
      (pixel_digits_out & pixel_digits_out) when ((graphics_on = '1') and (digits_pixel = '1') and (pixel_digits_out /= x"F")) else
       b_blue_margin when ((graphics_on = '1') and (margin_pixel = '1')) else 

b_doodle_outline when ((graphics_on = '1') and (doodle_outline_pixel = '1')) else
     b_doodle_body when ((graphics_on = '1') and (doodle_body_pixel = '1')) else
     b_doodle_light when ((graphics_on = '1') and (doodle_light_pixel = '1')) else
     b_doodle_stripe when ((graphics_on = '1') and (doodle_stripe_pixel = '1')) else
     --ignore this one
    b_jetpack_outline when ((graphics_on = '1') and (jetpack_outline_pixel = '1')) else
    b_jetpack_body    when ((graphics_on = '1') and (jetpack_body_pixel = '1')) else
    b_jetpack_yellow  when ((graphics_on = '1') and (jetpack_yellow_pixel = '1')) else
    b_jetpack_stripe  when ((graphics_on = '1') and (jetpack_stripe_pixel = '1')) else
    b_jetpack_darkblue when ((graphics_on = '1') and (jetpack_darkblue_pixel = '1')) else
    b_jetpack_brown   when ((graphics_on = '1') and (jetpack_brown_pixel = '1')) else
     b_greenPlatform when ((graphics_on = '1') and (greenPlatform_pixel = '1')) else
     b_flame_red    when ((graphics_on = '1') and (flame_red_pixel = '1')) else
     b_flame_orange when ((graphics_on = '1') and (flame_orange_pixel = '1')) else
     
     
         b_text_outline when ((graphics_on = '1') and (text_outline_pixel = '1')) else
         b_text_shadow when ((graphics_on = '1') and (text_shadow_pixel = '1')) else
         b_game_over_letters when ((graphics_on = '1') and (game_over_letters_pixel = '1')) else


     
         b_brown_beam_outline when ((graphics_on = '1') and (brown_beam_outline_pixel = '1')) else
    b_brown_beam_body when ((graphics_on = '1') and (brown_beam_body_pixel = '1')) else
    b_brown_beam_light when ((graphics_on = '1') and (brown_beam_light_pixel = '1')) else
    
     b_greenPlatform_outline when ((graphics_on = '1') and (greenPlatform_OUTLINE_pixel = '1')) else
     b_greenPlatform_green when ((graphics_on = '1') and (greenPlatform_GREEN_pixel = '1')) else
     b_greenPlatform_light when ((graphics_on = '1') and (greenPlatform_LIGHT_pixel = '1')) else
     
     b_bluePlatform_outline when ((graphics_on = '1') and (bluePlatform_OUTLINE_pixel = '1')) else
     b_bluePlatform_BLUE when ((graphics_on = '1') and (bluePlatform_GREEN_pixel = '1')) else
     b_bluePlatform_light when ((graphics_on = '1') and (bluePlatform_LIGHT_pixel = '1')) else
     b_BK_grid when ((graphics_on = '1') and (BK_grid_pixel = '1')) else
     b_BK_paper when ((graphics_on = '1') and (BK_paper_pixel = '1')) else

     b_BK_paper;

-- draw object shapes 
-- make object1 the background
BK_paper_pixel <= '1' when 
                            (
                                (pixel_type.sprite_type = "011111") 
                                 or (pixel_type.sprite_type = "001100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_BG) 
                                 or  (pixel_type.sprite_type = "001101" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_BG)   
                                 or (pixel_type.sprite_type = "000001" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_BG) or 
                                 (pixel_type.sprite_type = "000000" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_BG)
                                 or (pixel_type.sprite_type = "000011" and
                                    jetpack_sym_to_pix(jetpack(to_integer(row - pixel_type.row))
                                    (to_integer(column - pixel_type.col))) = jetpack_BG)
                                  or (pixel_type.sprite_type = "001000" and
                                 play_again_sym_to_pixel(play_again_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = TEXT_BG)
                                 or (pixel_type.sprite_type = "000111" and
                                 play_again_sym_to_pixel(play_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = TEXT_BG)
                                or (pixel_type.sprite_type = "000110" and
                                 game_over_sym_to_pix(game_over_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = GAME_OVER_BK)
                                 or (pixel_type.sprite_type = "001110" and
                                 beam_sym_to_pix(brown_beam_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = brown_beam_bg) 
                                 or (pixel_type.sprite_type = "011101" and
                                 beam_sym_to_pix(broken_brown_beam_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = brown_beam_bg)
                             
                             )
                                and (row (2 downto 0) /= "000" and column(2 downto 0) /= "000")

                         else '0';
BK_grid_pixel  <= '1' when   
                            (
                                (pixel_type.sprite_type = "011111") 
                                 or (pixel_type.sprite_type = "001100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_BG) 
                                 or  (pixel_type.sprite_type = "001101" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_BG)   
                                 or (pixel_type.sprite_type = "000001" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_BG) or 
                                 (pixel_type.sprite_type = "000000" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_BG)
                                 or (pixel_type.sprite_type = "000011" and
                                 jetpack_sym_to_pix(jetpack(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = jetpack_BG)
                                 or (pixel_type.sprite_type = "000010" and
                                 jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = doodle_BG_jd)
                                 
                                  or (pixel_type.sprite_type = "001000" and
                                 play_again_sym_to_pixel(play_again_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = TEXT_BG)
                                 or (pixel_type.sprite_type = "000111" and
                                 play_again_sym_to_pixel(play_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = TEXT_BG) 
                                 or (pixel_type.sprite_type = "000110" and
                                 game_over_sym_to_pix(game_over_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = GAME_OVER_BK)
                                 or (pixel_type.sprite_type = "001110" and
                                 beam_sym_to_pix(brown_beam_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = brown_beam_bg)                                
                                 or (pixel_type.sprite_type = "011101" and
                                 beam_sym_to_pix(broken_brown_beam_sprite(to_integer(row - pixel_type.row))
                                (to_integer(column - pixel_type.col))) = brown_beam_bg)
                            )
                                and (row (2 downto 0) = "000" or column(2 downto 0) = "000")

                         else '0';

--object2: the green platform
greenPlatform_OUTLINE_pixel <= '1' when ((pixel_type.sprite_type = "001100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_OUTLINE)) else '0';

greenPlatform_GREEN_pixel <= '1' when (pixel_type.sprite_type = "001100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_GREEN) else '0';

greenPlatform_LIGHT_pixel <= '1' when (pixel_type.sprite_type = "001100" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = greenPlatform_LIGHT) else '0';

doodle_LIGHT_pixel <= '1' when (pixel_type.sprite_type = "000001" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_LIGHT) or (pixel_type.sprite_type = "000000" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row))(to_integer(column - pixel_type.col))) = doodle_LIGHT)
                        or (pixel_type.sprite_type = "000010" and jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row))(to_integer(column - pixel_type.col))) = doodle_LIGHT_jd) else '0';
doodle_BODY_pixel <= '1' when (pixel_type.sprite_type = "000001" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_BODY) or (pixel_type.sprite_type = "000000" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_BODY) 
                        or(pixel_type.sprite_type = "000010" and jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_BODY_jd) else '0';
doodle_OUTLINE_pixel <= '1' when (pixel_type.sprite_type = "000001" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_OUTLINE) or (pixel_type.sprite_type = "000000" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_OUTLINE)
                            or (pixel_type.sprite_type = "000010" and jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_OUTLINE_jd) else '0';
doodle_stripe_pixel <= '1' when (pixel_type.sprite_type = "000001" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(TO_UNSIGNED(doodle_width, column'length) - (column - pixel_type.col)))) = doodle_stripe) or (pixel_type.sprite_type = "000000" and doodle_sym_to_pix(doodle_right(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_stripe) 
                            or (pixel_type.sprite_type = "000010" and jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row)) (to_integer(column - pixel_type.col))) = doodle_stripe_jd) else '0';

bluePlatform_OUTLINE_pixel <= '1' when ((pixel_type.sprite_type = "001101" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_OUTLINE)) else '0';

bluePlatform_GREEN_pixel <= '1' when (pixel_type.sprite_type = "001101" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_BLUE) else '0';

bluePlatform_LIGHT_pixel <= '1' when (pixel_type.sprite_type = "001101" and platform_full_tile(to_integer(row - pixel_type.row), to_integer(column - pixel_type.col)) = bluePlatform_LIGHT) else '0';

jetpack_outline_pixel <= '1' when
    (pixel_type.sprite_type = "000011" and
     jetpack_sym_to_pix(jetpack(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_outline)
else '0';

jetpack_body_pixel <= '1' when
    (pixel_type.sprite_type = "000011" and
     jetpack_sym_to_pix(jetpack(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_body)
     
     or     (pixel_type.sprite_type = "000010" and
     jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_body_jd)
else '0';

jetpack_yellow_pixel <= '1' when
    (pixel_type.sprite_type = "000011" and
     jetpack_sym_to_pix(jetpack(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_yellow) or 
     
     (pixel_type.sprite_type = "000010" and
     jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_yellow_jd)
else '0';

jetpack_stripe_pixel <= '1' when
    (pixel_type.sprite_type = "000011" and
     jetpack_sym_to_pix(jetpack(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_stripe) or 
     
     (pixel_type.sprite_type = "000010" and
     jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_stripe_jd)
else '0';

jetpack_darkblue_pixel <= '1' when
    (pixel_type.sprite_type = "000011" and
     jetpack_sym_to_pix(jetpack(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_darkblue) or 
     
         (pixel_type.sprite_type = "000010" and
     jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_darkblue_jd)
else '0';

jetpack_brown_pixel <= '1' when
    (pixel_type.sprite_type = "000011" and
     jetpack_sym_to_pix(jetpack(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_brown) or 
    
     (pixel_type.sprite_type = "000010" and
     jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = jetpack_brown_jd)
else '0';

flame_red_pixel <= '1' when pixel_type.sprite_type = "000010" and
     jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = flame_outer_jd else '0';

flame_orange_pixel <= '1' when pixel_type.sprite_type = "000010" and
     jetpack_and_doodle_sym_to_pix(jetpackAndDoodle(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = flame_core_jd else '0';

text_outline_pixel <= '1' when (pixel_type.sprite_type = "001000" and
     play_again_sym_to_pixel(play_again_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = TEXT_OUTLINE) or 
     (pixel_type.sprite_type = "000111" and
     play_again_sym_to_pixel(play_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = TEXT_OUTLINE)
       else '0';
text_shadow_pixel <= '1' when (pixel_type.sprite_type = "001000" and
     play_again_sym_to_pixel(play_again_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = TEXT_SHADOW) or
     (pixel_type.sprite_type = "000111" and
     play_again_sym_to_pixel(play_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = TEXT_SHADOW)  else '0';
     
game_over_letters_pixel <= '1' when (pixel_type.sprite_type = "000110" and
     game_over_sym_to_pix(game_over_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = GAME_OVER_LETTERS) else '0';

brown_beam_outline_pixel <= '1' when (pixel_type.sprite_type = "001110" and
     beam_sym_to_pix(brown_beam_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = brown_beam_outline) or 
     (pixel_type.sprite_type = "011101" and
     beam_sym_to_pix(broken_brown_beam_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = brown_beam_outline)
     else '0' 
     ;

brown_beam_body_pixel <= '1' when (pixel_type.sprite_type = "001110" and
     beam_sym_to_pix(brown_beam_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = brown_beam_body) or
     (pixel_type.sprite_type = "011101" and
     beam_sym_to_pix(broken_brown_beam_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = brown_beam_body) 
     else '0'; 

brown_beam_light_pixel <= '1' when (pixel_type.sprite_type = "001110" and
     beam_sym_to_pix(brown_beam_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = brown_beam_light) or 
      (pixel_type.sprite_type = "011101" and
     beam_sym_to_pix(broken_brown_beam_sprite(to_integer(row - pixel_type.row))
     (to_integer(column - pixel_type.col))) = brown_beam_light)
     else '0';    
 

end Behavioral;


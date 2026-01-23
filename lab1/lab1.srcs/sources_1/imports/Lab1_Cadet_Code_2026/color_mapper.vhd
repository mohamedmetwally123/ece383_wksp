----------------------------------------------------------------------------------
-- Lt Col James Trimble, 16-Jan-2025
-- color_mapper (previously scope face) determines the pixel color value based on the row, column, triggers, and channel inputs 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity color_mapper is
    Port ( color : out color_t;
           position: in coordinate_t;
		   trigger : in trigger_t;
           ch1 : in channel_t;
           ch2 : in channel_t);
end color_mapper;

architecture color_mapper_arch of color_mapper is

signal trigger_color : color_t := YELLOW; 
signal background_color: color_t := BLACK;
signal grid_color: color_t := WHITE;
signal hashes_color: color_t := WHITE;
-- Add other colors you want to use here

signal is_vertical_gridline, is_horizontal_gridline, is_within_grid, is_trigger_time, is_trigger_volt, is_ch1_line, is_ch2_line,
    is_horizontal_hash, is_vertical_hash : boolean := false;

-- Fill in values here
constant grid_start_row : integer := 20 ;
constant grid_stop_row : integer := 420 ;
constant grid_start_col : integer := 20 ;
constant grid_stop_col : integer := 620;
constant num_horizontal_gridblocks : integer := 10;
constant num_vertical_gridblocks : integer := 8;
constant center_column : integer := 320;
constant center_row : integer := 220;
constant hash_size : integer := 6; -- Might change it later
constant hash_horizontal_spacing : integer := 15;
constant hash_vertical_spacing : integer := 10;
--I added these
constant trigger_width : integer := 20;
constant trigger_height : integer := 10;


begin

-- Assign values to booleans here
    --First make sure we're inside the grid
    is_within_grid <= (position.row >= grid_start_row) and (position.row <= grid_stop_row)
                                 and (position.col >= grid_start_col) and (position.col <= grid_stop_col);
    is_horizontal_gridline <= is_within_grid and ((position.row - grid_start_row) mod 50 = 0);
    is_vertical_gridline <= is_within_grid and ((position.col - grid_start_col) mod 60 = 0);
    is_horizontal_hash <= (not is_vertical_gridline) and is_within_grid and
                          ((position.col - grid_start_col) mod hash_horizontal_spacing = 0) and
                          ((position.row <= center_row + hash_size / 2) and (position.row >= center_row - hash_size / 2));
    is_vertical_hash <= (not is_horizontal_gridline) and is_within_grid and
                         ((position.row - grid_start_row) mod hash_vertical_spacing = 0) and 
                         ((position.col <= center_column + hash_size / 2) and (position.col >= center_column - hash_size / 2));
    is_trigger_time <= (abs(to_integer(position.col) - to_integer(trigger.t))) <= (trigger_width / 2) and
                       (trigger_width / 2 - abs(to_integer(position.col) - to_integer(trigger.t))) >= (position.row - grid_start_row);
    is_trigger_volt <= (abs(to_integer(position.row) - to_integer(trigger.v))) <= (trigger_width / 2) and
                       (trigger_width / 2 - abs(to_integer(position.row) - to_integer(trigger.v))) >= (position.col - grid_start_col);
-- Use your booleans to choose the color
    color <=        trigger_color when (is_trigger_time or is_trigger_volt) else 
                    grid_color when (is_horizontal_gridline or is_vertical_gridline) else
                    hashes_color when(is_vertical_hash or is_horizontal_hash) else 
                    background_color;
                                   

end color_mapper_arch;

-- vga_signal_generator Generates the hsync, vsync, blank, and row, col for the VGA signal

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity vga_signal_generator is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           position: out coordinate_t;
           vga : out vga_t);
end vga_signal_generator;

architecture vga_signal_generator_arch of vga_signal_generator is

    signal horizontal_roll, vertical_roll: std_logic := '0';		
    signal h_counter_ctrl, v_counter_ctrl: std_logic := '1'; -- Default to counting up
    signal h_sync_is_low, v_sync_is_low, h_blank_is_low, v_blank_is_low : boolean := false;
    signal current_pos : coordinate_t;
    
    constant h_sync_lowest_boundary: integer := 655;
    constant h_sync_highest_boundary: integer := 751;
    constant h_blank_lowest_boundary: integer := 0;
    constant h_blank_highest_boundary: integer := 639;
    constant v_sync_lowest_boundary: integer := 489;
    constant v_sync_highest_boundary: integer := 491;
    constant v_blank_lowest_boundary: integer := 0;
    constant v_blank_highest_boundary: integer := 479;
    constant h_sync_max_value: integer := 799;
    constant v_sync_max_value: integer := 524;

begin

-- horizontal counter
    col_counter : counter
        generic map (
            num_bits  => 10,
            max_value => 799
        )
        port map ( clk => clk,
               reset_n => reset_n,
               ctrl => h_counter_ctrl,
               roll => horizontal_roll ,
               Q => current_pos.col);

-- Glue code to connect the horizontal and vertical counters
	v_counter_ctrl <= horizontal_roll;		
-- vertical counter
   
   row_counter : counter
       generic map (
          num_bits => 10,
          max_value => 524
       )
       port map (
           clk => clk,
           reset_n => reset_n,
           ctrl => v_counter_ctrl,
           roll => vertical_roll ,
           Q => current_pos.row);
-- Assign VGA outputs in a gated manner
process (clk)
begin
   if (rising_edge(clk)) then
      --When h_sync goes low
    h_sync_is_low <= (current_pos.col >= h_sync_lowest_boundary) and (current_pos.col < h_sync_highest_boundary);

    --When h_blank goes low
    h_blank_is_low <= ((current_pos.col >= h_blank_lowest_boundary) and (current_pos.col < h_blank_highest_boundary)) or
                       (current_pos.col = h_sync_max_value);

    --When v_sync goes low
    v_sync_is_low <= (current_pos.row >= v_sync_lowest_boundary) and (current_pos.row < v_sync_highest_boundary);
    --When v_blank goes low
    v_blank_is_low <= ((current_pos.row >= v_blank_lowest_boundary) and (current_pos.row < v_blank_highest_boundary)) or 
                       (current_pos.row = v_sync_max_value);  
                 
    position <= current_pos;
    vga.hsync <= '0' when (h_sync_is_low = true) else '1';
    vga.vsync <= '0' when (v_sync_is_low = true) else '1';
    vga.blank <= '0' when (v_blank_is_low = true and h_blank_is_low = true) else '1';
   end if;
end process;

-- Assign output ports



end vga_signal_generator_arch;

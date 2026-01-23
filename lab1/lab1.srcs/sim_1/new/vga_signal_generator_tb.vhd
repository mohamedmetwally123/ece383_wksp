----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/21/2026 02:34:44 PM
-- Design Name: 
-- Module Name: vga_signal_generator_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_signal_generator_tb is
--  Port ( );
end vga_signal_generator_tb;

architecture Behavioral of vga_signal_generator_tb is
    constant CLK_PERIOD : time := 10 ns;
    signal clk, reset_n: std_logic := '1';
    signal position: coordinate_t;
    signal vga: vga_t;
begin
    clk <= not clk after CLK_PERIOD / 2;
    dut : entity work.vga_signal_generator

        port map (
           clk => clk,
           reset_n => reset_n,
           position => position,
           vga => vga
        );


end Behavioral;

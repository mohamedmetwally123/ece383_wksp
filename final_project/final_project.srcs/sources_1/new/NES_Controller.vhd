----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026 10:28:57 AM
-- Design Name: 
-- Module Name: NES_Controller - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
library UNISIM;
use UNISIM.VComponents.all;
use work.graphicsParts.all;	

entity NES_Controller is
  Port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        NES_data: in std_logic;
        NES_clk: out std_logic;
        NES_latch: out std_logic;
        NES_scan: out std_logic_vector(7 downto 0)
   );
end NES_Controller;

architecture Behavioral of NES_Controller is
    signal cw: std_logic_vector(7 downto 0);
    signal sw: std_logic_vector(1 downto 0);
begin
    cu: NES_Controller_cu Port Map (
        clk  => clk,
        reset_n => reset_n,
        cw  => cw, -- control word
        sw => sw); 
     datapath: NES_Controller_datapath Port Map(
        clk  => clk,
        reset_n => reset_n,
        NES_data => NES_data,
        NES_clk => NES_clk,
        NES_latch => NES_latch,
        cw  => cw,  -- control word
        sw  => sw, -- status word   
        NES_scan => NES_scan 
     ); 

end Behavioral;

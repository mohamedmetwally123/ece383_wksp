----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/06/2026 04:04:32 PM
-- Design Name: 
-- Module Name: tb_priority_encoder - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_priority_encoder is
--  Port ( );
end tb_priority_encoder;

architecture Behavioral of tb_priority_encoder is
    signal i3, i2, i1, i0 : std_logic := '0';
    signal o1, o0 : std_logic;
begin
    test: entity work.priority_encoder
    port map (
      I3 => i3,
      I2 => i2,
      I1 => i1,
      I0 => i0,
      O1 => o1,
      O0 => o0
    );
    sim: process
    begin
        I3 <= '0'; I2 <= '0'; I1 <= '0'; I0 <= '1'; wait for 10 ns;
        I3 <= '0'; I2 <= '0'; I1 <= '1'; I0 <= '0'; wait for 10 ns;
        I3 <= '0'; I2 <= '1'; I1 <= '0'; I0 <= '0'; wait for 10 ns;
        I3 <= '1'; I2 <= '0'; I1 <= '0'; I0 <= '0'; wait for 10 ns;
        I3 <= '1'; I2 <= '1'; I1 <= '1'; I0 <= '1'; wait for 10 ns;
        wait;
    end process;
end Behavioral;

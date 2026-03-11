----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2026 03:49:09 PM
-- Design Name: 
-- Module Name: counter - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
    generic (
           num_bits : integer := 4;
           max_value : integer := 9
    );
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           ctrl : in STD_LOGIC;
           roll : out STD_LOGIC;
           Q : out unsigned (num_bits-1 downto 0));
end counter;

architecture Behavioral of counter is
    signal processQ: unsigned (num_bits - 1 downto 0) := (others => '0');
begin
    process(clk)
        begin
            if(rising_edge(clk)) then
                if(reset_n = '0') then
                    processQ <= (others => '0');
                elsif((ctrl = '1') and (processQ >= max_value)) then
                    processQ <= (others => '0');
                elsif ((ctrl = '1') and (processQ < max_value)) then
                    processQ <= processQ + 1; 
                else 
                    processQ <= processQ;
                end if;
            end if;
    end process;
    --Q represents the output, while processQ represents the internal state of the process
    Q <= processQ;
    --Better to have it outside because it will be evaluated all the time
    --And as long as processQ is equal to 9, roll will be driven high
    roll <= '1' when (processQ = max_value) else '0'; 
end Behavioral;

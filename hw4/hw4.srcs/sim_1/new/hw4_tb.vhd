----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2026 03:49:46 PM
-- Design Name: 
-- Module Name: counter_tb - Behavioral
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

entity hw4_tb is
end hw4_tb;

architecture Behavioral of hw4_tb is
    component counter 
        generic (
               num_bits : integer := 4;
               max_value : integer := 9
        );
        port ( clk : in STD_LOGIC;
               reset_n : in STD_LOGIC;
               ctrl : in STD_LOGIC;
               roll : out STD_LOGIC;
               Q : out unsigned (num_bits-1 downto 0));
    end component;
    
    signal clk, reset_n, ctrl: std_logic := '0';
    signal roll_lsb, roll_msb: std_logic := '0';
    signal Q_lsb, Q_msb: unsigned (3 downto 0) := "0000";
begin
    --Generating the clock
    clk <= not clk after 5 ns;
    lsb: counter port map(
        clk => clk,
        reset_n => reset_n,
        ctrl => ctrl,
        roll => roll_lsb,
        Q => Q_lsb
    );
    msb: counter port map(
    clk => clk,
    reset_n => reset_n,
    ctrl => roll_lsb,
    roll => roll_msb,
    Q => Q_msb
    );
    process
    begin
        reset_n <= '0'; wait for 10 ns;
        reset_n <= '1'; wait for 10 ns;
        ctrl <= '1'; wait for 40 ns;
        ctrl <= '0'; wait for 10 ns;
        ctrl <= '1'; wait;
    end process;


end Behavioral;

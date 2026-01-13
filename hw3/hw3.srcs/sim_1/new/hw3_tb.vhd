----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/12/2026 06:55:08 PM
-- Design Name: 
-- Module Name: hw3_tb - Behavioral
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

entity hw3_tb is
--  Port ( );
end hw3_tb;

architecture Behavioral of hw3_tb is
    component hw3
    port(
        d : in unsigned (7 downto 0);
        h : out STD_LOGIC
    );
    end component;
    signal d: unsigned (7 downto 0);
    signal h: std_logic; 
    
    constant num_test_cases : integer := 7;
    
    subtype input is unsigned(7 downto 0);
    type test_input_vector is array(1 to num_test_cases) of input;
    constant test_input: test_input_vector := (to_unsigned(17, 8), to_unsigned(34, 8), to_unsigned(2, 8), to_unsigned(51, 8), to_unsigned(68, 8), to_unsigned(85, 8), to_unsigned(52, 8)); 

    subtype output is std_logic;
    type test_output_vector is array(1 to num_test_cases) of output;
    signal test_output: test_output_vector := ('1', '1', '0', '1', '1', '1', '0');
    

begin
    uut: hw3 port map(
        d => d, 
        h => h 
    );
    process
        begin
            for i in 1 to num_test_cases loop
                d <= test_input(i);
                wait for 5 ns;
                assert h = test_output(i)
                report "Error in scancode_decode circuit for input case " &
                        integer'image(i) severity warning;
            end loop;
            wait;
        end process;
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/08/2026 01:06:57 PM
-- Design Name: 
-- Module Name: scancode_decoder_tb - Behavioral
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

entity scancode_decoder_tb is
--  Port ( );
end scancode_decoder_tb;

architecture behavior of scancode_decoder_tb is
    component scancode_decoder
        port(
        scancode : in STD_LOGIC_VECTOR (7 downto 0);
        decoded_value : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    
    signal scancode : std_logic_vector(7 downto 0);
    signal decoded_value : std_logic_vector(3 downto 0);
    
    constant num_test_cases : integer := 10;
    
    subtype input is std_logic_vector (7 downto 0);
    type test_input_vector is array(1 to num_test_cases) of input;
    signal test_input: test_input_vector := (x"45", x"16", x"1E", x"26", x"25", x"2E", x"36", x"3D", x"3E", x"46");
    
    subtype output is std_logic_vector(3 downto 0);
    type test_output_vector is array(1 to num_test_cases) of output;
    signal test_output: test_output_vector := ("0000", "0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "1001");
    
    begin
    uut: scancode_decoder port map(
        scancode => scancode,
        decoded_value => decoded_value  
    );
    
    process
        variable pass_count: integer := 0;
        begin 
            for i in 1 to num_test_cases loop
                scancode <= test_input(i);
                wait for 5 ns;
                assert decoded_value = test_output(i)
                    report "Error in scancode_decode circuit for input case " &
                    integer'image(i) severity warning;
                if(decoded_value = test_output(i)) then
                    pass_count := pass_count + 1; 
                end if;
            end loop;
            wait;
       end process; 
            
    end behavior;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2026 07:52:29 AM
-- Design Name: 
-- Module Name: Flag_Register - Behavioral
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

entity Flag_Register is
 Port ( clk: in std_logic;
        reset_n: in std_logic;
        set: in std_logic;
        clear: in std_logic;
        Q: out std_logic
        );
end Flag_Register;

architecture Behavioral of Flag_Register is
    signal Q_next, Q_current: std_logic := '0';
begin
    process(clk) 
        begin
        if(rising_edge(clk)) then
           if(reset_n = '0') then 
                Q_next <= '0';
           elsif(set = '0' and clear = '1') then 
                Q_next <= '0';
           elsif(set = '1' and clear = '0') then 
                Q_next <= '1';
           else 
                Q_next <= Q_current;                        
           end if; 
        
        end if;
    
        end process;
    Q_current <= Q_next;
    Q <= Q_current; 
end Behavioral;

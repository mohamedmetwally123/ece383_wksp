----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/04/2026 03:32:30 PM
-- Design Name: 
-- Module Name: lec11_cu - Behavioral
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

entity lec11_cu is
  Port (clk: in  STD_LOGIC;
					reset : in  STD_LOGIC;
					kbClk: in std_logic;
					cw: out STD_LOGIC_VECTOR(3 downto 0);
					sw: in STD_LOGIC;
					busy: out std_logic);
end lec11_cu;

architecture Behavioral of lec11_cu is
    type state_type is (waitStart, init0, compareI, waitClkFallingEdge, sampleBits, waitClkRisingEdge, increment_i, scanBits);  
    signal state: state_type := waitStart;
    signal less: std_logic:= '1';
begin
    state_process: process(clk)
        begin 
            if(rising_edge(clk)) then 
                if(reset = '0') then
                    state <= waitStart;
                else 
                    case state is 
                        when waitStart => 
                            if(kbClk = '0') then state <= init0; end if;             
                        when init0 => 
                            state <= compareI;
                        when compareI =>
                            if(sw = '1') then state <= scanBits;
                            else state <= waitClkFallingEdge; end if;
                         when waitClkFallingEdge =>
                            if(kbClk = '0') then state <= sampleBits; end if;
                         when sampleBits =>
                            state <= waitClkRisingEdge;
                         when waitClkRisingEdge =>
                            if(kbClk = '1') then state <= increment_i; end if;
                         when increment_i =>
                            state <= compareI;
                         when scanBits =>
                            state <= waitStart;
                         when others =>
                            state <= waitStart;
                      end case;
                 end if;
            end if;
        end process;
        cw <= "0000" when state = waitStart else
              "0011" when state = init0 else 
              "0000" when state = compareI else
              "0000" when state = waitClkFallingEdge else
              "0100" when state = sampleBits else
              "0000" when state = waitClkRisingEdge else 
              "0001" when state = increment_i else 
              "1000" when state = scanBits;
        busy <= '0' when state = waitstart else '1';
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026 09:31:20 AM
-- Design Name: 
-- Module Name: NES_Controller_datapath - Behavioral
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

entity NES_Controller_datapath is
  Port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        NES_data: in std_logic;
        NES_clk: out std_logic;
        NES_latch: out std_logic;
        cw      : in std_logic_vector(7 downto 0);  -- control word
        sw      : out std_logic_vector(1 downto 0); -- status word   
        NES_scan: out std_logic_vector(7 downto 0)    
   );
end NES_Controller_datapath;

architecture Behavioral of NES_Controller_datapath is
    signal read_counter: unsigned(3 downto 0):= "0000";
    signal delay_counter: unsigned(10 downto 0):= "00000000000";
    
    alias sw_NES_read_complete : std_logic is sw(0);
    alias sw_delay_complete : std_logic is sw(1);


    signal delay_length: unsigned(10 downto 0):= TO_UNSIGNED(1200, 11); 
    signal data_length: unsigned(3 downto 0):=  TO_UNSIGNED(8, 4);  
    
    signal NES_shift_reg: std_logic_vector(7 downto 0);
    signal NES_scan_reg: std_logic_vector(7 downto 0);


begin
        -- counter to track how many bits are read from the nes controller
        NES_read_counter: counter 
        generic map (N => 4) 
        port map(
            clk     => clk,
            reset_n => reset_n,
            ctrl    => cw(1 downto 0),
            D       => "0000",
            Q       => read_counter
        );
        
        sw_NES_read_complete <= '1' when read_counter >= data_length else '0';
        
        NES_delay_counter: counter 
        generic map (N => 11) 
        port map(
            clk     => clk,
            reset_n => reset_n,
            ctrl    => cw(3 downto 2),
            D       => "00000000000",
            Q       => delay_counter
        );
        
        sw_delay_complete <= '1' when delay_counter >= delay_length else '0';
        
                -----------------------------------------------------------------------------
        --		The shift register keeps  8-bits 
        --    cw(4)
        --		0			hold
        --		1			shift right (data comes in at the MSB)
        -----------------------------------------------------------------------------
        process(clk)
        begin
            if (rising_edge(clk)) then
                if (reset_n = '0') then
                    NES_shift_reg <= (others => '0');
                elsif (cw(4) = '1') then
                    NES_shift_reg <= NES_data & NES_shift_reg(7 downto 1);
                end if;
            end if;
        end process;
	   
	        -----------------------------------------------------------------------------
	--		The NES_scan register is loaded with the 8 NES_scan bits for output 
	--    cw(7)
	--		0			hold
	--		1			load
	-----------------------------------------------------------------------------
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then
				NES_scan_reg <= (others => '0');
			elsif (cw(7) = '1') then
				NES_scan_reg <= NES_shift_reg;
			end if;
		end if;
	end process;
    
    NES_latch <= cw(6);
    NES_clk <= cw(5);
    NES_scan <= not NES_scan_reg;
end Behavioral;

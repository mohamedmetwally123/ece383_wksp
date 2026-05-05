----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2026 09:22:44 PM
-- Design Name: 
-- Module Name: doodle_audio_cu - Behavioral
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

entity doodle_audio_cu is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cw      : out std_logic_vector(1 downto 0);  -- control word
        sw      : in std_logic_vector(2 downto 0) -- status word
    );
end doodle_audio_cu;

architecture Behavioral of doodle_audio_cu is
    type state_type is (wait_for_audio_play_request, Load_sound, wait_for_ready_high, Inc_Read_Address, Is_done, wait_for_ready_low);
    signal state : state_type;
begin
	state_proces: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then 
				state <= wait_for_audio_play_request;
			else 
				case state is
				    when wait_for_audio_play_request => 
				        if(sw(1) = '1') then state <= Load_sound; end if;
					when Load_sound =>
					   state <= wait_for_ready_high;
					when wait_for_ready_high =>
					   if(sw(0) = '1') then state <= Inc_Read_Address; end if;
				    when Inc_Read_Address => 
				        state <= Is_done;
				    when Is_done =>
				        if(sw(2) = '1') then state <= wait_for_audio_play_request; else state <= wait_for_ready_low; end if;
				    when wait_for_ready_low =>
				         if(sw(0) = '0') then state <= wait_for_ready_high; end if;	   
				end case;
			end if;
		end if;
	end process; 
    cw <= "00" when state =  wait_for_audio_play_request else
	      "11" when state = Inc_Read_Address else 
	      "01";                
                  
end Behavioral;

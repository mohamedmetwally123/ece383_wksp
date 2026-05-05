----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2026 08:33:44 AM
-- Design Name: 
-- Module Name: NES_Controller_cu - Behavioral
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

entity NES_Controller_cu is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cw      : out std_logic_vector(7 downto 0);  -- control word
        sw      : in std_logic_vector(1 downto 0) -- status word
    );
end NES_Controller_cu;

architecture Behavioral of NES_Controller_cu is
    type state_type is (latch_high, latch_high_delay, latch_low, latch_low_delay,  Init_Counter, read_data, Inc_Counter, clk_high, clk_high_delay, clk_low, clk_low_delay, is_done, store_output);
    signal state : state_type;
begin
	state_proces: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then 
				state <= latch_high;
			else 
				case state is
				    when latch_high => 
				        state <= latch_high_delay; 
				    when latch_high_delay => 
				        if(sw(1) = '1') then state <= latch_low; end if;
					when latch_low =>
					   state <= latch_low_delay;
					when latch_low_delay => 
					    if(sw(1) = '1') then state <= Init_Counter; end if;
					when Init_Counter =>
					   state <= read_data;
				    when read_data => 
				        state <= clk_high;
				    when clk_high =>
				        state <= clk_high_delay;
				    when clk_high_delay =>
				         if(sw(1) = '1') then state <= clk_low; end if;
				    when clk_low => 
				        state <= clk_low_delay;
				    when clk_low_delay => 
				        if(sw(1) = '1') then state <= Inc_counter; end if;
				    when Inc_Counter => 
				        state <= Is_done;
				    when Is_done => 
				        if(sw(0) = '1') then state <= store_output; else state <= read_data;end if;
				    when store_output => 
				        state <= latch_high;
				    	   
				end case;
			end if;
		end if;
	end process; 
    cw <= "01001100" when state =  latch_high else
          "01000100" when state = latch_high_delay else
	      "00001100" when state = latch_low else
	      "00000100" when state = latch_low_delay else
	      "00001111" when state = Init_Counter else 
	      "00010000" when state = read_data else 
	      "00101100" when state = clk_high else
	      "00100100" when state = clk_high_delay else
	      "00001100" when state = clk_low else 
	      "00000100" when state = clk_low_delay else
          "00000001" when state = Inc_Counter else 
          "00000000" when state = is_done else 
          "10000000" when state = store_output else
          "00000000";

                  

end Behavioral;

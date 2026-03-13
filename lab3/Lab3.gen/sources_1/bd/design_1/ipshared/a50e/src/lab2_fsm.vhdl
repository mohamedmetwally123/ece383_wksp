----------------------------------------------------------------------------------
-- Name:	Template by George York (modified from Jeff Falkinburg)
-- Date:	Spring 2023
-- File:    lab2_fsm.vhd
-- HW:	    Lab 2 
-- Pupr:	Lab 2 Finite State Machine for the write circuitry.  
--
-- Doc:	Adapted from Dr Coulston's Lab exercise
-- 	
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity lab2_fsm is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           sw : in  STD_LOGIC_VECTOR (2 downto 0);
           cw : out  STD_LOGIC_VECTOR (2 downto 0));
end lab2_fsm;

architecture Behavioral of lab2_fsm is

    type state_type is (WaitForTrigger, ResetCounter, WaitForReady, SaveSample, IncrementCounter);
	signal state: state_type := WaitForTrigger;

begin

	-------------------------------------------------------------------------------
	--		SW		meaning
	--		sw[0] -> Ready
	--      sw[1] -> Last Address
	--      sw[2] -> Trigger
	-------------------------------------------------------------------------------
	state_proces: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then 
				state <= WaitForTrigger;
			else 
				case state is
				    when WaitForTrigger => 
				        if(sw(2) = '1') then state <= ResetCounter; end if;
					when ResetCounter =>
					   state <= WaitForReady;
					when WaitForReady =>
					   if(sw(0) = '1') then state <= SaveSample; end if;
				    when SaveSample => 
				        state <= IncrementCounter;
				    when IncrementCounter =>
				        if(sw(1) = '1') then state <= WaitForTrigger; else state <= WaitForReady; end if;	   
				end case;
			end if;
		end if;
	end process;

	-------------------------------------------------------------------------------
	--  CW output table
	--		CW		meaning
	--		cw[0:1]            cw[2]
    --	    00 -> Hold         1 -> Save Sample
    --	    01 -> Count Up     0 -> don't save sample
    --	    11 -> Reset  
    --      10 -> load D  
	-------------------------------------------------------------------------------
	
	cw <= "000" when state = WaitForTrigger else
	      "010" when state = ResetCounter else 
	      "000" when state = WaitForReady    else 
	      "100" when state = SaveSample   else
	      "001" when state = IncrementCounter;

end Behavioral;


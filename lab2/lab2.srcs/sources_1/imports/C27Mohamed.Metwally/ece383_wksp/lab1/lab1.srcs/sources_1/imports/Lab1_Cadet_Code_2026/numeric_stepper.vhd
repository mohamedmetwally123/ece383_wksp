-- Numeric Stepper: Holds a value and increments or decrements it based on button presses
-- James Trimble, 20 Jan 2026

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity numeric_stepper is
  generic (
    num_bits  : integer := 8;
    max_value : integer := 127;
    min_value : integer := -128;
    delta     : integer := 10
  );
  port (
    clk     : in  std_logic;
    reset_n : in  std_logic;                    -- active-low synchronous reset
    en      : in  std_logic;                    -- enable
    up      : in  std_logic;                    -- increment on rising edge
    down    : in  std_logic;                    -- decrement on rising edge
    q       : out signed(num_bits-1 downto 0)   -- signed output
  );
end numeric_stepper;

architecture numeric_stepper_arch of numeric_stepper is
    signal process_q : signed(num_bits-1 downto 0) := to_signed(min_value,num_bits);
    signal prev_up, prev_down : std_logic := '0'; --Track the previous states of up/down
    --is_increment/decrement: decide whether to increment/decrement
    --is_debouncing_up/down: Determine if the button is still debouncing
    signal is_increment, is_decrement, is_debouncing_up, is_debouncing_down : boolean := false;
    
    signal counter_ctrl, counter_reset: std_logic := '1';
    signal roll: std_logic := '0';
    signal process_counter: unsigned (18 downto 0) := (others => '0');
    
begin
    debouncer: counter
    -- horizontal counter
        generic map (
            num_bits  => 19,
            max_value => 500000
        )
        port map ( clk => clk,
               reset_n => counter_reset,
               ctrl => counter_ctrl,
               roll => roll ,
               Q => process_counter);
    process(clk)
    begin
    if(rising_edge(clk)) then
        --Reset everything if reset is low
        if(reset_n = '0') then 
            process_q <= to_signed(min_value, num_bits);
            prev_up <= '0';
            prev_down <= '0';
            is_debouncing_up <= false;
            is_debouncing_down <= false;
            counter_reset <= '0';
        else
            --Ensure counter doesn't reset. Counter reset is active low  
            if(is_debouncing_up or is_debouncing_down) then
                counter_reset <= '1';
            end if;
            --Debouncing up mode
            if(is_debouncing_up) then     
                if roll = '1' then
                    --Roll flag = 1 and the button signal is still high
                    if(up = '1' and en = '1' and (process_q + to_signed(delta, num_bits)) <= to_signed(max_value, num_bits)) then
                        process_q <=  process_q + to_signed(delta, num_bits); 
                    end if;
                    is_debouncing_up <= false;
                end if;
             --Debouncing down mode
            elsif(is_debouncing_down) then  
            
                if roll = '1' then 
                --Roll flag = 1 and the button signal is still high
                    if(down = '1' and en = '1' and (process_q - to_signed(delta, num_bits)) >= to_signed(min_value, num_bits)) then
                        process_q <=  process_q - to_signed(delta, num_bits); 
                    end if;
                    is_debouncing_down <= false; 
                end if;
            else 
                --If we got here, we're not in the debouncing mode
                --Button up is pressed
                if(prev_up = '0' and up = '1') then 
                    is_debouncing_up <= true;
                    counter_reset <= '0';
                --Button down is pressed
                elsif(prev_down = '0' and down = '1') then 
                    is_debouncing_down <= true;
                    counter_reset <= '0';
                end if;
            end if;
        end if; 
        --Update outputs
        prev_up <= up;
        prev_down <= down;
        q <= process_q;   
    end if;       
    end process;
    
end numeric_stepper_arch;

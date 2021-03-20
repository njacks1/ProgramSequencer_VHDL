library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity Incrementer is  
port( 
    incrementer_input : IN std_logic_vector(17 downto 0)    --Input number to Incrementer
    enable : IN std_logic   --on/off switch for Incrementer
    incrementer_output : OUT std_logic_vector(17 downto 0)     --Output number (incrementer_input + 1) from Incrementer
 );
end Incrementer;

architecture behav of Stack18Bits is
        process(incrementer_input, enable)  --Not sure if enable is suppose to be in the process list
            begin
                if(enable = '1') then
                    incrementer_output <= incrementer_input + 1;    --Adding one to the input if incrementer is ON
                else
                    incrementer_output <= "ZZZZZZZZZZZZZZZZZZ";     --High impedance if incrementer is OFF
                end if;
            end process;
    end behav;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity LoopComparator_14Bit is  
port(next_instruction : in std_logic_vector(13 downto 0);
     last_instruction : in std_logic_vector(13 downto 0);
     clk : in std_logic;
     loop_flag : out std_logic
 );
end LoopComparator_14Bit;

architecture behav of LoopComparator_14Bit is
    begin
        process(next_instruction, last_instruction, clk)    --Added clk to the process list
			begin
                if(clk'event and clk = '1) then
                    if (next_instruction = last_instruction) then
                        loop_flag <= '1';
                    else
                        loop_flag <= '0';
                    end if;
                end if;
			end process;
    end behav;
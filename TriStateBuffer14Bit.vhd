library ieee;
use ieee.std_logic_1164.all;
	Entity TriStateBuffer_14Bit is
		Port(enable : in std_logic;    --Enable bit
			input : in std_logic_vector(13 downto 0);  --Input signal
			output : out std_logic_vector(13 downto 0));    --Output signal
	end TriStateBuffer_14Bit;
	
	Architecture Behavioral of TriStateBuffer_14Bit is
		begin
			process(input, enable)  --Activate process if Enable or Input change
				begin
					if (sel = '1') then     --If enable is high, input will pass through to output
						output <= input;
					elsif (sel = '0') then     --If enable is low, input will not pass through to output
						output <= "ZZZZZZZZZZZZZZ";
					end if;
			end process;
		end Behavioral;
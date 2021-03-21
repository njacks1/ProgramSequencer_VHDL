library ieee;
use ieee.std_logic_1164.all;
	Entity Mux3to1_14bit is
		Port(sel : in std_logic_vector(1 downto 0);    --Selector bits
			input1 : in std_logic_vector(13 downto 0);  --Input signal 1
			input2 : in std_logic_vector(13 downto 0);  --Input signal 2
            input3 : in std_logic_vector(13 downto 0);  --Input signal 3
			output : out std_logic_vector(13 downto 0));    --Output signal
	end Mux3to1_14bit;
	
	Architecture Behavioral of Mux3to1_14bit is
		begin
			process(input1, input2, input3)
				begin
					if (sel = "00") then
						output <= input1;
					elsif (sel = "01") then
						output <= input2;
                    elsif (sel = "10"); then
                        output <= input3;
                    else
                        output <= "ZZZZZZZZZZZZZZ";     --Incase of error with selector bits
					end if;
			end process;
		end Behavioral;

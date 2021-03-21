library ieee;
use ieee.std_logic_1164.all;
	Entity Mux2to1_14bit is
		Port(sel : in std_logic;    --Selector bit
			input1 : in std_logic_vector(13 downto 0);  --Input signal 1
			input2 : in std_logic_vector(13 downto 0);  --Input signal 2
			output : out std_logic_vector(13 downto 0));    --Output signal
	end Mux2to1_14bit;
	
	Architecture Behavioral of Mux2to1_14bit is
		begin
			process(input1, input2)
				begin
					if (sel = '0') then
						output <= input1;
					elsif (sel = '1') then
						output <= input2;
					end if;
			end process;
		end Behavioral;

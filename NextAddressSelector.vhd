library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity next_address_Selector is 
	port (Inst		: IN std_logic_vector(23 downto 0);	-- 24 bits instruction
	      cond		: IN std_logic ;	                -- condition code in the instruction
	      LastInst	        : IN std_logic;				-- loop_end condition from the loop comparator
	      rs		: IN std_logic;
	      add_sel	        : OUT std_logic_vector(1 downto 0);
	      Clk 		: IN std_logic
);
end next_address_Selector;


architecture behav of next_address_Selector is 
begin
	process (rs, Inst, cond, LastInst, Clk)		
		variable s : std_logic_vector(1 downto 0) ;		
		begin
		if (Clk'event and Clk = '1' and rs = '1') then
			s := "00"; 
	    elsif (Clk'event and Clk = '1' and Inst(23 downto 19) = "00011") then -- Conditional Jump
			if (cond = '1') then
				s := "11" ; 	-- select the address from the IR
			else
				s := "10" ;	-- select from the pc incrementer
			end if;
		-- if the instruction is a conditional return
			
		elsif (Clk'event and Clk = '1' and Inst(23 downto 18) = "000101" and LastInst = '1') then

				if (cond = '1') then
					s := "10" ; -- select from the pc incrementer, end the loop
				else
					s := "01" ; -- select from the pc stack, start the loop again						
				end if;
				-- other 
                   --end if;
		elsif (Clk'event and Clk = '1') then
			s := "10" ; -- select from the pc incrementer
		end if;
		add_sel <= s; -- output the result
	end process;
end behav;



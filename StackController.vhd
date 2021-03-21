library ieee;
use ieee.std_logic_1164.all;

entity Stack_Controller is
port (	clk : in std_logic;  --Main clock
        reset : in std_logic;    --Reset switch
        PMD : in std_logic_vector(23 downto 0);     --Instruction from PMD line
        pop_stacks : in std_logic;    --Loop condition tested
        push : out std_logic_vector(1 downto 0);    --Push signals for stacks
        pop : out std_logic_vector(1 downto 0);     --Pop signals for stacks
        rs : out std_logic_vector(1 downto 0);      --Reset signals for stacks
end Stack_Controller;

architecture behav of Stack_Controller is 
begin
    process(clk)
        begin
            if(reset = '1') then
                push <= "00";
                pop <= "00";
                rs <= "00";
            elsif (PMD(23 downto 18) = "000101") then
                push <= "11";
                pop <= "00";
                rs <= "00";
            elsif (pop_stacks = '1') then
                push <= "00";
                pop <= "11";
                rs <= "00";                
            else
                push <= "00";
                pop <= "00";
                rs <= "00";
            end if;
        end process;
    end behav;
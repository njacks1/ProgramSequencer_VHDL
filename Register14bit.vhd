library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Register16 is
  Port(
    clk : in STD_LOGIC;
    load : in STD_LOGIC;    --Make sure this is hard coded to be 1
    reset : in STD_LOGIC;
    input : in STD_LOGIC_VECTOR(13 downto 0);
    output : out STD_LOGIC_VECTOR(13 downto 0));
end Register16;

architecture Behavioral of Register16 is
Signal storage : STD_LOGIC_VECTOR(13 downto 0);
begin
  process(clk, input, load, reset)
  begin
    if(reset = '0') then
        if(load = '1' and Clk'event and Clk = '1') then 
            storage <= input;
        elsif(Clk'event and Clk = '0') then
            output <= storage;
        end if;
    else
        storage = "00000000000000";
        output = "ZZZZZZZZZZZZZZ";  --Could possibly need this to be 0 rather than high impedance
    end if;
  end process;
end Behavioral;
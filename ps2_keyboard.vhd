library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity ps2_keyboard is
    GENERIC(
     clk_freq              : INTEGER;  --system clock frequency in Hz
     debounce_counter_size : INTEGER); --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
    Port ( clk : in STD_LOGIC;  --system clock input
           ps2_clk : in STD_LOGIC;  --clock signal from PS2 keyboard
           ps2_data : in STD_LOGIC; --data signal from PS2 keyboard
           ps2_code_new : out STD_LOGIC;    --flag that new PS/2 code is available on ps2_code bus
           ps2_code : out STD_LOGIC_VECTOR (7 downto 0));  --code received from PS/2
end ps2_keyboard;
architecture Behavioral of ps2_keyboard is

signal counter: integer:=0;

begin
process(ps2_clk)
begin
    if(falling_edge(ps2_clk))then
        if(counter>0 and counter <9 )then
            ps2_code(counter-1)<=ps2_data;
        elsif (counter=10)then
            counter<=0;
        end if;
        if(counter>=8) then
            ps2_code_new<='1';
       else
            ps2_code_new<='0';
       end if;
       counter<=counter+1;
    end if;
end process;
end Behavioral;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/01/2023 11:33:12 AM
-- Design Name: 
-- Module Name: clk_expander - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_expander is
    generic (
        T : integer :=20
    );
    Port ( clk : in std_logic;
           input : in STD_LOGIC_VECTOR(7 downto 0);
           valid : in std_logic;
           output : out STD_LOGIC_VECTOR(7 downto 0);
           valid_out : out std_logic
           );
end clk_expander;

architecture Behavioral of clk_expander is
signal c: integer :=0;
constant IDLE : std_logic_vector(1 downto 0):="00";
constant expand_state : std_logic_vector(1 downto 0):="10";
signal state : std_logic_vector(1 downto 0) := IDLE;
begin
process(clk)begin
if(rising_edge(clk)) then
    if(state=IDLE and valid='1') then
        state<=expand_state;
        output<=input;
        valid_out<='1';
    elsif(state=expand_state and c<T)then
        c<=c+1;
    elsif(state=expand_state and c>=T) then
        state<=IDLE;
        valid_out<='0';
        c<=0;
    end if;
end if;
end process;

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/18/2023 09:16:47 PM
-- Design Name: 
-- Module Name: Network_testbench - Behavioral
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

entity Network_testbench is
--  Port ( );
end Network_testbench;

architecture Behavioral of Network_testbench is
component NetworkOnChip is
Port ( 
        clk : in std_logic;
        Tx_00_self,Tx_01_self,Tx_10_self,Tx_11_self : out std_logic_vector(7 downto 0);
        Tx_00_self_valid,Tx_01_self_valid,Tx_10_self_valid,Tx_11_self_valid : out std_logic;
        Rx_00_self,Rx_01_self,Rx_10_self,Rx_11_self : in std_logic_vector(7 downto 0);
        Rx_00_self_valid,Rx_01_self_valid,Rx_10_self_valid,Rx_11_self_valid : in std_logic
);
end component;
signal Tx_00_self,Tx_01_self,Tx_10_self,Tx_11_self : std_logic_vector(7 downto 0);
signal Tx_00_self_valid,Tx_01_self_valid,Tx_10_self_valid,Tx_11_self_valid : std_logic;
signal Rx_00_self,Rx_01_self,Rx_10_self,Rx_11_self : std_logic_vector(7 downto 0);
signal Rx_00_self_valid,Rx_01_self_valid,Rx_10_self_valid,Rx_11_self_valid : std_logic;
signal clk : std_logic;
begin
Network: NetworkOnChip port map(clk,
Tx_00_self,Tx_01_self,Tx_10_self,Tx_11_self,
Tx_00_self_valid,Tx_01_self_valid,Tx_10_self_valid,Tx_11_self_valid,
Rx_00_self,Rx_01_self,Rx_10_self,Rx_11_self,
Rx_00_self_valid,Rx_01_self_valid,Rx_10_self_valid,Rx_11_self_valid
);
process begin
    clk<='0'; wait for 10 ns;
    clk<='1'; wait for 10 ns;
end process;
process begin
    Rx_00_self_valid<='0'; wait for 40 ns;
    Rx_00_self<="10001001"; Rx_00_self_valid<='1'; wait for 5*80 ns;
        Rx_00_self<="00000000"; Rx_00_self_valid<='0'; wait for 5*80 ns;
    Rx_00_self<="01011000"; Rx_00_self_valid<='1'; wait for 5*80 ns;
        Rx_00_self<="00000000"; Rx_00_self_valid<='0'; wait for 5*80 ns;
    Rx_00_self<="01001110"; Rx_00_self_valid<='1'; wait for 5*80 ns;
        Rx_00_self<="00000000"; Rx_00_self_valid<='0'; wait for 5*80 ns;
    Rx_00_self<="01111111"; Rx_00_self_valid<='1'; wait for 5*80 ns;
        Rx_00_self<="00000000"; Rx_00_self_valid<='0'; wait for 5*80 ns;
    Rx_00_self<="01011000"; Rx_00_self_valid<='1'; wait for 5*80 ns;
        Rx_00_self<="00000000"; Rx_00_self_valid<='0'; wait for 5*80 ns;
    wait;
end process;
end Behavioral;

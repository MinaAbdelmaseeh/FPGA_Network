----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/18/2023 08:02:28 PM
-- Design Name: 
-- Module Name: NetworkOnChip - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NetworkOnChip is
Port (  
        clk : std_logic;
        Tx_00_self,Tx_01_self,Tx_10_self,Tx_11_self : out std_logic_vector(7 downto 0);
        Tx_00_self_valid,Tx_01_self_valid,Tx_10_self_valid,Tx_11_self_valid : out std_logic;
        Rx_00_self,Rx_01_self,Rx_10_self,Rx_11_self : in std_logic_vector(7 downto 0);
        Rx_00_self_valid,Rx_01_self_valid,Rx_10_self_valid,Rx_11_self_valid : in std_logic
);
end NetworkOnChip;

architecture Behavioral of NetworkOnChip is
component router is
    generic(
        RESERVE_PATH :unsigned(1 downto 0):="10";
        RELEASE_PATH : unsigned(7 downto 0):="01111111";
        ACK : unsigned(7 downto 0) := "11000000";
        SELF_X : unsigned(2 downto 0);
        SELF_Y : unsigned(2 downto 0)
      );
    Port ( clk : in STD_LOGIC;
           Tx_up,Tx_down,Tx_left,Tx_right,Tx_self : out STD_LOGIC_VECTOR (7 downto 0);
           Tx_valid : out std_logic_vector(4 downto 0);
           Rx_up,Rx_down,Rx_left,Rx_right,Rx_self : in STD_LOGIC_VECTOR (7 downto 0);
           Rx_valid : in std_logic_vector(4 downto 0));

end component;
signal Tx_00_up,Tx_00_down,Tx_00_left,Tx_00_right : std_logic_vector(7 downto 0);
signal Tx_01_up,Tx_01_down,Tx_01_left,Tx_01_right : std_logic_vector(7 downto 0);
signal Tx_10_up,Tx_10_down,Tx_10_left,Tx_10_right : std_logic_vector(7 downto 0);
signal Tx_11_up,Tx_11_down,Tx_11_left,Tx_11_right : std_logic_vector(7 downto 0);

signal Rx_00_up,Rx_00_down,Rx_00_left,Rx_00_right : std_logic_vector(7 downto 0);
signal Rx_01_up,Rx_01_down,Rx_01_left,Rx_01_right : std_logic_vector(7 downto 0);
signal Rx_10_up,Rx_10_down,Rx_10_left,Rx_10_right : std_logic_vector(7 downto 0);
signal Rx_11_up,Rx_11_down,Rx_11_left,Rx_11_right : std_logic_vector(7 downto 0);

signal Tx_00_valid,Tx_01_valid,Tx_10_valid,Tx_11_valid : std_logic_vector(4 downto 0);
signal Rx_00_valid,Rx_01_valid,Rx_10_valid,Rx_11_valid : std_logic_vector(4 downto 0);
begin
router_00: router generic map(SELF_X=>"000", SELF_Y=>"000") port map(clk,Tx_00_up,Tx_00_down,Tx_00_left,Tx_00_right,Tx_00_self,Tx_00_valid,Rx_00_up,Rx_00_down,Rx_00_left,Rx_00_right,Rx_00_self,Rx_00_valid);
router_01: router generic map(SELF_X=>"001", SELF_Y=>"000") port map(clk,Tx_01_up,Tx_01_down,Tx_01_left,Tx_01_right,Tx_01_self,Tx_01_valid,Rx_01_up,Rx_01_down,Rx_01_left,Rx_01_right,Rx_01_self,Rx_01_valid);
router_10: router generic map(SELF_X=>"000", SELF_Y=>"001") port map(clk,Tx_10_up,Tx_10_down,Tx_10_left,Tx_10_right,Tx_10_self,Tx_10_valid,Rx_10_up,Rx_10_down,Rx_10_left,Rx_10_right,Rx_10_self,Rx_10_valid);
router_11: router generic map(SELF_X=>"001", SELF_Y=>"001") port map(clk,Tx_11_up,Tx_11_down,Tx_11_left,Tx_11_right,Tx_11_self,Tx_11_valid,Rx_11_up,Rx_11_down,Rx_11_left,Rx_11_right,Rx_11_self,Rx_11_valid);

Rx_01_left<=Tx_00_right; Rx_00_right<=Tx_01_left;
Rx_01_valid(2)<=Tx_00_valid(3); Rx_00_valid(3)<=Tx_01_valid(2);
Rx_10_down<=Tx_00_up; Rx_00_up<=Tx_01_down;
Rx_10_valid(1)<=Tx_00_valid(0); Rx_00_valid(0)<=Tx_01_valid(1);
Rx_11_left<=Tx_10_right; Rx_10_right<=Tx_11_left;
Rx_11_valid(2)<=Tx_10_valid(3); Rx_10_valid(3)<=Tx_11_valid(2);
Rx_11_up<=Tx_01_down; Rx_01_down<=Tx_11_up;
Rx_11_valid(0)<=Tx_01_valid(1); Rx_01_valid(1)<=Tx_11_valid(0);

----
Tx_00_self_valid<=Tx_00_valid(4);
Tx_01_self_valid<=Tx_01_valid(4);
Tx_10_self_valid<=Tx_10_valid(4);
Tx_11_self_valid<=Tx_11_valid(4);
-----------
Rx_00_valid(4)<=Rx_00_self_valid;
Rx_01_valid(4)<=Rx_01_self_valid;
Rx_10_valid(4)<=Rx_10_self_valid;
Rx_11_valid(4)<=Rx_11_self_valid;

-----------

end Behavioral;

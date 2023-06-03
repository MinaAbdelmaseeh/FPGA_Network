----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/02/2023 05:14:58 PM
-- Design Name: 
-- Module Name: network_on_chip - Behavioral
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

entity network_on_chip is
  Port (Rx : in std_logic;
        Tx : out std_logic;
        sw : in std_logic_vector(1 downto 0);
        clk : in std_logic
        );
end network_on_chip;

architecture Behavioral of network_on_chip is
component Node is
    generic (
        SELF_X : unsigned(2 downto 0) :="000";
        SELF_Y : unsigned(2 downto 0) :="000"
        );
    Port ( Tx_up,Tx_down,Tx_left,Tx_right : out STD_LOGIC;
           Rx_up,Rx_down,Rx_left,Rx_right : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

signal Tx_up00,Tx_down00,Rx_up00,Rx_down00,Tx_left00,Tx_right00,Rx_left00,Rx_right00 : std_logic;
signal Tx_up01,Tx_down01,Rx_up01,Rx_down01,Tx_left01,Tx_right01,Rx_left01,Rx_right01 : std_logic;
signal Tx_up10,Tx_down10,Rx_up10,Rx_down10,Tx_left10,Tx_right10,Rx_left10,Rx_right10 : std_logic;
signal Tx_up11,Tx_down11,Rx_up11,Rx_down11,Tx_left11,Tx_right11,Rx_left11,Rx_right11 : std_logic;

signal input_data : std_logic_vector(7 downto 0);
begin

rr11: Node generic map(SELF_X=>"001", SELF_Y=>"001") port map(Tx_up00, Tx_down00 ,Tx_left00,Tx_right00,Rx_up00,Rx_down00,Rx_left00,Rx_right00,clk);
--rr12: Node generic map(SELF_X=>"001", SELF_Y=>"010") port map(Tx_up01, Tx_down01 ,Tx_left01,Tx_right01,Rx_up01,Rx_down01,Rx_left01,Rx_right01,clk);
--rr21: Node generic map(SELF_X=>"010", SELF_Y=>"001") port map(Tx_up10, Tx_down10 ,Tx_left10,Tx_right10,Rx_up10,Rx_down10,Rx_left10,Rx_right10,clk);
--rr22: Node generic map(SELF_X=>"010", SELF_Y=>"010") port map(Tx_up11, Tx_down11 ,Tx_left11,Tx_right11,Rx_up11,Rx_down11,Rx_left11,Rx_right11,clk);
Rx_right00<=Tx_left10; Rx_left10<=Tx_right00;
Rx_right01<=Tx_left11; Rx_left11<=Tx_right01;

Rx_up00<=Tx_down01; Rx_down01<=Tx_up00;
Rx_up10<=Tx_down11; Rx_down11<=Tx_up10;

Rx_left00<=Rx;
Tx<=Tx_up00 when (sw="00")else
    Tx_down00 when (sw="01") else
    Tx_left00 when (sw="10") else
    Tx_right00;
end Behavioral;

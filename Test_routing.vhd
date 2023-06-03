----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/01/2023 09:11:21 AM
-- Design Name: 
-- Module Name: Test_routing - Behavioral
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

entity Test_routing is
    Port ( Tx_up,Tx_down,Tx_left,Tx_right : out STD_LOGIC;
           Rx_up,Rx_down,Rx_left,Rx_right : in STD_LOGIC;
           clk : in STD_LOGIC);
end Test_routing;

architecture Behavioral of Test_routing is
component router is
    generic(
        RESERVE_PATH :unsigned(1 downto 0):="10";
        RELEASE_PATH : unsigned(7 downto 0):="01111111";
        ACK : unsigned(7 downto 0) := "11000000";
        SELF_X : unsigned(2 downto 0):="000";
        SELF_Y : unsigned(2 downto 0):="000"
      );
    Port ( clk : in STD_LOGIC;
           Tx_up,Tx_down,Tx_left,Tx_right,Tx_self : out STD_LOGIC_VECTOR (7 downto 0) := "00000000";
           Tx_valid : out std_logic_vector(4 downto 0) :="00000";
           Rx_up,Rx_down,Rx_left,Rx_right,Rx_self : in STD_LOGIC_VECTOR (7 downto 0);
           Rx_valid : in std_logic_vector(4 downto 0));

end component;
component UART_RX is
    generic(
        baud_rate : integer := 9600
    );
    Port (clk : in std_logic;
          Rx : in STD_LOGIC;
          Rx_data : out std_logic_vector(7 downto 0);
          data_valid : out std_logic
          );
end component;
component UART_Tx is
    generic(
        baud_rate : integer := 9600
    );
    Port ( data_in : in STD_LOGIC_VECTOR (7 downto 0);
           data_valid : in STD_LOGIC;
           Tx,Tx_BUSY : out STD_LOGIC;
           clk : in STD_LOGIC);
end component;
component clk_expander is
    generic (
        T : integer :=20
    );
    Port ( clk : in std_logic;
           input : in STD_LOGIC_VECTOR(7 downto 0);
           valid : in std_logic;
           output : out STD_LOGIC_VECTOR(7 downto 0);
           valid_out : out std_logic
           );
end component;
constant SELF_X : unsigned(2 downto 0):="000";
constant SELF_y : unsigned(2 downto 0):="000";

signal Tx_valid,Rx_valid,Rx_valid_expanded: std_logic_vector(4 downto 0):="00000";
signal Tx_up_d,Tx_down_d,Tx_left_d,Tx_right_d,Rx_up_d,Rx_down_d,Rx_left_d,Rx_right_d: std_logic_vector(7 downto 0):="00000000";
signal Tx_up_d_expanded,Tx_down_d_expanded,Tx_left_d_expanded,Tx_right_d_expanded,Rx_up_d_expanded,Rx_down_d_expanded,Rx_left_d_expanded,Rx_right_d_expanded: std_logic_vector(7 downto 0):="00000000";

begin
router_00: router generic map(SELF_X=>SELF_X, SELF_Y=>S) port map(clk,Tx_up_d,Tx_down_d,Tx_left_d,Tx_right_d,open,Tx_valid,Rx_up_d,Rx_down_d,Rx_left_d_expanded,Rx_right_d_expanded,"00000000",Rx_valid_expanded);
Rx_valid(4)<='0'; -- no self

--UART_RX_up: UART_Rx generic map(baud_rate=>9600) port map(
--    Rx=>Rx_up,
--    Rx_data=>Rx_up_d,
--    data_valid=>Rx_valid(0),
--    clk=>clk
--);
--UART_RX_down: UART_Rx generic map(baud_rate=>9600) port map(
--    Rx=>Rx_down,
--    Rx_data=>Rx_down_d,
--    data_valid=>Rx_valid(1),
--    clk=>clk
--);
clk_expander_left_Rx: clk_expander port map (clk,Rx_left_d,Rx_valid(2),Rx_left_d_expanded,Rx_valid_expanded(2));

UART_RX_left: UART_Rx generic map(baud_rate=>9600) port map(
    Rx=>Rx_left,
    Rx_data=>Rx_left_d,
    data_valid=>Rx_valid(2),
    clk=>clk
);
clk_expander_right_Rx: clk_expander port map (clk,Rx_right_d,Rx_valid(3),Rx_right_d_expanded,Rx_valid_expanded(3));

UART_RX_right: UART_Rx generic map(baud_rate=>9600) port map(
    Rx=>Rx_right,
    Rx_data=>Rx_right_d,
    data_valid=>Rx_valid(3),
    clk=>clk
);
--------------- UART_Tx -------------------------------------
--UART_Tx_up: UART_Tx generic map(baud_rate=>9600) port map(
--    Tx=>Tx_up,
--    data_in=>Tx_up_d,
--    data_valid=>Tx_valid(0),
--    Tx_BUSY=> open,
--    clk=>clk
--);
--UART_Tx_down: UART_Tx generic map(baud_rate=>9600) port map(
--    Tx=>Tx_down,
--    data_in=>Tx_down_d,
--    data_valid=>Tx_valid(1),
--    Tx_BUSY=> open,
--    clk=>clk
--);
UART_Tx_left: UART_Tx generic map(baud_rate=>9600) port map(
    Tx=>Tx_left,
    data_in=>Tx_left_d,
    data_valid=>Tx_valid(2),
    Tx_BUSY=> open,
    clk=>clk
);
UART_Tx_right: UART_Tx generic map(baud_rate=>9600) port map(
    Tx=>Tx_right,
    data_in=>Tx_right_d,
    data_valid=>Tx_valid(3),
    Tx_BUSY=> open,
    clk=>clk
);


end Behavioral;

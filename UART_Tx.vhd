----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2023 01:40:14 AM
-- Design Name: 
-- Module Name: UART_Tx - Behavioral
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

entity UART_Tx is
    generic(
        baud_rate : integer := 9600
    );
    Port ( data_in : in STD_LOGIC_VECTOR (7 downto 0);
           data_valid : in STD_LOGIC;
           Tx : out STD_LOGIC:='1';
           Tx_BUSY : out STD_LOGIC:='0';
           clk : in STD_LOGIC);
end UART_Tx;

architecture Behavioral of UART_Tx is
signal uart_clk,reset_counter : std_logic := '0';
constant FPGA_clk : integer := 100_000_000; -- 100 MHz
constant c_max : integer := FPGA_clk / baud_rate;
signal counter : integer := 0;
signal data_in_d : std_logic_vector(7 downto 0);
constant IDLE : unsigned(3 downto 0) := "1000";
constant START : unsigned(3 downto 0) := "1001";
constant STOP : unsigned(3 downto 0) := "1011";

signal state : unsigned(3 downto 0):=IDLE;

begin
process(data_valid,clk,state,counter)
begin
        if(rising_edge(clk)) then
            if(state=IDLE and data_valid='1') then
                state<=START;
                data_in_d<=data_in;
                counter<=0;
                Tx<='0';
                Tx_Busy<='1';
            elsif(state=IDLE and data_valid='0') then
                Tx<='1';
                Tx_Busy<='0';
                
            elsif(state=START and counter<c_max) then
                counter<= counter +1;
                Tx<='0';  
            elsif(state=START and counter=c_max) then
                state<="0000";
                Tx<=data_in_d(0);
                counter<=0;
            elsif(state<"0111" and counter<c_max) then
                counter<= counter + 1;
                Tx<=data_in_d(to_integer(state));
            elsif(state<"0111" and counter=c_max)then
                state<=state + 1;
                counter<=0;
                Tx<=data_in_d(to_integer(state));
            elsif(state="0111" and counter<c_max) then
                counter<=counter + 1;
                Tx<=data_in_d(to_integer(state));
            elsif(state="0111" and counter=c_max) then
                state<=STOP;
                counter<=0;
                Tx<='1';
            elsif(state=STOP and counter<c_max)then
                counter<=counter + 1;
            elsif(state=STOP and counter=c_max) then
                state<=IDLE;
                Tx<='1';
                Tx_BUSY<='0';
                
                counter<=0;
            else
                Tx<='1';
                
                state<=IDLE;
                counter<=0;
            end if;
        end if;

end process;


end Behavioral;

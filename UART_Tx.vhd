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
           Tx,Tx_BUSY : out STD_LOGIC;
           clk : in STD_LOGIC);
end UART_Tx;

architecture Behavioral of UART_Tx is
signal uart_clk,reset_counter : std_logic := '0';
constant FPGA_clk : integer := 100_000_000; -- 100 MHz
constant c_max : integer := FPGA_clk / baud_rate;
signal counter : integer := 0;

constant IDLE : unsigned(3 downto 0) := "1000";
constant START : unsigned(3 downto 0) := "1001";
constant STOP : unsigned(3 downto 0) := "1011";

signal state : unsigned(3 downto 0):=IDLE;

begin

process(reset_counter,clk)
begin
    if(reset_counter='1') then
        counter<=0;
        uart_clk<='0';
    elsif(rising_edge(clk)) then
        if(counter+1=c_max/2) then
            counter<= 0;
            uart_clk<= not uart_clk;
        else
            counter<= counter + 1;
        end if;
    end if;
end process;

process(data_valid,uart_clk,state)
begin
        if(rising_edge(uart_clk)) then
            if(state=IDLE and data_valid='1') then
                state<=START;
            elsif(state=START) then
                state<="0000";
            elsif(state<"0111")then
                state<=state + 1;
            elsif(state="0111") then
                state<=STOP;
            elsif(state=STOP) then
                state<=IDLE;
            else
                state<=IDLE;
            end if;
        end if;

end process;

process(state,data_in) begin
    if(state=IDLE)then
        reset_counter<='0';
        TX<='1';
        Tx_BUSY<='0';
    elsif(state=START) then
        reset_counter<='0';
        TX<='0';
        Tx_BUSY<='1';
    elsif(state<="0111") then
        reset_counter<='0';
        Tx_BUSY<='1';
        TX<=data_in(to_integer(state));
    elsif(state=STOP) then
        reset_counter<='0';
        Tx_BUSY<='1';
        TX<='1';
    else
        -- not a case
        Tx_Busy<='0';
        Tx<='1';
        reset_counter<='0';
    end if;
end process;
end Behavioral;

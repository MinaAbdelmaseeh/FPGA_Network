----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2023 09:49:14 AM
-- Design Name: 
-- Module Name: UART_RX - Behavioral
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

entity UART_RX is
    generic(
        baud_rate : integer := 9600
    );
    Port (clk : in std_logic;
          Rx : in STD_LOGIC;
          Rx_data : out std_logic_vector(7 downto 0);
          data_valid : out std_logic
          );
end UART_RX;

architecture Behavioral of UART_RX is

signal uart_clk,reset_counter : std_logic;
constant FPGA_clk : integer := 100_000_000; -- 100 MHz
constant c_max : integer := FPGA_clk / baud_rate;
signal counter : integer := 0;
signal wait_counter : integer := 0;

constant IDLE : unsigned(3 downto 0) := "1000";
constant GO_TO_MIDDLE : unsigned(3 downto 0) := "1100";
constant START : unsigned(3 downto 0) := "1101";
constant STOP : unsigned(3 downto 0) := "1111";
signal start_flag : std_logic:='0';
signal state : unsigned(3 downto 0):=IDLE;

begin
-- generate uart_clk
process(reset_counter,clk)
begin
    if(reset_counter='1') then
        counter<=0;
--        uart_clk<='0';
    elsif(rising_edge(clk)) then
        if(counter+1=c_max) then
            counter<= 0;
            --uart_clk<= not uart_clk;
        else
            counter<= counter + 1;
        end if;
    end if;
end process;

-- UART
process(Rx,uart_clk,clk,state)
begin
    if(rising_edge(clk)) then
        if(state=IDLE and Rx='0') then
            --reset_counter<='1';
            state<=GO_TO_MIDDLE;
            wait_counter<=0;
        elsif(state=GO_TO_MIDDLE) then
            if(wait_counter=c_max/4) then
                wait_counter<=0;
                state<=START; -- read bit 0
            else
                wait_counter<=wait_counter + 1;
            end if;
        elsif(state=START and counter=c_max-1) then
            state<="0000";
        elsif(state<"0111") then
            if(counter=0)then
                Rx_data(to_integer(state))<=Rx;
            elsif(counter=c_max-1)then
                state<=state + 1;
            end if;
        elsif(state="0111") then
            if(counter=0)then
                Rx_data(to_integer(state))<=Rx;
            elsif(counter=c_max-1)then
                state<=STOP;
            end if;
        --else
            --state<=IDLE;
        elsif(state=STOP) then
            if(counter=0) then
                state<= IDLE;
            end if;
        end if;
    end if;
    
end process;
process(state)
begin
    if(state=IDLE) then
        data_valid<='0';
        reset_counter<='1';
    elsif(state=GO_TO_MIDDLE) then
        data_valid<='0';
        reset_counter<='1';
    elsif(state=START) then
        data_valid<='0';
        reset_counter<='0'; -- start the uart_clk
    elsif(state<"0111") then
        reset_counter<='0';
        data_valid<='0';
    elsif(state="0111") then
        reset_counter<='0';
--        Rx_data(to_integer(state))<=Rx;
        data_valid<='0';  
    elsif(state<=STOP) then
        reset_counter<='0';
        data_valid<='1';
    else
        -- do nothing -- forbidden states
        data_valid<='0';
        reset_counter<='1';
    end if;
end process;
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2023 10:39:52 AM
-- Design Name: 
-- Module Name: FIFO - Behavioral
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

entity FIFO_2 is
  generic(
    NBITS: integer := 10
  );
  Port (
    clk : in std_logic;
    FIFO_in : in std_logic_vector(7 downto 0);
    FIFO_out : out std_logic_vector(7 downto 0);
    full : out std_logic := '0';
    empty : out std_logic :='1';
    push,pop : in std_logic
  );
end FIFO_2;

architecture Behavioral of FIFO_2 is
signal read_ptr , write_ptr,read_ptr_prev , write_ptr_prev : unsigned(NBITS-1 downto 0) := to_unsigned(0,NBITS);
type arr is array (0 to ( (2**NBITS) - 1)) of std_logic_vector(7 downto 0);
signal full_d,full_curr : std_logic:='0';
signal empty_d,empty_curr : std_logic:='1';

signal fifo : arr;
signal push_pop : std_logic;
begin
full<=full_d;
empty<= empty_d;
process(read_ptr,write_ptr,read_ptr_prev,write_ptr_prev)
begin
        if(read_ptr=write_ptr) then            -- empty or full
            if(read_ptr_prev>write_ptr_prev) then
                -- push operation occured
                full_curr<='1';
                empty_curr<='0';
            elsif(read_ptr_prev<write_ptr_prev) then
                -- pop operation occured
                empty_curr<='1';
                full_curr<='0';                
            else
                empty_curr<=empty_d;
                full_curr<=full_d;
            end if;
        else
            empty_curr<='0';
            full_curr<='0';
        end if;
end process;
process(push,pop,clk)
begin
    if(rising_edge(clk)) then
    
        if(read_ptr=write_ptr) then            -- empty or full
            if(read_ptr_prev>write_ptr_prev) then
                -- push operation occured
                full_d<='1';
                empty_d<='0';
            elsif(read_ptr_prev<write_ptr_prev) then
                -- pop operation occured
                empty_d<='1';
                full_d<='0';                
            end if;
        else
            empty_d<='0';
            full_d<='0';
        end if;
    
        FIFO_out<=fifo(to_integer(read_ptr));
        if(push='1' and pop='1') then
            if(full_curr='0') then
                write_ptr<=write_ptr + 1;
                fifo(to_integer(write_ptr))<=std_logic_vector(fifo_in);
            end if;
            if(empty_curr='0') then
                read_ptr<=read_ptr + 1;
            end if;
            
            write_ptr_prev<=write_ptr;
            read_ptr_prev<=read_ptr;
        elsif(push = '1') then
            if(full_curr='0') then
                write_ptr<=write_ptr + 1;
                fifo(to_integer(write_ptr))<=std_logic_vector(fifo_in);
            end if;
            write_ptr_prev<=write_ptr;
            read_ptr_prev<=read_ptr;
       elsif(pop='1') then
            if(empty_curr='0') then
                read_ptr<=read_ptr + 1;
            end if;
            write_ptr_prev<=write_ptr;
            read_ptr_prev<=read_ptr;
        end if;
    end if;
end process;

end Behavioral;

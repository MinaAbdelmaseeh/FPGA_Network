----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/15/2023 01:12:33 PM
-- Design Name: 
-- Module Name: KEYBOARD_VGA_INTERFACE - Behavioral
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

entity KEYBOARD_VGA_INTERFACE is
  Port (
        R,G,B : out std_logic_vector(3 downto 0);
        Hsync,Vsync : out std_logic;
        clk : in STD_LOGIC;  --system clock input
        ps2_clk : in STD_LOGIC;  --clock signal from PS2 keyboard
        ps2_data : in STD_LOGIC
  );
end KEYBOARD_VGA_INTERFACE;

architecture Behavioral of KEYBOARD_VGA_INTERFACE is
component ps2_keyboard_to_ascii IS
  GENERIC(
      clk_freq                  : INTEGER := 50_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 8);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
  PORT(
      clk        : IN  STD_LOGIC;                     --system clock input
      ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
      ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value
END component;

component VGA_writer is
    Port ( clk : in STD_LOGIC;
           Key_event : in STD_LOGIC;
           ASCII_in : in std_logic_vector(6 downto 0);
           R : out STD_LOGIC_VECTOR (3 downto 0);
           G : out STD_LOGIC_VECTOR (3 downto 0);
           B : out STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC);
end component;
signal ASCII_in : std_logic_vector(6 downto 0);
signal KEY_event : std_logic;
begin

ps2: ps2_keyboard_to_ascii generic map (
    clk_freq => 100_000_000,
    ps2_debounce_counter_size => 8
)port map(
    clk=>clk,
    ps2_clk=>ps2_clk,
    ps2_data=>ps2_data,
    ascii_new=> KEY_event,
    ascii_code=>ASCII_in
);
VGA: VGA_writer port map(
    clk=>clk,
    Key_event => KEY_event,
    ASCII_in => ASCII_in,
    R => R,
    G=> G,
    B=>B,
    Hsync=>Hsync,
    Vsync=>Vsync
);
end Behavioral;

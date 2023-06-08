----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/15/2023 07:19:39 AM
-- Design Name: 
-- Module Name: VGA_writer - Behavioral
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

entity VGA_writer is
    Port ( clk : in STD_LOGIC;
           Key_event : in STD_LOGIC;
           ASCII_in : in std_logic_vector(6 downto 0);
           R : out STD_LOGIC_VECTOR (3 downto 0);
           G : out STD_LOGIC_VECTOR (3 downto 0);
           B : out STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC);
end VGA_writer;

architecture Behavioral of VGA_writer is
component blk_mem_gen_0 IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component;
component VGA_Controller is
    Port ( clk : in STD_LOGIC;
           Rin,Gin,Bin : in std_logic_vector(3 downto 0);
            R : out std_logic_vector (3 downto 0);
            G : out std_logic_vector (3 downto 0);
            B : out std_logic_vector (3 downto 0);
            Hsync : out STD_LOGIC :='0'; -- initialized to  1
            Vsync : out STD_LOGIC :='0';
            clk_out : out std_logic;
            disp_flag : out std_logic;
            x, y,ram_index,col,row : out integer := 0
           );
end component;

component font_rom is
   port(
      clk: in std_logic;
      addr: in std_logic_vector(10 downto 0);
      data: out std_logic_vector(7 downto 0)
   );
end component;

constant DISPLAY_WIDTH : integer:= 640;
constant DISPLAY_HEIGHT : integer := 480;

constant CHAR_WIDTH : integer := 8;
constant CHAR_HEIGHT : integer := 16;

constant DISPLAY_LEFT_MARGIN : integer := 10;
constant DISPLAY_RIGHT_MARGIN : integer := 10;
constant DISPLAY_TOP_MARGIN : integer := 20;
constant DISPLAY_BOTTOM_MARGIN : integer := 20;

constant CHAR_SPACING : integer := 2;
constant LINE_SPACING : integer := 4;

constant CHARS_PER_ROW :integer := (DISPLAY_WIDTH)/(CHAR_WIDTH + CHAR_SPACING);
constant NUM_LINES :integer := (DISPLAY_HEIGHT-DISPLAY_TOP_MARGIN-DISPLAY_BOTTOM_MARGIN)/(CHAR_HEIGHT + LINE_SPACING);
constant MAX_CHARS : integer :=CHARS_PER_ROW*NUM_LINES;

signal Rin,Gin,Bin : STD_LOGIC_VECTOR(3 downto 0);
signal x,y : integer;
signal clk_out,disp_flag : STD_LOGIC;
signal char_out,char_out_rev : std_logic_vector(7 downto 0) := "00000000";
signal ASCII_out,ASCII_tmp : std_logic_vector(6 downto 0);
signal addr : std_logic_vector(10 downto 0);

signal writer_ram_in,writer_ram_out : std_logic_vector(7 downto 0);
signal writer_ram_ena : std_logic;
signal writer_ram_wea : std_logic_vector(0 downto 0);
signal writer_ram_addra : unsigned(10 downto 0);
signal ram_index : unsigned(10 downto 0);
signal ram_index_x,ram_index_y : unsigned(10 downto 0);

signal v_sync_t : std_logic;
--- KEY EVNET FSM
--signal key_event_state : std_logic_vector(1 downto 0) := "00";
--constant IDLE : std_logic_vector(1 downto 0) := "00";            -- 00  | idle
--constant ADD_CHAR_TO_RAM : std_logic_vector(1 downto 0) := "01";  -- 01  | add char to memory
--constant DEBOUNCE : std_logic_vector(1 downto 0) := "10";  -- 10  | debounce
--signal debounce_counter : integer := 0;
--signal debounce_flag : boolean :=false;

------------
signal pos,char_x,char_y,char_xx : integer := 0;
begin
Vsync<=v_sync_t;

VGA:
    VGA_Controller port map (
        clk => clk,
        Rin => Rin,
        Gin => Gin,
        Bin => Bin,
        R=> R,
        G=>G,
        B=>B,
        Hsync=>Hsync,
        Vsync=>v_sync_t,
        clk_out=>clk_out,
        disp_flag => disp_flag,
        x=>x,
        y=>y,
        ram_index=>pos,
        col=>char_x,
        row=>char_y
    );

writer_ram:  blk_mem_gen_0 port map(
    addra=> std_logic_vector(writer_ram_addra),
    dina=>writer_ram_in,
    douta=>writer_ram_out,
    ena=>'1',
    wea=>writer_ram_wea,
    clka=>clk    
);
ascii_rom:  font_rom port map(
        clk=>clk,
        addr=>addr,
        data=>char_out
    );
    
---------
--- KEY EVENT FSM
--process(clk,key_event_state,KEY_event,debounce_flag,clk)
--begin
--    if(key_event_state=IDLE and KEY_event='1') then
--        key_event_state<=DEBOUNCE;
--    elsif(key_event_state=ADD_CHAR_TO_RAM and clk='1') then
--        key_event_state<=DEBOUNCE;
--    elsif(key_event_state= DEBOUNCE and debounce_flag=false) then
--        key_event_state<=IDLE;
--    end if;
--end process;
ram_index<=to_unsigned(to_integer(ram_index_x) + to_integer(ram_index_y)*CHARS_PER_ROW , 11);

ASCII_tmp<="1101101";
process(clk)
variable key_flag: boolean :=false;
begin
    if(rising_edge(clk)) then
        if(Key_event = '0') then
            key_flag := false;
        elsif(Key_event='1') then
            if(key_flag=false) then
                key_flag:=true;
                if('0'&ASCII_in=x"0D")then -- enter
                        ram_index_x<=to_unsigned(0,11);
                        ram_index_y<=ram_index_y + 1;
                    elsif('0'&ASCII_in=x"08" and (ram_index-1)>=0)then -- backspace
                        if(ram_index_x=0) then
                            ram_index_x<=to_unsigned(CHARS_PER_ROW-1,11);
                            ram_index_y<=ram_index_y - 1;
                        else
                            ram_index_x<=ram_index_x- 1;
                        end if;
                    elsif('0'&ASCII_in=x"20") then -- space
                        if(ram_index_x + 1 = CHARS_PER_ROW) then
                            ram_index_x<=to_unsigned(0,11);
                            ram_index_y<=ram_index_y + 1;
                        else
                            ram_index_x<=ram_index_x+ 1;
                        end if;
                    else
                        --ram_index<=ram_index + 1;
                        
                        if(ram_index_x + 1 = CHARS_PER_ROW) then
                            ram_index_x<=to_unsigned(0,11);
                            ram_index_y<=ram_index_y + 1;
                        else
                            ram_index_x<=ram_index_x + 1;     
                        end if;
                    end if;
            end if;
        end if;
    end if;

end process;
writer_ram_in<= x"20" when ('0'&ASCII_in=x"0D") or ('0'&ASCII_in=x"08") else
                '0'&ASCII_in;
ASCII_out<= writer_ram_out(6 downto 0);

process(v_sync_t,ram_index,pos) 
begin
        if(v_sync_t='0') then
            -- write
            writer_ram_wea<="1";
            writer_ram_addra<=ram_index;
        else
            --read
            writer_ram_wea<="0";
            writer_ram_addra<= to_unsigned(pos,11);
        end if;        

    
end process;

-------------- VGA control --------------

--pos<= ((x-DISPLAY_LEFT_MARGIN)/(CHAR_WIDTH+CHAR_SPACING)) + ((y-DISPLAY_TOP_MARGIN)/(CHAR_HEIGHT+LINE_SPACING))*CHARS_PER_ROW when ((x>=DISPLAY_LEFT_MARGIN) and (y>=DISPLAY_TOP_MARGIN)) else 0;
--char_x<=  ((x-DISPLAY_LEFT_MARGIN) mod (CHAR_WIDTH+CHAR_SPACING)) when (x>=DISPLAY_LEFT_MARGIN) else 0;
--char_y<= ((y-DISPLAY_TOP_MARGIN) mod (CHAR_HEIGHT+LINE_SPACING)) when (y>=DISPLAY_TOP_MARGIN) else 0;
--ASCII_out<= writer_ram(pos) when pos<=MAX_CHARS else "0000000";

addr<= ASCII_out & std_logic_vector(to_unsigned(char_y,4));
char_out_rev(0) <= char_out(7);
char_out_rev(1) <= char_out(6);
char_out_rev(2) <= char_out(5);
char_out_rev(3) <= char_out(4);
char_out_rev(4) <= char_out(3);
char_out_rev(5) <= char_out(2);
char_out_rev(6) <= char_out(1);
char_out_rev(7) <= char_out(0);
Rin<= "1111" when (char_x<CHAR_WIDTH and char_y<CHAR_HEIGHT and pos<=ram_index and (char_out_rev(char_x) = '1')) else "0000";
Bin<= "1111" when (char_x<CHAR_WIDTH and char_y<CHAR_HEIGHT and pos<=ram_index and (char_out_rev(char_x) = '1')) else "0000";
Gin<= "1111" when (char_x<CHAR_WIDTH and char_y<CHAR_HEIGHT and pos<=ram_index and (char_out_rev(char_x) = '1')) else "0000";


end Behavioral;

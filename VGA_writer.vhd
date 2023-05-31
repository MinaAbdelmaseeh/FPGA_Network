

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;



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
            x, y : out integer := 0
           );
end component;

component font_rom is
   port(
      clk: in std_logic;
      addr: in std_logic_vector(10 downto 0);
      data: out std_logic_vector(7 downto 0)
   );
end component;
constant DISPLAY_WIDTH : integer := 640;
constant DISPLAY_HEIGHT : integer := 480;

constant CHAR_WIDTH : integer := 8;
constant CHAR_HEIGHT : integer := 16;

constant DISPLAY_LEFT_MARGIN : integer := 10;
constant DISPLAY_RIGHT_MARGIN : integer := 10;
constant DISPLAY_TOP_MARGIN : integer := 20;
constant DISPLAY_BOTTOM_MARGIN : integer := 20;

constant DEBOUNCE_MAX : integer :=5000;

constant CHAR_SPACING : integer := 2;
constant LINE_SPACING : integer := 4;

constant CHARS_PER_ROW :integer := (DISPLAY_WIDTH-DISPLAY_LEFT_MARGIN-DISPLAY_RIGHT_MARGIN)/(CHAR_WIDTH + CHAR_SPACING);
constant NUM_LINES :integer := (DISPLAY_HEIGHT-DISPLAY_TOP_MARGIN-DISPLAY_BOTTOM_MARGIN)/(CHAR_HEIGHT + LINE_SPACING);
constant MAX_CHARS : integer :=CHARS_PER_ROW*NUM_LINES;

type ram_type is array (0 to MAX_CHARS) of std_logic_vector(6 downto 0);
signal writer_ram : ram_type;
signal Rin,Gin,Bin : STD_LOGIC_VECTOR(3 downto 0);
signal x,y : integer;
signal clk_out,disp_flag : STD_LOGIC;
signal char_out : std_logic_vector(7 downto 0);
signal ASCII_out : std_logic_vector(6 downto 0);
signal addr : std_logic_vector(10 downto 0);
signal ram_index : integer := 4;

--- KEY EVNET FSM
--signal key_event_state : std_logic_vector(1 downto 0) := "00";
--constant IDLE : std_logic_vector(1 downto 0) := "00";            -- 00  | idle
--constant ADD_CHAR_TO_RAM : std_logic_vector(1 downto 0) := "01";  -- 01  | add char to memory
--constant DEBOUNCE : std_logic_vector(1 downto 0) := "10";  -- 10  | debounce
--signal debounce_counter : integer := 0;
--signal debounce_flag : boolean :=false;

------------
signal pos,char_x,char_y : integer := 0;
begin

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
        Vsync=>Vsync,
        clk_out=>clk_out,
        disp_flag => disp_flag,
        x=>x,
        y=>y
    );
ascii_rom:
    font_rom port map(
        clk=>clk,
        addr=>addr,
        data=>char_out
    );
    
    
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

--process(key_event_state,clk)
--begin
--    if(key_event_state=IDLE) then
--        -- do nothing
--    elsif(key_event_state=ADD_CHAR_TO_RAM) then
----        writer_ram(ram_index)<="0000110";
----        ram_index<=ram_index + 1;
--        debounce_flag<=true;
--    elsif(key_event_state=DEBOUNCE) then -- debounce counter
--        if(rising_edge(clk)) then
--            if(debounce_flag = true and debounce_counter <=DEBOUNCE_MAX) then
--                debounce_counter<=debounce_counter + 1;
--            elsif(debounce_flag = true) then
--                debounce_counter<=0;
--                debounce_flag<=false;
--            end if;
--        end if;

--    end if;
--end process;
-------------- VGA control --------------
writer_ram(0)<="1101101";
writer_ram(1)<="1101001";
writer_ram(2)<="1101110";
writer_ram(3)<="1100001";

pos<= ((x-DISPLAY_LEFT_MARGIN)/(CHAR_WIDTH+CHAR_SPACING)) + ((y-DISPLAY_TOP_MARGIN)/(CHAR_HEIGHT+LINE_SPACING))*CHARS_PER_ROW when (x-DISPLAY_LEFT_MARGIN)>=0 and (y-DISPLAY_TOP_MARGIN)>=0 else 0;
char_x<=  ((x-DISPLAY_LEFT_MARGIN) mod (CHAR_WIDTH+CHAR_SPACING));
char_y<= (y-DISPLAY_TOP_MARGIN) mod (CHAR_HEIGHT+LINE_SPACING);
ASCII_out<= writer_ram(pos) when pos<MAX_CHARS else "0000000";
addr<= ASCII_out & std_logic_vector(to_unsigned(char_y,4));
Rin<= "1111" when (char_x<CHAR_WIDTH and pos>=0 and  pos<ram_index and char_y<CHAR_HEIGHT and (char_out(char_x) = '1')  and x>=DISPLAY_LEFT_MARGIN and x<DISPLAY_WIDTH-DISPLAY_RIGHT_MARGIN and y>=DISPLAY_TOP_MARGIN and y<DISPLAY_HEIGHT-DISPLAY_BOTTOM_MARGIN) else "0000";
Bin<= "1111" when (char_x<CHAR_WIDTH and pos>=0 and  pos<ram_index and char_y<CHAR_HEIGHT and (char_out(char_x) = '1') and x>=DISPLAY_LEFT_MARGIN and x<DISPLAY_WIDTH-DISPLAY_RIGHT_MARGIN and y>=DISPLAY_TOP_MARGIN and y<DISPLAY_HEIGHT-DISPLAY_BOTTOM_MARGIN) else "0000";
Gin<= "1111" when (char_x<CHAR_WIDTH and pos>=0 and  pos<ram_index and char_y<CHAR_HEIGHT and (char_out(char_x) = '1') and  x>=DISPLAY_LEFT_MARGIN and x<DISPLAY_WIDTH-DISPLAY_RIGHT_MARGIN and y>=DISPLAY_TOP_MARGIN and y<DISPLAY_HEIGHT-DISPLAY_BOTTOM_MARGIN) else "0000";

end Behavioral;

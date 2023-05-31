library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Controller is
    Port ( clk : in STD_LOGIC;
           Rin,Gin,Bin : in std_logic_vector(3 downto 0);
           R : out std_logic_vector (3 downto 0);
           G : out std_logic_vector (3 downto 0);
           B : out std_logic_vector (3 downto 0);
           Hsync : out STD_LOGIC :='0'; -- initialized to  1
           Vsync : out STD_LOGIC :='0';
           clk_out : out std_logic;
           disp_flag : out std_logic;
           x, y : out integer := 1
           ); -- initialized to 1
end VGA_Controller;



architecture Behavioral of VGA_Controller is

    signal clk_50,clk_25: std_logic :='0';
    constant T_FP_H: integer :=16;
    constant T_BP_H: integer :=48;
    constant T_PW_H: integer :=96;
    constant T_DISP_H: integer :=640;
    constant T_S_H: integer :=800;

    constant T_FP_V: integer :=8000;
    constant T_BP_V: integer :=23200;
    constant T_PW_V: integer :=1600;
    constant T_DISP_V: integer :=384000;
    constant T_S_V: integer :=416800;
     
    signal display_start_v,display_start_h : STD_LOGIC :='0';
    signal signal_v : STD_LOGIC;
    signal xInt, yInt : integer := 0;
    
begin

disp_flag<= display_start_h and display_start_v;
clk_div:
        process(clk,clk_50)
        begin
        if(rising_edge(clk)) then
            clk_50<= not clk_50;
        end if;
        if(rising_edge(clk_50)) then
            clk_25<= not clk_25;
        end if;
        end process;
H_sync_generation:
        process(clk_25,display_start_h,display_start_v)
            variable counter : integer :=0;
        begin

            if(rising_edge(clk_25)) then
                 counter := counter + 1;
                 if(counter=T_PW_H) then
                     HSync<='1';
                 elsif(counter=T_PW_H+T_BP_H) then
                     display_start_h<='1';
--                     xInt <= xInt + 1;
                 elsif(counter=T_PW_H+T_BP_H+T_DISP_H) then
                     display_start_h<='0';
--                     xInt <= 1;
                 elsif(counter=T_S_H) then
                     Hsync<='0';
                     counter:=0;
                 end if;

--                 x <= xInt;
            end if;

        end process;        
process(clk_25, display_start_v, display_start_h) begin
    if(rising_edge(clk_25)) then 
        if(display_start_h='1' and display_start_v='1') then
             xInt<=(xInt +1);
        else
            xInt<=0;
        end if;
    end if;
    if(rising_edge(display_start_h) and display_start_v='1') then
        yInt<= (yInt + 1) mod 480;
    end if;
--    if(rising_edge(display_start_v)) then
--        yInt<=0;
--    end if;     
end process;
V_sync_generation:
    process(clk_25,display_start_v)
        variable counter : integer :=0;
    begin
        -- V Sync
        if(rising_edge(clk_25)) then
             counter := counter + 1;
             if(counter=T_BP_V) then
                 display_start_v<='1';
             elsif(counter=T_DISP_V+T_BP_V) then
                 display_start_v<='0';
             elsif(counter=T_BP_V+T_DISP_V + T_FP_V) then
                 VSync<='0';
             elsif(counter=T_BP_V+T_DISP_V + T_FP_V + T_PW_V) then
                 Vsync<='1';
                 counter:=0;
             end if;
        end if;

    end process;
        
x<=xInt;
y<=yInt; 
clk_out<=clk_25;
R<= Rin when (display_start_v='1' and display_start_h='1')
     else "0000";
G<= Gin when (display_start_v='1' and display_start_h='1' )
     else "0000";
B<= Bin when (display_start_v='1' and display_start_h='1')
     else "0000";
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2023 11:51:23 AM
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

-- EACH NODE has X,Y each is 3bit => max network nodes = 8*8=64 node
-- THE NETWROK can support upto 



entity Node is
    --RESERVE REQUEST PAYLOAD [10 - target_x(2b) - target_y(2b) - sender_id(2b) ]    
  generic(
    RESERVE_PATH :unsigned(1 downto 0):="10";
    RELEASE_PATH : unsigned(7 downto 0):="01111111";
    ACK : unsigned(7 downto 0) := "11000000";
    SELF_X : unsigned(2 downto 0);
    SELF_Y : unsigned(2 downto 0);
    ID : STD_LOGIC_VECTOR(1 downto 0)
  );
  Port (
    clk: in std_logic;
    X,Y : in std_logic_vector(2 downto 0);
    Rx_up,Rx_down,Rx_left,Rx_right : in std_logic;
    Tx_up,Tx_down,Tx_left,Tx_right : out std_logic
   );
end Node;

architecture Behavioral of Node is
component UART_Tx is
    generic(
    baud_rate : integer := 9600
    );
    Port ( data_in : in STD_LOGIC_VECTOR (7 downto 0);
       data_valid : in STD_LOGIC;
       Tx,Tx_BUSY : out STD_LOGIC;
       clk : in STD_LOGIC
    );
end component;

component UART_Rx is
    generic(
        baud_rate : integer := 9600
    );
    Port (clk : in std_logic;
        Rx : in STD_LOGIC;
        Rx_data : out std_logic_vector(7 downto 0);
        data_valid : out std_logic
    );
end component;
-- RX signals
signal Rx_data_valid : std_logic_vector(3 downto 0);
signal Rx_up_data,Rx_down_data,Rx_left_data,Rx_right_data : std_logic_vector(7 downto 0);
-- TX signals
signal Tx_up_data_valid,Tx_down_data_valid,Tx_left_data_valid,Tx_right_data_valid,Node_Tx_en : std_logic;
signal Tx_up_data_in,Tx_down_data_in,Tx_left_data_in,Tx_right_data_in,Node_Tx_data : std_logic_vector(7 downto 0);
signal Tx_up_busy,Tx_down_busy,Tx_right_busy,Tx_left_busy : std_logic;
------------------
signal Tx_assigned_Rx: unsigned(11 downto 0); -- each 3 bit represents the Rx port that the Tx port is connceted to (up,down,left,right,self)
signal Tx_assigned: std_logic_vector(4 downto 0); -- each bit represents whether Tx port is connected or not (up, down , left ,right,self)

----- first stage of process_pipeline
signal current_request : unsigned(7 downto 0);
signal curr_rx_port,request_rx_port : unsigned(2 downto 0);
signal request_rx_port_2 : std_logic_vector(4 downto 0);
signal request_rx_valid : std_logic;
signal router_match : std_logic_vector(4 downto 0);
signal router_match_opt : std_logic_vector(4 downto 0);
signal router_match_res : std_logic_vector(4 downto 0);
----- second stage of process pipeline
signal current_request_pipe2 : unsigned(7 downto 0);
signal curr_rx_port_pipe2,request_rx_port_pipe2 : unsigned(2 downto 0);
signal request_rx_port_2_pipe2 : std_logic_vector(4 downto 0);
signal request_rx_valid_pipe2 : std_logic;
signal router_match_pipe2 : std_logic_vector(4 downto 0);
signal router_match_opt_pipe2 : std_logic_vector(4 downto 0);
signal router_match_res_pipe2 : std_logic_vector(4 downto 0);


begin
------------------------------ UART RX --------------------------------------
UART_RX_up: UART_Rx generic map(baud_rate=>9600) port map(
    Rx=>Rx_up,
    Rx_data=>Rx_up_data,
    data_valid=>Rx_data_valid(0),
    clk=>clk
);
UART_RX_down: UART_Rx generic map(baud_rate=>9600) port map(
    Rx=>Rx_down,
    Rx_data=>Rx_down_data,
    data_valid=>Rx_data_valid(1),
    clk=>clk
);
UART_RX_left: UART_Rx generic map(baud_rate=>9600) port map(
    Rx=>Rx_left,
    Rx_data=>Rx_left_data,
    data_valid=>Rx_data_valid(2),
    clk=>clk
);
UART_RX_right: UART_Rx generic map(baud_rate=>9600) port map(
    Rx=>Rx_right,
    Rx_data=>Rx_right_data,
    data_valid=>Rx_data_valid(3),
    clk=>clk
);
--------------- UART_Tx -------------------------------------
UART_Tx_up: UART_Tx generic map(baud_rate=>9600) port map(
    Tx=>Tx_up,
    data_in=>Tx_up_data_in,
    data_valid=>Tx_up_data_valid,
    Tx_BUSY=> Tx_up_busy,
    clk=>clk
);
UART_Tx_down: UART_Tx generic map(baud_rate=>9600) port map(
    Tx=>Tx_down,
    data_in=>Tx_down_data_in,
    data_valid=>Tx_down_data_valid,
    Tx_BUSY=> Tx_down_busy,
    clk=>clk
);
UART_Tx_left: UART_Tx generic map(baud_rate=>9600) port map(
    Tx=>Tx_left,
    data_in=>Tx_left_data_in,
    data_valid=>Tx_left_data_valid,
    Tx_BUSY=> Tx_left_busy,
    clk=>clk
);
UART_Tx_right: UART_Tx generic map(baud_rate=>9600) port map(
    Tx=>Tx_right,
    data_in=>Tx_right_data_in,
    data_valid=>Tx_right_data_valid,
    Tx_BUSY=> Tx_right_busy,
    clk=>clk
);
-------------------------READ RX FSM -----------------
-- this FSM iterates over the 4 Rx ports to check the incoming data and process the requests
process(clk)begin
    if(rising_edge(clk)) then
        if(curr_rx_port="000") then -- reading up port
            if(Rx_data_valid(0)='1') then
                current_request<=unsigned(Rx_up_data);
                request_rx_port<=curr_rx_port;
                request_rx_port_2<="00001";
                request_rx_valid<='1';
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="001";
        elsif(curr_rx_port="001") then --reading down port
            if(Rx_data_valid(1)='1') then
                current_request<=unsigned(Rx_down_data);
                request_rx_port<=curr_rx_port;
                request_rx_port_2<="00010";
                request_rx_valid<='1';
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="010";
        elsif(curr_rx_port="010") then -- reading left port
            if(Rx_data_valid(2)='1') then
                current_request<=unsigned(Rx_left_data);
                request_rx_port<=curr_rx_port;
                request_rx_port_2<="00100";
                request_rx_valid<='1';
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="011";
        elsif(curr_rx_port="011") then -- reading right port
            if(Rx_data_valid(3)='1') then
                current_request<=unsigned(Rx_right_data);
                request_rx_port<=curr_rx_port;
                request_rx_port_2<="01000";
                request_rx_valid<='1';
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="100";
        else -- checking if the node wants to send data
            if(Node_Tx_en='1') then
                current_request<=unsigned(Node_Tx_data);
                request_rx_port<=curr_rx_port;
                request_rx_port_2<= "10000";
                request_rx_valid<=Node_Tx_en;
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="000";
        end if;
    end if;
end process;
------------------ Processing requests --------------------
--- first stage
router_match(0)<= '1' when (current_request(2 downto 0)>SELF_Y) else '0';
router_match(1)<= '1' when (current_request(2 downto 0)<SELF_Y) else '0';
router_match(2)<= '1' when (current_request(5 downto 3)<SELF_X) else '0';
router_match(3)<= '1' when (current_request(5 downto 3)>SELF_X) else '0';
router_match(4)<= '1' when (current_request(5 downto 3)=SELF_X and current_request(2 downto 0)=SELF_Y) else '0';
router_match_opt<= router_match and not (Tx_assigned or request_rx_port_2); -- optimized ports that are optimum for sending data and not assigned to any port (NOTICE THAT : the incomming UART block is completely locked in case of path reservation)
router_match_res<= Tx_assigned when((router_match_opt(0) or router_match_opt(1) or router_match_opt(2) or router_match_opt(3) or router_match_opt(4)) = '0') else router_match_opt;
--- do the port assignment
process(clk) begin
    if(rising_edge(clk)) then
        if(current_request(7 downto 6)= RESERVE_PATH) then
            if(router_match_res(0)='1') then -- up
                
            elsif(router_match_res(1)='1') then
            
            elsif(router_match_res(2)='1') then
            
            elsif(router_match_res(3)='1') then
            
            elsif(router_match_res(4)='1') then
            
            else
            
            end if;
        elsif(current_request = ACK) then
        
        elsif(current_request = RELEASE_PATH) then
        
        else
        
        end if;
    end if;
end process;
-------------------Regesters-------------------------------
process(clk) begin
    if(rising_edge(clk)) then
        current_request_pipe2<=current_request;
        router_match_pipe2<=router_match;
        request_rx_port_pipe2<=request_rx_port;
        request_rx_valid_pipe2<=request_rx_valid;
        router_match_opt_pipe2<=router_match_opt_pipe2;
        router_match_res_pipe2<=router_match_res;
    end if;
end process;
------------------ second stage --------------------------

end Behavioral;

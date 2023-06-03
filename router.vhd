----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/17/2023 12:57:59 PM
-- Design Name: 
-- Module Name: router - Behavioral
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

entity router is
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

end router;

architecture Behavioral of router is
component fifo_generator_0 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;

signal Tx_assigned_Rx: unsigned(14 downto 0) := "111111111111111"; -- each 3 bit represents the Rx port that the Tx port is connceted to (up,down,left,right,self)
signal Rx_assigned_Tx: unsigned(14 downto 0) := "111111111111111"; -- each 3 bit represents the Rx port that the Tx port is connceted to (up,down,left,right,self)
signal Tx_assigned,Rx_assigned: std_logic_vector(4 downto 0) :="00000"; -- each bit represents whether Tx port is connected or not (up, down , left ,right,self)
signal Tx_up_d,Tx_down_d,Tx_left_d,Tx_right_d,Tx_self_d : std_logic_vector(7 downto 0);
signal Tx_valid_d : std_logic_vector(4 downto 0):="00000";
--- first stage ------
signal current_request : unsigned(7 downto 0);
signal curr_rx_port,request_rx_port : unsigned(2 downto 0):="000";
signal request_rx_port_2 : std_logic_vector(4 downto 0);
signal request_rx_valid : std_logic;
signal router_match : std_logic_vector(4 downto 0);
signal router_match_opt : std_logic_vector(4 downto 0);
signal router_match_res : std_logic_vector(4 downto 0);
----- second stage of process pipeline
signal current_request_pipe2 : unsigned(7 downto 0);
signal curr_rx_port_pipe2,request_rx_port_pipe2 : unsigned(2 downto 0):="000";
signal request_rx_port_2_pipe2 : std_logic_vector(4 downto 0);
signal request_rx_valid_pipe2 : std_logic;
signal router_match_pipe2 : std_logic_vector(4 downto 0);
signal router_match_opt_pipe2 : std_logic_vector(4 downto 0);
signal router_match_res_pipe2 : std_logic_vector(4 downto 0);

signal read_fifo,read_fifo_final : std_logic_vector(4 downto 0):="00000";
signal Rx_up_fifo,Rx_down_fifo,Rx_left_fifo,Rx_right_fifo,Rx_self_fifo : STD_LOGIC_VECTOR (7 downto 0);
signal full,empty : std_logic_vector(4 downto 0);
-------------- FSM -------------------
signal state : unsigned(1 downto 0):="00";
signal clk_8,clk_2 : std_logic:='1';
signal clk_4 : std_logic :='1';
----- expander FSM
signal Tx_up_expander_state,Tx_down_expander_state,Tx_left_expander_state,Tx_right_expander_state,Tx_self_expander_state : unsigned(4 downto 0):="11111";
begin
--read_fifo_final<=read_fifo or Rx_assigned;
--FIFO_Rx_up: fifo_generator_0 port map(
--clk =>clk_4,
--    srst=>'0',
--    din =>Rx_up,
--    wr_en => Rx_valid(0),
--    rd_en => read_fifo_final(0),
--    dout => Rx_up_fifo,
--    full => full(0),
--    empty => empty(0)
--);

--FIFO_Rx_down: fifo_generator_0 port map(
--clk =>clk_4,
--    srst=>'0',
--    din =>Rx_down,
--    wr_en => Rx_valid(1),
--    rd_en => read_fifo_final(1),
--    dout => Rx_down_fifo,
--    full => full(1),
--    empty => empty(1)
--);

--FIFO_Rx_left: fifo_generator_0 port map(
--clk =>clk_4,
--    srst=>'0',
--    din =>Rx_left,
--    wr_en => Rx_valid(2),
--    rd_en => read_fifo_final(2),
--    dout => Rx_left_fifo,
--    full => full(2),
--    empty => empty(2)
--);

--FIFO_Rx_right: fifo_generator_0 port map(
--clk =>clk_4,
--    srst=>'0',
--    din =>Rx_right,
--    wr_en => Rx_valid(3),
--    rd_en => read_fifo_final(3),
--    dout => Rx_right_fifo,
--    full => full(3),
--    empty => empty(3)
--);

--FIFO_Rx_self: fifo_generator_0 port map(
--clk =>clk_4,
--    srst=>'0',
--    din =>Rx_self,
--    wr_en => Rx_valid(4),
--    rd_en => read_fifo_final(4),
--    dout => Rx_self_fifo,
--    full => full(4),
--    empty => empty(4)
--);


--- FSM ----
process(clk) begin
    if(rising_edge(clk)) then
        state<=state + 1;
    end if;
end process;

process(clk) begin
    if(rising_edge(clk))then
        clk_2<= not clk_2;
    end if;
end process;
process(clk_2) begin
    if(rising_edge(clk_2)) then
        clk_4<= not clk_4;
    end if;
end process;

process(clk_4)begin
    if(rising_edge(clk_4)) then
        if(curr_rx_port="000") then -- reading up port
            if(Rx_valid(0)='1') then
                current_request<=unsigned(Rx_up);
                request_rx_port<=curr_rx_port;
                request_rx_port_2<="00001";
                request_rx_valid<='1';
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="001";
        elsif(curr_rx_port="001") then --reading down port
            if(Rx_valid(1)='1') then
                current_request<=unsigned(Rx_down);
                request_rx_port<=curr_rx_port;
                request_rx_port_2<="00010";
                request_rx_valid<='1';
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="010";
        elsif(curr_rx_port="010") then -- reading left port
            if(Rx_valid(2)='1') then
                current_request<=unsigned(Rx_left);
                request_rx_port<=curr_rx_port;
                request_rx_port_2<="00100";
                request_rx_valid<='1';
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="011";
        elsif(curr_rx_port="011") then -- reading right port
            if(Rx_valid(3)='1') then
                current_request<=unsigned(Rx_right);
                request_rx_port<=curr_rx_port;
                request_rx_port_2<="01000";
                request_rx_valid<='1';
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="100";
        else -- checking if the node wants to send data
            if(Rx_valid(4)='1') then
                current_request<=unsigned(Rx_self);
                request_rx_port<="100";
                request_rx_port_2<= "10000";
                request_rx_valid<='1';
            else
                request_rx_valid<='0';
            end if;
            curr_rx_port<="000";
        end if;
    end if;
end process;
--process(clk_4)begin
--    if(rising_edge(clk_4)) then
--        if(curr_rx_port="000") then -- reading up port
--            read_fifo<="00001";
--            if(empty(0)='0') then
--                current_request<=unsigned(Rx_up_fifo);
--                request_rx_port<=curr_rx_port;
--                request_rx_port_2<="00001";
--                request_rx_valid<='1';
                
--            else
--                request_rx_valid<='0';
--            end if;
--            curr_rx_port<="001";
--        elsif(curr_rx_port="001") then --reading down port
--            read_fifo<="00010";
--            if(empty(1)='0') then
--                current_request<=unsigned(Rx_down_fifo);
--                request_rx_port<=curr_rx_port;
--                request_rx_port_2<="00010";
--                request_rx_valid<='1';
                
--            else
--                request_rx_valid<='0';
--            end if;
--            curr_rx_port<="010";
--        elsif(curr_rx_port="010") then -- reading left port
--            read_fifo<="00100";
--            if(empty(2)='0') then
--                current_request<=unsigned(Rx_left_fifo);
--                request_rx_port<=curr_rx_port;
--                request_rx_port_2<="00100";
--                request_rx_valid<='1';
                
--            else
--                request_rx_valid<='0';
--            end if;
--            curr_rx_port<="011";
--        elsif(curr_rx_port="011") then -- reading right port
--            read_fifo<="01000";
--            if(empty(3)='0') then
--                current_request<=unsigned(Rx_right_fifo);
--                request_rx_port<=curr_rx_port;
--                request_rx_port_2<="01000";
--                request_rx_valid<='1';
                
--            else
--                request_rx_valid<='0';
--            end if;
--            curr_rx_port<="100";
--        else -- checking if the node wants to send data
--            read_fifo<="10000";
--            if(empty(4)='0') then
--                current_request<=unsigned(Rx_self_fifo);
--                request_rx_port<="100";
--                request_rx_port_2<= "10000";
--                request_rx_valid<='1';
                
--            else
--                request_rx_valid<='0';
--            end if;
--            curr_rx_port<="000";
--        end if;
--    end if;
--end process;

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
        if(state="00" and request_rx_valid='1' and  (current_request(7 downto 6)= RESERVE_PATH) and (Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))="111")) then
            if(router_match_res(0)='1') then -- up
                Tx_assigned(0)<='1';
                Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))<="000"; -- assign Tx up to request_Rx
                Tx_assigned_Rx(2 downto 0)<=request_rx_port;
                Rx_assigned(to_integer(request_rx_port))<='1';
            elsif(router_match_res(1)='1') then
                Tx_assigned(1)<='1';
                Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))<="001"; -- assign Tx down to request_Rx
                Tx_assigned_Rx(5 downto 3)<=request_rx_port;
                Rx_assigned(to_integer(request_rx_port))<='1';
            elsif(router_match_res(2)='1') then
                Tx_assigned(2)<='1';
                Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))<="010"; -- assign Tx left to request_Rx
                Tx_assigned_Rx(8 downto 6)<=request_rx_port;
                Rx_assigned(to_integer(request_rx_port))<='1';
            elsif(router_match_res(3)='1') then
                Tx_assigned(3)<='1';
                Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))<="011"; -- assign Tx right to request_Rx
                Tx_assigned_Rx(11 downto 9)<=request_rx_port;
                Rx_assigned(to_integer(request_rx_port))<='1';
            elsif(router_match_res(4)='1') then
                Tx_assigned(4)<='1';
                Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))<="100"; -- assign Tx self to request_Rx
                Tx_assigned_Rx(14 downto 12)<=request_rx_port;
                Rx_assigned(to_integer(request_rx_port))<='1';
            else
                
            end if;
        elsif(state="11" and request_rx_valid='1' and (((current_request = ACK) or (current_request = RELEASE_PATH))) and (Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))<="100") ) then
            Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))<="111"; -- assign to EMPTY
            Rx_assigned(to_integer(request_rx_port))<='0';
            Tx_assigned(to_integer(Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))))<='0';
            Tx_assigned_Rx(
            3*to_integer(Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port))) + 2 downto
            3*to_integer(Rx_assigned_Tx(3*to_integer(request_rx_port) + 2 downto 3*to_integer(request_rx_port)))
            )<="111";
        else
            -- do nothing 
            -- route is already established
        end if;
    end if;
end process;

-- TX VALID

Tx_valid<=Tx_assigned when (state="01" and request_rx_valid='1') else
          "00000";

--- router 
--Tx_up<= Rx_up_fifo when (state="10" and Tx_assigned_Rx(2 downto 0) = "000") else
--        Rx_down_fifo when (state="10" and Tx_assigned_Rx(2 downto 0) = "001") else
--        Rx_left_fifo when (state="10" and Tx_assigned_Rx(2 downto 0) = "010") else
--        Rx_right_fifo when (state="10" and Tx_assigned_Rx(2 downto 0) = "011") else
--        Rx_self_fifo when (state="10" and Tx_assigned_Rx(2 downto 0) = "100") else
--        "00000000"; -- empty
--Tx_down<= Rx_up_fifo when (state="10" and Tx_assigned_Rx(5 downto 3) = "000") else
--          Rx_down_fifo when (state="10" and Tx_assigned_Rx(5 downto 3) = "001") else
--          Rx_left_fifo when (state="10" and Tx_assigned_Rx(5 downto 3) = "010") else
--          Rx_right_fifo when (state="10" and Tx_assigned_Rx(5 downto 3) = "011") else
--          Rx_self_fifo when (state="10" and Tx_assigned_Rx(5 downto 3) = "100") else
--          "00000000"; -- empty
--Tx_left<= Rx_up_fifo when (state="10" and Tx_assigned_Rx(8 downto 6) = "000") else
--          Rx_down_fifo when (state="10" and Tx_assigned_Rx(8 downto 6) = "001") else
--          Rx_left_fifo when (state="10" and Tx_assigned_Rx(8 downto 6) = "010") else
--          Rx_right_fifo when (state="10" and Tx_assigned_Rx(8 downto 6) = "011") else
--          Rx_self_fifo when (state="10" and Tx_assigned_Rx(8 downto 6) = "100") else
--          "00000000"; -- empty
--Tx_right<= Rx_up_fifo when (state="10" and Tx_assigned_Rx(11 downto 9) = "000") else
--          Rx_down_fifo when (state="10" and Tx_assigned_Rx(11 downto 9) = "001") else
--          Rx_left_fifo when (state="10" and Tx_assigned_Rx(11 downto 9) = "010") else
--          Rx_right_fifo when (state="10" and Tx_assigned_Rx(11 downto 9) = "011") else
--          Rx_self_fifo when (state="10" and Tx_assigned_Rx(11 downto 9) = "100") else
--          "00000000"; -- empty
--Tx_self<= Rx_up_fifo when (state="10" and Tx_assigned_Rx(14 downto 12) = "000") else
--          Rx_down_fifo when (state="10" and Tx_assigned_Rx(14 downto 12) = "001") else
--          Rx_left_fifo when (state="10" and Tx_assigned_Rx(14 downto 12) = "010") else
--          Rx_right_fifo when (state="10" and Tx_assigned_Rx(14 downto 12) = "011") else
--          Rx_self_fifo when (state="10" and Tx_assigned_Rx(14 downto 12) = "100") else
--          "00000000"; -- empty

Tx_up<= std_logic_vector(current_request) when (state="01" and Tx_assigned_Rx(2 downto 0) = request_rx_port) else
          "00000000"; -- empty
Tx_down<= std_logic_vector(current_request) when (state="01" and Tx_assigned_Rx(5 downto 3) = request_rx_port) else
          "00000000"; -- empty
Tx_left<= std_logic_vector(current_request) when (state="01" and Tx_assigned_Rx(8 downto 6) = request_rx_port) else
          "00000000"; -- empty
Tx_right<= std_logic_vector(current_request) when (state="01" and Tx_assigned_Rx(11 downto 9) = request_rx_port) else
          "00000000"; -- empty
Tx_self<= std_logic_vector(current_request) when (state="01" and Tx_assigned_Rx(14 downto 12) = request_rx_port) else
          "00000000"; -- empty
          
--- output clock cycle expander convert from 1 clk to 4 clks using FSM
--process(clk) begin
--    if(rising_edge(clk)) then
--        if(Tx_up_expander_state="11111" and Tx_valid_d(0)='0') then
--            Tx_up_expander_state<="11110";
--            Tx_valid(0)<= '0';
--            Tx_up<= "00000000";
--        elsif(Tx_up_expander_state="11110" and Tx_valid_d(0)='1') then
--            Tx_up_expander_state<="00000";
--            Tx_valid(0)<= '1';
--            Tx_up<= Tx_up_d;
--        elsif(Tx_up_expander_state<"10100") then
--            Tx_valid(0)<= '1';
--            Tx_up_expander_state<=Tx_up_expander_state + 1;
--        elsif(Tx_up_expander_state="10100") then
--            Tx_valid(0)<= '0';
--            Tx_up<= "00000000";
--            Tx_up_expander_state<="11111";
--        end if;
--    end if;
--end process;

--process(clk) begin
--    if(rising_edge(clk)) then
--        if(Tx_down_expander_state="11111" and Tx_valid_d(1)='0') then
--            Tx_down_expander_state<="11110";
--            Tx_valid(1)<= '0';
--            Tx_down<= "00000000";
--        elsif(Tx_down_expander_state="11110" and Tx_valid_d(1)='1') then
--            Tx_down_expander_state<="00000";
--            Tx_valid(1)<= '1';
--            Tx_down<= Tx_down_d;
--        elsif(Tx_down_expander_state<"10100") then
--            Tx_valid(1)<= '1';
--            Tx_down_expander_state<=Tx_down_expander_state + 1;
--        elsif(Tx_down_expander_state="10100") then
--            Tx_valid(1)<= '0';
--            Tx_down<= "00000000";
--            Tx_down_expander_state<="11111";
--        end if;
--    end if;
--end process;

--process(clk) begin
--    if(rising_edge(clk)) then
--        if(Tx_left_expander_state="11111" and Tx_valid_d(2)='0') then
--            Tx_left_expander_state<="11110";
--            Tx_valid(2)<= '0';
--            Tx_left<= "00000000";
--        elsif(Tx_left_expander_state="11110" and Tx_valid_d(2)='1') then
--            Tx_left_expander_state<="00000";
--            Tx_valid(2)<= '1';
--            Tx_left<= Tx_left_d;
--        elsif(Tx_left_expander_state<"10100") then
--            Tx_valid(2)<= '1';
--            Tx_left_expander_state<=Tx_left_expander_state + 1;
--        elsif(Tx_left_expander_state="10100") then
--            Tx_valid(2)<= '0';
--            Tx_left<= "00000000";
--            Tx_left_expander_state<="11111";
--        end if;
--    end if;
--end process;

--process(clk) begin
--    if(rising_edge(clk)) then
--        if(Tx_right_expander_state="11111" and Tx_valid_d(3)='0') then
--            Tx_right_expander_state<="11110";
--            Tx_valid(3)<= '0';
--            Tx_right<= "00000000";
--        elsif(Tx_right_expander_state="11110" and Tx_valid_d(3)='1') then
--            Tx_right_expander_state<="00000";
--            Tx_valid(3)<= '1';
--            Tx_right<= Tx_right_d;
--        elsif(Tx_right_expander_state<"10100") then
--            Tx_valid(3)<= '1';
--            Tx_right_expander_state<=Tx_right_expander_state + 1;
--        elsif(Tx_right_expander_state="10100") then
--            Tx_valid(3)<= '0';
--            Tx_right<= "00000000";
--            Tx_right_expander_state<="11111";
--        end if;
--    end if;
--end process;

--process(clk) begin
--    if(rising_edge(clk)) then
--        if(Tx_self_expander_state="11111" and Tx_valid_d(4)='0') then
--            Tx_self_expander_state<="11110";
--            Tx_valid(4)<= '0';
--            Tx_self<= "00000000";
--        elsif(Tx_self_expander_state="11110" and Tx_valid_d(4)='1') then
--            Tx_self_expander_state<="00000";
--            Tx_valid(4)<= '1';
--            Tx_self<= Tx_self_d;
--        elsif(Tx_self_expander_state<"10100") then
--            Tx_valid(4)<= '1';
--            Tx_self_expander_state<=Tx_self_expander_state + 1;
--        elsif(Tx_self_expander_state="10100") then
--            Tx_valid(4)<= '0';
--            Tx_self<= "00000000";
--            Tx_self_expander_state<="11111";
--        end if;
--    end if;
--end process;
end Behavioral;

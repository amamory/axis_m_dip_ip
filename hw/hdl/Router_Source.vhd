----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/07/2020 05:41:32 PM
-- Design Name: 
-- Module Name: Router_Source - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- very simple packet generator to connect to the Hermes slave ports
-- it only sends a single flit packet with the value of the counter
-- to the address accoding to the dip switches
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Router_Source is
Port ( 
	clock   : in  std_logic;
	reset_n : in  std_logic;  
	-- connected to the zedboard
	dip_i   : in  std_logic_vector(7 downto 0);
	send_i  : in  std_logic;
	end_i   : in  std_logic;
	-- axi master streaming interface
	valid_o : out std_logic;
	ready_i : in  std_logic;
	data_o  : out std_logic_vector(31 downto 0)
);
end Router_Source;

architecture Behavioral of Router_Source is


type State_type IS (IDLE, SEND_HEADER, SEND_SIZE, SEND_PAYLOAD, WAIT_END); 
signal state, state_next : State_Type;  

signal counter : std_logic_vector (7 downto 0);

--attribute KEEP : string;
--attribute MARK_DEBUG : string;
--
--attribute KEEP of state : signal is "TRUE";
---- in verilog: (* keep = "true" *) wire signal_name;
--attribute MARK_DEBUG of state : signal is "TRUE";
--
--attribute KEEP of valid_o : signal is "TRUE";
--attribute MARK_DEBUG of valid_o : signal is "TRUE";
--
--attribute KEEP of ready_i : signal is "TRUE";
--attribute MARK_DEBUG of ready_i : signal is "TRUE";
--
--attribute KEEP of data_o : signal is "TRUE";
--attribute MARK_DEBUG of data_o : signal is "TRUE";


begin

    process(clock)
    begin
        if (clock'event and clock = '1') then
            if (reset_n = '0') then 
                state <= IDLE;
                counter <= (others => '0');
            else
                state <= state_next;
                if state = WAIT_END and end_i = '1' then
                    counter <=  counter + 1;
                end if;
            end if;
        end if;
    end process;


	process(state,send_i,end_i, ready_i)
	begin
		case state is
			when IDLE =>
                if send_i = '1' and ready_i = '1' then
                    state_next <= SEND_HEADER;
                else
                    state_next <= IDLE;
                end if; 
			when SEND_HEADER =>
                if ready_i = '1' then
                    state_next <= SEND_SIZE;
                else
                    state_next <= SEND_HEADER;
                end if; 
			when SEND_SIZE =>
                if ready_i = '1' then
                    state_next <= SEND_PAYLOAD;
                else
                    state_next <= SEND_SIZE;
                end if; 
			when SEND_PAYLOAD =>
                if ready_i = '1' then
                    state_next <= WAIT_END;
                else
                    state_next <= SEND_PAYLOAD;
                end if; 
			when WAIT_END =>
                if end_i = '1'  then
                    state_next <= IDLE;
                else
                    state_next <= WAIT_END;
                end if; 
            when others =>
                state_next <= IDLE;
        end case;
	end process;

	valid_o <= '0' when state = IDLE or state = WAIT_END else '1';
	
	data_o  <= x"0000" & x"0" & dip_i(7 downto 4) & x"0" & dip_i(3 downto 0)  when state = SEND_HEADER  else -- always send to the local port
	           x"00000001"           when state = SEND_SIZE    else -- always send only one flit
	           x"000000" & counter when state = SEND_PAYLOAD else -- always send the value in the dip switches
	           x"00000000";

end Behavioral;

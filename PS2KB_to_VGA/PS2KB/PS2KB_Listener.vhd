----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:12:18 07/26/2015 
-- Design Name: 
-- Module Name:    PS2KB_Listener - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PS2KB_Listener is
    Port ( rst			: in  STD_LOGIC;
           clk_1M		: in  STD_LOGIC;
           clk_kb		: inout  STD_LOGIC;
           data_kb	: in  STD_LOGIC;
			  clk			: buffer  STD_LOGIC;
           data		: buffer  STD_LOGIC_VECTOR (7 downto 0));
end PS2KB_Listener;

architecture Behavioral of PS2KB_Listener is
	type STATES is (ST_WAITING, ST_READING, ST_CHECKING, ST_ENDING, ST_REFUSING );
	signal state			: STATES;
	signal hits				: integer;-- range 255 downto 0;
	signal pos				: integer;-- range 7 downto 0;
	signal prev_clk_kb	: std_logic;
begin

	prev_clk_kb <= clk_kb when rising_edge(clk_1M);
	
	process (clk_1M, rst) begin
		if (rst = '0') then
			state <= ST_WAITING;
			hits <= 0;
			pos <= 0;
			clk_kb <= 'Z';
			clk <= '0';
			data <= (others => '0');
		elsif (rising_edge(clk_1M)) then
			if (clk = '1') then
				clk <= '0';
			elsif (prev_clk_kb = '1' and clk_kb = '0') then
				hits <= 0;
				case state is
					when ST_WAITING =>
						data(0) <= '1';
						if (data_kb = '0') then
							state <= ST_READING;
							pos <= 0;
						else
							state <= ST_REFUSING;
							clk_kb <= '0';
						end if;
					when ST_READING =>
						data(pos) <= data_kb;
						hits <= 0;
						if pos = 7 then
							state <= ST_CHECKING;
						else
							pos <= pos + 1;
						end if;
					when ST_CHECKING =>
						if (data(0) xor data(1) xor data(2) xor data(3) xor data(4)
						xor data(5) xor data(6) xor data(7) xor data_kb) = '1' then
							state <= ST_ENDING;
						else
							state <= ST_REFUSING;
							clk_kb <= '0';
						end if;
					when ST_ENDING =>
						if data_kb = '1' then
							state <= ST_WAITING;
							clk <= '1';
						else
							state <= ST_REFUSING;
							clk_kb <= '0';
						end if;
					when ST_REFUSING =>
				end case;
			elsif state /= ST_WAITING then
				if (200 <= hits) then
					hits <= 0;
					if state = ST_REFUSING then
						state <= ST_WAITING;
						clk_kb <= 'Z';
					else
						state <= ST_REFUSING;
						clk_kb <= '0';
					end if;
				else
					hits <= hits + 1;
				end if;
			end if;
		end if;
	end process;

end Behavioral;


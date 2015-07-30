----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:59:45 07/26/2015 
-- Design Name: 
-- Module Name:    PS2KB_Decoder - Behavioral 
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

entity PS2KB_Decoder is
    Port ( rst			: in  STD_LOGIC;
    	     clk_50M	: in  STD_LOGIC;
			  clk			: in  STD_LOGIC;
           data		: in  STD_LOGIC_VECTOR (7 downto 0);
			  clk_chr	: buffer  STD_LOGIC;
           char		: out  STD_LOGIC_VECTOR (7 downto 0));
end PS2KB_Decoder;

architecture Behavioral of PS2KB_Decoder is
	signal prev_clk		: STD_LOGIC;
	signal prev_data		: STD_LOGIC_VECTOR(23 downto 0);
	signal caps, shift	: STD_LOGIC;
	signal lowercase		: STD_LOGIC;
begin

	prev_clk	<= '0' when rst = '0' else
					clk when rising_edge(clk_50M);
	lowercase <= caps xor shift;

	process (rst, clk_50M) begin
		if (rst = '0') then
			clk_chr <= '0';
			char <= (others => '0');
			prev_data <= (others => '0');
			caps <= '0';
			shift <= '0';
		elsif (rising_edge(clk_50M)) then
			if (clk = '0' and clk_chr = '1') then
				clk_chr <= '0';
			elsif (prev_clk = '0' and clk = '1') then
    			prev_data <= prev_data(15 downto 0)&data;
    			if (prev_data(7 downto 0) = X"F0") then
					if (data = X"12") then
						shift <= '0';
					end if;
    			else
    				case data is
						when X"12" =>
							shift <= '1';
                  when X"0D" =>
                     caps <= not caps;
    					when X"1C" =>
    						char <= "01"&lowercase&"00001";
                     clk_chr <= '1';
                  when X"32" =>
                     char <= "01"&lowercase&"00010";
                     clk_chr <= '1';
                  when X"21" =>
                     char <= "01"&lowercase&"00011";
    					   clk_chr <= '1';
                  when X"23" =>
                     char <= "01"&lowercase&"00100";
    					   clk_chr <= '1';
                  when X"24" =>
                     char <= "01"&lowercase&"00101";
    					   clk_chr <= '1';
                  when X"2B" =>
                     char <= "01"&lowercase&"00110";
    					   clk_chr <= '1';
                  when X"34" =>
                     char <= "01"&lowercase&"00111";
    					   clk_chr <= '1';
                  when X"33" =>
                     char <= "01"&lowercase&"01000";
    					   clk_chr <= '1';
                  when X"43" =>
                     char <= "01"&lowercase&"01001";
    					   clk_chr <= '1';
                  when X"3B" =>
                     char <= "01"&lowercase&"01010";
    					   clk_chr <= '1';
                  when X"42" =>
                     char <= "01"&lowercase&"01011";
    					   clk_chr <= '1';
                  when X"4B" =>
                     char <= "01"&lowercase&"01100";
    					   clk_chr <= '1';
                  when X"3A" =>
                     char <= "01"&lowercase&"01101";
    					   clk_chr <= '1';
                  when X"31" =>
                     char <= "01"&lowercase&"01110";
    					   clk_chr <= '1';
                  when X"44" =>
                     char <= "01"&lowercase&"01111";
    					   clk_chr <= '1';
                  when X"4D" =>
                     char <= "01"&lowercase&"10000";
    					   clk_chr <= '1';
                  when X"15" =>
                     char <= "01"&lowercase&"10001";
    					   clk_chr <= '1';
                  when X"2D" =>
                     char <= "01"&lowercase&"10010";
    					   clk_chr <= '1';
                  when X"1B" =>
                     char <= "01"&lowercase&"10011";
    					   clk_chr <= '1';
                  when X"2C" =>
                     char <= "01"&lowercase&"10100";
    					   clk_chr <= '1';
                  when X"3C" =>
                     char <= "01"&lowercase&"10101";
    					   clk_chr <= '1';
                  when X"2A" =>
                     char <= "01"&lowercase&"10110";
    					   clk_chr <= '1';
                  when X"1D" =>
                     char <= "01"&lowercase&"10111";
    					   clk_chr <= '1';
                  when X"22" =>
                     char <= "01"&lowercase&"11000";
    					   clk_chr <= '1';
                  when X"35" =>
                     char <= "01"&lowercase&"11001";
    					   clk_chr <= '1';
                  when X"1A" =>
                     char <= "01"&lowercase&"11010";
    					   clk_chr <= '1';
                  when X"45" =>
							if (shift = '0') then
								char <= "00110000";
							else
								char <= "00101001";
							end if;
                     clk_chr <= '1';
                  when X"16" =>
							if (shift = '0') then
								char <= "00110001";
							else
								char <= "00100001";
							end if;
							clk_chr <= '1';
                  when X"1E" =>
							if (shift = '0') then
								char <= "00110010";
							else
								char <= "01000000";
							end if;
							clk_chr <= '1';
                  when X"26" =>
							if (shift = '0') then
								char <= "00110011";
							else
								char <= "00100011";
							end if;
							clk_chr <= '1';
                  when X"25" =>
							if (shift = '0') then
								char <= "00110100";
							else
								char <= "00100100";
							end if;
							clk_chr <= '1';
                  when X"2E" =>
							if (shift = '0') then
								char <= "00110101";
							else
								char <= "00100101";
							end if;
							clk_chr <= '1';
                  when X"36" =>
							if (shift = '0') then
								char <= "00110110";
							else
								char <= "01011110";
							end if;
							clk_chr <= '1';
                  when X"3D" =>
							if (shift = '0') then
								char <= "00110111";
							else
								char <= "00100110";
							end if;
							clk_chr <= '1';
                  when X"3E" =>
							if (shift = '0') then
								char <= "00111000";
							else
								char <= "00101010";
							end if;
							clk_chr <= '1';
                  when X"46" =>
							if (shift = '0') then
								char <= "00111001";
							else
								char <= "00101000";
							end if;
							clk_chr <= '1';
                  when others =>
					end case;
    			end if;
    		end if;
        end if;
	end process;

end Behavioral;


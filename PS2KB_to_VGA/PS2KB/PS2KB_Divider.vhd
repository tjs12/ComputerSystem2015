----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:00:28 07/26/2015 
-- Design Name: 
-- Module Name:    PS2KB_Divider - Behavioral 
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

entity PS2KB_Divider is
    Port ( clk_50M	: in  STD_LOGIC;
           clk_1M		: out  STD_LOGIC);
end PS2KB_Divider;

architecture Behavioral of PS2KB_Divider is
	signal count	: integer;-- range 50-1 downto 0;
	signal clk		: std_logic;
begin

	process (clk_50M) begin
		if (rising_edge(clk_50M)) then
			if (0 <= count and count < 25-1) then
				count <= count + 1;
			else
				count <= 0;
			end if;
		end if;
	end process;
	clk <= not clk when rising_edge(clk_50M) and count = 0;
	clk_1M <= clk;

end Behavioral;


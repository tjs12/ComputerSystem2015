----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:47:21 07/24/2015 
-- Design Name: 
-- Module Name:    VGA_Divider - Behavioral 
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

entity VGA_Divider is
    Port ( clk_50M : in  STD_LOGIC;
           clk_25M : out  STD_LOGIC;
           clk_1 : out  STD_LOGIC);
end VGA_Divider;

architecture Behavioral of VGA_Divider is
	signal clk1, clk2	: STD_LOGIC;
	signal count		: integer;
begin

	clk1 <= not clk1 when rising_edge(clk_50M);
	clk_25M <= clk1;
	
	process (clk_50M) begin
		if (rising_edge(clk_50M)) then
			if (0 <= count and count < 25000000-1) then
				count <= count + 1;
			else
				count <= 0;
			end if;
		end if;
	end process;
	clk2 <= not clk2 when rising_edge(clk_50M) and count = 0;
	clk_1 <= clk2;

end Behavioral;


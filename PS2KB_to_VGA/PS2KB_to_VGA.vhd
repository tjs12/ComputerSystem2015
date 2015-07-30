----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:51:36 07/30/2015 
-- Design Name: 
-- Module Name:    PS2KB_to_VGA - Behavioral 
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

entity PS2KB_to_VGA is
    Port ( rst			: in  STD_LOGIC;
           clk_50M	: in  STD_LOGIC;
           clk_kb		: inout  STD_LOGIC;
           data_kb	: in  STD_LOGIC;
           video		: out  STD_LOGIC_VECTOR (10 downto 0));
end PS2KB_to_VGA;

architecture Behavioral of PS2KB_to_VGA is
	component PS2KB is
		Port ( rst			: in  STD_LOGIC;
				 clk_50M		: in  STD_LOGIC;
				 clk_kb		: inout  STD_LOGIC;
				 data_kb		: in  STD_LOGIC;
				 clk_chr		: out  STD_LOGIC;
				 char			: out  STD_LOGIC_VECTOR (7 downto 0));
	end component;
	component VGA is
		Port ( rst			: in  STD_LOGIC;
				 clk_50M		: in  STD_LOGIC;
				 clk_chr		: in  STD_LOGIC;
				 char			: in  STD_LOGIC_VECTOR (15 downto 0);
				 video		: out  STD_LOGIC_VECTOR (10 downto 0));
	end component;
	signal clk_chr	: STD_LOGIC;
	signal char		: STD_LOGIC_VECTOR(7 downto 0);
begin

	ps2kb_m	: PS2KB port map (
		rst		=> rst,
		clk_50M	=> clk_50M,
		clk_kb	=> clk_kb,
		data_kb	=> data_kb,
		clk_chr	=> clk_chr,
		char		=> char
	);
	vga_m	: VGA port map (
		rst		=> rst,
		clk_50M	=> clk_50M,
		clk_chr	=> clk_chr,
		char		=> "00000000"&char,
		video		=> video
	);

end Behavioral;


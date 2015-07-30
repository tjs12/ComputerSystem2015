----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:53:44 07/17/2015 
-- Design Name: 
-- Module Name:    VGA_Decoder - Behavioral 
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
USE IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_Decoder is
    Port ( clk		: in STD_LOGIC;
			  clk_1	: in STD_LOGIC;
			  data	: in  STD_LOGIC_VECTOR (15 downto 0);
           addr	: in  STD_LOGIC_VECTOR (18 downto 0);
           color	: out  STD_LOGIC_VECTOR (8 downto 0));
end VGA_Decoder;

architecture Behavioral of VGA_Decoder is
	component VGA_ROM_Font is
		port ( clka		: IN STD_LOGIC;
				 addra	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
				 douta	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	end component;
	signal pixels		: STD_LOGIC_VECTOR(0 to 7);
	signal fg_color,
			 bg_color	: STD_LOGIC_VECTOR(8 downto 0);
	signal fg			: STD_LOGIC;
begin

	rom	: VGA_ROM_FONT port map (
		clka	=> clk,
		addra	=> data(7 downto 0)&addr(13 downto 10),
		douta	=> pixels
	);
	
	fg_color(2 downto 0) <= (others => not data(9));
	fg_color(5 downto 3) <= (others => not data(10));
	fg_color(8 downto 6) <= (others => not data(11));
	bg_color(2 downto 0) <= (others => data(12));
	bg_color(5 downto 3) <= (others => data(13));
	bg_color(8 downto 6) <= (others => data(14));
	fg <= pixels(conv_integer(UNSIGNED(addr(2 downto 0))));
	color <= (others => '0') when data(15) = '1' and clk_1 = '0' else
				bg_color when fg = '0' else
				fg_color;

end Behavioral;


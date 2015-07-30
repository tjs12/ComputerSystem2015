----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:30:50 07/17/2015 
-- Design Name: 
-- Module Name:    VGA - Behavioral 
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

entity VGA is
    Port ( rst				: in  STD_LOGIC;
           clk_50M		: in  STD_LOGIC;
           clk_chr		: in  STD_LOGIC;
           char			: in  STD_LOGIC_VECTOR (15 downto 0);
           video			: out  STD_LOGIC_VECTOR (10 downto 0));
end VGA;

architecture Behavioral of VGA is
	component VGA_Divider is
		Port ( clk_50M : in  STD_LOGIC;
				 clk_25M : out  STD_LOGIC;
				 clk_1 : out  STD_LOGIC);
	end component;
	component VGA_Controller is
		Port ( rst		: in  STD_LOGIC;
				 clk_50M	: in  STD_LOGIC;
				 clk_chr	: in  STD_LOGIC;
             char		: in  STD_LOGIC_VECTOR (15 downto 0);
             addr		: in  STD_LOGIC_VECTOR (18 downto 0);
             data		: out  STD_LOGIC_VECTOR (15 downto 0));
	end component;
	component VGA_Decoder is
		Port ( clk		: in STD_LOGIC;
				 clk_1	: in STD_LOGIC;
				 data		: in  STD_LOGIC_VECTOR (15 downto 0);
				 addr		: in  STD_LOGIC_VECTOR (18 downto 0);
             color	: out  STD_LOGIC_VECTOR (8 downto 0));
	end component;
	component VGA_Render is
		Port ( rst		: in  STD_LOGIC;
				 clk_25M	: in  STD_LOGIC;
				 addr		: out  STD_LOGIC_VECTOR (18 downto 0);
			    color	: in  STD_LOGIC_VECTOR (8 downto 0);
             video	: out  STD_LOGIC_VECTOR (10 downto 0));
	end component;
	signal clk_25M, clk_1	: STD_LOGIC;
	signal addr					: STD_LOGIC_VECTOR (18 downto 0);
	signal data					: STD_LOGIC_VECTOR (15 downto 0);
	signal color				: STD_LOGIC_VECTOR (8 downto 0);
begin

	div	:	VGA_Divider port map (
		clk_50M	=>	clk_50M,
		clk_25M	=>	clk_25M,
		clk_1		=> clk_1
	);
	
	con	:	VGA_Controller port map (
		rst		=>	rst,
		clk_50M	=> clk_50M,
		clk_chr	=>	clk_chr,
		char		=>	char,
		addr		=>	addr,
		data		=>	data
	);
	
	dec	:	VGA_Decoder port map (
		clk	=> clk_50M,
		clk_1	=> clk_1,
		data	=>	data,
		addr	=>	addr,
		color	=> color
	);
	
	ren	:	VGA_Render port map (
		rst		=>	rst,
		clk_25M	=>	clk_25M,
		addr		=>	addr,
		color		=>	color,
		video		=>	video
	);
	
end Behavioral;


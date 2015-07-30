----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:45:01 07/26/2015 
-- Design Name: 
-- Module Name:    PS2KB - Behavioral 
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

entity PS2KB is
    Port ( rst			: in  STD_LOGIC;
           clk_50M	: in  STD_LOGIC;
           clk_kb		: inout  STD_LOGIC;
           data_kb	: in  STD_LOGIC;
           clk_chr	: out  STD_LOGIC;
           char		: out  STD_LOGIC_VECTOR (7 downto 0));
end PS2KB;

architecture Behavioral of PS2KB is
	component PS2KB_Divider is
		Port ( clk_50M : in  STD_LOGIC;
				 clk_1M	: out  STD_LOGIC);
	end component;
	component PS2KB_Listener is
		Port ( rst		: in  STD_LOGIC;
				 clk_1M	: in  STD_LOGIC;
				 clk_kb	: inout  STD_LOGIC;
             data_kb	: in  STD_LOGIC;
             clk		: buffer  STD_LOGIC;
             data		: buffer  STD_LOGIC_VECTOR (7 downto 0));
	end component;
	component PS2KB_Decoder is
		Port ( rst			: in STD_LOGIC;
    	       clk_50M		: in  STD_LOGIC;
		       clk			: in  STD_LOGIC;
             data			: in  STD_LOGIC_VECTOR (7 downto 0);
		       clk_chr		: buffer STD_LOGIC;
             char			: out  STD_LOGIC_VECTOR (7 downto 0));
	end component;
	signal clk_1M, clk	: std_logic;
	signal data				: std_logic_vector(7 downto 0);
begin

	div	: PS2KB_Divider port map (
		clk_50M	=> clk_50M,
		clk_1M	=> clk_1M
	);
	
	lis	: PS2KB_Listener port map (
		rst		=> rst,
		clk_1M	=> clk_1M,
		clk_kb	=> clk_kb,
		data_kb	=> data_kb,
		clk		=> clk,
		data		=> data
	);
	
	dec	: PS2KB_Decoder port map (
		rst			=> rst,
		clk_50M		=> clk_50M,
		clk			=> clk,
		data			=> data,
		clk_chr		=> clk_chr,
		char			=> char
	);

end Behavioral;


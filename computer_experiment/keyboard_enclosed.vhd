----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:21:06 07/30/2015 
-- Design Name: 
-- Module Name:    keyboard_enclosed - Behavioral 
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

entity keyboard_enclosed is
    Port ( r : in  STD_LOGIC;
           data : out  STD_LOGIC_VECTOR (7 downto 0);
			  new_data : out STD_LOGIC;
			  clk_kb		: inout  STD_LOGIC;
           data_kb	: in  STD_LOGIC;
			  rst : in STD_LOGIC;
           clk50 : in  STD_LOGIC);
end keyboard_enclosed;

architecture Behavioral of keyboard_enclosed is

component PS2KB is
    Port ( rst			: in  STD_LOGIC;
           clk_50M	: in  STD_LOGIC;
           clk_kb		: inout  STD_LOGIC;
           data_kb	: in  STD_LOGIC;
           clk_chr	: out  STD_LOGIC;
           char		: out  STD_LOGIC_VECTOR (7 downto 0));
end component;

signal buff : STD_LOGIC_VECTOR(7 downto 0);
signal clk_chr : STD_LOGIC;
signal char : STD_LOGIC_VECTOR (7 downto 0);
signal fetched : STD_LOGIC;

begin
	kb : PS2KB port map (
		rst => rst,
		clk_50M => clk50,
		clk_kb => clk_kb,
		data_kb => data_kb,
		clk_chr => clk_chr,
		char => char
	);
	
	
	process(clk_chr, r, rst)
	begin
		if rst = '0' then
			buff <= x"00";
			fetched <= '1';
		elsif r = '1' then
			fetched <= '1';
		elsif clk_chr'event and clk_chr = '1' then
			buff <= char;
			fetched <= '0';
		end if;

	end process;
	
	
	
   process(r, buff, rst) 
	begin 
		
		if rst = '0' then
			data <= x"00";
		else
			data <= buff;
		end if;
		
--		if fetched = '0' then
--			data <= buff;
--		elsif fetched = '1' and r = '0' then
--			data <= x"00";
--		end if;
		--if r = '1' then
			--data <= buff;
		--end if;
	end process;
	
	new_data <= (not fetched);
end Behavioral;


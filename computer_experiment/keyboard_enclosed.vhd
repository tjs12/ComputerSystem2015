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
signal buff0 : STD_LOGIC_VECTOR(7 downto 0);
signal clk_chr : STD_LOGIC;
signal char : STD_LOGIC_VECTOR (7 downto 0);
signal status : integer := 0;
signal nextstatus : integer;
signal last_r : std_logic;

begin
	kb : PS2KB port map (
		rst => rst,
		clk_50M => clk50,
		clk_kb => clk_kb,
		data_kb => data_kb,
		clk_chr => clk_chr,
		char => char
	);
	
	--data <= buff0 when (status /= 0) else buff;
	data <= buff0 when (status /= 0) else x"00";
	process(clk_chr, char)
	begin
		if clk_chr'event and clk_chr = '1' then
			buff0 <= char;
		end if;
	end process;
	
	process(clk50, rst)
	variable nd : STD_LOGIC;
	begin

		
		if clk50'event and clk50 = '1' then
			status <= nextstatus;
		end if;
		
		if rst = '0' then
			status <= 0;
		end if;
		
		last_r <= r;
	end process;
	
	process(rst, status, buff0, clk_chr)
	begin
		if rst = '0' then
			buff <= x"00";
			--fetched <= '1';
			--status <= 0;
			new_data <= '0';
		end if;
		
		case status is
		when 0 =>
			new_data <= '0';
			buff <= x"00";
			if clk_chr = '1' then
				nextstatus <= 1;
				buff <= buff0; --NB
			else
				nextstatus <= 0;
			end if;
		when 1 =>
			new_data <= '1';
			buff <= buff0;
			nextstatus <= 2;
		when 2 =>
			if r = '1' then
				nextstatus <= 3;
				new_data <= '0';
				buff <= buff0;
			else 
				buff <= buff0;
				nextstatus <= 2;
				new_data <= '1';
			end if;
		when 3 =>
			if r = '0' then
				nextstatus <= 0;
			else 
				nextstatus <= 3;
			end if;
		when others =>
			nextstatus <= 0;
		end case;
			


	end process;
	

	
end Behavioral;


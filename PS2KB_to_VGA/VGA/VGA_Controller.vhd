----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:53:44 07/17/2015 
-- Design Name: 
-- Module Name:    VGA_Controller - Behavioral 
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

entity VGA_Controller is
	 Generic (
			  LINE_NUM	: integer := 30;
			  LINE_CHR	: integer := 80);
    Port ( rst			: in  STD_LOGIC;
			  clk_50M	: in  STD_LOGIC;
           clk_chr	: in  STD_LOGIC;
           char		: in  STD_LOGIC_VECTOR (15 downto 0);
           addr		: in  STD_LOGIC_VECTOR (18 downto 0);
           data		: out  STD_LOGIC_VECTOR (15 downto 0));
end VGA_Controller;

architecture Behavioral of VGA_Controller is
	component VGA_RAM_Text is
		port (	clka	: IN STD_LOGIC;
					wea	: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
					addra	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
					dina	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
					clkb	: IN STD_LOGIC;
					addrb	: IN STD_LOGIC_VECTOR(11 DOWNTO 0);
					doutb	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	end component;
	type IntegerArray is array (LINE_NUM-1 downto 0) of Integer range LINE_CHR downto 0;
	signal eol							: IntegerArray;
	signal prev_clk_chr				: std_logic;
	signal wea							: std_logic;
	signal new_line					: std_logic_vector(LINE_NUM-1 downto 0);
	signal addra, addrb				: std_logic_vector(11 downto 0);
	signal dina							: std_logic_vector(15 downto 0);
	signal doutb						: std_logic_vector(15 downto 0);
	signal start, line,
			 next_start, prev_line, next_line,
			 virt_line, phys_line	: Integer;-- range LINE_NUM-1 downto 0;
	signal column,
			 phys_column				: Integer;-- range LINE_CHR downto 0;
begin
	
	ram	: VGA_RAM_TEXT port map (
		clka		=> clk_50M,
		wea(0)	=> wea,
		addra		=> addra,
		dina		=> dina,
		clkb		=> not clk_50M,
		addrb		=> addrb,
		doutb		=> doutb
	);
	
	prev_clk_chr <= clk_chr when rising_edge(clk_50M);
	next_start	<= start+1 when (0 <= start and start < LINE_NUM-1) else
						0;
	prev_line	<= line-1 when (0 < line and line <= LINE_NUM-1) else
						LINE_NUM-1;
	next_line	<= line+1 when (0 <= line and line < LINE_NUM-1) else
						0;
	
	process (rst, clk_50M) begin
		if (rst = '0') then
			for i in eol'left downto eol'right loop
				eol(i) <= 0;
			end loop;
			wea <= '0';
			new_line <= (others => '0');
			start <= 0;
			line <= 0;
			column <= 0;
		elsif (rising_edge(clk_50M)) then
			if (prev_clk_chr = '0' and clk_chr = '1') then
				if (char(7 downto 0) = "00001000") then
					wea <= '0';
					if (eol(line) /= 0) then
						eol(line) <= eol(line)-1;
						column <= eol(line)-1;
					elsif (line /= start) then
						line <= prev_line;
						if (new_line(prev_line) = '1') then
							new_line(prev_line) <= '0';
							column <= eol(prev_line);
						else
							eol(prev_line) <= eol(prev_line) - 1;
							column <= eol(prev_line) - 1;
						end if;
					end if;
				elsif (char(7 downto 0) = "00001010") then
					wea <= '0';
					new_line(line) <= '1';
					eol(line) <= column;
					new_line(next_line) <= '0';
					eol(next_line) <= 0;
					line <= next_line;
					if (start = next_line) then
						start <= next_start;
					end if;
					column <= 0;
				elsif (column = LINE_CHR) then
					wea <= '1';
					dina <= char;
					addra <= conv_std_logic_vector(next_line, 5)&conv_std_logic_vector(0, 7);
					eol(line) <= column;
					line <= next_line;
					new_line(next_line) <= '0';
					eol(next_line) <= 1;
					column <= 1;
					if (start = next_line) then
						start <= next_start;
					end if;
				else
					wea <= '1';
					dina <= char;
					addra <= conv_std_logic_vector(line, 5)&conv_std_logic_vector(column, 7);
					eol(line) <= column+1;
					column <= column+1;
				end if;
			else
				wea <= '0';
			end if;
		end if;
	end process;
	
	virt_line <= CONV_INTEGER(UNSIGNED(addr(18 downto 14)));
	phys_line <= virt_line+start when virt_line+start < LINE_NUM else
					 virt_line+start-LINE_NUM;
	addrb <= conv_std_logic_vector(phys_line, 5)&addr(9 downto 3);
	phys_column <= CONV_INTEGER(UNSIGNED(addr(9 downto 3)));
	data	<= "1000000011011011" when phys_line = line and phys_column = column else
				doutb when phys_column < eol(phys_line) else
				(others => '0');

end Behavioral;


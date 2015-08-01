----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:53:44 07/17/2015 
-- Design Name: 
-- Module Name:    VGA_Render - Behavioral 
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

entity VGA_Render is
	 Generic (
			  H_PIXELS	: integer := 640;
			  V_LINES	: integer := 480);
    Port ( rst			: in	STD_LOGIC;
           clk_25M	: in 	STD_LOGIC;
			  addr		: out	STD_LOGIC_VECTOR (18 downto 0);
			  color		: in	STD_LOGIC_VECTOR (8 downto 0);
           video		: out	STD_LOGIC_VECTOR (10 downto 0));
end VGA_Render;

architecture Behavioral of VGA_Render is
	-- Horizontal timing constants
	--constant H_PIXELS			: integer := 640;		--number of pixels per line
	constant H_FRONTPORCH	: integer := 16;		--gap before sync pulse
	constant H_SYNCTIME		: integer := 96;		--width of sync pulse
	constant H_BACKPORCH		: integer := 48;		--gap after sync pulse
	constant H_SYNCSTART		: integer := H_PIXELS + H_FRONTPORCH;
	constant H_SYNCEND		: integer := H_SYNCSTART + H_SYNCTIME;
	constant H_PERIOD			: integer := H_SYNCEND + H_BACKPORCH;
        
	-- Vertical timing constants
	--constant V_LINES			: integer := 480;		--number of lines per frame
	constant V_FRONTPORCH	: integer := 10;		--gap before sync pulse
	constant V_SYNCTIME		: integer := 2;		--width of sync pulse
	constant V_BACKPORCH		: integer := 33;		--gap after sync pulse
	constant V_SYNCSTART		: integer := V_LINES + V_FRONTPORCH;
	constant V_SYNCEND		: integer := V_SYNCSTART + V_SYNCTIME;
	constant V_PERIOD			: integer := V_SYNCEND + V_BACKPORCH;

	--Internal signals
	signal hCounter			: integer;-- range H_PERIOD downto 0;	--horizontal counter of pixels
	signal vCounter			: integer;-- range V_PERIOD downto 0;	--vertical counter of lines
	signal hSync				: std_logic;			--internal horizontal sync
	signal vSync				: std_logic;			--internal vertical sync
begin

	process (rst, clk_25M) begin
		if (rst = '0') then
			hCounter <= 0;
		elsif (rising_edge(clk_25M)) then
			if (0 <= hCounter and hCounter < H_PERIOD-1) then
				hCounter <= hCounter + 1;
			else
				hCounter <= 0;
			end if;
			if (H_SYNCSTART <= hCounter and hCounter < H_SYNCEND) then
				hSync <= '0';
			else
				hSync <= '1';
			end if;
		end if;
   end process;
	
	process (rst, hSync) begin
		if (rst = '0') then
			vCounter <= 0;
		elsif (rising_edge(hSync)) then
			if (0 <= vCounter and vCounter < V_PERIOD-1) then
				vCounter <= vCounter + 1;
			else
				vCounter <= 0;
			end if;
			if (V_SYNCSTART <= vCounter and vCounter < V_SYNCEND) then
				vSync <= '0';
			else
				vSync <= '1';
			end if;
		end if;
	end process;

	process (clk_25M) begin
		if (rising_edge(clk_25M)) then
			addr <= CONV_STD_LOGIC_VECTOR(vCounter, 9)&CONV_STD_LOGIC_VECTOR(hCounter, 10);
			if (H_PIXELS <= hCounter or V_LINES <= vCounter) then
				video(8 downto 0) <= (others => '0');
			else
				video(8 downto 0) <= color;
			end if;
			video(9)		<= hSync;
			video(10)	<= vSync;
		end if;
	end process;

end Behavioral;


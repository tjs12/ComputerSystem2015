----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:59:32 07/20/2015 
-- Design Name: 
-- Module Name:    network - Behavioral 
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

entity network is
    Port ( data_enet : inout  STD_LOGIC_VECTOR (15 downto 0);
           ior : out  STD_LOGIC;
           iow : out  STD_LOGIC;
           cs : out  STD_LOGIC;
           cmd : out  STD_LOGIC;
           int : in  STD_LOGIC;
           rst_enet : out  STD_LOGIC;
           clk25 : out  STD_LOGIC;
           clk50 : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  addr : in STD_LOGIC_VECTOR(2 downto 0);
			  r : in STD_LOGIC;
			  w : in STD_LOGIC;
			  data : inout STD_LOGIC_VECTOR(15 downto 0));
end network;

architecture Behavioral of network is

	signal status : integer := 0;
	signal next_status : integer;
	
begin


	rst_enet <= rst;
	
	process(clk50)
	begin
		if clk50'event and clk50 = '1' then
			clk25 <= not clk25;
		end if;
		
		if clk25 /= '0' and clk25 /= '1' then
			clk25 <= '0';
		end if;
	end process;
	
	process(rst, clk50)
	begin
		if rst = '0' then
			status := 0;
		elsif clk50'event and clk50 = '1' then
			status <= next_status;
		end if;
	end process;
	
	process(status)
	begin
		if w = '1' then
			if addr(2 downto 0) = "000" then --register
				case status is
				when 0 =>
					cs <= '0';
					cmd <= '0';
					iow <= '0';
					next_status <= 1;
				when 1 =>
					data_enet(15 downto 0) <= data(15 downto 0);
					next_status <= 2;
				when 2 =>
					iow <= '1';
					next_status <= 3;
				end case;
				
			elsif addr(2 downto 0) = "100" then --data
				case status is
				when 3 =>
					cmd <= '1';
					iow <= '0';
					next_status <= 1;
				when 1 =>
					data_enet(15 downto 0) <= data(15 downto 0);
					next_status <= 2;
				when 2 =>
					iow <= '1';
					next_status <= 4;
				when 4 =>
					next_status <= 0;
				end case;
			end if;
			
		elsif r = '1' then
			if addr(2 downto 0) = "000" then --register
				case status is
				when 0 =>
					cs <= '0';
					cmd <= '0';
					ior <= '0';
					next_status <= 1;
				when 1 =>
					data_enet(15 downto 0) <= data(15 downto 0);
					next_status <= 2;
				when 2 =>
					ior <= '1';
					next_status <= 3;
				end case;
				
			elsif addr(2 downto 0) = "100" then --data
				case status is
				when 3 =>
					cmd <= '1';
					ior <= '0';
					next_status <= 1;
				when 1 =>
					data(15 downto 0) <= data_enet(15 downto 0);
					next_status <= 2;
				when 2 =>
					ior <= '1';
					next_status <= 4;
				when 4 =>
					next_status <= 0;
				end case;
			end if;
		end if;

	end process;

end Behavioral;


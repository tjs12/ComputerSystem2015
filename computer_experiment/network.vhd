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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


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
			  data_in : in STD_LOGIC_VECTOR(15 downto 0);
			  data_out : out STD_LOGIC_VECTOR(15 downto 0);
			  ready : out STD_LOGIC;
			  status_out : out STD_LOGIC_VECTOR(2 downto 0)
			  );
end network;

architecture Behavioral of network is

	signal status : integer := 0;
	signal next_status : integer;
	signal clk25_1, clk125 : STD_LOGIC;
	
	signal last_reg : STD_LOGIC_VECTOR(8 downto 0);
	
begin

	cs <= '0';

	rst_enet <= rst;
	
	clk25 <= clk25_1;
	
	status_out <= conv_std_logic_vector(status, 3);
	
	process(clk50)
	begin
		if clk50'event and clk50 = '1' then
			--if clk25_1 /= '0' and clk25_1 /= '1' then
				--clk25_1 <= '0';
			--else
				clk25_1 <= not clk25_1;
			--end if;
		end if;
		
		
	end process;
	
	process(clk25_1)
	begin
		if clk25_1'event and clk25_1 = '1' then
			clk125 <= not clk125;
		end if;
		if clk125 /= '0' and clk125 /= '1' then
			clk125 <= '0';
		end if;
	end process;
	
	process(rst, clk50)
	begin
		if rst = '0' then
			status <= 0;
			--ior <= '1';
			--iow <= '1';
			--cs <= '1';
		elsif clk25_1'event and clk25_1 = '1' then
			status <= next_status;
		end if;
	end process;
	
	process(status, r, w, addr, data_in, data_enet)
	begin
		ready <= '0';
		if w = '1' then
			if addr(2 downto 0) = "000" then --register
				case status is
				when 0 =>
					cmd <= '0';
					iow <= '0';
					ior <= '1';
					next_status <= 1;
				when 1 =>
					data_enet(15 downto 0) <= data_in(15 downto 0);
					last_reg (7 downto 0) <= data_in(7 downto 0);
					next_status <= 2;
				when 2 =>
					iow <= '1';
					next_status <= 3;
				when 3 =>
					iow <= '1';
					ior <= '1';
					next_status <= 3;
					ready <= '1';
				when others =>
					next_status <= 0;
				end case;
				
			elsif addr(2 downto 0) = "100" then --data
				case status is
				when 3 =>
					--cs <= '0';
					cmd <= '1';
					iow <= '0';
					--ior <= '1';
					next_status <= 1;
					data_enet(15 downto 0) <= data_in(15 downto 0);
				when 1 =>
					--iow <= '1';
					next_status <= 2;
				when 2 =>
					if last_reg(7 downto 4) = x"F" then
						next_status <= 4;
					else
						next_status <= 0;
					end if;
				when 4 =>
					next_status <= 0;
				when 0 =>
					iow <= '1';
					--ior <= '1';
					next_status <= 0;
					ready <= '1';
				when others =>
					next_status <= 3;
				end case;
			end if;
			
		elsif r = '1' then
			if addr(2 downto 0) = "000" then --register
				case status is
				when 0 =>
					cmd <= '0';
					ior <= '0';
					iow <= '1';
					next_status <= 1;
					data_enet(15 downto 0) <= "ZZZZZZZZZZZZZZZZ";
				when 1 =>
					--data_enet(15 downto 0) <= data_in(15 downto 0);
					data_out(15 downto 0) <= data_enet(15 downto 0);
					next_status <= 2;
				when 2 =>
					ior <= '1';
					next_status <= 3;
				when 3 => 
					next_status	<= 3;
					ready <= '1';
				when others =>
					next_status <= 0;
				end case;
				
			elsif addr(2 downto 0) = "100" then --data
				case status is
				when 3 =>
					cmd <= '1';
					ior <= '0';
					iow <= '1';
					next_status <= 1;
					data_enet(15 downto 0) <= "ZZZZZZZZZZZZZZZZ";
				when 1 =>
					data_out(15 downto 0) <= data_enet(15 downto 0);
					--data_enet(15 downto 0) <= "ZZZZZZZZZZZZZZZZ";
					next_status <= 5;
				when 5 =>
					--data_out(15 downto 0) <= data_enet(15 downto 0);
					next_status <= 2;
				when 2 =>
					ior <= '1';
					next_status <= 4;
				when 4 =>
					ior <= '1';
					if last_reg = x"F0" then
						next_status <= 6;
					else
						next_status <= 0;--0
					end if;
				when 6 =>
					next_status <= 7;
				when 7 => 
					next_status <= 8;
				when 8 =>
					next_status <= 0;
				when 0 =>
					ior <= '1';
					next_status <= 0;
					ready <= '1';
				when others =>
					next_status <= 3;
				end case;
			end if;
		else
			ior <= '1';
			iow <= '1';
		end if;

	end process;

end Behavioral;


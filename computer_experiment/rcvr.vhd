----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:44:47 12/01/2013 
-- Design Name: 
-- Module Name:    rcvr - Behavioral 
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
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rcvr is
port (rst,clk16x,rxd,rdn : in std_logic ;
	dout : out std_logic_vector (7 downto 0) ;
	data_ready : out std_logic ;
	framing_error : out std_logic ;
	parity_error : out std_logic 
) ;
end rcvr ;

architecture v1 of rcvr is

--signal rxd1 : std_logic ;
--signal rxd2 : std_logic ;
--signal clk1x_enable : std_logic ;
signal clkdiv :  unsigned (3 downto 0) ;
signal rsr : unsigned (7 downto 0) ;
signal rbr : unsigned (7 downto 0) ;
signal no_bits_rcvd : unsigned (3 downto 0) ;
signal parity : std_logic ;
signal clk1x : std_logic ;
signal isRead, readover : std_logic;

begin

process(rst, readover, rxd)
	begin
		if rst = '0' then
			isRead <= '0';
		elsif rxd = '0' then
			isRead <= '1';
		elsif readover'event and readover = '1' then
			isRead <= '0';
		end if;
end process;

process(rdn, readover, rst)
	begin
		if rst = '0' or rdn = '0' then
			data_ready <= '0';
		elsif readover'event and readover = '1' then
			data_ready <= '1';
		end if;
end process;

process(isRead, clk1x)
	begin
		if rst = '0' then
			readover <= '0';
			rsr <= "00000000";
			rbr <= "00000000";
			no_bits_rcvd <= "0000";
			framing_error <= '0';
			parity_error <= '0';
		elsif isRead = '0' then
			no_bits_rcvd <= "0000";
		elsif clk1x'event and clk1x = '1' then
			if std_logic_vector(no_bits_rcvd) = "0000" then
				no_bits_rcvd <= no_bits_rcvd + 1;
				readover <= '0';
				framing_error <= '0';
				parity_error <= '0';
				parity <= '1';
			elsif std_logic_vector(no_bits_rcvd) >= "0001" and std_logic_vector(no_bits_rcvd) <= "1010" then--读8个数据位和1个校验位，并进行校验位的比较
				rsr(7) <= rxd;
				rsr(6 downto 0) <= rsr(7 downto 1) ;
				parity <= parity xor rsr(7) ;
				if std_logic_vector(no_bits_rcvd) = "1001" then
					rbr <= rsr;
				end if;
				no_bits_rcvd <= no_bits_rcvd + 1;
			elsif std_logic_vector(no_bits_rcvd) = "1011" then
				if parity = '1' then
					parity_error <= '1';
					if rxd = '0' then
						framing_error <= '1';
					end if;
				end if;
				readover <= '1';
				no_bits_rcvd <= no_bits_rcvd + 1;
			end if;
			
		end if;
end process;

process(isRead ,clk16x)
	begin
		if isRead = '0' then
			clkdiv <= "0000";
		elsif clk16x'event and clk16x = '1' then
			clkdiv <= clkdiv + "0001";
		end if;
end process;

clk1x <= clkdiv(3);

--
--process (rst,clk16x)
--	begin
--		if rst = '0' then
--			rxd1 <= '1' ;
--			rxd2 <= '1' ;
--		elsif clk16x'event and clk16x = '1' then
--			rxd2 <= rxd1 ;
--			rxd1 <= rxd ;
--		end if ;
--end process ;
--
--process (rst,clk16x,rxd1,rxd2,no_bits_rcvd)
--	begin
--		if rst = '0' or std_logic_vector(no_bits_rcvd) = "1011" then
--			clk1x_enable <= '0' ;
--		elsif clk16x'event and clk16x = '1' then
--			if rxd1 = '0' and rxd2 = '1' then
--				clk1x_enable <= '1' ;
--			end if ;
--		end if ;
--end process  ;
--
--process (rst,clk16x,rdn,isRead)
--	begin
--		if rst = '0' or rdn = '0' then
--			data_ready <= '0' ;
--		elsif clk16x'event and clk16x = '1'  then
--			if isRead = '0' then
--				newdata <= '1';
--			end if;
--			if isRead = '1' and newdata = '1' then
--				data_ready <= '1' ;
--				newdata <= '0';
--			end if ;
--		end if ;
--end process ;
--
--process (rst,rdn,clk16x,clk1x_enable)
--	begin
--		if rst = '0' or clk1x_enable <= '0'  then
--			clkdiv <= "0000" ;
--		elsif clk16x'event and clk16x = '1' then
--			if clk1x_enable = '1' then
--				clkdiv <= clkdiv + "0001" ;
--			end if ;
--		end if ;
--end process ;
--
--clk1x <= clkdiv(3) ;
--
--process (clk1x,rst)
--	begin
--		if rst = '0' then
--			rsr <= "00000000" ;
--			rbr <= "00000000" ;
--			parity <= '1' ;
--			framing_error <= '0' ;
--			parity_error <= '0' ;
--			isRead <= '0';
--		elsif clk1x'event and clk1x = '1' then
--			if std_logic_vector(no_bits_rcvd) >= "0001" and std_logic_vector(no_bits_rcvd) <= "1010" then--读8个数据位和1个校验位，并进行校验位的比较
--				rsr(7) <= rxd2 ;
--				rsr(6 downto 0) <= rsr(7 downto 1) ;
--				parity <= parity xor rsr(7) ;
--
--				if std_logic_vector(no_bits_rcvd) = "0001" then
--					isRead <= '0';
--				end if;
--				if std_logic_vector(no_bits_rcvd) = "1001" then
--					rbr <= rsr ;isRead <= '1';
--				end if;
--			elsif std_logic_vector(no_bits_rcvd) = "1011" and parity = '1' then
--				parity_error <= '1' ;
--				if std_logic_vector(no_bits_rcvd) = "1011" and rxd2 = '0' then
--					framing_error <= '1' ;
--				end if;
--			end if ;
--		end if ;
--end process ;
--
--process (rst,clk1x,clk1x_enable,no_bits_rcvd)
--	begin
--		if rst = '0' or (std_logic_vector(no_bits_rcvd) = "1011" and clk1x_enable = '0') then
--			no_bits_rcvd <= "0000" ;
--		elsif clk1x'event and clk1x = '1' then
--			if clk1x_enable = '1' then
--				no_bits_rcvd <= no_bits_rcvd + "0001" ;
--			end if ;
--		end if ;
--end process ;

dout <= std_logic_vector(rbr) when rdn = '0' else "ZZZZZZZZ" ;

end ;







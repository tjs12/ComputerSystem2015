----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:32:53 12/01/2013 
-- Design Name: 
-- Module Name:    txmit - Behavioral 
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
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity txmit is
    Port ( rst : in  STD_LOGIC;
           clk16x : in  STD_LOGIC;
           wrn : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (7 downto 0);
           tbre : out  STD_LOGIC;
           tsre : out  STD_LOGIC;
			  --led : out STD_LOGIC_VECTOR(15 downto 0);
           sdo : out  STD_LOGIC);
end txmit;

architecture v1 of txmit is

signal tsr : std_logic_vector (7 downto 0) ;
signal tbr : std_logic_vector (7 downto 0) ;
signal parity :  std_logic ;
signal clkdiv :  unsigned (3 downto 0) ;
signal clk1x :  std_logic ;
signal no_bits_sent :  unsigned (3 downto 0) ;
signal tbre_t : std_logic;

begin

tbre <= not tbre_t;

process(wrn, rst, no_bits_sent)
	begin
		if rst = '0' or std_logic_vector(no_bits_sent) = "1101" then
			tbre_t <= '0';
		elsif wrn'event and wrn = '0' then
			tbre_t <= '1';
			tbr <= din;
		end if;	
end process;
process(clk1x, tbre_t)
	begin
		if tbre_t = '0' then
			no_bits_sent <= "0000";
			parity <= '1';
			sdo <= '1';
		elsif clk1x'event and clk1x = '1' then
			if std_logic_vector(no_bits_sent) = "0000" then
				no_bits_sent <= no_bits_sent + 1;
			elsif std_logic_vector(no_bits_sent) = "0001" then
				tsr <= tbr;
				tsre <= '0';
				no_bits_sent <= no_bits_sent + 1;
			elsif std_logic_vector(no_bits_sent) = "0010" then
				sdo <= '0';
				no_bits_sent <= no_bits_sent + 1;
			elsif std_logic_vector(no_bits_sent) >= "0011" and std_logic_vector(no_bits_sent) <= "1010" then
				tsr <= '0'& tsr(7 downto 1);
				sdo <= tsr(0);
				parity <= parity xor tsr(0);
				no_bits_sent <= no_bits_sent + 1;
			elsif std_logic_vector(no_bits_sent) = "1011" then
				sdo <= parity;
				no_bits_sent <= no_bits_sent + 1;
			elsif std_logic_vector(no_bits_sent) = "1100" then
				sdo <='1';
				tsre <= '1';
				no_bits_sent <= no_bits_sent + 1;
			end if;
		end if;
end process;

process (tbre_t, clk16x)
	begin
		if tbre_t = '0' then 
			clkdiv <=  "0000";
		elsif clk16x'event and clk16x = '1' then
			clkdiv <= clkdiv + "0001";
		end if;
end process;
clk1x <= not clkdiv(3);

end;
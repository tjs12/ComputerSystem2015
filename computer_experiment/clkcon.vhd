----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:40:43 12/01/2013 
-- Design Name: 
-- Module Name:    clkcon - Behavioral 
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
use ieee.std_logic_unsigned.all ;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clkcon is
    Port ( RST : in  STD_LOGIC;
           clk0 : in  STD_LOGIC;
           clk : out  STD_LOGIC);
end clkcon;

architecture v1 of clkcon is

signal cnt72 : integer;	
	
begin
process (clk0, rst)
	begin
	  if (rst='0') then
			cnt72<=0;   
	  elsif (clk0'event and clk0='1') then
												
			cnt72<=cnt72+1;
			if cnt72 = 35 then 
				  clk<='1';
				  
			elsif  cnt72=71 then
				  clk<='0';
				  cnt72<=0;
			end if;
		
		end if;
end process;
end v1;


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:17:19 07/07/2014 
-- Design Name: 
-- Module Name:    extend - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL ;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity extend is
    Port ( instruction : in  STD_LOGIC_VECTOR (31 downto 0);
           immediate : out  STD_LOGIC_VECTOR (31 downto 0));
end extend;

architecture Behavioral of extend is

begin
process(instruction)
	begin
		-- J, JAL
		if instruction(31 downto 27) = "00001" then
			immediate(1 downto 0) <= "00";
			for i IN 0 to 24 loop
				immediate(i + 2) <= instruction(i);
			end loop;
			for i IN 27 to 31 loop
				immediate(i) <= instruction(25);
			end loop;
		
		--SLL, SLLV, SRL
		elsif instruction(31 downto 21) = 0 and instruction(5 downto 2) = 0 and instruction(1 downto 0) /= "01" then
			for i IN 0 to 4 loop
				immediate(i) <= instruction(i + 6);
			end loop;
			for i IN 5 to 31 loop
				immediate(i) <= '0';
			end loop;
		
		--XORI, ORI, LUI, ANDI, SLTIU
		elsif instruction(31 downto 26) = "001110" or instruction(31 downto 26) = "001101"
			or instruction(31 downto 21) = "00111100000" or instruction(31 downto 26) = "001100"
			or instruction(31 downto 26) = "001011" then
			for i IN 0 to 15 loop
				immediate(i) <= instruction(i);
			end loop;
			for i IN 16 to 31 loop
				immediate(i) <= '0';
			end loop;
		
		--BEQ, BGEZ, BGTZ, BLEZ, BLTZ, BNE
		elsif instruction(31 downto 26) = "000100" or instruction(31 downto 26) = "000001"
			or instruction(31 downto 26) = "000111" or instruction(31 downto 26) = "000110"
			or instruction(31 downto 26) = "001110" or instruction(31 downto 26) = "000101" then
			immediate(1 downto 0) <= "00";
			for i IN 0 to 15 loop
				immediate(i + 2) <= instruction(i);
			end loop;
			for i IN 18 to 31 loop
				immediate(i) <= instruction(15);
			end loop;
			
		--others
		else
			for i IN 0 to 15 loop
				immediate(i) <= instruction(i);
			end loop;
			for i IN 16 to 31 loop
				immediate(i) <= instruction(15);
			end loop;
		
		end if;
end process;

end Behavioral;


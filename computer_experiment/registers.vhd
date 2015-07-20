----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:11:32 11/24/2013 
-- Design Name: 
-- Module Name:    reg - Behavioral 
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

entity registers is
    Port ( instruction : in  STD_LOGIC_VECTOR (31 downto 0);
           WriteData : in  STD_LOGIC_VECTOR (31 downto 0);
           ReadData1 : out  STD_LOGIC_VECTOR (31 downto 0);
           ReadData2 : out  STD_LOGIC_VECTOR (31 downto 0);
			  led : out STD_LOGIC_VECTOR(15 downto 0);
			  SW : in STD_LOGIC_VECTOR (31 downto 0);
			  PC : in STD_LOGIC_VECTOR (31 downto 0);
			  IR : in STD_LOGIC_VECTOR (31 downto 0);
			  Cause : in STD_LOGIC_VECTOR (31 downto 0);
			  Status : in STD_LOGIC_VECTOR (31 downto 0);
			  EPC : in STD_LOGIC_VECTOR (31 downto 0);
			  BadVAddr : in STD_LOGIC_VECTOR (31 downto 0);
           RegWrite : in  STD_LOGIC);
end registers;

architecture Behavioral of registers is

type asarray is array(31 downto 0) of std_logic_vector(31 downto 0);
signal reg : asarray;

begin

--led(14 downto 8) <= reg(17)(6 downto 0);
--led(15) <= RegWrite;
process(instruction, reg)
	begin
		if instruction(25 downto 21) = 0 then
			ReadData1 <= x"00000000";
		else
			ReadData1 <= reg(CONV_INTEGER(instruction(25 downto 21)));
		end if;
end process;

process(instruction, reg)
	begin
		if instruction(20 downto 16) = 0 then
			ReadData2 <= x"00000000";
		else
			ReadData2 <= reg(CONV_INTEGER(instruction(20 downto 16)));
		end if;
end process;
		
process(RegWrite, instruction, WriteData)
	begin
		if RegWrite = '1' then
			if instruction(31 downto 26) = "000011" then
				reg(31) <= WriteData;
			elsif instruction(31 downto 26) = "000000" then
				reg(CONV_INTEGER(instruction(15 downto 11))) <= WriteData;
			else
				reg(CONV_INTEGER(instruction(20 downto 16))) <= WriteData;
			end if;
		end if;
end process;

process(SW, PC, IR, reg, Cause, Status, EPC, BadVAddr)
	begin
		if SW(6) = '1' then
			case SW(5 downto 1) is
				when "00000" =>
					if SW(0) = '0' then
						led <= PC(15 downto 0);
					else
						led <= PC(31 downto 16);
					end if; 
				when "00001" =>
					if SW(0) = '0' then
						led <= IR(15 downto 0);
					else
						led <= IR(31 downto 16);
					end if; 
				when "00010" =>
					if SW(0) = '0' then
						led <= Cause(15 downto 0);
					else
						led <= Cause(31 downto 16);
					end if; 
				when "00011" =>
					if SW(0) = '0' then
						led <= Status(15 downto 0);
					else
						led <= Status(31 downto 16);
					end if; 
				when "00100" =>
					if SW(0) = '0' then
						led <= EPC(15 downto 0);
					else
						led <= EPC(31 downto 16);
					end if; 
				when "00101" =>
					if SW(0) = '0' then
						led <= BadVAddr(15 downto 0);
					else
						led <= BadVAddr(31 downto 16);
					end if; 
				when others =>
					led <= x"0000";
			end case;
		else
			if SW(0) = '0' then
				led <= reg(CONV_INTEGER(SW(5 downto 1)))(15 downto 0);
			else
				led <= reg(CONV_INTEGER(SW(5 downto 1)))(31 downto 16);
			end if;
		end if;
end process;
end Behavioral;


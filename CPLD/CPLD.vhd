----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:27:42 10/30/2014 
-- Design Name: 
-- Module Name:    CPLD - Behavioral 
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

entity CPLD is
    Port ( rxd : in  STD_LOGIC;
           txd : out  STD_LOGIC;
           pass_rxd : out  STD_LOGIC;
           pass_txd : in  STD_LOGIC;
			  ps2kb_clock : inout  STD_LOGIC;
			  ps2kb_data : in  STD_LOGIC;
			  pass_ps2kb_clock : inout  STD_LOGIC;
			  pass_ps2kb_data : out  STD_LOGIC);
end CPLD;

architecture Behavioral of CPLD is

begin

	pass_rxd <= rxd;
	txd <= pass_txd;
	
	pass_ps2kb_clock <= ps2kb_clock;
	pass_ps2kb_data <= ps2kb_data;

end Behavioral;


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:17:12 07/09/2014 
-- Design Name: 
-- Module Name:    mmu - Behavioral 
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

entity mmu is
	Port ( RST : in STD_LOGIC;
			 Index : in  STD_LOGIC_VECTOR (31 downto 0);
			 EntryLo0 : in  STD_LOGIC_VECTOR (31 downto 0);
          EntryLo1 : in  STD_LOGIC_VECTOR (31 downto 0);
			 EntryHi : in STD_LOGIC_VECTOR (31 downto 0);
			 Status : in STD_LOGIC_VECTOR (31 downto 0);
			 Vaddr : in STD_LOGIC_VECTOR (31 downto 0);
			 Paddr : out STD_LOGIC_VECTOR (31 downto 0);
			 DYP2 : out STD_LOGIC_VECTOR (2 downto 0) := "000";
			 flag_missing : out STD_LOGIC;
			 flag_writable : out STD_LOGIC;
			 --led : out STD_LOGIC_VECTOR(15 downto 0);
			 tlb_write : in STD_LOGIC);
end mmu;

architecture Behavioral of mmu is
type tlbarray is array(15 downto 0) of std_logic_vector(62 downto 0);
signal tlb : tlbarray := (others => (others => '0'));
begin
--led(15 downto 12) <= Index(3 downto 0);
--led(11 downto 8) <= EntryHi(3 downto 0);
--led(7 downto 4) <= tlb(0)(3 downto 0);
--led(3 downto 0) <= EntryLo0(3 downto 0);
process(Vaddr, tlb)
	begin
		if Vaddr >= x"80000000" and Vaddr < x"c0000000" then
			Paddr(28 downto 0) <= Vaddr(28 downto 0);
			Paddr(31 downto 29) <= "000";
			flag_missing <= '0';
			flag_writable <= '1';
			DYP2(2 downto 1) <= "00";
		else
			flag_missing <= '1';
			Paddr(11 downto 0) <= Vaddr(11 downto 0);
			--DYP2(0) <= '1';
			for i IN 0 to 15 loop
				if tlb(i)(62 downto 44) = Vaddr(31 downto 13) then
					DYP2(1) <= '1';
					if Vaddr(12) = '1' and tlb(i)(22) = '1' then
						DYP2(2) <= '1';
						Paddr(31 downto 12) <= tlb(i)(43 downto 24);
						flag_writable <= tlb(i)(23);
						flag_missing <= '0';
						exit;
					elsif Vaddr(12) = '0' and tlb(i)(0) = '1' then
						DYP2(2) <= '0';
						Paddr(31 downto 12) <= tlb(i)(21 downto 2);
						flag_writable <= tlb(i)(1);
						flag_missing <= '0';
						exit;
					end if;
				end if;
			end loop;
		end if;
end process;

DYP2(0) <= tlb_write;

process(tlb_write, RST, EntryHi, EntryLo0, EntryLo1, Index)
	begin
		if RST = '0' then
			tlb <= (others => (others => '0'));
		elsif tlb_write = '1' then
			tlb(CONV_INTEGER(Index(3 downto 0)))(62 downto 44) <= EntryHi(31 downto 13);
			tlb(CONV_INTEGER(Index(3 downto 0)))(43 downto 24) <= EntryLo1(25 downto 6);
			tlb(CONV_INTEGER(Index(3 downto 0)))(23 downto 22) <= EntryLo1(2 downto 1);
			tlb(CONV_INTEGER(Index(3 downto 0)))(21 downto 2) <= EntryLo0(25 downto 6);
			tlb(CONV_INTEGER(Index(3 downto 0)))(1 downto 0) <= EntryLo0(2 downto 1);
		end if;
end process;

end Behavioral;


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:29:40 07/02/2014 
-- Design Name: 
-- Module Name:    phy_mem - Behavioral 
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

entity phy_mem is
	Port ( CLK : in STD_LOGIC;
			 RST : in STD_LOGIC;
			 MemRead : in  STD_LOGIC;
          MemWrite : in  STD_LOGIC;
			 ready : out STD_LOGIC;
			 Vaddr : in STD_LOGIC_VECTOR (31 downto 0);
			 data_read : out STD_LOGIC_VECTOR (31 downto 0);
			 data_write : in STD_LOGIC_VECTOR (31 downto 0);
			 DYP2 : out STD_LOGIC_VECTOR (6 downto 0);
			 mem_error : out STD_LOGIC_VECTOR (1 downto 0);
			 --led : out STD_LOGIC_VECTOR(15 downto 0);
			 
			 Ram1EN : out  STD_LOGIC;
          Ram1OE : out  STD_LOGIC;
          Ram1WE : out  STD_LOGIC;
			 Ram1Addr : out  STD_LOGIC_VECTOR (19 downto 0);
			 Ram1Data : inout  STD_LOGIC_VECTOR (31 downto 0);
			 Ram2EN : out  STD_LOGIC;
          Ram2OE : out  STD_LOGIC;
          Ram2WE : out  STD_LOGIC;
			 Ram2Addr : out  STD_LOGIC_VECTOR (19 downto 0);
			 Ram2Data : inout  STD_LOGIC_VECTOR (31 downto 0);
			 
			 FlashCE : out  STD_LOGIC_VECTOR (2 downto 0);
          FlashBYTE : out  STD_LOGIC;
          FlashRP : out  STD_LOGIC;
          FlashOE : out  STD_LOGIC;
          FlashWE : out  STD_LOGIC;
			 FlashVPEN : out  STD_LOGIC;
          FlashAddr : out  STD_LOGIC_VECTOR (22 downto 0);
          FlashData : inout  STD_LOGIC_VECTOR (15 downto 0);
			 
			 Index : in  STD_LOGIC_VECTOR (31 downto 0);
			 EntryLo0 : in  STD_LOGIC_VECTOR (31 downto 0);
			 EntryLo1 : in  STD_LOGIC_VECTOR (31 downto 0);
			 EntryHi : in STD_LOGIC_VECTOR (31 downto 0);
			 Status : in STD_LOGIC_VECTOR (31 downto 0);
			 tlb_write : in STD_LOGIC;
			 BadVAddr : out STD_LOGIC_VECTOR (31 downto 0);
			 
			 enet_data : inout STD_LOGIC_VECTOR(15 downto 0);
			 enet_cmd : out STD_LOGIC;
			 enet_cs : out STD_LOGIC;
			 enet_int : in STD_LOGIC;
			 enet_ior : out STD_LOGIC;
			 enet_iow : out STD_LOGIC;
			 enet_reset : out STD_LOGIC;
			 clk_25 : out STD_LOGIC;
			 clk_50 : in STD_LOGIC;
			 
			 CLK11 : in STD_LOGIC;
			 com_int : out STD_LOGIC;
			 u_txd : in std_logic;
			 u_rxd : out std_logic
	);
end phy_mem;

architecture Behavioral of phy_mem is
	signal condi : STD_LOGIC_VECTOR (5 downto 0);
	
	signal ComDataIn, ComDataOut : std_logic_vector(7 downto 0);
	signal data_ready, wrn, rdn, tbre : std_logic;
	signal tsre, pe, fe : std_logic;
	
	type bytearray is array(1024 downto 0) of std_logic_vector(7 downto 0);
	signal ComBuffer : bytearray;
	signal head :  STD_LOGIC_VECTOR(9 downto 0);
	signal tail :  STD_LOGIC_VECTOR(9 downto 0);
	signal cond : STD_LOGIC_VECTOR (1 downto 0);
	signal rcvrrst : STD_LOGIC;
	signal txmtrst : STD_LOGIC;
	
	component uart is
	PORT (
		rst,clk,rxd,rdn,wrn : in std_logic;
		data_in : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0);
		data_ready : out std_logic;
		parity_error : out std_logic;
		framing_error : out std_logic;
		tbre : out std_logic;
		tsre : out std_logic;
		rcvrrst : in STD_LOGIC;
		txmtrst : in STD_LOGIC;
		--led : out STD_LOGIC_VECTOR(15 downto 0);
		sdo : out std_logic
	);
	end component;
	
	component mmu is
	PORT (
		RST : in STD_LOGIC;
		Index : in  STD_LOGIC_VECTOR (31 downto 0);
		EntryLo0 : in  STD_LOGIC_VECTOR (31 downto 0);
      EntryLo1 : in  STD_LOGIC_VECTOR (31 downto 0);
		EntryHi : in STD_LOGIC_VECTOR (31 downto 0);
		Status : in STD_LOGIC_VECTOR (31 downto 0);
		Vaddr : in STD_LOGIC_VECTOR (31 downto 0);
		Paddr : out STD_LOGIC_VECTOR (31 downto 0);
		flag_missing : out STD_LOGIC;
		DYP2 : out STD_LOGIC_VECTOR (2 downto 0);
		flag_writable : out STD_LOGIC;
		--led : out STD_LOGIC_VECTOR(15 downto 0);
		tlb_write : in STD_LOGIC
	);
	end component;
	
	component network is
	PORT (
			  data_enet : inout  STD_LOGIC_VECTOR (15 downto 0);
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
			  status_out : out STD_LOGIC_VECTOR(2 downto 0));
	end component;
	
	signal netr, netw : STD_LOGIC;
	signal nd_in, nd_out : STD_LOGIC_VECTOR(15 downto 0);
	signal n_st : STD_LOGIC_VECTOR(2 downto 0);
	
	

	
	signal Paddr : STD_LOGIC_VECTOR (31 downto 0);
	signal flag_missing : STD_LOGIC;
	signal flag_writable : STD_LOGIC;
	signal addr : STD_LOGIC_VECTOR (31 downto 0);

	component rom is
	Port ( addr : in  STD_LOGIC_VECTOR (11 downto 0);
          data : out  STD_LOGIC_VECTOR (31 downto 0)
	);
	end component;
	signal RomData :  STD_LOGIC_VECTOR(31 downto 0);

begin

	uart1 : uart port map (
		RST => RST,
		rcvrrst => rcvrrst,
		txmtrst => txmtrst,
		CLK => CLK11,
		rdn => rdn,
		wrn => wrn,
		data_in => ComDataIn,
		data_out => ComDataOut,
		data_ready => data_ready,
		parity_error => pe,
		framing_error => fe,
		tbre => tbre,
		tsre => tsre,
		--led => led,
		rxd => u_txd,
		sdo => u_rxd
	);
	
	mmu1 : mmu port map (
		RST => RST,
		Index => Index,
		EntryLo0 => EntryLo0,
      EntryLo1 => EntryLo1,
		EntryHi => EntryHi,
		Status => Status,
		Vaddr => Vaddr,
		Paddr => addr,
		flag_missing => flag_missing,
		flag_writable => flag_writable,
		DYP2 => DYP2(6 downto 4),
		--led => led,
		tlb_write => tlb_write
	);
	
	rom1 : rom port map (
		addr => addr(11 downto 0),
		data => RomData
	);

	
	net : network
	PORT MAP(
			  data_enet => enet_data,
           ior => enet_ior,
           iow => enet_iow,
           cs => enet_cs,
           cmd => enet_cmd,
           int => enet_int,
           rst_enet => enet_reset,
           clk25 => clk_25,
           clk50 => clk_50,
           rst => rst,
			  addr => addr(2 downto 0),
			  r => netr,
			  w => netw,
			  data_in => nd_in,
			  data_out => nd_out,
			  status_out => n_st
	);
			  
--RomAddr <= addr(11 downto 0);
--RomData <= addr;
--led <= condi;
--DYP2(1 downto 0) <= tail(1 downto 0);
DYP2(3 downto 2) <= head(1 downto 0);
DYP2(0) <= tsre;
DYP2(1) <= tbre;
--DYP2(6) <= '0';

FlashCE <= "000";
FlashVPEN <= '1';
FlashRP <= '1';
FlashBYTE <= '1';

process(RST, CLK, MemRead, MemWrite)
	begin
		if RST = '0' then
			condi <= "111111";
			tail <= "0000000000";
			ready <= '0';
			mem_error <= "00";
			--wrn <= '1';
		elsif MemRead = '0' and MemWrite = '0' then
			Ram1EN <= '1';
			Ram2EN <= '1';
			FlashOE <= '1';
			FlashWE <= '1';
			condi <= "111111";
			ready <= '0';
			--wrn <= '1';
			mem_error <= "00";
			netr <= '0';
			netw <= '0';
		elsif CLK'event and CLK = '1' then
			if condi = "111111" then
				if (Vaddr(31) = '1' and Status(4) = '1' and Status(1) = '0') 
					or Vaddr(1 downto 0) /= "00" then
					BadVAddr <= Vaddr;
					ready <= '1';
					mem_error <= "11";
				elsif flag_missing = '1' then
					BadVAddr <= Vaddr;
					ready <= '1';
					mem_error <= "01";
				elsif flag_writable = '0' and MemWrite = '1' then
					BadVAddr <= Vaddr;
					ready <= '1';
					mem_error <= "10";
				else
					condi <= "000000";
				end if;
			elsif addr >= x"00000000" and addr < x"00400000" then	--RAM1
				if MemRead = '1' then --read RAM1
					if condi = 0 then
						Ram1WE <= '1';
						Ram1OE <= '0';
						Ram1Data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
						Ram1Addr <= addr(21 downto 2);
						Ram1EN <= '0';
						--ready <= '0';
						condi <= condi + 1;
					elsif condi = 1 then
						data_read <= Ram1Data;
						ready <= '1';
						condi <= condi + 1;
					end if;
					
				elsif MemWrite = '1' then --write RAM1
					if condi = 0 then
						ready <= '0';
						Ram1WE <= '1';
						Ram1OE <= '1';
						Ram1EN <= '0';
						Ram1Addr <= addr(21 downto 2);
						Ram1Data <= data_write;
						condi <= condi + 1;
					elsif condi = 1 then
						condi <= condi + 1;
					elsif condi = 2 then
						Ram1WE <= '0';
						condi <= condi + 1;
					elsif condi = 3 then
						condi <= condi + 1;
					elsif condi = 4 then
						Ram1WE <= '1';
						condi <= condi + 1;
					elsif condi = 5 then
						condi <= condi + 1;
					elsif condi = 6 then
						ready <= '1';
						condi <= condi + 1;
					end if;
				end if;
				
			elsif addr >= x"00400000" and addr < x"00800000" then	--RAM2
				if MemRead = '1' then --read RAM2
					if condi = 0 then
						Ram2WE <= '1';
						Ram2OE <= '0';
						Ram2Data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
						Ram2Addr <= addr(21 downto 2);
						Ram2EN <= '0';
						--ready <= '0';
						condi <= condi + 1;
					elsif condi = 1 then
						data_read <= Ram2Data;
						ready <= '1';
						condi <= condi + 1;
					end if;
					
				elsif MemWrite = '1' then --write RAM2
					if condi = 0 then
						ready <= '0';
						Ram2WE <= '1';
						Ram2OE <= '1';
						Ram2EN <= '0';
						Ram2Addr <= addr(21 downto 2);
						Ram2Data <= data_write;
						condi <= condi + 1;
					elsif condi = 1 then
						condi <= condi + 1;
					elsif condi = 2 then
						Ram2WE <= '0';
						condi <= condi + 1;
					elsif condi = 3 then
						condi <= condi + 1;
					elsif condi = 4 then
						Ram2WE <= '1';
						condi <= condi + 1;
					elsif condi = 5 then
						condi <= condi + 1;
					elsif condi = 6 then
						ready <= '1';
						condi <= condi + 1;
					end if;
				end if;
				
			elsif addr >= x"1FC00000" and addr < x"1FC01000" then --片上ROM
				ready <= '1';
				data_read <= RomData;
			elsif addr >= x"1E000000" and addr < x"1F000000" then --FLASH
				if MemRead = '1' then --read Flash
					if condi = 0 then
						ready <= '0';
						FlashWE <= '0';
						FlashData <= x"00FF";
						condi <= condi + 1;
					elsif condi = 1 then
						FlashWE <= '1';
						condi <= condi + 1;
					elsif condi = 2 then
						FlashOE <= '0';
						condi <= condi + 1;
					elsif condi = 3 then
						FlashAddr <= addr(22 downto 2) & "00";
						FlashData <= "ZZZZZZZZZZZZZZZZ";
						condi <= condi + 1;
					elsif condi >= 4 and condi < 7 then
						condi <= condi + 1;
					elsif condi = 7 then
						data_read(15 downto 0) <= FlashData;
						condi <= condi + 1;
					elsif condi >= 8 and condi < 13 then
						condi <= condi + 1;
					elsif condi = 13 then
						FlashAddr <= addr(22 downto 2) & "10";
						FlashData <= "ZZZZZZZZZZZZZZZZ";
						condi <= condi + 1;
					elsif condi >= 14 and condi < 20 then
						condi <= condi + 1;
					elsif condi = 20 then
						data_read(31 downto 16) <= FlashData;
						condi <= condi + 1;
					elsif condi = 21 then
						ready <= '1';
						FlashOE <= '1';
						condi <= condi + 1;
					end if;
					
				elsif MemWrite = '1' then -- write Flash
					if addr(16 downto 1) = 0 then
						if condi = 0 then
							ready <= '0';
							FlashData <= x"0020";
							FlashWE <= '0';
							FlashOE <= '1';
							condi <= condi + 1;
						elsif condi = 1 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 2 then
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 3 then
							FlashWE <= '0';
							FlashAddr <= addr(22 downto 1) & '0';
							FlashData <= x"00D0";
							condi <= condi + 1;
						elsif condi = 4 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 5 then
							FlashData <= x"0070";
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 6 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 7 then
							FlashData <= "ZZZZZZZZZZZZZZZZ";
							FlashOE <= '0';
							condi <= condi + 1;
						elsif condi = 8 then
							FlashOE <= '1';
							if FlashData(7) = '1' then
								condi <= condi + 1;
							else
								condi <= "000101";
							end if;
						elsif condi = 9 then
							FlashData <= x"0020";
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 10 then
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 11 then
							FlashAddr <= (addr(22 downto 1) + 1) & '0';
							FlashData <= x"00D0";
							condi <= condi + 1;
						elsif condi = 12 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 13 then
							FlashData <= x"0070";
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 14 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 15 then
							FlashData <= "ZZZZZZZZZZZZZZZZ";
							FlashOE <= '0';
							condi <= condi + 1;
						elsif condi = 16 then
							FlashOE <= '1';
							if FlashData(7) = '1' then
								condi <= condi + 1;
							else
								condi <= "001101";
							end if;
						elsif condi = 17 then
							FlashData <= x"0040";
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 18 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 19 then
							FlashAddr <= addr(22 downto 1) & '0';
							FlashData <= data_write(15 downto 0);
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 20 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 21 then
							FlashWE <= '0';
							FlashData <= x"0070";
							condi <= condi + 1;
						elsif condi = 22 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 23 then
							FlashData <= "ZZZZZZZZZZZZZZZZ";
							FlashOE <= '0';
							condi <= condi + 1;
						elsif condi = 24 then
							FlashOE <= '1';
							if FlashData(7) = '1' then
								condi <= condi + 1;
							else
								condi <= "010101";
							end if;
						elsif condi = 25 then
							FlashData <= x"0040";
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 26 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 27 then
							FlashAddr <= (addr(22 downto 1) + 1) & '0';
							FlashData <= data_write(31 downto 16);
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 28 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 29 then
							FlashWE <= '0';
							FlashData <= x"0070";
							condi <= condi + 1;
						elsif condi = 30 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 31 then
							FlashData <= "ZZZZZZZZZZZZZZZZ";
							FlashOE <= '0';
							condi <= condi + 1;
						elsif condi = 32 then
							FlashOE <= '1';
							if FlashData(7) = '1' then
								ready <= '1';
								condi <= condi + 1;
							else
								condi <= "011101";
							end if;
						end if;
					else
						if condi = 0 then
							ready <= '0';
							FlashOE <= '1';
							FlashData <= x"0040";
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 1 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 2 then
							FlashAddr <= addr(22 downto 1) & '0';
							FlashData <= data_write(15 downto 0);
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 3 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 4 then
							FlashWE <= '0';
							FlashData <= x"0070";
							condi <= condi + 1;
						elsif condi = 5 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 6 then
							FlashData <= "ZZZZZZZZZZZZZZZZ";
							FlashOE <= '0';
							condi <= condi + 1;
						elsif condi = 7 then
							FlashOE <= '1';
							if FlashData(7) = '1' then
								condi <= condi + 1;
							else
								condi <= "000100";
							end if;
						elsif condi = 8 then
							FlashData <= x"0040";
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 9 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 10 then
							FlashAddr <= (addr(22 downto 1) + 1) & '0';
							FlashData <= data_write(31 downto 16);
							FlashWE <= '0';
							condi <= condi + 1;
						elsif condi = 11 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 12 then
							FlashWE <= '0';
							FlashData <= x"0070";
							condi <= condi + 1;
						elsif condi = 13 then
							FlashWE <= '1';
							condi <= condi + 1;
						elsif condi = 14 then
							FlashData <= "ZZZZZZZZZZZZZZZZ";
							FlashOE <= '0';
							condi <= condi + 1;
						elsif condi = 15 then
							FlashOE <= '1';
							if FlashData(7) = '1' then
								ready <= '1';
								condi <= condi + 1;
							else
								condi <= "001100";
							end if;
						end if;
					end if;
				end if;
				
			elsif addr = x"1FD003F8" then --串口1数据
				if MemRead = '1' then --read 串口1
					if condi = 0 then
						if tail /= head then
							data_read <= x"000000" & ComBuffer(CONV_INTEGER(tail));
							condi <= condi + 1;
						end if;
						ready <= '0';
					elsif condi = 1 then
						tail <= tail + 1;
						ready <= '1';
						condi <= condi + 1;
					end if;
					
				elsif MemWrite = '1' then --write 串口1
					if condi = 0 then
						ComDataIn <= data_write(7 downto 0);
						condi <= condi + 1;
						wrn <= '1';
						--ready <= '0';
--					elsif condi < 1 then
--						
--						condi <= condi + 1;
					elsif condi = 1 then
						--ComDataIn <= data_write(7 downto 0);
						wrn <= '0';
						condi <= condi + 1;
					elsif condi < 3 then
						condi <= condi + 1;
					elsif condi = 3 then
						wrn <= '1';
						ready <= '1';
						--wrn <= '0';
						--ComDataIn <= data_write(7 downto 0);
						condi <= condi + 1;
--					elsif condi < 10 then
--						condi <= condi + 1;
--					elsif condi = 10 then
--						--wrn <= '1';
--						ready <= '1';
--						condi <= condi + 1;
					end if;
				end if; 
				
			elsif addr = x"1FD003FC" then	--串口1状态
				if condi = 0 then
					data_read(0) <= tbre and tsre;
					if head /= tail then
						data_read(1) <= '1';
					else
						data_read(1) <= '0';
					end if;
					data_read(11 downto 2) <= head - tail;
					data_read(31) <= pe;
					data_read(30) <= fe;
					condi <= condi + 1;
				elsif condi = 1 then
					ready <= '1';
					condi <= condi + 1;
				end if;
				
			elsif addr = x"1FD003400" then --网口INDEX
				if MemRead = '1' then
					netr <= '1';
					netw <= '0';
					if n_st = "011" then
						data_read(15 downto 0) <= nd_out;
						data_read(31 downto 16) <= x"0000";
						ready <= '1';
					else
						ready <= '0';
					end if;
				elsif MemWrite = '1' then
					netr <= '0';
					netw <= '1';
					nd_in <= data_write(15 downto 0);
					if n_st = "011" then
						ready <= '1';
					else
						ready <= '0';
					end if;
				end if;
			elsif addr = x"1FD003404" then --网口DATA
				if MemRead = '1' then
					netr <= '1';
					netw <= '0';
					if n_st = "000" then
						data_read(15 downto 0) <= nd_out;
						data_read(31 downto 16) <= x"0000";
						ready <= '1';
					else
						ready <= '0';
					end if;
				elsif MemWrite = '1' then
					netr <= '0';
					netw <= '1';
					nd_in <= data_write(15 downto 0);
					if n_st = "000" then
						ready <= '1';
					else
						ready <= '0';
					end if;
				end if;
			else
				BadVAddr <= Vaddr;
				mem_error <= "11";
				ready <= '1';
			end if;
		end if;
end process;

--process(head, tail)
--	begin
--		if head /= tail then
--			com_int <= '1';
--		else
--			com_int <= '0';
--		end if;
--end process;
com_int <= '1' when head /= tail else '0';
rcvrrst <= '0' when cond = 3 or RST = '0' else '1';
--txmtrst <= '1' when ((MemWrite = '1' or tsre = '0') and RST = '1') else '0';
--rcvrrst <= RST;
txmtrst <= RST;

process(CLK, RST)
	begin
		if RST = '0' then
			head <= "0000000000";
			cond <= "00";
			--ComBuffer <= (others => (others => 'Z'));
			rdn <= '1';
		elsif CLK'event and CLK = '1'  then
			if cond = 0 then
				rdn <= '1';
				ComBuffer(CONV_INTEGER(head)) <= "ZZZZZZZZ";
				cond <= cond + 1;
			elsif cond = 1 then
				if data_ready = '1' then
					rdn <= '0';
					cond <= cond + 1;
				else
					cond <= "00";
				end if;
			elsif cond = 2 then
				ComBuffer(CONV_INTEGER(head)) <= ComDataOut;
				rdn <= '1';
				cond <= cond + 1;
			elsif cond = 3 then
				if head /= tail - 1 then
					head <= head + 1;
				end if;
				cond <= cond + 1;
			end if;
		end if;
end process;

end Behavioral;


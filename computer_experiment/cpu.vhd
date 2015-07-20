----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:03:07 07/01/2014 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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

entity cpu is
    Port ( RST : in  STD_LOGIC;
           CLK50 : in  STD_LOGIC;
			  CLKh : in  STD_LOGIC;
			  led : out STD_LOGIC_VECTOR (15 downto 0);
			  SW : in STD_LOGIC_VECTOR (31 downto 0);
			  KEY : in STD_LOGIC_VECTOR (3 downto 0);
			  DYP1 : out STD_LOGIC_VECTOR (6 downto 0);
			  DYP2 : out STD_LOGIC_VECTOR (6 downto 0);
			  
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
			 
			  CLK11 : in STD_LOGIC;
			  u_txd : in std_logic;
			  u_rxd : out std_logic
			  );
end cpu;

architecture Behavioral of cpu is

	signal Hi : STD_LOGIC_VECTOR (31 downto 0);
	signal Lo : STD_LOGIC_VECTOR (31 downto 0);
	signal condi : STD_LOGIC_VECTOR (4 downto 0);
	signal RegWrite : STD_LOGIC;
	signal IR : STD_LOGIC_VECTOR (31 downto 0);
	signal PC : STD_LOGIC_VECTOR (31 downto 0);
	signal timer_int : STD_LOGIC := '0';
	signal com_int : STD_LOGIC := '0';
	signal exc_code : STD_LOGIC_VECTOR (4 downto 0);
	signal CLK : STD_LOGIC;
	signal CLKx : STD_LOGIC;
	signal CLKsi : STD_LOGIC;
	
	signal Index : STD_LOGIC_VECTOR (31 downto 0);			--0
	signal EntryLo0 : STD_LOGIC_VECTOR (31 downto 0);		--2
	signal EntryLo1 : STD_LOGIC_VECTOR (31 downto 0);		--3
	signal BadVAddr : STD_LOGIC_VECTOR (31 downto 0);		--8
	signal Count : STD_LOGIC_VECTOR (31 downto 0) := x"00000000";--9
	signal EntryHi : STD_LOGIC_VECTOR (31 downto 0);		--10
	signal Compare : STD_LOGIC_VECTOR (31 downto 0);		--11
	signal Status : STD_LOGIC_VECTOR (31 downto 0);			--12
	signal Cause : STD_LOGIC_VECTOR (31 downto 0);			--13
	signal EPC : STD_LOGIC_VECTOR (31 downto 0);				--14
	signal EBase : STD_LOGIC_VECTOR (31 downto 0) := x"80000000";--15(not real)

	component multiplication is
	PORT (
		RST : in  STD_LOGIC;
		CLK : in  STD_LOGIC;
      start : in  STD_LOGIC;
      ready : out  STD_LOGIC;
      A : in  STD_LOGIC_VECTOR (31 downto 0);
      B : in  STD_LOGIC_VECTOR (31 downto 0);
      R : out  STD_LOGIC_VECTOR (63 downto 0)
	);
	end component;
	signal mult_start : STD_LOGIC;
	signal mult_ready : STD_LOGIC;
	signal mult_A : STD_LOGIC_VECTOR (31 downto 0);
	signal mult_B : STD_LOGIC_VECTOR (31 downto 0);
	signal mult_R : STD_LOGIC_VECTOR (63 downto 0);
	
	component alu is
	Port (
		A : in  STD_LOGIC_VECTOR (31 downto 0);
      B : in  STD_LOGIC_VECTOR (31 downto 0);
      R : out  STD_LOGIC_VECTOR (31 downto 0);
      opt : in  STD_LOGIC_VECTOR (3 downto 0)
	);
	end component;
	signal alu_A : STD_LOGIC_VECTOR (31 downto 0);
	signal alu_B : STD_LOGIC_VECTOR (31 downto 0);
	signal alu_R : STD_LOGIC_VECTOR (31 downto 0);
	signal alu_opt : STD_LOGIC_VECTOR (3 downto 0);

	
	component registers is
	Port (
		instruction : in  STD_LOGIC_VECTOR (31 downto 0);
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
      RegWrite : in  STD_LOGIC
	);
	end component;
	signal reg_WriteData : STD_LOGIC_VECTOR(31 downto 0);
	signal reg_ReadData1 : STD_LOGIC_VECTOR(31 downto 0);
	signal reg_ReadData2 : STD_LOGIC_VECTOR(31 downto 0);
	
	
	component phy_mem is
	Port ( 
			 CLK : in STD_LOGIC;
			 RST : in STD_LOGIC;
			 MemRead : in  STD_LOGIC;
          MemWrite : in  STD_LOGIC;
			 ready : out STD_LOGIC;
			 Vaddr : in STD_LOGIC_VECTOR (31 downto 0);
			 data_read : out STD_LOGIC_VECTOR (31 downto 0);
			 data_write : in STD_LOGIC_VECTOR (31 downto 0);
			 
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
			 DYP2 : out STD_LOGIC_VECTOR(6 downto 0);
			 mem_error : out STD_LOGIC_VECTOR (1 downto 0);
			 --led : out STD_LOGIC_VECTOR(15 downto 0);
			 
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
			 
			 CLK11 : in STD_LOGIC;
			 com_int : out STD_LOGIC;
			 u_txd : in std_logic;
			 u_rxd : out std_logic
	);
	end component;
	signal MemRead : STD_LOGIC;
	signal MemWrite : STD_LOGIC;
	signal mem_ready : STD_LOGIC;
	--attribute KEEP : string;
	signal mem_addr : STD_LOGIC_VECTOR(31 downto 0);
	--attribute KEEP of mem_addr: signal is "TRUE";
	signal mem_data_read : STD_LOGIC_VECTOR(31 downto 0);
	signal mem_data_write : STD_LOGIC_VECTOR(31 downto 0);
	--attribute KEEP of mem_data_write: signal is "TRUE";
	signal tlb_write : STD_LOGIC;
	signal mem_error : STD_LOGIC_VECTOR (1 downto 0);
	
	
	component extend is
   Port ( instruction : in  STD_LOGIC_VECTOR (31 downto 0);
          immediate : out  STD_LOGIC_VECTOR (31 downto 0)
	);
	end component;
	signal immediate_extend : STD_LOGIC_VECTOR (31 downto 0);
	
begin

	multiplication1 : multiplication PORT MAP(
		RST => RST,
		CLK => CLK,
		start => mult_start,
		ready => mult_ready,
		A => mult_A,
		B => mult_B,
		R => mult_R
	);
	
	
	alu1 : alu PORT MAP ( 
		A => alu_A,
      B => alu_B,
      R => alu_R,
      opt => alu_opt
	);


	registers1 : registers PORT MAP(
		instruction => IR,
      WriteData => reg_WriteData,
      ReadData1 => reg_ReadData1,
      ReadData2 => reg_ReadData2,
		led => led,
		PC => PC,
		SW => SW,
		Cause => Cause,
		IR => IR,
		Status => Status,
		EPC => EPC,
		BadVAddr => BadVAddr,
      RegWrite => RegWrite
	);
	
	
	phy_mem1 : phy_mem PORT MAP(
		CLK => CLK,
		RST => RST,
		MemRead => MemRead,
      MemWrite => MemWrite,
		ready => mem_ready,
		Vaddr => mem_addr,
		data_read => mem_data_read,
		data_write => mem_data_write,
		DYP2 => DYP2,
		mem_error => mem_error,
		--led => led,
		
		Ram1EN => Ram1EN,
      Ram1OE => Ram1OE,
      Ram1WE => Ram1WE,
		Ram1Addr => Ram1Addr,
		Ram1Data => Ram1Data,
		Ram2EN => Ram2EN,
      Ram2OE => Ram2OE,
      Ram2WE => Ram2WE,
		Ram2Addr => Ram2Addr,
		Ram2Data => Ram2Data,
		 
		FlashCE => FlashCE,
      FlashBYTE => FlashBYTE,
      FlashRP => FlashRP,
      FlashOE => FlashOE,
      FlashWE => FlashWE,
		FlashVPEN => FlashVPEN,
      FlashAddr => FlashAddr,
      FlashData => FlashData,
			 
		Index => Index,
		EntryLo0 => EntryLo0,
		EntryLo1 => EntryLo1,
		EntryHi => EntryHi,
		Status => Status,
		tlb_write => tlb_write,
		BadVAddr => BadVAddr,	
			
		CLK11 => CLK11,
		com_int => com_int,
		u_txd => u_txd,
		u_rxd => u_rxd
	);
	
	extend1 : extend PORT MAP(
		instruction => IR,
		immediate => immediate_extend
	);
	

--LED(4 downto 0) <= condi;
--LED(7 downto 6) <= "00";
--LED(5) <= mem_ready;
--DYP1 <=(CONV_INTEGER(condi) => '1', others => '0');
--LED(9 downto 5) <= testdata(4 downto 0);

process(CLK, RST)
	begin
		if RST = '0' then
			condi <= "00000";
			MemRead <= '0';
			MemWrite <= '0';
			RegWrite <= '0';
			mult_start <= '0';
			tlb_write <= '0';
			Compare <= x"04000000";
			PC <= x"BFC00000";
			Status <= x"ffffffff";
		elsif CLK'event and CLK = '1' then
			--STEP 0
			if condi = 0 then
				if Status(0) = '1' and Status(1) = '0' and ((Status(15) = '1' and timer_int = '1') or (Status(10) = '1' and com_int = '1'))then
					exc_code <= "00000";
					Cause(15) <= Status(15) and timer_int;
					Cause(10) <= Status(10) and com_int;
					PC <= PC + 4;
					condi <= "00111";
				else
					MemRead <= '1';
					mem_addr <= PC;
					condi <= condi + 1;
				end if;
			
			--STEP 1
			elsif condi = 1 then
				if mem_ready = '1' then
					PC <= PC + 4;
					MemRead <= '0';
					if mem_error /= 0 then
						condi <= "00111";
						case mem_error is
							when "01" =>
								exc_code <= "00010";
							when "11" =>
								exc_code <= "00100";
							when others=>
						end case;
					else
						IR <= mem_data_read;
						condi <= condi + 1;
					end if;
				end if;
			
			--STEP 2
			elsif condi = 2 then
				case IR(31 downto 26) is
					
					when "000000" =>
						if IR(10 downto 0) = "00000100001" then	--ADDU
							alu_A <= reg_ReadData1;
							alu_B <= reg_ReadData2;
							alu_opt <= "0001";
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000101010" then--SLT
							alu_A <= reg_ReadData1;
							alu_B <= reg_ReadData2;
							alu_opt <= "1100";
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000101011" then--SLTU
							alu_A <= reg_ReadData1;
							alu_B <= reg_ReadData2;
							alu_opt <= "1101";
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000100011" then--SUBU
							alu_A <= reg_ReadData1;
							alu_B <= reg_ReadData2;
							alu_opt <= "0010";
							condi <= condi + 1;
						elsif IR(15 downto 0) = "0000000000011000" then--MULT
							mult_A <= reg_ReadData1;
							mult_B <= reg_ReadData2;
							mult_start <= '1';
							condi <= condi + 1;
						elsif IR(25 downto 16) = 0 and IR(10 downto 0) = 18 then--MFLO
							reg_WriteData <= Lo;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(25 downto 16) = 0 and IR(10 downto 0) = 16 then--MFHI
							reg_WriteData <= Hi;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(20 downto 0) = 19 then				--MTLO
							Lo <= reg_ReadData1;
							condi <= "00000";
						elsif IR(20 downto 0) = 17 then				--MTHI
							Hi <= reg_ReadData1;
							condi <= "00000";
						elsif IR(10 downto 0) = 9 and IR(20 downto 16) = 0 then--JALR
							reg_WriteData <= PC;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(20 downto 0) = 8 then				--JR
							PC <= reg_ReadData1;
							condi <= "00000";
						elsif IR(10 downto 0) = "00000100100" then--AND
							alu_A <= reg_ReadData1;
							alu_B <= reg_ReadData2;
							alu_opt <= "0011";
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000100111" then--NOR
							alu_A <= reg_ReadData1;
							alu_B <= reg_ReadData2;
							alu_opt <= "1000";
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000100101" then--OR
							alu_A <= reg_ReadData1;
							alu_B <= reg_ReadData2;
							alu_opt <= "0100";
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000100110" then--XOR
							alu_A <= reg_ReadData1;
							alu_B <= reg_ReadData2;
							alu_opt <= "0111";
							condi <= condi + 1;
						elsif IR(25 downto 21) = 0 and IR(5 downto 0) = 0 then--SLL
							alu_A <= reg_ReadData2;
							alu_B <= immediate_extend;
							alu_opt <= "1001";
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000000100" then--SLLV
							alu_A <= reg_ReadData2;
							alu_B <= reg_ReadData1;
							alu_opt <= "1001";
							condi <= condi + 1;
						elsif IR(25 downto 21) = 0 and IR(5 downto 0) = 3 then--SRA
							alu_A <= reg_ReadData2;
							alu_B <= immediate_extend;
							alu_opt <= "1011";
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000000111" then--SRAV
							alu_A <= reg_ReadData2;
							alu_B <= reg_ReadData1;
							alu_opt <= "1011";
							condi <= condi + 1;
						elsif IR(25 downto 21) = 0 and IR(5 downto 0) = 2 then--SRL
							alu_A <= reg_ReadData2;
							alu_B <= immediate_extend;
							alu_opt <= "1010";
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000000110" then--SRLV
							alu_A <= reg_ReadData2;
							alu_B <= reg_ReadData1;
							alu_opt <= "1010";
							condi <= condi + 1;
						elsif IR(25 downto 0) = 12 then				--SYSCALL
							exc_code <= "01000";
							condi <= "00111";
						else
							exc_code <= "01010";
							condi <= "00111";
						end if;
					when "000001" =>
						if IR(20 downto 16) = 1 then					--BGEZ
							if reg_ReadData1(31) = '0' then
								PC <= PC + immediate_extend;
							end if;
							condi <= "00000";
						elsif IR(20 downto 16) = 0 then					--BLTZ
							if reg_ReadData1(31) = '1' then
								PC <= PC + immediate_extend;
							end if;
							condi <= "00000";
						else
							exc_code <= "01010";
							condi <= "00111";
						end if;
					when "000010" =>										--J
						PC(27 downto 0) <= immediate_extend(27 downto 0);
						condi <= "00000";
						
					when "000011" =>										--JAL
						reg_WriteData <= PC;
						RegWrite <= '1';
						condi <= condi + 1;
						
					when "000100" =>										--BEQ
						if reg_ReadData1 = reg_ReadData2 then
							PC <= PC + immediate_extend;
						end if;
						condi <= "00000";
						
					when "000101" =>										--BNE
						if reg_ReadData1 /= reg_ReadData2 then
							PC <= PC + immediate_extend;
						end if;
						condi <= "00000";
						
					when "000110" =>
						if IR(20 downto 16) = 0 then					--BLEZ
							if reg_ReadData1 = 0 or reg_ReadData1(31) = '1' then
								PC <= PC + immediate_extend;
							end if;
							condi <= "00000";
						else
							exc_code <= "01010";
							condi <= "00111";
						end if;
						
					when "000111" =>
						if IR(20 downto 16) = 0 then					--BGTZ
							if reg_ReadData1 /= 0 and reg_ReadData1(31) = '0' then
								PC <= PC + immediate_extend;
							end if;
							condi <= "00000";
						else
							exc_code <= "01010";
							condi <= "00111";
						end if;
						
					when "001001" => 										--ADDIU
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0001";
						condi <= condi + 1;
					when "001010" =>										--SLTI
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "1100";
						condi <= condi + 1;
					when "001011" =>										--SLTIU
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "1101";
						condi <= condi + 1;
					when "001100" =>										--ANDI
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0011";
						condi <= condi + 1;
					when "001101" =>										--ORI
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0100";
						condi <= condi + 1;
					when "001110" =>										--XORI
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0111";
						condi <= condi + 1;
					when "001111" =>
						if IR(25 downto 21) = 0 then					--LUI
							alu_A <= immediate_extend;
							alu_B <= x"00000010";
							alu_opt <= "1001";
							condi <= condi + 1;
						else
							exc_code <= "01010";
							condi <= "00111";
						end if;
					when "010000" =>
						if IR(25) = '1' and IR(24 downto 0) = 24 then--ERET
							if Status(4) = '1' and Status(1) = '0' then
								exc_code <= "01011";
								condi <= "00111";
							else
								Status(1) <= '0';
								PC <= EPC;
								condi <= "00000";
							end if;
						elsif IR(25 downto 21) = 0 and IR(10 downto 0) = 0 then --MFC0
							if Status(4) = '1' and Status(1) = '0' then
								exc_code <= "01011";
								condi <= "00111";
							else
								case CONV_INTEGER(IR(15 downto 11)) is
									when 0 =>
										reg_WriteData <= Index;
										RegWrite <= '1';
										condi <= condi + 1;
									when 2 =>
										reg_WriteData <= EntryLo0;
										RegWrite <= '1';
										condi <= condi + 1;
									when 3 =>
										reg_WriteData <= EntryLo1;
										RegWrite <= '1';
										condi <= condi + 1;
									when 8 =>
										reg_WriteData <= BadVAddr;
										RegWrite <= '1';
										condi <= condi + 1;
									when 9 =>
										reg_WriteData <= Count;
										RegWrite <= '1';
										condi <= condi + 1;
									when 10 =>
										reg_WriteData <= EntryHi;
										RegWrite <= '1';
										condi <= condi + 1;
									when 11 =>
										reg_WriteData <= Compare;
										RegWrite <= '1';
										condi <= condi + 1;
									when 12 =>
										reg_WriteData <= Status;
										RegWrite <= '1';
										condi <= condi + 1;
									when 13 =>
										reg_WriteData <= Cause;
										RegWrite <= '1';
										condi <= condi + 1;
									when 14 =>
										reg_WriteData <= EPC;
										RegWrite <= '1';
										condi <= condi + 1;
									when 15 =>
										reg_WriteData <= EBase;
										RegWrite <= '1';
										condi <= condi + 1;
									when others =>
										condi <= "00000";
								end case;
							end if;
						elsif IR(25 downto 21) = 4 and IR(10 downto 0) = 0 then --MTC0
							if Status(4) = '1' and Status(1) = '0' then
								exc_code <= "01011";
								condi <= "00111";
							else
								case CONV_INTEGER(IR(15 downto 11)) is
									when 0 =>
										Index <= reg_ReadData2;
										condi <= "00000";
									when 2 =>
										EntryLo0 <= reg_ReadData2;
										condi <= "00000";
									when 3 =>
										EntryLo1 <= reg_ReadData2;
										condi <= "00000";
									when 10 =>
										EntryHi <= reg_ReadData2;
										condi <= "00000";
									when 11 =>
										Compare <= reg_ReadData2;
										condi <= "00000";
									when 12 =>
										Status <= reg_ReadData2;
										condi <= "00000";
									when 14 =>
										EPC <= reg_ReadData2;
										condi <= "00000";
									when 15 =>
										EBase <= reg_ReadData2;
										condi <= "00000";
									when others =>
										condi <= "00000";
								end case;
							end if;
						elsif IR(25) = '1' and IR(24 downto 0) = 2 then--TLBWI
							if Status(4) = '1' and Status(1) = '0' then
								exc_code <= "01011";
								condi <= "00111";
							else
								tlb_write <= '1';
								condi <= condi + 1;
							end if;
						else
							exc_code <= "01010";
							condi <= "00111";
						end if;
					when "100000" =>										--LB
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0001";
						condi <= condi + 1;
					when "100011" =>										--LW
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0001";
						condi <= condi + 1;
					when "100100" =>										--LBU
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0001";
						condi <= condi + 1;
					when "101000" =>										--SB
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0001";
						condi <= condi + 1;
					when "100101" =>										--LHU
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0001";
						condi <= condi + 1;
					when "101011" =>										--SW
						alu_A <= reg_ReadData1;
						alu_B <= immediate_extend;
						alu_opt <= "0001";
						condi <= condi + 1;
					when "101111" =>										--CACHE
						condi <= "00000";
					when others	=>
						exc_code <= "01010";
						condi <= "00111";
				end case;
			
			--STEP 3
			elsif condi = 3 then
				case IR(31 downto 26) is
					
					when "000000" =>
						if IR(10 downto 0) = "00000100001" then	--ADDU
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000101010" then--SLT
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000101011" then--SLTU
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000100011" then--SUBU
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(15 downto 0) = "0000000000011000" then--MULT
							if mult_ready = '1' then
								mult_start <= '0';
								Hi <= mult_R(63 downto 32);
								Lo <= mult_R(31 downto 0);
								condi <= "00000";
							end if;
						elsif IR(25 downto 16) = 0 and IR(10 downto 0) = 18 then--MFLO
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(25 downto 16) = 0 and IR(10 downto 0) = 16 then--MFHI
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(20 downto 0) = 19 then				--MTLO
						elsif IR(20 downto 0) = 17 then				--MTHI
						elsif IR(10 downto 0) = 9 and IR(20 downto 16) = 0 then--JALR
							RegWrite <= '0';
							PC <= reg_ReadData1;
							condi <= "00000";
						elsif IR(20 downto 0) = 8 then				--JR
						elsif IR(10 downto 0) = "00000100100" then--AND
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000100111" then--NOR
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000100101" then--OR
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000100110" then--XOR
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(25 downto 21) = 0 and IR(5 downto 0) = 0 then--SLL
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000000100" then--SLLV
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(25 downto 21) = 0 and IR(5 downto 0) = 3 then--SRA
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000000111" then--SRAV
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(25 downto 21) = 0 and IR(5 downto 0) = 2 then--SRL
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(10 downto 0) = "00000000110" then--SRLV
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						elsif IR(25 downto 0) = 12 then				--SYSCALL
									
						end if;
					when "000001" =>
						if IR(20 downto 16) = 1 then					--BGEZ
							
						elsif IR(20 downto 16) = 0 then					--BLTZ
							
						end if;
					when "000010" =>										--J
						
						
					when "000011" =>										--JAL
						RegWrite <= '0';
						PC(27 downto 0) <= immediate_extend(27 downto 0);
						condi <= "00000";
						
					when "000100" =>										--BEQ
	
					when "000101" =>										--BNE

					when "000110" =>
						if IR(20 downto 16) = 0 then					--BLEZ
						end if;
						
					when "000111" =>
						if IR(20 downto 16) = 0 then					--BGTZ
						end if;
						
					when "001001" => 										--ADDIU
						reg_WriteData <= alu_R;
						RegWrite <= '1';
						condi <= condi + 1;
					when "001010" =>										--SLTI
						reg_WriteData <= alu_R;
						RegWrite <= '1';
						condi <= condi + 1;
					when "001011" =>										--SLTIU
						reg_WriteData <= alu_R;
						RegWrite <= '1';
						condi <= condi + 1;
					when "001100" =>										--ANDI
						reg_WriteData <= alu_R;
						RegWrite <= '1';
						condi <= condi + 1;
					when "001101" =>										--ORI
						reg_WriteData <= alu_R;
						RegWrite <= '1';
						condi <= condi + 1;
					when "001110" =>										--XORI
						reg_WriteData <= alu_R;
						RegWrite <= '1';
						condi <= condi + 1;
					when "001111" =>
						if IR(25 downto 21) = 0 then					--LUI
							reg_WriteData <= alu_R;
							RegWrite <= '1';
							condi <= condi + 1;
						end if;
					when "010000" =>
						if IR(25) = '1' and IR(24 downto 0) = 24 then--ERET
						
						elsif IR(25 downto 21) = 0 and IR(10 downto 0) = 0 then --MFC0
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(25 downto 21) = 4 and IR(10 downto 0) = 0 then --MTC0
						
						elsif IR(25) = '1' and IR(24 downto 0) = 2 then--TLBWI
							tlb_write <= '0';
							condi <= "00000";
						end if;
					when "100000" =>										--LB
						mem_addr <= alu_R(31 downto 2) & "00";
						MemRead <= '1';
						condi <= condi + 1;
					when "100011" =>										--LW
						mem_addr <= alu_R;
						MemRead <= '1';
						condi <= condi + 1;
					when "100100" =>										--LBU
						mem_addr <= alu_R(31 downto 2) & "00";
						MemRead <= '1';
						condi <= condi + 1;
					when "101000" =>										--SB
						mem_addr <= alu_R(31 downto 2) & "00";
						MemRead <= '1';
						condi <= condi + 1;
					when "100101" =>										--LHU
						mem_addr <= alu_R(31 downto 2) & '0' & alu_R(0);
						MemRead <= '1';
						condi <= condi + 1;
					when "101011" =>										--SW
						mem_addr <= alu_R;
						MemWrite <= '1';
						mem_data_write <= reg_ReadData2;
						condi <= condi + 1;
					when "101111" =>										--CACHE
					
					when others	=> 
				end case;

			--STEP 4
			elsif condi = 4 then
				case IR(31 downto 26) is
					
					when "000000" =>
						if IR(10 downto 0) = "00000100001" then	--ADDU
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(10 downto 0) = "00000101010" then--SLT
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(10 downto 0) = "00000101011" then--SLTU
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(10 downto 0) = "00000100011" then--SUBU
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(15 downto 0) = "0000000000011000" then--MULT
						elsif IR(25 downto 16) = 0 and IR(10 downto 0) = 18 then--MFLO
						elsif IR(25 downto 16) = 0 and IR(10 downto 0) = 16 then--MFHI
						elsif IR(20 downto 0) = 19 then				--MTLO
						elsif IR(20 downto 0) = 17 then				--MTHI
						elsif IR(10 downto 0) = 9 and IR(20 downto 16) = 0 then--JALR
						elsif IR(20 downto 0) = 8 then				--JR
						elsif IR(10 downto 0) = "00000100100" then--AND
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(10 downto 0) = "00000100111" then--NOR
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(10 downto 0) = "00000100101" then--OR
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(10 downto 0) = "00000100110" then--XOR
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(25 downto 21) = 0 and IR(5 downto 0) = 0 then--SLL
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(10 downto 0) = "00000000100" then--SLLV
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(25 downto 21) = 0 and IR(5 downto 0) = 3 then--SRA
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(10 downto 0) = "00000000111" then--SRAV
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(25 downto 21) = 0 and IR(5 downto 0) = 2 then--SRL
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(10 downto 0) = "00000000110" then--SRLV
							RegWrite <= '0';
							condi <= "00000";
						elsif IR(25 downto 0) = 12 then				--SYSCALL
									
						end if;
					when "000001" =>
						if IR(20 downto 16) = 1 then					--BGEZ
							
						elsif IR(20 downto 16) = 0 then					--BLTZ
							
						end if;
					when "000010" =>										--J		
						
					when "000011" =>										--JAL
						
					when "000100" =>										--BEQ
	
					when "000101" =>										--BNE

					when "000110" =>
						if IR(20 downto 16) = 0 then					--BLEZ
						end if;
						
					when "000111" =>
						if IR(20 downto 16) = 0 then					--BGTZ
						end if;
						
					when "001001" => 										--ADDIU
						RegWrite <= '0';
						condi <= "00000";
					when "001010" =>										--SLTI
						RegWrite <= '0';
						condi <= "00000";
					when "001011" =>										--SLTIU
						RegWrite <= '0';
						condi <= "00000";
					when "001100" =>										--ANDI
						RegWrite <= '0';
						condi <= "00000";
					when "001101" =>										--ORI
						RegWrite <= '0';
						condi <= "00000";
					when "001110" =>										--XORI
						RegWrite <= '0';
						condi <= "00000";
					when "001111" =>
						if IR(25 downto 21) = 0 then					--LUI
							RegWrite <= '0';
							condi <= "00000";
						end if;
					when "010000" =>
						if IR(25) = '1' and IR(24 downto 0) = 24 then--ERET
						
						elsif IR(25 downto 21) = 0 and IR(10 downto 0) = 0 then --MFC0
						
						elsif IR(25 downto 21) = 4 and IR(10 downto 0) = 0 then --MTC0
						
						elsif IR(25) = '1' and IR(24 downto 0) = 2 then--TLBWI
						
						end if;
					when "100000" =>										--LB
						if mem_ready = '1' then
							if mem_error /= 0 then
								condi <= "00111";
								case mem_error is
									when "01" =>
										exc_code <= "00010";
									when "11" =>
										exc_code <= "00100";
									when others=>
								end case;
								MemRead <= '0';
							else
								MemRead <= '0';
								case alu_R(1 downto 0) is
									when "00" =>
										reg_WriteData(7 downto 0) <= mem_data_read(7 downto 0);
									when "01" =>
										reg_WriteData(7 downto 0) <= mem_data_read(15 downto 8);
									when "10" =>
										reg_WriteData(7 downto 0) <= mem_data_read(23 downto 16);
									when "11" =>
										reg_WriteData(7 downto 0) <= mem_data_read(31 downto 24);
									when others=>
								end case;
								for i IN 8 to 31 loop
									reg_WriteData(i) <= mem_data_read(7);
								end loop;
								RegWrite <= '1';
								condi <= condi + 1;
							end if;
						end if;
					when "100011" =>										--LW
						if mem_ready = '1' then
							if mem_error /= 0 then
								condi <= "00111";
								case mem_error is
									when "01" =>
										exc_code <= "00010";
									when "11" =>
										exc_code <= "00100";
									when others=>
								end case;
								MemRead <= '0';
							else
								MemRead <= '0';
								reg_WriteData <= mem_data_read;
								RegWrite <= '1';
								condi <= condi + 1;
							end if;
						end if;
					when "100100" =>										--LBU
						if mem_ready = '1' then
							if mem_error /= 0 then
								condi <= "00111";
								case mem_error is
									when "01" =>
										exc_code <= "00010";
									when "11" =>
										exc_code <= "00100";
									when others=>
								end case;
								MemRead <= '0';
							else
								MemRead <= '0';
								case alu_R(1 downto 0) is
									when "00" =>
										reg_WriteData(7 downto 0) <= mem_data_read(7 downto 0);
									when "01" =>
										reg_WriteData(7 downto 0) <= mem_data_read(15 downto 8);
									when "10" =>
										reg_WriteData(7 downto 0) <= mem_data_read(23 downto 16);
									when "11" =>
										reg_WriteData(7 downto 0) <= mem_data_read(31 downto 24);
									when others=>
								end case;
								reg_WriteData(31 downto 8) <= x"000000";
								RegWrite <= '1';
								condi <= condi + 1;
							end if;
						end if;
					when "101000" =>										--SB
						if mem_ready = '1' then
							if mem_error /= 0 then
								condi <= "00111";
								case mem_error is
									when "01" =>
										exc_code <= "00011";
									when "11" =>
										exc_code <= "00101";
									when others=>
								end case;
								MemRead <= '0';
							else
								MemRead <= '0';
								
								case alu_R(1 downto 0) is
									when "00" =>
										mem_data_write(7 downto 0) <= reg_ReadData2(7 downto 0);
										mem_data_write(31 downto 8) <= mem_data_read(31 downto 8);
									when "01" =>
										mem_data_write(7 downto 0) <= mem_data_read(7 downto 0);
										mem_data_write(15 downto 8) <= reg_ReadData2(7 downto 0);
										mem_data_write(31 downto 16) <= mem_data_read(31 downto 16);
									when "10" =>
										mem_data_write(15 downto 0) <= mem_data_read(15 downto 0);
										mem_data_write(23 downto 16) <= reg_ReadData2(7 downto 0);
										mem_data_write(31 downto 24) <= mem_data_read(31 downto 24);
									when "11" =>
										mem_data_write(23 downto 0) <= mem_data_read(23 downto 0);
										mem_data_write(31 downto 24) <= reg_ReadData2(7 downto 0);
									when others=>
										mem_data_write <= (others => '0');
								end case;
								--mem_data_write(7 downto 0) <= reg_ReadData2(7 downto 0);
								--mem_data_write(31 downto 8) <= mem_data_read(31 downto 8);
								condi <= condi + 1;
							end if;
						end if;
					when "100101" =>										--LHU
						if mem_ready = '1' then
							if mem_error /= 0 then
								condi <= "00111";
								case mem_error is
									when "01" =>
										exc_code <= "00010";
									when "11" =>
										exc_code <= "00100";
									when others=>
								end case;
								MemRead <= '0';
							else
								MemRead <= '0';
								if alu_R(1) = '0' then
									reg_WriteData(15 downto 0) <= mem_data_read(15 downto 0);
								else
									reg_WriteData(15 downto 0) <= mem_data_read(31 downto 16);
								end if;
								reg_WriteData(31 downto 16) <= x"0000";
								RegWrite <= '1';
								condi <= condi + 1;
							end if;
						end if;
					when "101011" =>										--SW
						if mem_ready = '1' then
							if mem_error /= 0 then
								condi <= "00111";
								case mem_error is
									when "01" =>
										exc_code <= "00011";
									when "10" =>
										exc_code <= "00001";
									when "11" =>
										exc_code <= "00101";
									when others=>
								end case;
							else
								condi <= "00000";
							end if;
							MemWrite <= '0';
						end if;
					when "101111" =>										--CACHE
					
					when others	=> 
				end case;


			--STEP 5
			elsif condi = 5 then
				case IR(31 downto 26) is
					when "100000" =>										--LB
						RegWrite <= '0';
						condi <= "00000";
					when "100011" =>										--LW
						RegWrite <= '0';
						condi <= "00000";
					when "100100" =>										--LBU
						RegWrite <= '0';
						condi <= "00000";
					when "101000" =>										--SB
						MemWrite <= '1';
						condi <= condi + 1;
					when "100101" =>										--LHU
						RegWrite <= '0';
						condi <= "00000";
					when "101011" =>										--SW
					when others	=> 
				end case;
			
			--STEP 6
			elsif condi = 6 then
				case IR(31 downto 26) is
					when "101000" =>										--SB
						if mem_ready = '1' then
							if mem_error /= 0 then
								condi <= "00111";
								case mem_error is
									when "01" =>
										exc_code <= "00011";
									when "10" =>
										exc_code <= "00001";
									when "11" =>
										exc_code <= "00101";
									when others=>
								end case;
								MemWrite <= '0';
							else
								MemWrite <= '0';
								condi <= "00000";
							end if;
						end if;
					when others	=> 
				end case;
			
			--中断处理
			elsif condi = 7 then
				if Status(1) = '0' then
					EPC <= PC - 4;
				end if;
				Cause(6 downto 2) <= exc_code;
				Status(1) <= '1';
				PC <= EBase + x"00000180";
				condi <= "00000";
			end if;
--				MemRead <= '1';
--				mem_addr <= x"1FD003F8";
--				condi <= condi + 1;
--			elsif condi = 1 then
--				if mem_ready = '1' then
--					MemRead <= '0';
--					testdata <= mem_data_read;
--					condi <= condi + 1;
--				end if;
--			elsif condi = 2 then
--				MemWrite <= '1';
--				mem_addr <= x"00000000" + PC;
--				mem_data_write <= testdata;
--				condi <= condi + 1;
--			elsif condi = 3 then
--				if mem_ready = '1' then
--					MemWrite <= '0';
--					condi <= condi + 1;
--				end if;
--			elsif condi = 4 then
--				MemRead <= '1';
--				mem_addr <= x"00000000" + PC;
--				mem_data_write <= testdata;
--				condi <= condi + 1;
--			elsif condi = 5 then
--				if mem_ready = '1' then
--					MemRead <= '0';
--					testdata <= mem_data_read;
--					condi <= condi + 1;
--				end if;
--			elsif condi = 6 then
--				MemWrite <= '1';
--				mem_addr <= x"1FD003F8";
--				mem_data_write <= testdata;
--				condi <= condi + 1;
--			elsif condi = 7 then
--				if mem_ready = '1' then
--					MemWrite <= '0';
--					condi <= "00000";
--					PC <= PC + 1;
--				end if;
--			end if;
--			if condi = 0 then
--				MemRead <= '1';
--				mem_addr <= x"1FD003F8";
--				condi <= condi + 1;
--			elsif condi = 1 then
--				if mem_ready = '1' then
--					MemRead <= '0';
--					testdata <= mem_data_read;
--					condi <= condi + 1;
--				end if;
--			elsif condi = 2 then
--				--if testdata(1) = '1' then
--					condi <= condi + 1;
--					MemWrite <= '1';
--					mem_addr <= x"1FD003F8";
--					mem_data_write <= testdata + 1;
--				--else
--				--	condi <= "00000";
--				--end if;
--			elsif condi = 3 then
--				if mem_ready = '1' then
--					MemWrite <= '0';
--					--testdata <= mem_data_read;
--					condi <= "00000";
--				end if;
--			elsif condi = 4 then
--				MemWrite <= '1';
--				mem_data_write <= testdata;
--				mem_addr <= x"00000001";
--				condi <= condi + 1;
--			elsif condi = 5 then
--				if mem_ready = '1' then
--					MemWrite <= '0';
--					condi <= condi + 1;
--				end if;
--			elsif condi = 6 then
--				MemWrite <= '1';
--				mem_data_write <= testdata;
--				mem_addr <= x"00400001";
--				condi <= condi + 1;
--			elsif condi = 7 then
--				if mem_ready = '1' then
--					MemWrite <= '0';
--					condi <= condi + 1;
--				end if;
--			elsif condi = 8 then
--				MemWrite <= '1';
--				mem_data_write <= testdata;
--				mem_addr <= x"1E000001";
--				condi <= condi + 1;
--			elsif condi = 9 then
--				if mem_ready = '1' then
--					MemWrite <= '0';
--					condi <= condi + 1;
--				end if;
--			elsif condi = 10 then
--				MemRead <= '1';
--				mem_addr <= x"00000001";
--				condi <= condi + 1;
--			elsif condi = 11 then
--				if mem_ready = '1' then
--					MemRead <= '0';
--					testdata <= mem_data_read + 1;
--					condi <= condi + 1;
--				end if;
--			elsif condi = 12 then
--				--MemWrite <= '1';
--				--mem_data_write <= testdata;
--				--mem_addr <= x"1FD003F8";
--				condi <= condi + 1;
--			elsif condi = 13 then
--				--if mem_ready = '1' then
--				--	MemWrite <= '0';
--					condi <= condi + 1;
--				--end if;
--			elsif condi = 14 then
--				MemRead <= '1';
--				mem_addr <= x"00400001";
--				condi <= condi + 1;
--			elsif condi = 15 then
--				if mem_ready = '1' then
--					MemRead <= '0';
--					testdata <= mem_data_read + 2;
--					condi <= condi + 1;
--				end if;
--			elsif condi = 16 then
--				--MemWrite <= '1';
--				--mem_data_write <= testdata;
--				--mem_addr <= x"1FD003F8";
--				condi <= condi + 1;
--			elsif condi = 17 then
--				--if mem_ready = '1' then
--				--	MemWrite <= '0';
--					condi <= condi + 1;
--				--end if;
--			elsif condi = 18 then
--				MemRead <= '1';
--				mem_addr <= x"1E000001";
--				condi <= condi + 1;
--			elsif condi = 19 then
--				if mem_ready = '1' then
--					MemRead <= '0';
--					testdata <= mem_data_read + 3;
--					condi <= condi + 1;
--				end if;
--			elsif condi = 20 then
--				--MemWrite <= '1';
--				--mem_data_write <= testdata;
--				--mem_addr <= x"1FD003F8";
--				condi <= condi + 1;
--			elsif condi = 21 then
--				--if mem_ready = '1' then
--				--	MemWrite <= '0';
--					condi <= condi + 1;
--				--end if;
--			end if;
		end if;
	end process;

--process (sCLK)
--	variable change : STD_LOGIC_VECTOR (18 downto 0) := "0000000000000000000";
--	begin
--		if sCLK'event and sCLK = '1' then
--			change := change + 1;
--			if change(18 downto 0) = 0 then
--				CLK <= not CLK;
--			end if;
--		end if;
--end process;

process(condi)
	begin
	
	case condi(3 downto 0) is --以下是0~F的编码规则
           when"0000"=> DYP1<="1111110";--0
           when"0001"=> DYP1<="0110000";--1
           when"0010"=> DYP1<="1101101";--2
           when"0011"=> DYP1<="1111001";--3
           when"0100"=> DYP1<="0110011";--4
           when"0101"=> DYP1<="1011011";--5
           when"0110"=> DYP1<="1011111";--6
           when"0111"=> DYP1<="1110000";--7
           when"1000"=> DYP1<="1111111";--8
           when"1001"=> DYP1<="1110011";--9
           when"1010"=> DYP1<="1110111";--A
           when"1011"=> DYP1<="0011111";--B
           when"1100"=> DYP1<="1001110";--C
           when"1101"=> DYP1<="0111101";--D
           when"1110"=> DYP1<="1001111";--E
           when"1111"=> DYP1<="1000111";--F
           when others=>DYP1<="0000000";--其他情况 全灭
        end case;
	
end process;

process(CLK, RST)
	begin
		if RST = '0' then
			Count <= x"00000000";
		elsif CLK'event and CLK = '1' then
			
			Count <= Count + 1;
			if Count = Compare then
				Count <= x"00000000";
				timer_int <= '1';
			elsif Status(1) = '1' then
				timer_int <= '0';
			end if;
		end if;
end process;
--
--process(SW(31 downto 16), PC(15 downto 0), RST, SW(15))
--	begin
--		if RST = '0' then
--			CLKsi <= '0';
--		elsif PC(15 downto 0) = SW(31 downto 16) or SW(15) = '1' then
--			CLKsi <= '1';
--		end if;
--end process;
process(CLK50)
	begin
		if CLK50'event and CLK50 = '1' then
			CLKx <= not CLKx;
		end if;
end process;
CLKsi <= '1' when (PC(15 downto 0) = SW(31 downto 16) or SW(15) = '1') else '0';
--process(CLK50, CLKh, CLKsi)
--	--variable a : STD_LOGIC_VECTOR(16 downto 0);
--	begin
--		if CLKsi = '0' then
--			CLK <= CLK50;
--		else
--			CLK <= CLKh;
--		end if;
--end process;

CLK <= CLKx when CLKsi = '0' else CLKh;
--CLK <= CLK50;
end Behavioral;


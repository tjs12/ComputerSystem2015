----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:27:45 12/01/2013 
-- Design Name: 
-- Module Name:    uart2 - Behavioral 
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

entity uart is
    Port ( RST : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           rxd : in  STD_LOGIC;
           rdn : in  STD_LOGIC;
           wrn : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0);
           data_ready : out  STD_LOGIC;
           parity_error : out  STD_LOGIC;
           framing_error : out  STD_LOGIC;
           tbre : out  STD_LOGIC;
           tsre : out  STD_LOGIC;
			  rcvrrst : in STD_LOGIC;
			  txmtrst : in STD_LOGIC;
			  led : out STD_LOGIC_VECTOR(15 downto 0);
           sdo : out  STD_LOGIC);
end uart;

architecture v1 of uart is

	signal sclk : std_logic;
	component txmit 
		Port ( rst : in  STD_LOGIC;
           clk16x : in  STD_LOGIC;
           wrn : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (7 downto 0);
           tbre : out  STD_LOGIC;
           tsre : out  STD_LOGIC;
			  --led : out STD_LOGIC_VECTOR(15 downto 0);
           sdo : out  STD_LOGIC);
	end component ;

	component rcvr 
		port (
			rst : in std_logic;
			clk16x : in std_logic;
			rxd : in std_logic;
			rdn : in std_logic;
			data_ready : out std_logic;
			parity_error : out std_logic;
			framing_error : out std_logic;
			dout : out std_logic_vector(7 downto 0)
			);
	end component ;

	component clkcon
		 Port ( rst : in  STD_LOGIC;
				  clk0 : in  STD_LOGIC;
				  clk : out  STD_LOGIC);
	end component;

	begin
		u1 : txmit PORT MAP 
		(
		rst => txmtrst,
		clk16x => sclk,
		wrn => wrn,
		din => data_in,
		tbre => tbre,
		tsre => tsre,
		--led => led,
		sdo => sdo);

		u2 : rcvr PORT MAP  
		(rst => rcvrrst,
		clk16x => sclk,
		rxd => rxd,
		rdn => rdn,
		data_ready => data_ready,
		framing_error => framing_error,
		parity_error => parity_error,
		dout => data_out) ;

		u3:clkcon port map
		  (rst=>RST,
			clk0=>CLK,
			clk=>sclk);
			
end v1;



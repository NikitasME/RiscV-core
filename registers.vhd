----------------------------------------------------------------------------------
-- Author: Nikitas Metaxakis
-- Create Date:    15:16:02 03/03/2022 
-- Module Name:    registers - Behavioral  
-- Description: The register file consists of 32 32-bit general purpose registers.
-- Revision: 1.0
-- License: GPL v3.0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity registers is
	port( regA, regB, regW : in std_logic_vector(4 downto 0);
			clk, we : in std_logic;
			input : in std_logic_vector(31 downto 0);
			outA, outB : out std_logic_vector(31 downto 0));
end registers;

architecture Behavioral of registers is
	--Initialize register file
	type register_file is array (0 to 31) of std_logic_vector(31 downto 0);
	signal regs : register_file :=(
		x"00000000",x"00000000",x"00000000",x"00000000",
		x"00000000",x"00000000",x"00000000",x"00000000",
		x"00000000",x"00000000",x"00000000",x"00000000",
		x"00000000",x"00000000",x"00000000",x"00000000",
		x"00000000",x"00000000",x"00000000",x"00000000",
		x"00000000",x"00000000",x"00000000",x"00000000",
		x"00000000",x"00000000",x"00000000",x"00000000",
		x"00000000",x"00000000",x"00000000",x"00000000");
begin
process(clk)
begin
	if(falling_edge(clk)) then
		if we = '1' and regW /= "00000" then --Write enable (zero register stays always zero)
			regs(to_integer(unsigned(regW))) <= input;
		end if;
		outA <= regs(to_integer(unsigned(regA)));
		outB <= regs(to_integer(unsigned(regB)));
	end if;
end process;
end Behavioral;


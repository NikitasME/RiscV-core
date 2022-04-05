----------------------------------------------------------------------------------
-- Author: Nikitas Metaxakis 
-- 
-- Create Date:    15:26:55 03/02/2022 
-- Module Name:    pc - Behavioral 
-- Description: Calculates the next instruction address
-- Revision: 1.0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc is
	port(pc_in, branch_t : in std_logic_vector(31 downto 0);
		  clk, rst, branch : in std_logic;
		  l : in std_logic_vector(1 downto 0);
		  pc_out : out std_logic_vector(31 downto 0));
end pc;

architecture Behavioral of pc is

begin
process(clk)
begin
	if(rising_edge(clk)) then
		if rst='1' then
			pc_out <= x"00000000"; --Reset Program Counter
		else 
			if branch = '1' then
				pc_out <= branch_t; --Handle Branches
			elsif l = "00" then
				pc_out <= std_logic_vector(unsigned(pc_in) + 4); --Increment Program Counter by 4 because of 32-bit intructions
			else
				pc_out <= std_logic_vector(unsigned(pc_in)); --Stall for a clock period in case of a load
			end if;
		end if;
	end if;
end process;

end Behavioral;


----------------------------------------------------------------------------------
-- Author: Nikitas Metaxakis
-- Create Date:    15:03:46 03/02/2022 
-- Module Name:    memory - Behavioral 
-- Description: The memory module. Has a dual-port design for simultaneous read and write. Only 128 bytes are implemented, but can be extended easily.
-- Revision: 1.0
-- License: GPL v3.0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory is
	port(addr_read : in std_logic_vector(7 downto 0);
		  addr_write : in std_logic_vector(7 downto 0);
		  data_in : in std_logic_vector(31 downto 0);
		  clk : in std_logic;
		  we : in std_logic_vector(1 downto 0);
		  data_out : out std_logic_vector(31 downto 0));
end memory;

architecture Behavioral of memory is
type memory_array is array (0 to 127) of std_logic_vector(7 downto 0);

--Initialize memory array. The memory is pre-loaded with assembly code for multiplying 15 by 23.
signal mem : memory_array :=(
	x"00",x"f0",x"00",x"93", --addi x1 , x0, 15
	x"01",x"71",x"01",x"13", --addi x2, x2, 23
	x"00",x"10",x"f1",x"93", --and x3, x1, 1
	x"00",x"10",x"02",x"93", --addi x5, x0, 1
	x"00",x"30",x"04",x"63", --beq x3, x0, 8
	x"00",x"22",x"02",x"33", --add x4, x4, x2 
	x"40",x"10",x"d0",x"93", --srai x1, x1, 1
	x"00",x"11",x"11",x"13", --slli x2, x2, 1
	x"fe",x"50",x"94",x"e3", --bne x1, x5, -24
	x"00",x"22",x"02",x"33", --add x4, x4, x2
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00",
	x"00",x"00",x"00",x"00");
begin
process(clk)
begin
	if falling_edge(clk) then 
		case we is --Write Enable
			when "01" => --store byte
				mem(to_integer(unsigned(addr_write))) <= data_in(7 downto 0);
			when "10" => --store half-word
				mem(to_integer(unsigned(addr_write))+1) <= data_in(7 downto 0);
				mem(to_integer(unsigned(addr_write))) <= data_in(15 downto 8);
			when "11" => --store word
				mem(to_integer(unsigned(addr_write))+3) <= data_in(7 downto 0);
				mem(to_integer(unsigned(addr_write))+2) <= data_in(15 downto 8);
				mem(to_integer(unsigned(addr_write))+1) <= data_in(23 downto 16);
				mem(to_integer(unsigned(addr_write))) <= data_in(31 downto 24);
			when others =>
		end case;
	end if;
end process;
data_out <= mem(to_integer(unsigned(addr_read)))&mem(to_integer(unsigned(addr_read))+1)&mem(to_integer(unsigned(addr_read))+2)&mem(to_integer(unsigned(addr_read))+3);
end Behavioral;


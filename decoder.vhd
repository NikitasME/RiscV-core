----------------------------------------------------------------------------------
-- Author: Nikitas Metaxakis
-- Create Date:    14:47:04 03/01/2022 
-- Module Name:    decoder - Behavioral 
-- Description: The risc-v decoder. Supports some instructions that haven't been implemented in the ALU yet.
-- Revision: 1.0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
	port( inst, pc_in : in std_logic_vector(31 downto 0);
			clk : in std_logic;
			opcode : out std_logic_vector(6 downto 0);
			rd : out std_logic_vector(4 downto 0);
			rs1 : out std_logic_vector(4 downto 0);
			rs2 : out std_logic_vector(4 downto 0);
			imm, pc_out : out std_logic_vector(31 downto 0);
			funct3 : out std_logic_vector(2 downto 0);
			funct7 : out std_logic_vector(6 downto 0));
end decoder;

architecture Behavioral of decoder is

begin
	process(clk)
	begin
		if rising_edge(clk) then
			opcode <= inst(6 downto 0);	--Opcode
			rd <= inst(11 downto 7);		--Destination register
			rs1 <= inst(19 downto 15);		--First source register
			rs2 <= inst(24 downto 20);		--Second source register
			funct3 <= inst(14 downto 12);	--Funct3
			funct7 <= inst(31 downto 25); --Funct7
			pc_out <= pc_in;					--PC pass-through
			
			--Immediate value calculation
			case inst(6 downto 0) is
				when "0000011" | "0001111" | "0010011" | "0011011" | "1100111" | "1110011" => 
					imm <= (31 downto 11 => inst(31))&inst(30 downto 20); -- I instructions
				when "0010111" | "0110111" => 
					imm <= inst(31 downto 12)&"000000000000"; -- U instructions
				when "0100011" => 
					imm <= (31 downto 11 => inst(31))&inst(30 downto 25)&inst(11 downto 7); -- S instructions
				when "0110011" | "0111011" => 
					imm <= (others => '0'); -- R instructions
				when "1100011" => 
					imm <= (31 downto 12 => inst(31))&inst(7)&inst(30 downto 25)&inst(11 downto 8)&'0'; -- B instruuctions
				when "1101111" =>
					imm <= (31 downto 20 => inst(31))&inst(19 downto 12)&inst(20)&inst(30 downto 21)&'0'; -- J instructions
				when others =>
					imm <= (others => '0'); -- invalid or unsupported instructions
			end case;
		end if;
	end process;
end Behavioral;


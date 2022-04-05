----------------------------------------------------------------------------------
-- Author: Nikitas Metaxakis
-- Create Date:    15:39:47 03/03/2022  
-- Module Name:    alu - Behavioral 
-- Description: The Arithmetic and Logic Unit of the core. Supports the RV32I instruction set.
-- Revision: 1.0
-- License: GPL v3.0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
	port( dataA, dataB, imm, pc : in std_logic_vector(31 downto 0);
			opcode, f7 : in std_logic_vector(6 downto 0);
			rd_in : in std_logic_vector(4 downto 0);
			f3 : in std_logic_vector(2 downto 0);
			clk : in std_logic;
			result, branch_target, mem_data, eff_addr : out std_logic_vector(31 downto 0);
			rd_out : out std_logic_vector(4 downto 0);
			wmem, load : out std_logic_vector(1 downto 0);
			wreg, branch : out std_logic);
end alu;

architecture Behavioral of alu is
begin
process(clk)
	variable var : integer := 0;
begin
	if(rising_edge(clk)) then 
		if var = 0 then
			rd_out <= rd_in; --Destination register address pass-through
			case opcode is
				when "0010011" => --addi, slli, slti, sltiu, xori, srli, srai, ori, andi
					branch <= '0'; --No branch
					wreg <= '1'; 	--Register write enable
					wmem <= "00";	--Memory write enable
					load <= "00";	--No load
					case f3 is 
						when "000" => --addi
							result <= std_logic_vector(signed(dataA) + signed(imm));
						when "001" => --slli
							result <= std_logic_vector(shift_left(unsigned(dataA), to_integer(unsigned(imm(4 downto 0)))));
						when "010" => --slti
							if signed(dataA) < signed(imm) then
								result <= x"00000001";
							else 
								result <= x"00000000";
							end if;
						when "011" => --sltiu
							if unsigned(dataA) < unsigned(imm) then
								result <= x"00000001";
							else 
								result <= x"00000000";
							end if;
						when "100" => --xori
							result <= dataA xor imm;
						when "101" => --srli & srai
							case f7 is
								when "0000000" => --srli
									result <= std_logic_vector(shift_right(unsigned(dataA), to_integer(unsigned(imm(4 downto 0)))));
								when "0100000" => --srai
									result <= std_logic_vector(shift_right(signed(dataA), to_integer(unsigned(imm(4 downto 0)))));
								when others =>
							end case;
						when "110" => --ori
							result <= dataA or imm;
						when "111" => --andi
							result <= dataA and imm;
						when others =>
					end case;
				when "0110111" => --lui
					branch <= '0';	--No branch
					wreg <= '1';	--Register write enable
					load <= "00";	--No load
					wmem <= "00";	--Memory write enable
					result <= imm;
				when "0010111" => --auipc
					branch <= '0';	--No branch
					wreg <= '1';	--Register write enable
					load <= "00";	--No load
					wmem <= "00";	--Memory write enable
					result <= std_logic_vector(signed(imm) + signed(pc));
				when "0110011" => --add, sub, sll, slt, sltu, xor, srl, sra, or, and
					branch <= '0';	--No branch
					wreg <= '1';	--Register write enable
					load <= "00";	--No load
					wmem <= "00";	--Memory write enable
					case f3 is
						when "000" => --add, sub
							case f7 is
								when "0000000" => --add
									result <= std_logic_vector(signed(dataA) + signed(dataB));
								when "0100000" => --sub
									result <= std_logic_vector(signed(dataA) - signed(dataB));
								when others =>
							end case;
						when "001" => --sll
							result <= std_logic_vector(shift_left(unsigned(dataA), to_integer(unsigned(dataB(4 downto 0)))));
						when "010" => --slt
							if signed(dataA) < signed(dataB) then
								result <= x"00000001";
							else 
								result <= x"00000000";
							end if;
						when "011" => --sltu
							if unsigned(dataA) < unsigned(imm) then
								result <= x"00000001";
							else 
								result <= x"00000000";
							end if;
						when "100" => --xor
							result <= dataA xor dataB;
						when "101" => --srl, sra
							case f7 is 
								when "0000000" => --srl
									result <= std_logic_vector(shift_right(unsigned(dataA), to_integer(unsigned(dataB(4 downto 0)))));
								when "0100000" => --sra
									result <= std_logic_vector(shift_right(signed(dataA), to_integer(signed(dataB(4 downto 0)))));
								when others =>
							end case;
						when "110" => --or
							result <= dataA or dataB;
						when "111" => --and
							result <= dataA and dataB;
						when others =>
					end case;
				when "1101111" => --jal
					result <= std_logic_vector(signed(pc) + 4);
					branch_target <= std_logic_vector(signed(pc) + signed(imm));
					branch <= '1';	--Branch
					var := 2;		--Don't execute the next two intructions that are in the pipeline
					wreg <= '1';	--Register write enable
					load <= "00";	--No load
					wmem <= "00";	--Memory write enable
				when "1100111" => --jalr
					result <= std_logic_vector(signed(pc) + 4);
					branch_target <= std_logic_vector(signed(dataA) + signed(imm)) and x"fffffffe";
					branch <= '1';	--Branch
					var := 2;		--Don't execute the next two intructions that are in the pipeline
					wreg <= '1';	--Register write enable
					load <= "00";	--No load
					wmem <= "00";	--Memory write enable
				when "1100011" => --beq, bne, blt, bge, bltu, bgeu
					wreg <= '0';	--Register write enable
					load <= "00";	--No load
					wmem <= "00";	--Memory write enable
					branch_target <= std_logic_vector(signed(pc) + signed(imm));
					case f3 is
						when "000" => --beq
							if dataA = dataB then
								branch <= '1';	--Branch
								var := 2;		--Don't execute the next two intructions that are in the pipeline
							else 
								branch <= '0';	--No branch
							end if;
						when "001" => --bne
							if dataA = dataB then
								branch <= '0';	--No branch
							else 
								branch <= '1';	--Branch
								var := 2;		--Don't execute the next two intructions that are in the pipeline
							end if;
						when "100" => --blt
							if signed(dataA) < signed(dataB) then
								branch <= '1';	--Branch
								var := 2;		--Don't execute the next two intructions that are in the pipeline
							else 
								branch <= '0';	--No branch
							end if;
						when "101" => --bge
							if signed(dataA) >= signed(dataB) then
								branch <= '1';	--Branch
								var := 2;		--Don't execute the next two intructions that are in the pipeline
							else 
								branch <= '0';	--No branch
							end if;
						when "110" => --bltu
							if unsigned(dataA) < unsigned(dataB) then 
								branch <= '1';	--Branch
								var := 2;		--Don't execute the next two intructions that are in the pipeline
							else 
								branch <= '0';	--No branch
							end if;
						when "111" => --bgeu
							if unsigned(dataA) >= unsigned(dataB) then 
								branch <= '1';	--Branch
								var := 2;		--Don't execute the next two intructions that are in the pipeline
							else 
								branch <= '0';	--No branch
							end if;
						when others =>
							branch <= '0';	--No branch
					end case;
				when "0100011" => --sb, sh, sw, sd
					branch <= '0';	--No branch
					wreg <= '0';	--Register write enable
					load <= "00";	--No load
					eff_addr <= std_logic_vector(signed(dataA) + signed(imm));
					case f3 is
						when "000" => --sb
							mem_data <= "000000000000000000000000"&dataB(7 downto 0);
							wmem <= "01";	--Memory write enable for byte 
						when "001" => --sh
							mem_data <= "0000000000000000"&dataB(15 downto 0);
							wmem <= "10";	--Memory write enable for half-word
						when "010" => --sw
							mem_data <= dataB;
							wmem <= "11";	--Memory write enable for word
						when "011" => --sd (no 64-bit registers yet)
						when others =>
					end case;
				when "0000011" =>
					branch <= '0';	--No branch
					wmem <= "00";	--Memory write enable
					wreg <= '1';	--Register write enable
					eff_addr <= std_logic_vector(signed(dataA) + signed(imm));
					case f3 is 
						when "000" => --lb
							load <= "01";
						when "001" => --lh
							load <= "10";
						when "010" => --lw
							load <= "11";
						when "011" => --ld
							load <= "11";
						when others =>
					end case;
				when others =>
					branch <= '0';
					load <= "00";
					wreg <= '0';
					wmem <= "00";
			end case;
		else 
			branch <= '0';	
			load <= "00";
			wreg <= '0';
			wmem <= "00";
			var := var - 1;
		end if;
	end if;
end process;
end Behavioral;


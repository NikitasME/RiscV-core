----------------------------------------------------------------------------------
-- Author: Nikitas Metaxakis
-- Create Date:    15:34:08 03/02/2022 
-- Module Name:    core - Structural 
-- Description: The top module that describes the structural architechture of the design.
-- Revision: 1.0
-- License: GPL v3.0
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity core is
	port(clk, rst : in std_logic);
end core;

architecture Structural of core is
	
	-- Component declarations
	
	component pc 
		port(pc_in, branch_t : in std_logic_vector(31 downto 0);
		  clk, rst, branch : in std_logic;
		  l : in std_logic_vector(1 downto 0);
		  pc_out : out std_logic_vector(31 downto 0));
	end component;
	
	component memory
		port(addr_write : in std_logic_vector(7 downto 0);
		  addr_read : in std_logic_vector(7 downto 0);
		  data_in : in std_logic_vector(31 downto 0);
		  we : in std_logic_vector(1 downto 0);
		  clk : in std_logic;
		  data_out : out std_logic_vector(31 downto 0));
	end component;
	
	component decoder
		port( inst, pc_in : in std_logic_vector(31 downto 0);
			clk : in std_logic;
			opcode : out std_logic_vector(6 downto 0);
			rd : out std_logic_vector(4 downto 0);
			rs1 : out std_logic_vector(4 downto 0);
			rs2 : out std_logic_vector(4 downto 0);
			imm, pc_out : out std_logic_vector(31 downto 0);
			funct3 : out std_logic_vector(2 downto 0);
			funct7 : out std_logic_vector(6 downto 0));
	end component;
	
	component registers
		port( regA, regB, regW : in std_logic_vector(4 downto 0);
			clk, we : in std_logic;
			input : in std_logic_vector(31 downto 0);
			outA, outB : out std_logic_vector(31 downto 0));
	end component;
	
	component alu
		port( dataA, dataB, imm, pc : in std_logic_vector(31 downto 0);
			opcode, f7 : in std_logic_vector(6 downto 0);
			f3 : in std_logic_vector(2 downto 0);
			rd_in : in std_logic_vector(4 downto 0);
			clk : in std_logic;
			result, branch_target, mem_data, eff_addr : out std_logic_vector(31 downto 0);
			rd_out : out std_logic_vector(4 downto 0);
			wmem, load : out std_logic_vector(1 downto 0);
			wreg, branch : out std_logic);
	end component;

	-- Signals declatations
	
	signal data_to_memory, data_from_memory, immediate, reg_out_a, reg_out_b, counter, counter2, br_t, alu_out, addr, reg_in : std_logic_vector(31 downto 0);
	signal register_we, br : std_logic;
	signal memory_we, l : std_logic_vector(1 downto 0);
	signal reg_sel_a, reg_sel_b, reg_sel_d, reg_sel_d2 : std_logic_vector(4 downto 0);
	signal opcode, f7 : std_logic_vector(6 downto 0);
	signal read_addr : std_logic_vector(7 downto 0);
	signal f3 : std_logic_vector(2 downto 0);
	
begin

	-- Port Mapping
	
	program_counter : pc port map(
		pc_in => counter,
		pc_out => counter,
		branch_t => br_t,
		branch => br,
		clk => clk,
		rst => rst,
		l => l);	

	mem : memory port map(
		addr_read => read_addr,
		addr_write => addr(7 downto 0),
		data_in => data_to_memory,
		we => memory_we,
		clk => clk,
		data_out => data_from_memory);
		
	dec : decoder port map(
		inst => data_from_memory,
		pc_in => counter,
		pc_out => counter2,
		clk => clk,
		opcode => opcode,
		rd => reg_sel_d,
		rs1 => reg_sel_a,
		rs2 => reg_sel_b,
		imm => immediate,
		funct3 => f3,
		funct7 => f7);
		
	regs : registers port map(
		regA => reg_sel_a,
		regB => reg_sel_b,
		regW => reg_sel_d2,
		clk => clk,
		we => register_we,
		input => reg_in,
		outA => reg_out_a,
		outB => reg_out_b);
		
	yolo : alu port map(
		dataA => reg_out_a,
		dataB => reg_out_b,
		imm => immediate,
		pc => counter2,
		rd_in => reg_sel_d,
		rd_out => reg_sel_d2,
		opcode => opcode,
		f3 => f3,
		f7 => f7,
		clk => clk,
		result => alu_out,
		branch_target => br_t,
		branch => br,
		wreg => register_we,
		wmem => memory_we,
		mem_data => data_to_memory,
		eff_addr => addr,
		load => l);
		
	
	--Read from the memory the next intruction, unless there's a load
	read_addr <= counter(7 downto 0) when l = "00" else
					 addr(7 downto 0);
					 
	--The input for the register is the output of the alu, unless there's a load
	reg_in <= "000000000000000000000000"&data_from_memory(31 downto 24) when l = "01" else
				 "0000000000000000"&data_from_memory(31 downto 16) when l = "10" else
				 data_from_memory when l = "11" else
				 alu_out;
end Structural;


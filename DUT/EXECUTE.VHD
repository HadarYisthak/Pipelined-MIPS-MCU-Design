---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.aux_package.all;


ENTITY  Execute IS
	generic(
		DATA_BUS_WIDTH : integer := 32;
		FUNCT_WIDTH : integer := 6;
		PC_WIDTH : integer := 10
	);
	PORT(		read_data_1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data_2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			funct_i 	: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			jal_i	 	: IN 	STD_LOGIC;
			RegDst_i 	: IN 	STD_LOGIC;
			Opcode_i	: IN 	STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			Wr_data_FW_WB	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Wr_data_FW_MEM	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ForwardA 	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);		
			ForwardB	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			Wr_reg_addr_0	: IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Wr_reg_addr_1	: IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Wr_reg_addr     : OUT   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			zero_o 		: OUT	STD_LOGIC;
			alu_res_o 	: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			WriteData_EX    : OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 )
	);
END Execute;


ARCHITECTURE behavior OF Execute IS
SIGNAL a_input_w, b_input_w,b_input_temp		: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL alu_ctl_w					: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
	


--------------- ALU Inputs: A,B ----------------				
	------------ Forwarding ----------------
		-- Forward A
	WITH ForwardA SELECT 
			a_input_w <= 	read_data_1_i   WHEN "00",
					Wr_data_FW_WB  	WHEN "01",
					Wr_data_FW_MEM 	WHEN "10",
					X"00000000"	WHEN OTHERS;
		-- Forward B
	WITH ForwardB SELECT 
			b_input_temp <= read_data_2_i   WHEN "00",
					Wr_data_FW_WB  	WHEN "01",
					Wr_data_FW_MEM 	WHEN "10",
					X"00000000"	WHEN OTHERS;
--------------------------------------------------------------------------------------------------------
	--mux for sign extantion
	b_input_w <= 	b_input_temp WHEN (ALUSrc_ctrl_i = '0') ELSE
			sign_extend_i(DATA_BUS_WIDTH-1 DOWNTO 0);

	WriteData_EX <= b_input_temp; --_data for sw (rt - read_data_2)

	-----alu control generate-----
	ALU_CTL : ALU_CONTROL
	PORT MAP (	
		ALUOp	=> 	ALUOp_ctrl_i,
		Funct	=> 	funct_i	, 
		Opcode	=>	Opcode_i,
		ALU_ctl	=>	alu_ctl_w
);

----------------- Mux for Register Write Address ---------------------
	 Wr_reg_addr <= "11111"		WHEN RegDst_i = '1' and jal_i = '1' ELSE -- jal
			Wr_reg_addr_1 	WHEN RegDst_i = '1' ELSE 
			Wr_reg_addr_0;


-----alu port map
	LOGIC : ALU
	PORT MAP (	
		zero_o		=> 	zero_o,
		b_input_w	=> 	b_input_w, 
		a_input_w	=>	a_input_w,
		ALU_ctl		=>	alu_ctl_w,
		alu_res_o	=>	alu_res_o
);



  




END behavior;


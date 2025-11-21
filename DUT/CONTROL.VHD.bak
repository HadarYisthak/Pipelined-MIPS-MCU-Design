---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.const_package.all;


ENTITY control IS
   PORT( 	
		opcode_i 		: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		Funct_i			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
		RegDst_ctrl_o 		: OUT 	STD_LOGIC;
		ALUSrc_ctrl_o 		: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 	: OUT 	STD_LOGIC;
		RegWrite_ctrl_o 	: OUT 	STD_LOGIC;
		MemRead_ctrl_o 		: OUT 	STD_LOGIC;
		MemWrite_ctrl_o	 	: OUT 	STD_LOGIC;
		jal_o			: OUT 	STD_LOGIC;
		Branch_ctrl_o 		: OUT 	STD_LOGIC_VECTOR(1 downto 0);
		Jump_ctrl_o 		: OUT 	STD_LOGIC_VECTOR(1 downto 0);
		ALUOp_ctrl_o	 	: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  rtype_w, lw_w, sw_w, beq_w, itype_imm_w, bne_w , jal_w , J_w , Jr_w , mul_w : STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	rtype_w 		<=  '1'	WHEN	opcode_i = R_TYPE_OPC or opcode_i = MUL_OPC	ELSE '0';
	mul_w          		<=  '1'	WHEN  	opcode_i = MUL_OPC  				ELSE '0';
	lw_w          		<=  '1'	WHEN  	opcode_i = LW_OPC  				ELSE '0';
 	sw_w          		<=  '1'	WHEN  	opcode_i = SW_OPC  				ELSE '0';
   	beq_w         		<=  '1'	WHEN  	opcode_i = BEQ_OPC  				ELSE '0';
	itype_imm_w		<=  '1'	WHEN	((opcode_i = ADDI_OPC) or 
						( opcode_i = ORI_OPC)  or 
						( opcode_i = ANDI_OPC) or
						( opcode_i = XORI_OPC) or 
						( opcode_i = SLTI_OPC) or 
						( opcode_i = LUI_OPC) or
						( opcode_i = ADDIU_OPC))  
						ELSE '0';
 
	bne_w 	<= '1' when opcode_i = BNE_OPC else '0';
	jal_w 	<= '1' when opcode_i = JAL_OPC else '0';
	J_w	<= '1' when opcode_i = J_OPC else '0';
	Jr_w 	<= '1' when opcode_i =R_TYPE_OPC and Funct_i = "001000" else '0';			
							
  	RegDst_ctrl_o    	<=  rtype_w or jal_w; ---jal maybe should have a new output
	jal_o			<=  jal_w;
 	ALUSrc_ctrl_o  		<=  lw_w OR sw_w or itype_imm_w;
	MemtoReg_ctrl_o 	<=  lw_w;
  	RegWrite_ctrl_o 	<=  rtype_w OR lw_w or itype_imm_w or jal_w;
  	MemRead_ctrl_o 		<=  lw_w;
   	MemWrite_ctrl_o 	<=  sw_w; 
 	Branch_ctrl_o(0)      	<=  beq_w;
	Branch_ctrl_o(1)      	<=  bne_w;
	JUMP_ctrl_o(0)      	<=  J_w or Jal_w;
	JUMP_ctrl_o(1)      	<=  Jal_w or Jr_w;
	ALUOp_ctrl_o(0) 	<=  beq_w or bne_w or mul_w;
	ALUOp_ctrl_o(1) 	<=  rtype_w;

   END behavior;




---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
USE work.cond_comilation_package.all;


package aux_package is

	component MIPS is
		generic( 
			WORD_GRANULARITY : boolean 	:= G_WORD_GRANULARITY;
	        	MODELSIM : integer 		:= G_MODELSIM;
			DATA_BUS_WIDTH : integer 	:= 32;
			ITCM_ADDR_WIDTH : integer 	:= G_ADDRWIDTH;
			DTCM_ADDR_WIDTH : integer 	:= 10;
			PC_WIDTH : integer 		:= 8;
			FUNCT_WIDTH : integer 		:= 6;
			DATA_WORDS_NUM : integer 	:= G_DATA_WORDS_NUM;
			CLK_CNT_WIDTH : integer 	:= 16;
			INST_CNT_WIDTH : integer 	:= 16
	);
	PORT( 	rst_i, clk_i			: IN 	STD_LOGIC;
		BPADDR_i			: IN   STD_LOGIC_VECTOR( 7 DOWNTO 0 ); 
		-- Output important signals to pins for easy display in Simulator
		IFpc_o				: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		IDpc_o				: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		EXpc_o				: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		MEMpc_o				: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		WBpc_o				: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		IFinstruction_o			: OUT  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		IDinstruction_o			: OUT  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		EXinstruction_o			: OUT  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		MEMinstruction_o		: OUT  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		WBinstruction_o			: OUT  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		INSTCNT_o			: OUT  STD_LOGIC_VECTOR( 15 DOWNTO 0);
		CLKCNT_o			: OUT  STD_LOGIC_VECTOR( 15 DOWNTO 0);
		STCNT_o				: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		FHCNT_o				: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		STRIGERR_o			: OUT  STD_LOGIC
		);
	end component;
---------------------------------------------------------  
	component control is
		   PORT( 	
		opcode_i 		: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		Funct_i			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		RegDst_ctrl_o 		: OUT 	STD_LOGIC;
		ALUSrc_ctrl_o 		: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 	: OUT 	STD_LOGIC;
		RegWrite_ctrl_o 	: OUT 	STD_LOGIC;
		MemRead_ctrl_o 		: OUT 	STD_LOGIC;
		MemWrite_ctrl_o	 	: OUT 	STD_LOGIC;
		jal_o			: OUT 	STD_LOGIC;
		Branch_ctrl_o 		: OUT 	STD_LOGIC_VECTOR(1 downto 0);  --- first bit beq second bne
		Jump_ctrl_o 		: OUT 	STD_LOGIC;
		ALUOp_ctrl_o	 	: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
	end component;
---------------------------------------------------------	
	component dmemory is
		generic(
		DATA_BUS_WIDTH : integer := 32;
		DTCM_ADDR_WIDTH : integer := 10;
		WORDS_NUM : integer := 256
	);
	PORT(		clk_i,rst_i			: IN 	STD_LOGIC;
			dtcm_addr_i 		: IN 	STD_LOGIC_VECTOR(DTCM_ADDR_WIDTH-1 DOWNTO 0);
			dtcm_data_wr_i 		: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			MemRead_ctrl_i  	: IN 	STD_LOGIC;
			MemWrite_ctrl_i 	: IN 	STD_LOGIC;
			dtcm_data_rd_o 		: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
	end component;
---------------------------------------------------------		
	component Execute is
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
	end component;
---------------------------------------------------------		
	component Idecode is
		generic(
		DATA_BUS_WIDTH : integer := 32
	);
	PORT(		clk_i,rst_i			: IN 	STD_LOGIC;
			instruction_i 			: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			RegWrite_ctrl_i 		: IN 	STD_LOGIC;
			Jump				: IN	STD_LOGIC;
			pc_plus_4_i			: IN	STD_LOGIC_VECTOR(7 DOWNTO 0);
			ForwardA_ID, ForwardB_ID	: IN 	STD_LOGIC;
			write_register_address      	: IN    STD_LOGIC_VECTOR(4 DOWNTO 0);
			Branch_read_data_FW		: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
			Branch_ctrl_i			: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
			Stall_ID			: IN    STD_LOGIC;
			write_reg_data_i		: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
			PCSrc		 		: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			read_data_1_o			: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data_2_o			: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_o 			: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_register_1_address_w 	: OUT 	STD_LOGIC_VECTOR(4 DOWNTO 0);
			read_register_2_address_w 	: OUT 	STD_LOGIC_VECTOR(4 DOWNTO 0);
			write_register_address_0 	: OUT 	STD_LOGIC_VECTOR(4 DOWNTO 0);
			write_register_address_1 	: OUT 	STD_LOGIC_VECTOR(4 DOWNTO 0);
			pc_jump_o			: OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
			pc_branch_o 			: OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	end component;
---------------------------------------------------------		
	component Ifetch is
		GENERIC (MemWidth	: INTEGER;
		SIM 		: BOOLEAN);
	PORT(	IF_instruction_o					: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	IF_pc_plus_4_o 						: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		PCSrc_i 						: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        	Add_result_i 						: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
      		IF_pc_o 						: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		JumpAddr_i						: IN	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	clock, Stall_IF, reset,RUN			 		: IN 	STD_LOGIC);
	end component;
---------------------------------------------------------
	COMPONENT PLL port(
	    areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0     		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC );
    END COMPONENT;
---------------------------------------------------------	
COMPONENT  ALU_CONTROL IS
	PORT(	ALUOp 	: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		Funct 	: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
		Opcode 	: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
		ALU_ctl : OUT   STD_LOGIC_VECTOR( 3 DOWNTO 0 ));
END COMPONENT;
---------------------------------------------------------
COMPONENT Shifter IS
  GENERIC (
    n : INTEGER := 32;     -- data width
    k : INTEGER := 5       -- size of shamt
  );
  PORT (
    x, y       : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);     -- x contains shift amount in bits [k-1:0], y is data
    dir        : IN  STD_LOGIC;       			 -- direction: "000" = left, "001" = right
    res        : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
END COMPONENT;
---------------------------------------------------------
COMPONENT  ALU IS
	PORT(		a_input_w 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			b_input_w 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_ctl		 		: IN 	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
			zero_o 				: OUT	STD_LOGIC;
			alu_res_o			: OUT   STD_LOGIC_VECTOR( 31 DOWNTO 0 )
			);
END COMPONENT;
---------------------------------------------------------
COMPONENT HazardUnit IS
	PORT( 
		MemtoReg_EX, MemtoReg_MEM	 	: IN STD_LOGIC;
		WriteReg_EX, WriteReg_MEM	 	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);  -- rt and rd mux output
		RegRs_ID, RegRt_ID 			: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		RegRt_EX				: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_RegWr				: IN STD_LOGIC;
		Branch_ctrl				: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		Stall_IF, Stall_ID	 	 	: OUT STD_LOGIC
		);
END COMPONENT;
---------------------------------------------------------
COMPONENT ForwardingUnit IS
	PORT( 
		WriteReg_MEM, WriteReg_WB	: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_RegRs, EX_RegRt 		: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		ID_RegRs, ID_RegRt 		: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		MEM_RegWr, WB_RegWr		: IN  STD_LOGIC;
		MemtoReg_MEM			: IN STD_LOGIC;
		ForwardA, ForwardB		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		ForwardA_ID, ForwardB_ID	: OUT STD_LOGIC
		);
END COMPONENT;
---------------------------------------------------------
COMPONENT WRITE_BACK IS
	PORT( 
		ALU_Result, read_data		: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC_plus_4_i			: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		MemtoReg, Jal			: IN  STD_LOGIC;
		write_data 			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		write_data_mux			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
END COMPONENT;


end aux_package;


---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;
USE work.cond_comilation_package.all;
USE work.aux_package.all;


ENTITY MIPS IS
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
	PORT( 	rst_i, clk_i			: IN   STD_LOGIC;
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
END MIPS;
-------------------------------------------------------------------------------------
ARCHITECTURE structure OF MIPS IS
	-- declare signals used to connect VHDL components

	SIGNAL resetSim								: STD_LOGIC;
	SIGNAL RUN										: STD_LOGIC := '0';
	SIGNAL FHCNT_sig,STCNT_sig 				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL INSTCNT_sig,CLKCNT_sig 			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL dMemAddr 								: STD_LOGIC_VECTOR(DTCM_ADDR_WIDTH-1 DOWNTO 0);
	SIGNAL clk_pll, PLL_LOCKED,STOP 			: STD_LOGIC;
	
------ Control Registers ------
	-- WB -- 
	SIGNAL MemtoReg_WB, MemtoReg_MEM, MemtoReg_EX, MemtoReg_ID 	: STD_LOGIC;
	SIGNAL RegWrite_WB, RegWrite_MEM, RegWrite_EX, RegWrite_ID 	: STD_LOGIC;
	SIGNAL Jal_WB, Jal_MEM, Jal_EX, Jal_ID				: STD_LOGIC;
	
	-- MEM --
	SIGNAL Zero_MEM, Zero_EX 			: STD_LOGIC;
	SIGNAL MemWrite_MEM, MemWrite_EX, MemWrite_ID 	: STD_LOGIC;
	SIGNAL MemRead_MEM, MemRead_EX, MemRead_ID 	: STD_LOGIC;
	
	-- Forwarding Unit
	SIGNAL ForwardA, ForwardB					: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ForwardA_ID, ForwardB_ID					: STD_LOGIC; -- Branch Forwarding
	
	-- EXEC -- 
	
	SIGNAL ALUSrc_EX, ALUSrc_ID ,RegDst_EX, RegDst_ID 		: STD_LOGIC;
	SIGNAL ALUOp_EX, ALUOp_ID 					: STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	-- Hazard Unit -- Stall AND Flush
	SIGNAL Stall_IF, Stall_ID, Flush_sig				: STD_LOGIC;
	
	-- Instruction Decode --
	SIGNAL PCSrc_ID							: STD_LOGIC_VECTOR(1 DOWNTO 0);
	
-------- States Registers ------
	-- Instruction Fetch
	SIGNAL PC_plus_4_IF	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL IR_IF		: STD_LOGIC_VECTOR(31 DOWNTO 0 );
	SIGNAL PC_IF		: STD_LOGIC_VECTOR(7 DOWNTO 0);

	-- Instruction Decode
	SIGNAL PC_plus_4_ID				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL IR_ID		    			: STD_LOGIC_VECTOR(31 DOWNTO 0 );
	SIGNAL PC_ID					: STD_LOGIC_VECTOR(7 DOWNTO 0); 
	SIGNAL read_data_1_ID, read_data_2_ID 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_extend_ID				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Wr_reg_addr_0_ID, Wr_reg_addr_1_ID	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL rd_reg_adde_1_ID,rd_reg_adde_2_ID	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL PCBranch_addr_ID				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL JumpAddr_ID				: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Branch_ctrl_ID				: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Jump_ID					: STD_LOGIC;
	
																
	-- Execute                                                  
	SIGNAL PC_plus_4_EX				      		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL IR_EX		    			  		: STD_LOGIC_VECTOR(31 DOWNTO 0 ); 
	SIGNAL PC_EX							: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL read_data_1_EX, read_data_2_EX 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_extend_EX				  		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Wr_reg_addr_0_EX, Wr_reg_addr_1_EX, Wr_reg_addr_EX	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_data_EX						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Add_Result_EX						: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_Result_EX					   	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Opcode_EX						: STD_LOGIC_VECTOR( 5 DOWNTO 0 );
																
	-- Memory
	SIGNAL IR_MEM		    		: STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
	SIGNAL PC_MEM				: STD_LOGIC_VECTOR(7 DOWNTO 0);     
	SIGNAL PC_plus_4_MEM			: STD_LOGIC_VECTOR(7 DOWNTO 0);	
	SIGNAL Add_Result_MEM			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL ALU_Result_MEM			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL write_data_MEM, read_data_MEM	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Wr_reg_addr_MEM			: STD_LOGIC_VECTOR( 4 DOWNTO 0 );									    
	SIGNAL JumpAddr_MEM			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
	-- WriteBack
	SIGNAL IR_WB		    		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL PC_WB				: STD_LOGIC_VECTOR(7 DOWNTO 0); 
	SIGNAL PC_plus_4_WB			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL read_data_WB			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ALU_Result_WB			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Wr_reg_addr_WB			: STD_LOGIC_VECTOR( 4 DOWNTO 0 ); 
	SIGNAL write_data_WB			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL write_data_mux_WB		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	------------------------------------------------------


BEGIN

-------------------------- FPGA or ModelSim -----------------------
	--resetSim	 	<= rst_i;
	resetSim 	<= rst_i WHEN WORD_GRANULARITY ELSE not rst_i;
-------------------------- output signals -----------------------
		IFpc_o			<= PC_IF;			
		IDpc_o			<= PC_ID;
		EXpc_o			<= PC_EX;	
		MEMpc_o			<= PC_MEM;	
		WBpc_o			<= PC_WB;	
		IFinstruction_o		<= IR_IF;	
		IDinstruction_o		<= IR_ID;	
		EXinstruction_o		<= IR_EX;	
		MEMinstruction_o	<= IR_MEM;	
		WBinstruction_o		<= IR_WB;	
	

   --------------------- PORT MAP COMPONENTS --------------------------
	-------------------PLL -----------------------------
	pll_inst: PLL port map(
		inclk0 => clk_i,
		areset => '0',
		c0 => clk_pll, 
		locked => PLL_LOCKED
	);
	--clk_pll <= clk_i;
   ----- Instruction Fetch -----
	IFE : Ifetch GENERIC MAP(MemWidth => DTCM_ADDR_WIDTH , SIM => G_WORD_GRANULARITY  ) 
	PORT MAP (		IF_instruction_o	=> IR_IF,
    	    			IF_pc_plus_4_o 		=> PC_plus_4_IF,
				Add_result_i 		=> PCBranch_addr_ID(7 DOWNTO 0), 
				PCSrc_i			=> PCSrc_ID,
				IF_pc_o 		=> PC_IF,      
				JumpAddr_i		=> JumpAddr_ID,
				clock 			=> clk_pll, 
				Stall_IF	    	=> Stall_IF,
				reset 			=> resetSim,
				RUN				=> RUN);




----- Instruction Decode -----
	ID : Idecode
   	PORT MAP (		read_data_1_o 		=> read_data_1_ID,
        			read_data_2_o 		=> read_data_2_ID,
				write_register_address_0=> Wr_reg_addr_0_ID,
				write_register_address_1=> Wr_reg_addr_1_ID,
				write_register_address  => Wr_reg_addr_WB,
				read_register_1_address_w => rd_reg_adde_1_ID,
				read_register_2_address_w => rd_reg_adde_2_ID,
        			instruction_i 		=> IR_ID,
				pc_plus_4_i	 	=> PC_plus_4_ID,
				RegWrite_ctrl_i 	=> RegWrite_WB,
				write_reg_data_i	=> write_data_mux_WB,
				ForwardA_ID		=> ForwardA_ID,
				ForwardB_ID		=> ForwardB_ID,
				Branch_ctrl_i		=> Branch_ctrl_ID,
				Jump			=> Jump_ID,
				Stall_ID	    	=> Stall_ID, 
				Branch_read_data_FW 	=> ALU_Result_MEM, 
				Sign_extend_o 		=> Sign_extend_ID,
				PCSrc			=> PCSrc_ID,
				pc_jump_o		=> JumpAddr_ID,
				pc_branch_o		=> PCBranch_addr_ID,
        			clk_i 			=> clk_pll,  
				rst_i 			=> resetSim );


----- Control Unit in Instruction Decode -----
	CTL:   control
	PORT MAP ( 		opcode_i 		=> IR_ID( 31 DOWNTO 26 ),
                		Funct_i			=> IR_ID( 5 DOWNTO 0 ),
				RegDst_ctrl_o 		=> RegDst_ID,
				ALUSrc_ctrl_o 		=> ALUSrc_ID,
				MemtoReg_ctrl_o 	=> MemtoReg_ID,
				RegWrite_ctrl_o 	=> RegWrite_ID,
				MemRead_ctrl_o 		=> MemRead_ID,
				MemWrite_ctrl_o 	=> MemWrite_ID,
				Branch_ctrl_o		=> Branch_ctrl_ID,
				Jump_ctrl_o		=> Jump_ID,
				jal_o			=> Jal_ID,
				ALUOp_ctrl_o 		=> ALUop_ID );

----- Execute -----
	EXE:  Execute
   	PORT MAP (	Read_data_1_i 	=> read_data_1_EX,
             		Read_data_2_i 	=> read_data_2_EX,
			Sign_extend_i 	=> Sign_extend_EX,
                	funct_i		=> Sign_extend_EX( 5 DOWNTO 0 ),
			Opcode_i 	=> Opcode_EX,
			ALUOp_ctrl_i 	=> ALUOp_EX,
			ALUSrc_ctrl_i 	=> ALUSrc_EX,
			zero_o 		=> Zero_EX,
			RegDst_i	=> RegDst_EX,
                	alu_res_o	=> ALU_Result_EX,
			Wr_reg_addr     => Wr_reg_addr_EX,
			Wr_reg_addr_0   => Wr_reg_addr_0_EX,
			Wr_reg_addr_1   => Wr_reg_addr_1_EX,
			Wr_data_FW_WB	=> write_data_WB,  -- For Forwarding
			Wr_data_FW_MEM	=> ALU_Result_MEM, -- For Forwarding
			ForwardA	=> ForwardA,
			ForwardB	=> ForwardB,
			WriteData_EX    => write_data_EX,
                	jal_i		=> Jal_EX );
				

----- Hazard Unit (Stalls AND Flushs AND Forwarding) -----
	Hazard:	HazardUnit PORT MAP(	
				MemtoReg_EX	=> MemtoReg_EX,	
				MemtoReg_MEM	=> MemtoReg_MEM,
				WriteReg_EX	=> Wr_reg_addr_EX,
				WriteReg_MEM   	=> Wr_reg_addr_MEM,
				RegRt_EX 	=> IR_EX(20 DOWNTO 16),
				RegRs_ID	=> IR_ID(25 DOWNTO 21),
				RegRt_ID 	=> IR_ID(20 DOWNTO 16),
				EX_RegWr	=> RegWrite_EX,
				Branch_ctrl	=> Branch_ctrl_ID,
				Stall_IF        => Stall_IF,
				Stall_ID        => Stall_ID);


----- Forward Unit (Forwarding) -----
	Forward: forwardingUnit
	PORT MAP(		
				MemtoReg_MEM	=> MemtoReg_MEM,
				WriteReg_WB	=> Wr_reg_addr_WB,
				WriteReg_MEM   	=> Wr_reg_addr_MEM,
				EX_RegRt 	=> IR_EX(20 DOWNTO 16),
				EX_RegRs	=> IR_EX(25 DOWNTO 21),
				ID_RegRs	=> IR_ID(25 DOWNTO 21),
				ID_RegRt 	=> IR_ID(20 DOWNTO 16),
				MEM_RegWr	=> RegWrite_MEM,
				WB_RegWr	=> RegWrite_WB,
				ForwardA    	=> ForwardA,
				ForwardB	=> ForwardB,
				ForwardA_ID 	=> ForwardA_ID,
				ForwardB_ID	=> ForwardB_ID);


----- Data Memory -----
	ModelSim_part: 
		IF (WORD_GRANULARITY = TRUE) GENERATE
				dMemAddr <= ALU_Result_MEM (9 DOWNTO 0);
		END GENERATE ModelSim_part;
		
	FPGA: 
		IF (WORD_GRANULARITY = FALSE) GENERATE
				--dMemAddr <= ALU_Result_MEM(9 DOWNTO 2) & "00" ;
				dMemAddr <= ALU_Result_MEM(9 DOWNTO 0)  ;
		END GENERATE FPGA;
	
	MEM:  dmemory
	GENERIC MAP(WORDS_NUM => DATA_WORDS_NUM, DTCM_ADDR_WIDTH =>DTCM_ADDR_WIDTH) 
	PORT MAP (	dtcm_data_rd_o 		=> read_data_MEM,
			dtcm_addr_i 		=> dMemAddr,  --jump memory address by 4
			dtcm_data_wr_i 		=> write_data_MEM, 
			MemRead_ctrl_i 		=> MemRead_MEM, 
			MemWrite_ctrl_i 	=> MemWrite_MEM, 
         clk_i 			=> clk_pll,  
			rst_i 			=> resetSim );

----- Write Back -----	
	WB: WRITE_BACK PORT MAP(ALU_Result		=> ALU_Result_WB,
				read_data		=> read_data_WB,
				PC_plus_4_i		=> PC_plus_4_WB,
				MemtoReg		=> MemtoReg_WB,
				Jal			=> Jal_WB,  
				write_data		=> write_data_WB,
				write_data_mux		=> write_data_mux_WB);


---------------------------------------------------------------------------
	------- PROCESS TO COUNT Clocks, Stalls, Flushs --------
	IFpc_o		<= PC_IF;
	STRIGERR_o 	<= '1' WHEN ((NOT WORD_GRANULARITY) AND (BPADDR_i = PC_ID(7 DOWNTO 0)) and (BPADDR_i /= X"00")) ELSE '0'; 
	Flush_sig	<= PCSrc_ID(0) OR PCSrc_ID(1);
	


PROCESS (clk_pll, resetSim, Flush_sig, Stall_ID, Stall_IF) 
		VARIABLE CLKCNT_sig		: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		VARIABLE INSTCNT_sig		: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		VARIABLE STCNT_sig		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		VARIABLE FHCNT_sig		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		
	BEGIN
		IF resetSim = '1' THEN
			INSTCNT_sig	:= X"0000";
			CLKCNT_sig  	:= X"0000";
			STCNT_sig 	:= X"00";
			FHCNT_sig 	:= X"00";
		ELSIF (rising_edge(clk_pll)) THEN 	-- count clk counts on rising edge
			CLKCNT_sig := CLKCNT_sig + 1;
			IF Stall_IF = '1' THEN 	-- count on rising edge when stall occurs
				STCNT_sig := STCNT_sig + 1;
			END IF;
			IF Flush_sig = '1' THEN		-- count on rising edge when flush occurs
				FHCNT_sig := FHCNT_sig + 1;
			END IF;
			IF (Stall_IF= '0' and FLUSH_sig ='0') THEN
				INSTCNT_sig := INSTCNT_sig + 1;
			END IF;
			
		END IF;
		------------- Signals To support CPI/IPC calculation -------------
		CLKCNT_o 	<= CLKCNT_sig;
		STCNT_o		<= STCNT_sig;
		FHCNT_o		<= FHCNT_sig;
		INSTCNT_o	<= INSTCNT_sig;
	END PROCESS;


	
	----------------------- Connect Pipeline Registers ------------------------
	
	RUN <= '1' WHEN (resetSim'EVENT and resetSim='1');
	
	PROCESS (clk_pll,resetSim,RUN)
	BEGIN
		IF (clk_pll'EVENT AND clk_pll = '1') THEN-- and resetSim ='0' and RUN='1') THEN
			-------------- Instruction Fetch TO Instruction Decode ---------------- 
			IF Stall_ID = '0' THEN 
				PC_plus_4_ID <= PC_plus_4_IF;
				IR_ID <= IR_IF;
				PC_ID <= PC_IF;
			END IF;
			IF Flush_sig='1'  THEN -- CLR IF_ID
				PC_plus_4_ID 	<= "00000000";
				IR_ID 		<= X"00000000";
				PC_ID		<= "00000000";			
			END IF;
			-------------------- Instruction Decode TO Execute -------------------- 
			IF (Stall_ID = '1') THEN -- CLR ID_IF register
				----- Control Reg ----
				---removed branch_EX---
				MemtoReg_EX      <= '0';
				RegWrite_EX      <= '0';
				MemWrite_EX      <= '0';
				MemRead_EX	 <= '0';
				RegDst_EX 	 <= '0';  
				ALUSrc_EX	 <= '0';
				ALUOp_EX 	 <= "00";
				Opcode_EX	 <= "000000";
				Jal_EX		 <= '0';   
				----- State Reg -----
				PC_plus_4_EX     <= "00000000";
				IR_EX		 <= X"00000000";
				PC_EX		 <= "00000000";
				read_data_1_EX   <= X"00000000";
				read_data_2_EX   <= X"00000000";
				Sign_extend_EX   <= X"00000000";
				Wr_reg_addr_0_EX <= "00000";
				Wr_reg_addr_1_EX <= "00000";
			ELSE 
				----- Control Reg -----
				MemtoReg_EX     <= MemtoReg_ID;
				RegWrite_EX     <= RegWrite_ID;
				MemWrite_EX     <= MemWrite_ID;
				MemRead_EX	<= MemRead_ID;
				RegDst_EX 	<= RegDst_ID;
				ALUSrc_EX	<= ALUSrc_ID;
				ALUOp_EX 	<= ALUOp_ID;
				Opcode_EX	<= IR_ID(31 DOWNTO 26);
				Jal_EX		<= Jal_ID;   
				----- State Reg -----
				PC_plus_4_EX     <= PC_plus_4_ID; 
				IR_EX		 <= IR_ID; 
				PC_EX		 <= PC_ID;
				read_data_1_EX   <= read_data_1_ID;   
				read_data_2_EX   <= read_data_2_ID; 
				Sign_extend_EX   <= Sign_extend_ID; 
				Wr_reg_addr_0_EX <= Wr_reg_addr_0_ID; 
				Wr_reg_addr_1_EX <= Wr_reg_addr_1_ID; 
			END IF;
			
			-------------------------- Execute TO Memory --------------------------- 
			----- Control Reg -----
			MemtoReg_MEM    <= MemtoReg_EX;
			RegWrite_MEM    <= RegWrite_EX;
			MemWrite_MEM    <= MemWrite_EX;
			MemRead_MEM	<= MemRead_EX;	
			Jal_MEM		<= Jal_EX;
			----- State Reg -----
			PC_plus_4_MEM	<= PC_plus_4_EX;
			ALU_Result_MEM  <= ALU_Result_EX;
			write_data_MEM	<= write_data_EX;  
			Wr_reg_addr_MEM	<= Wr_reg_addr_EX;
			IR_MEM		 <= IR_EX; 
			PC_MEM		 <= PC_EX;
			
			------------------------- Memory TO WriteBack ------------------------- 
			----- Control Reg -----
			MemtoReg_WB		<= MemtoReg_MEM;
			RegWrite_WB		<= RegWrite_MEM;
			Jal_WB			<= Jal_MEM;
			
			----- State Reg -----
			PC_plus_4_WB	<= PC_plus_4_MEM;
			read_data_WB	<= read_data_MEM;
			ALU_Result_WB	<= ALU_Result_MEM;
			Wr_reg_addr_WB	<= Wr_reg_addr_MEM;
			IR_WB		<= IR_MEM; 
			PC_WB		<= PC_MEM;
		END IF;
		
	END PROCESS;		
	---------------------------------------------------------------------------
END structure;












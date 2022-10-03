module RISCV_TOP (
	//General Signals
	input wire CLK,
	input wire RSTn,

	//I-Memory Signals
	output wire I_MEM_CSN,
	input wire [31:0] I_MEM_DI,//input from IM
	output reg [11:0] I_MEM_ADDR,//in byte address

	//D-Memory Signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DI,
	output wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,

	//RegFile Signals
	output wire RF_WE,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA1,
	input wire [31:0] RF_RD1,
	input wire [31:0] RF_RD2,
	output wire [31:0] RF_WD,
	output wire HALT,                   // if set, terminate program
	output reg [31:0] NUM_INST,         // number of instruction completed
	output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
	);

	// TODO:
	// 3. Initialize all intermediate register values at NOP -- do nothing until actual instruction controls arrive 
	// 			- Do so via Initial begin ... end 
	// 5. See what to do with CSN, WEN, NUM_INST, OUTPUT_PORT, CLK, RSTn 

	// I_MEM_CSN and D_MEM_CSN
	// bitwise masks for accessing intstructions and data from memory 

	// WIRE INITIALIZATIONS
	wire[6:0] ALUop_IN; 
	wire [3:0] AlUop_OUT;
	// hazard 
	wire ID_EX_MemRead_IN; 
	wire[4:0] ID_EX_RD_IN; 
    wire[4:0] IF_ID_RS1_IN; 
    wire[4:0] IF_ID_RS2_IN; 
	wire PCWrite_OUT; 
	wire IF_ID_Write_OUT;
    wire ID_EX_CtrlSrc_OUT; 
	// forward 
	wire EX_MEM_RegWrite_IN; 
	wire MEM_WB_RegWrite_IN;
	wire[1:0] FRD_A_OUT; 
	wire[1:0] FRD_B_OUT;
	// PC 
	wire [31:0] PC_IN;
	wire [31:0] PC_OUT;
	// PC INC 
	wire [31:0] PC_4_OUT;
	// JUMP 
	wire [31:0] MUX_JUMP_IN; 
	wire [31:0] MUX_JUMP_OUT;
	// NOP 
	parameter [31:0] NOP = 32'b0;
	wire [31:0] IR_D_IN; 
	// IF/ID 
	wire [31:0] PC_D_OUT; 
	wire [31:0] PC_4_D_OUT;
	wire [31:0] IR_D_OUT;

	wire[31:0] func7_IN; // passed to ALU CONTROL
	wire[31:0] func3_IN; // passed to ALU CONTROL
	wire [20:0] CTRLS_OUT; 
	wire [31:0] CTRLS_EX_OUT;
	wire [31:0] PC_EX_OUT;
	wire [31:0] PC_4_EX_OUT;
	wire [31:0] RF_RD1_EX_OUT; 
	wire [31:0] RF_RD2_EX_OUT;
	wire [31:0] SW_EX_OUT;
	wire [31:0] Br_Imm_EX_OUT;
	wire [31:0] Imm_EX_OUT;
	wire [31:0] JAL_EX_OUT;
	wire [31:0] RD_EX_OUT;
	wire [31:0] RS1_EX_OUT; 
	wire [31:0] RS2_EX_OUT;
	wire [31:0] Br_Addr_M_IN; 
	wire [31:0] MUX_A_OUT; 
	wire [31:0] MUX_B_OUT;
	wire [31:0] ALU_FRD_A_OUT; 
	wire [31:0] ALU_FRD_B_OUT; 
	wire [31:0] AOut_M_IN; 
	wire BrTkn_M_IN; 
	wire [6:0] CTRLS_M_IN; 
	wire [31:0] CTRLS_M_OUT;
	wire [31:0] PC_4_M_OUT; 
	wire [31:0] Br_Addr_M_OUT;

	wire [31:0] AOut_M_OUT;
	wire [31:0] BrTkn_M_OUT;
	wire [31:0] B_M_OUT;
	wire [31:0] RD_M_OUT;
	wire BrFlush_OUT;
	wire [6:0] CTRLS_WB_IN;
	wire [31:0] CTRLS_WB_OUT;
	wire [31:0] PC_4_WB_OUT;
	wire [31:0] MDR_WB_OUT;
	wire [31:0] AOut_WB_OUT;
	wire [31:0] RD_WB_OUT; 
	wire [31:0] MEM_TO_REG_OUT;
	wire [31:0] WB_OUT; 

	// CONTROL UNIT 
	wire[6:0] OPCODE_IN; 
	wire ID_EX_RS1_used_OUT; 
	wire ID_EX_RS2_used_OUT; 
	wire RD_used_OUT; 
	wire SrcA_OUT; 
	wire NullLSB_OUT; 
	wire InstComp_OUT; 
	wire Jump_OUT; 
	wire RegWrite_OUT; 
	wire [6:0] ALUCtrl_OUT; 
	wire [1:0] SrcB_OUT; 
	wire Branch_OUT;
	wire MemWrite_OUT; 
	wire MemRead_OUT; 
	wire MemToReg_OUT; 
	wire ALUToReg_OUT; 
	CONTROL CTRL_UNIT(
		.OPCODE			(OPCODE_IN),
		.ID_EX_RS1_used	(ID_EX_RS1_used_OUT),
		.ID_EX_RS2_used	(ID_EX_RS2_used_OUT),
		.SrcA			(SrcA_OUT),
		.NullLSB	 	(NullLSB_OUT), 
		.InstComp		(InstComp_OUT),
		.Jump 			(Jump_OUT), 
  		.RegWrite		(RegWrite_OUT),
  		.ALUCtrl		(ALUCtrl_OUT),
  		.SrcB			(SrcB_OUT),
  		.Branch			(Branch_OUT),
  		.MemWrite		(MemWrite_OUT),
  		.MemRead		(MemRead_OUT),
  		.MemToReg		(MemToReg_OUT),
  		.ALUToReg		(ALUToReg_OUT)
	);

	// ALU CONTROL UNIT 
	// func7_IN coming from FUNC7_EX (see below)
	// func3_IN coming from FUNC3_EX (see below)
	 
	ALUCONTROL ALU_CTRL_UNIT(
    	.func7				(func7_IN[6:0]),
    	.func3				(func3_IN[2:0]),
    	.ALUop				(ALUop_IN),

    	.ALUControlSignal	(AlUop_OUT)
	);

	// HAZARD UNIT
	// CTRLS_EX_OUT = {ID_EX_RS2_used_OUT [20], ID_EX_RS1_used_OUT [19], SrcA_OUT [18], NullLSB_OUT [17], InstComp_OUT [16], Jump_OUT [15], RegWrite_OUT [14], ALUCtrl_OUT [13:7], SrcB_OUT [6:5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]};

	assign ID_EX_MemRead_IN = CTRLS_EX_OUT[2]; 
	assign ID_EX_RD_IN = RD_EX_OUT[4:0]; 
	assign IF_ID_RS1_IN = IR_D_OUT[19:15];
	assign IF_ID_RS2_IN = IR_D_OUT[24:20]; 
	HZRD HZRD_UNIT(
    	.ID_EX_MemRead	(ID_EX_MemRead_IN), 
		.BrFlush		(BrFlush_OUT),
    	.ID_EX_RD		(ID_EX_RD_IN),
    	.IF_ID_RS1		(IF_ID_RS1_IN),
    	.IF_ID_RS2		(IF_ID_RS2_IN),
		.RSTn			(RSTn),
		.OP				(IR_D_OUT[6:0]),
    	.PCWrite		(PCWrite_OUT),
    	.IF_ID_Write	(IF_ID_Write_OUT),
    	.ID_EX_CtrlSrc	(ID_EX_CtrlSrc_OUT)
	);

	// FORWARDING UNIT 
	// CTRLS_M_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	assign EX_MEM_RegWrite_IN = CTRLS_M_OUT[5]; // RegWrite_OUT 
	// CTRLS_WB_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], BrFlush_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	assign MEM_WB_RegWrite_IN = CTRLS_WB_OUT[5]; // RegWrite_OUT
	// assign ID_EX_RS1_IN = RS1_EX_OUT; 
	// assign ID_EX_RS2_IN = RS2_EX_OUT; 
	// CTRLS_EX_OUT = {ID_EX_RS2_used_OUT [20], ID_EX_RS1_used_OUT [19], SrcA_OUT [18], NullLSB_OUT [17], InstComp_OUT [16], Jump_OUT [15], RegWrite_OUT [14], ALUCtrl_OUT [13:7], SrcB_OUT [6:5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]};
	// CTRLS_M_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	// CTRLS_WB_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], BrFlush_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	wire FRD_PRE_A_OUT;
	wire FRD_PRE_B_OUT; 
	FRD FRD_UNIT(
    	.EX_MEM_RegWrite	(EX_MEM_RegWrite_IN), 
    	.MEM_WB_RegWrite	(MEM_WB_RegWrite_IN),
    	.EX_MEM_RD			(RD_M_OUT),
    	.ID_EX_RS1			(RS1_EX_OUT),
    	.ID_EX_RS2			(RS2_EX_OUT),
		.ID_EX_RS1_used		(CTRLS_EX_OUT[19]),
		.ID_EX_RS2_used		(CTRLS_EX_OUT[20]),
    	.MEM_WB_RD			(RD_WB_OUT),
    	.FRD_A				(FRD_A_OUT),
    	.FRD_B				(FRD_B_OUT),
		.OP					(IR_D_OUT[6:0]),
		.IF_ID_RS1			({27'b0, IR_D_OUT[19:15]}),
		.IF_ID_RS2			({27'b0, IR_D_OUT[24:20]}),
		.FRD_PRE_A			(FRD_PRE_A_OUT),
		.FRD_PRE_B			(FRD_PRE_B_OUT)
	);

	// -------- BEGIN MODULES OF CPU -------- // 

	// PC 
	// PCWrite_OUT is output wire of hazard unit, initially assigned to 1 (see below)
	
	REG PC_REG (
		.CLK	(CLK),
		.write	(PCWrite_OUT),
		.IN		(PC_IN),
		.OUT	(PC_OUT)
	); 
	// PC_OUT is output wire of PC_REG, initially assigned to 1 (see below)
	 
	PC_INC PC_4_INC (
		.PC_current (PC_OUT), 
		.PC_4		(PC_4_OUT)
	); 
	// Jump MUX
	// PC_4_OUT output from PC_4_INC (see above)
	// AOut_M_IN is output from ALU MAIN UNIT (see below)
	// JUMP_OUT at CTRLS_EX_OUT[15] - output from reg CTRL_EX in ID/EX (see below)
	// CTRLS_EX_OUT = {RD_used_OUT [21], ID_EX_RS2_used_OUT [20], ID_EX_RS1_used_OUT [19], SrcA_OUT [18], NullLSB_OUT [17], InstComp_OUT [16], Jump_OUT [15], RegWrite_OUT [14], ALUCtrl_OUT [13:7], SrcB_OUT [6:5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]};

	MUX_2 MUX_JUMP (
		.IN_0	(PC_4_OUT),
		.IN_1 	(MUX_JUMP_IN),
		.sel 	(CTRLS_EX_OUT[15]), // Jump 
		.OUT 	(MUX_JUMP_OUT)
	);
	// BrFLUSH MUX 
	// MUX_JUMP_OUT output from MUX_JUMP (see above)
	// Br_Addr_M_OUT output from Br_Addr_M in EX/MEM (see below)
	// BrFlush_OUT generated after ALU result (see below) 
	// PC_IN input of PC_REG (see above)
	MUX_2 MUX_BR_FLUSH (
		.IN_0	(MUX_JUMP_OUT),
		.IN_1 	(Br_Addr_M_OUT),
		.sel 	(BrFlush_OUT),
		.OUT 	(PC_IN)
	);
	// IM
	assign I_MEM_ADDR = PC_OUT; 

	// Flushing IM vs NOP MUX 
	// I_MEM_DI from I_MEM
	 
	// Jump_OUT from Control unit (see above), BrFlush_OUT generated after ALU result (see below)
	
	MUX_2 IM_NOP (
		.IN_0 	(I_MEM_DI), 
		.IN_1 	(NOP),
		.sel 	(CTRLS_EX_OUT[15] || BrFlush_OUT), 
		.OUT 	(IR_D_IN)
	); 

	// IF/ID 
	// IF_ID_Write_OUT from Hazard unit (see above)
	// PC_OUT from PC_REG
	
	REG PC_D (
		.CLK 	(CLK),
		.write	(IF_ID_Write_OUT), 
		.IN 	(PC_OUT),
		.OUT 	(PC_D_OUT)
	);
	// PC_4_OUT from PC_4_INC (see above)
	 
	REG PC_4_D (
		.CLK 	(CLK),
		.write	(IF_ID_Write_OUT), 
		.IN 	(PC_4_OUT),
		.OUT 	(PC_4_D_OUT)
	);
	// IR_D_IN is output from IM-NOP MUX (see above)
	 
	REG IR_D (
		.CLK 	(CLK),
		.write	(IF_ID_Write_OUT), 
		.IN 	(IR_D_IN),
		.OUT 	(IR_D_OUT)	
	); 

	// ID STAGE
	// RF 
	// RD_WB_OUT output from RD_WB in MEM/WB (see below)
	// WB_OUT output from MUX_ALU_TO_REG (see below)
	assign RF_RA1 = IR_D_OUT[19:15];  // RS1 
	assign RF_RA2 = IR_D_OUT[24:20];  // RS2
	assign RF_WA1 = RD_WB_OUT; 
	// CTRLS_WB_OUT = {RD_used_OUT [7], InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], BrFlush_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	assign RF_WE = CTRLS_WB_OUT[5]; // RegWrite_OUT
	assign RF_WD = WB_OUT; // 
	// output wire HALT,                   // if set, terminate program
	// output reg [31:0] NUM_INST,         // number of instruction completed
	// output wire [31:0] OUTPUT_PORT 

	// FRD_PRE_A
	wire [31:0] MUX_FRD_PRE_A_OUT;
	MUX_2 MUX_FRD_PRE_A (
		.IN_0	(RF_RD1),
		.IN_1	(WB_OUT),
		.sel	(FRD_PRE_A_OUT),
		.OUT	(MUX_FRD_PRE_A_OUT)
	);
	// FRD_PRE_B
	wire [31:0] MUX_FRD_PRE_B_OUT;
	MUX_2 MUX_FRD_PRE_B (
		.IN_0	(RF_RD2),
		.IN_1	(WB_OUT),
		.sel	(FRD_PRE_B_OUT),
		.OUT	(MUX_FRD_PRE_B_OUT)
	);

	// Control Unit 
	assign OPCODE_IN = IR_D_OUT[6:0]; 

	// EX BUBBLE MUX 
	// always @(ID_EX_CtrlSrc_OUT) begin 
	// 	if (~ID_EX_CtrlSrc_OUT) begin 
	// 		CTRLS_OUT = 0; 
	// 	end 
	// end 
	
	// JUMP or BRANCH FLUSH 
	// BrFlush_OUT generated after ALU computation (see below)
	// always @ (Jump_OUT, BrFlush_OUT) begin 
	// 	if (Jump_OUT || BrFlush_OUT) begin 
	// 		// assign InstComp_OUT = 1'b0; 
	// 		// assign Jump_OUT = 1'b0; 
	// 		// assign RegWrite_OUT = 1'b0;
	// 		// assign ALUCtrl_OUT = 7'b0;
	// 		// assign SrcB_OUT = 2'b0;
	// 		// assign Branch_OUT = 1'b0;
	// 		// assign MemWrite_OUT = 1'b0;
	// 		// assign MemRead_OUT = 1'b0;
	// 		// assign MemToReg_OUT = 1'b0; 
	// 		// assign ALUToReg_OUT = 1'b0;
	// 		CTRLS_OUT = 0; 
	// 	end 
	// end 

	// ID/EX 
	// func7 and func3 
	// func7 = IR_D_OUT[31-25], func7 = IR_D_OUT[14-12]
	 
	REG FUNC7_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	({25'b0, IR_D_OUT[31:25]}),
		.OUT 	(func7_IN)	
	);
	 
	REG FUNC3_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	({29'b0, IR_D_OUT[14:12]}),
		.OUT 	(func3_IN)	
	); 
	// CTRL_EX Register that stores all control signals 
	
	// concanetation: leftmost wire of length n takes [20:20-n+1] indices. Follow order defined above
	assign CTRLS_OUT = {ID_EX_RS2_used_OUT, ID_EX_RS1_used_OUT, SrcA_OUT, NullLSB_OUT, InstComp_OUT, Jump_OUT, RegWrite_OUT, ALUCtrl_OUT, SrcB_OUT, Branch_OUT, MemWrite_OUT, MemRead_OUT, MemToReg_OUT, ALUToReg_OUT};
					// {1,                 1, 					1,				1,           1,             1, 		 1,         1, 			7, 			2, 			1, 			1, 				..., 					1		}
	// CTRLS_EX_OUT = {ID_EX_RS2_used_OUT [20], ID_EX_RS1_used_OUT [19], SrcA_OUT [18], NullLSB_OUT [17], InstComp_OUT [16], Jump_OUT [15], RegWrite_OUT [14], ALUCtrl_OUT [13:7], SrcB_OUT [6:5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]};

	REG CTRLS_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	({11'b0, {(~ID_EX_CtrlSrc_OUT) ? 21'b0 : ((CTRLS_EX_OUT[15] || BrFlush_OUT) ? 21'b0 : CTRLS_OUT)}}),
		.OUT 	(CTRLS_EX_OUT)
	);

	// PC_D_OUT is from reg PC_D (see above); 
	 
	REG PC_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	(PC_D_OUT),
		.OUT 	(PC_EX_OUT)
	);
	// PC_4_D_OUT is from reg PC_4_D (see above); 
	 
	REG PC_4_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	(PC_4_D_OUT),
		.OUT 	(PC_4_EX_OUT)
	);
	// RF_RD1 from RegFile Signals (see above)
	
	REG A_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	(MUX_FRD_PRE_A_OUT),
		.OUT 	(RF_RD1_EX_OUT)
	);
	// RF_RD2 from RegFile Signals (see above)
	 
	REG B_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	(MUX_FRD_PRE_B_OUT),
		.OUT 	(RF_RD2_EX_OUT)
	);
	// IR_D_OUT from IF/ID 
	 
	REG SW_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	({ {20 {IR_D_OUT[31]}}, {IR_D_OUT[31:25]}, {IR_D_OUT[11:7]} }),
		.OUT 	(SW_EX_OUT)
	);
	// IR_D_OUT from IF/ID
	 
	REG BrImm_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	({ {20{IR_D_OUT[31]}} ,{IR_D_OUT[31]}, {IR_D_OUT[7]}, {IR_D_OUT[30:25]}, {IR_D_OUT[11:8]} } << 1),
		.OUT 	(Br_Imm_EX_OUT)
	);
	// IR_D_OUT from IF/ID
	
	REG Imm_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	({ {20{IR_D_OUT[31]}}, {IR_D_OUT[31:20]}}),
		.OUT 	(Imm_EX_OUT)
	);

	// IR_D_OUT from IF/ID
	
	REG JAL_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	({ {12{IR_D_OUT[31]}}, {IR_D_OUT[31]}, {IR_D_OUT[19:12]}, {IR_D_OUT[20]}, {IR_D_OUT[30:21]} } << 1),
		.OUT 	(JAL_EX_OUT)
	);
	// IR_D_OUT from IF/ID
	
	REG RD_EX (
		.CLK 	(CLK),
		.write	(1'b1), 
		.IN 	({27'b0, IR_D_OUT[11:7]}),
		.OUT 	(RD_EX_OUT)
	);

	REG RS1_EX (
		.CLK	(CLK),
		.write	(1'b1),
		.IN 	({27'b0, IR_D_OUT[19:15]}),
		.OUT	(RS1_EX_OUT)
	);
	REG RS2_EX (
		.CLK	(CLK),
		.write	(1'b1),
		.IN 	({27'b0, IR_D_OUT[24:20]}),
		.OUT	(RS2_EX_OUT)
	);

	// EX STAGE 

	// Branch Address 
	// Br_Imm_EX_OUT from Br_Imm_EX register (see above)
	// PC_EX_OUT from PC_EX register (see above)
	
	Br_Addr_ADD Br_Addr_ADDER (
		.BrImm			(Br_Imm_EX_OUT),
		.PC_current 	(PC_EX_OUT),
		.BrAddr 		(Br_Addr_M_IN)
	);
	// MUX SrcB 
	// RF_RD2_EX_OUT from B_EX reg in ID/EX (see above)
	// SW_EX_OUT from SW_EX in ID/EX 
	// JAL_EX_OUT from JAL_EX in ID/EX
	// Imm_EX_OUT from Imm_EX in ID/EX
	// sel = SrcB_OUT = CTRLS_EX_OUT[6:5]
	
	// RF_RD1_EX_OUT from A_EX reg in ID/EX (see above)
	// CTRLS_EX_OUT = {ID_EX_RS2_used_OUT [20], ID_EX_RS1_used_OUT [19], SrcA_OUT [18], NullLSB_OUT [17], InstComp_OUT [16], Jump_OUT [15], RegWrite_OUT [14], ALUCtrl_OUT [13:7], SrcB_OUT [6:5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]};
	// MUX_3 MUX_FRD_A (
	// 	.IN_0 	(MUX_A_OUT),
	// 	.IN_1 	(AOut_M_OUT),
	// 	.IN_2 	(WB_OUT),
	// 	.sel 	(FRD_A_OUT),
	// 	.OUT 	(ALU_FRD_A_OUT)
	// );
	MUX_3 MUX_FRD_A (
		.IN_0 	(RF_RD1_EX_OUT),
		.IN_1 	(AOut_M_OUT),
		.IN_2 	(WB_OUT),
		.sel 	(FRD_A_OUT),
		.OUT 	(ALU_FRD_A_OUT)
	);
	MUX_2 MUX_A (
		.IN_0	(PC_EX_OUT),
		.IN_1 	(ALU_FRD_A_OUT),
		.sel 	(CTRLS_EX_OUT[18]), // SrcA_OUT
		.OUT	(MUX_A_OUT)
	);
	// MUX_3 MUX_FRD_B (
	// 	.IN_0 	(MUX_B_OUT),
	// 	.IN_1 	(AOut_M_OUT),
	// 	.IN_2 	(WB_OUT),
	// 	.sel 	(FRD_B_OUT),
	// 	.OUT 	(ALU_FRD_B_OUT)
	// );
	MUX_3 MUX_FRD_B (
		.IN_0 	(RF_RD2_EX_OUT),
		.IN_1 	(AOut_M_OUT),
		.IN_2 	(WB_OUT),
		.sel 	(FRD_B_OUT),
		.OUT 	(ALU_FRD_B_OUT)
	);
	MUX_4 MUX_B (
		.IN_0	(ALU_FRD_B_OUT),
		.IN_1 	(SW_EX_OUT),
		.IN_2	(JAL_EX_OUT),
		.IN_3 	(Imm_EX_OUT),
		.sel	(CTRLS_EX_OUT[6:5]), // SrcB_OUT 
		.OUT 	(MUX_B_OUT)
	);
	// MUX_A_OUT from MUX_A (see above)
	// AOut_M_OUT from AOut_M from EX/MEM (see below)
	// WB_OUT - write back data signal send back to RF (see below)
	// FRD_A_OUT is output from Forwarding Unit (see above)
	
	// MUX_B_OUT from MUX_B (see above)
	// AOut_M_OUT from AOut_M from EX/MEM (see below)
	// WB_OUT - write back data signal send back to RF (see below)
	// FRD_B_OUT is output from Forwarding Unit (see above)
	
	
	// ALUop_IN - input of ALU CTRL UNIT (see above)
	// ALUCtrl_OUT = CTRLS_EX_OUT[13:7] from ID/EX (see above)
	// CTRLS_EX_OUT = {ID_EX_RS2_used_OUT [20], ID_EX_RS1_used_OUT [19], SrcA_OUT [18], NullLSB_OUT [17], InstComp_OUT [16], Jump_OUT [15], RegWrite_OUT [14], ALUCtrl_OUT [13:7], SrcB_OUT [6:5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]};
	assign ALUop_IN = CTRLS_EX_OUT[13:7]; // ALUCtrl_OUT 
	// ALU_FRD_A_OUT from MUX_FRD_A (see above)
	// ALU_FRD_B_OUT from MUX_FRD_B (see above)
	// AlUop_OUT - output from ALU CTRL UNIT (see above)
	
	ALU ALU_MAIN (
		.A 		(MUX_A_OUT),
		.B 		(MUX_B_OUT),
		.OP 	(AlUop_OUT), 
		.C 		(AOut_M_IN),
		.BrTkn	(BrTkn_M_IN)
	);

	// JUMP: JALR VS JAL (NullLSB_OUT ? JALR : JAL)
	assign MUX_JUMP_IN = CTRLS_EX_OUT[17] ? (AOut_M_IN & 'hfffffffe) : AOut_M_IN; 

	// EX/MEM
	
	// CTRLS_EX_OUT (output from CTRL_EX register from ID/EX - see above) = 
	// CTRLS_EX_OUT = {ID_EX_RS2_used_OUT [20], ID_EX_RS1_used_OUT [19], SrcA_OUT [18], NullLSB_OUT [17], 
	// InstComp_OUT [16], Jump_OUT [15], RegWrite_OUT [14], ALUCtrl_OUT [13:7], SrcB_OUT [6:5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]};
	assign CTRLS_M_IN = {CTRLS_EX_OUT[16], CTRLS_EX_OUT[14], CTRLS_EX_OUT[4], CTRLS_EX_OUT[3], CTRLS_EX_OUT[2], CTRLS_EX_OUT[1], CTRLS_EX_OUT[0]};
	// CTRLS_M_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	REG CTRLS_M (
		.CLK 	(CLK),
		.write 	(1'b1),
		.IN		({25'b0, BrFlush_OUT ? 7'b0 : CTRLS_M_IN}),
		.OUT	(CTRLS_M_OUT)
	); 
	// PC_4_EX_OUT output from PC_4_EX reg in ID/EX (see above)
	
	REG PC_4_M (
		.CLK 	(CLK),
		.write 	(1'b1),
		.IN		(PC_4_EX_OUT),
		.OUT	(PC_4_M_OUT)
	);
	// Br_Addr_M_IN output from Br_Addr_ADDER in EX stage (see above)
	 
	REG Br_Addr_M (
		.CLK 	(CLK),
		.write 	(1'b1),
		.IN		(Br_Addr_M_IN),
		.OUT	(Br_Addr_M_OUT)
	);
	// AOut_M_IN output from ALU MAIN UNIT in EX stage (see above)
	 
	REG AOut_M (
		.CLK 	(CLK),
		.write 	(1'b1),
		.IN		(AOut_M_IN),
		.OUT	(AOut_M_OUT)
	);
	// BrTkn_M_IN output from ALU MAIN UNIT in EX stage (see above)
	
	REG BrTkn_M (
		.CLK 	(CLK),
		.write 	(1'b1),
		.IN		({31'b0, BrTkn_M_IN}),
		.OUT	(BrTkn_M_OUT)
	);
	// RF_RD2_EX_OUT from B_EX reg in ID/EX (see above)
	
	REG B_M (
		.CLK 	(CLK),
		.write 	(1'b1),
		// .IN		(RF_RD2_EX_OUT),
		.IN		(ALU_FRD_B_OUT),
		.OUT	(B_M_OUT)
	);
	// RD_EX_OUT output from RD_EX register in ID/EX (see above)
	 
	REG RD_M (
		.CLK 	(CLK),
		.write 	(1'b1),
		.IN		(RD_EX_OUT),
		.OUT	(RD_M_OUT)
	);

	// MEM STAGE 
	// [6:0] CTRLS_M_OUT output from CTRLS_M reg in EX/MEM (see above)
	// CTRLS_M_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	 
	assign BrFlush_OUT = BrTkn_M_OUT[0] && CTRLS_M_OUT[4];  // BrTkn & Branch_OUT
	// DM 
	assign D_MEM_ADDR = AOut_M_OUT; 
	assign D_MEM_DOUT = B_M_OUT; 
	assign D_MEM_WEN = ~CTRLS_M_OUT[3]; // negation of MemWrite_OUT 
	assign D_MEM_BE = 4'b1111; // as far as I understand, how many bytes enabled for write. Since we write all 32 bits back, 4'b1111 

	// MEM/WB
	// [6:0] CTRLS_M_OUT output from CTRLS_M reg in EX/MEM (see above)
	// CTRLS_M_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], MemRead_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}	
	assign CTRLS_WB_IN = {CTRLS_M_OUT[6], CTRLS_M_OUT[5], CTRLS_M_OUT[4], CTRLS_M_OUT[3], BrFlush_OUT, CTRLS_M_OUT[1], CTRLS_M_OUT[0]};
	// CTRLS_WB_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], BrFlush_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	REG CTRLS_WB (
		.CLK	(CLK),
		.write 	(1'b1),
		.IN		({25'b0, CTRLS_WB_IN}),
		.OUT 	(CTRLS_WB_OUT)
	);
	// PC_4_M_OUT output from PC_4_M reg in EX/MEM (see above)
	 
	REG PC_4_WB (
		.CLK	(CLK),
		.write 	(1'b1),
		.IN		(PC_4_M_OUT),
		.OUT 	(PC_4_WB_OUT)
	);
	// D_MEM_DI is data coming from DM (see above)
	 
	REG MDR_WB (
		.CLK 	(CLK),
		.write 	(1'b1), 
		.IN 	(D_MEM_DI), 
		.OUT 	(MDR_WB_OUT)
	); 
	// AOut_M_OUT is output from AOut_M from EX/MEM (see above)
	 
	REG AOut_WB (
		.CLK 	(CLK),
		.write 	(1'b1), 
		.IN 	(AOut_M_OUT), 
		.OUT 	(AOut_WB_OUT)
	);
	// RD_M_OUT is output from RD_M from EX/MEM (see above)
	
	REG RD_WB (
		.CLK	(CLK),
		.write	(1'b1),
		.IN		(RD_M_OUT),
		.OUT	(RD_WB_OUT)
	);
	// MemToReg MUX 
	// PC_4_WB_OUT from PC_4_WB in MEM/WB (see above)
	// MDR_WB_OUT from MDR_WB in MEM/WB (see above)
	// CTRLS_WB_OUT output from CTRLS_WB reg in MEM/WB (see above)
	// CTRLS_WB_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], BrFlush_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	MUX_2 MUX_MEM_TO_REG (
		.IN_0	(PC_4_WB_OUT),
		.IN_1 	(MDR_WB_OUT),
		.sel	(CTRLS_WB_OUT[1]), // MemToReg_OUT
		.OUT	(MEM_TO_REG_OUT)
	);
	// AluToReg MUX 
	// AOut_WB_OUT from AOut_WB in MEM/WB (see above)
	// MEM_TO_REG_OUT from MUX_MEM_TO_REG (see above)
	// CTRLS_WB_OUT output from CTRLS_WB reg in MEM/WB (see above)
	// CTRLS_WB_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], BrFlush_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}	
	MUX_2 MUX_ALU_TO_REG (
		.IN_0	(MEM_TO_REG_OUT),
		.IN_1 	(AOut_WB_OUT),
		.sel	(CTRLS_WB_OUT[0]), // ALUToReg_OUT
		.OUT	(WB_OUT)
	);

	// -------- END   MODULES OF CPU -------- //

	// UPDATE num_inst at completion of each instruction 
	// CTRLS_WB_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], BrFlush_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	always @ (posedge CLK) begin 
		if (RSTn && CTRLS_WB_OUT[6]) NUM_INST <= NUM_INST + 1; //InstComp_OUT ???
	end 


	// AFTER START SIMULATION NEGEDGE TRIGGERS FIRST
	always @ (posedge CLK) begin 
		if (RSTn) begin
		// $display("NUM_INST BLYA %d", NUM_INST);
		// $display("OPCODE is : %b", OPCODE_IN);

		// $display("PC_IN is %d", PC_IN);
		// $display("PC_OUT is %d", PC_OUT); 
		// $display("I_MEM_ADDR is %d", I_MEM_ADDR); 
		// $display("I_MEM_DI is %b", I_MEM_DI); 

		// $display("IR_D_OUT is %b", IR_D_OUT);

		// $display("CTRLS_EX_OUT Sig is %b", CTRLS_EX_OUT); 
		// $display("CTRLS_M_OUT Sig is %b", CTRLS_M_OUT); 
		// $display("CTRLS_WB_OUT Sig is %b", CTRLS_WB_OUT); 
		// $display("RegWrite is %d", CTRLS_WB_OUT[5]); //RegWrite_OUT

		// $display("Jump_OUT sig is %b ", Jump_OUT);
		// $display("BrFlush_OUT sig is %b", BrFlush_OUT);

		// $display("RS1 used is %b", CTRLS_EX_OUT[19]);
		// $display("RS2 used is %b", CTRLS_EX_OUT[20]); 
		// $display("--------------------------------------EX STAGE:------------------------------------");
		// $display("rs1 is %d", RS1_EX_OUT); 
		// $display("rs2 is %d", RS2_EX_OUT); 
		// $display("A_EX read from RF[rs1] is %d", RF_RD1_EX_OUT);
		// $display("B_EX read from RF[rs2] is %d", RF_RD2_EX_OUT);

		// $display("MUX_A sel signal is %b", CTRLS_EX_OUT[18]); 
		// $display("MUX FRD_B sel signal is %b", FRD_B_OUT);
		// $display("MUX_A result is %d", MUX_A_OUT); 
		// $display("MUX_FRD_B result is %d", ALU_FRD_B_OUT); 

		// $display("MUX_FRD_A sel signal is %b", FRD_A_OUT); 
		// $display("MUX_B sel signal is %b", CTRLS_EX_OUT[6:5]);
		// $display("MUX_FRD_A result (ALU input 1) is %d", ALU_FRD_A_OUT);
		// $display("MUX_B result (ALU input 2) is %d", MUX_B_OUT);
		// $display("MUX JUMP OUT is %b", MUX_JUMP_OUT);
		// $display("MUX JUMP IN is %b", MUX_JUMP_IN);
		// $display("MUX JUMP OUT is %b", BrTkn_M_OUT);
		// $display("-------------------------------------MEM STAGE: ------------------------------------");
		// $display("B_M_OUT is %d", B_M_OUT);
		// $display("input: DMEM ADDR is %d", D_MEM_ADDR);
		// $display("input: DMEM STORE DATA is %d", D_MEM_DOUT); 
		// $display("input: DMEM WEN is %d", D_MEM_WEN); 
		// $display("output: DMEM LOAD DATA is %d", D_MEM_DI);
		// $display("--------------------------------------WB STAGE: --------------------------------");
		// $display("MemToReg signal is %b", CTRLS_WB_OUT[1]);
		// $display("AluToReg signal is %b", CTRLS_WB_OUT[0]); 
		// $display("MDR_WB_OUT is %d", MDR_WB_OUT); 
		// $display("PC_4_WB_OUT is %d", PC_4_WB_OUT);
		// $display("AOut_WB_OUT is %d", AOut_WB_OUT);
		// $display("final WB_OUT is %d", WB_OUT);
		// $display("Write Destination ADDR (RD) is %d", RD_WB_OUT);
		// $display("RegWrite is %b", CTRLS_WB_OUT[5]); 
		// $display("OUTPUT_PORT_REG is %h", OUTPUT_PORT_REG);
		// $display("==============================================================================");
		end
	end

	// always @ (OUTPUT_PORT) begin 
	// 	$display("OUTPUT REG CHANGED TO %h", OUTPUT_PORT); 
	// end 

	// RSTn handling 
	reg [31:0] I_MEM_CSN_REG; 
	reg [31:0] D_MEM_CSN_REG;
	assign I_MEM_CSN = I_MEM_CSN_REG; 
	assign D_MEM_CSN = D_MEM_CSN_REG; 

	always @ (RSTn) begin 
		//$display("RSTn %d", RSTn);
		if (RSTn) begin 
			I_MEM_CSN_REG = 0; 
			D_MEM_CSN_REG = 0; 
		end else begin 
			I_MEM_CSN_REG = 1; 
			D_MEM_CSN_REG = 1; 
		end 
	end 

	// HALT LOGIC 
	reg [31:0] LAST_INSTR; 
	reg HALT_REG; 
	assign HALT = HALT_REG; 

	always	@(IR_D_OUT) begin 
		if (LAST_INSTR == 'h00c00093 && IR_D_OUT == 'h00008067) 
			HALT_REG = 1; 
		else 
			HALT_REG = 0; 
		LAST_INSTR = IR_D_OUT; 
	end 

	// OUTPUT PORT LOGIC 
	// CTRLS_WB_OUT output from CTRLS_WB reg in MEM/WB (see above)
	// CTRLS_WB_OUT = {InstComp_OUT [6], RegWrite_OUT [5], Branch_OUT [4], MemWrite_OUT [3], BrFlush_OUT [2], MemToReg_OUT [1], ALUToReg_OUT [0]}
	reg [31:0] OUTPUT_PORT_REG; 
	assign OUTPUT_PORT = OUTPUT_PORT_REG; 

	always @(posedge CLK) begin 
		if (CTRLS_WB_OUT[4]) begin // Branch_OUT - detect B type
			if (CTRLS_WB_OUT[2]) // BrFlush_OUT - taken  
				OUTPUT_PORT_REG <= 1;  
			else 
				OUTPUT_PORT_REG <= 0; 
		end else if (CTRLS_WB_OUT[3]) begin  // MemWrite_OUT - check Store (SW) instruction
			OUTPUT_PORT_REG <= AOut_WB_OUT; // target address 
		end else if (CTRLS_WB_OUT[5]) begin // Regwire => RD used 
			OUTPUT_PORT_REG <= WB_OUT; // WB data 
		end 
	end 



	//assign I_MEM_ADDR = 0;     // WILL NOT UPDATE INSTRUCTIONS
	// INITIAL BEGIN ... END (num_inst = 0, wires that come from control unit set to 0, )
	initial begin
		NUM_INST <= 0;
		// default: first PC address at 0 
		//PC_REG.VAL <= 0; 
		// assign I_MEM_ADDR <= 0;  
		//CTRLS_EX.VAL <= 0; 
		//CTRLS_M.VAL <= 0; 
		//CTRLS_EX.VAL <= 0; 
		// 
		OUTPUT_PORT_REG <= 0; 
		//IR_D.VAL <= 0;  
		// RD_M.VAL <= 0; 

		// default: HAZARD UNIT not blocking 
		// PCWrite_OUT <= 1; 
		// IF_ID_Write_OUT <= 1; 
		// ID_EX_CtrlSrc_OUT <= 1; 
		// 
		// FRD_A_OUT <= 0; 
		// FRD_B_OUT <= 0; 
	end

endmodule //

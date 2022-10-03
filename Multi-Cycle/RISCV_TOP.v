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
	output wire HALT,
	output reg [31:0] NUM_INST,
	output wire [31:0] OUTPUT_PORT
	);

	// TODO: implement multi-cycle CPU

	// initialization of CTRL_UNIT
	wire [6:0] OPCODE_IN;
	wire PCWrite_OUT;
	wire Branch_OUT;
	wire IMRead_OUT;
	wire IRWrite_OUT;
	wire RegWrite_OUT;
	wire ALUSrcA_OUT;
	wire [2:0] ALUSrcB_OUT;
	wire [6:0] ALUOp_OUT;
	wire NullLSB_OUT;
	wire MemRead_OUT;
	wire MemWrite_OUT;
	wire MemToReg_OUT;
	wire InstSig_OUT;
	wire ALUOutWrite_OUT;
	wire SaveSig_OUT;
	CONTROL CTRL_UNIT(
		.CLK(CLK),
		.OPCODE(OPCODE_IN),
		.RSTn(RSTn),

		.PCWrite(PCWrite_OUT),
		.Branch(Branch_OUT),
		.IMRead(IMRead_OUT),
		.IRWrite(IRWrite_OUT),
		.RegWrite(RegWrite_OUT),
		.ALUSrcA(ALUSrcA_OUT),
		.ALUSrcB(ALUSrcB_OUT),
		.ALUOp(ALUOp_OUT),
		.NullLSB(NullLSB_OUT),
		.MemRead(MemRead_OUT),
		.MemWrite(MemWrite_OUT),
		.MemToReg(MemToReg_OUT),
		.InstSig(InstSig_OUT),
		.ALUOutWrite(ALUOutWrite_OUT),
		.SaveSig(SaveSig_OUT)
	);

	// initialization of ALU_CTRL
	wire [6:0] func7_IN;
    wire [2:0] func3_IN;
    wire [6:0] ALUop_IN;
	wire [3:0] ALUControlSignal_OUT;
	ALUCONTROL ALU_CTRL(
		.func3(func3_IN),
		.func7(func7_IN),
		.ALUop(ALUop_IN),
		.ALUControlSignal(ALUControlSignal_OUT)
	);

	// initialization of ALU
	wire [31:0] ALU_A;
	wire [31:0] ALU_B;
	wire [31:0] ALU_C;
	wire [3:0] ALU_OP;
	wire BrTkn;
	ALU ALU1(
		.A(ALU_A),
		.B(ALU_B),
		.OP(ALU_OP),
		.C(ALU_C),
		.BrTkn(BrTkn)
	);

	// initialization of intermediate registers
	wire PCWrite_IN;
	wire [31:0] PC_IN;
	wire [31:0] PC_OUT;
	REG PC_REG(
		.CLK(CLK),
		.write(PCWrite_IN),
		.IN(PC_IN),
		.OUT(PC_OUT)
	);

	wire IRWrite_IN;
	wire [31:0] IR_IN;
	wire [31:0] IR_OUT;
	REG IR(
		.CLK(CLK),
		.write(IRWrite_IN),
		.IN(IR_IN),
		.OUT(IR_OUT)
	);

	wire [31:0] A_IN;
	wire [31:0] A_OUT;
	REG A(
		.CLK(CLK),
		.write(1'b1),
		.IN(A_IN),
		.OUT(A_OUT)
	);
	
	wire [31:0] B_IN;
	wire [31:0] B_OUT;
	REG B(
		.CLK(CLK),
		.write(1'b1),
		.IN(B_IN),
		.OUT(B_OUT)
	);

	wire [31:0] ALUOut_IN;
	wire [31:0] ALUOut_OUT;
	wire ALUOutWrite_IN;
	REG ALUOut(
		.CLK(CLK),
		.write(ALUOutWrite_IN),
		.IN(ALUOut_IN),
		.OUT(ALUOut_OUT)
	);	

	wire [31:0] MDR_IN;
	wire [31:0] MDR_OUT;
	REG MDR(
		.CLK(CLK),
		.write(1'b1),
		.IN(MDR_IN),
		.OUT(MDR_OUT)
	);

	// initialization of MUXes
	wire [31:0] MUX_A_0;
	wire [31:0] MUX_A_1;
	wire MUX_A_sel;
	wire [31:0] MUX_A_OUT;
	MUX_2 MUX_A(
		.IN_0(MUX_A_0),
		.IN_1(MUX_A_1),
		.sel(MUX_A_sel),
		.OUT(MUX_A_OUT)
	);

	wire [31:0] MUX_B_000;
	wire [31:0] MUX_B_001;
	wire [31:0] MUX_B_010;
	wire [31:0] MUX_B_011;
	wire [31:0] MUX_B_100;
	wire [31:0] MUX_B_101;
	wire [2:0] MUX_B_sel;
	wire [31:0] MUX_B_OUT;
	MUX_6 MUX_B(
		.IN_000(MUX_B_000),
		.IN_001(MUX_B_001),
		.IN_010(MUX_B_010),
		.IN_011(MUX_B_011),
		.IN_100(MUX_B_100),
		.IN_101(MUX_B_101),
		.sel(MUX_B_sel),
		.OUT(MUX_B_OUT)
	);

	wire [31:0] MEM_TO_REG_0;
	wire [31:0] MEM_TO_REG_1;
	wire MEM_TO_REG_sel;
	wire [31:0] MEM_TO_REG_OUT;
	MUX_2 MEM_TO_REG(
		.IN_0(MEM_TO_REG_0),
		.IN_1(MEM_TO_REG_1),
		.sel(MEM_TO_REG_sel),
		.OUT(MEM_TO_REG_OUT)
	);

	// wire assignment
	// inputs of CTRL
	assign OPCODE_IN = IR_OUT[6:0];

	// inputs of ALU_CTRL
	assign func3_IN = IR_OUT[14:12];
	assign func7_IN = IR_OUT[31:25];
	assign ALUop_IN = ALUOp_OUT;

	// inputs of PC
	assign PC_IN = ALUOut_OUT;
	assign PCWrite_IN = (PCWrite_OUT | (BrTkn & Branch_OUT));

	// inputs of IM
	assign I_MEM_ADDR = PC_OUT;

	// inputs of IR
	assign IR_IN = I_MEM_DI;
	assign IRWrite_IN = IRWrite_OUT;

	// inputs of RF
	assign RF_RA1 = IR_OUT[19:15];
	assign RF_RA2= IR_OUT[24:20];
	assign RF_WA1 = IR_OUT[11:7];
	assign RF_WE = RegWrite_OUT;
	assign RF_WD = MEM_TO_REG_OUT;

	// inputs of A
	assign A_IN = RF_RD1;

	// inputs of B
	assign B_IN = RF_RD2;

	//inputs of MUX_A
	assign MUX_A_0 = PC_OUT;
	assign MUX_A_1 = A_OUT;
	assign MUX_A_sel = ALUSrcA_OUT;

	// inputs of MUX_B
	assign MUX_B_000 = B_OUT;
	assign MUX_B_001 = 4;
	assign MUX_B_010 = { {20 {IR_OUT[31]}}, {IR_OUT[31:25]}, {IR_OUT[11:7]} };
	assign MUX_B_011 = { {20{IR_OUT[31]}} ,{IR_OUT[31]}, {IR_OUT[7]}, {IR_OUT[30:25]}, {IR_OUT[11:8]} } << 1;
	assign MUX_B_100 =  { {20{IR_OUT[31]}}, {IR_OUT[31:20]}}	;
	assign MUX_B_101 = { {12{IR_OUT[31]}}, {IR_OUT[31]}, {IR_OUT[19:12]}, {IR_OUT[20]}, {IR_OUT[30:21]} } << 1;

	assign MUX_B_sel = ALUSrcB_OUT;

	// inputs of ALU
	assign ALU_A = MUX_A_OUT;
	assign ALU_B = MUX_B_OUT;
	assign ALU_OP = ALUControlSignal_OUT;

	// inputs of ALUOut
	assign ALUOutWrite_IN = ALUOutWrite_OUT;
	assign ALUOut_IN = NullLSB_OUT ? (ALU_C & 'hfffffffe) : ALU_C;

	// inputs of DM
	assign D_MEM_BE = 4'b1111;
	assign D_MEM_WEN = ~MemWrite_OUT;
	assign D_MEM_ADDR = ALUOut_OUT;
	assign D_MEM_DOUT = B_OUT;

	// inputs of MDR
	assign MDR_IN = D_MEM_DI;

	// inputs of MEM_TO_REG MUX
	assign MEM_TO_REG_0 = ALUOut_OUT;
	assign MEM_TO_REG_1 = MDR_OUT;
	assign MEM_TO_REG_sel = MemToReg_OUT;

	initial begin
		NUM_INST <= 0;
	end

	always @ (negedge CLK) begin
		if (RSTn && InstSig_OUT) NUM_INST <= NUM_INST + 1;
	end

	assign I_MEM_ADDR = 0; 	

	reg [31:0] I_MEM_CSN_REG;
	reg [31:0] D_MEM_CSN_REG;
	assign I_MEM_CSN = I_MEM_CSN_REG;
	assign D_MEM_CSN = D_MEM_CSN_REG;

	always @ (RSTn) begin
		if (RSTn) begin
			I_MEM_CSN_REG = 0;
			D_MEM_CSN_REG = 0;
			// RF_WD_REG = 32'hF00; DON't know if we need it
		end else begin
			I_MEM_CSN_REG = 1;
			D_MEM_CSN_REG = 1;
		end
	end

	// halt logic
	reg [31:0] LAST_INSTR;
	reg HALT_REG;
	assign HALT = HALT_REG;

	always @ (IR_OUT) begin
		if (LAST_INSTR == 'h00c00093 && IR_OUT == 'h00008067)
			HALT_REG = 1;
		else
			HALT_REG = 0;
		LAST_INSTR = IR_OUT;

	end



	// output port logic
	reg [31:0] OUTPUT_PORT_REG;
	assign OUTPUT_PORT = OUTPUT_PORT_REG;

	initial begin
		OUTPUT_PORT_REG <= 0;
	end

	
	reg [31:0] dummy;

	always @ (posedge SaveSig_OUT) begin
		if (RegWrite_OUT) begin
			if (InstSig_OUT & SaveSig_OUT) begin
				assign OUTPUT_PORT_REG = MEM_TO_REG_OUT;
			end
			else if (SaveSig_OUT) begin
				dummy = MEM_TO_REG_OUT;
				assign OUTPUT_PORT_REG = dummy;
			end
		end 

		if (Branch_OUT) begin
			assign OUTPUT_PORT_REG = BrTkn;
		end

		if (MemWrite_OUT ) begin
			assign OUTPUT_PORT_REG = ALUOut_OUT;
		end
		
	end


	initial begin
		PC_REG.VAL = 0;
	end

endmodule //

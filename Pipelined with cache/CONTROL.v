/* ########## START OF CONTROL UNIT ########### */
module CONTROL (
  input [6:0]OPCODE,

  output reg SrcA,
  output reg NullLSB, 
  output reg InstComp, 
  output reg Jump,
  output reg RegWrite,
  output reg [6:0] ALUCtrl,
  output reg [1:0] SrcB,
  output reg Branch,
  output reg MemWrite,
  output reg MemRead,
  output reg MemToReg,
  output reg ALUToReg,
  output reg ID_EX_RS1_used,
  output reg ID_EX_RS2_used
);
  initial begin
  SrcA = 0; 
  NullLSB = 0;
  InstComp = 0;
  Jump = 0;
  RegWrite = 0;
  ALUCtrl = 0;
  SrcB = 0;
  Branch = 0;
  MemWrite = 0;
  MemRead = 0;
  MemToReg = 0;
  ALUToReg = 0;
  ID_EX_RS1_used = 0;
  ID_EX_RS2_used = 0;
  end
  // Jump
  // RegWrite
  // ALUCtrl
  // SrcB
  // Branch
  // MemWrite
  // MemRead
  // MemToReg
  // ALUToReg

always @ (*) begin
  case (OPCODE)
  7'b0000000: begin // NOP
    SrcA = 1'b0;
    NullLSB = 1'b0; 
    InstComp = 1'b0;
    Jump = 1'b0;
    RegWrite = 1'b0;
    ALUCtrl = 7'b0000000;
    SrcB = 2'b00;
    Branch = 1'b0;
    MemWrite = 1'b0;
    MemRead = 1'b0;
    MemToReg = 1'b0;
    ALUToReg = 1'b0;
    ID_EX_RS1_used = 1'b0;
    ID_EX_RS2_used = 1'b0;
  end
  7'b1101111: begin // JAL
    SrcA = 1'b0;
    NullLSB = 1'b0;
    InstComp = 1'b1;
    Jump = 1'b1;
    RegWrite = 1'b1;
    ALUCtrl = 7'b1101111;
    SrcB = 2'b10;
    Branch = 1'b0;
    MemWrite = 1'b0;
    MemRead = 1'b0;
    MemToReg = 1'b0;
    ALUToReg = 1'b0;
    ID_EX_RS1_used = 1'b0;
    ID_EX_RS2_used = 1'b0;
  end
  7'b1100111: begin // JALR
    SrcA = 1'b1;
    NullLSB = 1'b1; 
    InstComp = 1'b1;
    Jump = 1'b1;
    RegWrite = 1'b1;
    ALUCtrl = 7'b1100111;
    SrcB = 2'b11;
    Branch = 1'b0;
    MemWrite = 1'b0;
    MemRead = 1'b0;
    MemToReg = 1'b0;
    ALUToReg = 1'b0;
    ID_EX_RS1_used = 1'b1;
    ID_EX_RS2_used = 1'b0;
  end
  7'b1100011: begin // B-Type
    SrcA = 1'b1;
    NullLSB = 1'b0;
    InstComp = 1'b1;
    Jump = 1'b0;
    RegWrite = 1'b0;
    ALUCtrl = 7'b1100011;
    SrcB = 2'b00;
    Branch = 1'b1;
    MemWrite = 1'b0;
    MemRead = 1'b0;
    MemToReg = 1'b0;
    ALUToReg = 1'b1;
    ID_EX_RS1_used = 1'b1;
    ID_EX_RS2_used = 1'b1;
  end
  7'b0000011: begin // LW
    SrcA = 1'b1;
    NullLSB = 1'b0;
    InstComp = 1'b1;
    Jump = 1'b0;
    RegWrite = 1'b1;
    ALUCtrl = 7'b0000011;
    SrcB = 2'b11;
    Branch = 1'b0;
    MemWrite = 1'b0;
    MemRead = 1'b1;
    MemToReg = 1'b1;
    ALUToReg = 1'b0;
    ID_EX_RS1_used = 1'b1;
    ID_EX_RS2_used = 1'b0;
  end
  7'b0100011: begin // SW
    SrcA = 1'b1;
    NullLSB = 1'b0;
    InstComp = 1'b1;
    Jump = 1'b0;
    RegWrite = 1'b0;
    ALUCtrl = 7'b0100011;
    SrcB = 2'b01;
    Branch = 1'b0;
    MemWrite = 1'b1;
    MemRead = 1'b0;
    MemToReg = 1'b0;
    ALUToReg = 1'b1;
    ID_EX_RS1_used = 1'b1;
    ID_EX_RS2_used = 1'b1;
  end
  7'b0010011: begin // I-Type
    SrcA = 1'b1;
    NullLSB = 1'b0;
    InstComp = 1'b1;
    Jump = 1'b0;
    RegWrite = 1'b1;
    ALUCtrl = 7'b0010011;
    SrcB = 2'b11;
    Branch = 1'b0;
    MemWrite = 1'b0;
    MemRead = 1'b0;
    MemToReg = 1'b0;
    ALUToReg = 1'b1;
    ID_EX_RS1_used = 1'b1;
    ID_EX_RS2_used = 1'b0;
  end
  7'b0110011: begin // R-Type
    SrcA = 1'b1;
    NullLSB = 1'b0;
    InstComp = 1'b1;
    Jump = 1'b0;
    RegWrite = 1'b1;
    ALUCtrl = 7'b0110011;
    SrcB = 2'b00;
    Branch = 1'b0;
    MemWrite = 1'b0;
    MemRead = 1'b0;
    MemToReg = 1'b0;
    ALUToReg = 1'b1;
    ID_EX_RS1_used = 1'b1;
    ID_EX_RS2_used = 1'b1;
  end
  endcase
end
endmodule
/* ########## END OF CONTROL UNIT ########### */


/* ########## START OF ALU CONTROL UNIT ########### */
module ALUCONTROL (
    input wire [6:0]func7,
    input wire [2:0]func3,
    input wire [6:0]ALUop,

    output reg [3:0] ALUControlSignal
);

    always @ (*) begin

        /*
        ALU Control Signal Table
            0000 ADD
            0001 SUB
            0010  < (signed)
            0011  >= (signed)
            0100  < (unsigned)
            0101  >= (unsigned)
            0110  ^ (XOR)
            0111  & (AND)
            1000  | (OR)
            1001  << (LLShift)
            1010  >> (RLShift)
            1011  >> (RAShift)
            1100  == (eq)
            1101  != (neq)
        */

        case (ALUop)
        7'b0000000: begin ALUControlSignal = 4'b0000; end // NOP
        7'b1101111: begin ALUControlSignal = 4'b0000; end // JAL 
        7'b1100111: begin ALUControlSignal = 4'b0000; end // JALR
        7'b1100011: begin // B-Type
            case (func3)
            3'b000: begin ALUControlSignal = 4'b1100; end // BEQ
            3'b001: begin ALUControlSignal = 4'b1101; end // BNE
            3'b100: begin ALUControlSignal = 4'b0010; end // BLT
            3'b101: begin ALUControlSignal = 4'b0011; end // BGE
            3'b110: begin ALUControlSignal = 4'b0100; end // BLTU
            3'b111: begin ALUControlSignal = 4'b0101; end // BGEU
            endcase
        end
        7'b0000011: begin ALUControlSignal = 4'b0000; end // LW
        7'b0100011: begin ALUControlSignal = 4'b0000; end // SW
        7'b0010011: begin // R-Type Imm
            case (func3)
                3'b000: begin ALUControlSignal = 4'b0000; end // ADDI
                3'b010: begin ALUControlSignal = 4'b0010; end // SLTI
                3'b011: begin ALUControlSignal = 4'b0100; end // SLTIU
                3'b100: begin ALUControlSignal = 4'b0110; end // XORI
                3'b110: begin ALUControlSignal = 4'b1000; end // ORI
                3'b111: begin ALUControlSignal = 4'b0111; end // ANDI
                3'b001: begin ALUControlSignal = 4'b1001; end // SLLI
                3'b101: begin // SR(L/A)I
                    case (func7)
                        7'b0000000: begin ALUControlSignal = 4'b1010; end // SRLI
                        7'b0100000: begin ALUControlSignal = 4'b1011; end // SRAI
                    endcase
                end
            endcase
        end
        7'b0110011: begin // R-Type rs2
            case (func3)
                3'b000: begin
                    case (func7)
                        7'b0000000: begin ALUControlSignal = 4'b0000; end // ADD
                        7'b0100000: begin ALUControlSignal = 4'b0001; end // SUB
                    endcase
                end
                3'b001: begin ALUControlSignal = 4'b1001; end // SLL
                3'b010: begin ALUControlSignal = 4'b0010; end // SLT
                3'b011: begin ALUControlSignal = 4'b0100; end // SLTU
                3'b100: begin ALUControlSignal = 4'b0110; end // XOR
                3'b101: begin // SLL
                    case (func7)
                        7'b0000000: begin ALUControlSignal = 4'b1010; end // SRL
                        7'b0100000: begin ALUControlSignal = 4'b1011; end // SRA
                    endcase
                end
                3'b110: begin ALUControlSignal = 4'b1000; end // OR
                3'b111: begin ALUControlSignal = 4'b0111; end // AND
            endcase
        end
        endcase

    end

endmodule 
/* ########## END OF ALU CONTROL UNIT ########### */
module CONTROL (
  input CLK,
  input [6:0]OPCODE,
  input RSTn,

  output reg PCWrite,
  output reg Branch,
  output reg IMRead,
  output reg IRWrite,
  output reg RegWrite,
  output reg ALUSrcA,
  output reg [2:0] ALUSrcB,
  output reg [6:0] ALUOp,
  output reg NullLSB,
  output reg MemRead,
  output reg MemWrite,
  output reg MemToReg,
  output reg InstSig,
  output reg ALUOutWrite,
  output reg SaveSig
);

reg [3:0] current_state = 4'b0000;
reg [3:0] next_state;

// states 
parameter stateNeg = 4'b1111;
parameter state0 = 4'b0000;
parameter state1 = 4'b0001;
parameter state2 = 4'b0010;
parameter state3 = 4'b0011;
parameter state4 = 4'b0100;
parameter state5 = 4'b0101;
parameter state6 = 4'b0110;
parameter state7 = 4'b0111;
parameter state8 = 4'b1000;
parameter state9 = 4'b1001;
parameter state10 = 4'b1010;
parameter state11 = 4'b1011;
parameter state12 = 4'b1100;
parameter state13 = 4'b1101;
parameter state14 = 4'b1110;



always@(posedge CLK)
begin
  if(RSTn) begin
    current_state <= next_state;
  end
end

  // else current_state = next_state; // MAYBE ONE CYLE LATER

  // SET THE OUTPUT CONTROL SIGNALS
always@(current_state) begin
      //if(RSTn) begin

      //$display("I'm BUSSSING state %d", current_state );
      /*
      PCWrite = 1'b0;
      Branch = 1'b0;
      IMRead = 1'b0;
      IRWrite = 1'b0;
      RegWrite = 1'b0;
      ALUSrcA = 1'b0;
      ALUSrcB = 3'b000;
      ALUOp = OPCODE;
      NullLSB = 1'b0;
      MemRead = 1'b0;
      MemWrite = 1'b0;
      MemToReg = 1'b0;
      */
      case(current_state)
      // stateNeg: begin 
      //   next_state = state0; 
      // end
      state0:
      begin
        IMRead = 1'b1;
        IRWrite = 1'b1;
        ALUSrcB = 3'b001;

        PCWrite = 1'b0;
        Branch = 1'b0;
        RegWrite = 1'b0;
        ALUSrcA = 1'b0;
        ALUOp = 7'b1101111;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b1;
        SaveSig = 1'b0;
      end
      state1:
      begin
        RegWrite = 1'b1;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        ALUSrcA = 1'b0;
        ALUSrcB = 3'b000;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b0;
        SaveSig = 1'b1;
      end
      state2:
      begin
        PCWrite = 1'b1;
        ALUSrcB = 3'b011;

        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUSrcA = 1'b0;
        ALUOp = 7'b1101111;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b1;
        SaveSig = 1'b0;
      end
      state3:
      begin
        ALUSrcB = 3'b101;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUSrcA = 1'b0;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b1;
        SaveSig = 1'b0;
      end
      state4:
      begin
        ALUSrcB = 3'b100;
        NullLSB = 1'b1;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUSrcA = 1'b1;
        ALUOp = OPCODE;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b1;
        SaveSig = 1'b0;
      end
      state5:
      begin
        Branch = 1'b1;
        ALUSrcA = 1'b1;

        PCWrite = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUSrcB = 3'b000;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b1;
        ALUOutWrite = 1'b0;
        SaveSig = 1'b1;
      end
      state6:
      begin
        ALUSrcA = 1'b1;
        ALUSrcB = 3'b100;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b1;
        SaveSig = 1'b0;
      end
      state7:
      begin
        ALUSrcA = 1'b1;
        ALUSrcB = 3'b010;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b1;
        SaveSig = 1'b0;
      end
      state8:
      begin
        ALUSrcA = 1'b1;
        ALUSrcB = 3'b100;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b1;
        SaveSig = 1'b0;
      end
      state9:
      begin
        ALUSrcA = 1'b1;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUSrcB = 3'b000;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b1;
        SaveSig = 1'b0;
      end
      state10:
      begin
        PCWrite = 1'b1;

        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUSrcA = 1'b0;
        ALUSrcB = 3'b000;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b1;
        ALUOutWrite = 1'b0;
        SaveSig = 1'b0;
      end
      state11:
      begin
        MemRead = 1'b1;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUSrcA = 1'b0;
        ALUSrcB = 3'b000;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b0;
        ALUOutWrite = 1'b0;
        SaveSig = 1'b0;
      end
      state12:
      begin
        MemWrite = 1'b1;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b0;
        ALUSrcA = 1'b0;
        ALUSrcB = 3'b000;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b1;
        ALUOutWrite = 1'b0;
        SaveSig = 1'b1;
      end
      state13:
      begin
        RegWrite = 1'b1;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        ALUSrcA = 1'b0;
        ALUSrcB = 3'b000;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        InstSig = 1'b1;
        ALUOutWrite = 1'b0;
        SaveSig = 1'b1;
      end
      state14:
      begin
        RegWrite = 1'b1;
        MemToReg = 1'b1;

        PCWrite = 1'b0;
        Branch = 1'b0;
        IMRead = 1'b0;
        IRWrite = 1'b0;
        ALUSrcA = 1'b0;
        ALUSrcB = 3'b000;
        ALUOp = OPCODE;
        NullLSB = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        InstSig = 1'b1;
        ALUOutWrite = 1'b0;
        SaveSig = 1'b1;
      end
      endcase

  //end
end 

always @(current_state or OPCODE) begin
  // SET THE NEXT STATE
  case(current_state)
   stateNeg: begin next_state = state0; end
  state0:
  begin
    case(OPCODE)
    7'b1101111, 7'b1100111: begin next_state = state1; end // JAL & JALR
    7'b1100011, 7'b0000011, 7'b0100011, 7'b0010011, 7'b0110011: begin next_state = state2; end //B-type, LW, SW, RImm, R-type
    endcase
  end
  state1: 
  begin
    case(OPCODE)
    7'b1101111: begin next_state = state3; end // JAL
    7'b1100111: begin next_state = state4; end // JALR
    endcase
  end
  state2:
  begin
    case(OPCODE)
    7'b1100011: begin next_state = state5; end // B-type
    7'b0000011: begin next_state = state6; end // LW
    7'b0100011: begin next_state = state7; end // SW
    7'b0010011: begin next_state = state8; end // RImm
    7'b0110011: begin next_state = state9; end // R-type
    endcase
  end
  state3: begin next_state = state10; end
  state4: begin next_state = state10; end
  state5: begin next_state = state0; end
  state7: begin next_state = state12; end
  state8: begin next_state = state13; end
  state6: begin next_state = state11; end
  state9: begin next_state = state13; end
  state10: begin next_state = state0; end
  state11: begin next_state = state14; end
  state12: begin next_state = state0; end
  state13: begin next_state = state0; end
  state14: begin next_state = state0; end
  default: begin next_state = state0; end 
  endcase
end
endmodule


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

module RISCV_CTRL (
    input wire [6:0] OP,  

    // control signals 
    output wire [3:0] ALUOp,
    output wire [1:0] ALUSrcPC01, 
    output wire [2:0] ALUSrc2USJ+, 
    output wire MemWrite, 
    output wire MemRead, 
    output wire MemToReg, 
    output wire RegWrite, 
    output wire ReturnAddrToReg, 
    output wire Branch, 
    // output wire BrTkn, INSIDE ALU CONTROL
    output wire Jump, 
    output wire IndirectJump, 
    // output wire [2:0] RegWriteSize, INSIDE ALU CONTROL
    // output wire [2:0] MemRegSize INSIDE ALU CONTROL
    ); 
            // ALUOp = 
            // ALUSrcPC01 = 
            // ALUSrc2USJ+ = 
            // MemWrite = 
            // MemRead = 
            // MemToReg = 
            // RegWrite = 
            // ReturnAddrToReg = 
            // Branch = 
            // Jump = 
            // IndirectJump = 


    // realization 
    always @ (*) begin 
        case (OP) 
        7'b0110111: begin // LUI 0000 (Load Upper Immediate: Reg = Instr[31:12] + [0...0])
            ALUOp = 4'b0000;
            ALUSrcPC01 = 2'b01; 
            ALUSrc2USJ+ = 3'b001; 
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            ReturnAddrToReg = 1'b0;
            Branch = 1'b0;
            Jump = 1'b0;
            IndirectJump = 1'b0;
        end 
        7'b0010111: begin // AUIPC 0001 : Reg = PC + (Instr(31:12) + [0...0])
            ALUOp = 4'b0001; 
            ALUSrcPC01 = 2'b00;
            ALUSrc2USJ+ = 3'b001;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            ReturnAddrToReg = 1'b0;
            Branch = 1'b0;
            Jump = 1'b0;
            IndirectJump = 1'b0;
        end 
        7'b1101111: begin // JAL 0010 : sign exteded signed offset Instr(31, 19:12, 20, 30:21 = 31:12) + PC, save PC+4 to rd address Instr(11:7)
            ALUOp = 4'b0010; 
            ALUSrcPC01 = 2'b00;
            ALUSrc2USJ+ = 3'b001;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            ReturnAddrToReg = 1'b1;
            Branch = 1'b0;
            Jump = 1'b1;
            IndirectJump = 1'b0;
        end 
        7'b1100111: begin // JALR 0011
            ALUOp = 4'b0011;
            ALUSrcPC01 = 2'b10;
            ALUSrc2USJ+ = 3'b011;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            ReturnAddrToReg = 1'b1;
            Branch = 1'b0;
            Jump = 1'b1;
            IndirectJump = 1'b1;
        end 
        7'b1100011: begin // BEQ, BNE, BLT, BGE, BLTU, BGEU 0100
            ALUOp = 4'b0100;
            ALUSrcPC01 = 2'b10;
            ALUSrc2USJ+ = 3'b000;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b0;
            ReturnAddrToReg = 1'b0;
            Branch = 1'b1;
            Jump = 1'b0;
            IndirectJump = 1'b0;
        end 
        7'b0000011: begin // LB, LH, LW, LBU, LHU 0101
            ALUOp = 4'b0101;
            ALUSrcPC01 = 2'b10;
            ALUSrc2USJ+ = 3'b100;
            MemWrite = 1'b0;
            MemRead = 1'b1;
            MemToReg = 1'b1;
            RegWrite = 1'b1;
            ReturnAddrToReg = 1'b0;
            Branch = 1'b0;
            Jump = 1'b0;
            IndirectJump = 1'b0;
        end 
        7'b0100011: begin // SB, SH, SW 0110
            ALUOp = 4'b0110;
            ALUSrcPC01 = 2'b10;
            ALUSrc2USJ+ = 3'b010;
            MemWrite = 1'b1;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b0;
            ReturnAddrToReg = 1'b0;
            Branch = 1'b0;
            Jump = 1'b0;
            IndirectJump = 1'b0;
        end
        7'b0010011: begin // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI 0111
            ALUOp = 4'b0111;
            ALUSrcPC01 = 2'b10;
            ALUSrc2USJ+ = 3'b100; // NOTE!!!! that SL(R)L(I)I uses shamt [24:20] that is rs2 address wire. We need to sign extend and then MUX with Imm [31:20] with the control from ALU Control Unit
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            ReturnAddrToReg = 1'b0;
            Branch = 1'b0;
            Jump = 1'b0;
            IndirectJump = 1'b0;
        end
        7'b0110011: begin // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND 1000
            ALUOp = 4'b1000;
            ALUSrcPC01 = 2'b10;
            ALUSrc2USJ+ = 3'b000;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            ReturnAddrToReg = 1'b0;
            Branch = 1'b0;
            Jump = 1'b0;
            IndirectJump = 1'b0;
        end
        endcase
    end 

endmodule

module RISCV_ALU_CTRL (
    // get ALUOp => understand if you need to process func3 [14:12] & func7 [31:25]
    input wire [6:0] func7,
    input wire [2:0] func3,
    input wire [3:0] ALUop, // depends on the number of possible OP signals sent by main control unit 

    output wire [3:0] ALUControlSignal, // type of operation 
    output wire [2:0] RegWriteSize, 
    /* 
    RegWriteSize: 
    000 - unsigned 8 bit extended 
    001 - signed 8 bit extended 
    010 - unsigned 16 bit extended 
    011 - signed 16 bit extended 
    100 - 32 bit 
    */
    output wire [2:0] MemWriteSize,
    output wire ShamtOverImm // shamt (1), Imm (0) - additional MUX before ALUSrc2USJ+ = 100 
    // BrTkn is the output from the ALU not ALU Unit
);
    always @ (*) begin

        /*
        4'b0000 LUI: Imm[0..0] ^ 'h0 = Imm[0..0]; XOR 
        4'b0001 AUIPC: Imm[0..0] ^ [0..0]PC = Imm[PC] , PC is 12 bit so no overlap 
        4'b0010 JAL: [sign ext]Instr(31:12) + PC => PC 
        4'b0011 JALR: 
        4'b0100 Branch: 
        4'b0101 Load: 
        4'b0110 Store: 
        4'b0111 Arithmetic with Imm: 
        4'b1000 Arithmetic:  
        */

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
        4'b0000 begin // LUI
            ALUControlSignal = 4'b0000; 
            RegWriteSize = 3'b100; 
            MemRegSize = x; 
            ShamtOverImm = 1'b0; 
        end
        4'b0001 begin // AUIPC 
            ALUControlSignal = 4'b0000; 
            RegWriteSize = 3'b100; 
            MemRegSize = x; 
            ShamtOverImm = 1'b0; 
        end 
        4'b0010 begin // JAL (? overflow) : sign ext Imm + PC => PC
        // NOTE: Pc+4 must be zero extended before passing through the last MUX before WB stage  
            ALUControlSignal = 4'b0000; 
            RegWriteSize = 3'b100; 
            MemRegSize = x; 
            ShamtOverImm = 1'b0; 
        end 
        4'b0011 begin // JALR 
            ALUControlSignal = 4'b0000;
            RegWriteSize = 3'b100;
            MemRegSize = x;
            ShamtOverImm = 1'b0;
        end
        4'b0100 begin // B-Type
            case (func3)
            3'b000 begin // BEQ
                ALUControlSignal = 4'1100; // MAYBE another signal for == because it has same signal as BNE and we cannot distinguish between them in ALU. Check if we can == and !=
                RegWriteSize = 3'b100;
                MemRegSize = x;
                ShamtOverImm = 1'b0;
            end
            3'b001 begin // BNE
                ALUControlSignal = 4'b1101;
                RegWriteSize = 3'b100;
                MemRegSize = x;
                ShamtOverImm = 1'b0;
            end
            3'b001 begin // BLT
                ALUControlSignal = 4'b0010;
                RegWriteSize = 3'b100;
                MemRegSize = x;
                ShamtOverImm = 1'b0;
            end
            3'b001 begin // BGE
                ALUControlSignal = 4'b0011;
                RegWriteSize = 3'b100;
                MemRegSize = x;
                ShamtOverImm = 1'b0;
            end
            3'b001 begin // BLTU
                ALUControlSignal = 4'b0100;
                RegWriteSize = 3'b100;
                MemRegSize = x;
                ShamtOverImm = 1'b0;
            end
            3'b001 begin // BGEU
                ALUControlSignal = 4'b0101;
                RegWriteSize = 3'b100;
                MemRegSize = x;
                ShamtOverImm = 1'b0;
            end
            endcase
        end
        4'b0101 begin // L-Type
            case (func3) begin
                3'b000 begin // LB
                    ALUControlSignal = 4'b0000;
                    RegWriteSize = 3'b001;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b000 begin // LH
                    ALUControlSignal = 4'b0000;
                    RegWriteSize = 3'b011;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b000 begin // LW
                    ALUControlSignal = 4'b0000;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b000 begin // LBU
                    ALUControlSignal = 4'b0000;
                    RegWriteSize = 3'b000;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b000 begin // LHU
                    ALUControlSignal = 4'b0000;
                    RegWriteSize = 3'b010;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
            endcase
        end
        4'b0110 begin // S-Type
            case (func3) begin
                3'b000 begin // SB
                    ALUControlSignal = 4'b0000;
                    RegWriteSize = x;
                    MemRegSize = 3'b000;
                    ShamtOverImm = 1'b0;
                end
                3'b001 begin // SH
                    ALUControlSignal = 4'b0000;
                    RegWriteSize = x;
                    MemRegSize = 3'b010;
                    ShamtOverImm = 1'b0;
                end
                3'b010 begin // SW
                    ALUControlSignal = 4'b0000;
                    RegWriteSize = x;
                    MemRegSize = 3'b100;
                    ShamtOverImm = 1'b0;
                end
            endcase
        end
        4'b0111 begin // R-Type Imm
            case (func3)
                3'b000 begin // ADDI
                    ALUControlSignal = 4'b0000;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b010 begin // SLTI
                    ALUControlSignal = 4'b0010;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b011 begin // SLTIU
                    ALUControlSignal = 4'b0100;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b100 begin // XORI
                    ALUControlSignal = 4'b0110;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b110 begin // ORI
                    ALUControlSignal = 4'b1000;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b111 begin // ANDI
                    ALUControlSignal = 4'b0111;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b001 begin // SLLI
                    ALUControlSignal = 4'b1001;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b1;
                end
                3'b101 begin // SR(L/A)I
                    case (func7)
                        7'b0000000 begin // SRLI
                            ALUControlSignal = 4'b1010;
                            RegWriteSize = 3'b100;
                            MemRegSize = x;
                            ShamtOverImm = 1'b1;
                        end
                        7'b0100000 begin // SRAI
                            ALUControlSignal = 4'b1011;
                            RegWriteSize = 3'b100;
                            MemRegSize = x;
                            ShamtOverImm = 1'b1;
                        end
                    endcase
                end
            endcase
        end
        4'b1000 begin // R-Type rs2
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
            case (func3)
                3'b000 begin
                    case (func7)
                        7'b0000000 begin // ADD
                            ALUControlSignal = 4'b0000;
                            RegWriteSize = 3'b100;
                            MemRegSize = x;
                            ShamtOverImm = 1'b0;
                        end
                        7'b0100000 begin // SUB
                            ALUControlSignal = 4'b0001;
                            RegWriteSize = 3'b100;
                            MemRegSize = x;
                            ShamtOverImm = 1'b0;
                        end
                    endcase
                end
                3'b001 begin // SLL NOTE To use lower 5 bits from the value held by rs2
                    ALUControlSignal = 4'b1001;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b010 begin // SLT
                    ALUControlSignal = 4'b0010;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b011 begin // SLTU
                    ALUControlSignal = 4'b0100;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b100 begin // XOR
                    ALUControlSignal = 4'b0110;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b101 begin // SLL
                    case (func7)
                        7'b0000000 begin // SRL
                            ALUControlSignal = 4'b1010;
                            RegWriteSize = 3'b100;
                            MemRegSize = x;
                            ShamtOverImm = 1'b0;
                        end
                        7'b0100000 begin // SRA
                            ALUControlSignal = 4'b1011;
                            RegWriteSize = 3'b100;
                            MemRegSize = x;
                            ShamtOverImm = 1'b0;
                        end
                    endcase
                end
                3'b110 begin // OR
                    ALUControlSignal = 4'b1000;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
                3'b111 begin //AND
                    ALUControlSignal = 4'b0111;
                    RegWriteSize = 3'b100;
                    MemRegSize = x;
                    ShamtOverImm = 1'b0;
                end
            endcase
        end
        endcase

    end

endmodule 
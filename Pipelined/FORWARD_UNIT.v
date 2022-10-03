module FRD (
    input wire EX_MEM_RegWrite,
    input wire MEM_WB_RegWrite,
    input wire [31:0] EX_MEM_RD,
    input wire ID_EX_RS1_used,
    input wire ID_EX_RS2_used,
    input wire [31:0] ID_EX_RS1,
    input wire [31:0] ID_EX_RS2,
    input wire [31:0] MEM_WB_RD,
    input wire [31:0] IF_ID_RS1,
    input wire [31:0] IF_ID_RS2,
    input wire [6:0] OP,
    output reg [1:0] FRD_A,
    output reg [1:0] FRD_B,
    output reg FRD_PRE_A,
    output reg FRD_PRE_B
);

    always @ (*) 
    begin
        assign FRD_A = 2'b00;
        assign FRD_B = 2'b00;
        assign FRD_PRE_A = 1'b0;
        assign FRD_PRE_B = 1'b0;

        // EX/MEM forwarding - checking instruction executed 1 cycle ago 
        if (EX_MEM_RegWrite)
        begin
            if ((EX_MEM_RD == ID_EX_RS1) && ID_EX_RS1_used)
                begin
                //$display("1 CYCLE AGO");
                assign FRD_A = 2'b01;
                end
            if ((EX_MEM_RD == ID_EX_RS2) && ID_EX_RS2_used)
                assign FRD_B = 2'b01;
        end   

        // MEM/WB forwarding - checking instruction executed 2 cycles ago 
        if (MEM_WB_RegWrite)
        begin
            if (ID_EX_RS1_used) 
            begin
                if ((MEM_WB_RD == ID_EX_RS1) && ((EX_MEM_RD != ID_EX_RS1)||(EX_MEM_RegWrite == 0)))
                begin
                    //$display("2 CYCLE AGO");
                    assign FRD_A = 2'b10;
                end
            end

            if (ID_EX_RS2_used)
            begin
                if ((MEM_WB_RD == ID_EX_RS2) && ((EX_MEM_RD != ID_EX_RS2)||(EX_MEM_RegWrite == 0)))
                begin
                    assign FRD_B = 2'b10;
                end
            end
        end

        // forwarding after reg file but before reg
        if (MEM_WB_RegWrite) 
        begin
            if (OP == 7'b1100011 || OP == 7'b0100011 || OP == 7'b0110011) // both rs1 and rs2
            begin
                if (MEM_WB_RD == IF_ID_RS1)
                    assign FRD_PRE_A = 1'b1;
                if (MEM_WB_RD == IF_ID_RS2)
                    assign FRD_PRE_B = 1'b1;
            end

            if (OP == 7'b1100111 || OP == 7'b0000011 || OP == 7'b0010011) // only rs1
            begin
                if (MEM_WB_RD == IF_ID_RS1)
                    assign FRD_PRE_A = 1'b1;
            end
        end
    end
endmodule
module HZRD (
    input wire ID_EX_MemRead,
    input wire BrFlush, 
    input wire [4:0] ID_EX_RD,
    input wire [4:0] IF_ID_RS1, 
    input wire [4:0] IF_ID_RS2,
    input wire [6:0] OP, 
    input wire RSTn,
    output reg PCWrite,
    output reg IF_ID_Write,
    output reg ID_EX_CtrlSrc
);

initial begin 
    assign PCWrite = 1'b1  & RSTn ;
    assign IF_ID_Write = 1'b1  & RSTn;
    assign ID_EX_CtrlSrc = 1'b1  & RSTn;
end 

always @ (*)
begin
    assign PCWrite = 1'b1  & RSTn;
    assign IF_ID_Write = 1'b1  & RSTn;
    assign ID_EX_CtrlSrc = 1'b1  & RSTn;

    // DETECT load instructions 
    if (ID_EX_MemRead == 1'b1)
    begin
        if (OP == 7'b1100011 || OP == 7'b0100011 || OP == 7'b0110011) // both rs1 and rs2
        begin
            if (ID_EX_RD == IF_ID_RS1 || ID_EX_RD == IF_ID_RS2) 
            begin
                assign PCWrite = BrFlush;
                assign IF_ID_Write = BrFlush;
                assign ID_EX_CtrlSrc = 1'b0;
            end
        end
        if (OP == 7'b1100111 || OP == 7'b0000011 || OP == 7'b0010011) // only rs1
        begin
            if (ID_EX_RD == IF_ID_RS1)
            begin
                assign PCWrite = BrFlush;
                assign IF_ID_Write = BrFlush;
                assign ID_EX_CtrlSrc = 1'b0;
            end
        end

    end
end
endmodule
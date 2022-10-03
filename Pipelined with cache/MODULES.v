module STOPPER (
    input wire CLK,
    input wire MemAcc,
    output wire WriteAll,
    output wire AlreadyProcessed
);

reg   [3:0]     latency_counter;
reg state;
reg WriteAll_reg;
reg AlreadyProcessed_reg;


assign WriteAll = WriteAll_reg;
assign AlreadyProcessed = AlreadyProcessed_reg;

initial begin
    state <= 0;
    AlreadyProcessed_reg <= 0;
    WriteAll_reg <= 1;
end

always @ (posedge CLK) begin
    if (~state)
    begin
        if (MemAcc)
        begin
            latency_counter = 6;
            state = 1;
            WriteAll_reg = 0;
            AlreadyProcessed_reg = 0;
        end
        else
        begin
            WriteAll_reg = 1;
            AlreadyProcessed_reg = 0;
        end
    end
    else
    begin
        if (latency_counter)
        begin
            latency_counter <= latency_counter - 1;
            WriteAll_reg = 0;
            AlreadyProcessed_reg = 0;
        end
        else 
        begin // 8th cycle
            state = 0;
            WriteAll_reg = 1;
            AlreadyProcessed_reg = 1;
        end
    end
end

endmodule

module REG (
    input wire CLK,
    input wire write,
    input wire [31:0] IN,
    output wire [31:0] OUT
);
    reg [31:0] VAL;

    initial begin
        VAL = 0;
    end

    assign OUT = VAL;

    // negedge because inside 1 cycle we need to get value from reg_file, which is posedge
    // therefore saving should happen some time later after reading, therefore it's negedge
    always @(negedge CLK) 
    begin
        if (write) 
        begin
            VAL <= IN;
        end
    end

endmodule

module MUX_2 (
    input wire [31:0] IN_0,
    input wire [31:0] IN_1,   
    input wire sel,
    output wire [31:0] OUT
);

assign OUT = sel ? IN_1 : IN_0;

endmodule

// forwardA, forwardB
module MUX_3 (
    input wire [31:0] IN_0, // 00
    input wire [31:0] IN_1, // 01
    input wire [31:0] IN_2, // 10
    input wire[1:0] sel,
    output wire [31:0] OUT
);

assign OUT = sel[1] ? IN_2 : (sel[0] ? IN_1 : IN_0);

endmodule

// SrcB
module MUX_4 (
    input wire [31:0] IN_0, // 00
    input wire [31:0] IN_1, // 01
    input wire [31:0] IN_2, // 10
    input wire [31:0] IN_3, // 11
    input wire[1:0] sel,
    output wire [31:0] OUT
);

assign OUT = sel[1] ? (sel[0] ? IN_3 : IN_2) : (sel[0] ? IN_1 : IN_0);

endmodule

module PC_INC (
    input wire [31:0] PC_current, 
    output wire [31:0] PC_4
);
    assign PC_4 = PC_current + 4; 
endmodule 

module Br_Addr_ADD (
    input wire [31:0] BrImm, 
    input wire [31:0] PC_current, 
    output wire [31:0] BrAddr 
);
    assign BrAddr = BrImm + PC_current; 
endmodule 

// module MUX_6 (
//     input wire [31:0] IN_000,
//     input wire [31:0] IN_001,   
//     input wire [31:0] IN_010,  
//     input wire [31:0] IN_011,  
//     input wire [31:0] IN_100,
//     input wire [31:0] IN_101,   

//     input wire [2:0] sel,
//     output wire [31:0] OUT
// );

// assign OUT = sel[2] ? (sel[0] ? IN_101 : IN_100) : (sel[1] ?  (sel[0] ? IN_011 : IN_010) : (sel[0] ? IN_001 : IN_000));

// endmodule
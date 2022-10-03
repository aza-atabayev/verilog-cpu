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
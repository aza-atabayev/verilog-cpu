module ALU(A,B,OP,C,BrTkn);

	input wire [31:0] A;
	input wire [31:0] B;
	input wire [3:0] OP;
	output reg [31:0] C;
    output reg BrTkn;


	always @(*) begin
        BrTkn = 0;
        C = 0;
	    case (OP) 
	    4'b0000 :
            begin
                C = A + B;
                BrTkn = 0;
	        end
	    4'b0001 : 
            begin
                C = A - B;
                BrTkn = 0;
	        end
	    4'b0010 : 
            begin
                if ($signed(A) < $signed(B)) begin
                    BrTkn = 1;
                    C = 1;
                end
                else begin 
                    BrTkn = 0;
                    C = 0;
                end
            end
	    4'b0011 : 
            begin
                if ($signed(A) >= $signed(B)) begin
                    BrTkn = 1;
                    C = 1;
                end
                else begin 
                    BrTkn = 0;
                    C = 0;
                end
            end
	    4'b0100 : 
            begin
                if ($unsigned(A) < $unsigned(B)) begin
                    BrTkn = 1;
                    C = 1;
                end
                else begin 
                    BrTkn = 0;
                    C = 0;
                end
            end
	    4'b0101 : 
            begin
                if ($unsigned(A) >= $unsigned(B)) begin
                    BrTkn = 1;
                    C = 1;
                end
                else begin 
                    BrTkn = 0;
                    C = 0;
                end
            end
	    4'b0110 : C = A ^ B;
	    4'b0111 : C = A & B;
	    4'b1000 : C = A | B;
        4'b1001 : C = A << B;
	    4'b1010 : C = A >> B;
	    4'b1011 : C = $signed(A) >>> B;
        4'b1100 : 
            begin
                if (A == B)
                    BrTkn = 1;
                else 
                    BrTkn = 0;
            end
	    4'b1101 : 
            begin
                if (A != B)
                    BrTkn = 1;
                else 
                    BrTkn = 0;
            end
	  endcase
	end

endmodule
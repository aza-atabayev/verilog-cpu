`timescale 1ns/10ps
module SP_DRAM #(parameter ROMDATA = "", AWIDTH = 10, SIZE = 1024, DWIDTH = 128, LATENCY = 8) ( // AZAMAT CHANGED SIZE FROM 1024 to 4096
	input	wire			CLK,
	input	wire			CSN,//chip select negative??
	input	wire	[AWIDTH-1:0]	ADDR,
	input	wire			WEN,//write enable negative??
	//input	wire	[3:0]		BE,//byte enable, removed for Cache lab
	input	wire	[127:0]		DI, //data in // CHANGED FROM 127 TO 31 
	output	wire	[127:0]		DOUT // data out // CHANGED FROM 127 TO 31
);

	reg		[127:0]		outline; // CHANGED FROM 127 TO 31
	reg		[127:0]		ram[0 : SIZE-1]; // CHANGED FROM 127 TO 31
	reg		[127:0]		temp; // CHANGED FROM 127 TO 31

	// New features for Cache lab
	reg   [3:0]     latency_counter;
	reg							reg_WEN;
	reg		[AWIDTH-1:0]	reg_ADDR;
	reg 	[127:0]		reg_DI;

	initial begin
		if (ROMDATA != "")
			$readmemh(ROMDATA, ram);
	end

	assign #1 DOUT = outline;

	always @ (negedge CLK) begin
		// $display("ADDR IN DMEM MODEL AT EACH NEGEDGE CLOCK: %d", ADDR);
		if (latency_counter)
		begin
			latency_counter <= latency_counter - 1;
		end
		else if (~CSN)
		begin
			latency_counter <= LATENCY-2;
			reg_WEN <= WEN;
			reg_ADDR <= ADDR;
			reg_DI <= DI;
			// $display("ADDRESS WRITTEN ON THE ~CSN inside DMEM and THE ADDR FROM TOP:: %d, %d", reg_ADDR, ADDR);
		end

		// Synchronous write
		else if (~latency_counter)
				if (~reg_WEN) begin 
					// $display("DMEM WRITE HAPPENING: %b. AT %d ADDRESS", reg_DI, reg_ADDR); 
					ram[reg_ADDR] = reg_DI;
				end 
				else begin 
					// $display("DMEM READ HAPPENING: %b. AT %d ADDRESS", ram[reg_ADDR], reg_ADDR);
					outline = ram[reg_ADDR];
				end
	end

endmodule

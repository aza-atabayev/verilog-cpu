/*
NOTE:
 1: 4 words per cacheline (4 data blocks)
 2: 128B cache capacity -> 32 words -> store 8 cachelines
 4: No Replacement policy cuz' direct mapped
 5: write-through for write-hit policy, no dirty bit
 6: write-allocate for write-miss policy
*/

module CACHE(
  input           CLK,
  input           RSTn,

  // STOPPER
  output wire WriteAll,

  // CPU
  input           MemWrite,
  input           MemRead,
  input  [11:0]   CPU_MEM_ADDR_IN,
  input  [31:0]   CPU_MEM_DI,

  output [31:0]   CPU_MEM_DOUT,
  // output [1:0]    LATENCY_STATE,

  // Data Memory
  input  [127:0]  D_MEM_DI,         // Data Read from DMEM
  output [127:0]  D_MEM_DOUT,       // Data Written to DMEM
  output [9:0]    D_MEM_ADDR,       // Address to DMEM
  output          D_MEM_CSN,        // Memory Access
  output          D_MEM_WEN         // Write Enable Negative

);

  /*
    Index = CPU_MEM_ADDR_IN[4:2] xxxxxxx000xx
    Data Inside Tag = CPU_MEM_ADDR_IN[2:0] xxxxxxxxxx00
    Address to D_MEM = CPU_MEM_ADDR_IN[11:2] 0000000000xx
    Tag = CPU_MEM_ADDR_IN[11:5] 0000000xxxxx
  */

  /*  
      cache [ 134:128 | 127:96 |  95:64 | 63:32  |  31:0  ]
            
    | Index |   Tag   | Data 4 | Data 3 | Data 2 | Data 1 |
     -----------------------------------------
    |  000  | 0000000 | xxxxxx | xxxxxx | xxxxxx | xxxxxx |
    |  001  | 0000000 | xxxxxx | xxxxxx | xxxxxx | xxxxxx |
    |  010  | 0000000 | xxxxxx | xxxxxx | xxxxxx | xxxxxx |
    |  011  | 0000000 | xxxxxx | xxxxxx | xxxxxx | xxxxxx |
    |  100  | 0000000 | xxxxxx | xxxxxx | xxxxxx | xxxxxx |
    |  101  | 0000000 | xxxxxx | xxxxxx | xxxxxx | xxxxxx |
    |  110  | 0000000 | xxxxxx | xxxxxx | xxxxxx | xxxxxx |
    |  111  | 0000000 | xxxxxx | xxxxxx | xxxxxx | xxxxxx |
  */


  // Inner Registers
  reg [5:0] local_latency;
  reg state;
  reg [1:0]step;
  reg [134:0] cache[7:0]; // Initialize Cache

  // Outside Registers
  reg [2:0] CACHE_IND;
  reg [6:0] CACHE_TAG;
  reg [1:0] CACHE_D_NUM;

  reg [31:0] CPU_MEM_DOUT_REG;
  // reg [1:0] LATENCY_STATE_REG;
  reg [127:0] D_MEM_DOUT_REG;
  reg [9:0] D_MEM_ADDR_REG;
  reg D_MEM_CSN_REG;
  reg D_MEM_WEN_REG;
  assign CPU_MEM_DOUT = CPU_MEM_DOUT_REG;
  // assign LATENCY_STATE = LATENCY_STATE_REG;
  assign D_MEM_DOUT = D_MEM_DOUT_REG;
  assign D_MEM_ADDR = D_MEM_ADDR_REG;
  assign D_MEM_CSN = D_MEM_CSN_REG;
  assign D_MEM_WEN = D_MEM_WEN_REG;

  // STOPPER Registers
  reg WriteAll_reg;
  assign WriteAll = WriteAll_reg;

  // NEW STOPPER Registers
  reg   [5:0]     templocal_latency;
  reg tempstate;
  reg [2:0]tempstep;


// ---------------------------- START ------------------------- //
  initial begin 
    state <= 0;
    step <= 0;
    WriteAll_reg <= 1;
    D_MEM_WEN_REG <= 1;
    D_MEM_CSN_REG <= 1;
    tempstate <= 0;
    tempstep <= 0;
  end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  always @ (posedge CLK) begin
    if (RSTn) begin
      if (~tempstate) begin
        if (MemRead) begin // Read hit/miss
          if (cache[CPU_MEM_ADDR_IN[4:2]][134:128] == CPU_MEM_ADDR_IN[11:5]) begin
            // READ HIT
            tempstate = 0;
            templocal_latency = 0;
            tempstep = 0;

            D_MEM_CSN_REG = 1;
            D_MEM_WEN_REG = 1;
            WriteAll_reg = 1;
          end
          else begin // READ MISS
            case (tempstep)
              3'b000: begin
                tempstep = 3'b001;
                D_MEM_CSN_REG = 1;
                D_MEM_WEN_REG = 1;

                tempstate = 0;
                templocal_latency = 0;
                WriteAll_reg = 0;

                
              end
              3'b001: begin
                tempstep = 3'b010;
                D_MEM_CSN_REG = 0;
                D_MEM_WEN_REG = 1;

                tempstate = 1;
                templocal_latency = 5;
                WriteAll_reg = 0;
                
              end
              3'b010: begin // before last cycle
                tempstep = 3'b011;

                D_MEM_CSN_REG = 1;
                D_MEM_WEN_REG = 1;

                templocal_latency = 0;
                tempstate = 0;
                WriteAll_reg = 0;
                
              end
              3'b011: begin // last cycle
              // $display("READ MISS EMPTY SPACE tempstep = %b", tempstep);
                tempstep = 3'b000;
                D_MEM_CSN_REG = 1;
                D_MEM_WEN_REG = 1;

                templocal_latency = 0;
                tempstate = 0;
                WriteAll_reg = 1;
                
              end

            endcase
          end
        end
        else if (MemWrite) begin
          if (cache[CPU_MEM_ADDR_IN[4:2]][134:128] == CPU_MEM_ADDR_IN[11:5]) begin
            // WRITE HIT
            case (tempstep)
              3'b000: begin
                // $display("WRITE HIT EMPTY SPACE tempstep = %b", tempstep);
                tempstep = 3'b001;
                D_MEM_CSN_REG = 1;
                D_MEM_WEN_REG = 1;

                tempstate = 0;
                templocal_latency = 0;
                WriteAll_reg = 0;
                
              end
              3'b001: begin
                // $display("WRITE HIT EMPTY SPACE tempstep = %b", tempstep);
                tempstep = 3'b010;

                D_MEM_CSN_REG = 0;
                D_MEM_WEN_REG = 0;

                templocal_latency = 5;
                tempstate = 1;
                WriteAll_reg = 0;
              
              end
              3'b010: begin // LAST cycle
                // $display("WRITE HIT EMPTY SPACE tempstep = %b", tempstep);
                tempstep = 3'b000;

                D_MEM_CSN_REG = 1;
                D_MEM_WEN_REG = 1;

                templocal_latency = 0;
                tempstate = 0;
                WriteAll_reg = 1;
                
              end

            endcase
          end
          else begin // WRITE MISS
            case (tempstep)
              3'b000: begin
                // $display("WRITE MISS EMPTY SPACE tempstep = %b", tempstep);
                tempstep = 3'b001;
                D_MEM_CSN_REG = 1;
                D_MEM_WEN_REG = 1;

                tempstate = 0;
                templocal_latency = 0;
                WriteAll_reg = 0;
              end
              3'b001: begin
                // $display("WRITE MISS EMPTY SPACE tempstep = %b", tempstep);
                tempstep = 3'b010;

                D_MEM_CSN_REG = 0;
                D_MEM_WEN_REG = 1;

                templocal_latency = 5;
                tempstate = 1;
                WriteAll_reg = 0;
              end
              3'b010: begin
                // $display("WRITE MISS EMPTY SPACE tempstep = %b", tempstep);
                tempstep = 3'b011;

                D_MEM_CSN_REG = 1;
                D_MEM_WEN_REG = 1;

                templocal_latency = 0;
                tempstate = 0;
                WriteAll_reg = 0;
              end
              3'b011: begin
                // $display("WRITE MISS EMPTY SPACE tempstep = %b", tempstep);
                tempstep = 3'b100;
                // $display("What do you mean by that? %b == %b", cache[CPU_MEM_ADDR_IN[4:2]][134:128], CPU_MEM_ADDR_IN[11:5]);

                D_MEM_CSN_REG = 1;
                D_MEM_WEN_REG = 1;

                templocal_latency = 0;
                tempstate = 0;
                WriteAll_reg = 0;
              end
              3'b100: begin
                tempstep = 3'b101;
                D_MEM_CSN_REG = 0;
                D_MEM_WEN_REG = 0;

                tempstate = 1;
                templocal_latency = 5;
                WriteAll_reg = 0;
              end
              3'b101: begin
                tempstep = 3'b000;

                D_MEM_CSN_REG = 1;
                D_MEM_WEN_REG = 1;

                templocal_latency = 0;
                tempstate = 0;
                WriteAll_reg = 1;
              end

            endcase
          end
        end
        else begin
          WriteAll_reg = 1;
          D_MEM_CSN_REG = 1;
          D_MEM_WEN_REG = 1;
          tempstate = 0;
        end
      end
      else begin
        if (templocal_latency) begin
          templocal_latency = templocal_latency - 1;
        end
        else begin
          tempstate = 0;
        end
      end
    end
  end




reg [134:0] temp_cache_line;


  always @ (negedge CLK) begin  // Have it same like DMEM?
    if (RSTn) begin
      if (~state) begin
        // $display("CPU MEM ADDR IN THE NEGEDGE CACHE: %d", CPU_MEM_ADDR_IN);
        CACHE_IND = CPU_MEM_ADDR_IN[4:2];
        CACHE_TAG = CPU_MEM_ADDR_IN[11:5];
        CACHE_D_NUM = CPU_MEM_ADDR_IN[1:0];
        if (MemRead) begin // Read hit/miss
          if (cache[CACHE_IND][134:128] == CACHE_TAG) begin // Read Hit
            case (CACHE_D_NUM)
            2'b00: CPU_MEM_DOUT_REG = cache[CACHE_IND][31:0];
            2'b01: CPU_MEM_DOUT_REG = cache[CACHE_IND][63:32];
            2'b10: CPU_MEM_DOUT_REG = cache[CACHE_IND][95:64];
            2'b11: CPU_MEM_DOUT_REG = cache[CACHE_IND][127:96];
            endcase

            // INNER Registers
            state = 0;
            local_latency = 0;
            step = 0; 
          end
          else begin // Read Miss
            // LATENCY_STATE_REG = 2'b01;
            case (step)
              2'b00: begin
                // D_MEM Access
                step = 1;
                D_MEM_ADDR_REG = CPU_MEM_ADDR_IN[11:2];

                local_latency = 7;
                state = 1;
              end
              2'b01: begin
                // Cache Update
                step = 0;
                cache[CACHE_IND] = {CACHE_TAG, D_MEM_DI};
                case (CACHE_D_NUM)
                  2'b00: CPU_MEM_DOUT_REG = cache[CACHE_IND][31:0];
                  2'b01: CPU_MEM_DOUT_REG = cache[CACHE_IND][63:32];
                  2'b10: CPU_MEM_DOUT_REG = cache[CACHE_IND][95:64];
                  2'b11: CPU_MEM_DOUT_REG = cache[CACHE_IND][127:96];
                endcase

                local_latency = 0;
                state = 0;
              end
            endcase
          end
        end
        else if (MemWrite) begin // Write hit/miss
          if (cache[CACHE_IND][134:128] == CACHE_TAG) begin // Write Hit
            // Write through: We update Cache and Update DMEM
            // LATENCY_STATE_REG = 2'b10;
                // Cache Update
                step = 0;
                case (CACHE_D_NUM)
                  2'b00: cache[CACHE_IND][31:0] = CPU_MEM_DI;
                  2'b01: cache[CACHE_IND][63:32] = CPU_MEM_DI;
                  2'b10: cache[CACHE_IND][95:64] = CPU_MEM_DI;
                  2'b11: cache[CACHE_IND][127:96] = CPU_MEM_DI;
                endcase

                // Memory Access and Update
                D_MEM_DOUT_REG = cache[CACHE_IND][127:0];
                D_MEM_ADDR_REG = CPU_MEM_ADDR_IN[11:2];


                local_latency = 7;
                state = 1;
                // $display("CPU_MEM_DOUT ON WRITE HIT BEFORE DMEM ACCESS: %b", CPU_MEM_DOUT_REG);
          end
          else begin // Write Miss
            // LATENCY_STATE_REG = 2'b11;
            // Write Allocate: 
            case (step)
              2'b00: begin
                // Memory Access
                step = 1;

                D_MEM_ADDR_REG = CPU_MEM_ADDR_IN[11:2];

                local_latency = 7;
                state = 1;
              end
              2'b01: begin
                // Cache Update and send Memory Update
                step = 2;
                temp_cache_line = {CACHE_TAG, D_MEM_DI};
                //cache[CACHE_IND] = {CACHE_TAG, D_MEM_DI};
                case (CACHE_D_NUM)
                  2'b00: temp_cache_line[31:0] = CPU_MEM_DI;
                  2'b01: temp_cache_line[63:32] = CPU_MEM_DI;
                  2'b10: temp_cache_line[95:64] = CPU_MEM_DI;
                  2'b11: temp_cache_line[127:96] = CPU_MEM_DI;
                endcase

                // CPU_MEM_DOUT_REG = 0; // FOR SAFETY
                D_MEM_DOUT_REG = temp_cache_line[127:0]; //cache[CACHE_IND][127:0];
                D_MEM_ADDR_REG = CPU_MEM_ADDR_IN[11:2];

                local_latency = 6; // AZA changed to 6 from 7 to account for stage below
                state = 1;
                // $display("CPU_MEM_DOUT ON WRITE MISS BEFORE DMEM ACCESS: %b", CPU_MEM_DOUT_REG);
              end
              2'b10: begin
                step = 0;
                cache[CACHE_IND] = temp_cache_line;

                local_latency = 0;
                state = 0;
                // $display("CPU_MEM_DOUT ON WRITE MISS LAST CYCLE IS: %b", CPU_MEM_DOUT_REG);
              end

            endcase
          end
        end
      end
      else begin
        if (local_latency) begin
          local_latency = local_latency - 1;
        end
        else begin
          state = 0;
        end
      end
    end
  end
endmodule

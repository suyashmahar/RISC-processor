`timescale 1ns/1ps
module SimpleDisplayMemory
  #(
    parameter DisplayBufferSize = 256
    )(
      input wire 			  clk,
  
      input wire [31:0] 		  InstAdd, // Address to fetch instruction from
      input wire [31:0] 		  DataAdd, // Address to fetch data from
      input wire [31:0] 		  MemDataContent,
  
      input wire 			  DataReadEn, // Enables output from memory
      input wire 			  DataWriteEn, // Enables writing to memory at end of cur. cycle

      input wire 			  MEMTYPE, // Enables writing to memory at end of cur. cycle
  
      output reg [31:0] 		  MemDataOut, // Data from memory
      output reg [31:0] 		  MemInstOut, // Instruction from memory	
      output wire [DisplayBufferSize-1:0] DisplayBuffer
      );
   
   reg [31:0] 				  mem [1023:0];
   reg [7:0] 				  dispMem [DisplayBufferSize/8:0];

   genvar 				  i;
   generate
       for (i = 0; i < DisplayBufferSize/8; i = i + 1) begin
	   assign DisplayBuffer[(i+1)*8 - 1 : i*8] = dispMem[DisplayBufferSize/8-i-1][7:0];
       end
   endgenerate

   integer k = 0;
   initial begin
       mem [0] = 32'h77ff0030;
       mem [1] = 32'h77ff0001;
       mem [2] = 32'h77ff0001;
       mem [3] = 32'h77ff002d;
       mem [4] = 32'h77ff002c;
       mem [5] = 32'h00000030;
       mem [6] = 32'h00000031;
       mem [7] = 32'h00000032;
       mem [8] = 32'h00000033;
       mem [9] = 32'h00000034;
       mem [10] = 32'h00000035;
       mem [11] = 32'h00000036;
       mem [12] = 32'h00000037;
       mem [13] = 32'h00000038;
       mem [14] = 32'h00000039;
       mem [15] = 32'h00000061;
       mem [16] = 32'h00000062;
       mem [17] = 32'h00000063;
       mem [18] = 32'h00000064;
       mem [19] = 32'h00000065;
       mem [20] = 32'h00000066;
       
       // Push
       mem [21] = 32'hc3bd0004;
       mem [22] = 32'h673dfffc;
       //ANDC
       mem [23] = 32'he339000f;
       // SHLC
       mem [24] = 32'hf3390002;
       // LD
       mem [25] = 32'h63390014;
       // STV
       mem [26] = 32'h03380000;
       
       mem [27] = 32'h633dfffc;
       mem [28] = 32'hc3bdfffc;
       mem [29] = 32'h6ffc0000;
       mem [30] = 32'hc3bd0004;
       mem [31] = 32'h66fdfffc;
       mem [32] = 32'hc3bd0004;
       mem [33] = 32'h671dfffc;
       mem [34] = 32'hc3bd0004;
       mem [35] = 32'h679dfffc;
       mem [36] = 32'hc31f001c;
       mem [37] = 32'h779fffef;
       mem [38] = 32'hf7390004;
       mem [39] = 32'hc318fffc;
       mem [40] = 32'hd6f80000;
       mem [41] = 32'h77f7fffb;
       mem [42] = 32'h639dfffc;
       mem [43] = 32'hc3bdfffc;
       mem [44] = 32'h631dfffc;
       mem [45] = 32'hc3bdfffc;
       mem [46] = 32'h62fdfffc;
       mem [47] = 32'hc3bdfffc;
       mem [48] = 32'h6ffc0000;
       mem [49] = 32'hc3bf0c00;
       mem [50] = 32'hc37f0c00;
       mem [51] = 32'hc33f01ea;
       mem [52] = 32'h779fffe9;
       mem [53] = 32'hc3ff0000;
       mem [54] = 32'h77fffffe;

       for (k = 0; k < DisplayBufferSize; k = k + 1) begin
	   dispMem[k] = 8'h00;
       end
   end
   
   always @(posedge clk) begin
       //#1
       if (DataWriteEn) begin
           if (MEMTYPE) begin
               dispMem[DataAdd/4] = MemDataContent;
           end else begin
               mem[DataAdd/4] = MemDataContent;
           end
       end
   end
   
   always @(mem, DataAdd, InstAdd, MEMTYPE) begin
       //#2
       MemInstOut = mem[InstAdd/4];

       if (MEMTYPE) begin
           MemDataOut = dispMem[DataAdd/4];       
       end else begin
           MemDataOut = mem[DataAdd/4];
       end
   end
endmodule // BasicTestMemory


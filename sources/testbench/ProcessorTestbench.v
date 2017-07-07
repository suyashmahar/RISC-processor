`timescale 1ns / 1ps

module ProcessorTestbench;
   
   reg clk;
   reg RESET;
   
   Processor uut(
      .clk(clk),
      .RESET(RESET)
   );

   integer i = 0;
   
   initial begin
      clk = 0;
      RESET = 0;
      #20
	RESET = 1;
      #20
	RESET = 0;
   end

   always begin
	 #40 clk = ~clk;
   end
endmodule

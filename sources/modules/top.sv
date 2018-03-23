`timescale 1ns / 1ps

module top
  #(
    parameter DisplayBufferSize = 256 
    )(
      // Global clock
      input wire  clk,
      input wire  RESET,
      input wire  IRQ,
      // Output wires for LCD
      output wire hSync, vSync,
      output wire [3-1:0] red, green, blue
      );

   wire [ASCII_SIZE-1:0] DisplayBuffer [CHARS_VERT-1:0][CHARS_HORZ-1:0];	// Display buffer from memory
   wire [256:0] 	      chars;		// chars in ascii for LCD
   
   Processor processor_instance
     (
      .clk(clk),
      .RESET(RESET),
      .IRQ(IRQ),
      .DisplayBuffer(DisplayBuffer)
      );

   draw vga_instance
     (
      .clk_25M(clk),
      .charBuffer(DisplayBuffer),
      .hSync(hSync), .vSync(vSync),
      .red(red), .green(green), .blue(blue)
      );
   

endmodule

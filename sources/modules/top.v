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
      output wire lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7
      );

   wire [DisplayBufferSize:0] DisplayBuffer;	// Display buffer from memory
   wire [256:0] 	      chars;		// chars in ascii for LCD
   
   Processor processor_instance
     (
      .clk(clk),
      .RESET(RESET),
      .IRQ(IRQ),
      .DisplayBuffer(DisplayBuffer)
      );

   LCD lcd_instance
     (
      .clk(clk),
      .chars(DisplayBuffer),
      .lcd_rs(lcd_rs), .lcd_rw(lcd_rw),. lcd_e(lcd_e),. lcd_4(lcd_4),. lcd_5(lcd_5),. lcd_6(lcd_6), .lcd_7(lcd_7)
      );
   

endmodule

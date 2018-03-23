`timescale 1ns/1ps
`include "dispConsts.svh"

module draw(clk_25M, charBuffer, hSync, vSync, red, green, blue);
   			 
   input clk_25M;
   input [ASCII_SIZE-1:0] charBuffer [CHARS_VERT-1:0][CHARS_HORZ-1:0];
   
   output wire hSync, vSync;
   output reg [3-1:0] red, green, blue;

   // Text mode parameters
      
   // Opposite order of each array element to keep ROM human readable
   reg [0:ASCII_SIZE-1] fontRom [ROM_SIZE-1:0];

   wire 	       draw;
   wire [32-1:0]       hPos, vPos;
   hvSyncGen hvInst(clk_25M, hSync, vSync, draw, hPos, vPos);
 
   initial begin
       {{red}, {green}, {blue}} = 12'h000;
       // Initialise font ROM
       $readmemb("/home/suyash/vgaCharRom.bin", fontRom);
   end

   function getXYPixel;
      input [32-1:0] hPos, vPos;
      input [0:ASCII_SIZE-1] fontRom [ROM_SIZE-1:0];
      input [8-1:0] 	    charBuffer [CHARS_VERT-1:0][CHARS_HORZ-1:0];

       getXYPixel = fontRom[(charBuffer[vPos>>4][hPos>>3])<<4 + (vPos&4'b111)][hPos&3'b111];
   endfunction // getXYPixel

   always @(hPos, vPos) begin
       //$display("%d:%d", hPos, vPos);
       //{{red}, {green}, {blue}} = {12{getXYPixel(hPos, vPos, fontRom, charBuffer)}};
       {{red}, {green}, {blue}} = {12{fontRom[(charBuffer[vPos/16][hPos/8])*16 + (vPos&4'b1111)][hPos&3'b111]}};
       
       //$display("For hPos: %d vPos: %d, got x: %d y: %d %d %d %d", hPos, vPos, charBuffer[vPos>>4][hPos>>3]<<4 + vPos&4'b1111, hPos&3'b111, vPos>>4, hPos>>4, vPos&4'b1111);
   end
endmodule // draw


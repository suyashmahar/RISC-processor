`timescale 1ns/1ps
`define DEBUG
module hvSyncGen(clk_25M, hSync, vSync, draw, hPos, vPos);
   input clk_25M;   
   output hSync, vSync, draw;
   output [32-1:0] hPos, vPos;
   
`ifdef DEBUG
   parameter FP_H = 48, H = 640, BP_H = 48, RT_H = 96;
   parameter FP_V = 33, V = 480, BP_V = 33, RT_V = 2;
`else
   parameter FP_H = 16, H = 640, BP_H = 48, RT_H = 96;
   parameter FP_V = 10, V = 480, BP_V = 33, RT_V = 2;
`endif
   
   integer hCounter, vCounter;
   
   function genXSync;
      input integer   counter, fp, disp, bp, rt;
       begin : genXSync_block
	   genXSync = (counter > disp + fp) && (counter < disp + fp + rt) 
	     ? 1'b1 : 1'b0;
       end
   endfunction // function

   function genDrawPulse;
      input integer hCounter, vCounter;
      input integer fp_h, h;
      input integer fp_v, v;
       
       if ((hCounter - fp_h < h && hCounter > fp_h) && (vCounter - fp_v < v && vCounter > fp_v)) begin
	   genDrawPulse = 1'b1;
       end else begin
	   genDrawPulse = 1'b0;
       end
   endfunction // genDrawPulse

   assign hPos = (hCounter < H) ? hCounter : 0;
   assign vPos = (vCounter < V) ? vCounter : 0;
   
   assign hSync = genXSync(hCounter, FP_H, H, BP_H, RT_H);
   assign vSync = genXSync(vCounter, FP_V, V, BP_V, RT_V);
   assign draw = genDrawPulse(hCounter, vCounter, FP_H, H, FP_V, V);

   initial begin
       hCounter = 0;
       vCounter = 0;
   end

   always @(posedge (hCounter == 0)) begin
       vCounter = (vCounter == FP_V + V + BP_V + RT_V) ? 1'b0 : vCounter + 1;
   end
   
   always @(posedge clk_25M) begin
       hCounter = (hCounter == FP_H + H + BP_H + RT_H) ? 1'b0 : hCounter + 1;
   end
endmodule // hvSyncGen

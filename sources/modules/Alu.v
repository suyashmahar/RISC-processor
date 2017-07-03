`timescale 1ns / 1ps

module Alu(
    input wire [5:0] alufn,
    input wire [31:0] a,
    input wire [31:0] b,

    output wire [31:0] s,
    output reg [31:0] z,
    output wire [31:0] v,
    output wire [31:0] n
);


endmodule

module AddSub(
    input wire [5:0] alufn,
    input wire [31:0] a,
    input wire [31:0] b,

    output wire [31:0] s,
    output reg [31:0] z,
    output wire [31:0] v,
    output wire [31:0] n
);

   reg [31:0]     xb;

   integer 	i = 0;
   
   always @(b, alufn[0]) begin
      for (i = 0; i < 32; i = i + 1) begin
	xb[i] = b[i] ^ alufn[0];
      end
   end

   assign s = a + xb + alufn[0];

   reg 	   z_loc;
   always @(s) begin
      for (i = 0; i < 31; i = i + 1) begin
         z_loc = z_loc + s[i]; 
      end
      z = z_loc;
   end

   assign v = (a[31] & xb[31] & (~s[31])) + ((~a[31]) & (~xb[31]) & s[31]);
   assign n = s[31]; 

endmodule

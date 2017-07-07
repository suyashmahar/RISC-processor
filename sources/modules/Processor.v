`timescale 1ns / 1ps

module Processor(
   input wire clk,
   input wire RESET
);
   
   wire [31:0] InstAdd;
   wire [31:0] InstData;
   wire [31:0] SextC;
   wire        WERF;
   reg [31:0]  WD;
   wire [31:0] RD1;
   wire [31:0] RD2;
   wire [2:0]  PCSEL;
   wire        RA2SEL;
   wire        ASEL;
   wire        BSEL;
   wire [1:0]  WDSEL;
   wire [5:0]  ALUFN;
   wire [31:0] aluRes;       
   wire        WR;
   wire        WASEL;
   wire [31:0] MemDataOut;
   wire [31:0] a;
   wire [31:0] b;
   wire [31:0] Rc; 

   assign Rc = InstData[25:21];
   
   assign SextC = {{16{InstData[15]}}, InstData[15:0]};

   ProgramCounter #(32) pc_inst (
      .rst_i(RESET), 
      .clk_i(clk), 
      .pc_o(InstAdd) 
   );

   // Connection for ALU using BSEL from CtrlModule
   assign a = RD1;
   assign b = BSEL ? SextC : RD2;
   Alu alu_inst(
      .alufn(ALUFN),
      .a(a),
      .b(b),
      .alu(aluRes),
      .z(),
      .v(),
      .n()
   );

   always @(aluRes, MemDataOut, WDSEL) begin
      case (WDSEL)
	 2'b00:
	   WD = {32{1'b0}};
	 2'b01:
	   WD = aluRes;
	 2'b10:
	   WD = MemDataOut;
	 default:
	   WD = {32{1'b0}};
      endcase // case (WDSEL)
   end // always @ (alu, RD, WDSEL)
   
	
   RegfileModule regFile_inst(
      .clk(clk), 
      .Ra(InstData[20:16]), 
      .Rb(InstData[15:11]), 
      .Rc(InstData[25:21]), 
      .WERF(WERF),                                                
      .RA2SEL(RA2SEL), 
      .WD(WD), 
      .RD1(RD1), 
      .RD2(RD2)
   );
   
   BasicTestMemory mem_inst(
      .clk(clk), 
      .InstAdd(InstAdd/4),
      .DataAdd(aluRes/4),
      .MemDataContent(RD2),
      .DataReadEn(~WR), 
      .DataWriteEn(WR),
      .MemDataOut(MemDataOut), 
      .MemInstOut(InstData)			 
   );

   CtrlLogicModule ctrl_inst(
      .OPCODE(InstData[31:26]),
      .RESET(RESET),	       
      .PCSEL(PCSEL),
      .RA2SEL(RA2SEL),
      .ASEL(ASEL),
      .BSEL(BSEL),
      .WDSEL(WDSEL),
      .ALUFN(ALUFN),
      .WR(WR),
      .WERF(WERF),
      .WASEL(WASEL)
   );
endmodule

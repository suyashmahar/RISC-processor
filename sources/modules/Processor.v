`timescale 1ns / 1ps

module Processor 
  #(
    parameter RstAddr = 32'h80000000,     // Address to jump upon RESET
    parameter XAddr = 32'h80000008,       // Address to jump upon exception
    parameter IllOpAddr = 32'h80000004,    // Address to jump upon execution of illegal Op-code
    parameter XPReg = 5'b11110,           // Register add for storing pc upon exception
    parameter DisplayBufferSize = 256    // Bits
    )(
      input wire 			clk, // Global clock
      input wire 			RESET, // External RESET input
      input wire 			IRQ, // Interrupt
      output wire [DisplayBufferSize-1:0] DisplayBuffer  // Memory output for display 
   );
      
   wire [31:0] 		  InstAdd;      //Address of next instruction to fetch
   wire [31:0] 		 InstData;      // Instruction fetched from memory
   wire [31:0] 		 SextC;		// Gets C from Inst and sign extends it
   wire 		 WERF;		// Write enable for register file
   reg [31:0] 		 WD;	        // Write data for register file
   wire [31:0] 		 RD1;		// Data from 1st register corresponding to Ra
   wire [31:0] 		 RD2;		// Data from 2nd register corresponding to Rb
   wire [2:0] 		 PCSEL;		// Control for mux selecting next PC
   wire 		 RA2SEL;	// Controls mux selecting add. for 2nd reg in regile
   wire 		 ASEL;		// Selects input 'A' for ALU
   wire 		 BSEL;		// Selects input 'B' for ALU
   wire [1:0] 		 WDSEL;		// Selects WD
   wire [5:0] 		 ALUFN;		// alu function 
   wire [31:0] 		 aluRes;       	// Result from ALU
   wire 		 WR;		// Write enable for memory
   wire 		 WASEL;		// Selects write add. for reg file
   wire [31:0] 		 MemDataOut;	// Output from memory (data)
   wire [31:0] 		 a;		// Input 'A' to ALU 
   wire [31:0] 		 b;		// Input 'B' to ALU
   wire [31:0] 		 Rc;		// Add. of C reg 
   wire [31:0] 		 JT;
   wire [31:0] 		 ShftSextC;	// 4*SextC
   wire [31:0] 		 PcIncr;
   wire [31:0] 		 branchOffset;
   wire 		 MEMTYPE;
   wire 		 Z;
   
   assign Rc = InstData[25:21];
   assign SextC = {{16{InstData[15]}}, InstData[15:0]};
   assign ShftSextC = SextC << 2;
   assign JT = {{RD1[31:2]}, {2'b00}};

   assign Z = RD1 == 32'h00000000;

   ProgramCounter #(32) pc_inst 
     (
      .RESET(RESET), 
      .clk(clk),
      .PCSEL(PCSEL),
      .XAddr(XAddr),
      .RstAddr(RstAddr),
      .IllOpAddr(IllOpAddr),
      .IRQ(IRQ),
      .JT(JT&32'hfffffffc),
      .ShftSextC(ShftSextC),
      .pc_o(InstAdd),
      .PcIncr(PcIncr),
      .branchOffset(branchOffset)
      );
   
   // Connection for ALU using BSEL from CtrlModule
   assign a = ASEL ? {{1'b0}, {branchOffset[30:0]}} : RD1;
   assign b = BSEL ? SextC : RD2;
   
   Alu alu_inst
     (
      .alufn(ALUFN),
      .a(a),
      .b(b),
      .alu(aluRes),
      .z(),
      .v(),
      .n()
      );

   always @(aluRes, InstAdd, PcIncr, MemDataOut, WDSEL) begin
       case (WDSEL)
	2'b00:
	  WD = {{InstAdd[31]}, {PcIncr[30:0]}};
	2'b01:
	  WD = aluRes;
	2'b10:
	  WD = MemDataOut;
	default:
	  WD = {32{1'b0}};
      endcase // case (WDSEL)
   end // always @ (alu, RD, WDSEL)
   
   
   RegfileModule regFile_inst
     (
      .clk(clk), 
      .XPReg(XPReg),
      .WASEL(WASEL),
      .Ra(InstData[20:16]), 
      .Rb(InstData[15:11]), 
      .Rc(InstData[25:21]), 
      .WERF(WERF),                                                
      .RA2SEL(RA2SEL), 
      .WD(WD), 
      .RD1(RD1), 
      .RD2(RD2)
      );
   
   SimpleDisplayMemory
     #(
       256 // Display buffer width
       ) mem_inst (
	 .clk(clk), 
	 .InstAdd({{1'b0}, {InstAdd[30:0]}}),
	 .DataAdd(aluRes),
	 .MemDataContent(RD2),
	 .DataReadEn(~WR), 
	 .DataWriteEn(WR),
	 .MemDataOut(MemDataOut), 
	 .MemInstOut(InstData),
	 .DisplayBuffer(DisplayBuffer),
   .MEMTYPE(MEMTYPE)
      );
   
   CtrlLogicModule ctrl_inst
     (
      .OPCODE(InstData[31:26]),
      .RESET(RESET),	       
      .IRQ(IRQ),
      .PCSEL(PCSEL),
      .RA2SEL(RA2SEL),
      .ASEL(ASEL),
      .BSEL(BSEL),
      .WDSEL(WDSEL),
      .ALUFN(ALUFN),
      .MEMTYPE(MEMTYPE),
      .pc_31(InstAdd[31]),
      .WR(WR),
      .WERF(WERF),
      .WASEL(WASEL),
      .Z(Z)
      );
endmodule

`timescale 1ns / 1ps

// This module was manually verified
module CtrlLogicModule(
    input wire [5:0] OPCODE,
    input wire 	     RESET,
    input wire 	     Z,
    input wire 	     IRQ,
		       
    output reg [2:0] PCSEL,
    output reg 	     RA2SEL,
    output reg 	     ASEL,
    output reg 	     BSEL,
    output reg [1:0] WDSEL,
    output reg [5:0] ALUFN,
    output reg 	     WR,
    output reg 	     WERF,
    output reg 	     WASEL
);

   reg [16:0] 	     opcodeROM [63:0];
   wire [5:0] 	     opcode_extended;

   assign opcode_extended = IRQ ? 6'b000000 : OPCODE;
   
   initial begin
       WR = 0;
       WERF = 0;
              
       opcodeROM[6'b000000] = 17'b00000010000000011;
       opcodeROM[6'b000001] = 17'b00000101100000011;
       opcodeROM[6'b000010] = 17'b00001001100000011;
       opcodeROM[6'b000011] = 17'b00001101100000011;
       opcodeROM[6'b000100] = 17'b00010001100000011;
       opcodeROM[6'b000101] = 17'b00010101100000011;
       opcodeROM[6'b000110] = 17'b00011001100000011;
       opcodeROM[6'b000111] = 17'b00011101100000011;
       opcodeROM[6'b001000] = 17'b00100001100000011;
       opcodeROM[6'b001001] = 17'b00100101100000011;
       opcodeROM[6'b001010] = 17'b00101001100000011;
       opcodeROM[6'b001011] = 17'b00101101100000011;
       opcodeROM[6'b001100] = 17'b00110001100000011;
       opcodeROM[6'b001101] = 17'b00110101100000011;
       opcodeROM[6'b001110] = 17'b00111001100000011;
       opcodeROM[6'b001111] = 17'b00111101100000011;
       opcodeROM[6'b010000] = 17'b01000001100000011;
       opcodeROM[6'b010001] = 17'b01000101100000011;
       opcodeROM[6'b010010] = 17'b01001001100000011;
       opcodeROM[6'b010011] = 17'b01001101100000011;
       opcodeROM[6'b010100] = 17'b01010001100000011;
       opcodeROM[6'b010101] = 17'b01010101100000011;
       opcodeROM[6'b010110] = 17'b01011001100000011;
       opcodeROM[6'b010111] = 17'b01011101100000011;
       opcodeROM[6'b011000] = 17'b00000000000110010;   // LD
       opcodeROM[6'b011001] = 17'b00000000010101100;   // ST
       opcodeROM[6'b011010] = 17'b01101001100000011;   
       opcodeROM[6'b011011] = 17'b01101101000000010;   // JMP
       opcodeROM[6'b011100] = 17'b01110001100000011;
       opcodeROM[6'b011101] = 17'b01110111100000010;   // BEQ
       opcodeROM[6'b011110] = 17'b01111000000000010;   // BNE
       opcodeROM[6'b011111] = 17'b01110000001010010;   // LDR
       opcodeROM[6'b100000] = 17'b00000000000001010;   // ADD
       opcodeROM[6'b100001] = 17'b00000100000001010;   // SUB
       opcodeROM[6'b100010] = 17'b10001000000001010;   // MUL    
       opcodeROM[6'b100011] = 17'b10001100000001010;   // DIV
       opcodeROM[6'b100100] = 17'b11001100000001010;   // CMPEQ
       opcodeROM[6'b100101] = 17'b11010100000001010;   // CMPLT  
       opcodeROM[6'b100110] = 17'b11011100000001010;   // CMPLE
       opcodeROM[6'b100111] = 17'b10011101100000011;   
       opcodeROM[6'b101000] = 17'b01100000000001010;   // AND
       opcodeROM[6'b101001] = 17'b01111000000001010;   // OR
       opcodeROM[6'b101010] = 17'b01011000000001010;   // XOR
       opcodeROM[6'b101011] = 17'b10101101100000011;   
       opcodeROM[6'b101100] = 17'b10000000000001010;   // SHL
       opcodeROM[6'b101101] = 17'b10000100000001010;   // SHR
       opcodeROM[6'b101110] = 17'b10001100000001010;   // SRA
       opcodeROM[6'b101111] = 17'b10111101100000011;
       opcodeROM[6'b110000] = 17'b00000000000101010;   // ADDC
       opcodeROM[6'b110001] = 17'b00000100000101010;   // SUBC
       opcodeROM[6'b110010] = 17'b10001000000101010;   // MULC
       opcodeROM[6'b110011] = 17'b10001100000101010;   // DIVC
       opcodeROM[6'b110100] = 17'b11001100000101010;   // CMPEQC
       opcodeROM[6'b110101] = 17'b11010100000101010;   // CMPLTC
       opcodeROM[6'b110110] = 17'b11011100000101010;   // CMPLEC
       opcodeROM[6'b110111] = 17'b11011101100000011;
       opcodeROM[6'b111000] = 17'b01100000000101010;   // ANDC
       opcodeROM[6'b111001] = 17'b01111000000101010;   // ORC
       opcodeROM[6'b111010] = 17'b01011000000101010;   // XORC
       opcodeROM[6'b111011] = 17'b11101101100000011;   
       opcodeROM[6'b111100] = 17'b10000000000101010;   // SHLC
       opcodeROM[6'b111101] = 17'b10000100000101010;   // SHRC
       opcodeROM[6'b111110] = 17'b10001100000101010;   // SRAC
       opcodeROM[6'b111111] = 17'b11111101100000011;
       
    end

    // ROM description
    // <ALUFN-6><PCSEL-3><RA2SEL><ASEL><BSEL><WDSEL-2><WR><WERF><WASL>
   always @(opcode_extended, RESET, Z) begin
      #5
	ALUFN = opcodeROM[opcode_extended][16:11];         
       RA2SEL = opcodeROM[opcode_extended][7];             // ✔
       ASEL = opcodeROM[opcode_extended][6];               
       BSEL = opcodeROM[opcode_extended][5];               // ✔
       WDSEL = opcodeROM[opcode_extended][4:3];            // ✔
       WR = (~RESET) & opcodeROM[opcode_extended][2];      // ✔
       WERF = (~RESET) & opcodeROM[opcode_extended][1];    // ✔
       WASEL = opcodeROM[opcode_extended][0];              
       
       // PCSEL logic for BEQ and BNE due to their dependence
       // on Z
       if (opcode_extended == 6'b011101) begin   // BEQ
	   PCSEL = {{2'b00}, {Z}};               
       end else if (opcode_extended == 6'b011110) begin // BNE
	   PCSEL = {{2'b00}, {~Z}};               
       end else begin
	   PCSEL = opcodeROM[opcode_extended][10:8];
       end

   end // always @ (OPCODE, RESET, Z)
endmodule // CtrlLogicModule


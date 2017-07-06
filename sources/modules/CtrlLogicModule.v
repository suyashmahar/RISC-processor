`timescale 1ns / 1ps

// This module was manually verified
module CtrlLogicModule(
    input wire [6:0]  OPCODE,
    input wire 	      RESET,
		       
    output reg [2:0] PCSEL,
    output reg       RA2SEL,
    output reg       ASEL,
    output reg       BSEL,
    output reg [1:0] WDSEL,
    output reg [5:0] ALUFN,
    output reg       WR,
    output reg       WERF,
    output reg       WASEL
);

    reg [16:0] opcodeROM [63:0];
   
    initial begin
       WR = 0;
       WERF = 0;
              
       opcodeROM[6'b000000] = 17'b00000000000000000;
       opcodeROM[6'b000001] = 17'b00000100000000000;
       opcodeROM[6'b000010] = 17'b00001000000000000;
       opcodeROM[6'b000011] = 17'b00001100000000000;
       opcodeROM[6'b000100] = 17'b00010000000000000;
       opcodeROM[6'b000101] = 17'b00010100000000000;
       opcodeROM[6'b000110] = 17'b00011000000000000;
       opcodeROM[6'b000111] = 17'b00011100000000000;
       opcodeROM[6'b001000] = 17'b00100000000000000;
       opcodeROM[6'b001001] = 17'b00100100000000000;
       opcodeROM[6'b001010] = 17'b00101000000000000;
       opcodeROM[6'b001011] = 17'b00101100000000000;
       opcodeROM[6'b001100] = 17'b00110000000000000;
       opcodeROM[6'b001101] = 17'b00110100000000000;
       opcodeROM[6'b001110] = 17'b00111000000000000;
       opcodeROM[6'b001111] = 17'b00111100000000000;
       opcodeROM[6'b010000] = 17'b01000000000000000;
       opcodeROM[6'b010001] = 17'b01000100000000000;
       opcodeROM[6'b010010] = 17'b01001000000000000;
       opcodeROM[6'b010011] = 17'b01001100000000000;
       opcodeROM[6'b010100] = 17'b01010000000000000;
       opcodeROM[6'b010101] = 17'b01010100000000000;
       opcodeROM[6'b010110] = 17'b01011000000000000;
       opcodeROM[6'b010111] = 17'b01011100000000000;
       opcodeROM[6'b011000] = 17'b01100000000110010;   // LD
       opcodeROM[6'b011001] = 17'b01100100010101100;   // ST
       opcodeROM[6'b011010] = 17'b01101000000000000;   
       opcodeROM[6'b011011] = 17'b01101100000001010;   // JMP
       opcodeROM[6'b011100] = 17'b01110000000000000;
       opcodeROM[6'b011101] = 17'b01110100000001010;   // BEQ
       opcodeROM[6'b011110] = 17'b01111000000001010;   // BNE
       opcodeROM[6'b011111] = 17'b01111100000001010;   // LDR
       opcodeROM[6'b100000] = 17'b10000000000001010;   // ADD
       opcodeROM[6'b100001] = 17'b10000100000001010;   // SUB
       opcodeROM[6'b100010] = 17'b10001000000001010;   // MUL    
       opcodeROM[6'b100011] = 17'b10001100000001010;   // DIV
       opcodeROM[6'b100100] = 17'b10010000000001010;   // CMPEQ
       opcodeROM[6'b100101] = 17'b10010100000001010;   // CMPLT  
       opcodeROM[6'b100110] = 17'b10011000000001010;   // CMPLE
       opcodeROM[6'b100111] = 17'b10011100000000000;   
       opcodeROM[6'b101000] = 17'b10100000000001010;   // AND
       opcodeROM[6'b101001] = 17'b10100100000001010;   // OR
       opcodeROM[6'b101010] = 17'b10101000000001010;   // XOR
       opcodeROM[6'b101011] = 17'b10101100000000000;   
       opcodeROM[6'b101100] = 17'b10110000000001010;   // SHL
       opcodeROM[6'b101101] = 17'b10110100000001010;   // SHR
       opcodeROM[6'b101110] = 17'b10111000000001010;   // SRA
       opcodeROM[6'b101111] = 17'b10111100000000000;
       opcodeROM[6'b110000] = 17'b11000000000101010;   // ADDC
       opcodeROM[6'b110001] = 17'b11000100000101010;   // SUBC
       opcodeROM[6'b110010] = 17'b11001000000101010;   // MULC
       opcodeROM[6'b110011] = 17'b11001100000101010;   // DIVC
       opcodeROM[6'b110100] = 17'b11010000000101010;   // CMPEQC
       opcodeROM[6'b110101] = 17'b11010100000101010;   // CMPLTC
       opcodeROM[6'b110110] = 17'b11011000000101010;   // CMPLEC
       opcodeROM[6'b110111] = 17'b11011100000000000;
       opcodeROM[6'b111000] = 17'b11100000000101010;   // ANDC
       opcodeROM[6'b111001] = 17'b11100100000101010;   // ORC
       opcodeROM[6'b111010] = 17'b11101000000101010;   // XORC
       opcodeROM[6'b111011] = 17'b11101100000000000;   
       opcodeROM[6'b111100] = 17'b11110000000101010;   // SHLC
       opcodeROM[6'b111101] = 17'b11110100000101010;   // SHRC
       opcodeROM[6'b111110] = 17'b11111000000101010;   // SRAC
       opcodeROM[6'b111111] = 17'b11111100000000000;
       
    end

    // ROM description
    // <ALUFN-6><PCSEL-3><RA2SEL><ASEL><BSEL><WDSEL-2><WR><WERF><WASL>
   always @(OPCODE, RESET) begin
      ALUFN = opcodeROM[OPCODE][16:11];          // ✔
      PCSEL = opcodeROM[OPCODE][10:8];           // N/U
      RA2SEL = opcodeROM[OPCODE][7];             // ✔
      ASEL = opcodeROM[OPCODE][6];               // N/U
      BSEL = opcodeROM[OPCODE][5];               // ✔
      WDSEL = opcodeROM[OPCODE][4:3];            // ✔
      WR = (~RESET) & opcodeROM[OPCODE][2];      // ✔
      WERF = (~RESET) & opcodeROM[OPCODE][1];    // ✔
      WASEL = opcodeROM[OPCODE][0];              // N/U
   end
   

endmodule

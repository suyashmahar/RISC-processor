; (C) 2017, Suyash Mahar
; This content is licensed under 'MIT License'

; Simple program for RISC-Processor
;   This program display powers of two starting from 2^0
;
; Technical details
; > Display buffer starts from 0x000003F7 and ends at 0x000003FF (inclusive)
; > DB(Display buffer) is 4x4 bytes (32x4 = 128 bits) wide
; > Contents will be start displaying as soon as value is written to 
;   0x000003FF
; > Memory location 0x000003F8 is used as a counter
; > Buffer content is displayed as hexadecimal representation

. = 0       ; Start from 0

; Implementation specific details
;   Jump to 8x00000000 on reset
;   Jump to 8x00000004 on Illegal Instruction
;   Jump to 8x0000000c on interrupts
; RESET
    BR Start            ; RESET
    BR IllInst          ; Illegal instruction 
    BR IRQ              ; IRQ
      
; Reset on execution of illegal instruction
IllInst:
    BR Start 

; Handles softare interrupts
IRQ:
    CMPEQC %r26, 0x1, %r25 
    BNE 25, PrintRout, %r31     ; Branch to Print Routine if value at 
                                ; r26 is 1
	BR Start 

; Print routine passes contents of r25 to 
; display buffer.
PrintRout:                                
    STV %r24, 0x0, %r31 
	JMP %r30, %r31 

; Main execution part of program
Start:
    ;ADDC %r31, 0x1, %r24     ; Initialize r24 with 1
    ADDC %r31, 0x1, %r26     ; Store 1 in r24 for print call
    loop:
        ADD %r24, %r24, %r24      ; Calculate next power of 2
        BR IRQ, r30            ; Print current number
        BNE %r24, loop, %r31     ; If %r24 is 0, change it to 1
		ADDC %r31, 1, %r24       ;   by adding 1 to it 
		BRloop                 ; loop again ;-)

LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0
LONG 0

.include "beta.uasm"
;  Simple Printing
; ~-~-~-~-~-~-~-~-~-~-~-~-
;  Stack starts from 0xC00
; ~-~-~-~-~-~-~-~-~-~-~-~-


. = 0       ;  Start from 0

;  Implementation specific details
;    Jump to 8x00000000 on reset
;    Jump to 8x00000004 on Illegal Instruction
;    Jump to 8x0000000c on interrupts
;  RESET
    BR Start            ; RESET
    BR IllInst          ; Illegal instruction 
    BR IRQ              ; IRQ
       
;  Reset on execution of illegal instruction
IllInst:
    BR Start 

; Handles softare interrupts
IRQ:
    BR Start 

ascii_data_ = .
    LONG 0x30   ; 0
    LONG 0x31   ; 1
    LONG 0x32   ; 2
    LONG 0x33   ; 3
    LONG 0x34   ; 4
    LONG 0x35   ; 5
    LONG 0x36   ; 6
    LONG 0x37   ; 7
    LONG 0x38   ; 8
    LONG 0x39   ; 9

    LONG 0x61   ; a
    LONG 0x62   ; b
    LONG 0x63   ; c
    LONG 0x64   ; d
    LONG 0x65   ; e
    LONG 0x66   ; f
    
; Prints Least significant 4 bits of %r25 
; after converting them to ASCII    
printNibble_:
    PUSH %r25
    ANDC %r25, 0xf, %r25   ;  Set digits other than [3:0] as 0
    SHLC %r25, 0x2, %r25
	LD %r25, ascii_data_, %r25   ;  Load ascii value of last 4 bits
    STV %r25, 0x0, %r24 ;  Store ASCII value at next display memory location
    POP %r25
    JMP LP

;  r35 contains character to print 
;  %r24 contains position of character in display
PrintInt:
    PUSH %r23
    PUSH %r24
    PUSH LP

    ;  Initialize %r24 to 0 
    ADDC %r31, 28, %r24
    
    ;  Prints the number in hex form nibble by nibble 
    print_int_loop:
        BR printNibble_, LP
        SHRC %r25, 0x4, %r25
        ADDC %r24, -4, %r24    ;  Increment %24 for next vid mem location
        CMPLTC %r24, 0x0, %r23
        BEQ %r23, print_int_loop, %r31
    
    POP LP
    POP %r24
    POP %r23

    JMP LP
     
;  Main execution part of program
Start:
    ADDC %r31, 0xc00, SP    ;  Starts stack from 0xc00
    ADDC %r31, 0xc00, BP    

    ;  Print '000001ea'
    ADDC %r31, 0x01ea, %r25
    BR PrintInt, LP

    ; Enter infinte loop
	halt_loop:  
		ADDC %R31, 0x0, %R31
		BEQ %r31, halt_loop, %r31
	
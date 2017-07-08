# Copyright 2017 Suyash Mahar

# Disassembler for beta (MIT-6.004 processor)

# Usage:
#   1. Place instructions compiled to hex in "program_file.txt"
#   2. Run the script within same directory using `python2.7 disassembler.py`

# Note:
#   Line starting with '#' is treated as a comment
import re

opcodes = \
""".       .       .       .       .       .       .       .
.       .       .       .       .       .       .       .
.       .       .       .       .       .       .       .
LD      ST      .       JMP     .       BEQ     BNE     LDR
ADD     SUB     MUL     DIV     CMPEQ   CMPLT   CMPL    .
AND     OR      XOR     .       SHL     SHR     SRA     .
ADDC    SUBC    MULC    DIVC    CMPEQC  CMPLTC  CMPLEC  .
ANDC    ORC     XORC    .       SHLC    SHRC    SRAC    .
"""

PROG_FILE = "program_file.txt"

rr = re.compile(r"[^\s]+", re.VERBOSE)

# Read opcodes to single dimensional array
opcodes = rr.findall(opcodes)

# File containing hex values
prog = str.split(open(PROG_FILE, 'r').read(), "\n")

def get_opcode_from_bin(opcode_bin):
    i = int(opcode_bin, 2)
    res = (opcodes[i])
    return (res, res == ".")
for line in prog:
    # Ignore line if is a comment i.e. '#'
    if (line[0] == "#"):
        continue

    line = bin(int(line, 16))[2:].zfill(32)
    [opcode, isInvalidOpCode] = get_opcode_from_bin(line[0:6])
    
    isWithLiteral = opcode[-1] == "C";

    rc = line[6:11]
    ra = line[11:16]

    # print "rc=" + rc + " ra=" + ra
    if (isInvalidOpCode == True):
        print "Illegal opcode: 0b" + line
    else:
        if (isWithLiteral):
            literal = line[-16:]
            print opcode + " %R" + str(int(ra, 2)) + ", " + str(int(literal, 2)) + ", %R" + str(int(rc, 2)) + ""
        else:
            rb = line[17:22]
            print opcode + " %R" + str(int(ra, 2)) + ", %R" + str(int(rb, 2)) + ", %R" + str(int(rc, 2)) + ""

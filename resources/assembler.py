import re
import string
import sys

""" Define enum """ 
def enum(**enums):
    return type('Enum', (), enums)

# Defines error_codes
Errors = enum(ILLOP = 0, ILLREG=1)

# symbol table
sym_table = {}

""" Compiles op codes into single dimensional array """
def compile_opcodes():
    # Define opcodes
    opcodes = \
    """.       .       .       .       .       .       .       .
    .       .       .       .       .       .       .       .
    .       .       .       .       .       .       .       .
    LD      ST      .       JMP     .       BEQ     BNE     LDR
    ADD     SUB     MUL     DIV     CMPEQ   CMPLT   CMPLE   .
    AND     OR      XOR     .       SHL     SHR     SRA     .
    ADDC    SUBC    MULC    DIVC    CMPEQC  CMPLTC  CMPLEC  .
    ANDC    ORC     XORC    .       SHLC    SHRC    SRAC    .
    LONG"""

    rr = re.compile(r"[^\s]+", re.VERBOSE)

    # Read opcodes to single dimensional array
    return rr.findall(opcodes)

"""
    Removes all comments from program
"""
def strip_comments(prog_content):
    # temp = re.sub(r'[\n]+', '', prog_content)
    return re.sub(r';.*', '', prog_content)

""" Adds label with address to symbol table """
def add_to_sym_table(label, address):
    global sym_table
    sym_table[label] = address

""" Converts bits to int to 2's complement representation """
def twos_complement(in_int, bits):
    s = bin(in_int & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)

""" Converts literal to hex if it is decimal, returns int """
def fix_literal(literal):
    if (literal[0:2] == "0x"):
        return twos_complement(int(literal[2:], 16), 16)
    else:
        return twos_complement(int(literal), 16) 

""" Returns label offset from current address """
def get_label_offset(label, addr):
    global sym_table
    return fix_literal(addr - sym_table[label])

"""
    Converts one instruction into corresponding 
    machine language instruction
"""
def convert_inst(instr, opcodes, addr):
    keyword_arr = re.split(r', |,| ', instr)
    result ='{0:06b}'.format(opcodes.index(keyword_arr[0].upper()))

    reg_used = instr.count('%')   
    
    if (keyword_arr[0] == "LONG"):
        result = '{0:032b}'.format(int(fix_literal(keyword_arr[1]), 2))
    elif (len(keyword_arr) == 3): # JMP / LDR
        if (reg_used == 2):
            result += '{0:05b}'.format((keyword_arr[2])[2:]) # Rc
            result += '{0:05b}'.format((keyword_arr[1])[2:]) # Ra
            result += '0'*16
        else:
            result += '{0:05b}'.format((keyword_arr[2])[2:]) # Rc
            result += '11111'
            result += get_label_offset(keyword_arr[1], addr)
    elif (len(keyword_arr) == 4):
        if (reg_used == 2): # R1 literal R2
            if (keyword_arr[0] == 'ST'): #ST
                result += '{0:05b}'.format(int((keyword_arr[1])[2:])) # Rc
                result += '{0:05b}'.format(int((keyword_arr[3])[2:])) # Ra
                result += fix_literal(keyword_arr[2]) # literal
            elif ((keyword_arr[0] == 'BEQ') | (keyword_arr[0] == 'BNE')):
                result += '{0:05b}'.format(int((keyword_arr[1])[2:])) # Rc
                result += '{0:05b}'.format(int((keyword_arr[3])[2:])) # Ra
                result += get_label_offset(keyword_arr[2], addr) # literal
            else:
                result += '{0:05b}'.format(int((keyword_arr[3])[2:])) # Rc
                result += '{0:05b}'.format(int((keyword_arr[1])[2:])) # Ra
                result += fix_literal(keyword_arr[2]) # literal
        else:
            result += '{0:05b}'.format(int((keyword_arr[3])[2:])) # Rc
            result += '{0:05b}'.format(int((keyword_arr[1])[2:])) # Ra
            result += '{0:05b}'.format(int((keyword_arr[2])[2:])) # Ra
            result += '0'*11 # padding
    return result

"""
    Error handling
"""
def handle_error(error_code, instruction):
    if (error_code == Errors.ILLOP):
        print "Illegal op code : " + str(instruction)
    elif (error_code == Errors.ILLREG):
        print "Illegal reg index : " + str(instruction)
    exit()

"""
    Entry point of script
"""
def main(file_name):
    # Load content of file and strip all comments
    program_content = open(file_name, 'r').read()
    program_content = strip_comments(program_content)
    program_content = re.sub(r'\n+', '\n', program_content)
    program_content = re.sub(r' +', ' ', program_content)
    program_content = re.sub(r'[ \t]+', ' ', program_content)

    # Compile opcodes to single dimension array
    opcodes = compile_opcodes()

    program_arr = re.split(r'\n', program_content)

    cur_address = 0
    for instr in program_arr:
        if (instr[0] == "."):
            add_to_sym_table(instr[1:], cur_address)
        else:
            print '{0:08x}'.format(int(convert_inst(instr, opcodes, cur_address), 2))
            cur_address += 4    # Increment current address by 4

# Start here
for arg in sys.argv[1:]:
    main(arg)

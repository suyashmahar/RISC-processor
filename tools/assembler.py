import re
import sys

""" Define enum """
def enum(**enums):
    return type('Enum', (), enums)

# Defines error_codes
Errors = enum(ILLOP = 0, ILLREG=1)

""" Compiles op codes into single dimensional array """
def compile_opcodes():
    # Define opcodes
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

    rr = re.compile(r"[^\s]+", re.VERBOSE)

    # Read opcodes to single dimensional array
    return rr.findall(opcodes)

"""
    Removes all comments from program
"""
def strip_comments(prog_content):
    # temp = re.sub(r'[\n]+', '', prog_content)
    return re.sub(r';.*', '', prog_content)

""" Returns address for label """
def get_literal(label):
    return '000000000000000'

"""
    Converts one instruction into corresponding 
    machine language instruction
"""
def convert_inst(instr, opcodes):
    keyword_arr = re.split(r', |,| ', instr)
    result ='{0:06b}'.format(opcodes.index(keyword_arr[0].upper()))

    reg_used = instr.count('%')   
    
    if (len(keyword_arr) == 3): # JMP / LDR
        if (reg_used == 2):
            result += '{0:05b}'.format((keyword_arr[2])[2:]) # Rc
            result += '{0:05b}'.format((keyword_arr[1])[2:]) # Ra
            result += '0000000000000000'
        else:
            result += '{0:05b}'.format((keyword_arr[2])[2:]) # Rc
            result += '11111'
            result += get_literal(keyword_arr[1])
    elif (len(keyword_arr) == 4):
        if (reg_used == 2): # R1 literal R2
            if (keyword_arr[0] == 'ST'): #ST
                result += '{0:05b}'.format(int((keyword_arr[1])[2:])) # Rc
                result += '{0:05b}'.format(int((keyword_arr[3])[2:])) # Ra
                result += '{0:016b}'.format(int(keyword_arr[2])) # literal
            elif (keyword_arr[0] == 'BEQ' | keyword_arr[0] == 'BNE'):
                result += '{0:05b}'.format(int((keyword_arr[1])[2:])) # Rc
                result += '{0:05b}'.format(int((keyword_arr[3])[2:])) # Ra
                result += get_literal(keyword_arr[2]) # literal
            else:
                result += '{0:05b}'.format(int((keyword_arr[3])[2:])) # Rc
                result += '{0:05b}'.format(int((keyword_arr[1])[2:])) # Ra
                result += '{0:016b}'.format(int(keyword_arr[2])) # literal
        else:
            result += '{0:05b}'.format(int((keyword_arr[3])[2:])) # Rc
            result += '{0:05b}'.format(int((keyword_arr[1])[2:])) # Ra
            result += '{0:05b}'.format(int((keyword_arr[2])[2:])) # Ra
            result += '00000000000'
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
    # Compile opcodes to single dimension array
    opcodes = compile_opcodes()

    for instr in re.split(r'\n', program_content):
        print convert_inst(instr, opcodes)

# Start here
for arg in sys.argv[1:]:
    main(arg)

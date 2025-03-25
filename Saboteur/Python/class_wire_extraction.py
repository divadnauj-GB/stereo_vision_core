import re

# ---------------------------------------------------------------------------------------------------------------------------------
# Bug fix: Number of bits of the signal. Previously only check MSB. Now it finds MSB and LSB then calculate # of bits.
# New method was added: get_MSB()
# ---------------------------------------------------------------------------------------------------------------------------------
# This class was modified for SEU fault. Because now we want to extract signals defined as "reg".
# ---------------------------------------------------------------------------------------------------------------------------------
# This class was modified in version-3. Extracting wire or input names were changes. No longer compare length of the string after 
# "substrings = wire_string.split()". "process_string()" function were changed completely.
#
# Previous class contain following in "process_string()":
#        # Check for valid number of substrings
#        if len(substrings) < 3:
#            # Single-bit wire
#            self.name = substrings[1].replace(';', '')
#            self.numBit = 1
#        else:
#            # Multiple-bit wire
#            self.name = substrings[2].replace(';', '')  # Extract the name
#            # Extract the bit number from the brackets
#            numBit_str = re.search(r'\[(\d+):\d+\]', substrings[1])
#            if numBit_str:
#               self.numBit = int(numBit_str.group(1)) + 1
#  
# Reason: Some wire definition varies from netlist to netlist.
# ie:
# "wire \ghdl_gen_07_[3681] ;"  -> this will not be counted in previous function. because before ";" there is space which make length 3
# therefore it cant get name for 1-bit signal.
# New version extract signal according to characters. It now search for curle bracket if not found it is 1-bit signal. then search for name
# as the last string in the line 
# DONT FORGET: The code captures MSB for the length and does not check MSB. ie. [11:x] it capture 11 and do not interested in x.
# ---------------------------------------------------------------------------------------------------------------------------------
# This class is used for extracting wire's name and number of bits in given line in the file.
# exp:
# wire [2:0] _001_;
# for this string it exract "_001_" and 2. Then save as struct. However number of bits is 2+1=3. it saves 3.
# ---------------------------------------------------------------------------------------------------------------------------------

class WireInfo:
    def __init__(self, wire_string):
        self.name = None
        self.numBit = None
        self.MSB = None
        self.type = None
        self.lineNum = None
        self.process_string(wire_string)
    
    def process_string(self, wire_string):
        # Remove ';'
        wire_string = wire_string.strip().replace(';', '')
        
        # Check for bit range using regex
        match = re.search(r'\[(\d+):(\d+)\]', wire_string)
        if match:
            n, m = int(match.group(1)), int(match.group(2))
            self.numBit = abs(n - m) + 1  # Extract MSB and LSB to calculate width
            self.MSB = n
        else:
            self.numBit = 1  # Default to 1 if no range is defined
            self.MSB = 0

        # Extract name after removing "wire" or "input" or "reg" and bit range
        name_match = re.search(r'(wire|reg|input)(?:\s+\[\d+:\d+\])?\s+(\\?\S+)', wire_string)
        if name_match:
            self.type = name_match.group(1)
            remaining_string = name_match.group(2)
            # Get the last word after whitespace
            self.name = remaining_string
    
    def get_name(self):
        return self.name
    
    def get_numBit(self):
        return self.numBit

    def get_MSB(self):
        return self.MSB
    
    def get_type(self):
        return self.type

    def get_lineNum(self):
        return self.lineNum
MOV variable, 12
MOV variable, 7
CMP variable, variable
JG L0
MOV t0, 0
JMP L1
L0:
MOV t0, 1
L1:
PRINT x
PRINT y
CMP expression, 0
JE L2
JMP L3
L2:
L3:
MOV AX, expression
RET

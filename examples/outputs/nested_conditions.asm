CMP variable, variable
JG L0
MOV t0, 0
JMP L1
L0:
MOV t0, 1
L1:
MOV AX, expression
RET
MOV AX, expression
RET
CMP expression, 0
JE L2
JMP L3
L2:
L3:
MOV variable, 20
MOV variable, 35
MOV variable, factor
CMP variable, 25
JG L4
MOV t1, 0
JMP L5
L4:
MOV t1, 1
L5:
PRINT z
PRINT x
CMP expression, 0
JE L6
JMP L7
L6:
L7:
MOV AX, expression
RET

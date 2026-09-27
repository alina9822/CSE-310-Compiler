MOV variable, 0
MOV variable, 0
CMP variable, 6
JL L0
MOV t0, 0
JMP L1
L0:
MOV t0, 1
L1:
MOV t1, variable
MUL t1, 3
MOV variable, t1
CMP variable, 8
JG L2
MOV t2, 0
JMP L3
L2:
MOV t2, 1
L3:
MOV t3, variable
ADD t3, variable
MOV variable, t3
MOV t4, variable
ADD t4, 1
MOV variable, t4
CMP expression, 0
JE L4
JMP L5
L4:
L5:
MOV t5, variable
ADD t5, 1
MOV variable, t5
L6:
CMP expression, 0
JE L7
L7:
PRINT total
MOV AX, expression
RET

MOV t0, variable
ADD t0, variable
MOV AX, expression
RET
MOV variable, 0
MOV variable, 0
CMP variable, 5
JL L0
MOV t1, 0
JMP L1
L0:
MOV t1, 1
L1:
MOV t2, variable
ADD t2, factor
MOV variable, t2
MOV t3, variable
ADD t3, 1
MOV variable, t3
L2:
CMP expression, 0
JE L3
L3:
PRINT total
MOV AX, expression
RET

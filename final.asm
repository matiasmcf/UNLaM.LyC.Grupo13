.MODEL LARGE
.386
.STACK 200h
.DATA
;...... Agregar data
.CODE
MOV AX,@DATA
MOV DS,AX
MOV R1, _b
MUL R1, _c
MOV @aux1, R1
MOV R1, _a
ADD R1, @aux1
MOV @aux2, R1
MOV R1, _e
ADD R1, _f
MOV @aux3, R1
MOV R1, _d
DIV R1, @aux3
MOV @aux4, R1
MOV R1, @aux2
SUB R1, @aux4
MOV @aux5, R1
MOV R1, @aux5
ADD R1, _20
MOV @aux6, R1
MOV R1, @aux6
MOV _z, R1
	mov AX,4c00h
	INT 21h
END

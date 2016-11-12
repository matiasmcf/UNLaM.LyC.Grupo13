include macros2.asm
include number.asm

.MODEL LARGE
.STACK 200h
.386
.387
.DATA

	MAXTEXTSIZE equ 50
	@_asd 	DW 4 dup (0)
	@_abc 	DW 5 dup (0)
	@_a 	DD 0.0
	@_b 	DD 0.0
	@_z 	DD 0.0
	@_x 	DD 0.0
	@_c 	DB MAXTEXTSIZE dup (?),'$'
	@_d 	DB MAXTEXTSIZE dup (?),'$'
	@_e 	DD 0.0
	@_g 	DD 0.0
	@_h 	DD 0.0
	@_4 	DW 4
	@_5 	DW 5
	@_Inicio_del_programa 	DB "Inicio del programa",'$',31 dup(?)
	@_3p5 	DD 3.5
	@_g_esd 	DB "g es:",'$',45 dup(?)
	@_10 	DW 10
	@_a_esd 	DB "a es:",'$',45 dup(?)
	@_20 	DW 20
	@_b_esd 	DB "b es:",'$',45 dup(?)
	@_cadena 	DB "cadena",'$',44 dup(?)
	@_c_esd 	DB "c es:",'$',45 dup(?)
	@_2 	DW 2
	@_resultado_de_la_expresion_esd 	DB "resultado de la expresion es:",'$',21 dup(?)
	@__de_prueba 	DB " de prueba",'$',40 dup(?)
	@_d_esd 	DB "d es:",'$',45 dup(?)
	@_e_esd 	DB "e es:",'$',45 dup(?)
	@_1 	DW 1
	@_0 	DW 0
	@_a_es_igual_a_cero 	DB "a es igual a cero",'$',33 dup(?)
	@_a_es_distinto_de_cero 	DB "a es distinto de cero",'$',29 dup(?)
	@_asdC2C_esd 	DB "asd[2] es:",'$',40 dup(?)
	@_3 	DW 3
	@_50 	DW 50
	@_70 	DW 70
	@_Vector_asdCbC 	DB "Vector asd[b]",'$',37 dup(?)
	@_fuera_de_rango_C1P4C 	DB "fuera de rango [1;4]",'$',30 dup(?)
	@_Cancelando_ejecucionppp 	DB "Cancelando ejecucion...",'$',27 dup(?)
	@_60 	DW 60
	@_asdCbC_esd 	DB "asd[b] es:",'$',40 dup(?)
	@_15 	DW 15
	@_10_mas_asdC2C_mas_15_esd 	DB "10 mas asd[2] mas 15 es:",'$',26 dup(?)
	@_4p0 	DD 4.0
	@_6p0 	DD 6.0
	@_7p0 	DD 7.0
	@_8p0 	DD 8.0
	@_9p0 	DD 9.0
	@_3p0 	DD 3.0
	@_AVG_esd 	DB "AVG es:",'$',43 dup(?)
	@_21 	DW 21
	@_asdC2C_menor_a_21 	DB "asd[2] menor a 21",'$',33 dup(?)
	@_asdC2C_mayor_o_igual_a_21 	DB "asd[2] mayor o igual a 21",'$',25 dup(?)
	@_avg_mayor_a_asdC2C 	DB "avg mayor a asd[2]",'$',32 dup(?)
	@_avg_menor_o_igual_a_asdC2C 	DB "avg menor o igual a asd[2]",'$',24 dup(?)
	@_Fin_del_programa 	DB "Fin del programa",'$',34 dup(?)
	@_auxR0 	DD 0.0
	@_auxR1 	DD 0.0
	@_auxR2 	DD 0.0
	@_auxR3 	DD 0.0
	@_auxR4 	DD 0.0
	@_auxR5 	DD 0.0
	@_auxR6 	DD 0.0
	@_auxR7 	DD 0.0
	@_auxR8 	DD 0.0
	@_auxR9 	DD 0.0
	@_auxR10 	DD 0.0
	@_auxR11 	DD 0.0
	@_auxR12 	DD 0.0
	@_auxR13 	DD 0.0
	@_auxR14 	DD 0.0
	@_auxR15 	DD 0.0
	@_auxR16 	DD 0.0
	@_auxR17 	DD 0.0
	@_auxR18 	DD 0.0
	@_auxR19 	DD 0.0
	@_auxR20 	DD 0.0
	@_auxR21 	DD 0.0
	@_auxR22 	DD 0.0
	@_auxR23 	DD 0.0
	@_auxR24 	DD 0.0
	@_auxR25 	DD 0.0
	@_auxR26 	DD 0.0
	@_auxR27 	DD 0.0
	@_auxR28 	DD 0.0
	@_auxR29 	DD 0.0
	@_auxR30 	DD 0.0
	@_auxR31 	DD 0.0
	@_auxR32 	DD 0.0
	@_auxR33 	DD 0.0
	@_auxR34 	DD 0.0
	@_auxR35 	DD 0.0
	@_auxR36 	DD 0.0
	@_auxR37 	DD 0.0
	@_auxE0 	DW 0
	@_auxE1 	DW 0
	@_auxE2 	DW 0
	@_auxE3 	DW 0
	@_auxE4 	DW 0
	@_auxE5 	DW 0
	@_auxE6 	DW 0
	@_auxE7 	DW 0
	@_auxE8 	DW 0
	@_auxE9 	DW 0
	@_auxE10 	DW 0
	@_auxE11 	DW 0
	@_auxE12 	DW 0
	@_auxE13 	DW 0
	@_auxE14 	DW 0
	@_auxE15 	DW 0
	@_auxE16 	DW 0
	@_auxE17 	DW 0
	@_auxE18 	DW 0
	@_auxE19 	DW 0
	@_auxE20 	DW 0
	@_auxE21 	DW 0
	@_auxE22 	DW 0
	@_auxE23 	DW 0
	@_auxE24 	DW 0
	@_auxE25 	DW 0
	@_auxE26 	DW 0
	@_auxE27 	DW 0
	@_auxE28 	DW 0
	@_auxE29 	DW 0
	@_auxE30 	DW 0
	@_auxE31 	DW 0
	@_auxE32 	DW 0
	@_auxE33 	DW 0
	@_auxE34 	DW 0
	@_auxE35 	DW 0
	@_auxE36 	DW 0
	@_auxE37 	DW 0

.CODE
.startup
	mov AX,@DATA
	mov DS,AX

	FINIT

;SALIDA POR CONSOLA
	displayString 	@_Inicio_del_programa
	newLine 1
;ASIGNACION REAL
	fld 	@_3p5
	fstp 	@_g
;SALIDA POR CONSOLA
	displayString 	@_g_esd
	newLine 1
;SALIDA POR CONSOLA
	displayFloat 	@_g,3
	newLine 1
;ASIGNACION ENTERO
	fild 	@_10
	fistp 	@_a
;SALIDA POR CONSOLA
	displayString 	@_a_esd
	newLine 1
;SALIDA POR CONSOLA
	displayInteger 	@_a,3
	newLine 1
;ASIGNACION ENTERO
	fild 	@_20
	fistp 	@_b
;SALIDA POR CONSOLA
	displayString 	@_b_esd
	newLine 1
;SALIDA POR CONSOLA
	displayInteger 	@_b,3
	newLine 1
;ASIGNACION CADENA
	mov ax, @DATA
	mov ds, ax
	mov es, ax
	mov si, OFFSET	@_cadena
	mov di, OFFSET	@_c
	call copiar
;SALIDA POR CONSOLA
	displayString 	@_c_esd
	newLine 1
;SALIDA POR CONSOLA
	displayString 	@_c
	newLine 1
;SUMA DE ENTEROS
	fild 	@_b
	fiadd 	@_10
	fistp 	@_auxE0
;RESTA DE ENTEROS
	fild 	@_4
	fisubr 	@_10
	fistp 	@_auxE1
;DIVISION DE ENTEROS
	fild 	@_auxE1
	fidivr 	@_auxE0
	fistp 	@_auxE2
;MULTIPLICACION DE ENTEROS
	fild 	@_2
	fimul 	@_5
	fistp 	@_auxE3
;SUMA DE ENTEROS
	fild 	@_auxE3
	fiadd 	@_auxE2
	fistp 	@_auxE4
;ASIGNACION ENTERO
	fild 	@_auxE4
	fistp 	@_a
;SALIDA POR CONSOLA
	displayString 	@_resultado_de_la_expresion_esd
	newLine 1
;SALIDA POR CONSOLA
	displayInteger 	@_a,3
	newLine 1
;ASIGNACION CADENA
	mov ax, @DATA
	mov ds, ax
	mov es, ax
	mov si, OFFSET	@__de_prueba
	mov di, OFFSET	@_d
	call copiar
;SALIDA POR CONSOLA
	displayString 	@_d_esd
	newLine 1
;SALIDA POR CONSOLA
	displayString 	@_d
	newLine 1
;ASIGNACION ENTERO
	fild 	@_2
	fistp 	@_e
;SALIDA POR CONSOLA
	displayString 	@_e_esd
	newLine 1
;SALIDA POR CONSOLA
	displayInteger 	@_e,3
	newLine 1
if_0:
	fild 	@_b
	fild 	@_a
	fcomp
	fstsw	ax
	fwait
	sahf
	jae		endif_0
	fild 	@_20
	fild 	@_b
	fcomp
	fstsw	ax
	fwait
	sahf
	jne		endif_0
then_if_0:
repeat_0:
;ASIGNACION ENTERO
	fild 	@_2
	fistp 	@_e
repeat_1:
;RESTA DE ENTEROS
	fild 	@_1
	fisubr 	@_e
	fistp 	@_auxE5
;ASIGNACION ENTERO
	fild 	@_auxE5
	fistp 	@_e
	fild 	@_1
	fild 	@_e
	fcomp
	fstsw	ax
	fwait
	sahf
	ja		repeat_1
end_repeat_1:
;RESTA DE ENTEROS
	fild 	@_1
	fisubr 	@_a
	fistp 	@_auxE6
;ASIGNACION ENTERO
	fild 	@_auxE6
	fistp 	@_a
	fild 	@_0
	fild 	@_a
	fcomp
	fstsw	ax
	fwait
	sahf
	jne		repeat_0
end_repeat_0:
if_1:
	fild 	@_0
	fild 	@_a
	fcomp
	fstsw	ax
	fwait
	sahf
	jne		else_1
then_if_1:
;SALIDA POR CONSOLA
	displayString 	@_a_es_igual_a_cero
	newLine 1
	jmp		endif_1
else_1:
;SALIDA POR CONSOLA
	displayString 	@_a_es_distinto_de_cero
	newLine 1
endif_1:
endif_0:
;PREPARO EL ARRAY PARA TRABAJAR COMO RECEPTOR |
	mov ax, @_2
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
;RESTA DE ENTEROS
	fild 	@_1
	fisubr 	@_2
	fistp 	@_auxE7
;MULTIPLICACION DE ENTEROS
	fild 	@_auxE7
	fimul 	@_4
	fistp 	@_auxE8
;SUMA DE ENTEROS
	fild 	@_auxE8
	fiadd 	@_5
	fistp 	@_auxE9
;ASIGNO ALGO AL ARRAY
	mov ax, @_auxE9
	mov word ptr[bx],ax
;PREPARO EL ARRAY PARA TRABAJAR COMO FACTOR |
	fild @_2
	fistp @_auxE10
	mov ax, @_auxE10
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, word ptr[bx]
	mov @_auxE11, ax
;ASIGNO EL ARRAY A UNA VARIABLE
	fild 	@_auxE11
	fistp 	@_a
;SALIDA POR CONSOLA
	displayString 	@_asdC2C_esd
	newLine 1
;SALIDA POR CONSOLA
	displayInteger 	@_a,3
	newLine 1
;PREPARO EL ARRAY PARA TRABAJAR COMO FACTOR |
	fild @_1
	fistp @_auxE12
	mov ax, @_auxE12
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, word ptr[bx]
	mov @_auxE13, ax
;ASIGNO EL ARRAY A UNA VARIABLE
	fild 	@_50
	fistp 	@_auxE13
;PREPARO EL ARRAY PARA TRABAJAR COMO RECEPTOR |
	mov ax, @_2
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
;MULTIPLICACION DE ENTEROS
	fild 	@_3
	fimul 	@_20
	fistp 	@_auxE14
;ASIGNO ALGO AL ARRAY
	mov ax, @_auxE14
	mov word ptr[bx],ax
;PREPARO EL ARRAY PARA TRABAJAR COMO RECEPTOR |
	mov ax, @_3
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
;ASIGNO ALGO AL ARRAY
	mov ax, @_70
	mov word ptr[bx],ax
;ASIGNACION ENTERO
	fild 	@_2
	fistp 	@_b
if_2:
	fild 	@_4
	fild 	@_b
	fcomp
	fstsw	ax
	fwait
	sahf
	jae		then_if_2
	fild 	@_1
	fild 	@_b
	fcomp
	fstsw	ax
	fwait
	sahf
	jae		end_if_2
then_if_2:
;SALIDA POR CONSOLA
	displayString 	@_Vector_asdCbC
	newLine 1
;SALIDA POR CONSOLA
	displayString 	@_fuera_de_rango_C1P4C
	newLine 1
;SALIDA POR CONSOLA
	displayString 	@_Cancelando_ejecucionppp
	newLine 1
	mov ah, 4ch
	int 21h
end_if_2:
;PREPARO EL ARRAY PARA TRABAJAR COMO RECEPTOR €
	fild @_b
	fistp @_auxE15
	mov ax, @_auxE15
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
;DIVISION DE ENTEROS
	fild 	@_3
	fidivr 	@_60
	fistp 	@_auxE16
;ASIGNO ALGO AL ARRAY
	mov ax, @_auxE16
	mov word ptr[bx],ax
if_3:
	fild 	@_4
	fild 	@_b
	fcomp
	fstsw	ax
	fwait
	sahf
	jae		then_if_3
	fild 	@_1
	fild 	@_b
	fcomp
	fstsw	ax
	fwait
	sahf
	jae		end_if_3
then_if_3:
;SALIDA POR CONSOLA
	displayString 	@_Vector_asdCbC
	newLine 1
;SALIDA POR CONSOLA
	displayString 	@_fuera_de_rango_C1P4C
	newLine 1
;SALIDA POR CONSOLA
	displayString 	@_Cancelando_ejecucionppp
	newLine 1
	mov ah, 4ch
	int 21h
end_if_3:
;PREPARO EL ARRAY PARA TRABAJAR COMO FACTOR €
	fild @_b
	fistp @_auxE17
	mov ax, @_auxE17
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, word ptr[bx]
	mov @_auxE18, ax
;ASIGNO EL ARRAY A UNA VARIABLE
	fild 	@_auxE18
	fistp 	@_a
;SALIDA POR CONSOLA
	displayString 	@_asdCbC_esd
	newLine 1
;SALIDA POR CONSOLA
	displayInteger 	@_a,3
	newLine 1
;PREPARO EL ARRAY PARA TRABAJAR COMO FACTOR |
	fild @_2
	fistp @_auxE19
	mov ax, @_auxE19
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, word ptr[bx]
	mov @_auxE20, ax
;SUMA DE ENTEROS
	fild 	@_auxE20
	fiadd 	@_10
	fistp 	@_auxE21
;SUMA DE ENTEROS
	fild 	@_15
	fiadd 	@_auxE21
	fistp 	@_auxE22
;ASIGNO EL ARRAY A UNA VARIABLE
	fild 	@_auxE22
	fistp 	@_a
;SALIDA POR CONSOLA
	displayString 	@_10_mas_asdC2C_mas_15_esd
	newLine 1
;SALIDA POR CONSOLA
	displayInteger 	@_a,3
	newLine 1
;ASIGNACION REAL
	fld 	@_4p0
	fstp 	@_h
;ASIGNACION REAL
	fld 	@_6p0
	fstp 	@_g
;SUMA DE REALES
	fld 	@_g
	fld 	@_h
	fadd
	fstp 	@_auxR0
;SUMA DE REALES
	fld 	@_8p0
	fld 	@_7p0
	fadd
	fstp 	@_auxR1
;SUMA DE REALES
	fld 	@_9p0
	fld 	@_auxR1
	fadd
	fstp 	@_auxR2
;DIVISION DE REALES
	fld 	@_3p0
	fld 	@_auxR2
	fdivr
	fstp 	@_auxR3
;SUMA DE REALES
	fld 	@_auxR3
	fld 	@_auxR0
	fadd
	fstp 	@_auxR4
;DIVISION DE REALES
	fld 	@_3p0
	fld 	@_auxR4
	fdivr
	fstp 	@_auxR5
;ASIGNACION REAL
	fld 	@_auxR5
	fstp 	@_g
;SALIDA POR CONSOLA
	displayString 	@_AVG_esd
	newLine 1
;SALIDA POR CONSOLA
	displayFloat 	@_g,3
	newLine 1
;PREPARO EL ARRAY PARA TRABAJAR COMO FACTOR |
	fild @_2
	fistp @_auxE23
	mov ax, @_auxE23
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, word ptr[bx]
	mov @_auxE24, ax
;ASIGNO EL ARRAY A UNA VARIABLE
	fild 	@_auxE24
	fistp 	@_a
;SALIDA POR CONSOLA
	displayString 	@_asdC2C_esd
	newLine 1
;SALIDA POR CONSOLA
	displayInteger 	@_a,3
	newLine 1
if_4:
;PREPARO EL ARRAY PARA TRABAJAR COMO FACTOR |
	fild @_2
	fistp @_auxE25
	mov ax, @_auxE25
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, word ptr[bx]
	mov @_auxE26, ax
	fild 	@_21
	fild 	@_auxE26
	fcomp
	fstsw	ax
	fwait
	sahf
	jae		else_4
then_if_4:
;SALIDA POR CONSOLA
	displayString 	@_asdC2C_menor_a_21
	newLine 1
	jmp		endif_4
else_4:
;SALIDA POR CONSOLA
	displayString 	@_asdC2C_mayor_o_igual_a_21
	newLine 1
endif_4:
if_5:
;SUMA DE REALES
	fld 	@_g
	fld 	@_h
	fadd
	fstp 	@_auxR6
;SUMA DE REALES
	fld 	@_8p0
	fld 	@_7p0
	fadd
	fstp 	@_auxR7
;SUMA DE REALES
	fld 	@_9p0
	fld 	@_auxR7
	fadd
	fstp 	@_auxR8
;DIVISION DE REALES
	fld 	@_3p0
	fld 	@_auxR8
	fdivr
	fstp 	@_auxR9
;SUMA DE REALES
	fld 	@_auxR9
	fld 	@_auxR6
	fadd
	fstp 	@_auxR10
;DIVISION DE REALES
	fld 	@_3p0
	fld 	@_auxR10
	fdivr
	fstp 	@_auxR11
;PREPARO EL ARRAY PARA TRABAJAR COMO FACTOR |
	fild @_2
	fistp @_auxE27
	mov ax, @_auxE27
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, word ptr[bx]
	mov @_auxE28, ax
	fild 	@_auxE28
	fild 	@_auxR11
	fcomp
	fstsw	ax
	fwait
	sahf
	jbe		else_5
then_if_5:
;SALIDA POR CONSOLA
	displayString 	@_avg_mayor_a_asdC2C
	newLine 1
	jmp		endif_5
else_5:
;SALIDA POR CONSOLA
	displayString 	@_avg_menor_o_igual_a_asdC2C
	newLine 1
endif_5:
;SALIDA POR CONSOLA
	displayString 	@_Fin_del_programa
	newLine 1
	mov ah, 4ch
	int 21h

;FIN DEL PROGRAMA DE USUARIO

strlen proc
	mov bx, 0
	strl01:
	cmp BYTE PTR [si+bx],'$'
	je strend
	inc bx
	jmp strl01
	strend:
	ret
strlen endp

copiar proc
	call strlen
	cmp bx , MAXTEXTSIZE
	jle copiarSizeOk
	mov bx , MAXTEXTSIZE
	copiarSizeOk:
	mov cx , bx
	cld
	rep movsb
	mov al , '$'
	mov byte ptr[di],al
	ret
copiar endp

concat proc
	push ds
	push si
	call strlen
	mov dx , bx
	mov si , di
	push es
	pop ds
	call strlen
	add di, bx
	add bx, dx
	cmp bx , MAXTEXTSIZE
	jg concatSizeMal
	concatSizeOk:
	mov cx , dx
	jmp concatSigo
	concatSizeMal:
	sub bx , MAXTEXTSIZE
	sub dx , bx
	mov cx , dx
	concatSigo:
	push ds
	pop es
	pop si
	pop ds
	cld
	rep movsb
	mov al , '$'
	mov byte ptr[di],al
	ret
concat endp

end
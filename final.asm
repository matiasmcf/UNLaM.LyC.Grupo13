include macros2.asm
include number.asm

.MODEL LARGE
.STACK 200h
.386
.387
.DATA

	MAXTEXTSIZE equ 50
	@true dd 1.0
	@false dd 0.0
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
	@_4 	DD 4.0
	@_5 	DD 5.0
	@_Inicio_del_programa 	DB "Inicio del programa",'$',31 dup(?)
	@_10 	DD 10.0
	@_1 	DD 1.0
	@_0 	DD 0.0
	@_3 	DD 3.0
	@_13 	DD 13.0
	@_g_es 	DB "g es",'$',46 dup(?)
	@_Asignando_vector 	DB "Asignando vector",'$',34 dup(?)
	@_570 	DD 570.0
	@_asd_3_es 	DB "asd 3 es",'$',42 dup(?)
	@_Fin_del_programa 	DB "Fin del programa",'$',34 dup(?)
	@aux0 	DD 0.0
	@aux1 	DD 0.0
	@aux2 	DD 0.0
	@aux3 	DD 0.0

.CODE
.startup
	mov AX,@DATA
	mov DS,AX

	FINIT

	displayString 	@_Inicio_del_programa
	newLine 1
	fld 	@_10
	fstp 	@_a
	fld 	@_5
	fstp 	@_b
repeat_0:
if_0:
	fld 	@_b
	fld 	@_a
	fcomp
	fstsw	ax
	fwait
	sahf
	jbe		else_0
then_if_0:
	displayFloat 	@_a,3
	newLine 1
	jmp		endif_0
else_0:
	displayFloat 	@_b,3
	newLine 1
endif_0:
	fld 	@_1
	fld 	@_a
	fsubr
	fstp 	@aux0
	fld 	@aux0
	fstp 	@_a
	fld 	@_0
	fld 	@_a
	fcomp
	fstsw	ax
	fwait
	sahf
	jae		repeat_0
end_repeat_0:
	fld 	@_5
	fld 	@_3
	fadd
	fstp 	@aux1
	fld 	@_13
	fld 	@aux1
	fadd
	fstp 	@aux2
	fld 	@_3
	fld 	@aux2
	fdivr
	fstp 	@aux3
	fld 	@aux3
	fstp 	@_g
	displayString 	@_g_es
	newLine 1
	displayFloat 	@_g,3
	newLine 1
	displayString 	@_Asignando_vector
	newLine 1
	mov ax, 3
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, 570
	mov word ptr[bx],ax
	mov ax, 3
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, word ptr[bx]
	mov @_a,eax
	displayString 	@_asd_3_es
	newLine 1
	displayInteger 	@_a,3
	newLine 1
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
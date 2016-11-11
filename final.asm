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
	@_a 	DW 0
	@_b 	DW 0
	@_z 	DW 0
	@_x 	DW 0
	@_c 	DB MAXTEXTSIZE dup (?),'$'
	@_d 	DB MAXTEXTSIZE dup (?),'$'
	@_e 	DW 0
	@_g 	DD 0.0
	@_4 	DW 4
	@_5 	DW 5
	@_Inicio_del_programa 	DB "Inicio del programa",'$',31 dup(?)
	@_2 	DW 2
	@_10 	DW 10
	@_Fin_del_programa 	DB "Fin del programa",'$',34 dup(?)
	@_aux0 	DD 0.0

.CODE
.startup
	mov AX,@DATA
	mov DS,AX

	FINIT

	displayString 	@_Inicio_del_programa
	newLine 1
	mov ax, @_2
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	fild 	@_10
	fiadd 	@_5
	fistp 	@_aux0
	mov ax, @_aux0
	mov word ptr[bx],ax
	mov ax, @_2
	mov bx, 2
	mul bx
	mov bx, ax
	add bx, OFFSET @_asd
	mov ax, word ptr[bx]
	mov @_a,ax
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
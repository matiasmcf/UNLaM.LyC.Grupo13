%flex% Lexico.l
%bison% -dyv Sintactico.y
%gcc% lex.yy.c y.tab.c -o TPFinal.exe
TPfinal.exe "prueba.txt"
COPY .\final.asm D:\Tasm4\final.asm
pause
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
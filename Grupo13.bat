%flex% Lexico.l
%gcc% lex.yy.c -o TPFinal.exe
TPfinal.exe "prueba.txt"
pause
del lex.yy.c
del TPfinal.exe
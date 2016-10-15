%flex% Lexico.l
%bison% -dyv Sintactico.y
%gcc% lex.yy.c y.tab.c -o TPFinal.exe
TPfinal.exe "prueba.txt"
%gcc% GraficadorPolacaArbol.c -o arbol.exe
arbol.exe
%graphviz% -Tpng graphInfo.txt > intermedia.png
pause
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del graphInfo.txt
del TPFinal.exe
del arbol.exe
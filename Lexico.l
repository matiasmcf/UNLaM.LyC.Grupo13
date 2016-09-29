%{
//INCLUDE////////////////////////////////////////////////////////////
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	//#include "y.tab.h"
	#include <string.h>

//DEFINE/////////////////////////////////////////////////////////////
	#define CARACTER_NOMBRE "_"
	#define NO_ENCONTRADO -1

//ENUMS//////////////////////////////////////////////////////////////
	enum token{
		ID=1,
		CADENA,
		ENTERO,
		REAL,
		COMILLA,
		COMA,
		C_A,
		C_C,
		P_C,
		P_A,
		GB,
		OP_CONCAT,
		OP_SUMA,
		OP_RESTA,
		OP_MUL,
		OP_DIV,
		OP_ASIG,
		COMPARADOR,
		AND,
		OR,
		OP_NOT,
		CONST_REAL,
		CONST_CADENA,
		CONST_ENTERO,
		PROGRAMA,
		FIN_PROGRAMA,
		DECLARACIONES,
		FIN_DECLARACIONES,
		DIM,
		AS,
		IF,
		ELSE,
		THEN,
		ENDIF,
		WHILE,
		ENDWHILE,
		ALLEQUAL,
		WRITE,
		READ,
		FILTER,
		COMENTARIO
	};

	enum valorMaximo{
		ENTERO_MAXIMO = 32768,
		CADENA_MAXIMA = 31,
		TAM = 100
	};

	enum tipoDato{
		tipoEntero,
		tipoReal,
		tipoCadena,
		sinTipo
	};

	enum sectorTabla{
		sectorVariables,
		sectorConstantes
	};

	enum error{
		errorEnteroFueraDeRango,
		errorRealFueraDeRango,
		errorCadenaDemasiadoLarga
	};

//ESTRUCTURAS////////////////////////////////////////////////////////
	typedef struct{
		char nombre[100];
		char valor[100];
		char tipo[100];
		int longitud;
	} registro;

//DEFINICIONES DE FUNCIONES//////////////////////////////////////////
	char* cortarCadena(char* ,int);
	char* reemplazarCaracter(char const * const,  char const * const,  char const * const) ;
	void grabarTablaDeSimbolos(int);
	void insertarEnTablaDeSimbolos(sectorTabla, tipoDato);
	char* normalizar(char*);
	int buscarEnTablaDeSimbolos(sectorTabla, char*);
	void mensajeDeError(error,const char*);

//VARIABLES GLOBALES/////////////////////////////////////////////////
	unsigned long entero64bits;
	registro tablaVariables[TAM];
	registro tablaConstantes[TAM];
	int indiceVariable=0;
	int indiceConstante=0;

%}

%option noyywrap
%option yylineno
DIGITO						[0-9]
LETRA						[a-zA-Z]
ID							{LETRA}({LETRA}|{DIGITO}|_)*
COMENTARIO     				(-\/).*(\/-)
CONST_CADENA 				\"([^\"\\\\]|\\\\.)*\"
CONST_ENTERO				{DIGITO}+
CONST_REAL					([0-9]*\.[0-9]+)

%%

"="							{ printf("OP_ASIG\n");return OP_ASIG;}
"+"							{ printf("OP_SUMA\n");return OP_SUMA;}
"++"						{ printf("OP_CONCAT\n");return OP_CONCAT; }
"-"							{ printf("OP_RESTA\n");return OP_RESTA;}
"*"							{ printf("OP_MUL\n");return OP_MUL;}
"/"							{ printf("OP_DIV\n");return OP_DIV;}
"("							{ printf("P_A\n");return P_A;}
")"							{ printf("P_C\n");return P_C;}
"["							{ printf("C_A\n");return C_A;}
"]"							{ printf("C_C\n");return C_C;}
"\""						{ printf("COMILLA\n");return COMILLA;}
"=="						{ printf("CMP_IGUAL\n");return COMPARADOR;}
"!="						{ printf("CMP_DIST\n");return COMPARADOR; }
">"							{ printf("CMP_MAYOR\n");return COMPARADOR; }
"<"							{ printf("CMP_MENOR\n");return COMPARADOR; }
"<="						{ printf("CMP_NENIG\n");return COMPARADOR; }
">="						{ printf("CMP_MAYIG\n");return COMPARADOR; }
"and"						{ printf("AND\n");return AND; }
"or"						{ printf("OR\n");return OR; }
"not"              			{ printf("OP_NOT\n");return OP_NOT; }
"programa"					{ printf("PROGRAMA\n");return PROGRAMA;}
"fin_programa"				{ printf("FIN_PROGRAMA\n");return FIN_PROGRAMA;}
"declaraciones"				{ printf("DECLARACIONES\n");return DECLARACIONES;}
"fin_declaraciones"			{ printf("FIN_DECLARACIONES\n");return FIN_DECLARACIONES;}
","							{ printf("COMA\n");return COMA; }
"real"						{ printf("REAL\n");return REAL;}
"entero"					{ printf("ENTERO\n");return ENTERO;}
"cadena"					{ printf("CADENA\n");return CADENA;}
"DIM"						{ printf("DIM\n");return DIM; }
"AS"						{ printf("AS\n");return AS; }
"if"						{ printf("IF\n");return IF; }
"else"						{ printf("ELSE\n");return ELSE; }
"endif"						{ printf("ENDIF\n");return ENDIF;}
"while"						{ printf("WHILE\n");return WHILE; }
"endwhile"					{ printf("ENDWHILE\n");return ENDWHILE; }
"AllEqual"					{ printf("ALLEQUAL\n");return ALLEQUAL; }
"WRITE"						{ printf("WRITE\n");return WRITE; }
"READ"						{ printf("READ\n");return READ; }
"FILTER"					{ printf("FILTER\n");return FILTER; }
"_"							{ printf("GB\n");return GB;}
{ID}						{ printf("ID\n");insertarEnTablaDeSimbolos(sectorVariables, sinTipo);return ID;}
{CONST_ENTERO}	  			{ printf("CONST_ENTERO: %s\n",yytext);insertarEnTablaDeSimbolos(sectorConstantes, tipoEntero);return CONST_ENTERO;}
{CONST_REAL}				{ printf("CONST_REAL: %s\n",yytext);insertarEnTablaDeSimbolos(sectorConstantes, tipoReal);return CONST_REAL;}
{CONST_CADENA}				{ printf("CONST_CADENA: %s\n",yytext);insertarEnTablaDeSimbolos(sectorConstantes, tipoCadena);return CONST_CADENA;}
{COMENTARIO}				{ printf("COMENTARIO\n");return COMENTARIO;}
"\n"
"\r\n"
"\t"
" "
. 							{ printf("Linea: %d. Error lexico. Descripcion: El caracter %s es invalido\n",yylineno,yytext); exit(1);}

%%


char * reemplazarCaracter(char const * const original,  char const * const pattern,  char const * const replacement)
{
	size_t const replen = strlen(replacement);
	size_t const patlen = strlen(pattern);
	size_t const orilen = strlen(original);
	size_t patcnt = 0;
	const char * oriptr;
	const char * patloc;
	for (oriptr = original; patloc = strstr(oriptr, pattern); oriptr = patloc + patlen){
		patcnt++;
	}
  {
	size_t const retlen = orilen + patcnt * (replen - patlen);
    char * const returned = (char *) malloc( sizeof(char) * (retlen + 1) );
    if (returned != NULL)
    {
	char * retptr = returned;
	for (oriptr = original; patloc = strstr(oriptr, pattern); oriptr = patloc + patlen){
	size_t const skplen = patloc - oriptr;
	strncpy(retptr, oriptr, skplen);
	retptr += skplen;
	strncpy(retptr, replacement, replen);
	retptr += replen;
	}
	strcpy(retptr, oriptr);
	}
	return returned;
	}
}

char * cortarCadena(char* cad,int tam){
	if(strlen(cad)>tam)
		cad[tam]='\0';
	return cad;
}


int main(int argc,char *argv[])
{
	if ((yyin = fopen(argv[1], "rt")) == NULL)
	{
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}
	else
	{
		while(yylex()!=0){
		}
	}
	fclose(yyin);
	grabarTablaDeSimbolos(0);
	return 0;
}

void grabarTablaDeSimbolos(int error){
	FILE*pf=fopen("ts.txt","w+");
	int i;
	if(!pf){
		printf("Error al crear la tabla de simbolos\n");
		return;
	}
	fprintf(pf,"%-32s|\t%-32s|\t%-32s|\t%-32s\n","NOMBRE","TIPO","VALOR","LONGITUD");
	for(i = 0; i<indiceVariable; i++){
		fprintf(pf,"%-32s|\t%-32s|\t%-32s|\t%-32s\n",tablaVariables[i].nombre,tablaVariables[i].tipo,"* variable *","----------");
	}

	for(i = 0; i<indiceConstante; i++){
		if(tablaConstantes[i].longitud==0)
			fprintf(pf,"%-32s|\t%-32s|\t%-32s|\t%-32s\n",tablaConstantes[i].nombre,tablaConstantes[i].tipo,tablaConstantes[i].valor,"----------");
		else
			fprintf(pf,"%-32s|\t%-32s|\t%-32s|\t%-32d\n",tablaConstantes[i].nombre,tablaConstantes[i].tipo,tablaConstantes[i].valor,tablaConstantes[i].longitud);
	}
	if(error==1)
		fprintf(pf,"TABLA INCOMPLETA (ERROR DE COMPILACION)\n");
	fclose(pf);
}

char* normalizar(char* cadena){
	char *aux = (char *) malloc( sizeof(char) * (strlen(cadena)) + 2);;
	strcpy(aux,CARACTER_NOMBRE);
	strcat(aux,cadena);
	aux=reemplazarCaracter(aux,",","c");
	aux=reemplazarCaracter(aux,".","p");
	aux=reemplazarCaracter(aux,":","d");
	aux=reemplazarCaracter(aux,";","P");
	aux=reemplazarCaracter(aux,"-","m");
	aux=reemplazarCaracter(aux," ","_");
	aux=reemplazarCaracter(aux,"\"","");
	return aux;
}


void insertarEnTablaDeSimbolos(sectorTabla sector, tipoDato tipo){
	if(buscarEnTablaDeSimbolos(sectorConstantes,yytext)!=NO_ENCONTRADO)
		return;
	switch(sector){
		case sectorConstantes:
			switch (tipo) {
				case tipoReal:
					if (atof(yytext)<0 || atof(yytext)>ENTERO_MAXIMO)
						mensajeDeError(errorRealFueraDeRango,yytext);
					strcpy(tablaConstantes[indiceConstante].valor,yytext);
					strcpy(tablaConstantes[indiceConstante].tipo,"real");
					tablaConstantes[indiceConstante].longitud=0;
					strcpy(tablaConstantes[indiceConstante++].nombre,normalizar(yytext));
					break;

				case tipoCadena:
					yytext=reemplazarCaracter(yytext,"\"","");
					strcpy(tablaConstantes[indiceConstante].valor,yytext);
					strcpy(tablaConstantes[indiceConstante].tipo,"cadena");
					tablaConstantes[indiceConstante].longitud=strlen(yytext);
					strcpy(tablaConstantes[indiceConstante++].nombre,normalizar(yytext));
					break;

				case tipoEntero:
					if (atoi(yytext)<0 || atoi(yytext)>ENTERO_MAXIMO)
						mensajeDeError(errorEnteroFueraDeRango,yytext);
					strcpy(tablaConstantes[indiceConstante].valor,yytext);
					strcpy(tablaConstantes[indiceConstante].tipo,"entero");
					tablaConstantes[indiceConstante].longitud=0;
					strcpy(tablaConstantes[indiceConstante++].nombre,normalizar(yytext));
					break;
			}
			break;

		case sectorVariables:
			yytext=reemplazarCaracter(yytext,"\"","");
			strcpy(tablaVariables[indiceVariable].valor,"variable");
			strcpy(tablaVariables[indiceVariable].tipo,"----------");
			tablaVariables[indiceVariable].longitud=strlen(yytext);
			strcpy(tablaVariables[indiceVariable++].nombre,normalizar(yytext));
			break;
			break;
	}
}

int buscarEnTablaDeSimbolos(sectorTabla sector, char* objetivo){
	objetivo=normalizar(objetivo);
	switch(sector){
		case sectorConstantes:
				for(int i=0;i<indiceConstante;i++)
					if(strcmp(tablaConstantes[i].nombre,objetivo)==0)
						return i;
				break;
		case sectorVariables:
				for(int i=0;i<indiceVariable;i++)
					if(strcmp(tablaVariables[i].nombre,objetivo)==0)
						return i;
				break;
	}
	return NO_ENCONTRADO;
}

void mensajeDeError(error error,const char* info){
	grabarTablaDeSimbolos(1);
	printf("[Linea %d]: ",yylineno);
	switch(error){ 
        case errorEnteroFueraDeRango: 
            printf("Entero %s fuera de rango [0 ; %d]\n",info,ENTERO_MAXIMO-1);
            break ;
		case errorRealFueraDeRango: 
            printf("Real %s fuera de rango. Debe ser un real de 32bits\n",info);
            break ;
        case errorCadenaDemasiadoLarga:
            printf("Cadena: \"%s\" fuera de rango. La longitud maxima es 30 caracteres\n", info);
            break ; 
      }
       system ("Pause");
	   exit (1);
	 }
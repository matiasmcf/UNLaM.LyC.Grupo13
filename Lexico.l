%{
//INCLUDE////////////////////////////////////////////////////////////
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	#include "y.tab.h"
	#include <string.h>
	#include <float.h>

//DEFINE/////////////////////////////////////////////////////////////
	#define CARACTER_NOMBRE "_"
	#define NO_ENCONTRADO -1
	#define preMaxCadena 46
	#define preMaxEntero 6

//ENUMS//////////////////////////////////////////////////////////////
	enum valorMaximo{
		ENTERO_MAXIMO = 65535,
		CADENA_MAXIMA = 31,
		TAM = 100
	};

	enum tipoDato{
		tipoEntero,
		tipoReal,
		tipoCadena,
		tipoArray,
		sinTipo
	};

	enum sectorTabla{
		sectorVariables,
		sectorConstantes
	};

	enum error{
		errorEnteroFueraDeRango,
		errorRealFueraDeRango,
		errorCadenaDemasiadoLarga,
		errorIdDemasiadoLargo,
		errorCaracterInvalido
	};

//ESTRUCTURAS////////////////////////////////////////////////////////
	typedef struct{
		char nombre[100];
		char valor[100];
		enum tipoDato tipo;
		int longitud;
		int limite;
	} registro;

//DEFINICIONES DE FUNCIONES//////////////////////////////////////////
	char* cortarCadena(char* ,int);
	char* reemplazarCaracter(char const * const,  char const * const,  char const * const) ;
	void grabarTablaDeSimbolos(int);
	void insertarEnTablaDeSimbolos(enum sectorTabla,enum tipoDato);
	char* normalizar(char*);
	int buscarEnTablaDeSimbolos(enum sectorTabla, char*);
	void mensajeDeError(enum error,const char*);
	char * cortarCadena(char* ,int);
	void guardarToken(char *);
	char* obtenerTipo(enum sectorTabla, enum tipoDato);
	void mostrarTablaDeSimbolos();

//VARIABLES GLOBALES/////////////////////////////////////////////////
	unsigned long entero64bits;
	registro tablaVariables[TAM];
	registro tablaConstantes[TAM];
	int indiceVariable=0;
	int indiceConstante=0;
	char *tiraDeTokens;

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

":"							{ guardarToken("DOS_PUNTOS\n");return DOS_PUNTOS;}
"="							{ guardarToken("OP_ASIG\n");return OP_ASIG;}
"+"							{ guardarToken("OP_SUMA\n");return OP_SUMA;}
"++"						{ guardarToken("OP_CONCAT\n");return OP_CONCAT; }
"-"							{ guardarToken("OP_RESTA\n");return OP_RESTA;}
"*"							{ guardarToken("OP_MUL\n");return OP_MUL;}
"/"							{ guardarToken("OP_DIV\n");return OP_DIV;}
"("							{ guardarToken("P_A\n");return P_A;}
")"							{ guardarToken("P_C\n");return P_C;}
"["							{ guardarToken("C_A\n");return C_A;}
"]"							{ guardarToken("C_C\n");return C_C;}
"\""						{ guardarToken("COMILLA\n");return COMILLA;}
"=="						{ guardarToken("CMP_IGUAL\n");strcpy(yylval.cadena,yytext);return COMPARADOR;}
"!="						{ guardarToken("CMP_DIST\n");strcpy(yylval.cadena,yytext);return COMPARADOR; }
">"							{ guardarToken("CMP_MAYOR\n");strcpy(yylval.cadena,yytext);return COMPARADOR; }
"<"							{ guardarToken("CMP_MENOR\n");strcpy(yylval.cadena,yytext);return COMPARADOR; }
"<="						{ guardarToken("CMP_NENIG\n");strcpy(yylval.cadena,yytext);return COMPARADOR; }
">="						{ guardarToken("CMP_MAYIG\n");strcpy(yylval.cadena,yytext);return COMPARADOR; }
"and"						{ guardarToken("AND\n");return AND; }
"or"						{ guardarToken("OR\n");return OR; }
"not"              			{ guardarToken("OP_NOT\n");return OP_NOT; }
"programa"					{ guardarToken("PROGRAMA\n");return PROGRAMA;}
"fin_programa"				{ guardarToken("FIN_PROGRAMA\n");return FIN_PROGRAMA;}
"DECVAR"					{ guardarToken("DECLARACIONES\n");return DECLARACIONES;}
"ENDEC"						{ guardarToken("FIN_DECLARACIONES\n");return FIN_DECLARACIONES;}
"AVG"						{ guardarToken("AVG\n");return AVG;}
","							{ guardarToken("COMA\n");return COMA; }
"real"						{ guardarToken("REAL\n");return REAL;}
"entero"					{ guardarToken("ENTERO\n");return ENTERO;}
"cadena"					{ guardarToken("CADENA\n");return CADENA;}
"DIM"						{ guardarToken("DIM\n");return DIM; }
"AS"						{ guardarToken("AS\n");return AS; }
"if"						{ guardarToken("IF\n");return IF; }
"else"						{ guardarToken("ELSE\n");return ELSE; }
"endif"						{ guardarToken("ENDIF\n");return ENDIF;}
"WRITE"						{ guardarToken("WRITE\n");return WRITE; }
"READ"						{ guardarToken("READ\n");return READ; }
"repeat"					{ guardarToken("REPEAT\n");return REPEAT;}
"while"						{ guardarToken("WHILE\n");return WHILE;}
"array"				 		{ guardarToken("ARRAY\n");return ARRAY; }
"_"							{ guardarToken("GB\n");return GB;}
"{"							{ guardarToken("LLAVE_ABIERTA\n");return LLAVE_ABIERTA;}
"}"							{ guardarToken("LLAVE_CERRADA\n");return LLAVE_CERRADA;}
{ID}						{ guardarToken("ID\n");strcpy(yylval.cadena,yytext);insertarEnTablaDeSimbolos(sectorVariables, sinTipo);return ID;}
{CONST_ENTERO}	  			{ guardarToken("CONST_ENTERO\n");strcpy(yylval.cadena,yytext);insertarEnTablaDeSimbolos(sectorConstantes, tipoEntero);return CONST_ENTERO;}
{CONST_REAL}				{ guardarToken("CONST_REAL\n");strcpy(yylval.cadena,yytext);insertarEnTablaDeSimbolos(sectorConstantes, tipoReal);return CONST_REAL;}
{CONST_CADENA}				{ guardarToken("CONST_CADENA\n");strcpy(yylval.cadena,yytext);insertarEnTablaDeSimbolos(sectorConstantes, tipoCadena);return CONST_CADENA;}
{COMENTARIO}				{ guardarToken("COMENTARIO\n");}
"\n"
"\r\n"
"\t"
" "
. 							{mensajeDeError(errorCaracterInvalido,yytext);}

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

void grabarTablaDeSimbolos(int error){
	//TIRA DE TOKENS
	FILE*pt=fopen("tiraDeTokens.txt","w+");
	if(!pt){
		printf("Error al crear la tabla de simbolos\n");
		return;
	}
	fprintf(pt,"%s",tiraDeTokens);
	fclose(pt);
	//
	FILE*pf=fopen("ts.txt","w+");
	int i;
	if(!pf){
		printf("Error al crear la tabla de simbolos\n");
		return;
	}
	fprintf(pf,"%-32s|\t%-15s|\t%-32s|\t%-13s|\t%-13s\n\n","NOMBRE","TIPO","VALOR","LONGITUD","LIMITE");
	for(i = 0; i<indiceVariable; i++){
		if(tablaVariables[i].limite!=0)
			fprintf(pf,"%-32s|\t%-15s|\t%-32s|\t%-13s|\t%-13d\n",tablaVariables[i].nombre,obtenerTipo(sectorVariables, tablaVariables[i].tipo),"----------------------------","----------",tablaVariables[i].limite);
		else
			fprintf(pf,"%-32s|\t%-15s|\t%-32s|\t%-13s|\t%-13s\n",tablaVariables[i].nombre,obtenerTipo(sectorVariables, tablaVariables[i].tipo),"----------------------------","----------","----------");
	}

	for(i = 0; i<indiceConstante; i++){
		if(tablaConstantes[i].longitud==0)
			fprintf(pf,"%-32s|\t%-15s|\t%-32s|\t%-13s|\t%-13s\n",tablaConstantes[i].nombre,obtenerTipo(sectorConstantes, tablaConstantes[i].tipo),tablaConstantes[i].valor,"----------","----------");
		else
			fprintf(pf,"%-32s|\t%-15s|\t%-32s|\t%-13d|\t%-13s\n",tablaConstantes[i].nombre,obtenerTipo(sectorConstantes, tablaConstantes[i].tipo),tablaConstantes[i].valor,tablaConstantes[i].longitud,"----------");
	}
	if(error==1)
		fprintf(pf,"\n**** TABLA INCOMPLETA (ERROR DE COMPILACION) ****\n");
	fclose(pf);
}

void mostrarTablaDeSimbolos(){
	printf("%-32s|\t%-15s|\t%-32s|\t%-13s|\t%-13s\n\n","NOMBRE","TIPO","VALOR","LONGITUD","LIMITE");
	int i;
	for(i = 0; i<indiceVariable; i++){
		if(tablaVariables[i].limite!=0)
			printf("%-32s|\t%-15s|\t%-32s|\t%-13s|\t%-13d\n",tablaVariables[i].nombre,obtenerTipo(sectorVariables, tablaVariables[i].tipo),"----------------------------","----------",tablaVariables[i].limite);
		else
			printf("%-32s|\t%-15s|\t%-32s|\t%-13s|\t%-13s\n",tablaVariables[i].nombre,obtenerTipo(sectorVariables, tablaVariables[i].tipo),"----------------------------","----------","----------");
	}

	for(i = 0; i<indiceConstante; i++){
		if(tablaConstantes[i].longitud==0)
			printf("%-32s|\t%-15s|\t%-32s|\t%-13s|\t%-13s\n",tablaConstantes[i].nombre,obtenerTipo(sectorConstantes, tablaConstantes[i].tipo),tablaConstantes[i].valor,"----------","----------");
		else
			printf("%-32s|\t%-15s|\t%-32s|\t%-13d|\t%-13s\n",tablaConstantes[i].nombre,obtenerTipo(sectorConstantes, tablaConstantes[i].tipo),tablaConstantes[i].valor,tablaConstantes[i].longitud,"----------");
	}
}

char* normalizar(char* cadena){
	char *aux = (char *) malloc( sizeof(char) * (strlen(cadena)) + 2);
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

char* obtenerTipo(enum sectorTabla sector, enum tipoDato tipo){
	switch(sector){
		case sectorConstantes:
			switch(tipo){
				case tipoReal:
					return("const_real");
					break;
				case tipoCadena:
					return("const_cadena");
					break;
				case tipoEntero:
					return("const_entera");
					break;
			}
			break;
		case sectorVariables:
			switch(tipo){
				case tipoReal:
					return("real");
					break;
				case tipoCadena:
					return("cadena");
					break;
				case tipoEntero:
					return("entero");
					break;
				case tipoArray:
					return("array");
					break;
				case sinTipo:
					return("sin tipo");
					break;
			}
			break;
	}
}

void insertarEnTablaDeSimbolos(enum sectorTabla sector, enum tipoDato tipo){
	char *cadena=(char*)malloc(sizeof(char));
	switch(sector){
		case sectorConstantes:
			if(buscarEnTablaDeSimbolos(sectorConstantes,yytext)!=NO_ENCONTRADO)
				return;
			switch (tipo) {
				case tipoReal:
					if (atof(yytext)<0 || atof(yytext)>FLT_MAX)
						mensajeDeError(errorRealFueraDeRango,yytext);
					strcpy(tablaConstantes[indiceConstante].valor,yytext);
					tablaConstantes[indiceConstante].tipo=tipoReal;
					tablaConstantes[indiceConstante].longitud=0;
					tablaConstantes[indiceConstante].limite=0;
					strcpy(tablaConstantes[indiceConstante++].nombre,normalizar(yytext));
					break;

				case tipoCadena:
					strcpy(cadena,yytext);
					cortarCadena(cadena,preMaxCadena);
					cadena=reemplazarCaracter(cadena,"\"","");
					if(strlen(cadena)>=CADENA_MAXIMA)
						mensajeDeError(errorCadenaDemasiadoLarga, cadena);
					strcpy(tablaConstantes[indiceConstante].valor,cadena);
					tablaConstantes[indiceConstante].tipo=tipoCadena;
					tablaConstantes[indiceConstante].longitud=strlen(cadena);
					tablaConstantes[indiceConstante].limite=0;
					strcpy(tablaConstantes[indiceConstante++].nombre,normalizar(cadena));
					break;

				case tipoEntero:
					strcpy(cadena,yytext);
					cortarCadena(cadena,preMaxEntero);
					if (atoi(cadena)<0 || atoi(cadena)>ENTERO_MAXIMO)
						mensajeDeError(errorEnteroFueraDeRango,yytext);
					strcpy(tablaConstantes[indiceConstante].valor,cadena);
					tablaConstantes[indiceConstante].tipo=tipoEntero;
					tablaConstantes[indiceConstante].longitud=0;
					tablaConstantes[indiceConstante].limite=0;
					strcpy(tablaConstantes[indiceConstante++].nombre,normalizar(cadena));
					break;
			}
			break;

		case sectorVariables:
			cadena=cortarCadena(yytext,preMaxCadena);
			cadena=reemplazarCaracter(cadena,"\"","");
			if(strlen(cadena)>=CADENA_MAXIMA)
				mensajeDeError(errorCadenaDemasiadoLarga, cadena);
			if(buscarEnTablaDeSimbolos(sectorVariables,cadena)!=NO_ENCONTRADO)
				return;
			strcpy(tablaVariables[indiceVariable].valor,cadena);
			tablaVariables[indiceVariable].tipo=sinTipo;
			tablaVariables[indiceVariable].longitud=0;
			tablaVariables[indiceVariable].limite=0;
			strcpy(tablaVariables[indiceVariable++].nombre,normalizar(cadena));
			break;
	}
}

int buscarEnTablaDeSimbolos(enum sectorTabla sector, char* objetivo){
	objetivo=normalizar(objetivo);
	int i;
	switch(sector){
		case sectorConstantes:
				for(i=0;i<indiceConstante;i++)
					if(strcmp(tablaConstantes[i].nombre,objetivo)==0)
						return i;
				return NO_ENCONTRADO;
				break;

		case sectorVariables:
				for(i=0;i<indiceVariable;i++)
					if(strcmp(tablaVariables[i].nombre,objetivo)==0)
						return i;
				return NO_ENCONTRADO;
				break;
	}
	return NO_ENCONTRADO;
}

void mensajeDeError(enum error error,const char* info){
	grabarTablaDeSimbolos(1);

	printf("[Linea %d] ",yylineno);
	switch(error){ 

        case errorEnteroFueraDeRango: 
            printf("ERROR LEXICO. Descripcion: Entero %s fuera de rango [0 ; %d]\n",info,ENTERO_MAXIMO);
            break ;

		case errorRealFueraDeRango: 
            printf("ERROR LEXICO. Descripcion: Real %s fuera de rango. Debe ser un real de 32bits.\n",info);
            break ;

        case errorCadenaDemasiadoLarga:
            printf("ERROR LEXICO. Descripcion: Cadena \"%s\" fuera de rango. La longitud maxima es de 30 caracteres.\n", info);
            break ; 

        case errorIdDemasiadoLargo:
            printf("ERROR LEXICO. Descripcion: El id \"%s\" es demasiado largo. La longitud maxima es de 30 caracteres.\n", info);
            break ; 

        case errorCaracterInvalido:
        	printf("ERROR LEXICO. Descripcion: El caracter %s es invalido.\n",info);
        	break;
      }
       system ("Pause");
	   exit (1);
	 }

void guardarToken(char* token){
	char* aux = (char*) malloc ( sizeof(char) * (strlen(tiraDeTokens)) +1);
	strcpy(aux, tiraDeTokens);
	tiraDeTokens=(char*) malloc ( sizeof(char) * (strlen(aux)) + strlen(token)+1);
	strcpy(tiraDeTokens,aux);
	strcat(tiraDeTokens,token);
}
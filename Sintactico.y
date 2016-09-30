
%{
//////////////////////INCLUDES//////////////////////////////////////
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	#include "y.tab.h"
	#include <string.h>
	#include <float.h>
	#include <math.h>

	#define CARACTER_NOMBRE "_"
	#define NO_ENCONTRADO -1
	#define SIN_ASIGNAR "SinAsignar"

///////////////////// ENUMS ////////////////////////////////////////
	enum tipoDeError{
		ErrorSintactico,
		ErrorLexico
	};

	enum error{
		ErrorIntFueraDeRango,
		ErrorStringFueraDeRango,
		ErrorEnDeclaracionCantidad,
		ErrorIdRepetida,
		ErrorIdNoDeclarado,
		ErrorIdDistintoTipo,
		ErrorAllEqual,
		ErrorRead,
		ErrorConstanteDistintoTipo,
		ErrorOperacionNoValida,
		ErrorFloatFueraDeRango,
		ErrorMultipleTipo
	};

	enum sectorTabla{
		sectorVariables,
		sectorConstantes
	};

	enum tipoDato{
		tipoEntero,
		tipoReal,
		tipoCadena,
		tipoArray,
		sinTipo
	};


	enum valorMaximo{
		ENTERO_MAXIMO = 32768,
		CADENA_MAXIMA = 31,
		TAM = 100
	};

///////////////////// ESTRUCUTURAS  ////////////////////////////////
	typedef struct{
		char nombre[100];
		char valor[100];
		char tipo[100];
		int longitud;
		int limite;
	} registro;

///////////////////// DECLARACION DE FUNCIONES /////////////////////
	int yyerrormsj(const char *,enum tipoDeError,enum error);
	int yyerror();

///////////////////// DECLARACION DE VARIABLES GLOBALES //////////// 
	extern registro tablaVariables[TAM];
	extern registro tablaConstantes[TAM];
	extern int yylineno;
	extern int indiceConstante;
	extern int indiceVariable;
	extern char *tiraDeTokens;
	int yystopparser=0;
	FILE  *yyin;
	char *yyltext;
	char *yytext;
	unsigned long entero64bits;
	int indicesParaAsignarTipo[TAM];
	int contadorListaVar;

	%}

	%union {
		int entero;
		double real;
		char cadena[50];
	}

///////////////////// TOKENS////////////////////////////////////////
	//TOKEN TIPOS DE DATO
	%token <cadena>ID
	%token <cadena>CADENA
	%token <cadena>ENTERO
	%token <cadena>REAL
	%token ARRAY
	
	//TOKEN SIMBOLOS
	%token COMILLA COMA C_A C_C  P_C P_A GB DOS_PUNTOS LLAVE_ABIERTA LLAVE_CERRADA
	
	//TOKEN OPERANDOS
	%token OP_CONCAT
	%left OP_SUMA OP_RESTA OP_MUL OP_DIV OP_ASIG
	//TOKEN COMPARADORES
	%token COMPARADOR AND OR OP_NOT
	
	//TOKEN CONSTANTES
	%token CONST_REAL CONST_CADENA CONST_ENTERO
	
	//TOKEN PALABRAS RESERVADAS
	%token PROGRAMA FIN_PROGRAMA DECLARACIONES FIN_DECLARACIONES DIM AS IF ELSE THEN ENDIF REPEAT WRITE READ AVG
	
%%

programa:  	   
	PROGRAMA bloque_declaraciones bloque_sentencias FIN_PROGRAMA
	;

bloque_declaraciones:
	DECLARACIONES declaraciones FIN_DECLARACIONES
	;
	
declaraciones:         	        	
	declaracion
	|declaraciones declaracion
	;

declaracion:  
	{contadorListaVar=0;}
	lista_var DOS_PUNTOS tipo
	;

tipo: 
	REAL 	
	{
		int i;
		for(i=0;i<contadorListaVar;i++){
			if(strcmp(tablaVariables[indicesParaAsignarTipo[i]].tipo,SIN_ASIGNAR)==0)
				strcpy(tablaVariables[indicesParaAsignarTipo[i]].tipo,"real");
			else
				yyerrormsj(tablaVariables[indicesParaAsignarTipo[i]].valor,ErrorSintactico,ErrorMultipleTipo);
		}
		printf("Declaradas %d var real/s\n",contadorListaVar);
	}
	|CADENA 
	{
		int i;
		for(i=0;i<contadorListaVar;i++){
			if(strcmp(tablaVariables[indicesParaAsignarTipo[i]].tipo,SIN_ASIGNAR)==0)
				strcpy(tablaVariables[indicesParaAsignarTipo[i]].tipo,"cadena");
			else
				yyerrormsj(tablaVariables[indicesParaAsignarTipo[i]].valor,ErrorSintactico,ErrorMultipleTipo);
		}
		printf("Declaradas %d var cadena/s\n",contadorListaVar);
	}
	|ENTERO 
	{
		int i;
		for(i=0;i<contadorListaVar;i++){
			if(strcmp(tablaVariables[indicesParaAsignarTipo[i]].tipo,SIN_ASIGNAR)==0)
				strcpy(tablaVariables[indicesParaAsignarTipo[i]].tipo,"entero");
			else
				yyerrormsj(tablaVariables[indicesParaAsignarTipo[i]].valor,ErrorSintactico,ErrorMultipleTipo);
		}
		printf("Declaradas %d var entera/s\n",contadorListaVar);
	}
	|ARRAY 	
	{
		int i;
		for(i=0;i<contadorListaVar;i++){
			if(strcmp(tablaVariables[indicesParaAsignarTipo[i]].tipo,SIN_ASIGNAR)==0)
				strcpy(tablaVariables[indicesParaAsignarTipo[i]].tipo,"array");
			else
				yyerrormsj(tablaVariables[indicesParaAsignarTipo[i]].valor,ErrorSintactico,ErrorMultipleTipo);
		}
		printf("Declaradas %d var array/s\n",contadorListaVar);
	}
	;
	 
lista_var:
	var 
	|var COMA lista_var 
 	 ;

var:
	ID 
	{
		int posicion=buscarEnTablaDeSimbolos(sectorVariables,yylval.cadena);
		indicesParaAsignarTipo[contadorListaVar++]=posicion;
	}
	|ID 
	{
		int posicion=buscarEnTablaDeSimbolos(sectorVariables,yylval.cadena);
		indicesParaAsignarTipo[contadorListaVar++]=posicion;
	}
	P_A CONST_ENTERO 
	{
		tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>3)].limite=atoi($<cadena>4);
	} P_C
	;

bloque_sentencias: 
	sentencia
	|bloque_sentencias sentencia
	;

sentencia: 
	write
	|read
	|asignacion		
	|sentencia_if
	;

sentencia_if: 
	IF P_A condicion P_C bloque_if ENDIF
	;

bloque_if:
 	bloque_sentencias 
 	|bloque_sentencias ELSE bloque_sentencias 
 	;

comparacion : expresion COMPARADOR expresion  
	;

condicion:
	comparacion 
	|OP_NOT comparacion 
	|comparacion and_or comparacion
	;

write:  
	WRITE CONST_CADENA
	|WRITE ID 
	;

read:
	READ ID	
	;

and_or:
	AND
	|OR
	;

asignacion: 
	ID OP_ASIG expresion
	|ID C_A CONST_ENTERO C_C OP_ASIG expresion
	|ID C_A CONST_ENTERO C_C OP_ASIG LLAVE_ABIERTA expresiones LLAVE_CERRADA
	;

expresion:
    termino
	|expresion OP_RESTA termino
    |expresion OP_SUMA termino
	|expresion OP_CONCAT termino
 	;

termino: 
    factor
    |termino OP_MUL factor
    |termino OP_DIV factor
	;

factor:
    ID 
    | CONST_ENTERO 
    | CONST_REAL
	| CONST_CADENA
    | P_A expresion P_C
    | average
    ;

average:
	AVG P_A C_A expresiones C_C P_C

expresiones:
	expresion
	| expresiones COMA expresion

%%

int main(int argc,char *argv[])
{
	if ((yyin = fopen(argv[1], "rt")) == NULL)
	{
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}
	else
	{
		tiraDeTokens=(char*)malloc(sizeof(char)*1);
		strcpy(tiraDeTokens,"");
		yyparse();
	}
	fclose(yyin);
	grabarTablaDeSimbolos(0);
	printf("\n* COMPILACION EXITOSA *\n");
	return 0;
}

/////////////////////////////////////DEFINICION  DE FUNCIONES///////////////////////////////////////////////////

int yyerrormsj(const char * info,enum tipoDeError tipoDeError ,enum error error)
     {
		 grabarTablaDeSimbolos(1);
		printf("Linea: %d. ",yylineno);
       switch(tipoDeError){
          case ErrorSintactico: 
            printf("Error sintactico. ");
            break;
          case ErrorLexico: 
            printf("Error lexico. ");
            break;
        }
      switch(error){ 
        case ErrorIntFueraDeRango: 
            printf("Entero %s fuera de rango [-%d ; %d]\n",info,ENTERO_MAXIMO,ENTERO_MAXIMO-1);
            break ;
		case ErrorFloatFueraDeRango: 
            printf("Real %s fuera de rango. Debe ser un real de 32bits\n",info);
            break ;
        case ErrorStringFueraDeRango:
            printf("Cadena: \"%s\" fuera de rango. La longitud maxima es 30 caracteres\n", info);
            break ; 
		case ErrorEnDeclaracionCantidad:
			printf("Descripcion: no coinciden la cantidad de ids declaradas con la cantidad de tipos declarados\n");
			break ; 
		case ErrorIdRepetida:
			printf("Descripcion: el id '%s' ha sido declarado mas de una vez\n",info);
			break;
		case ErrorIdNoDeclarado: 
			printf("Descripcion: el id '%s' no ha sido declarado\n",info);
			break;
		case ErrorIdDistintoTipo: 
			break;
		case ErrorConstanteDistintoTipo: 
			break;
		case ErrorAllEqual: 
			printf("Descripcion: Error AllEqual: %s\n",info);
			break;
		case ErrorOperacionNoValida:
			break;
		case ErrorMultipleTipo:
			printf("Descripcion: el id '%s' ya tiene un tipo asignado\n",info);
			break;
      }

       system ("Pause");
	     exit (1);
      }

int yyerror()
     {
		grabarTablaDeSimbolos(1);
		printf("Error sintatico \n");
		system ("Pause");
		exit (1);
     }

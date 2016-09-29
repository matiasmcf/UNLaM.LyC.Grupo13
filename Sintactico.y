
%{
//////////////////////INCLUDES//////////////////////////////////////
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	#include "y.tab.h"
	#include <string.h>
	#include <float.h>
	#include <math.h>
	//#include <graphics.h>
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
		ErrorFloatFueraDeRango
	};

	enum tipoDeDato{
		TipoEntero,
		TipoReal,
		TipoCadena,
		SinTipo
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
	//
	unsigned long entero64bits;
%}

%union {
	int entero;
	double real;
	char cadena[50];
}

////////////////////////////////////TOKENS//////////////////////////
	//TOKEN TIPOS DE DATO
	%token <cadena>ID
	%token <cadena>CADENA
	%token <entero>ENTERO
	%token <real>REAL
	
	//TOKEN SIMBOLOS
	%token COMILLA COMA C_A C_C  P_C P_A GB
	
	//TOKEN OPERANDOS
	%token OP_CONCAT
	%left OP_SUMA OP_RESTA OP_MUL OP_DIV OP_ASIG
	//TOKEN COMPARADORES
	%token COMPARADOR AND OR OP_NOT
	
	//TOKEN CONSTANTES
	%token CONST_REAL CONST_CADENA CONST_ENTERO
	
	//TOKEN PALABRAS RESERVADAS
	%token PROGRAMA FIN_PROGRAMA DECLARACIONES FIN_DECLARACIONES DIM AS IF ELSE THEN ENDIF REPEAT WRITE READ
	
%%

programa:  	   
	PROGRAMA bloque_declaraciones bloque_sentencias FIN_PROGRAMA
	;

bloque_declaraciones:
	DECLARACIONES declaraciones FIN_DECLARACIONES
	;
	
declaraciones:         	        	
		declaracion
		| declaraciones declaracion
		;

declaracion:  
		DIM C_A lista_var C_C AS C_A lista_tipo C_C 
		;
	 
lista_var:
		ID
		| ID COMA lista_var 
 	 ;
	 
tipo: 
		ENTERO
		| REAL
		| CADENA
		 ;

lista_tipo : 
		tipo
		| tipo COMA lista_tipo
		;

bloque_sentencias: 
		sentencia
		|  bloque_sentencias sentencia
		;

sentencia: 
		write
		| read
		| asignacion 		
		| sentencia_if
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
		| OP_NOT comparacion 
		| comparacion and_or comparacion
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
    ;

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
	printf("\n* COMPILACION EXITOSA* \n");
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

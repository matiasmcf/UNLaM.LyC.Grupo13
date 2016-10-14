
%{
//////////////////////INCLUDES//////////////////////////////////////
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	#include "y.tab.h"
	#include <string.h>

	#define CARACTER_NOMBRE "_"
	#define NO_ENCONTRADO -1
	#define SIN_ASIGNAR "SinAsignar"

///////////////////// ENUMS ////////////////////////////////////////
	enum valorMaximo{
		ENTERO_MAXIMO = 32768,
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
		ErrorIdRepetida,
		ErrorIdNoDeclarado,
		ErrorArraySinTipo,
		ErrorArrayFueraDeRango,
		ErrorLimiteArrayNoPermitido,
		ErrorOperacionNoValida,
		ErrorIdDistintoTipo,
		ErrorConstanteDistintoTipo,
		ErrorArrayAsignacionMultiple
	};

		enum tipoDeError{
		ErrorSintactico,
		ErrorLexico
	};

///////////////////// ESTRUCUTURAS  ////////////////////////////////
	typedef struct{
		char nombre[100];
		char valor[100];
		enum tipoDato tipo;
		int longitud;
		int limite;
	} registro;
	
///////////////////// DECLARACION DE FUNCIONES /////////////////////
	int yyerrormsj(const char *,enum tipoDeError,enum error, const char*);
	int yyerror();
	
	//Funciones para notacion intermedia
	void insertarEnPolaca(char * v);
	void inicializarPolaca();
	void finalizarPolaca();

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
	int indicesParaAsignarTipo[TAM];
	enum tipoDato tipoAsignacion=sinTipo;
	//Boolean
	int esAsignacion=0;
	int esAverage=0;
	int esAsignacionVectorMultiple;
	//Contadores
	int contadorListaVar=0;
	int contadorExpresionesVector=0;
	int cantidadDeExpresionesEsperadasEnVector=0;
	//Notacion intermedia
	FILE *pPolaca;

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
	%token PROGRAMA FIN_PROGRAMA DECLARACIONES FIN_DECLARACIONES DIM AS IF ELSE THEN ENDIF REPEAT WHILE WRITE READ AVG
	
%%

programa:  	   
	PROGRAMA {printf("INICIO DEL PROGRAMA\n");}bloque_declaraciones bloque_sentencias FIN_PROGRAMA {printf("FIN DEL PROGRAMA\n");}
	;

bloque_declaraciones:
	DECLARACIONES {printf("DECLARACIONES\n");}declaraciones FIN_DECLARACIONES {printf("FIN_DECLARACIONES\n");}
	;
	
declaraciones:         	        	
	declaracion
	|declaraciones declaracion
	;

declaracion:  
	{contadorListaVar=0;}
	lista_var_dec DOS_PUNTOS tipo
	;

tipo: 
	REAL 	
	{
		int i;
		printf("  Declaradas: ");
		for(i=0;i<contadorListaVar;i++){
			if(tablaVariables[indicesParaAsignarTipo[i]].tipo==sinTipo){
				printf("'%s' ",tablaVariables[indicesParaAsignarTipo[i]].valor);
				tablaVariables[indicesParaAsignarTipo[i]].tipo=tipoReal;
			}
			else
				yyerrormsj(tablaVariables[indicesParaAsignarTipo[i]].valor,ErrorSintactico,ErrorIdRepetida,"");
		}
		printf("de tipo real\n");
	}
	|CADENA 
	{
		int i;
		printf("  Declaradas: ");
		for(i=0;i<contadorListaVar;i++){
			if(tablaVariables[indicesParaAsignarTipo[i]].tipo==sinTipo){
				printf("'%s' ",tablaVariables[indicesParaAsignarTipo[i]].valor);
				tablaVariables[indicesParaAsignarTipo[i]].tipo=tipoCadena;
			}
			else
				yyerrormsj(tablaVariables[indicesParaAsignarTipo[i]].valor,ErrorSintactico,ErrorIdRepetida,"");
		}
		printf("de tipo cadena\n");
	}
	|ENTERO 
	{
		int i;
		printf("  Declaradas: ");
		for(i=0;i<contadorListaVar;i++){
			if(tablaVariables[indicesParaAsignarTipo[i]].tipo==sinTipo){
				printf("'%s' ",tablaVariables[indicesParaAsignarTipo[i]].valor);
				tablaVariables[indicesParaAsignarTipo[i]].tipo=tipoEntero;
			}
			else
				yyerrormsj(tablaVariables[indicesParaAsignarTipo[i]].valor,ErrorSintactico,ErrorIdRepetida,"");
		}
		printf("de tipo entero\n");
	}
	|ARRAY 	
	{
		int i;
		printf("  Declaradas: ");
		for(i=0;i<contadorListaVar;i++){
			if(tablaVariables[indicesParaAsignarTipo[i]].tipo==sinTipo){
				printf("'%s' ",tablaVariables[indicesParaAsignarTipo[i]].valor);
				tablaVariables[indicesParaAsignarTipo[i]].tipo=tipoArray;
			}
			else
				yyerrormsj(tablaVariables[indicesParaAsignarTipo[i]].valor,ErrorSintactico,ErrorIdRepetida,"");
		}
		printf("de tipo array\n");
	}
	;
	 
lista_var_dec:
	var_dec 
	|var_dec COMA lista_var_dec 
 	 ;

var_dec:
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
		if(atoi($<cadena>4)<=0)
			yyerrormsj($<cadena>3,ErrorSintactico,ErrorLimiteArrayNoPermitido,$<cadena>4);
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
	|asignacion_vector	
	|sentencia_if
	|sentencia_repeat
	;

sentencia_repeat: 
	REPEAT {printf("INICIO REPEAT\n");}bloque_sentencias WHILE  P_A condicion{printf("CONDICION\n");} P_C {printf("FIN REPEAT\n");}
	;

sentencia_if: 
	IF {printf("IF\n");}P_A condicion P_C bloque_if ENDIF{printf("ENDIF\n");}
	;

bloque_if:
 	bloque_sentencias 
 	|bloque_sentencias ELSE {printf("ELSE\n");}bloque_sentencias 
 	;

comparacion : expresion COMPARADOR expresion  
	;

condicion:
	comparacion 
	|OP_NOT comparacion 
	|comparacion and_or comparacion
	;

write:  
	WRITE CONST_CADENA {printf("WRITE CONSTANTE\n");}
	|WRITE ID 
	{
		printf("WRITE VARIABLE\n");
		if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorIdNoDeclarado,"");
	}
	;

read:
	READ ID	
	{
		printf("READ VARIABLE\n");
		if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorIdNoDeclarado,"");
	}
	;

and_or:
	AND
	|OR
	;

asignacion: 
	ID 
	{
		if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorIdNoDeclarado,"");
		esAsignacion=1;
		printf("ASIGNACION: %s\t", $<cadena>1);
		tipoAsignacion=tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo;
		printf("(tipo: %s)\n",obtenerTipo(sectorVariables,tipoAsignacion));
	} 
	OP_ASIG expresion 
	{
		esAsignacion=0;
		tipoAsignacion=sinTipo;
		insertarEnPolaca($<cadena>1);
		insertarEnPolaca("=");		
	}
	;

asignacion_vector: 
	vector OP_ASIG {printf("ASIGNACION VECTOR: %s\n", $<cadena>1);} expresion 
	|vector OP_ASIG
	{
		printf("ASIGNACION VECTOR MULTIPLE: %s\n", $<cadena>1);
		esAsignacionVectorMultiple=1;
		contadorExpresionesVector=0;
	} LLAVE_ABIERTA expresiones LLAVE_CERRADA 
	{
		if(contadorExpresionesVector!=cantidadDeExpresionesEsperadasEnVector)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorArrayAsignacionMultiple,"");
		esAsignacionVectorMultiple=0;
		contadorExpresionesVector=0;
		cantidadDeExpresionesEsperadasEnVector=0;
	}
	;

expresion:
    termino
	|expresion OP_RESTA 
	{
		printf("RESTA\n");
		if(esAsignacion==1&&tipoAsignacion==tipoCadena)
			yyerrormsj("resta", ErrorSintactico,ErrorOperacionNoValida,"");

	} termino {insertarEnPolaca("-");}
    |expresion OP_SUMA 
    {
    	if(esAsignacion==1&&tipoAsignacion==tipoCadena)
			yyerrormsj("suma", ErrorSintactico,ErrorOperacionNoValida,"");
    	printf("SUMA\n");
    }termino {insertarEnPolaca("+");}
	|expresion OP_CONCAT 
	{
		if(esAsignacion==1&&tipoAsignacion!=tipoCadena)
			yyerrormsj("concatenacion", ErrorSintactico,ErrorOperacionNoValida,"");
		printf("CONCATENACION\n");
	} termino
 	;

termino: 
    factor
    |termino OP_MUL 
    {
    	printf("MULTIPLICACION\n");
    	if(esAsignacion==1&&tipoAsignacion==tipoCadena)
			yyerrormsj("multiplicacion", ErrorSintactico,ErrorOperacionNoValida,"");
    } factor {insertarEnPolaca("*");}
    |termino OP_DIV 
    {
    	printf("DIVISION\n");
    	if(esAsignacion==1&&tipoAsignacion==tipoCadena)
			yyerrormsj("division", ErrorSintactico,ErrorOperacionNoValida,"");
    } factor {insertarEnPolaca("/");}
	;

factor:
    ID 
    {
    	if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorIdNoDeclarado,"");
    	printf("ID: %s\n", $<cadena>1);
    	if(esAverage==0)
    		if(esAsignacion==1&& tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo!=tipoAsignacion)
				yyerrormsj($<cadena>1, ErrorSintactico,ErrorIdDistintoTipo,"");
    } {insertarEnPolaca($<cadena>1);}
    | vector 
    {
    	printf("VECTOR: %s\n", $<cadena>1);
    	if(esAverage==0)
    		if(esAsignacion==1&&tipoAsignacion!=tipoEntero)
    			yyerrormsj($<cadena>1, ErrorSintactico,ErrorIdDistintoTipo,"");
    }
    | CONST_ENTERO 
    {
    	printf("CONST_ENTERO: %s\n", $<cadena>1);
    	if(esAverage==0)
    		if(esAsignacion==1&&tipoAsignacion!=tipoEntero)
    			yyerrormsj($<cadena>1, ErrorSintactico,ErrorConstanteDistintoTipo,"");
		insertarEnPolaca($<cadena>1);
    } 
    | CONST_REAL 
    {
    	printf("CONST_REAL: %s\n", $<cadena>1);
    	if(esAsignacion==1&&tipoAsignacion!=tipoReal)
    		yyerrormsj($<cadena>1, ErrorSintactico,ErrorConstanteDistintoTipo,"");
    }
	| CONST_CADENA 
	{
		printf("CONST_CADENA: %s\n", $<cadena>1);
		if(esAsignacion==1&&tipoAsignacion!=tipoCadena)
    		yyerrormsj($<cadena>1, ErrorSintactico,ErrorConstanteDistintoTipo,"");
	}
    | P_A expresion P_C 
    | average
    {
    	if(esAsignacion==1&&tipoAsignacion!=tipoReal)
    		yyerrormsj($<cadena>1, ErrorSintactico,ErrorConstanteDistintoTipo,"");
    }
    ;

vector:
    ID C_A ID C_C
    | ID C_A CONST_ENTERO C_C
    {
    	if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
    		yyerrormsj($<cadena>1,ErrorSintactico,ErrorArraySinTipo,"");
    	if(atoi($<cadena>3)<=0 || atoi($<cadena>3)>(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].limite))
    		yyerrormsj($<cadena>1,ErrorSintactico,ErrorArrayFueraDeRango,$<cadena>3);
    	if(esAsignacionVectorMultiple==0){
    		cantidadDeExpresionesEsperadasEnVector=atoi($<cadena>3);
    	}
    }
    ;

average:
	AVG 
	{
		printf("AVERAGE\n");
		esAverage=1;
	} P_A C_A expresiones C_C P_C {esAverage=0;}

expresiones:
	expresion 
	{
		if(esAsignacionVectorMultiple==1&&esAverage==0)
			contadorExpresionesVector++;
	}
	| expresiones COMA expresion
	{
		if(esAsignacionVectorMultiple==1&&esAverage==0)
			contadorExpresionesVector++;
	}

%%

int main(int argc,char *argv[])
{
	inicializarPolaca();
	if ((yyin = fopen(argv[1], "rt")) == NULL)
	{
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}
	else
	{
		tiraDeTokens=(char*)malloc(sizeof(char));
		strcpy(tiraDeTokens,"");
		yyparse();
	}
	fclose(yyin);
	grabarTablaDeSimbolos(0);
	finalizarPolaca();
	printf("\n* COMPILACION EXITOSA *\n");
	return 0;
}

/////////////////////////////////////DEFINICION  DE FUNCIONES///////////////////////////////////////////////////

int yyerrormsj(const char * info,enum tipoDeError tipoDeError ,enum error error, const char *infoAdicional)
     {
		 grabarTablaDeSimbolos(1);
		printf("[Linea %d] ",yylineno);
       switch(tipoDeError){
          case ErrorSintactico: 
            printf("Error sintactico. ");
            break;
          case ErrorLexico: 
            printf("Error lexico. ");
            break;
        }
      switch(error){  
		case ErrorIdRepetida:
			printf("Descripcion: el id '%s' ha sido declarado mas de una vez\n",info);
			break;
		case ErrorIdNoDeclarado: 
			printf("Descripcion: el id '%s' no ha sido declarado\n",info);
			break;
		case ErrorArraySinTipo:
			printf("Descripcion: el id '%s' NO tiene un tipo asignado\n",info);
			break;
		case ErrorArrayFueraDeRango:
			printf("Descripcion: vector '%s(0..%d)' fuera de rango. Se intenta acceder a '%s[%s]'\n",info,(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,info)].limite),info,infoAdicional);
			break;
		case ErrorLimiteArrayNoPermitido:
			printf("Descripcion: el vector %s (%s) no tiene un limite valido, debe ser mayor a 0\n",info, infoAdicional);
			break;
		case ErrorOperacionNoValida: 
			printf("Descripcion: La operacion %s no es valida para variables de tipo %s\n",info, obtenerTipo(sectorVariables, tipoAsignacion));
			break;
		case ErrorIdDistintoTipo: 
			printf("Descripcion: La variable '%s' no es de tipo %s\n",info,obtenerTipo(sectorVariables, tipoAsignacion));
			break;
		case ErrorConstanteDistintoTipo: 
			printf("Descripcion: La constante %s no es de tipo %s\n", info, obtenerTipo(sectorVariables, tipoAsignacion));
			break;
		case ErrorArrayAsignacionMultiple: 
			printf("Descripcion: El vector %s esperaba %d expresiones, pero se recibieron %d.\n", info,cantidadDeExpresionesEsperadasEnVector,contadorExpresionesVector );
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

void inicializarPolaca(){
    pPolaca = fopen("intermedia.txt", "w");
    if(pPolaca == NULL){
        printf("Error al abrir el archivo: intermedia.txt \n");
    }
}

void insertarEnPolaca( char *token ){
    fputs( token, pPolaca);
	fputs( " ", pPolaca);
}

void finalizarPolaca(){
    fclose(pPolaca);
}

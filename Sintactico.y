
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
	#define TRUE 1
	#define FALSE 0
	#define ERROR -1
	#define OK 3

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
		ErrorArrayAsignacionMultiple,
		ErrorTipoAverage
	};

	enum tipoDeError{
		ErrorSintactico,
		ErrorLexico
	};

	enum tipoCondicion{
		condicionIf,
		condicionRepeat
	};

	enum and_or{
		and,
		or,
		condicionSimple
	};

	enum tipoSalto{
		normal,
		inverso
	};

///////////////////// ESTRUCUTURAS  ////////////////////////////////
	
	//Tabla de simbolos
	typedef struct{
		char nombre[100];
		char valor[100];
		enum tipoDato tipo;
		int longitud;
		int limite;
	} registro;
	
	//Pila
	typedef struct
	{
		char *cadena;
		int cantExpresiones;
		int salto1;
		int salto2;
		int nro;
		enum and_or andOr;
	}t_info;

	typedef struct s_nodoPila{
    	t_info info;
    	struct s_nodoPila* psig;
	}t_nodoPila;

	typedef t_nodoPila *t_pila;

	//Polaca
	typedef struct
	{
		char cadena[CADENA_MAXIMA];
		int nro;
	}t_infoPolaca;

	typedef struct s_nodoPolaca{
    	t_infoPolaca info;
    	struct s_nodoPolaca* psig;
	}t_nodoPolaca;

	typedef t_nodoPolaca *t_polaca;

	///////////////////// DECLARACION DE FUNCIONES /////////////////////
	int yyerrormsj(const char *,enum tipoDeError,enum error, const char*);
	int yyerror();
	
	//Funciones para notacion intermedia
	void guardarPolaca(t_polaca*);
	int ponerEnPolacaNro(t_polaca*,int, char *);
	int ponerEnPolaca(t_polaca*, char *);
	void crearPolaca(t_polaca*);
	char* obtenerSalto(enum tipoSalto);
	char* obtenerSalto2(char*,enum tipoSalto);
	//Funciones para manejo de pilas
	void vaciarPila(t_pila*);
	t_info* sacarDePila(t_pila*);
	void crearPila(t_pila*);
	int ponerEnPila(t_pila*,t_info*);
	t_info* topeDePila(t_pila*);
	

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
	int esAsignacionVectorMultiple;
	//Contadores
	int contadorListaVar=0;
	int contadorExpresionesVector=0;
	int cantidadDeExpresionesEsperadasEnVector=0;
	int contadorAVG=0;
	int contadorPolaca=0;
	int contadorIf=0;
	int contadorWhile=0;
	//Notacion intermedia
	t_polaca polaca;
	t_pila pilaAVG;
	t_pila pilaIf;
	t_pila pilaWhile;
	char ultimoComparador[3];
	char nombreVector[CADENA_MAXIMA];
	int inicioAsignacionMultiple;
	int expresionesRestantes;
	enum tipoCondicion tipoCondicion;
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
	PROGRAMA {printf("INICIO DEL PROGRAMA\n");} bloque_declaraciones bloque_sentencias FIN_PROGRAMA {printf("FIN DEL PROGRAMA\n");}
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
	REPEAT 
	{
		printf("INICIO REPEAT\n"); 
		printf("IF\n");
		t_info info;
		info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
		info.nro=contadorWhile++;
		sprintf(info.cadena,"[repeat_%d]",info.nro);
		ponerEnPolaca(&polaca,info.cadena);
		sprintf(info.cadena,"repeat_%d",info.nro);
		ponerEnPila(&pilaWhile,&info);
	}
	bloque_sentencias WHILE
	{
		tipoCondicion=condicionRepeat;
	}  
	P_A condicion P_C 
	{
		printf("FIN REPEAT\n");
		sacarDePila(&pilaWhile);
	}
	;

sentencia_if: 
	IF 
	{
		printf("IF\n");
		t_info info;
		info.cadena=(char*)malloc(sizeof(char)*CADENA_MAXIMA);
		info.nro=contadorIf++;
		sprintf(info.cadena,"[if_%d]",info.nro);
		ponerEnPolaca(&polaca,info.cadena);
		ponerEnPila(&pilaIf,&info);
		tipoCondicion=condicionIf;
	}
	P_A condicion P_C
	{
		char aux[10];
 		sprintf(aux,"[then_if_%d]",topeDePila(&pilaIf)->nro);
 		ponerEnPolaca(&polaca,aux);
	} 
	bloque_if ENDIF
	{
		printf("ENDIF\n");
		char aux[20];
		sprintf(aux,"[endif_%d]",sacarDePila(&pilaIf)->nro);
		ponerEnPolaca(&polaca,aux);
	}
	;

bloque_if:
 	bloque_sentencias 
 	{
 		char aux[10];
 		sprintf(aux,"endif_%d",topeDePila(&pilaIf)->nro);
 		if(topeDePila(&pilaIf)->andOr==and||topeDePila(&pilaIf)->andOr==or)
 			ponerEnPolacaNro(&polaca,topeDePila(&pilaIf)->salto2,aux);
 		ponerEnPolacaNro(&polaca,topeDePila(&pilaIf)->salto1,aux);
 	}
 	|bloque_sentencias 
 	{
 		char aux[10];
 		sprintf(aux,"endif_%d",topeDePila(&pilaIf)->nro);
 		ponerEnPolaca(&polaca,aux);
 		ponerEnPolaca(&polaca,"BI");
 	}
 	ELSE 
 	{
 		char aux[10];
 		sprintf(aux,"[else_%d]",topeDePila(&pilaIf)->nro);
 		ponerEnPolaca(&polaca,aux);
 	}
 		bloque_sentencias 
 	{
 		printf("ELSE\n");
 		char aux[10];
 		sprintf(aux,"else_%d",topeDePila(&pilaIf)->nro);
 		if(topeDePila(&pilaIf)->andOr==and)
 			ponerEnPolacaNro(&polaca,topeDePila(&pilaIf)->salto2,aux);
 		else
 			if(topeDePila(&pilaIf)->andOr==or){
 				sprintf(aux,"then_if_%d",topeDePila(&pilaIf)->nro);
 				ponerEnPolacaNro(&polaca,topeDePila(&pilaIf)->salto2,aux);
 			}
 		sprintf(aux,"else_%d",topeDePila(&pilaIf)->nro);
 		ponerEnPolacaNro(&polaca,topeDePila(&pilaIf)->salto1,aux);
 	}
 	;

comparacion : expresion COMPARADOR expresion {strcpy(ultimoComparador,$<cadena>2);} 
	;

condicion:
	comparacion
	{
		switch(tipoCondicion){
			case condicionIf:
				topeDePila(&pilaIf)->andOr=condicionSimple;
				topeDePila(&pilaIf)->salto1=contadorPolaca+1;
				ponerEnPolaca(&polaca,"CMP");
				ponerEnPolaca(&polaca,"");
				//TODO: Revisar si las instrucciones son correctas
				ponerEnPolaca(&polaca,obtenerSalto(inverso));
				break;

			case condicionRepeat:
				topeDePila(&pilaWhile)->andOr=condicionSimple;
				ponerEnPolaca(&polaca,"CMP");
		 		ponerEnPolaca(&polaca,topeDePila(&pilaWhile)->cadena);
				//TODO: Revisar si las instrucciones son correctas
				ponerEnPolaca(&polaca,obtenerSalto(normal));
				char aux[20];
				sprintf(aux,"[end_repeat_%d]",topeDePila(&pilaWhile)->nro);
				ponerEnPolaca(&polaca,aux);
				break;
		}
		
	} 
	|OP_NOT comparacion 
	{
		switch(tipoCondicion){
			case condicionIf:
				topeDePila(&pilaIf)->andOr=condicionSimple;
				topeDePila(&pilaIf)->salto1=contadorPolaca+1;
				ponerEnPolaca(&polaca,"CMP");
				ponerEnPolaca(&polaca,"");
				//TODO: Revisar si las instrucciones son correctas
				ponerEnPolaca(&polaca,obtenerSalto(normal));
				break;

			case condicionRepeat:
				topeDePila(&pilaWhile)->andOr=condicionSimple;
				ponerEnPolaca(&polaca,"CMP");
		 		ponerEnPolaca(&polaca,topeDePila(&pilaWhile)->cadena);
				//TODO: Revisar si las instrucciones son correctas
				ponerEnPolaca(&polaca,obtenerSalto(inverso));
				char aux[20];
				sprintf(aux,"[end_repeat_%d]",topeDePila(&pilaWhile)->nro);
				ponerEnPolaca(&polaca,aux);
				break;
		}
		
	} 
	|comparacion and_or 
	{
		switch(tipoCondicion){
			case condicionIf:
				switch(topeDePila(&pilaIf)->andOr){
					case and:
						topeDePila(&pilaIf)->salto2=contadorPolaca+1;
						ponerEnPolaca(&polaca,"CMP");
						ponerEnPolaca(&polaca,"");
						//TODO: Revisar si las instrucciones son correctas
						ponerEnPolaca(&polaca,obtenerSalto(inverso));
						break;

					case or:
						topeDePila(&pilaIf)->salto2=contadorPolaca+1;
						ponerEnPolaca(&polaca,"CMP");
						ponerEnPolaca(&polaca,"");
						//TODO: Revisar si las instrucciones son correctas
						ponerEnPolaca(&polaca,obtenerSalto(normal));
						break;
				}
				break;

			case condicionRepeat:
				switch(topeDePila(&pilaWhile)->andOr){
					case and:
						ponerEnPolaca(&polaca,"CMP");
				 		char aux[20];
						sprintf(aux,"end_repeat_%d",topeDePila(&pilaWhile)->nro);
						ponerEnPolaca(&polaca,aux);
						//TODO: Revisar si las instrucciones son correctas
						ponerEnPolaca(&polaca,obtenerSalto(inverso));
						break;

					case or:
						ponerEnPolaca(&polaca,"CMP");
				 		ponerEnPolaca(&polaca,topeDePila(&pilaWhile)->cadena);
						//TODO: Revisar si las instrucciones son correctas
						ponerEnPolaca(&polaca,obtenerSalto(normal));
						break;
				}
				break;
		}
	}
	comparacion
	{
		switch(tipoCondicion){
			case condicionIf:
				topeDePila(&pilaIf)->salto1=contadorPolaca+1;
				ponerEnPolaca(&polaca,"CMP");
				ponerEnPolaca(&polaca,"");
				//TODO: Revisar si las instrucciones son correctas
				ponerEnPolaca(&polaca,obtenerSalto(inverso));
				break;

			case condicionRepeat:
				ponerEnPolaca(&polaca,"CMP");
		 		ponerEnPolaca(&polaca,topeDePila(&pilaWhile)->cadena);
				//TODO: Revisar si las instrucciones son correctas
				ponerEnPolaca(&polaca,obtenerSalto(normal));
				char aux[20];
				sprintf(aux,"[end_repeat_%d]",topeDePila(&pilaWhile)->nro);
				ponerEnPolaca(&polaca,aux);
				break;
		}
	}
	;

write:  
	WRITE CONST_CADENA 
	{
		printf("WRITE CONSTANTE\n"); 
		ponerEnPolaca(&polaca,tablaConstantes[buscarEnTablaDeSimbolos(sectorConstantes,$<cadena>2)].nombre);
		ponerEnPolaca(&polaca,"WRITE");
	}
	|WRITE ID 
	{
		printf("WRITE VARIABLE\n");
		if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorIdNoDeclarado,""); 
		ponerEnPolaca(&polaca,tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>2)].nombre);
		ponerEnPolaca(&polaca,"WRITE");
	}
	;

read:
	READ ID	
	{
		printf("READ VARIABLE\n");
		if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorIdNoDeclarado,"");	 
		ponerEnPolaca(&polaca,tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>2)].nombre);
		ponerEnPolaca(&polaca,"READ");
	}
	;

and_or:
	AND 	
	{
		if(tipoCondicion==condicionIf)
			topeDePila(&pilaIf)->andOr=and;
		else
			topeDePila(&pilaWhile)->andOr=and;
	}
	|OR 	
	{
		if(tipoCondicion==condicionIf)
			topeDePila(&pilaIf)->andOr=or;
		else
			topeDePila(&pilaWhile)->andOr=or;
	}
	;

asignacion: 
	ID 
	{
		if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorIdNoDeclarado,"");
		esAsignacion=1;
		printf("ASIGNACION: %s\t", $<cadena>1);
		tipoAsignacion=tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo;
		ponerEnPolaca(&polaca,tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].nombre);
		printf("(tipo: %s)\n",obtenerTipo(sectorVariables,tipoAsignacion));
	} 
	OP_ASIG expresion 
	{
		esAsignacion=0;
		tipoAsignacion=sinTipo;
		ponerEnPolaca(&polaca,"=");
		printf("FIN ASIGNACION\n");		
	}
	;

asignacion_vector: 
	vector OP_ASIG {printf("ASIGNACION VECTOR: %s\n", $<cadena>1);} expresion {ponerEnPolaca(&polaca,"=");}
	|vector OP_ASIG
	{
		printf("ASIGNACION VECTOR MULTIPLE: %s\n", $<cadena>1);
		esAsignacionVectorMultiple=1;
		contadorExpresionesVector=0;
		inicioAsignacionMultiple=contadorPolaca-1;
	} LLAVE_ABIERTA expresiones LLAVE_CERRADA 
	{
		if(contadorExpresionesVector!=cantidadDeExpresionesEsperadasEnVector)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorArrayAsignacionMultiple,"");
		esAsignacionVectorMultiple=0;
		contadorExpresionesVector=0;
		cantidadDeExpresionesEsperadasEnVector=expresionesRestantes=0;
	}
	;

expresion:
    termino
	|expresion OP_RESTA 
	{
		printf("RESTA\n");
		if(esAsignacion==1&&tipoAsignacion==tipoCadena)
			yyerrormsj("resta", ErrorSintactico,ErrorOperacionNoValida,"");

	} termino {ponerEnPolaca(&polaca,"-");}
    |expresion OP_SUMA 
    {
    	if(esAsignacion==1&&tipoAsignacion==tipoCadena)
			yyerrormsj("suma", ErrorSintactico,ErrorOperacionNoValida,"");
    	printf("SUMA\n");
    }termino {ponerEnPolaca(&polaca,"+");}
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
    } factor {ponerEnPolaca(&polaca,"*");}
    |termino OP_DIV 
    {
    	printf("DIVISION\n");
    	if(esAsignacion==1&&tipoAsignacion==tipoCadena)
			yyerrormsj("division", ErrorSintactico,ErrorOperacionNoValida,"");
    } factor {ponerEnPolaca(&polaca,"/");}
	;

factor:
    ID 
    {
    	printf("ID: %s\n", $<cadena>1);
    	//verificacion de errores
    	if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
			yyerrormsj($<cadena>1,ErrorSintactico,ErrorIdNoDeclarado,"");
    	if(topeDePila(&pilaAVG)==NULL)
    		if(esAsignacion==1&& tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo!=tipoAsignacion)
				yyerrormsj($<cadena>1, ErrorSintactico,ErrorIdDistintoTipo,"");
		//Acciones
		ponerEnPolaca(&polaca,tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].nombre);
	}
    | vector 
    | CONST_ENTERO 
    {
    	printf("CONST_ENTERO: %s\n", $<cadena>1);
    	//verificacion de errores
    	if(topeDePila(&pilaAVG)==NULL)
    		if(esAsignacion==1&&tipoAsignacion!=tipoEntero)
    			yyerrormsj($<cadena>1, ErrorSintactico,ErrorConstanteDistintoTipo,"");
		//Acciones
		ponerEnPolaca(&polaca,tablaConstantes[buscarEnTablaDeSimbolos(sectorConstantes,$<cadena>1)].nombre);
    } 
    | CONST_REAL 
    {
    	printf("CONST_REAL: %s\n", $<cadena>1);
    	//verificacion de errores
    	if(esAsignacion==1&&tipoAsignacion!=tipoReal)
    		yyerrormsj($<cadena>1, ErrorSintactico,ErrorConstanteDistintoTipo,"");
    	//Acciones
		ponerEnPolaca(&polaca,tablaConstantes[buscarEnTablaDeSimbolos(sectorConstantes,$<cadena>1)].nombre);
    }
	| CONST_CADENA 
	{
		printf("CONST_CADENA: %s\n", $<cadena>1);
		//verificacion de errores
		if(esAsignacion==1&&tipoAsignacion!=tipoCadena)
    		yyerrormsj($<cadena>1, ErrorSintactico,ErrorConstanteDistintoTipo,"");
    	//Acciones
		ponerEnPolaca(&polaca,tablaConstantes[buscarEnTablaDeSimbolos(sectorConstantes,$<cadena>1)].nombre);
	}
    | P_A expresion P_C 
    | average
    {
    	//Verificacion de errores
    	if(esAsignacion==1&&tipoAsignacion!=tipoReal)
    		yyerrormsj($<cadena>1, ErrorSintactico,ErrorTipoAverage,"");
    	//Acciones
    }
    ;

vector:
    ID C_A ID C_C
    {
    	printf("VECTOR: %s\n", $<cadena>1);
    	char aux[50];
    	//Verificacion de errores
    	if(topeDePila(&pilaAVG)==NULL)
    		if(esAsignacion==1&&tipoAsignacion!=tipoEntero)
    			yyerrormsj($<cadena>1, ErrorSintactico,ErrorIdDistintoTipo,"");
    	//Acciones

    	//Validacion de rango
    	sprintf(aux,"[if_%d]",contadorIf);
    	ponerEnPolaca(&polaca,aux);
    	ponerEnPolaca(&polaca,tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>3)].nombre);
    	ponerEnPolaca(&polaca,"CMP");
    	sprintf(aux,"%d",tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].limite);
    	ponerEnPolaca(&polaca,aux);
    	sprintf(aux,"then_if_%d",contadorIf);
    	ponerEnPolaca(&polaca,aux);
    	ponerEnPolaca(&polaca,obtenerSalto2(">=",normal));
    	ponerEnPolaca(&polaca,tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>3)].nombre);
    	insertarEnTablaDeSimbolos(sectorConstantes,tipoEntero,"1");
    	sprintf(aux,"%s",tablaConstantes[buscarEnTablaDeSimbolos(sectorConstantes,"1")].nombre);
    	ponerEnPolaca(&polaca,aux);
    	ponerEnPolaca(&polaca,"CMP");
    	sprintf(aux,"end_if_%d",contadorIf);
    	ponerEnPolaca(&polaca,aux);
    	ponerEnPolaca(&polaca,obtenerSalto2(">=",normal));
    	sprintf(aux,"[then_if_%d]",contadorIf);
    	ponerEnPolaca(&polaca,aux);
    	//Mensaje de error
    	sprintf(aux,"Vector %s[%s]",$<cadena>1,$<cadena>3);
    	insertarEnTablaDeSimbolos(sectorConstantes,tipoCadena,aux);
    	ponerEnPolaca(&polaca,tablaConstantes[buscarEnTablaDeSimbolos(sectorConstantes,aux)].nombre);
    	ponerEnPolaca(&polaca,"WRITE");
    	sprintf(aux,"fuera de rango [1;%d]",tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].limite);
    	insertarEnTablaDeSimbolos(sectorConstantes,tipoCadena,aux);
    	ponerEnPolaca(&polaca,tablaConstantes[buscarEnTablaDeSimbolos(sectorConstantes,aux)].nombre);
    	ponerEnPolaca(&polaca,"WRITE");
    	ponerEnPolaca(&polaca,"EXIT");
    	sprintf(aux,"[end_if_%d]",contadorIf);
    	ponerEnPolaca(&polaca,aux);
    	contadorIf++;
    	//Agregar a polaca	
	    strcpy(aux,tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].nombre);
	    strcat(aux,"[");
	    strcat(aux,$<cadena>3);
	    strcat(aux,"]");
	    ponerEnPolaca(&polaca,aux);
    }
    | ID C_A CONST_ENTERO C_C
    {	
    	printf("VECTOR: %s\n", $<cadena>1);
    	char aux[50];
    	//Verificacion de errores
    	if(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].tipo==sinTipo)
    		yyerrormsj($<cadena>1,ErrorSintactico,ErrorArraySinTipo,"");
    	if(atoi($<cadena>3)<=0 || atoi($<cadena>3)>(tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].limite))
    		yyerrormsj($<cadena>1,ErrorSintactico,ErrorArrayFueraDeRango,$<cadena>3);
    	if(esAsignacionVectorMultiple==0){
    		cantidadDeExpresionesEsperadasEnVector=atoi($<cadena>3);
    		expresionesRestantes=cantidadDeExpresionesEsperadasEnVector;
    		strcpy(nombreVector,tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].nombre);
    	}
    	if(topeDePila(&pilaAVG)==NULL)
    		if(esAsignacion==1&&tipoAsignacion!=tipoEntero)
    			yyerrormsj($<cadena>1, ErrorSintactico,ErrorIdDistintoTipo,"");
    	//Acciones
    	strcpy(aux,tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,$<cadena>1)].nombre);
	    strcat(aux,"[");
	    strcat(aux,$<cadena>3);
	    strcat(aux,"]");
	    ponerEnPolaca(&polaca,aux);
    }
    ;

average:
	AVG 
	{
		printf("AVERAGE\n");
		contadorAVG++;
		t_info info;
		info.nro=contadorAVG;
		info.cadena=(char*)malloc(sizeof(char));
		if(info.cadena==NULL){
			printf("Error al solicitar memoria\n");
			exit(1);
		}
		info.cantExpresiones=0;
		ponerEnPila(&pilaAVG,&info);
	} 
	P_A C_A expresiones C_C P_C 
	{
		printf("Expresiones en AVG_%d: %d\n", topeDePila(&pilaAVG)->nro,topeDePila(&pilaAVG)->cantExpresiones);
		char aux[50];
		sprintf(aux,"%d",topeDePila(&pilaAVG)->cantExpresiones);
		insertarEnTablaDeSimbolos(sectorConstantes,tipoEntero,aux);
		sprintf(aux,"%s",tablaConstantes[buscarEnTablaDeSimbolos(sectorConstantes,aux)].nombre);
		ponerEnPolaca(&polaca,aux);
		ponerEnPolaca(&polaca,"/");
		sacarDePila(&pilaAVG);
	}

expresiones:
	expresion 
	{
		if(topeDePila(&pilaAVG)==NULL){
			if(esAsignacionVectorMultiple==1){
				contadorExpresionesVector++;
				char aux[CADENA_MAXIMA];
				sprintf(aux,"%s[%d]",nombreVector,expresionesRestantes);
				ponerEnPolacaNro(&polaca,inicioAsignacionMultiple,aux);
				expresionesRestantes--;
				ponerEnPolaca(&polaca,"=");
			}
		}
		else{
			topeDePila(&pilaAVG)->cantExpresiones++;
		}
	}
	| expresiones 
	{
		if(topeDePila(&pilaAVG)==NULL)
			if(esAsignacionVectorMultiple==1){
				ponerEnPolaca(&polaca,"");
				inicioAsignacionMultiple=contadorPolaca-1;
		}
	}
	COMA expresion
	{
		if(topeDePila(&pilaAVG)==NULL){
			if(esAsignacionVectorMultiple){
				contadorExpresionesVector++;
				char aux[CADENA_MAXIMA];
				sprintf(aux,"%s[%d]",nombreVector,expresionesRestantes);
				ponerEnPolacaNro(&polaca,inicioAsignacionMultiple,aux);
				expresionesRestantes--;
				ponerEnPolaca(&polaca,"=");
			}
		}
		else{
			topeDePila(&pilaAVG)->cantExpresiones++;
			ponerEnPolaca(&polaca,"+");
		}
	}

%%

int main(int argc,char *argv[])
{
	crearPila(&pilaAVG);
	crearPila(&pilaWhile);
	crearPila(&pilaIf);
	crearPolaca(&polaca);
	if ((yyin = fopen(argv[1], "rt")) == NULL)
	{
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}
	else
	{
		tiraDeTokens=(char*)malloc(sizeof(char));
		if(tiraDeTokens==NULL){
			printf("Error al solicitar memoria\n");
			exit(1);
		}
		strcpy(tiraDeTokens,"");
		yyparse();
	}
	fclose(yyin);
	grabarTablaDeSimbolos(0);
	vaciarPila(&pilaAVG);
	vaciarPila(&pilaWhile);
	vaciarPila(&pilaIf);
	guardarPolaca(&polaca);
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
		case ErrorTipoAverage:
			printf("Descripcion: La funcion AVG devuelve un valor 'real', pero '%s' es de tipo %s\n", info, obtenerTipo(sectorVariables, tablaVariables[buscarEnTablaDeSimbolos(sectorVariables,info)].tipo));
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

/////////////////Pila/////////////////////////////////////////////////////

	void crearPila(t_pila* pp)
	{
	    *pp=NULL; 
	}

	int ponerEnPila(t_pila* pp,t_info* info)
	{
	    t_nodoPila* pn=(t_nodoPila*)malloc(sizeof(t_nodoPila));
	    if(!pn)
	        return 0;
	    pn->info=*info;
	    pn->psig=*pp;
	    *pp=pn;
	    return 1;
	}

	t_info * sacarDePila(t_pila* pp)
	{
		t_info* info = (t_info *) malloc(sizeof(t_info));
	    if(!*pp){
	    	return NULL;
	    }
	    *info=(*pp)->info;
	    *pp=(*pp)->psig;
	    return info;

	}

	void vaciarPila(t_pila* pp)
	{
	    t_nodoPila* pn;
	    while(*pp)
	    {
	        pn=*pp;
	        *pp=(*pp)->psig;
	        free(pn);
	    }
	}

	t_info* topeDePila(t_pila* pila){
		return &((*pila)->info);
	}

	/////////////////POLACA/////////////////////////////////////////////////////
	void crearPolaca(t_polaca* pp)
	{
	    *pp=NULL; 
	}

	int ponerEnPolaca(t_polaca* pp, char *cadena)
	{
	    t_nodoPolaca* pn = (t_nodoPolaca*)malloc(sizeof(t_nodoPolaca));
	    if(!pn){
	    	printf("ponerEnPolaca: Error al solicitar memoria (pn).\n");
	        return ERROR;
	    }	    
	    t_nodoPolaca* aux;
	    strcpy(pn->info.cadena,cadena);
	    pn->info.nro=contadorPolaca++;
	    pn->psig=NULL;
	    if(!*pp){
	    	*pp=pn;
	    	return OK;
	    }
	    else{
	    	aux=*pp;
	    	while(aux->psig)
	        	aux=aux->psig;
	        aux->psig=pn;
	    	return OK;
	    }
	}

	int ponerEnPolacaNro(t_polaca* pp,int pos, char *cadena)
	{
		t_nodoPolaca* aux;
		aux=*pp;
	    while(aux!=NULL && aux->info.nro<pos){
	    	aux=aux->psig;
	    }
	    if(aux->info.nro==pos){
	    	strcpy(aux->info.cadena,cadena);
	    	return OK;
	    }
	    else{
	    	printf("NO ENCONTRADO\n");
	    	return ERROR;
	    }
	    return ERROR;
	}

	void guardarPolaca(t_polaca *pp){
		FILE*pt=fopen("intermedia.txt","w+");
		t_nodoPolaca* pn;
		if(!pt){
			printf("Error al crear la tabla de simbolos\n");
			return;
		}
		while(*pp)
	    {
	        pn=*pp;
	        fprintf(pt, "%s\n",pn->info.cadena);
	        *pp=(*pp)->psig;
	        free(pn);
	    }
		fclose(pt);
	}

	char* obtenerSalto(enum tipoSalto tipo){
		switch(tipo){
			case normal:
				if(strcmp(ultimoComparador,"==")==0)
					return("BEQ");
				if(strcmp(ultimoComparador,">")==0)
					return("BGT");
				if(strcmp(ultimoComparador,"<")==0)
					return("BLT");
				if(strcmp(ultimoComparador,">=")==0)
					return("BGE");
				if(strcmp(ultimoComparador,"<=")==0)
					return("BLE");
				if(strcmp(ultimoComparador,"!=")==0)
					return("BNE");
				break;

			case inverso:
				if(strcmp(ultimoComparador,"==")==0)
					return("BNE");
				if(strcmp(ultimoComparador,">")==0)
					return("BLE");
				if(strcmp(ultimoComparador,"<")==0)
					return("BGE");
				if(strcmp(ultimoComparador,">=")==0)
					return("BLT");
				if(strcmp(ultimoComparador,"<=")==0)
					return("BGT");
				if(strcmp(ultimoComparador,"!=")==0)
					return("BEQ");
				break;
		}
	}

	char* obtenerSalto2(char* comparador,enum tipoSalto tipo){
		switch(tipo){
			case normal:
				if(strcmp(comparador,"==")==0)
					return("BEQ");
				if(strcmp(comparador,">")==0)
					return("BGT");
				if(strcmp(comparador,"<")==0)
					return("BLT");
				if(strcmp(comparador,">=")==0)
					return("BGE");
				if(strcmp(comparador,"<=")==0)
					return("BLE");
				if(strcmp(comparador,"!=")==0)
					return("BNE");
				break;

			case inverso:
				if(strcmp(comparador,"==")==0)
					return("BNE");
				if(strcmp(comparador,">")==0)
					return("BLE");
				if(strcmp(comparador,"<")==0)
					return("BGE");
				if(strcmp(comparador,">=")==0)
					return("BLT");
				if(strcmp(comparador,"<=")==0)
					return("BGT");
				if(strcmp(comparador,"!=")==0)
					return("BEQ");
				break;
		}
	}
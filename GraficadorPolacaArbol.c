	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	#include <string.h>

typedef struct
	{
		char valor[31];
		int nroNodo;
	}t_info;

	typedef struct s_nodo
	{
	    t_info info;
	    struct s_nodo *izq;
	    struct s_nodo *der;
	}t_nodo;

	typedef struct s_nodoPila{
    	t_nodo info;
    	struct s_nodoPila* psig;
	}t_nodoPila;

	typedef t_nodoPila *t_pila;

	void vaciarPila(t_pila*);
	t_nodo * sacar_de_pila(t_pila*);
	int ponerEnPila(t_pila*,t_nodo*);
	void crearPila(t_pila*);
	void recorrerGenerandoViz(const t_nodo*, FILE*);
	void enumerarNodos(t_nodo *);
	void generarArchivoGraphViz(t_nodo *);
	t_nodo * copiarNodo(t_nodo*);
	void insertarHijo (t_nodo **, t_nodo *);
	t_nodo * crearHojaT(const char*);
	t_nodo * crearNodo(const t_info *, t_nodo *, t_nodo *);
	t_nodo * crearHoja(const t_info *);

	int nroNodo;
	t_pila pila;

//////////////////////////////////////////////////////////////////////////////////////////////

	t_nodo * crearHoja(const t_info *d)
	{
	    t_nodo *p = (t_nodo*) malloc(sizeof(t_nodo));
	    if(!p){ 
	    	printf("No hay memoria disponible. El programa se cerrará\n");
	    	exit(1);
	    }
	    p->info=*d;
	    p->der=p->izq=NULL;
	    return p;
	}

	t_nodo * crearNodo(const t_info *d, t_nodo * hijo_izq, t_nodo * hijo_der)
	{
	    t_nodo *p = (t_nodo*) malloc(sizeof(t_nodo));
	    if(!p){ 
	    	printf("No hay memoria disponible. El programa se cerrará\n");
	    	exit(1);
	    }
	    p->info=*d;
	    p->izq= hijo_izq;
	    p->der= hijo_der;
	    return p;
	}

	t_nodo * crearHojaT(const char* info)
	{
	    t_nodo *p = (t_nodo*) malloc(sizeof(t_nodo));
	    if(!p){ 
	    	printf("No hay memoria disponible. El programa se cerrará\n");
	    	exit(1);
	    }
	    strcpy(p->info.valor,info);
	    p->der=p->izq=NULL;
	    return p;
	}

	void insertarHijo (t_nodo ** puntero, t_nodo * hijo){
		*puntero=hijo;
	}

	t_nodo * copiarNodo(t_nodo* nodo){
		if(!nodo)
			return NULL;
		t_nodo *nuevo=(t_nodo*)malloc(sizeof(t_nodo));
		nuevo->info=nodo->info;
		if(nodo->izq)
			nuevo->izq=copiarNodo(nodo->izq);
		else
			nuevo->izq=NULL;
		if(nodo->der)
			nuevo->der=copiarNodo(nodo->der);
		else
			nuevo->der=NULL;
		return nuevo;
	}

	void generarArchivoGraphViz(t_nodo *raiz){
		nroNodo=0;
		enumerarNodos(raiz);
		FILE*pf=fopen("graphInfo.txt","w+");
		if(!pf){
			printf("Error al generar el archivo para GraphViz\n");
			return;
		}
		fprintf(pf, "graph g{\n");
		recorrerGenerandoViz(raiz,pf);
		fprintf(pf, "}\n");
		fclose(pf);
	}

	void enumerarNodos(t_nodo *n){
		if(n){
			n->info.nroNodo=nroNodo;
			nroNodo++;
			enumerarNodos(n->izq);
			enumerarNodos(n->der);
		}
	}

	void recorrerGenerandoViz(const t_nodo* nodo, FILE* pf)
	{
	    if(nodo)
	    {
	    	if(nodo->izq!=NULL&&nodo->der!=NULL){
	   			fprintf(pf,"\t%d[label=\"%s\"]\n", nodo->info.nroNodo,nodo->info.valor);
	   			fprintf(pf,"\t%d[label=\"%s\"]\n", nodo->izq->info.nroNodo,nodo->izq->info.valor);
	   			fprintf(pf,"\t%d[label=\"%s\"]\n", nodo->der->info.nroNodo,nodo->der->info.valor);
	   			if(nodo->izq)
	   				fprintf(pf,"\t%d--%d\n", nodo->info.nroNodo,nodo->izq->info.nroNodo);
	   			if(nodo->der)
	   				fprintf(pf,"\t%d--%d\n", nodo->info.nroNodo,nodo->der->info.nroNodo);
	   		}
	    	recorrerGenerandoViz(nodo->izq,pf);
	    	recorrerGenerandoViz(nodo->der,pf);
	    }
	}

//////////////////////////////////////////////////////////////////////////////////////////////

	void crearPila(t_pila* pp)
	{
	    *pp=NULL; 
	}

	int ponerEnPila(t_pila* pp,t_nodo* nodo)
	{
	    t_nodoPila* pn=(t_nodoPila*)malloc(sizeof(t_nodoPila));
	    if(!pn)
	        return 0;
	    pn->info=*nodo;
	    pn->psig=*pp;
	    *pp=pn;
	    return 1;
	}

	t_nodo * sacar_de_pila(t_pila* pp)
	{
		t_nodo* info = (t_nodo *) malloc(sizeof(t_nodo));
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

///////////////////////////////////////////////////////////////////////////////////

	int main ( void ){
		static const char filename[] = "intermedia.txt";
		FILE *file = fopen ( filename, "r" );
		crearPila(&pila);
		t_nodo* arbol;
		if ( file != NULL ){
			char line [ 128 ];
			while ( fgets ( line, sizeof line, file ) != NULL ){
				if (strlen(line)<=0)
				{
					//printf("Saliendo\n");
					generarArchivoGraphViz(arbol);
					return 0;
				}
				if(strchr(line, '+')!=NULL||strchr(line, '-')!=NULL||strchr(line, '=')!=NULL||strchr(line, '*')!=NULL||strchr(line, '/')!=NULL){
					t_info info;
					strcpy(info.valor,line);
					arbol=crearNodo(&info,sacar_de_pila(&pila),sacar_de_pila(&pila));
					//printf("Creado nodo: %s",line);
					ponerEnPila(&pila,arbol);
				}
				else{
					ponerEnPila(&pila,crearHojaT(line));
					//printf("ELSE. Puesto en pila: %s",line);
				}

			}
			generarArchivoGraphViz(arbol);
			fclose ( file );
		}
		else{
			perror ( filename );
		}
		return 0;
	}
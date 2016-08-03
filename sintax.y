%{
#include <stdio.h>
#include "tabla_sym.h"

extern int errors, lines, chars;

#define TABLE_FILE "tablasimbolos"


#define ERROR 0
#define WARNING 1
#define NOTE 2

#define KEY_TYPE -100

FILE *yyin;
char *arch;

extern int yylineno;
int yylex(); 
void yyerror();
int install(const char *lexeme, int type);
void install_keywords(char* keywords[], int n);
void install_id(char *name, int type);
void print_table(table_t table);
char *strbuild(int option, const char *str1, const char *str2);
void print_cursor();
void get_line(char *line);
#define YYDEBUG 1 

%}

%start programa


%token  MAIN 

%token DOSPUNTOS COMA PCOMA IGUAL PAR_A PAR_C COR_A COR_C LLAV_A LLAV_C   

%token IF ELSE THEN DO WHILE INPUT OUTPUT RETURN

%token TD_ENTERO TD_DECIMAL TD_BOLEANO TD_CARACTER TD_CADENA
%token INTEGER FLOAT STRING CHAR BOOLEAN
%token IDENT 

%union {char *lexeme;
	int integer; 
	float real;
	}

%type<lexeme> IDENT
%type<integer> INTEGER l_expr l_factor
%type<real> FLOAT g_expr g_term g_factor
%type<bool> BOOLEAN

%left '+' '-'
%left '*' '/'
%left L_IGUAL L_MAYQ L_MAYIQ L_MENQ L_MENIQ L_AND L_OR
%right IGUAL
%right L_NOT

%glr-parser
 
%%
programa		:declaracion MAIN PAR_A PAR_C LLAV_A comandos LLAV_C funcion
			|error {yyerror("formato principal invalido",ERROR);};

		

declaracion		:TD_ENTERO DOSPUNTOS IDENT{install_id($3,TD_ENTERO);} 
			|TD_DECIMAL DOSPUNTOS IDENT{install_id($3,TD_DECIMAL);}
			|TD_BOLEANO DOSPUNTOS IDENT{install_id($3,TD_BOLEANO);};


funcion			:%empty
			| IDENT PAR_A PAR_C  LLAV_A comandos LLAV_C funcion
|error {yyerror("formato principal invalido",ERROR);};
				


comandos		:listacomandos;			

listacomandos		:comando listacomandos
			|%empty;



comando: 		kw_dec_atrib 
			| controlFlujo
			|error {yyerror("instruccion incorrecta o faltante",ERROR);};

kw_dec_atrib:		RETURN|
			INPUT|
			OUTPUT|
			atribucion|
			declaracion;


controlFlujo		:flujo_if
			|flujo_while
			|flujo_dowhile;

atribucion		:atribucion_i
			|IDENT IGUAL IDENT{

char *str;
	if(get_entry($1) != NULL) {
		
		if(get_entry($3) != NULL) {
			if(get_type($1) == get_type($3)) {
				set_value($1, get_value($3));
			}
			else {
				str = (char *)strbuild(0,
						(char *)strbuild(1, "tipos de datos incompatibles en '%s' ", $1),
						(char *)strbuild(1, "y '%s'", $3)
						);
			}
		}
		else {
			str = (char *)strbuild(1, "declaracion de '%s' no encontrada", $1);
			yyerror(str, ERROR);
		}
	}
	else {
		str = (char *)strbuild(1, "declaracion de '%s' no encontrada", $1);
		yyerror(str, ERROR);
	}

}
| error { yyerror("formato invalido de atribucion", ERROR);};


atribucion_i: IDENT IGUAL g_expr {
	if(get_entry($1)) {
		// if they have the same type
		if(get_type($1) == TD_ENTERO) {
			// does the attribution
			set_value($1,(int) $3);
		}
		else if(get_type($1) == TD_DECIMAL) {
			// does the attribution
			set_value($1,(float) $3);
		}
		
		else if(get_type($1) == TD_BOLEANO) {
			// does the attribution
			if($3>0&&$3<1){

			set_value($1,0);}
			else if($3>1&&$3<2)
				{set_value($1,1);}
else {
			yyerror("tipos de datos incompatibles", WARNING);
		}

			}
		
		else {
			yyerror("tipos de datos incompatibles", WARNING);
		}
	}
	else {
		char *str = (char *)strbuild(1, "declaracion de '%s' no encontrada", $1);
		yyerror(str, ERROR);
	}
};

g_expr: g_expr '+' g_term { $$ = $1 + $3; }
      | g_expr '-' g_term { $$ = $1 - $3; } 
      | g_term { $$ = $1; }
;


g_term: g_term '*' g_factor { $$ = $1 * $3; } 
      | g_term '/' g_factor { $$ = $1 / $3; } 
      | g_factor { $$ = $1; }
;

g_factor: PAR_A g_expr PAR_C { $$ = $2; }
        | INTEGER { $$ = $1; }
	| FLOAT { $$ = $1; }
;
	





 flujo_if	:IF PAR_A l_expr PAR_C THEN LLAV_A comandos LLAV_C flujo_else

flujo_else	:%empty
		|ELSE LLAV_A comandos LLAV_C;

		 		
flujo_while	:WHILE PAR_A l_expr PAR_C DO LLAV_A comandos LLAV_C;
		
flujo_dowhile	:DO LLAV_A comandos LLAV_C WHILE PAR_A l_expr PAR_C PCOMA
		;
l_expr: l_expr L_IGUAL l_factor { $$ = $1 == $3; }
      | l_expr L_AND l_factor { $$ = $1 && $3; }
      | l_expr L_OR l_factor { $$ = $1 || $3; }
      | l_expr L_MAYQ l_factor { $$ = $1 > $3; }
      | l_expr L_MENQ l_factor { $$ = $1 < $3; }
      | L_NOT l_expr { $$ = !$2; }
      | l_factor
      ;

l_factor: PAR_A l_expr PAR_C { $$ = $2; }
| INTEGER { $$ = $1; }
| FLOAT { $$ = $1; }
| IDENT {            
	
	if(get_entry($1)) {
		$$ = (int) get_value($1);
	}
	else {
		char *str = (char *)strbuild(1, "declaracion de '%s' no encontrada", $1);
		yyerror(str, ERROR);
	}
};


%%




int main (int argc, char **argv){

char* keywords[] = { "if", "else", "do", "while", "input", "output",
"return", "int","float","bool","string"};
++argv, --argc;
	if ( argc > 0 ) {
		arch = strdup(argv[0]);
		yyin = fopen( argv[0], "r" );
}

else {
		arch = strdup("stdin");
		yyin = stdin;
}

init_table();

install_keywords(keywords, 11);

yyparse();

if(errors==0) {
		printf("Analisis finalizado\n");
	}
	else {
		printf("Se han encontrado %d errores\n", errors);
}

print_table(table);

return 0;

}

int install(const char *lexeme, int type) {
	int success = 1;
	entry_t *e;

	e = (entry_t *)get_entry(lexeme);
	if(e == 0) {
		/* Packs the data in a new entry and puts it
		 * at the head of the table
		 */
		put_entry((entry_t *)create_entry(type, lexeme, 0));
	}
	else {
		// It's already in the table
		success = 0;
	}
	return success;
}

//palabras en la tabla

//Inserts all keywords at the beginning of the symbol table
void install_keywords(char* keywords[], int n) {
	int i;
	for(i = 0; i < n; i++) {
		install(keywords[i], KEY_TYPE);
	}
}


//imprimir tabla

void print_table(table_t table) {
	FILE *f = fopen (TABLE_FILE, "w");
	int i;
	entry_t *cur;
	
			fprintf(f, "TABLA DE SÍMBOLOS\n""%d entradas\n\n", table.t_size);

			fprintf(f, "|  #   |    tipodato  |         VALOR        |\n");

for(i = 1, cur = table.t_head;
	    cur != NULL;
	    cur = cur->next, i++) {
		if(cur->type == TD_ENTERO) {
			fprintf(f, "| %-5d | 	ENTERO   |  %s = %d\n", i, cur->lexeme, (int) cur->value);
		} 
		else if(cur->type == TD_DECIMAL) {
			fprintf(f, "| %-5d |   FLOTANTE  |  %s = %f\n", i, cur->lexeme, (float) cur->value);
		} 
		else if(cur->type == TD_BOLEANO) {
			fprintf(f, "| %-5d |   BOOLEANO  |  %s = %f\n", i, cur->lexeme,  cur->value);
		} 
		else if(cur->type == KEY_TYPE) {
			fprintf(f, "| %-5d |   PALABRA   |  %s\n", i, cur->lexeme);
		}
	}

	 
}


void yyerror(const char *msg, int type) {
	if(strcmp(msg, "syntax error") == 0) {
		printf("Error Sintactico\n");
	}
	else {
		
		switch(type) {
			case ERROR:
				printf("%s:%d:%d: Error: %s\n", arch, lines, chars, msg);
				break;

			case WARNING:
				printf("%s:%d:%d: Advertencia: %s\n", arch, lines, chars, msg);
				break;

			case NOTE:
				printf("%s:%d:%d: Nota: %s\n", arch, lines, chars, msg);
				break;

			default:
				printf("%s:%d:%d: Error: %s\n", arch, lines, chars, msg);
		}

		errors++;
		print_cursor();
	}
}


void install_id(char *name, int type) {
	// checks if ID is in symbol table, if it's not then installs it
	if(install(name, type)) {
		// successfully installed it
		//printf("%s was installed.\n", name);
	}
	else {
		int t = get_type(name);
		char *str;
		if(t == type) {
			str = (char *)strbuild(1, "Redeclaracion de '%s'", name);
		}
		else {
			str = (char *)strbuild(1, "Tipos conflictivos para '%s'", name);
		}
		yyerror(str, NOTE);
	}
}

char *strbuild(int option, const char *str1, const char *str2) {
	char *full_str;

	if(option == 1) {
		int size;
		// allocates the size of the resulting string
		size = snprintf(NULL, 0, str1, str2);
		full_str = (char *)malloc(size+1);

		// if there's space then prints into the string
		if(full_str != NULL) {
			snprintf(full_str, size+1, str1, str2);
		}
		// or just returns the first value
		else {
			full_str = (char *)strdup(str1);
		}
	}
	else {
		// concatenates
		full_str = (char *)malloc((strlen(str1) + strlen(str2)) * sizeof(char));
                if(full_str != NULL) {
			strcat(full_str, str1);
			strcat(full_str, str2);
		}
	}

	return full_str;
}


void print_cursor() {
	int i;
	char line[256];

	get_line(line);
	printf("%s", line);

	for(i=0; i<chars-1; i++) {
		if(line[i] == '\t') {
			printf("\t");
		}
		else {
			printf(" ");
		}
	}
	printf("^^\n");
}

void get_line(char *line) {
	int i;
	fpos_t position;

	// saves current position in file
	fgetpos(yyin, &position);

	//fseek(yyin, 0, SEEK_SET);
	rewind(yyin);
	for(i=0; i<lines; i++) {
		fgets(line, 256, yyin);
	}

	// recover position in file
	fsetpos(yyin, &position);
}














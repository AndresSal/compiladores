%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sintax.tab.h"

int lines=1, chars=0, errors=0;
void count_lib(char*str, int leng, int *c,int *l);

void yyerror(char *);
char mensaje[100];

%}

/* numeros */
numero [0-9]
entero (-)?{numero}+
real 	(-)?{numero}*\.{numero}+
boolean "true"|"false"

/*letras */
caracter [a-zA-Z]
ID	[a-zA-Z][a-zA-Z0-9]*
string (\"[^\"]*\")


/*espacios en blanco */
omitir [ \t]
saltolinea \n|\r

%option noyywrap
%option yylineno
%option noinput
%option nounput

%%
 /*alcance*/
"[" 		{chars++;return COR_A;}
"]" 		{chars++;return COR_C;}
"("		{chars++;return PAR_A;}
")"		{chars++;return PAR_C;}
"{"		{chars++;return LLAV_A;}
"}"		{chars++;return LLAV_C;}
 /*simbolos*/

";"		{chars++;return PCOMA;}
":"		{chars++;return DOSPUNTOS;}
","		{chars++;return COMA;}
"=" 		{chars++;return IGUAL;}

"<"		{chars+=yyleng; return L_MENQ;}
"<="		{chars+=yyleng; return L_MENIQ;}
">"		{chars+=yyleng; return L_MAYQ;}
">="		{chars+=yyleng; return L_MAYIQ;}
"=="		{chars+=yyleng; return L_IGUAL;}
"&&"		{chars+=yyleng; return L_AND;}
"||"            {chars+=yyleng; return L_OR;}
"!"		{chars+=yyleng; return L_NOT;}
"+" |	
"-" |
"*" |
"/" {chars++;return yytext[0];}		


 /*palabras reservadas*/
"main"		{chars+=yyleng;return MAIN;}
"return" 	{chars+=yyleng;return RETURN;}
"if" 		{chars+=yyleng;return IF;}
"else"	 	{chars+=yyleng;return ELSE;}
"then" 		{chars+=yyleng;return THEN;}
"do" 		{chars+=yyleng;return DO;}
"while" 	{chars+=yyleng;return WHILE;}
"input" 	{chars+=yyleng;return INPUT;}
"output" 	{chars+=yyleng;return OUTPUT;}

 /*tipos de dato*/
"int" 		{chars+=yyleng;return TD_ENTERO;}
"float" 	{chars+=yyleng;return TD_DECIMAL;}
"boolean" 	{chars+=yyleng;return TD_BOLEANO;}
"char" 		{chars+=yyleng;return TD_CARACTER;}
"string" 	{chars+=yyleng;return TD_CADENA;}

({entero}|{real}|{boolean}){ID} {
	printf("( %3d : %-3d ) identificador inválido: %s\n", lines, chars, yytext);
	chars += yyleng;
	errors++;
}

 /*valores*/
{boolean} 	{yylval.lexeme=(char*)strdup(yytext);return BOOLEAN;}
{entero} 	{yylval.integer=(int)atoi(yytext); return INTEGER;}
{real} 		{yylval.real=(float)atof(yytext);return FLOAT;}
{string} 	{count_lb(yytext, yyleng,&chars,&lines);return STRING;}
"\'"{caracter}{0,1}"\'" 	{yylval.lexeme=(char *)strdup(yytext);return CHAR;}
{ID}			{yylval.lexeme = (char *)strdup(yytext);
			chars+=yyleng;return IDENT;}
 /*comentarios*/
"//".*? 		{lines++;}
"/*"[^"*/"]* 		{lines++;}

{omitir}+		{chars++;}
{saltolinea}+		{chars=0;lines++;}
. 	{sprintf(mensaje, " Error Lexico  (Linea: %d) entrada no permitida", yylineno); yyerror(mensaje);chars++;
errors++;}
%%


void count_lb(char *str, int leng, int *c, int *l) {
	int i;

	for(i=0; i<leng; i++) {
		(*c)++;
		if(str[i] == '\n') {
			(*l)++;
			*c = 0;
		}
	}
}





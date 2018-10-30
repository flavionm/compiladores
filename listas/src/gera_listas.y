%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

using namespace std;

#define YYSTYPE Atributos

int linha = 1;
int coluna = 1;

struct Atributos {
	string valor;
	string codigo;
	int linha;
};

struct Lista {
	bool sublista;
	string valorString;
	Lista* valorSublista;
	Lista* proximo;
};

int yylex();
int yyparse();
void yyerror(const char *);

%}

%start S
%token TK_CINT TK_CDOUBLE TK_ID

%%

S : L { cout << "Saida:\n"
						 << "Lista t1;\n"
						 << $1.codigo << endl; }
	;

L : A ',' L
	| A
	;

A : TK_ID    { $$.codigo = (string) "t1.sublista = false;\n" +
													 "t1.valorString = \"" + $1.valor + "\";\n" +
													 "t1.valorSublista = nullptr;\n" +
													 "t1.proximo = nullptr;\n"; }
	| TK_CINT
	| TK_CDOUBLE
	| '(' L ')'	{ $0 = $2; }
	;

%%

#include "lex.yy.c"

void yyerror( const char* st ) {
	 puts( st );
	 printf( "Linha %d, coluna %d, proximo a: %s\n", linha, coluna, yytext );
	 exit( 0 );
}

int main()
{
	yyparse();
}

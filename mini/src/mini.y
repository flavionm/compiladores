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
	string v;
	string c;
	int linha;
};

int yylex();
int yyparse();
void yyerror (const char *);

string geraNomeVar();

int nVar = 0;

%}

%start S
%token CINT CDOUBLE TK_ID TK_VAR TK_CONSOLE TK_SHIFTR TK_SHIFTL
%token TK_FOR TK_IN TK_2PT TK_IF TK_THEN TK_ELSE

%left '+' '-'
%left '*' '/'

%%

S:	CMDS {
		cout << $1.c << endl;
	}
	;

CMDS:	CMDS CMD ';' {
			$$.c = $1.c + $2.c;
		}
		| CMD ';'
		;

CMD:	DECLVAR
		| ENTRADA
		| SAIDA
		| ATR
		| FOR
		| IF
		;

DECLVAR:	TK_VAR VARS {
				$$.c = "int " + $2.c + ";\n";
			}
			;

VARS:	VARS ',' VAR {
			$$.c = $1.c + ", " + $3.c;
		}
		| VAR
		;

VAR:	TK_ID '[' CINT ']' {
			$$.c = $1.v + "[" + $3.v + "]";
		}
		| TK_ID {
			$$.c = $1.v;
		}
		;

ENTRADA:	TK_CONSOLE TK_SHIFTR TK_ID {
				$$.c = "cin >> " + $3.v + ";\n";
			}
			| TK_CONSOLE TK_SHIFTR TK_ID '[' E ']' {
				$$.v = geraNomeVar();
				$$.c = $5.c
				+ "cin >> " + $$.v + ";\n"
				+ $3.v + "[" + $5.v + "] = " + $$.v + ";\n";
			}
			;

SAIDA:	TK_CONSOLE TK_SHIFTL E {
			$$.c = $3.c + "cout << " + $3.v + " << endl;\n";
		}
		;

FOR:	TK_FOR TK_ID TK_IN '[' E TK_2PT E ']' CMD {
			string cond = geraNomeVar();
			$$.c = $5.c	+ $7.c
			+ $2.v + " = " + $5.v + ";\n"
			+ "meio:\n" + cond + " = " + $2.v + " > " + $7.v + ";\n"
			+ "if( " + cond + ") goto fim;\n"
			+ $9.c
			+ $2.v + " = " + $2.v + " + 1;\n"
			+ "goto meio;\n"
			+ "fim:\n";
		}
		;

IF:	TK_IF E TK_THEN CMD TK_ELSE CMD
	;

ATR:	TK_ID '=' E ';' {
			$$.v = $3.v;
			$$.c = $3.c + $1.v + " = " + $3.v + ";\n";
		}
		| TK_ID '[' E ']' '=' E ';' {
			$$.c = $3.c + $6.c
			+ $1.v + "[" + $3.v + "] = " + $6.v + ";\n";
			$$.v = $6.v;
		}
		;

E:	E '+' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ $$.v + " = " + $1.v + "+" + $3.v + ";\n";
	}
	| E '-' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ $$.v + " = " + $1.v + "-" + $3.v + ";\n";
	}
	| E '*' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ $$.v + " = " + $1.v + "*" + $3.v + ";\n";
	}
	| E '/' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ $$.v + " = " + $1.v + "/" + $3.v + ";\n";
	}
	| V
	;

V:	TK_ID '[' E ']' {
		$$.v = geraNomeVar();
		$$.c = $3.c + $$.v
		+ " = " + $1.v + "[" + $3.v + "];\n";
	}
	| TK_ID {
		$$.c = "";
		$$.v = $1.v;
	}
	| CINT {
		$$.c = "";
		$$.v = $1.v;
	}
	| '(' E ')' {
		$$ = $2;
	}
	;

%%

#include "lex.yy.c"

void yyerror (const char* st) {
	puts (st);
	printf ("Linha %d, coluna %d, proximo a: %s\n", linha, coluna, yytext);
	exit (0);
}

string geraNomeVar() {
	char buf[20] = "";

	sprintf (buf, "t%d", nVar++);

	return buf;
}

int main () {
	yyparse();

	return 0;
}

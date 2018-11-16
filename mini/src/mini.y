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
string geraNomeLabel (string);
string declaraVars();

int nVar = 0;
int nLabel = 0;

%}

%start S
%token CINT CSTR CDOUBLE TK_ID TK_VAR TK_CONSOLE TK_SHIFTR TK_SHIFTL TK_EQUALS
%token TK_FOR TK_IN TK_2PT TK_IF TK_THEN TK_ELSE TK_ENDL TK_BEGIN TK_END

%right '='
%nonassoc '>' '<' TK_EQUALS
%left '+' '-'
%left '*' '/' '%'

%%

S:	CMDS {
		$$.c = string("#include <iostream>\n\n")
		+ "using namespace std;\n\n"
		+ "int main () {\n"
		+ "\t" + declaraVars() + "\n"
		+ $1.c + "\n"
		+ "\treturn 0;\n"
		+ "}";
		cout << $$.c << endl;
	}
	;

BLOCK:	TK_BEGIN CMDS TK_END {
			$$.c = $2.c;
		}
		| CMD
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
				$$.c = "\tint " + $2.c + ";\n";
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

ENTRADA:	ENTRADA TK_SHIFTR TK_ID {
				$$.c = $1.c
				+ "\tcin >>" + $3.v + ";\n";
			}
			| ENTRADA TK_SHIFTR TK_ID '[' E ']' {
				$$.v = geraNomeVar();
				$$.c = $1.c + $5.c
				+ "\tcin >> " + $$.v + ";\n"
				+ "\t" + $3.v + "[" + $5.v + "] = " + $$.v + ";\n";
			}
			| TK_CONSOLE TK_SHIFTR TK_ID {
				$$.c = "\tcin >> " + $3.v + ";\n";
			}
			| TK_CONSOLE TK_SHIFTR TK_ID '[' E ']' {
				$$.v = geraNomeVar();
				$$.c = $5.c
				+ "\tcin >> " + $$.v + ";\n"
				+ "\t" + $3.v + "[" + $5.v + "] = " + $$.v + ";\n";
			}
			;

SAIDA:	SAIDA TK_SHIFTL E {
			$$.c = $1.c + $3.c
			+ "\t" + "cout << " + $3.v + ";\n";
		}
		| SAIDA TK_SHIFTL STRING {
			$$.c = $1.c
			+ "\tcout << " + $3.v + ";\n";
		}
		| TK_CONSOLE TK_SHIFTL E {
			$$.c = $3.c
			+ "\tcout << " + $3.v + ";\n";
		}
		| TK_CONSOLE TK_SHIFTL STRING {
			$$.c = string("\tcout << ") + $3.v + ";\n";
		}
		;

STRING:	CSTR
		| TK_ENDL {
			$$.v = "endl";
		}
		;

FOR:	TK_FOR TK_ID TK_IN '[' E TK_2PT E ']' BLOCK {
			string cond = geraNomeVar();
			$$.c = $5.c	+ $7.c
			+ "\t" + $2.v + " = " + $5.v + ";\n"
			+ "\t" + geraNomeLabel("for_mid") + ":\n"
			+ "\t" + cond + " = " + $2.v + " > " + $7.v + ";\n"
			+ "\tif (" + cond + ") goto " + geraNomeLabel("end_for") + ";\n"
			+ $9.c
			+ "\t" + $2.v + " = " + $2.v + " + 1;\n"
			+ "\tgoto " + geraNomeLabel("for_mid") + ";\n"
			+ "\t" + geraNomeLabel("end_for") + ":\n";
			nLabel++;
		}
		;

IF:	TK_IF E TK_THEN BLOCK TK_ELSE BLOCK {
		$$.c = $2.c
		+ "\tif (" + $2.v + ") goto " + geraNomeLabel("if_true") + ";\n"
		+ $6.c
		+ "\tgoto " + geraNomeLabel("end_if") + ";\n"
		+ "\t" + geraNomeLabel("if_true") + ":\n"
		+ $4.c
		+ "\t" + geraNomeLabel("end_if") + ":\n";
		nLabel++;
	}
	| TK_IF E TK_THEN BLOCK {
		$$.c = $2.c
		+ "\tif (" + $2.v + ") goto " + geraNomeLabel("if_true") + ";\n"
		+ "\tgoto " + geraNomeLabel("end_if") + ";\n"
		+ "\t" + geraNomeLabel("if_true") + ":\n"
		+ $4.c
		+ "\t" + geraNomeLabel("end_if") + ":\n";
		nLabel++;
	}
	;

ATR:	TK_ID '=' E {
			$$.v = $3.v;
			$$.c = $3.c
			+ "\t" + $1.v + " = " + $3.v + ";\n";
		}
		| TK_ID '[' E ']' '=' E {
			$$.c = $3.c + $6.c
			+ "\t" + $1.v + "[" + $3.v + "] = " + $6.v + ";\n";
			$$.v = $6.v;
		}
		;

E:	E '+' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ "\t" + $$.v + " = " + $1.v + "+" + $3.v + ";\n";
	}
	| E '-' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ "\t" + $$.v + " = " + $1.v + "-" + $3.v + ";\n";
	}
	| E '*' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ "\t" + $$.v + " = " + $1.v + "*" + $3.v + ";\n";
	}
	| E '/' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ "\t" + $$.v + " = " + $1.v + "/" + $3.v + ";\n";
	}
	| E '%' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ "\t" + $$.v + " = " + $1.v + "%" + $3.v + ";\n";
	}
	| E '>' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ "\t" + $$.v + " = " + $1.v + ">" + $3.v + ";\n";
	}
	| E '<' E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ "\t" + $$.v + " = " + $1.v + "<" + $3.v + ";\n";
	}
	| E TK_EQUALS E {
		$$.v = geraNomeVar();
		$$.c = $1.c + $3.c
		+ "\t" + $$.v + " = " + $1.v + "==" + $3.v + ";\n";
	}
	| V
	;

V:	TK_ID '[' E ']' {
		$$.v = geraNomeVar();
		$$.c = $3.c
		+ "\t" + $$.v + " = " + $1.v + "[" + $3.v + "];\n";
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

	sprintf (buf, "_t%d", nVar++);

	return buf;
}

string geraNomeLabel (string nome) {
	return "_" + nome + to_string(nLabel);
}

string declaraVars() {
	string vars = "int __";

	for (int i = 0; i < nVar; i++) {
		vars += ", _t" + to_string(i);
	}
	vars += ";\n";

	return vars;
}

int main () {
	yyparse();

	return 0;
}

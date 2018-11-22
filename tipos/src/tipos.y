%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>

using namespace std;

#define YYSTYPE Atributos
#define SSIZE "257"

int linha = 1;
int coluna = 1;

typedef string Tipo;

struct Atributos {
	string v;
	string c;
	Tipo t;
	int linha;
};

extern "C" int yylex();
int yyparse();
void yyerror (const char *);

Tipo buscaTipoVar (string v);
string geraNomeVar (Tipo t);
string geraNomeLabel (string);
string declaraVars();
bool isArithmethic (string operador);
bool isComparison (string operador);
Tipo buscaTipoOperacao (string operador, Tipo a, Tipo b);
Atributos geraCodigoOperador (string operador, Atributos a, Atributos b);

map<Tipo, Tipo> impl {
	{"int", "int"}, {"real", "double"}, {"bool", "int"},
	{"char", "char"}, {"string", "char"}
};
map<Tipo, int> nVar {
	{"int", 0}, {"real", 0}, {"bool", 0}, {"char", 0}, {"string", 0}
} ;
int nLabel = 0;
map<string, Tipo> var_symtab {};
map<string,Tipo> resOpr = {
	{"+intint", "int"}, {"+intreal", "real"}, {"+realint", "real"}, {"+realreal", "real"},
	{"+charchar", "string"}, {"+charstring", "string"}, {"+stringchar", "string"}, {"+stringstring", "string"},
	{"+charint", "int"}, {"+intchar", "int"}, {"+charreal", "real"}, {"+realchar", "real"},
	{"*intint", "int"}, {"*intreal", "real"}, {"*realint", "real"}, {"*realreal", "real"},
	{"*charint", "int"}, {"*intchar", "int"}, {"*charreal", "real"}, {"*realchar", "real"},
	{"%intint", "int"},
	{"%charint", "int"}, {"%intchar", "int"},
	{">intint", "bool"}, {">intreal", "bool"}, {">realint", "bool"}, {">realreal", "bool"},
	{">charchar", "bool"}, {">charstring", "bool"}, {">stringchar", "bool"}, {">stringstring", "bool"},
	{">charint", "bool"}, {">intchar", "bool"}, {">charreal", "bool"}, {">realchar", "bool"}
};

%}

%start S
%token CINT CSTR CDOUBLE CCHAR TK_ID TK_CONSOLE TK_SHIFTR TK_SHIFTL TK_EQUALS
%token TK_FOR TK_IN TK_2PT TK_IF TK_THEN TK_ELSE TK_ENDL TK_BEGIN TK_END
%token TK_INT TK_REAL TK_BOOL TK_CHAR TK_STRING

%right '='
%nonassoc '>' '<' TK_EQUALS
%left '+' '-'
%left '*' '/' '%'

%%

S:	CMDS {
		$$.c = string("#include <iostream>\n")
		+ "#include <string.h>\n\n"
		+ "using namespace std;\n\n"
		+ "int main () {\n"
		+ declaraVars() + "\n"
		+ $1.c + "\n"
		+ "\treturn 0;\n"
		+ "}";
		cout << $$.c << endl;
	}
	;

BLOCK:	TK_BEGIN CMDS TK_END {
			$$ = $2;
		}
		| CMD
		;

CMDS:	CMDS CMD {
			$$.c = $1.c + $2.c;
		}
		| CMD
		;

CMD:	DECLVAR ';'
		| ENTRADA ';'
		| SAIDA ';'
		| ATR ';'
		| FOR ';'
		| IF
		;

DECLVAR:	DECLVAR ',' VAR {
				string array = "";
				if ($1.v == "string")
					array = string("[") + SSIZE + "]";
				$$.c = $1.c
				+ "\t" + impl[$1.v] + " " + $3.v + array + ";\n";
				$$.v = $1.v;
				var_symtab[$3.v] = $1.v;
			}
			| TYPE VAR {
				string array = "";
				if ($1.v == "string")
					array = string("[") + SSIZE + "]";
				$$.c = "\t" + impl[$1.v] + " " + $2.v + array + ";\n";
				$$.v = $1.v;
				var_symtab[$2.v] = $1.v;
			}
			;

TYPE:	TK_INT
		| TK_REAL
		| TK_BOOL
		| TK_CHAR
		| TK_STRING
		;

VAR:	/*TK_ID '[' CINT ']' {
			$$.c = $1.v + "[" + $3.v + "]";
		}
		|*/ TK_ID
		;

ENTRADA:	ENTRADA TK_SHIFTR TK_ID {
				$$.c = $1.c
				+ "\tcin >>" + $3.v + ";\n";
			}
			/*| ENTRADA TK_SHIFTR TK_ID '[' E ']' {
				$$.v = geraNomeVar();
				$$.c = $1.c + $5.c
				+ "\tcin >> " + $$.v + ";\n"
				+ "\t" + $3.v + "[" + $5.v + "] = " + $$.v + ";\n";
			}*/
			| TK_CONSOLE TK_SHIFTR TK_ID {
				$$.c = "\tcin >> " + $3.v + ";\n";
			}
			/*| TK_CONSOLE TK_SHIFTR TK_ID '[' E ']' {
				$$.v = geraNomeVar();
				$$.c = $5.c
				+ "\tcin >> " + $$.v + ";\n"
				+ "\t" + $3.v + "[" + $5.v + "] = " + $$.v + ";\n";
			}*/
			;

SAIDA:	SAIDA TK_SHIFTL E {
			$$.c = $1.c + $3.c
			+ "\tcout << " + $3.v + ";\n";
		}
		| SAIDA TK_SHIFTL TK_ENDL {
			$$.c = $1.c
			+ "\tcout << " + $3.v + ";\n";
		}
		| TK_CONSOLE TK_SHIFTL E {
			$$.c = $3.c
			+ "\tcout << " + $3.v + ";\n";
		}
		| TK_CONSOLE TK_SHIFTL TK_ENDL {
			$$.c = "\tcout << " + $3.v + ";\n";
		}
		;

FOR:	TK_FOR TK_ID TK_IN '[' E TK_2PT E ']' BLOCK {
			string cond = geraNomeVar("bool");
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

IF:	TK_IF E TK_THEN BLOCK TK_ELSE BLOCK ';' {
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
			if ($3.t == "string") {
				$$.c = $3.c
				+ "\tstrncpy (" + $1.v + ", " + $3.v + ", " + SSIZE + ");\n";
			} else {
				$$.c = $3.c
				+ "\t" + $1.v + " = " + $3.v + ";\n";
			}
		}
		/*| TK_ID '[' E ']' '=' E {
			$$.c = $3.c + $6.c
			+ "\t" + $1.v + "[" + $3.v + "] = " + $6.v + ";\n";
			$$.v = $6.v;
		}*/
		;

E:	E '+' E {
		$$ = geraCodigoOperador ($2.v, $1, $3);
	}
	| E '-' E {
		$$ = geraCodigoOperador ($2.v, $1, $3);
	}
	| E '*' E {
		$$ = geraCodigoOperador ($2.v, $1, $3);
	}
	| E '/' E {
		$$ = geraCodigoOperador ($2.v, $1, $3);
	}
	| E '%' E {
		$$ = geraCodigoOperador ($2.v, $1, $3);
	}
	| E '>' E {
		$$ = geraCodigoOperador ($2.v, $1, $3);
	}
	| E '<' E {
		$$ = geraCodigoOperador ($2.v, $1, $3);
	}
	| E TK_EQUALS E {
		$$ = geraCodigoOperador ($2.v, $1, $3);
	}
	| V
	;

V:	/*TK_ID '[' E ']' {
		$$.v = geraNomeVar();
		$$.c = $3.c
		+ "\t" + $$.v + " = " + $1.v + "[" + $3.v + "];\n";
	}
	|*/ TK_ID {
		$$.v = $1.v;
		$$.t = buscaTipoVar($1.v);
	}
	| CINT {
		$$.v = $1.v;
		$$.t = "int";
	}
	| CDOUBLE {
		$$.v = $1.v;
		$$.t = "real";
	}
	| CSTR {
		$$.v = $1.v;
		$$.t = "string";
	}
	| CCHAR {
		$$.v = $1.v;
		$$.t = "char";
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

Tipo buscaTipoVar (string v) {
	if (var_symtab.find(v) == var_symtab.end()) {
		string temp = "Variavel '" + v + "' nao definida\n";
		yyerror(temp.c_str());
	}
	return var_symtab[v];
}

string geraNomeVar(Tipo t) {
	return "_" + t + "_t" + to_string(nVar[t]++);
}

string geraNomeLabel (string nome) {
	return "_label_" + nome + to_string(nLabel);
}

string declaraVars() {
	string vars;

	for (auto p : nVar) {
		string array = "";
		if (p.first == "string")
			array = string("[") + SSIZE + "]";
		for (int i = 0; i < p.second; i++)
			vars += "\t" + impl[p.first] + " _" + p.first + "_t" + to_string(i) + array + ";\n";
	}

	return vars;
}

bool isArithmethic (string operador) {
	return operador == "-" || operador == "*" || operador == "/";
}

bool isComparison (string operador) {
	return operador == ">" || operador == "<" || operador == "==";
}

Tipo buscaTipoOperacao (string operador, Tipo a, Tipo b) {
	string oprGroup;
	if (isArithmethic(operador))
		oprGroup = "*";
	else if (isComparison(operador))
			oprGroup = ">";
	else
		oprGroup = operador;
	return resOpr[oprGroup + a + b];
}

Atributos geraCodigoOperador (string operador, Atributos a, Atributos b) {
	Atributos r;

	r.t = buscaTipoOperacao (operador, a.t, b.t);
	if (r.t == "") {
		string temp = "Operacao '" + operador + "' inválida entre " + a.t + " e " + b.t;
		yyerror( temp.c_str() );
	}

	r.v = geraNomeVar (r.t);
	if (r.t == "string") {
		if (operador == "+") {
			r.v = geraNomeVar (r.t);
			r.c = a.c + b.c
			+ "\tstrncpy (" + r.v + ", " + a.v + ", " + SSIZE + ");\n"
			+ "\tstrncat (" + r.v + ", " + b.v + ", " + SSIZE + ");\n";
		} else if (isComparison(operador)) {
			r.v = geraNomeVar ("bool");
			string tempVar = geraNomeVar("int");
			r.c = a.c + b.c
			+ "\t" + tempVar + " = strncmp (" + a.v + ", " + b.v + ", " + SSIZE + ");\n"
			+ "\t" + r.v + " = " + tempVar + operador + "0;\n";
		}
	}
	else {
		r.v = geraNomeVar (r.t);
		r.c = a.c + b.c
		+ "\t" + r.v + " = " + a.v + " " + operador + " " + b.v + ";\n";
	}

	return r;
}

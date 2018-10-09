%{ // Código em C/C++
#include <stdio.h>
#include <string>

using namespace std;

enum TOKEN { _INT = 256, _FLOAT, _ID, _IF, _MAIG };

%}

/* Coloque aqui definições regulares */

D	[0-9]
L	[A-Za-z_]

WS	[ \t\n]
INT	{D}+
FLOAT	{INT}("."{INT})?([Ee]("+"|"-")?{INT})?
ID	{L}({L}|{D})*

%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */

{WS}	{ /* ignora espaço */ }
"if"	{ return _IF; }
{INT}	{ return _INT; }
{FLOAT}	{ return _FLOAT; }
{ID}	{ return _ID; }

">="	{ return _MAIG; }

.       { return *yytext; /* Essa deve ser a última regra. Dessa forma qualquer caractere isolado será retornado pelo seu código ascii. */ }

%%

/* Não coloque nada aqui - a função main é automaticamente incluída na hora de avaliar e dar a nota. */

int main() {
    int token = 0;

    while( (token = yylex()) != EOF )
        printf( "Token: %d %s\n", token, yytext );

    return 0;
}

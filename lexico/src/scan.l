%{ // Código em C/C++
#include <stdio.h>
#include <string>

using namespace std;

enum TOKEN {_ID = 256, _FOR, _IF, _INT, _FLOAT, _MAIG, _MEIG, _IG, _DIF, _STRING, _COMENTARIO};

%}

/* Coloque aqui definições regulares */

D	    [0-9]
L	    [A-Za-z_]
WS	    [ \t\n]

INT	    {D}+
FLOAT	{INT}("."{INT})?([Ee]("+"|"-")?{INT})?
ID	    {L}({L}|{D})*
STR     \"([^\"\n]|\\\"|\"\")*\"
/*COM     \/\*[^(\*\/)]*\*\/*/

%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */

{WS}	{/* ignora espaço */}
"if"	{return _IF;}
"for"   {return _FOR;}
{INT}	{return _INT;}
{FLOAT}	{return _FLOAT;}
{ID}	{return _ID;}
{STR}   {return _STRING;}
    /*{COM}   {return _COMENTARIO;}*/

">="	{return _MAIG;}
"<="	{return _MEIG;}
"=="	{return _IG;}
"!="	{return _DIF;}

.       {return *yytext; /* Essa deve ser a última regra. Dessa forma qualquer caractere isolado será retornado pelo seu código ascii. */}

%%

/* Não coloque nada aqui - a função main é automaticamente incluída na hora de avaliar e dar a nota. */

int main() {
    int token = 0;

    while((token = yylex()) != EOF)
        printf("Token: %d %s\n", token, yytext);

    return 0;
}

%{
int token (int);
%}

DIGITO	[0-9]
LETRA	[A-Za-z_]
INT		{DIGITO}+
DOUBLE	{DIGITO}+("."{DIGITO}+)?
ID		{LETRA}({LETRA}|{DIGITO})*
STR		\"([^\"\n]|\\\"|\"\")*\"
CHAR	\'.\'

%%

"\t"	{coluna += 4;}
" "		{coluna++;}
"\n"	{linha++; coluna = 1;}

{INT}	{return token (CINT);}
{DOUBLE}	{return token (CDOUBLE);}
{STR}	{return token (CSTR);}
{CHAR}	{return token (CCHAR);}

"int"	{return token (TK_INT);}
"real"	{return token (TK_REAL);}
"boolean"	{return token (TK_BOOL);}
"char"	{return token (TK_CHAR);}
"string"	{return token (TK_STRING);}
"console"	{return token (TK_CONSOLE);}
">>"	{return token (TK_SHIFTR);}
"<<"	{return token (TK_SHIFTL);}
"=="	{return token (TK_EQUALS);}
"<>"	{return token (TK_DIFF);}
"<="	{return token (TK_LESS_E);}
">="	{return token (TK_GREAT_E);}
"for"	{return token (TK_FOR);}
"in"	{return token (TK_IN);}
".."	{return token (TK_2PT);}
"if"	{return token (TK_IF);}
"then"	{return token (TK_THEN);}
"else"	{return token (TK_ELSE);}
"endl"	{return token (TK_ENDL);}
"begin"	{return token (TK_BEGIN);}
"end"	{return token (TK_END);}

{ID}	{return token (TK_ID);}

.		{return token (*yytext);}

%%

int token (int tk) {
	yylval.v = yytext;
	coluna += strlen(yytext);

	return tk;
}

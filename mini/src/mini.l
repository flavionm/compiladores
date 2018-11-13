%{
int token( int );
%}

DIGITO	[0-9]
LETRA	[A-Za-z_]
INT		{DIGITO}+
DOUBLE	{DIGITO}+("."{DIGITO}+)?
ID		{LETRA}({LETRA}|{DIGITO})*


%%

"\t"	{ coluna += 4; }
" "		{ coluna++; }
"\n"	{ linha++; coluna = 1; }

{INT}	{ return token( CINT ); }
{DOUBLE}	{ return token( CDOUBLE ); }

"var"	{ return token( TK_VAR ); }
"console"	{ return token( TK_CONSOLE ); }
">>"	{ return token( TK_SHIFTR ); }
"<<"	{ return token( TK_SHIFTL ); }
"for"	{ return token( TK_FOR ); }
"in"	{ return token( TK_IN ); }
".."	{ return token( TK_2PT ); }
"if"	{ return token( TK_IF ); }
"then"	{ return token( TK_THEN ); }
"else"	{ return token( TK_ELSE ); }

{ID}	{ return token( TK_ID ); }

.		{ return token( *yytext ); }

%%

int token( int tk ) {
	yylval.v = yytext;
	coluna += strlen(yytext);

	return tk;
}

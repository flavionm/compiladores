DIGITO  [0-9]
LETRA   [A-Za-z_]
INT     {DIGITO}+
DOUBLE  {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
OPR	[(),]


%%

"\t"       { coluna += 4; }
" "        { coluna++; }
"\n"	   { linha++; coluna = 1; }
{INT} 	   { yylval.valor = yytext; coluna += strlen(yytext); return TK_CINT; }
{DOUBLE}   { yylval.valor = yytext; coluna += strlen(yytext); return TK_CDOUBLE; }

{ID}       { yylval.valor = yytext; coluna += strlen(yytext); return TK_ID; }
{OPR}      { yylval.valor = yytext; coluna += strlen(yytext); return yytext[0]; }


.          { coluna++; yylval.valor = yytext; yyerror( "Caractere inválido!\n" ); }

%%

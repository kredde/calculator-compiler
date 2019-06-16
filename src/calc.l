%option noyywrap

%{
#include <stdio.h>
#include <string.h>
%}

%%
[ \t] { /* ignore whitespaces */ }
exit  { return EXIT; }
false {
	yylval.i = 0;
	return BOOL;
}
true {
	yylval.i = 1;
	return BOOL;
}
 /* number */
[0-9]+\.[0-9]+|[0-9]+ { 
	yylval.f = atof(yytext);
	return NUMBER; 
}
 /* identifier */
[a-zA-Z_][a-zA-Z0-9_]* {
	struct node *n = lookup(yytext);
	if (n) {
		yylval.n = n;
		int data_type = get_data_type(n);
		int qualifier_type = get_qualifier_type(n);
		if (qualifier_type == FUNC) {
			return FUNCTION;
		} else {
			return data_type == NUMBER ? ID_NUMBER : ID_BOOL;
		}
	} else {
		/* create new variable */
		yylval.n = create_entry(yytext, UNDEF, UNDEF);
		return ID_UNDEF;
	}
}
::   	{ return FUNC_CALL; }
==    { return EQ; }
!=    { return NE; }
\<=   { return LE; }
\>=   { return GE; }
\<    { return LT; }
\>    { return GT; }
\|\|? { return OR; }
&&?   { return AND; }
 /* tokens */
[!#%:=\n\(\)\+\-\*\/\^] { return yytext[0]; }
%%
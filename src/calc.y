%{
#include "util.h"

int main();
int yylex();
int yyparse();
void yyerror(char *);
void register_constants();
void register_functions();
void pretty_print(float);
%}

%union {
	float f;
	int i;
	struct node *n;
}

%expect 1

// data-types: 
%token<i> BOOL
%token<f> NUMBER 

// id-types: 
%token<n> ID_BOOL
%token<n> ID_NUMBER
%token<n> ID_UNDEF
%token<n> FUNCTION

// tokens
%token EXIT
%token AND
%token OR
%token EQ
%token NE
%token GT
%token GE
%token LT
%token LE

// functions
%type<f> func
%type<i> comp

// expressions
%type<i> expr_b
%type<f> expr_n

// assignments
%type<n> assignment_n
%type<n> assignment_b
%type<n> id

// print statement
%type<void> stmt

// associativity
%right '=' FUNC_CALL
%left '+' '-' 
%left '/' '*' 
%left '%' 
%left '^'
%nonassoc UMINUS
%nonassoc EQ NE GT LT GE LE 

%left OR
%left AND
%left '!'

%start input

%%
input: 
	|	stmt input
;

stmt:
	'\n'				{ printf("\n") ;}
 	|	EXIT			{ exit(0); }
	|	ID_UNDEF	{ 
		char * id = get_id($1);
		char * message = malloc(24 + strlen(id));
		sprintf(message, "variable '%s' is not defined", id);
		yyerror(message);
	 }
	|	expr_n		{ pretty_print($1); }
	|	expr_b		{ printf("=> %s\n", $1 ? "true" : "false"); }
	;

id:
		ID_NUMBER	{ $$ = $1; }
	|	ID_BOOL		{ $$ = $1; }
	|	ID_UNDEF	{ $$ = $1; }
	;

assignment_n:
		id '=' expr_n	{
			if(get_qualifier_type($1) != CONST) {
				if (get_data_type($1) == UNDEF) {
					insert($1);
				}
				set_qualifier_type($1,VAR);
				set_data_type($1, NUMBER);
				set_int($1, 0);
				set_float($1, $3);
				$$ = $1;
			} else {
				yyerror("cannot modify a constant");
			}
		}
	|	FUNCTION '=' expr_n	{ yyerror("cannot use this function as variable"); }		
	|	'#' assignment_n {
			if($2) {
				set_qualifier_type($2, CONST);
				$$ = $2;
			}	
		}	
	|	'#' ID_NUMBER	{
			if (get_qualifier_type($2) != CONST) {
				set_qualifier_type($2, CONST);
				$$ = $2;
			} else {
				yyerror("already defined as constant.");
			}
		}	
	;

assignment_b:
		id '=' expr_b	{
			if(get_qualifier_type($1) != CONST) {
				if (get_data_type($1) == UNDEF) {
					insert($1);
				}
				set_qualifier_type($1,VAR);
				set_data_type($1, BOOL);
				set_int($1, $3);
				$$ = $1;
			} else {
				yyerror("cannot modify a constant.");
			}
		}
	|	FUNCTION '=' expr_b	{ yyerror("cannot use this function as variable."); }
	|	'#' assignment_b {
			if($2) {
				set_qualifier_type($2, CONST);
				$$ = $2;
			}	
		}	
	|	'#' ID_BOOL	{
			if (get_qualifier_type($2) != CONST) {
				set_qualifier_type($2, CONST);
				$$ = $2;
			} else {
				yyerror("already defined as constant.");
			}
		}	
;

func: 
		FUNCTION FUNC_CALL expr_n { $$ = eval_func($1, $3 * 1.0); }
	|	id FUNC_CALL expr_n { yyerror("this function is not defined"); }
	;

expr_n: 
		expr_n '+' expr_n { $$ = $1 + $3; }
	|	expr_n '-' expr_n { $$ = $1 - $3; }
	|	expr_n '/' expr_n {
			if ($3 != 0) {
				$$ = $1 / $3;
			} else {
				yyerror("division by 0 is not allowed");
			}
		}
	|	expr_n '%' expr_n {
			if (is_integer($1) && is_integer($3)) {
				if ($3 != 0) {
					$$ = (int)$1 % (int)$3;
				} else {
					yyerror("modulo by 0 is not allowed");
				}
			} else {
				yyerror("both operands of the modulo have to be integers");
			}
		}									
	|	expr_n '*' expr_n { $$ = $1 * $3; }
	|	expr_n '^' expr_n { $$ = pow($1, $3); }
	|	'(' expr_n ')' { $$ = $2; }
	|	NUMBER { $$ = $1; }
	|	ID_NUMBER { $$ = get_float($1); }
	|	assignment_n {
			if($1) {
				$$ = get_float($1);
			}
		}		
	|	func 						{ $$ = $1; }
	|	'-' expr_n %prec UMINUS		{ $$ = -1.0 * $2; }
;

expr_b: 
		BOOL { $$ = $1; }
	|	ID_BOOL { $$ = get_int($1); }
	|	assignment_b {
			if($1) {
				$$ = get_int($1);
			}
		}
	|	comp { $$ = $1; }
	|	expr_b AND expr_b { $$ = $1 && $3; }
	|	expr_b OR expr_b { $$ = $1 || $3; }
	|	'!' expr_b { $$ = !$2; }
	|	'(' expr_b ')' { $$ = $2; }
	;

comp:
		expr_n EQ expr_n { $$ = $1 == $3; }
	|	expr_n NE expr_n { $$ = $1 != $3; }
	|	expr_n GT expr_n { $$ = $1 > $3; }
	|	expr_n GE expr_n { $$ = $1 >= $3; }
	|	expr_n LT expr_n { $$ = $1 < $3; }
	|	expr_n LE expr_n { $$ = $1 <= $3; }
	|	expr_b EQ expr_b { $$ = $1 == $3; }
	|	expr_b NE expr_b { $$ = $1 == $3; }
;

%%
#include "lex.yy.c"
#include <wchar.h>
#include <locale.h>

int main() {
	setlocale(LC_ALL, "en_US.utf8");
	const wchar_t calculator_emoji = 0x1F522;
	printf("Calculator %lc\nby Kristian Schwienbacher\n\n", calculator_emoji);

	register_constants();
	register_functions();
	printf("\nType simple expressions - exit to quit the program\n\n");
	return yyparse();
}

void yyerror(char *error_msg) {
	// print in red
	printf("\033[1;31m"); 
	printf("[ERROR => %s]\n\n", error_msg);
	printf("\033[0m");
	yyparse();
}

void register_constants() {
	printf("registered constants: \033[0;32mpi, e, f (golden ratio), g (gravity acceleration)\033[0m \n");
	set_float(insert(create_entry("pi", CONST, NUMBER)), 3.141593);
	set_float(insert(create_entry("e", CONST, NUMBER)), 2.718282);
	set_float(insert(create_entry("f", CONST, NUMBER)), 1.618034);
	set_float(insert(create_entry("g", CONST, NUMBER)), 9.80665);
}

void register_functions() {
	printf("registered functions: \033[0;32msqrt, tan, sin, cos, ln, log2, log10, fac\033[0m \n");
	insert(create_entry("sqrt", FUNC, NUMBER));
	insert(create_entry("tan", FUNC, NUMBER));
	insert(create_entry("sin", FUNC, NUMBER));
	insert(create_entry("cos", FUNC, NUMBER));
	insert(create_entry("ln", FUNC, NUMBER));
	insert(create_entry("log2", FUNC, NUMBER));
	insert(create_entry("log10", FUNC, NUMBER));
	insert(create_entry("fac", FUNC, NUMBER));
}

void pretty_print(float f) {
	if (is_integer(f)) {
		printf("=> \033[0;32m%d\033[0m\n", (int)f);
	} else {
		printf("=> \033[0;32m%f\033[0m\n", f);
	}
}
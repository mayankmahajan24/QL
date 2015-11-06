(*
 * QL: Parser
 *
 * Manager: Matthew Piccolella
 * Systems Architect: Anshul Gupta
 * Tester: Evan Tarrh
 * Language Guru: Gary Lin
 * Systems Integrator: Mayank Mahajan
 *)

%{ open Ast;; %}

////////////////////////////////////////////////
//////////////////// TOKENS ////////////////////
////////////////////////////////////////////////

/* Functions */
%token FUNCTION RETURN COLON

/* Loops */
%token WHERE IN AS FOR WHILE

/* Conditionals */
%token IF ELSEIF ELSEIF

/* Math Operators */
%token PLUS MINUS TIMES DIVIDE

/* Equivalency Operators */
%token NEQ, EQ, LEQ, GEQ, LT, GT, NOT

/* Punctuation */
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK SEMICOLON COMMA EOF

/* Types */
%token INT FLOAT VOID STRING JSON ARRAY BOOL

/* Assignment */
%token ASSIGN

/* TODO: Add the types of our tokens. (int_literal, float_literal, etc.) */

/* Precedence */
/* TODO: Establish the precedence definitions for our operators. */

%start program
%type <Ast.program> program

%%

/* Start Program */
program:
  | /* Nothing */
  | decls EOF

/* Literals */
literal:
  | int_literal
  | float_literal
  | boolean_literal
  | string_literal
  | array_literal
  | json_literal

int_literal: INT LPAREN INT_LITERAL RPAREN

float_literal: FLOAT LPAREN FLOAT_LITERAL RPAREN

boolean_literal: BOOLEAN LPAREN BOOLEAN_LITERAL RPAREN

string_literal: STRING LPAREN STRING_LITERAL RPAREN

array_literal: ARRAY LPAREN INT_LITERAL RPAREN

json_literal: JSON LPAREN STRING_LITERAL RPAREN

/* Functions */
func-dec: FUNCTION ID LPAREN formals_opt RPAREN COLON LBRACK stmt_list RBRACK



/* Expressions */
expr:
  | literal
  | ID
  | expr PLUS expr
  | expr MINUS expr
  | expr TIMES expr
  | expr DIVIDE expr
  | expr EQ expr
  | expr NEQ expr
  | expr LEQ expr
  | expr GEQ expr
  | expr AND expr
  | expr OR expr
  | NOT expr
  | ID LPAREN actuals_opt RPAREN
  | LPAREN expr RPAREN





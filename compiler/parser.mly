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

/* Boolean Operators */
%token AND OR

/* TODO: Add the types of our tokens. (int_literal, float_literal, etc.) */

/* Precedence */
/* TODO: Establish the precedence definitions for our operators. */

%start program
%type <Ast.program> program

%%

/* Start Program */
program:
  | /* Nothing */
  | stmt_list EOF

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

boolean_literal: BOOL LPAREN BOOL_LITERAL RPAREN

string_literal: STRING LPAREN STRING_LITERAL RPAREN

array_literal: ARRAY LPAREN INT_LITERAL RPAREN

json_literal: JSON LPAREN STRING_LITERAL RPAREN

/* Operators */
bool_operator:
  | AND
  | OR

comparison_operator:
  | NEQ
  | EQ
  | LEQ
  | GEQ
  | LT
  | GT

/* Variables */
data_type:
  | INT
  | FLOAT
  | BOOL
  | STRING
  | ARRAY
  | JSON

/* Functions */
func-dec: FUNCTION ID LPAREN formals_opt RPAREN COLON return_type LBRACK stmt_list RBRACK

return_type:
  | data_type
  | VOID

formals_opt:
  | /* Nothing */
  | formal_list

formal_list:
  | arg_decl
  | formal_list COMMA arg_decl

arg_decl:
  | data-type ID

/* Function statement list can contain all statements as well as return */
func_stmt_list:
  | /* Nothing */
  | stmt_list
  | func_stmt_list return_stmt

return_stmt: RETURN expr ENDLINE

////////////////////////////////////////////////////
//////////////////// STATEMENTS ////////////////////
////////////////////////////////////////////////////

stmt_list_opt:
  | /* Nothing */
  | stmt_list

stmt_list:
  | stmt
  | stmt_list stmt

/* NOTE: I think using end of the line for for loops is hard. */
stmt:
  | expr ENDLINE
  | for_loop ENDLINE
  | while_loop ENDLINE
  | where_stmt ENDLINE
  | if_elseif_else_stmt ENDLINE

/* Where Statements */
where_stmt: WHERE LPAREN where_expr_opt RPAREN AS ID LBRACK stmt_list RBRACK IN where_lit

/* TODO: This part is hard. Make sure it's right. */
where_expr_opt:
  | /* Nothing */
  | where_expr_list

where_expr_list:
  | where_expr
  | where_expr_list bool_operator where_expr

where_expr:
  | where_arg comparison_operator where_arg
  | NOT where_arg

where_arg:
  | where_selector
  | literal

where_selector: LBRACE STRING_LITERAL RBRACE

where_lit:
  | ID
  | json_literal

/* Loops */
for_loop: FOR LPAREN expr COMMA bool_expr COMMA expr RPAREN LBRACK stmt_list RBRACK

while_loop: WHILE LPAREN expr RPAREN LBRACK stmt_list RBRACK 

/* If/ElseIf/Else */
if_elseif_else_stmt: if_stmt else_if_stmt_list_opt else_stmt_opt

if_stmt: IF LPAREN bool_expr_list RPAREN LBRACK stmt_list_opt RBRACK

else_if_stmt_list_opt:
  | /* Nothing */
  | else_if_stmt_list

else_if_stmt_list:
  | else_if_stmt
  | else_if_stmt_list else_if_stmt

else_if_stmt: ELSEIF LPAREN bool_expr_list RPAREN LBRACK stmt_list_opt RBRACK 

else_stmt_opt:
  | /* Nothing */
  | else_stmt

else_stmt: ELSE LBRACK stmt_list_opt RBRACK

bool_expr_list:
  | bool_expr
  | bool_expr_list bool_operator bool_expr

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

actuals_opt:
  | /* Nothing */
  | actuals_list

actuals_list:
  | expr
  | actuals_list, expr

bool_expr:
  | expr EQ expr
  | expr NEQ expr
  | expr LT expr
  | expr LEQ expr
  | expr GT expr
  | expr GEQ expr
  | boolean_literal
  | ID

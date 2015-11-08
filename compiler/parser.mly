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

%token <int> INT_LITERAL
%token <float> FLOAT_LITERAL
%token <string> STRING_LITERAL
%token <string> BOOLEAN_LITERAL          
%token <string> ID

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
  | INT_LITERAL
  | FLOAT_LITERAL
  | BOOL_LITERAL
  | STRING_LITERAL
  | array_literal
  | json_literal

/* TODO DEFINE THESE PROPERLY */
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
func_dec: FUNCTION ID LPAREN formals_opt RPAREN COLON return_type LBRACK stmt_list RBRACK

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
  | data_type ID

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
  | assignment_stmt ENDLINE

/*TODO: Add assignment to above and its possible derivations*/

/* Where Statements */
where_stmt: WHERE LPAREN bool_expr_list RPAREN AS ID LBRACK stmt_list RBRACK IN where_lit

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
  | BOOL_LITERAL          { Binop($1, Equal,   $3) }
  | ID                    { Binop($1, Equal,   $3) }
  | expr EQ expr          { Binop($1, Equal,   $3) }
  | expr NEQ expr         { Binop($1, Equal,   $3) }
  | expr LT expr          { Binop($1, Equal,   $3) }
  | expr LEQ expr         { Binop($1, Equal,   $3) }
  | expr GT expr          { Binop($1, Equal,   $3) }
  | expr GEQ expr         { Binop($1, Equal,   $3) }
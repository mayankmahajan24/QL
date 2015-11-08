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
%token LPAREN RPAREN LCURLY RCURLY LSQUARE RSQUARE SEMICOLON COMMA EOF

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
  stmt_list EOF    { List.rev $1 }

/* Literals */
literal:
  | INT_LITERAL     { Literal_int($1) }
  | FLOAT_LITERAL   { Literal_float($1) }
  | BOOL_LITERAL    { Literal_bool($1) }
  | STRING_LITERAL  { Literal_string($1) }
  | array_literal   { $1 }
  | json_literal    { $1 }

primitive_literal:
    INT_LITERAL     { Literal_int($1) }
  | FLOAT_LITERAL   { Literal_float($1) }
  | BOOL_LITERAL    { Literal_bool($1) }
  | STRING_LITERAL  { Literal_string($1) }

array_literal:
    LSQUARE primitive_literal_list RSQUARE    { List.rev $2 }

primitive_literal_list:
      /* Nothing */         { [] }
    | primitive_literal_list COMMA primitive_literal    { $3 :: $1 }

json_literal:
    JSON LPAREN STRING_LITERAL RPAREN { Json_from_file($3) }

/* Variables */
/* ~~~~~~~~~~~~~~~~~~~ PLEASE REVISIT ~~~~~~~~~~~~~~~~~~~ */
data_type:
  | INT     { "int" }      
  | FLOAT   { "float" }
  | BOOL    { "bool" }
  | STRING  { "string" }
  | ARRAY   { "array" }
  | JSON    { "json" }

/* Functions */
func_dec: FUNCTION ID LPAREN formals_opt RPAREN COLON 
    return_type LSQUARE stmt_list RSQUARE   { Declare_func($2, $4, $7, List.rev $9) }

return_type:
  | data_type   { $1 }
  | VOID        { "void" }

formals_opt:
  | /* Nothing */   { [] }
  | formal_list     { List.rev $1 }

formal_list:
  | arg_decl                    { [$1] }
  | formal_list COMMA arg_decl  { $3 :: $1 }

arg_decl:
   data_type ID     { Declare_arg($1, $2) }

////////////////////////////////////////////////////
//////////////////// STATEMENTS ////////////////////
////////////////////////////////////////////////////

stmt_list:
  /* Nothing */    { [] }
  | stmt_list stmt {$2 :: $1}

/* NOTE: I think using end of the line for for loops is hard. */

for (x = 1; x < 10; while(x < 10) x++;) {System.out.println ("Made it");}

stmt:
  | expr ENDLINE                 { Expr($1) } 
  | FOR LPAREN expr COMMA bool_expr COMMA
    assignment_stmt RPAREN LCURLY stmt_list RCURLY ENDLINE             { For($3, $5, $7, ) 
  | while_loop ENDLINE
  | where_stmt ENDLINE
  | if_elseif_else_stmt ENDLINE
  | assignment_stmt ENDLINE
  | func_dec ENDLINE
  | return_stmt ENDLINE

/*TODO: Add assignment to above and its possible derivations*/

/* Where Statements */
where_stmt: WHERE LPAREN bool_expr_list RPAREN AS ID LCURLY stmt_list RCURLY IN where_lit

where_lit:
  | ID
  | json_literal

/* Loops */
for_loop: 

while_loop: WHILE LPAREN expr RPAREN LCURLY stmt_list RCURLY 

/* If/ElseIf/Else */
if_elseif_else_stmt: if_stmt else_if_stmt_list_opt else_stmt_opt

if_stmt: IF LPAREN bool_expr_list RPAREN LCURLY stmt_list_opt RCURLY

else_if_stmt_list_opt:
  | /* Nothing */
  | else_if_stmt_list

else_if_stmt_list:
  | else_if_stmt
  | else_if_stmt_list else_if_stmt

else_if_stmt: ELSEIF LPAREN bool_expr_list RPAREN LCURLY stmt_list_opt RCURLY 

else_stmt_opt:
  | /* Nothing */
  | else_stmt

else_stmt: ELSE LCURLY stmt_list_opt RCURLY

/*Assignment*/
assignment_stmt:
  | data_type ID ASSIGN expr {Assign($1, $2, $3)}

bool_expr_list:
  | bool_expr
  | bool_expr_list bool_operator bool_expr

actuals_opt:
  | /* Nothing */
  | actuals_list

actuals_list:
  | expr
  | actuals_list, expr


/* Expressions */
expr:
  | literal                       { $1 }
  | ID                            { Id($1) }
  | expr PLUS expr                { Binop($1, Add,   $3) }
  | expr MINUS expr               { Binop($1, Sub,   $3) }
  | expr TIMES expr               { Binop($1, Mult,  $3) }
  | expr DIVIDE expr              { Binop($1, Div,   $3) }
  | ID LPAREN actuals_opt RPAREN  { Call($1, $3) }
  | LPAREN expr RPAREN            { $2 }


actuals_opt:
  | /* Nothing */
  | actuals_list

actuals_list:
  | expr
  | actuals_list, expr

bool_expr:
  | BOOL_LITERAL          { Literal_bool($1) }
  | ID                    { Id($1) }
  | expr EQ expr          { Binop($1, Equal,   $3) }
  | expr NEQ expr         { Binop($1, Neq,   $3) }
  | expr LT expr          { Binop($1, Less,   $3) }
  | expr LEQ expr         { Binop($1, Leq,   $3) }
  | expr GT expr          { Binop($1, Greater,   $3) }
  | expr GEQ expr         { Binop($1, Geq,   $3) }
  | bool_expr AND bool_expr    { Binop($1, And,   $3) }
  | bool_expr OR bool_expr     { Binop($1, Or,   $3) }
  
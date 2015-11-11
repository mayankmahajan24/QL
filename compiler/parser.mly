//////////////////////////////////////////
////// QL: Parser ////////////////////////
////// Manager: Matthew Piccolella ///////
////// Systems Architect: Anshul Gupta ///
////// Tester: Evan Tarrh ////////////////
////// Language Guru: Gary Lin ///////////
////// Systems Integrator: Mayank Mahajan/
//////////////////////////////////////////

%{ open Ast;; %}

////////////////////////////////////////////////
//////////////////// TOKENS ////////////////////
////////////////////////////////////////////////

/* Functions */
%token FUNCTION RETURN COLON

/* Loops */
%token WHERE IN AS FOR WHILE

/* Conditionals */
%token IF ELSEIF ELSE

/* Math Operators */
%token PLUS MINUS TIMES DIVIDE

/* Equivalency Operators */
%token NEQ, EQ, LEQ, GEQ, LT, GT, NOT

/* Punctuation */
%token LPAREN RPAREN LCURLY RCURLY LSQUARE RSQUARE SEMICOLON COMMA EOF ENDLINE

/* Types */
%token INT FLOAT VOID STRING JSON ARRAY BOOL

/* Assignment */
%token ASSIGN

/* Boolean Operators */
%token AND OR

%token <int> INT_LITERAL
%token <float> FLOAT_LITERAL
%token <string> STRING_LITERAL
%token <string> BOOL_LITERAL
%token <string> ID

/* Precedence */
/* TODO: Establish the precedence definitions for our operators. */

%nonassoc NOELSE

%right ASSIGN
%left AND OR
%left NOT
%left PLUS MINUS
%left TIMES DIVIDE

%start program
%type <Ast.program> program

%%

/* Start Program */
program:
    stmt_list EOF    { List.rev $1 }

/* Literals */
literal:
    INT_LITERAL     { Literal_int($1) }
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
    JSON LPAREN STRING_LITERAL RPAREN { Json_from_file($3) } /*String literal refers to filename*/

/* Variables */
/* ~~~~~~~~~~~~~~~~~~~ PLEASE REVISIT ~~~~~~~~~~~~~~~~~~~ */
data_type:
    INT     { "int" }      
  | FLOAT   { "float" }
  | BOOL    { "bool" }
  | STRING  { "string" }
  | ARRAY   { "array" }
  | JSON    { "json" }

return_type:
    data_type   { $1 }
  | VOID        { "void" }

formals_opt:
    /* Nothing */   { [] }
  | formal_list     { List.rev $1 }

formal_list:
    arg_decl                    { [$1] }
  | formal_list COMMA arg_decl  { $3 :: $1 }

arg_decl:
    data_type ID
    {{
        var_type   = $1;
        var_name   = $2;
    }}


////////////////////////////////////////////////////
//////////////////// STATEMENTS ////////////////////
////////////////////////////////////////////////////

stmt_list:
  /* Nothing */    { [] }
  | stmt_list stmt {$2 :: $1}

stmt:
    expr ENDLINE                                { Expr($1) } 
  | FOR LPAREN expr COMMA bool_expr COMMA
    assignment_stmt RPAREN
    LCURLY stmt_list RCURLY ENDLINE             { For($3, $5, $7, $10) } 
  | WHILE LPAREN bool_expr RPAREN
    LCURLY stmt_list RCURLY ENDLINE             { While($3, $6) }
  | WHERE LPAREN where_expr_list_opt RPAREN AS ID
    LCURLY stmt_list RCURLY
    IN where_lit ENDLINE                        { Where($3, $6, $8, $11) }
  | IF LPAREN bool_expr RPAREN
    LCURLY stmt_list RCURLY
    ENDLINE %prec NOELSE                        { If($3, $6, Block([])) }
  | IF LPAREN bool_expr RPAREN
    LCURLY stmt_list RCURLY
    ELSE LCURLY stmt_list RCURLY ENDLINE        { If($3, $6, $10) }
  | assignment_stmt ENDLINE                     { $1 }
  | func_decl                                   { $1 }
  | RETURN expr ENDLINE                         { Return($2) }

/* Function Declaration */
func_decl:
    | FUNCTION ID LPAREN formals_opt RPAREN COLON return_type LCURLY stmt_list RCURLY ENDLINE
    {{
        fname = $2;
        args = $4;
        return = $7;
        body = List.rev $9
    }}

/* Assignment */
assignment_stmt:
    data_type ID ASSIGN expr { Assign($1, $2, $4) }

/* Where Statements */
where_expr_list_opt:
  /* Nothing */       { [] }
  | where_expr_list   { $1 }

where_expr_list:
  where_expr                    { [$1] }
  | where_expr AND where_expr   { Where_cond($1, And, $3) }
  | where_expr OR where_expr    { Where_cond($1, Or, $3) }

where_expr:
  where_arg EQ where_arg      { Where_eval($1, Equal, $3) }
  | where_arg NEQ where_arg   { Where_eval($1, Neq, $3) }
  | where_arg LT where_arg    { Where_eval($1, Less, $3) }
  | where_arg LEQ where_arg   { Where_eval($1, Leq, $3) }
  | where_arg GT where_arg    { Where_eval($1, Greater, $3) }
  | where_arg GEQ where_arg   { Where_eval($1, Geq, $3) }
  | NOT where_arg             { Not($2) }

where_arg:
  json_selector_list  { List.rev $1 }
  | expr              { $1 }

/* Selectors for json expressions */
json_selector_list:
  json_selector { [$1] }
  | json_selector_list json_selector { $2 :: $1 }

json_selector: LSQUARE STRING_LITERAL RSQUARE { $2 }

where_lit:
    ID              { Id($1) }
  | json_literal    { $1 }

actuals_opt:
    /* Nothing */ { [] }
  | actuals_list  { List.rev $1 }

actuals_list:
    expr                    { [$1] }
  | actuals_list COMMA expr { $3 :: $1 }

/* Expressions */
expr:
    literal                       { $1 }
  | ID                            { Id($1) }
  | expr PLUS expr                { Binop($1, Add,   $3) }
  | expr MINUS expr               { Binop($1, Sub,   $3) }
  | expr TIMES expr               { Binop($1, Mult,  $3) }
  | expr DIVIDE expr              { Binop($1, Div,   $3) }
  | ID LPAREN actuals_opt RPAREN  { Call($1, $3) }
  | LPAREN expr RPAREN            { $2 }

bool_expr:
    BOOL_LITERAL            { Literal_bool($1) }
  | ID                      { Id($1) }
  | expr EQ expr            { Binop($1, Equal,   $3) }
  | expr NEQ expr           { Binop($1, Neq,   $3) }
  | expr LT expr            { Binop($1, Less,   $3) }
  | expr LEQ expr           { Binop($1, Leq,   $3) }
  | expr GT expr            { Binop($1, Greater,   $3) }
  | expr GEQ expr           { Binop($1, Geq,   $3) }
  | bool_expr AND bool_expr { Binop($1, And,   $3) }
  | bool_expr OR bool_expr  { Binop($1, Or,   $3) }
  | NOT bool_expr           { Not($2) }
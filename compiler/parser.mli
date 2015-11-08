type token =
  | FUNCTION
  | RETURN
  | COLON
  | WHERE
  | IN
  | AS
  | FOR
  | WHILE
  | IF
  | ELSEIF
  | ELSE
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | NEQ
  | EQ
  | LEQ
  | GEQ
  | LT
  | GT
  | NOT
  | LPAREN
  | RPAREN
  | LCURLY
  | RCURLY
  | LSQUARE
  | RSQUARE
  | SEMICOLON
  | COMMA
  | EOF
  | ENDLINE
  | INT
  | FLOAT
  | VOID
  | STRING
  | JSON
  | ARRAY
  | BOOL
  | ASSIGN
  | AND
  | OR
  | INT_LITERAL of (int)
  | FLOAT_LITERAL of (float)
  | STRING_LITERAL of (string)
  | BOOL_LITERAL of (string)
  | ID of (string)

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program

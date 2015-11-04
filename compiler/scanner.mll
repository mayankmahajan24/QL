(*
 * QL
 *
 * Manager: Matthew Piccolella
 * Systems Architect: Anshul Gupta
 * Tester: Evan Tarrh
 * Language Guru: Gary Lin
 * Systems Integrator: Mayank Mahajan
 *)

{ open Parser }

let num = ['0'-'9']+
let exp = 'e' ('+'|'-')? ['0'-'9']+
let flt = '.'['0'-'9']+ exp?
	| ['0'-'9']+ ( ('.' ['0'-'9']* exp?) | exp)

let boolean = "true" | "false"

rule token = parse
(* Whitespace *)
| [' ' '\t' '\r']  { token lexbuf }
| '\n'             { ENDLINE }

(* Comments *)
| "#~~"            { comment lexbuf }

(* Punctuation *)
| '('         { LPAREN }    | ')'         { RPAREN }
| '{'         { LBRACE }    | '}'         { RBRACE }
| ';'         { SEMICOLON } | ','         { COMMA }

(* Math Operators *)
| '+'         { PLUS }      | '-'         { MINUS }
| '*'         { TIMES }     | '/'         { DIVIDE }
| '='         { ASSIGN }

(* Equivalency Operators *)
| "!="        { NEQ }       | "=="        { EQ }
| "<="        { LEQ }       | '<'         { LT }
| ">="        { GEQ }       | '>'         { GT }
| "not"       { NOT }

(* Logical Operators *)
| "&"        { AND }       | "|"        { OR }

(* Conditional Keywords *)
| "if"        { IF }        | "else"      { ELSE }
| "elseif"    { ELSEIF }     

(* Loop Keywords *)
| "where"     { WHERE }     | "in"        { IN }
| "as"        { AS }        | "for"       { FOR }
| "while"     { WHILE }

(* Function Keywords *)
| "function"  { FUNCTION }  | "return"    { RETURN }
| ':'         { COLON }

(* Type Keywords *)
| "int"       { INT }       | "float"     { FLOAT }
| "void"      { VOID }      | "string"    { STRING }
| "json"      { JSON }      | "array"     { ARRAY }
| "bool"      { BOOL }

(* end of file *)
| eof { EOF }

(* Identifiers *)
| ['a'-'z']['a'-'z' 'A'-'Z' '0'-'9']* as var { ID(var) }

(* Literals *)
| num as intlit      { INT_LITERAL(int_of_string intlit) }
| flt as fltlit      { FLOAT_LITERAL(float_of_string fltlit) }
| boolean as boollit { BOOLEAN_LITERAL(bool_of_string boollit) }
| '"' ([^'"']* as strlit) '"' { STRING_LITERAL(strlit) }
| '\'' ([^'\'']* as strlit) '\'' {STRING_LITERAL(strlit)}

(* Comment Eater *)
and comment = parse
| "~~#" { token lexbuf }      (* End of comments *)
| _    { comment lexbuf }    (* Still a comment *)





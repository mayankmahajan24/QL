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

let num = '-'?['0'-'9']+
let flt = (['-']?)['0'-'9']*'.'['0'-'9']+(('e'(['-''+']?)['0'-'9']+)?)
    (['-']?)['0'-'9']+'.'['0'-'9']*(('e'(['-''+']?)['0'-'9']+)?)
    | (['-']?)['0'-'9']+'e'(['-''+']?)['0'-'9']+

rule token = parse
(* Whitespace *)
| [' ' '\t' '\r' '\n']  { token lexbuf }

(* Comments *)
| "#~~"                 { comment lexbuf }

(* Punctuation *)
| '('         { LPAREN }  | ')'         { RPAREN }
| '{'         { LBRACE }  | '}'         { RBRACE }
| ';'         { SEMI }    | ','         { COMMA }

(* Math Operators *)
| '+'         { PLUS }    | '-'         { MINUS }
| '*'         { TIMES }   | '/'         { DIVIDE }
| '='         { ASSIGN }

(* Relational Operators *)
| "!="        { NEQ }     | "=="         { EQ }
| "<="        { LEQ }     | '<'          { LT }
| ">="        { GEQ }     | '>'          { GT }

(* Conditional Keywords *)
| "if"        { IF }      | "else"       { ELSE }
| "elseif"    { ELSEIF }     

(* Loop Keywords *)
| "where"     { WHERE }   | "in"         { IN }
| "as"        { AS }      | "for"        { FOR }
| "while"     { WHILE }

(* Function Keywords *)
| "where"     { WHERE }   | "in"         { IN }

(* Comment Eater *)
and comment = parse
| "~~#" { token lexbuf }      (* End of comments *)
| _    { comment lexbuf }    (* Still a comment *)

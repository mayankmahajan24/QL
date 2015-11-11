(*
    QL: Parser
    Manager: Matthew Piccolella
    Systems Architect: Anshul Gupta
    Tester: Evan Tarrh
    Language Guru: Gary Lin
    Systems Integrator: Mayank Mahajan
*)

type op = Equal | Neq | Less | Leq | Greater | Geq | Add | Sub | Mult | Div | And | Or
type bool_op = Equal | Neq | Less | Leq | Greater | Geq
type log_op = And | Or

type expr =
    | Literal_int of int
    | Literal_float of float
    | Literal_string of string
    | Literal_bool of bool
    | Id of string
    | Binop of expr * op * expr
    | Call of string * expr list
    (* Need to include array accessor here. -- Matt*)


type arg_decl = {
    var_type   : string;
    var_name   : string;
}

type stmt =
    | Expr of expr
    | For of expr * bool_expr * assignment_stmt * stmt_list
    | While of bool_expr * stmt_list
    | Where of where_expr_list_opt * string * stmt_list * where_lit
    (* ID might need to be string, im not sure -- Gary *)
    | If of bool_expr * stmt_list * stmt_list
    | Return of expr
    | Not of bool_expr
    (* Try to get the other not *)
    | Assign of data_type * string * expr
    (* Same ID comment as above *)

type where_expr_list =
    | Where_cond of where_expr * log_op * where_expr

type where_expr =
    | Where_eval of where_arg * bool_op * where_arg

type json_literal =
    | Json_from_file of string

type func_decl = {
    fname      : string;
    args       : arg_decl list;
    return     : string;
    body       : stmt list;
}

type program = stmt list
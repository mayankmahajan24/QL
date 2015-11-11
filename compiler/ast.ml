(*
 * QL
 *
 * Manager: Matthew Piccolella
 * Systems Architect: Anshul Gupta
 * Tester: Evan Tarrh
 * Language Guru: Gary Lin
 * Systems Integrator: Mayank Mahajan
 *)

type bool_op = Equal | Neq | Less | Leq | Greater | Geq
type math_op = Add | Sub | Mult | Div
type binop_op = Equal | Neq | Less | Leq | Greater | Geq |
                Add | Sub | Mult | Div
type conditional = And | Or

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

type bool_expr =
    | Binop of expr * bool_op * expr
    | Bool_binop of bool_expr * conditional * bool_expr
    | Not of bool_expr

type data_type =
    | Int
    | Float
    | Bool
    | String
    | Json
    | Array of data_type

type assignment_stmt =
    | Assign of data_type * string * expr

type where_expr =
    | Where_eval of expr * bool_op * expr

type where_expr_list =
    | Where_cond of where_expr * conditional * where_expr

type where_lit =
    | Id of string
    | Json_from_file of string

type stmt =
    | Expr of expr
    | For of expr * bool_expr * assignment_stmt * stmt list
    | While of bool_expr * stmt list
    | Where of where_expr_list * string * stmt list * where_lit
    | If of bool_expr * stmt list * stmt list
    | Return of expr
    | Not of expr

type func_decl = {
    fname      : string;
    args       : arg_decl list;
    return     : string;
    body       : stmt list;
}

type program = stmt list

let program_s (vars, funcs) = "([" ^ String.concat ", " vars ^ "],\n" ^
  String.concat "\n" (List.map func_decl_s funcs) ^ ")"
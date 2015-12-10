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
    | Literal_bool of string
    | Literal_array of expr list
    | Id of string
    | Binop of expr * math_op * expr
    | Call of string * expr list
    | Json_from_file of string
    | Json_selector_list of string list
    | Bracket_select of string * expr list
    (* Need to include array accessor here. -- Matt*)

type arg_decl = {
    var_type   : string;
    var_name   : string;
}

type bool_expr =
    | Literal_bool of string
    | Binop of expr * bool_op * expr
    | Bool_binop of bool_expr * conditional * bool_expr
    | Not of bool_expr
    | Id of string

type data_type =
    | Int
    | Float
    | Bool
    | String
    | Json
    | Array of data_type
    | AnyType

type stmt =
    | Expr of expr
    | For of stmt * bool_expr * stmt * stmt list
    | While of bool_expr * stmt list
    | Where of bool_expr * string * stmt list * expr
    | If of bool_expr * stmt list * stmt list
    | Return of expr
    | Not of expr
    | Assign of string * string * expr
    | Update_variable of string * expr
    | Array_assign of string * string * expr list
    | Fixed_length_array_assign of string * string * int
    | Bool_assign of string * string * bool_expr
    | Func_decl of string * arg_decl list * string * stmt list
    | Noop
    (* Look into making return type limited to certain set *)

type program = stmt list

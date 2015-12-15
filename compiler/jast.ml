open Ast

type math_op = Add | Sub | Mult | Div
type conditional = And | Or
type bool_op = Equal | Neq | Less | Leq | Greater | Geq

type data_type =
    | Int
    | Double
    | Bool
    | String
    | Json
    | Array of data_type

type arg_decl = {
    var_type   : string;
    var_name   : string;
}

type expr =
    | Literal_int of int
    | Literal_double of float
    | Literal_string of string
    | Literal_bool of string
    | Array_initializer of expr list
    | Id of string
    | Binop of expr * math_op * expr
    | Call of string * expr list
    | Json_object of string
    | Bracket_select of string * string * expr list * data_type list
    | Array_select of string * expr
    | Dummy_expr of string

type bool_expr =
    | Literal_bool of string
    | Binop of expr * bool_op * expr
    | Bool_binop of bool_expr * conditional * bool_expr
    | Not of bool_expr
    | Id of string

type stmt =
    | Assign of string * string * expr
    | Expr of expr
    | Dummy_stmt of string
    | Array_assign of string * string * expr list
    | Fixed_length_array_assign of string * string * int
    | Update_variable of string * expr
    | Update_array_element of string * expr * expr
    | Bool_assign of string * bool_expr
    | Return of expr
    | Func_decl of string * arg_decl list * string * stmt list
    | If of bool_expr * stmt list * stmt list
    | While of bool_expr * stmt list
    | For of stmt * bool_expr * stmt * stmt list
    | Where of bool_expr * string * stmt list * expr

type program = stmt list
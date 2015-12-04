open Ast

type math_op = Add | Sub | Mult | Div

type data_type =
    | Int
    | Double
    | Bool
    | String
    | Json
    | Array of data_type

type expr =
    | Literal_int of int
    | Literal_double of float
    | Literal_string of string
    | Literal_bool of string
    | Literal_array of expr list
    | Id of string
    | Binop of expr * math_op * expr
    | Call of string * expr list
    | Json_object of string
    | Bracket_select of string * expr list
    | Dummy_expr of string

type stmt =
    | Assign of string * string * expr
    | Expr of expr
    | Dummy_stmt of string

type program = stmt list
//////////////////////////////////////////
////// QL: Parser ////////////////////////
////// Manager: Matthew Piccolella ///////
////// Systems Architect: Anshul Gupta ///
////// Tester: Evan Tarrh ////////////////
////// Language Guru: Gary Lin ///////////
////// Systems Integrator: Mayank Mahajan/
//////////////////////////////////////////

type bool_op = Equal | Neq | Less | Leq | Greater | Geq
type math_op = Add | Sub | Mult | Div

type expr =
    | Literal_int of int
    | Literal_float of float
    | Literal_string of string
    | Literal_bool of bool
    | Id of string
    | Binop of expr * bool_op * expr
    | Binop of expr * math_op * expr
    | Call of string * actuals_opt
    (* Need to include array accessor here. -- Matt*)


type arg_decl = {
    var_type   : string;
    var_name   : string;
}

type stmt =
    | Expr of expr
    | For of expr * bool_expr * assignment_stmt * stmt_list
    | While of bool_expr * stmt_list
    | Where of where_expr_list_opt * ID * stmt_list * where_lit
    (* ID might need to be string, im not sure -- Gary *)
    | If of bool_expr * stmt_list * stmt_list
    | Return of expr
    | Not of bool_expr
    | Not of where_arg
    | Assign of data_type * ID * expr
    (* Same ID comment as above *)

type where_expr_list =
    | Where_cond of where_expr * And * where_expr
    | Where_cond of where_expr * Or * where_expr

type where_expr =
    | Where_eval of where_arg * bool_op * where_arg

type json_literal =
    | Json_from_file of STRING_LITERAL
    (* Same thing as ID from line 34, not sure if STRING_LITERAL
                                should be just string -- Gary*)

type func_decl = {
    fname      : string;
    args       : arg_decl list;
    return     : string;
    body       : stmt list;
}

type program = stmt list
//////////////////////////////////////////
////// QL: Parser ////////////////////////
////// Manager: Matthew Piccolella ///////
////// Systems Architect: Anshul Gupta ///
////// Tester: Evan Tarrh ////////////////
////// Language Guru: Gary Lin ///////////
////// Systems Integrator: Mayank Mahajan/
//////////////////////////////////////////

type op = Equal | Neq | Less | Leq | Greater | Geq | Add | Sub | Mult | Div

type expr =
    | Literal_int of int
    | Literal_float of float
    | Literal_string of string
    | Literal_bool of bool
    | Id of string
    | Binop of expr * op * expr
    | Call of string * expr list
    (* Need to include array accessor here.
     *)


type arg_decl = {
    var_type   : string;
    var_name   : string;
}

type stmt =
    (* Fill these in *)

type func_decl = {
    fname      : string;
    args       : arg_decl list;
    return     : string;
    body       : stmt list;
}

type program = stmt list
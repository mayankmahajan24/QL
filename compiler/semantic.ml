(* Compile the program to Java. Does no compile time check for now*)
open Ast

module StringMap = Map.Make(String)

(* Symbol Table *)
type env = {
	function_index: int StringMap.t;
	var_index: data_type StringMap.t list;
}

type data_type = Int | Float | Bool | String | Array | Json | AnyType

(* write program to .java file *)
let write_to_file prog_str =
    let file = open_out "Test.java" in
        Printf.fprintf file "%s" prog_str

(* let rec check_expr_type (expr : Ast.expr) = match expr
	_ -> print_endline "lol"
 *)

let string_to_data_type (s: string) = match s
	with "int" -> Int
	| "float" -> Float
	| "bool" -> Bool
	| "string" -> String
	| "array" -> Array
	| "json" -> Json
	| _ -> raise (Failure "unsupported data type")

let check_binop_type (left_expr : data_type) (op : Ast.math_op) (right_expr : data_type) = match (left_expr, op, right_expr)
	with (Int, _, Int) -> Int
	| (Float, _, Float) -> Float
	| (String, Add, String) -> String
	| (_, _, _) -> raise (Failure "cannot perform binary operations with provided arguments")

let rec check_expr_data_type (expr : Ast.expr) = match expr
	with Literal_int(i) -> Int
	| Literal_float(i) -> Float
	| Literal_bool(i) -> Bool
	| Literal_string(i) -> String
	| Literal_array(i) -> Array
	| Json_from_file(i) -> Json
	| Binop(left_expr, op, right_expr) -> check_binop_type (check_expr_data_type(left_expr)) op (check_expr_data_type(right_expr))
	| _ -> raise (Failure "unimplemented expression")

let equate e1 e2 =
	if (e1 != e2) then raise (Failure "data_type mismatch")

let string_data_literal (expr : Ast.expr) = match expr
		with Literal_int(i) -> string_of_int i
	| Literal_float(i) -> string_of_float i
	| Literal_bool(i) -> i
	| Literal_string(i) -> i
	| _ -> raise (Failure "we can't print this")

(* TODO: Get rid of this garbage function. *)
let handle_print_function (print_term : string) =
	let prog_str = "
	public class Test {
		public static void main(String[] args) {
 		" ^ "System.out.println(\"" ^ print_term  ^ "\"); " ^ "
		}
	}
	" in
	let file = open_out "Test.java" in
  	Printf.fprintf file "%s" prog_str

let handle_expr_statement (expr : Ast.expr) = match expr
	with Call(f_name, args) -> (match f_name
		with "print" -> handle_print_function (string_data_literal(List.hd args))
		| _ -> print_endline "TODO: Implement function calls")
	| _ -> ()

(* compile AST to java syntax *)
let check_statement (stmt : Ast.stmt) = match stmt
	with Expr(e1) -> handle_expr_statement(e1)
	| Assign(data_type, id, e1) ->
		let e1 = string_to_data_type(data_type) and e2 = check_expr_data_type(e1) in
			equate e1 e2
	(* stmt_list contains func --> if func_name is print --> create Java syntax for printing
	 anything fails, reject program *)

(* entry point into semantic checker *)
let check_program (stmt_list : Ast.program) =
	List.map check_statement stmt_list
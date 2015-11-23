(* Compile the program to Java. Does no compile time check for now*)
open Ast;;
open Environment;;

type data_type = Int | Float | Bool | String | Array | Json | AnyType


exception ReturnStatementMissing;;

(* write program to .java file *)
let write_to_file prog_str =
    let file = open_out "Test.java" in
        Printf.fprintf file "%s" prog_str

(* TODO: Try to get rid of this. Weird to have two different representations. *)
let ast_data_to_data (dt : Ast.data_type) = match dt
	with Int -> Int
	| Float -> Float
	| Bool -> Bool
	| String -> String
	| Array(i) -> Array
	| Json -> Json
	| _ -> AnyType

let string_to_data_type (s : string) = match s
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

let rec check_expr_type (expr : Ast.expr) (env: Environment.symbol_table) = match expr
	with Literal_int(i) -> Int
	| Literal_float(i) -> Float
	| Literal_bool(i) -> Bool
	| Literal_string(i) -> String
	| Literal_array(i) -> Array
	| Json_from_file(i) -> Json
	| Binop(left_expr, op, right_expr) -> check_binop_type (check_expr_type left_expr env) op (check_expr_type right_expr env)
	| Id(i) -> ast_data_to_data((var_type i env))
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
let output_file =
	open_out_gen [Open_creat; Open_text; Open_append] 0o640 "Test.java"

let print_to_file (prog_str : string) =
	let file = output_file in
		Printf.fprintf file "%s" prog_str;;

let print_header (class_name : string) =
	let prog_str = "public class " ^ class_name ^ " { public static void main(String[] args) { " in
	print_to_file prog_str

let handle_print_function (print_term : string) =
	let prog_str = "System.out.println(\"" ^ print_term  ^ "\"); " in
	print_to_file prog_str

let handle_expr_statement (expr : Ast.expr) = match expr
	with Call(f_name, args) -> (match f_name
		with "print" -> handle_print_function (string_data_literal(List.hd args))
		| _ -> print_endline "TODO: Implement function calls")
	| _ -> ()

(* compile AST to java syntax *)
let rec check_statement (stmt : Ast.stmt) (env : Environment.symbol_table) = match stmt
	with Expr(e1) ->
		handle_expr_statement(e1);
		env
	| Assign(data_type, id, e1) ->
		let e1 = string_to_data_type(data_type) and e2 = check_expr_type (e1) (env) in
			equate e1 e2;
			declare_var id data_type env
	| Func_decl(func_name, arg_list, return_type, stmt_list) ->
		let func_env = declare_func func_name return_type arg_list env in
		(* TODO: Implement void functions *)
		if return_type != "void" && List.length arg_list == 0 then
			raise ReturnStatementMissing
		else
		check_function_statements (List.rev stmt_list) func_env return_type;
		env
	| _ -> raise (Failure "Unimplemented functionality")

and check_statements stmts env = match stmts
    with [] -> env
  | [stmt] -> check_statement stmt env
  | stmt :: other_stmts ->
  		let env = check_statement stmt env in
  		check_statements other_stmts env

and check_function_statements stmts env return_type = match stmts
    with [] ->
    if return_type != "void" then raise ReturnStatementMissing else
    env
  | [stmt] ->
  	check_return_statement stmt env return_type
  | stmt :: other_stmts ->
  		let env = check_statement stmt env in
  		check_function_statements other_stmts env return_type

and check_return_statement (stmt : Ast.stmt) (env : Environment.symbol_table) (return_type : string) =
	if return_type != "void" then match stmt
		with Return(expr) ->
			let left = string_to_data_type(return_type) and right = check_expr_type (expr) (env) in
				equate left right;
				env
		| _ -> raise (Failure "Function must end with return statement")
	else
		check_statement stmt env

(* entry point into semantic checker *)
let check_program (stmt_list : Ast.program) =
	let env = Environment.create in
	print_header "Test";
	check_statements stmt_list env;
	print_to_file " } }"


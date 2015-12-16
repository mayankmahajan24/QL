open Ast;;
open Environment;;

type data_type = Int | Float | Bool | String | Array | Json | AnyType

exception ReturnStatementMissing;;
exception ImproperBraceSelection;;
exception ImproperBraceSelectorType;;
exception MultiDimensionalArraysNotAllowed;;
exception NotBoolExpr;;
exception BadBinopType;;
exception IncorrectWhereType;;
exception UpdatingBool;;
exception IncorrectSelectorId;; (*When you use selectors with IDs that aren't jsons or arrays*)

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

let ast_data_to_string (dt : Ast.data_type) = match dt
	with Int -> "int"
	| Float -> "float"
	| Bool -> "bool"
	| String -> "string"
	| Array(i) -> "array"
	| Json -> "json"
	| _ -> raise (Failure "cannot convert to string")

let data_to_ast_data (dt : data_type) = match dt
	with Int -> Ast.Int
	| Float -> Ast.Float
	| Bool -> Ast.Bool
	| String -> Ast.String
	| Array -> Ast.Array(Ast.Int)
	| Json -> Ast.Json
	| _ -> Ast.AnyType

let string_to_data_type (s : string) = match s
	with "int" -> Int
	| "float" -> Float
	| "bool" -> Bool
	| "string" -> String
	| "array" -> Array
	| "json" -> Json
	| _ -> raise (Failure "unsupported data type")

let string_data_literal (expr : Ast.expr) = match expr
		with Literal_int(i) -> string_of_int i
	| Literal_float(i) -> string_of_float i
	| Literal_bool(i) -> i
	| Literal_string(i) -> i
	| _ -> raise (Failure "we can't print this")

let check_binop_type (left_expr : data_type) (op : Ast.math_op) (right_expr : data_type) = match (left_expr, op, right_expr)
	with (Int, _, Int) -> Int
	| (Float, _, Float) -> Float
	| (String, Add, String) -> String
	| (AnyType, _, Int) -> Int
	| (AnyType, _, Float) -> Float
	| (AnyType, Add, String) -> String
	| (Int, _, AnyType) -> Int
	| (Float, _, AnyType) -> Float
	| (String, Add, AnyType) -> String
	| (AnyType, Add, AnyType) -> AnyType
	| (AnyType, _, AnyType) -> Float
		(* If we're doing math on two any types, just assume it's a float. *)
	| (_, _, _) ->
		raise (Failure "cannot perform binary operations with provided arguments")

(*Possibly add int/float comparison*)
let check_bool_expr_binop_type (left_expr : data_type) (op : Ast.bool_op) (right_expr : data_type) = match op
		with Equal | Neq -> (match (left_expr, right_expr)
			with (Int, Int) -> Bool
			| (Float, Float) -> Bool
			| (String, String) -> Bool
			| (Bool, Bool) -> Bool
			| (AnyType, _) -> Bool
			| (_, AnyType) -> Bool
			| _ -> raise (Failure "cannot perform binary operations with provided arguments")
			)
		| Less | Leq | Greater | Geq -> (match (left_expr, right_expr)
			with (Int, Int) -> Bool
			| (Float, Float) -> Bool
			| (AnyType, _) -> Bool
			| (_, AnyType) -> Bool
			| _ -> raise (Failure "cannot perform binary operations with provided arguments")
			)

let rec check_bracket_select_type (d_type : data_type) (selectors : expr list) (env : symbol_table) (id : string) (serial : string) = match d_type
	with Array ->
		if List.length selectors != 1 then raise MultiDimensionalArraysNotAllowed;
		(* We can ignore the env because we're explicitly updating later. *)
		let (expr_type, _) = check_expr_type (List.hd selectors) (env) in
		if expr_type != Int && expr_type != AnyType then raise ImproperBraceSelectorType;
		let ast_array_type = array_type (id) (env) in
		let data_type = ast_data_to_data ast_array_type in
		if expr_type == AnyType then
			let expr_head = List.hd selectors in
			let json_update_map = json_selector_update (serialize (expr_head) (env)) "int" (env) in
			(data_type, json_update_map)
		else
			(data_type, env)
	(* Return the type being stored for this particular array *)
	| Json ->
		List.iteri (fun index expr ->
				let (expr_type, _) = check_expr_type (expr) (env) in
				(* Might need to infer the type if we JSON select, as it could be a string or int. *)
				if expr_type != String && index == 0 then (raise ImproperBraceSelectorType);
				if expr_type != String && expr_type != Int then (raise ImproperBraceSelectorType);
		) selectors;
		(ast_data_to_data (json_selector_type (serial) (env)), env)
	| _ -> raise ImproperBraceSelection

and check_expr_type (expr : Ast.expr) (env: Environment.symbol_table) = match expr
	with Literal_int(i) -> (Int,env)
	| Literal_float(i) -> (Float,env)
	| Literal_bool(i) -> (Bool,env)
	| Literal_string(i) -> (String,env)
	| Literal_array(i) -> (Array,env)
	| Json_from_file(i) -> (Json,env)
	| Binop(left_expr, op, right_expr) ->
		let (left_type, left_env) = (check_expr_type left_expr env) in
		let (right_type, right_env) = (check_expr_type right_expr left_env) in
		((check_binop_type left_type op right_type), right_env)
	| Id(i) -> (ast_data_to_data((var_type i env)), env)
	| Call(func_name, arg_list) ->
		let arg_types = List.map (fun expr ->
			let (expr_type, _) = (check_expr_type (expr) (env)) in
			(data_to_ast_data(expr_type))) arg_list in
		verify_func_call func_name arg_types env;
		let func_return_type = func_return_type func_name env in (match func_name
			with "print" ->	(ast_data_to_data(func_return_type), env)
			| "length" -> (ast_data_to_data(func_return_type), env)
			| _ -> let func_args = (FunctionMap.find func_name env.func_map) in
				let func_arg_types = func_args.args in
				let new_json_mapping = List.fold_left2 (fun env expr expected_type -> (match expr
					with Bracket_select(id, selectors) -> json_selector_update (serialize (expr) (env)) (ast_data_to_string expected_type) (env)
					| _ -> env
				)) env arg_list func_arg_types in
				(ast_data_to_data(func_return_type), new_json_mapping)
		)
	| Bracket_select(id, selectors) ->
		let selector_ast_data_type = var_type id env in
		let selector_data_type = ast_data_to_data selector_ast_data_type in
		(check_bracket_select_type (selector_data_type) (selectors) (env) (id) (serialize (expr) (env)))
	| Json_selector_list(i) ->
		(AnyType,env)

and serialize (expr : Ast.expr) (env : symbol_table) = match expr
	with Bracket_select(id, selectors) ->
		let serialized = List.fold_left (fun acc x ->
			let (expr_type,_) = check_expr_type (x) (env) in
			(match expr_type
				with String -> acc ^ "[\"" ^ (serialize_literal x) ^ "\"]"
				| Int -> acc ^ (serialize_literal x)
				| _ -> acc
			)
			) id (List.rev selectors) in
		serialized
		(* This is going to cause errors. Watch out for it. *)
	| _ -> raise (Failure "incorrect usage of bracket syntax")

and serialize_literal (literal : expr) = match literal
		with Literal_int(i) -> string_of_int i
	| Literal_float(i) -> string_of_float i
	| Literal_bool(i) -> i
	| Literal_string(i) -> i
	| Id(i) -> i
	| Bracket_select(id, selectors) -> (List.fold_left (
		fun str expr -> str ^ (serialize_literal (expr)))) id selectors
	| _ -> raise (Failure "we can't print this") 

let rec map_json_types (expr : Ast.expr) (env : symbol_table) (data_type : string) = match expr
	with Binop(left_expr, op, right_expr) ->
		let left_env = (map_json_types (left_expr) (env) (data_type)) in
		let right_env = (map_json_types (right_expr) (left_env) (data_type)) in
		right_env
	| Bracket_select(id, selectors) ->
		json_selector_update (serialize (expr) (env)) (data_type) (env)
	| _ -> env

let json_selector_found (expr : Ast.expr) (env : symbol_table) = match expr
	with Bracket_select(id, selectors) ->
		let selector_ast_data_type = var_type id env in
		let selector_data_type = ast_data_to_data selector_ast_data_type in
		if selector_data_type == Json then
			(List.iteri (fun index expr ->
				(* TODO: If we use a non-declared JSON value, we'll have an error. Think about how to infer this. *)
				let (expr_type,_) = check_expr_type (expr) (env) in
				if expr_type != String && index = 0 then raise ImproperBraceSelectorType;
				if expr_type != String && expr_type != Int then raise ImproperBraceSelectorType;
			) selectors;
			true)
		else
			false
	| _ -> false

let equate e1 e2 =
	if (e1 != e2) && (e1 != AnyType) && (e2 != AnyType) then raise (Failure "data_type mismatch")

let string_data_literal (expr : Ast.expr) = match expr
		with Literal_int(i) -> string_of_int i
	| Literal_float(i) -> string_of_float i
	| Literal_bool(i) -> i
	| Literal_string(i) -> i
	| _ -> raise (Failure "we can't print this")

let handle_expr_statement (expr : Ast.expr) (env: Environment.symbol_table) = match expr
	with Call(f_name, args) -> (match f_name with
		"print" ->
		 	if List.length args != 1 then
				raise (Failure "Print only takes one argument")
			else
				let (_, _) = (check_expr_type (List.hd args) (env)) in
				env
		| "length" ->
		 	if List.length args != 1 then
				raise (Failure "Length only takes one argument")
			else
				let (_, _) = (check_expr_type (List.hd args) (env)) in
				env
		| _ ->
			(* TODO: A bug could be here, cause we're ignoring the env variable we're getting *)
			let arg_types = List.map (fun expr ->
				let (expr_type, _) = (check_expr_type (expr) (env)) in
				(data_to_ast_data(expr_type))) args in
			verify_func_call f_name arg_types env;
			let func_args = FunctionMap.find f_name env.func_map in
			let func_arg_types = func_args.args in
			let new_json_mapping = List.fold_left2 (fun env expr expected_type -> (match expr
				with Bracket_select(id, selectors) -> json_selector_update (serialize (expr) (env)) (ast_data_to_string expected_type) (env)
				| _ -> env
				)) env args func_arg_types in
			new_json_mapping
		)
	| _ -> env

let handle_json (json_expr : Ast.expr) (env : Environment.symbol_table) = match json_expr
	with Id(i) -> (match var_type i env
		with Json -> Json
		| _ -> raise IncorrectWhereType)
	| Json_from_file(json) -> Json
	| _ -> raise IncorrectWhereType

let rec handle_bool_expr (bool_expr : Ast.bool_expr) (env : Environment.symbol_table) = match bool_expr
	with Literal_bool(i) -> (Bool,env)
	| Binop(e1, op, e2) ->
			let (l_type, left_env) = (check_expr_type e1 env) in
			let (r_type, right_env) = (check_expr_type e2 left_env) in
			let _ = check_bool_expr_binop_type (l_type) (op) (r_type) in
			(match (l_type, r_type)
				with (AnyType, AnyType) ->
					(* NOTE: We're defining things that are compared as floats, so we can define them as something. *)
					let new_left_env = json_selector_update (serialize (e1) (env)) "float" (right_env) in
					let new_right_env = json_selector_update (serialize (e2) (env)) "float" (new_left_env) in
					(Bool, new_right_env)
				| (AnyType, _) ->
					let new_env = json_selector_update (serialize (e1) (right_env)) (ast_data_to_string (data_to_ast_data (r_type))) (right_env) in
					(Bool, new_env)
				| (_, AnyType) ->
					let new_env = json_selector_update (serialize (e2) (right_env)) (ast_data_to_string (data_to_ast_data (l_type))) (right_env) in
					(Bool, new_env)
				| (_, _) -> (Bool, right_env)
			)
	| Bool_binop(e1, conditional, e2) ->
		let (_, left_env) = handle_bool_expr (e1) (env) in
		let (_, right_env) = handle_bool_expr (e2) (left_env) in
 		(Bool, right_env)
	| Not(e1) ->
		let (_,new_env) = handle_bool_expr (e1) (env) in
		(Bool, new_env)
	| Id(i) -> match var_type i env
		with Bool -> (Bool,env)
		| _ -> raise NotBoolExpr

(* compile AST to java syntax *)
let rec check_statement (stmt : Ast.stmt) (env : Environment.symbol_table) = match stmt
	with Expr(e1) ->
		let updated_expr = (handle_expr_statement (e1) (env)) in
		updated_expr
	| Update_variable (id, e1) ->
		let ast_dt = var_type id env in
			if ast_dt == Bool then
				raise UpdatingBool
			else
				let data_type = ast_data_to_data ast_dt in
					if data_type == Json then
						raise (Failure "json aliasing not supported")
					else
						let (right,new_env) = check_expr_type (e1) (env) in
							equate data_type right;
							(match right
								with AnyType -> json_selector_update (serialize (e1) (new_env)) (ast_data_to_string ast_dt) (new_env)
								| _ -> new_env
							)
 	| If(bool_expr, then_stmt, else_stmt) ->
		let (_,new_env) = handle_bool_expr bool_expr env in
		let _ = check_statements (List.rev then_stmt) (new_env) in
		let _ = check_statements (List.rev else_stmt) (new_env) in
			new_env
  	| Update_array_element (id, e1, e2) ->
  		let ast_array_data_type = array_type id env in
		let data_type = ast_data_to_data ast_array_data_type in
		let (right, new_env) = check_expr_type (e2) (env) in
			equate data_type right;
			env;
	| For(init_stmt, bool_expr, update_stmt, stmt_list) ->
		let init_env = check_statement init_stmt env in
		let (_,new_env) = handle_bool_expr bool_expr init_env in
		let update_env = check_statement update_stmt new_env in
		let _ = check_statements (List.rev stmt_list) (update_env) in
			(* We need to worry about scoping here. I think we want all the things in bool expr to count. *)
		new_env
	| While(bool_expr, body) ->
		let (_,while_env) = handle_bool_expr bool_expr env in
		let _ = check_statements (List.rev body) (while_env) in
		(* Same thing here. We might want to be returning while_env *)
		while_env
	| Where(bool_expr, id, stmt_list, json_object) ->
		let update_env = declare_var id "json" env in
		let (_,where_env) = handle_bool_expr bool_expr update_env in
		let _ = handle_json json_object update_env in
		let _ = (check_statements (List.rev stmt_list) (update_env)) in
		(* Also here. *)
		where_env
	| Assign(data_type, id, e1) ->
		if (json_selector_found e1 env) == true then
			let updated_env = declare_var id data_type env in
			json_selector_update (serialize e1 env) data_type updated_env;
		else
			let left = string_to_data_type(data_type) and (right,new_env) = check_expr_type (e1) (env) in
			equate left right;
			let declared_var = declare_var id data_type new_env in
			map_json_types e1 declared_var data_type
	| Array_assign(expected_data_type, id, e1) ->
		let left = data_to_ast_data(string_to_data_type(expected_data_type)) in
			let inferred_type = List.map (fun expr ->
				(* Don't need to use new env because we won't have JSON in the array *)
				let (data_type,_) = (check_expr_type (expr) (env)) in
				data_to_ast_data (data_type)) e1 in
				let declare_var_env = declare_var id "array" env in
					define_array_type (left) (inferred_type) (declare_var_env) (id)
	| Fixed_length_array_assign(expected_data_type, id, length) ->
		let left = data_to_ast_data(string_to_data_type(expected_data_type)) in
			let declare_var_env = declare_var id "array" env in
				define_array_type left [] declare_var_env id
	| Array_select_assign(expected_data_type, new_var_id, array_id, e1 ) ->
		let left = data_to_ast_data(string_to_data_type(expected_data_type)) in
			let _ = (match ast_data_to_data(var_type array_id env)
			with Json -> true
			| Array -> equate (ast_data_to_data left) (ast_data_to_data (array_type array_id env));
						true
			| _ -> raise IncorrectSelectorId;
			)	in
			let declare_var_env = declare_var new_var_id "array" env in 
				define_array_type left [] declare_var_env new_var_id
	| Bool_assign(data_type, id, e1) ->
		let left = string_to_data_type(data_type) and (right,new_env) = handle_bool_expr (e1) (env) in
			equate left right;
			declare_var id data_type new_env;
	| Func_decl(func_name, arg_list, return_type, stmt_list) ->
		let func_env = declare_func func_name return_type arg_list env in
		let func_env_vars = define_func_vars arg_list func_env in
		(* TODO: Implement void functions *)
		if (return_type != "void" && (List.length arg_list) == 0) then raise ReturnStatementMissing;
		let _ = check_function_statements (List.rev stmt_list) func_env_vars return_type in
		func_env
	| Noop -> env
	| _ -> raise (Failure "Unimplemented functionality")

and check_statements (stmts : Ast.stmt list) (env : Environment.symbol_table) = match stmts
    with [] -> env
  | [stmt] -> check_statement stmt env
  | stmt :: other_stmts ->
   		let new_env = check_statement stmt env in
  		check_statements other_stmts new_env

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
			(* Since we're returning, we don't need to declare the returned JSON type as a type *)
			let left = string_to_data_type(return_type) and (right,_) = check_expr_type (expr) (env) in
				equate left right;
				env
		| _ -> raise (Failure "Function must end with return statement")
	else
		check_statement stmt env


(* entry point into semantic checker *)
let check_program (stmt_list : Ast.program) =
	let env = Environment.create in
	check_statements (stmt_list) (env);



open Ast;;
open Environment;;
open Jast;;
open Semantic;;

let ql_to_java_type (data_type : string) = match data_type
  with "int" -> "int"
  | "float" -> "double"
  | "string" -> "String"
  | "json" -> "JSONObject"
  | "bool" -> "boolean"
  | _ -> "Invalid data type"

let convert_math_op (op : Ast.math_op) = match op
  with Add -> Jast.Add
  | Sub -> Jast.Sub
  | Mult -> Jast.Mult
  | Div -> Jast.Div

let convert_bool_op (op : Ast.bool_op) = match op
  with Equal -> Jast.Equal
  | Neq -> Jast.Neq
  | Less -> Jast.Less
  | Leq -> Jast.Leq
  | Greater -> Jast.Greater
  | Geq -> Jast.Geq

let convert_cond (cond : Ast.conditional) = match cond
  with And -> Jast.And
  | Or -> Jast.Or

let rec convert_data_type (data_type : Semantic.data_type) = match data_type
  with Semantic.Int -> Jast.Int
  | Semantic.Float -> Jast.Double
  | Semantic.Bool -> Jast.Bool
  | Semantic.String -> Jast.String
  | Semantic.Json -> Jast.Json
  | Semantic.Array -> Jast.Array(convert_data_type (data_type))
  | Semantic.AnyType -> raise (Failure "We should not have an AnyType here.")

let rec convert_expr (expr : Ast.expr) (symbol_table : Environment.symbol_table) = match expr
  with Ast.Literal_int(i) -> Jast.Literal_int(i)
  | Ast.Literal_string(i) -> Jast.Literal_string(i)
  | Ast.Literal_float(i) -> Jast.Literal_double(i)
  | Ast.Literal_bool(i) -> Jast.Literal_bool(i)
  | Ast.Call(func_name, arg_list) ->
    let converted_args = List.map (fun arg -> (convert_expr (arg) (symbol_table))) arg_list in
    Jast.Call(func_name, converted_args)
  | Ast.Id(i) -> Jast.Id(i)
  | Ast.Binop(left_expr, op, right_expr) ->
    let left_convert = convert_expr left_expr symbol_table in
    let right_convert = convert_expr right_expr symbol_table in
    let op_convert = convert_math_op op in
    Jast.Binop(left_convert, op_convert, right_convert)
  | Ast.Bracket_select(id, selectors) ->
    let id_type = var_type id symbol_table in
    (match id_type
      with Array(data_type) ->
        let head_expr = (convert_expr (List.hd selectors) (symbol_table)) in
        Jast.Array_select(id, head_expr)
      | _ ->
        let selector_exprs = List.map (fun select -> (convert_expr (select) (symbol_table))) selectors in
        let serialize_id = serialize (expr) (symbol_table) in
        let json_type = json_selector_type (serialize_id) (symbol_table) in
        let java_type = ql_to_java_type (ast_data_to_string (json_type)) in
        let selector_types = List.map (fun expr -> 
          let (expr_type,_) = check_expr_type (expr) (symbol_table) in
          convert_data_type (expr_type)
        ) selectors in
        Jast.Bracket_select(id, java_type, selector_exprs, selector_types)
    )
  | Ast.Json_from_file(i) -> Jast.Json_object(i)
  | Ast.Literal_array(expr_list) ->
    let sast_exprs = List.map (fun expr -> (convert_expr (expr) (symbol_table))) expr_list in
    Jast.Array_initializer(sast_exprs)
  | _ -> Jast.Dummy_expr("We gotta get rid of this")

let rec convert_bool_expr (op : Ast.bool_expr) (symbol_table : Environment.symbol_table) = match op
  with Ast.Literal_bool(i) -> Jast.Literal_bool(i)
  | Ast.Binop(left_exp, op, right_expr) -> Jast.Binop((convert_expr (left_exp) (symbol_table)), (convert_bool_op (op)), (convert_expr (right_expr) (symbol_table)))
  | Ast.Bool_binop(left_exp, cond, right_exp) -> Jast.Bool_binop((convert_bool_expr (left_exp) (symbol_table)), (convert_cond cond), (convert_bool_expr (right_exp) (symbol_table)))
  | Ast.Not(exp) -> Jast.Not((convert_bool_expr (exp) (symbol_table)))
  | Ast.Id(i) -> Jast.Id(i)

let convert_arg_decl (arg_decl : Ast.arg_decl) =
  {
    var_type = ql_to_java_type arg_decl.var_type;
    var_name = arg_decl.var_name;
  }

let rec build_expr_list (jast_exprs: Jast.expr list) (exprs: Ast.expr list) (symbol_table: Environment.symbol_table) = 
  match exprs
    with [head] -> List.rev (jast_exprs@[(convert_expr head symbol_table)])
    | head :: tl -> (build_expr_list (jast_exprs@[(convert_expr head symbol_table)]) tl symbol_table)
    | _ -> []

let rec convert_statement (stmt : Ast.stmt) (symbol_table : Environment.symbol_table) = match stmt
  with Ast.Assign(data_type, id, e1) ->
    let corresponding_data_type = ql_to_java_type data_type in
    Jast.Assign(corresponding_data_type, id, (convert_expr (e1) (symbol_table)))
  | Ast.Expr(e1) -> Jast.Expr(convert_expr e1 symbol_table)
  | Ast.Array_assign(expected_data_type, id, e1) ->
    let expr_list = List.map (fun expr -> (convert_expr (expr) (symbol_table))) e1 in
    Jast.Array_assign((ql_to_java_type (expected_data_type)), id, expr_list)
  | Ast.Fixed_length_array_assign(expected_data_type, id, length) ->
    Jast.Fixed_length_array_assign(expected_data_type, id, length)
  | Ast.Update_variable (id, e1) ->
    let update_expr = convert_expr e1 symbol_table in
    Jast.Update_variable(id, update_expr)
  | Ast.Update_array_element (id, e1, e2) ->
    let index_expr = convert_expr e1 symbol_table in
      let update_expr = convert_expr e2 symbol_table in
        Jast.Update_array_element(id, index_expr, update_expr)
  | Ast.Bool_assign(data_type, id, e1) -> Jast.Bool_assign(id, (convert_bool_expr (e1) (symbol_table)))
  | Ast.Return(e1) -> Jast.Return(convert_expr e1 symbol_table)
  | Ast.Func_decl(id, arg_decl_list, return_type, body) ->
    let jast_arg_decl_list = List.map convert_arg_decl arg_decl_list in
    let jast_body = build_list [] body symbol_table in
    Jast.Func_decl(id, jast_arg_decl_list, ql_to_java_type return_type, jast_body)
  | Ast.If(condition, body, else_body) ->
    let jast_body = build_list [] body symbol_table in
    let jast_else_body = build_list [] else_body symbol_table in
    Jast.If(convert_bool_expr condition symbol_table, jast_body, jast_else_body)
  | Ast.While(condition, body) ->
    let jast_body = build_list [] body symbol_table in
    Jast.While(convert_bool_expr condition symbol_table, jast_body)
  | Ast.For(init, condition, update, body) ->
    let jast_init = convert_statement init symbol_table in
    let jast_condition = convert_bool_expr condition symbol_table in
    let jast_update = convert_statement update symbol_table in
    let jast_body = build_list [] body symbol_table in
    Jast.For(jast_init, jast_condition, jast_update, jast_body)
  | Ast.Array_select_assign(expected_data_type, new_var_id, array_id, selectors) ->
    Jast.Array_select_assign((ql_to_java_type expected_data_type), new_var_id, array_id, (build_expr_list [] selectors symbol_table))
  | Ast.Where(condition, id, body, json) ->
    let jast_condition = convert_bool_expr condition symbol_table in
    let jast_body = build_list [] body symbol_table in
    let jast_json = convert_expr json symbol_table in
    Jast.Where(jast_condition, id, jast_body, jast_json)
  | _ -> Jast.Dummy_stmt("Really just terrible programming")

and build_list (jast_body: Jast.stmt list) (body: Ast.stmt list) (symbol_table: Environment.symbol_table) =
  match body
    with [head] -> List.rev (jast_body@[(convert_statement head symbol_table)])
    | head :: tl -> (build_list (jast_body@[(convert_statement head symbol_table)]) tl symbol_table)
    | _ -> []

let convert_semantic (stmt_list : Ast.program) (symbol_table : Environment.symbol_table) =
  List.map (fun stmt -> convert_statement (stmt) (symbol_table)) stmt_list

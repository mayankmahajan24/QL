open Ast;;
open Environment;;
open Jast;;

let ql_to_java_type (data_type : string) = match data_type
  with "int" -> "int"
  | "float" -> "double"
  | "string" -> "String"
  | "json" -> "JSONObject"
  | _ -> "Invalid data type"

let convert_math_op (op : Ast.math_op) = match op
  with Add -> Jast.Add 
  | Sub -> Jast.Sub
  | Mult -> Jast.Mult
  | Div -> Jast.Div

let rec convert_expr (expr : Ast.expr) (symbol_table : Environment.symbol_table) = match expr
  with Ast.Literal_int(i) -> Jast.Literal_int(i)
  | Ast.Literal_string(i) -> Jast.Literal_string(i)
  | Ast.Literal_float(i) -> Jast.Literal_double(i)
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
        Jast.Bracket_select(id, selector_exprs)
    )
  | _ -> Jast.Dummy_expr("This is horrendous")

let convert_statement (stmt : Ast.stmt) (symbol_table : Environment.symbol_table) = match stmt
  with Ast.Assign(data_type, id, e1) ->
    let corresponding_data_type = ql_to_java_type data_type in
    Jast.Assign(corresponding_data_type, id, (convert_expr (e1) (symbol_table)))
  | Ast.Expr(e1) -> Jast.Expr(convert_expr e1 symbol_table)
  | Ast.Array_assign(expected_data_type, id, e1) ->
    let expr_list = List.map (fun expr -> (convert_expr (expr) (symbol_table))) e1 in
    Jast.Array_assign((ql_to_java_type (expected_data_type)), id, expr_list)
  | Ast.Update_variable (id, e1) ->
    let update_expr = convert_expr e1 symbol_table in
    Jast.Update_variable(id, update_expr)
  | _ -> Jast.Dummy_stmt("Really just terrible programming")

let convert_semantic (stmt_list : Ast.program) (symbol_table : Environment.symbol_table) = 
  List.map (fun stmt -> convert_statement (stmt) (symbol_table)) stmt_list 
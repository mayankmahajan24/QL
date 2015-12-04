open Ast;;
open Environment;;
open Jast;;

let rec convert_expr (expr : Ast.expr) (symbol_table : Environment.symbol_table) = match expr
  with Ast.Literal_int(i) -> Jast.Literal_int(i)
  | Ast.Literal_string(i) -> Jast.Literal_string(i)
  | Ast.Call(func_name, arg_list) -> 
    let converted_args = List.map (fun arg -> (convert_expr (arg) (symbol_table))) arg_list in
    Jast.Call(func_name, converted_args)
  | _ -> Jast.Dummy_expr("This is horrendous")

let convert_statement (stmt : Ast.stmt) (symbol_table : Environment.symbol_table) = match stmt
  with Ast.Assign(data_type, id, e1) -> Jast.Assign(data_type, id, (convert_expr (e1) (symbol_table)))
  | Ast.Expr(e1) -> Jast.Expr(convert_expr e1 symbol_table)
  | _ -> Jast.Dummy_stmt("Really just terrible programming")

let convert_semantic (stmt_list : Ast.program) (symbol_table : Environment.symbol_table) = 
  List.map (fun stmt -> convert_statement (stmt) (symbol_table)) stmt_list 
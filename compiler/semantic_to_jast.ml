open Ast;;
open Environment;;
open Jast;;

let convert_expr (expr : Ast.expr) (symbol_table : Environment.symbol_table) = match expr
  with Ast.Literal_int(i) -> Jast.Literal_int(i)
  | _ -> Jast.Dummy_expr("This is horrendous")

let convert_statement (stmt : Ast.stmt) (symbol_table : Environment.symbol_table) = match stmt
  with Ast.Assign(data_type, id, e1) -> Jast.Assign(data_type, id, (convert_expr (e1) (symbol_table)))
  | _ -> Jast.Dummy_stmt("Really just terrible programming")

let convert_semantic (stmt_list : Ast.program) (symbol_table : Environment.symbol_table) = 
  List.map (fun stmt -> convert_statement (stmt) (symbol_table)) stmt_list 
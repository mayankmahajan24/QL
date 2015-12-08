open Jast;;

let convert_operator (op : math_op) = match op
  with Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"

let convert_bool_operator (op : bool_op) = match op
  with Equal -> "==" 
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="

let convert_cond_op (cond : conditional) = match cond
  with And -> "&&"
  | Or -> "||"

let rec handle_expression (expr : Jast.expr) = match expr 
  with Call(func_name, expr_list) -> (match func_name
    with "print" ->
      "System.out.println(" ^ (handle_expression (List.hd expr_list)) ^ ");\n"
    | _ -> "")
  | Literal_string(i) -> "\"" ^ i ^ "\""
  | Literal_int(i) -> string_of_int i
  | Literal_double(i) -> string_of_float i
  | Id(i) -> i
  | Array_select(id, interior) ->
    let select_index = handle_expression interior in
    id ^ "[" ^ select_index ^ "]"
  | Literal_bool(i) -> "\"" ^ i ^ "\""
  (* Think about printing literal with the lower case to match those printed with identifiers *)
  | Binop(left_expr, op, right_expr) -> handle_expression left_expr ^ " " ^ convert_operator op ^ " " ^ handle_expression right_expr
  | _ -> ""

let rec handle_bool_expr (expr : Jast.bool_expr) = match expr
  with Literal_bool(i) ->
    (match i
      with "True" -> "true"
      | "False" -> "false"
      | _ -> "bad")
  | Binop(left_expr, op, right_expr) ->
    (handle_expression left_expr) ^ " " ^ (convert_bool_operator op) ^ " " ^ (handle_expression right_expr) 
  | Bool_binop(left_expr, cond, right_expr) ->
    (handle_bool_expr left_expr) ^ " " ^ (convert_cond_op cond) ^ " " ^ (handle_bool_expr right_expr)
  | Not(expr) ->
    "!" ^ (handle_bool_expr expr)
  | Id(i) -> i

let rec comma_separate_list (expr_list : Jast.expr list) = match expr_list
  with [] -> ""
  | head :: exprs ->
    if List.length exprs != 0 then
      (handle_expression head) ^ "," ^ (comma_separate_list exprs)
    else
      (handle_expression head)

let rec handle_statement (stmt : Jast.stmt) (prog_string : string) (func_string : string) = match stmt
  with Expr(expr) ->
    let expr_string = handle_expression expr in 
    let new_prog_string = prog_string ^ expr_string in
    (new_prog_string, func_string)
  | Assign(data_type, id, expr) ->
    let expr_string = handle_expression expr in
    let assign_string = data_type ^ " " ^ id ^ " = " ^ expr_string ^ ";\n" in
    let new_prog_string = prog_string ^ assign_string in 
    (new_prog_string, func_string)
  | Array_assign(expected_data, id, e1) ->
    let new_prog_string = prog_string ^ expected_data ^ "[] " ^ id ^ " = {" ^ (comma_separate_list (e1)) ^ "};\n" in
    (new_prog_string, func_string)
  | Jast.Update_variable(id, expr) -> 
    let new_prog_string = prog_string ^ id ^ " = " ^ (handle_expression (expr)) ^ ";\n" in
    (new_prog_string, func_string)
  | Bool_assign(id, expr) ->
    (* Why can't we reassign to a boolean? Seems broken *)
    let new_prog_string = prog_string ^ "boolean " ^ id ^ " = " ^ (handle_bool_expr expr) ^ ";\n" in
    (new_prog_string, func_string)
  | _ -> (prog_string, func_string)

(* This won't work for functions, which we need to define externally. Maybe give a separate string for these? *)
and handle_statements (stmt_list : Jast.program) (prog_string : string) (func_string : string) = match stmt_list
    with [] -> (prog_string, func_string)
  | [stmt] -> handle_statement stmt prog_string func_string
  | stmt :: other_stmts ->
      let (new_prog_string, new_func_string) = handle_statement stmt prog_string func_string in
      handle_statements other_stmts new_prog_string new_func_string

let print_to_file (prog_str : string) (file_name : string) =
  let file = (open_out file_name) in
    Printf.fprintf file "%s" prog_str;;

let program_header (class_name : string) =
  let prog_string  = "public class " ^ class_name ^ " { 
    public static void main(String[] args) { 
      try {
    " in
  prog_string

let program_footer = " } catch (Exception e) {\nSystem.out.println(\"No\");\n}\n}" 

let generate_code (program : Jast.program) (file_name : string) = 
  let (prog, funcs) = handle_statements program "" "" in
  let final_program = (program_header file_name) ^ prog ^ program_footer ^ funcs ^ " \n}" in
  let java_program_name = file_name ^ ".java" in
  print_to_file final_program java_program_name;;
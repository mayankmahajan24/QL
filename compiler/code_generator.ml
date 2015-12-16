open Jast;;
open Str;;

let rec range i j = if i > j then [] else i :: (range (i+1) j)

let rec range i j = if i > j then [] else i :: (range (i+1) j)

let rec range i j = if i > j then [] else i :: (range (i+1) j)

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

let cast_json_access (prog_str : string) (data_type : string) = match data_type
  with "int" -> "((Long) " ^ prog_str ^ ").intValue()"
  | "double" -> "((Number) " ^ prog_str ^ ").doubleValue()"
  | "JSONObject" -> ""
  | "boolean" -> ""
  | "String" ->  "(String)" ^ prog_str
  | _ -> raise (Failure "cast_json_access failure")

let rec comma_separate_list (expr_list : Jast.expr list) = match expr_list
  with [] -> ""
  | head :: exprs ->
    if List.length exprs != 0 then
      (handle_expression head) ^ "," ^ (comma_separate_list exprs)
    else
      (handle_expression head)

and handle_expression (expr : Jast.expr) = match expr
  with Call(func_name, expr_list) -> (match func_name
    with "print" ->
      "System.out.println(" ^ (handle_expression (List.hd expr_list)) ^ ");\n"
    | "length" -> (match List.hd expr_list
      with Id(i) ->
        i ^ ".length\n"
      | _ -> "oops"
      )
    | _ -> func_name ^ "(" ^ comma_separate_list expr_list ^ ")"
  )
  | Literal_string(i) -> "\"" ^ i ^ "\""
  | Literal_int(i) -> string_of_int i
  | Literal_double(i) -> string_of_float i
  | Id(i) -> i
  | Array_select(id, interior) ->
    let select_index = handle_expression interior in
    id ^ "[" ^ select_index ^ "]"
  | Literal_bool(i) ->
    (match i
      with "True" -> "true"
      | "False" -> "false"
      | _ -> "bad")
  (* Think about printing literal with the lower case to match those printed with identifiers *)
  | Binop(left_expr, op, right_expr) -> handle_expression left_expr ^ " " ^ convert_operator op ^ " " ^ handle_expression right_expr
  | Json_object(file_name) -> "(JSONObject) (new JSONParser()).parse(new FileReader(\""^ file_name ^ "\"))"
  | Array_initializer(expr_list) -> "{" ^ comma_separate_list (expr_list) ^ "}"
  | Bracket_select(id, data_type, expr_list, expr_types) ->
    (* This is wonky logic, but it should work *)
    if List.length expr_list == 1 then (
      cast_json_access (id ^ ".get(" ^ handle_expression (List.hd expr_list) ^ ")") data_type
      )
    else
      let expr_type_pairs = List.combine expr_list expr_types in
      let expr_num_range = range 0 ((List.length expr_list) - 1) in
      let prog_str = List.fold_left2 (fun prog_str expr_pair index ->
        let (expr, expr_type) = expr_pair in
        if index != ((List.length expr_list) - 1) then (
          if index = 0 then (
            (match (List.nth expr_types (index + 1))
              with Int -> "((JSONArray) " ^ id ^ ".get(" ^ handle_expression (expr) ^ "))"
              | String -> "((JSONObject) " ^ id ^ ".get(" ^ handle_expression(expr) ^ "))"
              | _ -> raise (Failure "Fuck this.")
            )
          )
          else (
            (match (List.nth expr_types (index + 1))
              with Int -> "((JSONArray) " ^ prog_str ^ ".get(" ^ handle_expression (expr) ^ "))"
              | String -> "((JSONObject) " ^ prog_str ^ ".get(" ^ handle_expression(expr) ^ "))"
              | _ -> raise (Failure "Fuck this.")
            )
          )
        )
        else (
          cast_json_access (prog_str ^ ".get(" ^ handle_expression (expr) ^ ")") data_type
        )
      ) "" expr_type_pairs expr_num_range in
      prog_str
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

let rec comma_separate_arg_list (arg_decl_list : Jast.arg_decl list) = match arg_decl_list
  with [] -> ""
  | head :: arg_decls ->
    if List.length arg_decls != 0 then
      head.var_type ^ " " ^ head.var_name ^ "," ^ (comma_separate_arg_list arg_decls)
    else
      head.var_type ^ " " ^ head.var_name

let remove_semicolon (str : string) =
  Str.global_replace (Str.regexp_string ";") "" str

let rec handle_statement (stmt : Jast.stmt) (prog_string : string) (var_string: string) (func_string : string) (in_block : bool) = match stmt
  with Expr(expr) ->
    let expr_string = handle_expression expr in
    let new_prog_string = prog_string ^ expr_string ^ ";" in
    (new_prog_string, var_string, func_string)
  | Assign(data_type, id, expr) ->
    let expr_string = handle_expression expr in
    if not in_block then (
      let assign_string = "static " ^ data_type ^ " " ^ id ^ " = " ^ expr_string ^ ";\n" in
      (prog_string, var_string ^ assign_string, func_string)
    )
    else (
      let assign_string = data_type ^ " " ^ id ^ " = " ^ expr_string ^ ";\n" in
      (prog_string ^ assign_string, var_string, func_string)
    )
  | Array_assign(expected_data, id, e1) ->
    if not in_block then (
      let new_var_string = var_string ^ "static " ^ expected_data ^ "[] " ^ id ^ " = {" ^ (comma_separate_list (e1)) ^ "};" in
      (prog_string, new_var_string, func_string)
    ) else (
      let new_prog_string = prog_string ^ expected_data ^ "[] " ^ id ^ " = {" ^ (comma_separate_list (e1)) ^ "};" in
      (new_prog_string, var_string, func_string)
    )
  | Fixed_length_array_assign(expected_data, id, length) ->
      if not in_block then (
      let new_var_string = var_string ^ "static " ^ expected_data ^ "[] " ^ id ^ " = new " ^ expected_data ^ "[" ^ string_of_int length ^ "];\n" in
      (prog_string, new_var_string, func_string)
    ) else (
      let new_prog_string = prog_string ^ expected_data ^ "[] " ^ id ^ " = new " ^ expected_data ^ "[" ^ string_of_int length ^ "];\n" in
      (new_prog_string, var_string, func_string)
    )
  | Jast.Update_variable(id, expr) ->
    let new_prog_string = prog_string ^ id ^ " = " ^ (handle_expression (expr)) ^ ";\n" in
    (new_prog_string, var_string, func_string)
  | Jast.Update_array_element(id, e1, e2) ->
    let new_prog_string = prog_string ^ id ^ "[" ^ (handle_expression(e1)) ^ "] = " ^ (handle_expression(e2)) ^ ";\n" in
    (new_prog_string, var_string, func_string)
  | Bool_assign(id, expr) ->
    (* Why can't we reassign to a boolean? Seems broken *)
    let new_prog_string = prog_string ^ "boolean " ^ id ^ " = " ^ (handle_bool_expr expr) ^ ";" in
    (new_prog_string, var_string, func_string)
  | Func_decl(id, arg_decl_list, return_type, body) ->
    let (prog, var, func) = handle_statements body "" "" "" true in
    let new_func_string = func_string ^ "public static " ^ return_type ^ " " ^ id ^ "(" ^ comma_separate_arg_list arg_decl_list ^ ")" ^ "{\n" ^ prog ^ "}\n" in
     (prog_string, var_string, new_func_string)
  | Return(e1) ->
    let new_prog_string = prog_string ^ "return " ^ (handle_expression e1) ^ ";" in
    (new_prog_string, var_string, func_string)
  | If(condition, body, else_body) ->
    let (prog, var, func) = handle_statements body "" "" "" true in
    let (else_prog, else_var, else_func) = handle_statements else_body "" "" "" true in
    let new_prog_string = prog_string ^ "if (" ^ handle_bool_expr condition ^ ") {" ^ prog ^ "} else {\n" ^ else_prog ^ "}" in
    (new_prog_string, var_string, func_string)
  | While(condition, body) ->
    let (prog, var, func) = handle_statements body "" "" "" true in
    let new_prog_string = prog_string ^ "while (" ^ handle_bool_expr condition ^ ") {" ^ prog ^ "}\n" in
    (new_prog_string, var_string, func_string)
  | For(init, condition, update, body)  ->
    let (init_stmt, init_var, init_func) = handle_statement init "" "" "" true in
    let condition_stmt = handle_bool_expr condition in
    let (update_stmt, update_var, update_func) = handle_statement update "" "" "" false in
    let (body_stmt, update_var, body_func) = handle_statements body "" "" "" false in
    let new_prog_string = prog_string ^
      "for (" ^ init_stmt ^ condition_stmt ^ ";" ^ remove_semicolon(update_stmt) ^ ") {\n"
         ^ body_stmt ^ "}\n" in
    (new_prog_string, var_string, func_string)
  | _ -> (prog_string, var_string, func_string)

and handle_statements (stmt_list : Jast.program) (prog_string : string) (var_string: string) (func_string : string) (in_block : bool)  = match stmt_list
    with [] -> (prog_string, var_string, func_string)
  | [stmt] -> 
    let (prog, var, func) = (handle_statement stmt prog_string var_string func_string in_block) in
    (prog ^ "\n", var, func)
  | stmt :: other_stmts ->
      (* We add a blank line for each statement. Don't need to do this in the case of assing *)
      let (new_prog_string, new_var_string, new_func_string) = (handle_statement stmt (prog_string ^ "\n") var_string func_string in_block) in
      handle_statements other_stmts new_prog_string new_var_string new_func_string in_block

let print_to_file (prog_str : string) (file_name : string) =
  let file = (open_out file_name) in
    Printf.fprintf file "%s" prog_str;;

let program_header (class_name : string) =
  let header_string = "
  import java.io.FileReader;\n
  import java.util.Iterator;\n
 
  import org.json.simple.JSONArray;\n
  import org.json.simple.JSONObject;\n
  import org.json.simple.parser.JSONParser;\n" in
  let prog_string  = header_string ^ "public class " ^ class_name ^ " { 

    " in
  prog_string

let main_method = "public static void main(String[] args) { 
      try {
    "

let program_footer = " } catch (Exception e) {\nSystem.out.println(\"No\");\n}\n}"

let generate_code (program : Jast.program) (file_name : string) =
  let (prog, var, funcs) = handle_statements program "" "" "" false in
  let final_program = (program_header file_name) ^ var ^ main_method ^ prog ^ program_footer ^ funcs ^ " \n}" in
  let java_program_name = file_name ^ ".java" in
  print_to_file final_program java_program_name;;
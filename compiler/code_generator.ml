open Jast;;

let rec handle_statement (stmt : Jast.stmt) (prog_string : string) (func_string : string) = 
  (prog_string, func_string)

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
  let prog_string  = "public class " ^ class_name ^ " { public static void main(String[] args) { " in
  prog_string

let generate_code (program : Jast.program) (file_name : string) = 
  let (prog, funcs) = handle_statements program "" "" in
  let final_program = (program_header file_name) ^ prog ^ "}" ^ funcs ^ " }" in
  let java_program_name = file_name ^ ".java" in
  print_to_file final_program java_program_name;;
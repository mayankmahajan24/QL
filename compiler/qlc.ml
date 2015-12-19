(*
 * QL
 *
 * Manager: Matthew Piccolella
 * Systems Architect: Anshul Gupta
 * Tester: Evan Tarrh
 * Language Guru: Gary Lin
 * Systems Integrator: Mayank Mahajan
 *)

type action = Raw | Ast | Semantic | Semantic_to_jast | Code_generator

let _ =
  if Array.length Sys.argv > 2 then
    let file_name = Sys.argv.(1) in
    let file_executable = Sys.argv.(2) in 
    let file = open_in (file_name) in 
    let lexbuf = Lexing.from_channel file in
    let program = Parser.program Scanner.token lexbuf in
    let symbol_table = Semantic.check_program program in
    let jast = Semantic_to_jast.convert_semantic program symbol_table in
    Code_generator.generate_code jast file_executable
  else (
    if Array.length Sys.argv > 1 then (
      print_endline "Please provide a name for your executable.";
    )
    else (
      print_endline "Please provide both a QL file and a name for your executable.";
    )
  )

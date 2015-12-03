type action = Raw | Ast | Semantic | Semantic_to_jast | Code_generator

let _ =
  if Array.length Sys.argv > 1 then
    let file_name = Sys.argv.(1) in
    let lexbuf = Lexing.from_channel stdin in
    let program = Parser.program Scanner.token lexbuf in
    let symbol_table = Semantic.check_program program in
    let jast = Semantic_to_jast.convert_semantic program symbol_table in
    Code_generator.generate_code jast file_name
  else
    print_endline "Please provide a file name"

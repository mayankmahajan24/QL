type action = Raw | Ast | Semantic

let _ =
  let action = if Array.length Sys.argv > 1 then
    List.assoc Sys.argv.(1) [ ("-r", Raw);
                              ("-a", Ast);
                            ]
  else Raw in
  let lexbuf = Lexing.from_channel stdin in
  let program = Parser.program Scanner.token lexbuf in
  Semantic.check_program program

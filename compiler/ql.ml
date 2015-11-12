type action = Raw | Ast

let _ =
  let action = if Array.length Sys.argv > 1 then
    List.assoc Sys.argv.(1) [ ("-r", Raw);
                              ("-a", Ast);
                            ]
  else Raw in
  let lexbuf = Lexing.from_channel stdin in
  let program = Parser.program Scanner.token lexbuf in
  match action with
    Raw -> print_endline "TODO: Add a printer that does something"
  | Ast -> print_endline "TODO: Add a printer that does something"

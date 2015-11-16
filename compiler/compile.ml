(* Compile the program to Java. Does no compile time check for now*)
open Ast

module StringMap = Map.Make(String)

(* Symbol table *)
type env = {
	var_index : data_type StringMap.t;
}

(* write program to .java file *)
let write_to_file prog_str =
    let file = open_out "test.java" in
        Printf.fprintf file "%s" prog_str 

let rec match_expr expr = match expr
	with Call(x, _) -> x
	| _ -> "mess2"

(* compile AST to java syntax *)
let translate stmt = match stmt
	with Expr(e1) -> "mess"
	| _ -> "deeznuts"

	(* stmt_list contains func --> if func_name is print --> create Java syntax for printing
	 anything fails, reject program *)

(* entry point into compiler *)
let start_compiling stmt_list = 
	let java_string = List.map translate stmt_list in
	let out = "
	import org.json.simple.*;

	public class Test {
		public static void main(String[] args) {
			JSONParser parser = new JSONParser();
		 	JSONArray a = (JSONArray) parser.parse(new FileReader(\"file.json\"));

 		" ^ string_of_int (List.length stmt_list) ^ "

		}
	}
	" in write_to_file out
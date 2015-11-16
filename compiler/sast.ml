(*	AST ---> Semantic AST
	Checking names and types
 *)

open Ast
module StringMap = Map.Make(String)

(* Symbol Table *)
type env = {
	function_index: int StringMap.t;
	var_index: data_type StringMap.t list;
}

open Ast;;

module FunctionMap = Map.Make(String);;
module VariableMap = Map.Make(String);;

exception VarAlreadyDeclared;;
exception VarNotDeclared;;

type func_info  = {
  id : string; 
  return : data_type; 
  args : data_type list;
  arg_names: string list;
}

type symbol_table = {
  func_map: func_info FunctionMap.t;
  var_map: data_type VariableMap.t;
}

let create = 
  {
    func_map = FunctionMap.empty;
    var_map = VariableMap.empty;  
  }

let update f_map v_map = 
  {
    func_map = f_map;
    var_map = v_map;
  }

let string_to_data_type (s : string) = match s
  with "int" -> Int
  | "float" -> Float
  | "bool" -> Bool
  | "string" -> String
  | "array" -> Array(Int)
  | "json" -> Json
  | _ -> raise (Failure "unsupported data type")

let declare_var (id : string) (data_type : string) (env : symbol_table) = 
  if VariableMap.mem id env.var_map then 
    raise VarAlreadyDeclared
  else 
    let update_var_map = VariableMap.add id (string_to_data_type(data_type)) env.var_map in
    update env.func_map update_var_map

let var_type (id : string) (env : symbol_table) =
  if VariableMap.mem id env.var_map then
    VariableMap.find id env.var_map
  else
    raise VarNotDeclared

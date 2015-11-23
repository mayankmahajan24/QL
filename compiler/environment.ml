open Ast;;

module FunctionMap = Map.Make(String);;
module VariableMap = Map.Make(String);;

exception VarAlreadyDeclared;;
exception VarNotDeclared;;
exception FunctionAlreadyDeclared;;

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

let create_func (func_name: string) (ret_type : string) (args : arg_decl list) =
  {
    id = func_name;
    return = (string_to_data_type ret_type);
    args = List.map (fun arg -> string_to_data_type arg.var_type) args;
    arg_names = List.map (fun arg -> arg.var_name) args;
  }

let rec define_func_vars (func_vars : arg_decl list) (env : symbol_table) = match func_vars
  with [] -> env
  | head::body ->
    let new_env = declare_var head.var_name head.var_type env in
    define_func_vars body new_env

let declare_func (func_name : string) (ret_type : string) (args : arg_decl list) (env : symbol_table) =
  if FunctionMap.mem func_name env.func_map then
    raise FunctionAlreadyDeclared
  else
    let update_func_map = FunctionMap.add func_name (create_func func_name ret_type args) env.func_map in
    let new_func_env = update update_func_map env.var_map in
    define_func_vars args new_func_env
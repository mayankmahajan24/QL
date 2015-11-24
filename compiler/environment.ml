open Ast;;

module FunctionMap = Map.Make(String);;
module VariableMap = Map.Make(String);;
module ArrayTypeMap = Map.Make(String);;

exception VarAlreadyDeclared;;
exception VarNotDeclared;;
exception FunctionAlreadyDeclared;;
exception FunctionNotDeclared;;
exception IncorrectFunctionParameterTypes;;
exception MixedTypeArray;;
exception ArrayLiteralTypeMismatch;;

type func_info  = {
  id : string; 
  return : data_type; 
  args : data_type list;
  arg_names: string list;
}

type symbol_table = {
  func_map: func_info FunctionMap.t;
  var_map: data_type VariableMap.t;
  array_type_map: data_type ArrayTypeMap.t;
}

let create = 
  {
    func_map = FunctionMap.empty;
    var_map = VariableMap.empty;
    array_type_map = ArrayTypeMap.empty;
  }

let update f_map v_map a_type_map =
  {
    func_map = f_map;
    var_map = v_map;
    array_type_map = a_type_map;
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
  print_endline "reached";
  if VariableMap.mem id env.var_map then 
    raise VarAlreadyDeclared
  else 
    let update_var_map = VariableMap.add id (string_to_data_type(data_type)) env.var_map in
    update env.func_map update_var_map env.array_type_map

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

let define_array_type (args : data_type list) (env : symbol_table) (id : string) =
  if List.length args != 0 then
    let first_type = List.hd args in
    (* Verify all types are the same *)
    List.iter (fun (data_type) -> if first_type != data_type then raise MixedTypeArray) args;
    let update_array_type_map = ArrayTypeMap.add id first_type env.array_type_map in
    update env.func_map env.var_map update_array_type_map
  else
    let update_array_type_map = ArrayTypeMap.add id Ast.AnyType env.array_type_map in
    update env.func_map env.var_map update_array_type_map

let array_type (id : string) (env : symbol_table) =
  if ArrayTypeMap.mem id env.array_type_map then
    ArrayTypeMap.find id env.array_type_map
  else
    raise VarNotDeclared

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
    update update_func_map env.var_map env.array_type_map

let verify_func_call (func_name: string) (args : data_type list) (env : symbol_table) =
  if FunctionMap.mem func_name env.func_map then
    let declared_func = FunctionMap.find func_name env.func_map in
    let type_pairs = List.combine args declared_func.args in
    List.iter (fun (left, right) -> if left != right then raise IncorrectFunctionParameterTypes) type_pairs;
  else
    raise FunctionNotDeclared

let func_return_type (func_name : string) (env : symbol_table) =
  if FunctionMap.mem func_name env.func_map then
    let declared_func = FunctionMap.find func_name env.func_map in
    declared_func.return
  else
    raise FunctionNotDeclared


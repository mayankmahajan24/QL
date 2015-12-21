# QL Language Reference Manual

### Anshul Gupta (akg2155), Evan Tarrh (ert2123), Gary Lin (gml2153), Matt Piccolella (mjp2220), Mayank Mahajan (mm4399)

##Table of Contents

1. Introduction
2. Lexical conventions
    1. Identifiers
    2. Keywords
    3. Comments
    4. Literals
        1. `int` literals
        2. `float` literals
        3. `bool` literals
        4. `string` literals
3. Data Types
    1. Primitive Types
        1. Integers
        2. Floating Point Numbers
        3. Booleans
        4. Strings
    2. Non-Primitive Types
        1. Arrays
        2. JSONs
4. Expressions
    1. Literals
    2. Identifiers
    3. Bracket Selectors
    4. Binary Operators
        1. Multiplication
        2. Division
        3. Addition
        4. Subtraction
    5. Boolean Expressions
        1. Literal
        2. Identifier
        3. Negation
        4. Equivalency Operators
        5. Logical Operators
    6. Function Calls
5. Statements
    1. Declaring Variables
    2. Updating Variables
    3. Return Statements
    4. Function Declarations
        1. Parameter Declarations
        2. Colon and Return Type
        3. Grammar for Function Declarations
    5. Loop Statements
        1. `where`
        2. `for`
        3. `while`
    6. Conditional Statements
        1. `if/else`
6. Built-In Functions
    1. Length
    2. Print


## 1.0 Introduction
JavaScript Object Notation (JSON) is an open-standard format that uses human-readable format to capture attribute-value pairs. JSON has gained prominence replacing XML encoded-data in browser-server communication, particularly with the explosion of RESTful APIs and AJAX requests that often make use of JSON.

While domain-specific languages like SQL and PostgreSQL work with relational databases, languages like AWK specialize in processing datatables, especially tab-separated files. We noticed a need for a language designed to interact with JSON data, to quickly search through JSON structures and run meaningful queries on the JSON data, all the while using a syntax that aligned much more closely with the actual structure of the data we were using.

## 2.0 Lexical Conventions
### 2.1 Identifiers
Identifiers are combinations of letters and numbers. They must start with a lowercase letter, and can be any combination of lowercase letters, uppercase letters, and numbers. Lowercase letters and uppercase letters are seen as being distinct. Identifiers can refer to three things in our language: variables, functions, and function arguments.
### 2.2 Keywords
The following words are defined as keywords and are reserved for the use of the language; thus, they cannot be used as identifiers to name either a variable, a function, or a function argument:

```
int, float, bool, string, json, array, where, in, as, for, while, return, function, true, false, if, elseif, else, void, not
```
### 2.3 Comments
We reserve the symbol `#~~` to introduce a comment and the symbol `~~#` to close a comment. Comments cannot be nested, and they do not occur within string literals. A comment looks as follows:

```
#~~ This is a comment. ~~#
```

### 2.4 Literals
Our language supports several different types of literals.
#### 2.4.1 `int` literals
A string of numeric digits of arbitrary size that does not contain a decimal point.  Integers can have an optional ‘-’ at the beginning of the string of numbers to indicate a negative number.
#### 2.4.2 `float` literals
QL is following Brian Kernighan and Dennis Ritchie's explanation in *The C Programming Language*: "A floating constant consists of an integer part, a decimal part, a fraction part, an e, and an optionally signed integer exponent. The integer and fraction parts both consist of a sequence of digits. Either the integer part, or the fraction part (not both) may be missing; either the decimal point or the e and the exponent (not both) may be missing." Floats can also contain an optional ‘-’ at the beginning of the float to indicate a negative value.
#### 2.4.3 `bool` literals
Booleans can take on one of two values: `True` or `False`. Booleans in QL are capitalized.
#### 2.4.4 `string` literals
A sequence of ASCII characters surrounded by double quotation marks on both sides.

## 3.0 Data Types
### 3.1 Primitive Types
The primitive types in QL can be statically typed; in other words, the type of a variable is known at compile time. This occurs when the right side of the assignment is a literal of a data type. The primitive types can be declared and then initialized later (their value is null in the interim) or declared and initialized in-line.

#### 3.1.1 Integers (`int`)
Integers are signed, 8-byte literals denoting a number as a sequence of digits e.g. `5`,`6`,`-1`,`0`.

#### 3.1.2 Floating Point Numbers (`float`)
Floats are signed, 8-byte single-precision floating point numbers e.g. `-3.14`, `4e10`, `.1`, `2.`.

#### 3.1.3 Boolean (`bool`)
Booleans are defined by the `True` and `False` keywords. Only boolean types can be used in logical expressions e.g. `True`, `False`.

#### 3.1.4 String (`string`)
Since our language doesn't contain characters, strings are the only way of expressing zero or more characters in the language. Each string is enclosed by two quotation marks e.g. `"e"`, `"Hello, world!"`.

### 3.2 Non-Primitive Types
All non-primitive data types are passed by a reference in memory. They can each be declared and initialized later (their value is null in the interim) or declared and initialized in line.


#### 3.2.1 Arrays (`array`)
Arrays represent multiple instances of one of the primitive data types represented as contiguous memory. Each array must contain only a single type of primitives; for example, we can have either an array of `int`, an array of `float`, an array of `bool`, and an array of `string`, but no combinations of these types. Note that nested arrays are not allowed in QL. The size of the array is fixed at the time of its creation e.g. `array(10)`. Arrays in QL are statically typed since the type of a variable is known at compile time.

#### 3.2.2 JSON (`json`)
Since the language must search and return results from JSON files, it supports JSONs as a non-primitive type. A `json` object can be created directly from a filename of a valid JSON. For example, one could write: `json a = json("file1.json")`. During runtime, the generated java code will check if the contents of the file make up a valid JSON. This means that JSONs are dynamically typed in QL.

JSONs are statically inferred but checked dynamically in QL.

## 4.0 Expressions

Expressions in QL can be one of the following types. A statment in our language can be composed of just an expression but it's much more useful to use them in other statements like if-else constructs, loops and assign statements.

### 4.1 Data Type Literal
Expressions can be just a literal, as defined for our language in Section 2.4 above. This allows us to directly input a value where needed.

e.g in `int a = 5` the 5 on the right hand side of the assignment operator is a Data Type Literal of integer type, used to assign a value to the variable `a`.

### 4.2 Identifier
Expressions can be just an identifier, as defined for our language in Section 2.1 above. This allows us to use variables as values where needed.

e.g in `int b = a` the `a` on the right hand side of the assignment operator is an Identifier of integer type, used to assign a value to the variable `b`.

### 4.3 Bracket Selector

This can be used in two different ways:

- [int `index`]: accesses value at `index` of an array variable
  * Return type is the same as the array’s type.
  * This square bracket notation can be used to assign a value into a variable.
    Example of QL Code:
    ```
    array int a = [1;2;3;4]
    int b = a[2]
    ```

    At the end of this program, b is equal to 3.

- [string `key`]: accesses value at `key` of a JSON variable
  * Return type is inferred from the value in JSON. The type can be one of three things: a value (int, float, bool, string), an array, and a json.
  * QL performs static inferring when a declared variable is assigned to a json variable with bracket selectors. The program will check what the type of the left hand side of the assignment is and infer that the json with bracket selectors will resolve to that type.

    Example of QL Code:
    ```
    json a = json("sample.json")
    int b = a["value"]
    ```

    It is unclear what a["value"] is so our compiler infers that it will be an integer, since the left hand side of the assignment is an `int`. This happens in our static semantic check.


This operator can be nested, e.g.: ["data"]["views"]["total"]. It associates from left to right.  This means that each additional bracket selector will go one level deeper into the JSON by getting the value of corresponding key.

Below is a program containing different examples of the `[]` operator. `file1.json` is the JSON file we will be using in this example.

file1.json:
```
{"data": {
    "views": {
        "total": 80
    },
    "items": {
        "category": "News"
    },
    "users": [
        "Matt",
        "Evan",
        "Gary"
    ]
}
```

bracket-example.ql:
```
json file1 = json("file1.json")

#~~ file1["data"]["views"]["total"] statically inferred as an int ~~#
int total = file1["data"]["views"]["total"]
```

Here is an example of obtaining a JSON object by using a bracket selector on another JSON object.
Say that the json variable b equals this json below.

```
b = {
    "size":10,
    "links": {
        "1": 1,
        "2": 2,
        "3": 3
    }
}

This is the result of using a bracket selector on b.
```

QL then allows for commands like `json links = b["links"]`. The links variable would then look as follows:

```
links = {
    "1" : 1,
    "2" : 2,
    "3" : 3
}
```


### 4.4 Binary Operator
#### 4.4.1 Multiplication: `*`
##### _left associative_
`e1 * e2`

This operation is only valid when both e1 and e2 are integers or floats.
When e1 and e2 are ints, this operator will return an int.
When e1 and e2 are floats, this operator will return a float.

For all other combinations of types, we throw an error (incompatible data types).

Below is an example of the `*` operator:

```
int a = 5 * 6

float b = 1.0 * 10.0
```
The program above will have a equal to 30 and b equal to 10.0.

#### 4.4.2 Division: `/`
##### _left associative_
`e1 / e2`

This operation is only valid when both e1 and e2 are integers or floats.
When e1 and e2 are ints, this operator will return an int.
When e1 and e2 are floats, this operator will return a float.

For all other combinations of types, we throw an error (incompatible data types).

Below is an example of the `/` operator:

```
int a = 10 / 2

float b = 100.0 / 20.0
```
The program above will have a equal to 5 and b equal to 5.0.

#### 4.4.3 Addition: `+`
##### _left associative_
`e1 + e2`

This operation is only valid when both e1 and e2 are integers, floats, or strings.
When e1 and e2 are ints, this operator will return an int.
When e1 and e2 are floats, this operator will return a float.
When e1 and e2 are strings, this operator will return a string.

For all other combinations of types, we throw an error (incompatible data types).

Below is an example of the `+` operator:

```
int a = 1 + 2

float b = 10.1 + 4.1

string c = "hello " + "goat"
```

The program above will have a equal to 3, b equal to 14.2, and c equal to "hello goat".

#### 4.4.4 Subtraction: `-`
##### _left associative_
`e1 - e2`

This operation is only valid when both e1 and e2 are integers or floats.
When e1 and e2 are ints, this operator will return an int.
When e1 and e2 are floats, this operator will return a float.

For all other combinations of types, we throw an error (incompatible data types).

Below is an example of the `-` operator:

```
int a = 10 - 1

float b = 10.0 - 1.9
```

The program above will have a equal to 9 and b equal to 8.1.

### 4.5 Boolean Expressions

Boolean expressions are fundamentally important to the decision constructs used in our language, like the `if-else` block and inside the conditional statements for loops like `while`, `for` and `where`. Each boolean expression must evaluate to `True` or `False`.

#### 4.5.1 Boolean Literal

Boolean expressions can be just a boolean literal, which could be the keyword `True` or `False`.

e.g in `if(True)` the `True` inside the `if` conditional is a Boolean Literal.

#### 4.5.2 Identifier of boolean variable

Expressions can be just an identifier, as defined for our language in Section 2.1 above. This allows us to use variables as values where needed. QL performs static semantic checking to ensure that the identifier used as a Boolean expression has been defined earlier with `bool` type.

e.g in `if(a)` the `a` inside the `if` conditional is a Identifier that must be of bool type.

#### 4.5.3 `not` : negation

- `not bool_expr` evaluates `bool_expr` as a boolean first and then returns the opposite of the `bool_expr` (if `bool_expr` was true, return false; if `bool_expr` was false, return true)

If the `not` operator is used on anything other than a bool, we throw an error.

#### 4.5.4 Equivalency operators

Operators and the types they can be used on
- == : equivalence
    - `string` == `string`
    - `int` == `int`
    - `float` == `float`

- != : non-equivalence
    - `string` == `string`
    - `int` == `int`
    - `float` == `float`

- \> : greater than
    - `int` == `int`
    - `float` == `float`

- < : less than,
    - `int` == `int`
    - `float` == `float`

- \>= : greater than or equal to,
    - `int` == `int`
    - `float` == `float`

- <= : less than or equal to
    - `int` == `int`
    - `float` == `float`

Each of these operators act on two operands, each of an `expr` as defined in Section 4.4 above. It is important to note that neither of the operands of the equivalency operator can acutally be of boolean types themselves. The operator returns a bool.

Our static semantic checker checks at compile time if the operands on either side of the equivalency operators are of the same data type or not. Since QL does not support type casting, in case the data types fail to match, the compiler reports an error.

Examples of this operator:

- `3 == 3`, checks for equality between the two integer literals
- `5.0 != 3`, fails to compile because the two operands are of different data types
- `a == 5 + 4`, evaluates both operands, each an `expr` before applying the equivalency boolan operator. As such, the data type of `a` is obtained from the symbol table and then 5 + 4 is evaluated before checking for equality. In case, `a` is not of type `int` as inferred from the operand that evaluates to 9, the compiler reports an error.
- `a > 5 == 3` fails to work because although the precedence rules evalaute this boolean expression from left to right, `a > 5` returns a type of `bool` which cannot be used in the `==` operators.

#### 4.5.5 Logical operators

- `expr1` & `expr2`: evaluates `expr1` and `expr2` as booleans (throws error if this is not possible), and returns true if they both evaluate to true; otherwise, returns false.
- `expr1` | `expr2`: evaluates `expr1` and `expr2` as booleans (throws error if this is not possible), and returns true if either evaluate to true; otherwise, returns false.

### 4.6 Function Calls
A function-call invokes a previously declared function by matching the unique function name and the list of arguments, as follows:

```
<function_identifier> <LPAREN> <arg1> <COMMA> <arg2> <COMMA> ... <RPAREN>
```

This transfers the control of the program execution to the invoked function and waits for it to return before proceeding with computation. Some examples of possible function calls are:

```
array int a = [4;2;1;3]
int b = length(a)
```

The variable b is now equal to 4.

## 5.0 Statements
### 5.1 Declaring Variables
To declare a variable, a data type must be specified followed by the variable name and an equals sign.  The right side of the equals sign depends on what type of data type has been declared. If it is a primitive data type, then the user has to specify the corresponding literal of that data type.  If the data type is non-primitive, then the user has to enumerate either the array it is assigning into the variable or the JSON constructor with the corresponding JSON file name passed in. In addition, variables can be declared and assigned as another previously declared variable of the same data type.

This is the specific grammar for declaring a variable.

```
<var_decl>:
    | <ARRAY> <array_data_type> <id> <EQUALS> <list_of_literals>
    | <ARRAY> <array_data_type> <id> <EQUALS> <ARRAY> <LPAREN> <int_literal> <RPAREN>
    | <assignment_data_type> <id> <EQUALS> <expr>
<expr>:
    | <literal>
    | <id>
    | ... (other expressions)
```

Examples of the declaration of variables:

```
int i = 0
float f = 1.4 * 5e5
bool b = True
string s = "goats"
array int nums = array(10)
array string strs = ["So","many","features","it's","remarkable"]
```

### 5.2 Updating Variables
To update a variable, the variable on the left side of the equals sign must already by declared.  The right side of the equals sign follows the same rules as section 5.1's explanation of declaring variables.  The only distinction is this time, there does not need to be a data type prior to the variable name on the left hand side of the equals sign.

This is the specific grammar for reassigning a variable.

```
<var_update>:
    | <id> <EQUALS> <expr>
    | <id> <LSQUARE> <int_literal> <RSQUARE> <EQUALS> <expr>
<expr>:
    | <literal>
    | <id>
    | ... (other expressions)
```

Examples of updating variables (assuming these variables were previously declared as the same type):

```
nums[3] = 42
i = 5 * 9
f = -0.01
s = "GOATS"
```

### 5.3 Return statements
The final statement of the body of a function must be a return statement. A function's return statement must correspond to the return type that was specified after the colon in the function declaration.

This is how our grammar handles return statements:

```
<RETURN> <expr>
```

### 5.4 Function Declaration
Function declarations in QL all start with the function keyword, followed by the function identifier, parentheses with parameter declarations inside, a colon, a return type, and brackets with the function body inside.

#### 5.4.1 Parameter declarations
The parameter declarations inside the parentheses are the same as the left hand side of a variable declaration. The variable data type followed by the identifier. These variable declarations are separated by commas.

This is QL's grammar for parameter declarations.

```
<parameter_declaration> :
    | <arg_decl>
    | <parameter_declaration> <COMMA> <arg_decl>
<arg_decl>:
    | <data_type> <id>
```

#### 5.4.2 Colon and Return Type
The colon functions in our language as the specifier of a function return type. Before this colon is an argument list and immediately after this colon comes our function return type, which can be any of the data types previously discussed.

This is how our grammar uses colons:

```
<LPAREN> <parameter_declaration> <RPAREN> <COLON> <return_type>
```

#### 5.4.3 Grammar for Function Declarations

This is QL's grammar for function declarations.

```
<FUNCTION> <id> <LPAREN> <parameter_declaration> <RPAREN> <COLON> <return_type> <LCURLY> <stmt_list> <RCURLY>
```

Here is an example of QL code.

```
function average (float x, float y, float z) : float {
  float a = x + y + z
  return a / 3.0
}
```

### 5.5 Loop statements

The loop statements in QL allow us to iteratively call a block of statements in our code.

#### 5.5.1 `where` loops
The where loop is a key feature of QL that allows the user to search through a JSON array and execute a set of statements for all the JSON array elements (key, value pairs by structure) that match a certain boolean condition. For example, consider the following JSON file opened in QL using the `json temp = json("sample.json")` command:

```
{
  "count" : 5,
  "int_index" : 0,
  "owner" : "Matt",
  "number" : 5.4,
  "friends" : [
    {
      "name" : "Anshul",
      "age" : 12
    },
    {
      "name" : "Evan",
      "age" : 54
    },
    {
      "name" : "Gary",
      "age" : 21
    },
    {
      "name" : "Mayank",
      "age" : 32
    }
  ]
}
```

We can run the where loop on the `temp["friends"]` array, with each element of the array resembling the following structure:

```
{
  "name" : "Anshul",
  "age" : 12
}
```

A where loop must start with the `where` keyword, followed by a boolean condition enclosed in parentheses. This condition will be checked against every element in the JSON. The next element is the `as <identifier>`, which allows the user to associate the current element of the array being processed using the `<identifier>`. Following this is a `{`, which marks the beginning of the body code which is applied to each element for which the condition evaluates to true. A closing `}` signifies the end of the body. After the closing brace, there is a mandatory "in" keyword, which is followed by the JSON array through which the clause will iterate to extract elements.

```
where (<boolean_condition>) as <identifier> {
    #~~ List of statements ~~#
} in <json_array>
```
The scoping rules make the `<identifier>` available to the `<boolean_condition>` and the block statements enclosed in the braces. The `<json_array>` is referenced using the Bracket Selector notation in Section 4.3 above.

For the `sample.json` file opened using the `temp` JSON variable shown above, a where loop to print the names of all friends over the age of 21 would look like this in QL:

```
where (friend["age"] >= 21) as friend {
    string name = friend["name"]
    print(name)
} in temp["friends"]
```

#### 5.5.2 `for` loops
The for loop starts with the `for` keyword, followed by a set of three expressions separated by commas and enclosed by parentheses. The first expression is the initialization, where temporary variables can be initialized. The second expression is the boolean condition; at each iteration through the loop, the boolean condition will be checked. The loop will execute as long as the boolean condition is satisfied, and will exit as soon as the condition evaluates to false. The third expression is the update expression, where variables can be updated at each stage of the loop. Following these three expressions is an open `{` , followed by a list of statements, and then a close `}`.

```
for (<initialization>, <boolean_condition>, <update>) {
    #~~ List of statements ~~#
}
```

The `<initialization>` and the `<update>` are each assignment statements, as defined in section 5.1 and 5.2 above. The `<boolean_condition>` is a boolean expression, as defined in section 4.5 above.

#### 5.5.3 `while` loops
The while loop is initiated by the `while` keyword, followed by a boolean expression enclosed within a set of matching paranthesis. After this, there is a block of statements, enclosed by `{` and `}`, which are executed in succession as long as the the condition represented by the boolean expression is no longer satisfied.

```
while (<boolean_condition>) {
    #~~ List of statements ~~#
}
```

### 5.6 Conditional Statement

Conditional statements are crucial to the program flow and execute a segment of the code based on a boolean expression.

#### 5.6.1 `if/else` clauses
The if-else clause checks the truth of a condition, executing a list of statements if the boolean condition provided is true. Only the `if` statement is required and the `else` statement is optional.

```
if (<boolean_condition>) {
    #~~ List of statements ~~#
} else {
    #~~ List of statements ~~#
}
```

## 6.0 Built-In Functions

Two built-in functions are included with the language for convenience for the user.

### 6.1 `length`

`length(arr)` accepts as its parameter an array, and returns an integer equal to the number of elements in the array.

### 6.2 `print`

We also include a built-in print function to print strings and primitive types.

```
print(<expr>)
```

Here, `<expr>` must evaluate to a primitive type. Attempting to print something that is not a primitive will result in an error.

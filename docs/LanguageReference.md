# QL Language Reference Manual

### Anshul Gupta (akg2155), Evan Tarrh (ert2123), Gary Lin (gml2153), Matt Piccolella (mjp2220), Mayank Mahajan (mm4399)

## 1.0 Introduction
JavaScript Object Notation (JSON) is an open-standard format that uses human-readable format to capture attribute-value pairs. JSON has gained prominence replacing XML encoded-data in browser-server communication, particularly with the explosion of RESTful APIs and AJAX requests that often make use of JSON.

While domain-specific languages like SQL and PostgreSQL work with relational databases, languages like AWK specialize in processing datatables, especially tab-separated files. We noticed a need for a language designed to interact with JSON data, to quickly search through JSON structures and run meaningful queries.

## 2.0 Data Types
### 2.1 Primitive Types
All primitive data types are passed by value. They can each be declared and then initialized later (their value is null in the interim) or declared and initialized in-line.

#### 2.1.1 Integers (`int`)
Integers are signed, 8-byte literals denoting a number as a sequence of digits e.g. `5`,`6`,`-1`,`0`.

#### 2.1.2 Floating Point Numbers (`float`)
Floats are signed, 8-byte single-precision floating point numbers e.g. `-3.14`, `4e10`, `.1`, `2.`.

#### 2.1.3 Boolean (`bool`)
Booleans are defined by the `true` and `false` keywords. Only boolean types can be used in logical expressions e.g. `true`, `false`.

#### 2.1.4 String (`string`)
Since our language doesn't contain characters, strings are the only way of expressing zero or more characters in the language. Each string is enclosed by two quotation marks e.g. `"e"`, `"Hello, world!"`.

### 2.2 Non-Primitive Types
All non-primitive data types are passed by a reference in memory. They can each be declared and initialized later (their value is null in the interim) or declared and initialized in line.


#### 2.2.1 Arrays (`array`)
Arrays represent multiple instances of one of the primitive data types represente as contiguous memory. The square bracket notation is used to create an array and then get direct access to elements. Each array must contain only a single type of primitives; for example, we can have either an array of `int`, an array of `float`, an array of `bool`, and an array of `string`, but no combinations of these types. The size of the array is fixed at the time of its creation e.g. `array(10)`.

#### 2.2.2 JSON (`json`)
Since the language must search and return results from JSON files, it supports Jsons as a non-primitive type. A `json` object can be created through multiple mechanisms. The first is directly from a filename of a valid JSON. For example, one could write: `json a = json("file1.json")`. This will check `file1.json` to ensure it is a valid JSON, and if so, will store the JSON in the variable `a`. The second way to obtain a JSON object is by using a subset of a current JSON. For example, say the following variable is already set:

```
b = {
    "size":10,
    "links": {
        "1": 1,
        "2": 2,
        "3": 3
    }
}   
```

QL then allows for commands like `json links = b["links"]`. The links variable would then look as follows:

```
links = {
    "1" : 1,
    "2" : 2,
    "3" : 3
}
```

## 3.0 Lexical Conventions
### 3.1 Identifiers
Identifiers are combinations of letters and numbers. They must start with a lowercase letter, and can be any combination of lowercase letters, uppercase letters, and numbers. Lowercase letters and uppercase letters are seen as being distinct. We also reject dashes in identifiers. Identifiers can refer to three things in our language: variables, functions, and function arguments.
### 3.2 Keywords
The following words are defined as keywords and are reserved for the use of the language; thus, they cannot be used as identifiers to name either a variable, a function, or a function argument:

```
int, float, bool, string, json, array, where, in, as, for, while, return, function, true, false, if, elseif, else, void, not
```
### 3.3 Comments
We reserve the symbol `#~~` to introduce a comment and the symbol `~~#` to close a comment. Comments cannot be nested, and they do not occur within string literals. A comment looks as follows:

```
#~~ This is a comment. ~~#
```

### 3.4 Literals
Our language supports several different types of literals.
#### 3.4.1 `int` literals
A string of numeric digits of arbitrary size that does not contain a decimal point with an optional ‘-’ to indicate a negative number.
#### 3.4.2 `float` literals
A string of numeric digits of arbitrary size, followed by a single ‘.’ digit character, followed by another string of numeric digits of arbitrary size. It can also contain an optional ‘-’ to indicate a negative number.
#### 3.4.3 `boolean` literals
Booleans can take on one of two values: `true` or `false`. `true` evaluates to an integer value of 1 and `false` evaluates to an integer value of  0. Thus, something like `true == 1` would evaluate to `true`, and something like `if(1)` would be valid.
#### 3.4.4 `string` literals
A sequence of ASCII characters surrounded by double quotation marks on both sides.

## 4.0 Syntax
### 4.1 Program Structure
A QL program consists of a series of statements. There is no concept of a `main` method in our language. The commands are run in order. We can also define functions, which must be defined earlier in the program than they are used. QL is not an object-oriented, so there is no concept of a class or an object. Similar to languages like Python or AWK, the execution of a QL script will simply run the expressions present in our file.
### 4.2 Punctuation
### 4.3 Operators
### 4.4 Declarations
### 4.5 Statements
There are several different kinds of statements in QL, including both basic and compound statements. Basic statements can consist of three different types of expressions, including assignments, math operations, and function calls. Statements are separated by the newline character `\n`, as follows:

```
expression \n
```

The effects of the expression are evaluated prior to the next expression being evaluated. The precedence of operators within the expression goes from highest to lowest. To determine which operator binds tighter than another, check the operator precedence above.
#### 4.5.1 Declaration of Variables
To declare a variable, a data type must be specified followed by the variable name and an equals sign.  After the equal sign, the user has to specify the datatype with the corresponding parameters to be passed into the constructor in parentheses.

```
<data_type> <variable_name> = <data_type>(<parameter>)
<parameter> = <identifier> | <literal>
```

Some examples of the declaration of variables would be:

```
array testArr = array(10)
int i = int(0)
float f = float(1.4e10)
bool b = bool(true)
string s = string("foo")
```

#### 4.5.2 Function Calls
To call a function, the function’s name is used in conjunction with its arguments immediately following in parentheses. If necessary, there is also an assignment to a variable if the function returns a value. Some examples of function calls are:

```
sort(a)
array a = append(a, int(2))
```
#### 4.5.3 Conditional Statements
Our conditional statements behave as conditional statements in other languages do. They check the truth of a condition, executing a list of statements if the boolean condition provided is true. Only the `if` statement is required. We can provide an arbitrary number of `elseif` statements following the `if`, though there can also be none. Finally, we can follow an `if`/combination of `elseif`'s with a single `else`, though there can be only one.

An example conditional statement is as follows:

```
if (__boolean condition__) {
    #~~ List of statements ~~#
} 
elseif (__boolean condition__) {
    #~~ List of statements ~~#
} else {
    #~~ List of statements ~~#
}
```

#### 4.5.4 Return statements
A return statement ends the definition of a function which has a non-void return type. If there is no return statement at the bottom of the function block, it is evidence that there is a `void` return type for the function; if it's not a `void` return type, then we return a compiler error.



## 5.0 Standard Library Functions

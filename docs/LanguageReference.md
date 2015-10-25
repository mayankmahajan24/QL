# QL Language Reference Manual

### Anshul Gupta (akg2155), Evan Tarrh (ert2123), Gary Lin (gml2153), Matt Piccolella (mjp2220), Mayank Mahajan (mm4399)

## 1.0 Introduction
JavaScript Object Notation (JSON) is an open-standard format that uses human-readable format to capture attribute-value pairs. JSON has gained prominence replacing XML encoded-data in browser-server communication, particularly with the explosion of RESTful APIs and AJAX requests that often make use of JSON.

While domain-specific languages like SQL and PostgreSQL work with relational databases, languages like AWK specialize in processing datatables, especially tab-separated files. We noticed a need for a language designed to interact with JSON data, to quickly search through JSON structures and run meaningful queries.

## 2.0 Data Types
### 2.1 Primitive Types
All primitive data types are passed by value. They can each be declared and then initialized later (their value is null in the interim) or declared and initialized in-line.
    - Integers (`int`): Signed, 8-byte literals denoting a number as a sequence of digits e.g. `5`,`6`,`-1`,`0`
    - Floating Point Numbers (`float`): Signed, 8-byte single-precision floating point numbers e.g. `-3.14`, `4e10`, `.1`, `2.`
    - Boolean (`bool`): Defined by the `true` and `false` keywords. Only boolean types can be used in logical expressions e.g. `true`, `false`
    - String (`string`): Since our language doesn't contain characters, strings are the only way of expressing zero or more characters in the language. Each string is enclosed by double quotes e.g. `"e"`, `"Hello, world!"`
### 2.2 Non-Primitive Types
All non-primitive data types are passed by a reference in memory. They can each be declared and initialized later (their value is null in the interim) or declared and initialized in line.
    - Arrays (`array`): Represent multiple instances of one of the primitive data types represente as contiguous memory. The square bracket notation is used to create an array and then get direct access to elements. Each array must The size of the array is fixed at the time of its creation e.g. `[1,2,3]`, `["my", "name"]`, `[true, false, false, true]`
    - JSON (`json`):  Since the language must search and return results from JSON files, it supports Jsons as a non-primitive type. A `json` object can be created through multiple mechanisms. The first is directly from a filename of a valid JSON. For example, one could write: `json a = json("file1.json")`. This will check `file1.json` to ensure it is a valid JSON, and if so, will store the JSON in the variable `a`. The second way to obtain a JSON object is by using a subset of a current JSON. For example, say the following variable is already set:
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



    QL then allows for commands like:

    ```
    json links = b["links"]
    ```

    The `links` variable would then be:

    ```
    links = {
        "1" : 1,
        "2" : 2,
        "3" : 3
    }
    ```

## 3.0 Lexical Conventions
### 3.1 Identifiers
### 3.2 Keywords
### 3.3 Comments
### 3.4 Literals

## 4.0 Syntax
### 4.1 Expressions
### 4.2 Punctuation
### 4.3 Operators
### 4.4 Declarations
### 4.5 Statements


### 5.0 Standard Library Functions

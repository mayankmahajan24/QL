# QL Style Manifesto
_Write QL code._

## Values
When writing QL code, strive for readability, simplicity, and brevity, in that order.

## Hierarchy
Each QL program should follow a strict hierarchy; that is to say, all components of the program should be compartmentalized in the following order:
  1. Program header (Comment explaining program and any required files)
  2. JSON imports
  3. Global variables
  4. Function declarations
  5. Program code (incl. `where` loops)
  6. Mandatory newline

## Indentation
QL doesn’t care about whitespace, apart from newlines. To that end, indentation is only a convention. We recommend indenting whenever a new scope is created, e.g. inside a function or a loop (`where`/`while`/`for`). Closing brackets should align with the indentation level of the line of code that created the scope being closed.

## Empty Lines
There are times where it is appropriate to include an empty line for readability. We recommend an empty line immediately before creation of a new scope (e.g. declaring a function or creating a loop). If the programmer wishes, he can separate “thoughts” of code with newlines, as is common when programming in other languages. **N.B.**: All QL programs must end with an empty line of code.

## Comments
Comments begin with `#~~` and end in `~~#`. Every QL program should begin with a comment explaining the usage of the program and any required files (especially JSON in a certain format). Apart from that, comments should be used sparingly. Never use inline comments (i.e., any line of code should not have a comment on the same line). Only use comments where a programmer who is already familiar with QL needs extra context to understand the code.

## Naming
Functions and variables should make use of lowerCamelCase when named. Names should be verbose, but not overly so (for example, prefer `endLat` over `el` or `endingLatitude`).

## Line Length
QL’s naive parsing of newlines mean that lines of code are occasionally quite long. This is OK.

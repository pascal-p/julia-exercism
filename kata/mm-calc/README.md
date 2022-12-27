# Mad Math Calculator

You have to write a `calc(a,b,operator)` function to receive 2 numbers and 1 operator respectively, assuming a, b, and operator. calc function will calculate a result from a and b as indicated by operator and return as a number.


## Coding Limitation:

The data listed below are not allowed in your code:

 - Operators
    - Mathematical operators: +, -, *, /, %
    - Bitwise operators: <<, >>, ^, ~, !, |, &
    - Other operators: <, >, .
 - Brackets: [, ], {, }
 - Digits/Numbers: 0-9, NaN
 - Quotations: ", ', `` `
 - Loop commands: for, while
 - Additional libraries/constructors: Array, Math, Number, String
 - ~Trolling conditions: global, return, this~
 - ~Note: arrow function is allowed~

The modules/functions below are also disabled:
 - Bypassing functions: ~`require()`~, `eval()`, function constructor
 - JS related
   - ~Time functions: `setTimeout()`, `setInterval()`~
   - ~Modules: fs, vm~

Input:
  - x, y as integer from 0 to 5000
  - operator as string of basic mathematical operator as follow:
    - "+" addition
    - "-" substraction
    - "*" multiplication
    - "/" division
    - "%" modulus
    - "^" power (limited to range of x, y)

Output:
  return a number with maximum 2 decimal places (rounded down), or NaN if a/0 or a%0

## Examples:
 - `calc(1, 2, "+") == 3` should return true
 - `calc(0, 0, "-") == 0` should return true
 - `calc(6, 7, "*") == 42` should return true
 - `calc(5, 4, "%") == 1`  should return true
 - `isNaN(calc(9, 0, "/"))` should return true


## Source

ref. https://www.codewars.com/kata/5a42497e55519ef5c5000015

<hr />
<p><sub><em>Dec 2022, Corto Inc</sub></em></p>

# Calculator

### Compiling the program
```bash
$ flex calc.l
$ bison -vdy calc.y
$ gcc -std=gnu99 util.c y.tab.c -lm -o calculator
```

### Running the program
```bash
$ ./calculator
```
starts the calculator as command line program

## Description
The calculator-language has 2 different datatypes:
- boolean   (true, false)
- number    (1, -2, 3, 0.001, -34.5)

### Assignments:
- variables: 
  - a = true
  - b = -7
  - c = 4.12
- assignments are also expressions, the give back the assigned value:
  - this is valid:  
    - a = (b = (f = 4 * 2 + g = 1) + 4) + 2 
    - g = 1 f = 9 b = 13 a = 15

- constants:
  - #a=5		(a becomes a constant and it's value cannot be changed)
  - b=4			(assigns 4 to the variable b)
  - #b			(b becomes a constant)

### Dynamic Typing:
It's possible to change type of variables as it is needed:
- a = 23.3        	assigned as a number
- a = false       	becomes a boolean
- a = 22          	becomes an number

supported operations/operators:
- `+ - * / % ^ ( ) == != < > >= >= ! && ||`

### Functions
There are several built in functions, they can be called with the `::` operator:
- sqrt::2             => 1.414214
- sqrt::sqrt::2       => 1.189207

supported functions:
- `sqrt, tan, sin, cos, ln, log2, log10, fac`

### Operators
Comparison (`<, <=, ==, !=, >, >=`) and boolean operations (`&& or &, || or |, !`) are evaluated to a boolen
-  4 < 5 		=> true
-  5 == 5.00		=> true
-  false && true	=> false
-  false || true	=> true

### Predefined Constants
There are four predefined constants: pi, e, golden ratio (f), gravity acceleration (g).

## Sample Input & Output

```
Calculator 🔢
by Kristian Schwienbacher

registered constants: pi, e, f (golden ratio), g (gravity acceleration)
registered functions: sqrt, tan, sin, cos, ln, log2, log10, fac

Type simple expressions - exit to quit the program

a = 4
=> 4

sqrt::a
=> 2

#b = 5
=> 5

b = 4
[ERROR => cannot modify a constant]

fac::7
=> 5040

exit
```
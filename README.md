# Arithmetic Operators

The library contains verilog modules for parametric floating- and fixed-point operators.

# Properties of Fixed-point operators:
* Customizable integer length and fraction length
* Unsigned
* In case of overflow: Sets all output bits to 1
* In case of Underflow: Sets all output bits to 0
* Combinational block/ Not clocked/ Not pipelined

# Properties of Floating-point operators:
* Customizable exponent length and mantissa length
* Unsigned
* Supports only normalized floating numbers 
* Overflow and Underflow handling: Sets output to highest and lowest possible values respectively
* Combinational block/ Not clocked/ Not pipelined
* No sign bit as only unsigned numbers are supported




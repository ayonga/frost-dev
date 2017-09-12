---
title: Utility Functions for Symbolic Math Toolbox
tags: [symbolic, utility]
keywords: Symbolic Math Toolbox Mathematica Mathlink eval_math eval_math_fun 
summary: A tutorial about the utility functions of FROST symbolic math toolbox 
author: Ayonga Hereid
---

{% include callout.html content="A complete list of symbolic utility function
can be
found
[here](http://localhost:4000/pages/html/dir_70fcf45972686018cf73f211242311ab.html)."
type="warning"%}

## Evaluate Mathematica Expression ##

The original Ben's toolbox has only one function `math` for communicating
between Matlab and Mathematica. The function, however, does not handle errors
during the evaluation and requires to write the complete Mathematica expression
in the original format. So I wrote two wrapper functions `eval_math` and
`eval_math_fun` in FROST to extend this function.

### eval_math ###

This function has the exact same functionality and syntax as the original `math`
function, except it stops if an error is detected during the Mathematica
evaluation. This function has three different operating modes:

+ Send Mathematica commands directly, and print out the results. In this case,
  only one input argument is required. For example:

``` matlab
>> eval_math('N[EulerGamma]') % the input must be a string of valid Mathematica expression

ans =

0.5772156649015329
```
+ Assign Mathematica numerical results to a Matlab variable. It requires two
  input arguments: the first one is the string of Mathematica expression, and
  the second argument is the specific flag: `math2matlab`. For example:

``` matlab
>> hilbert=eval_math('Inverse[hilbert]', 'math2matlab')

hilbert =

    9.0000  -36.0000   30.0000
  -36.0000  192.0000 -180.0000
   30.0000 -180.0000  180.0000
```

+ Assign Matlab numerical data to a Mathematica symbolic variable. Three input
  arguments are required: the first argument is the name of the symbolic
  variable (in Mathematica), the second one must be the flag `matlab2math`, and
  the last argument is the numerical data to given. For example:

``` matlab
>> eval_math('hilbert','matlab2math', hilb(3))

ans =

hilbert

>> eval_math('hilbert')

ans =
{% raw %}
{{1., 0.5, 0.333333}, {0.5, 0.333333, 0.25}, {0.333333, 0.25, 0.2}}
{% endraw %}
```



Specifically, to quit the Mathematica kernal, run:

``` matlab
>> eval_math('quit')
Mathematica Kernel quitting per your request...
```

### eval_math_fun ###

This function can be used to call a specific Mathematica function block with
input arguments and options. Unlike `eval_math`, you do not need to write down
the whole Mathematica expression and the input argument can be native Matlab
data types (numerical, char/string, struct, cell, etc.) The return value is a
`SymExpression` object that stores the evaluated Mathematica expression. The basic syntax of this function is:

``` matlab
eval_math_fun('SomeMathFunc',{input1,input2,..,inputN},options);
```

where `options` is a Matlab struct data specifies the options of the Mathematica
function that has
specific
[options pattern](http://reference.wolfram.com/language/ref/OptionsPattern.html). 

For example:

``` matlab
>> eval_math_fun('RandomReal',{10}) % == eval_math('RandomReal[10]')

ans =
5.703973525491923

>> eval_math_fun('Plus',{2,2})      % == eval_math('2+2')

ans =

4
```


## Data Conversion ##

These functions convert a specific Matlab variable to a character string
represents a valid Mathematica expression.

{{site.data.alerts.note}} The return value of these functions is not a symbolic
expression, rather a character vector in Matlab. To get the symbolic expression,
you can use 'eval_math' function with the return character vector as the input
argument.  {{site.data.alerts.end}}


### str2mathstr ###

It converts a matlab character vector into a character vector of valid
Mathematica expression. For example:

``` matlab
>> str2mathstr('hello world')

ans =

"hello world"
```

If you want to preserve the original form, call the function with
`ConvertString` option being false. For example:

``` matlab
>> str2mathstr('hello world','ConvertString',false)

ans =

hello world
```

### num2mathstr ###

It converts a numerical scalar number into a character vector of valid numerical number in Mathematica. This function is particularly designed to address `inf` and integer numbers.

For example:

``` matlab
>> num2mathstr(inf)

ans =

Infinity

>> num2mathstr(23)

ans =

23

>> num2mathstr(23.023)

ans =

23.023000
```

### mat2math ###

It converts a 2-D numerical matrix into a valid representation of Mathematica matrix. 

For example:

``` matlab
>> mat2math(hilb(3))

ans =
{%raw%}
{{1, 0.500000, 0.333333},{0.500000, 0.333333, 0.250000},{0.333333, 0.250000, 0.200000}}
{%endraw%}
```


### cell2tensor ###

It converts a cell array to valid representation of tensor array in Mathematica. 



For example:

``` matlab
>> cell2tensor({'hello',hilb(3),inf})

ans =
{%raw%}
{"hello", {{1, 0.500000, 0.333333},{0.500000, 0.333333, 0.250000},{0.333333, 0.250000, 0.200000}}, Infinity}
{%endraw%}
```

{% include note.html content="This function recursively converts the contents of
each cell based on the original data type." %}

### struct2assoc ###

It converts a Matlab struct data to a association data representation in Mathematica.

``` matlab
>> b
b = 

  struct with fields:

      text: 'hello world'
    matrix: [3×3 double]
       num: -Inf

>> struct2assoc(b)

ans =

{%raw%}
<| "text"->"hello world", "matrix"->{{1, 0.500000, 0.333333},{0.500000, 0.333333, 0.250000},{0.333333, 0.250000, 0.200000}}, "num"->Infinity |>
{%endraw%}
```

{% include note.html content="This function recursively converts the contents of
each cell based on the original data type." %}

### general2math ###


This function is a wrapper for the other conversion functions. It detects the
data type of the input arguments, and call the appropriate conversion function.

For example:

``` matlab
>> general2math(b)

ans =

{%raw%}
<| "text"->"hello world", "matrix"->{{1, 0.500000, 0.333333},{0.500000, 0.333333, 0.250000},{0.333333, 0.250000, 0.200000}}, "num"->Infinity |>
{%endraw%}

>> general2math({'hello',hilb(3),inf})

ans =
{%raw%}
{"hello", {{1, 0.500000, 0.333333},{0.500000, 0.333333, 0.250000},{0.333333, 0.250000, 0.200000}}, Infinity}
{%endraw%}
```

{% include note.html content="This function recursively converts the contents of
each cell based on the original data type." %}















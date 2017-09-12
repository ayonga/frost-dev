---
title: Symbolic Expression Syntax
tags: [symbolic]
keywords: SymExpression
summary: The basic syntax of SymExpression object
author: Ayonga Hereid
---


{% include callout.html content="Similar to the `sym` class in Matlab, all
symbolic expression in FROST is an object of `SymExpression` class. A
`SymExpression` object can be created explicitly, or can be obtained from any
symbolic calculation." type="default"%}


## Create Symbolic Expression Explicitly ##

You can create a `SymExpression` object by explicitly calling the class
constructor function. The input argument can be one of the following data types:

+ numeric: create a numeric symbolic expression object, e.g., 1, 3.1415

``` matlab
>> SymExpression(pi)

ans =

3.141593

>> SymExpression(hilb(3))

ans =
{% raw %}
{{1, 0.5, 0.333333}, {0.5, 0.333333, 0.25}, {0.333333, 0.25, 0.2}}
{% endraw %}
```

+ char: create a single symbolic expression specified by the text, e.g., Cos[x]

``` matlab
>> SymExpression('Cos[x]')

ans =

Cos[x]
```

{{site.data.alerts.note}}
The input text must be a valid Mathematica expression. For example, it should be <code>Cos[x]</code>, not <code>cos(x)</code>.
{{site.data.alerts.end}}

+ cell: create a tensor array in Mathematica specified by the input cell.

``` matlab
>> SymExpression({1,hilb(3),'Cos[x]'})

ans =
{% raw %}
{1, {{1, 0.5, 0.333333}, {0.5, 0.333333, 0.25}, {0.333333, 0.25, 0.2}}, Cos[x]}
{% endraw %}
```

+ struct: create a association in Mathematica specified by the input struct.

``` matlab
>> b = 

  struct with fields:

      text: 'hello world'
    matrix: [3×3 double]
       num: -Inf

>> SymExpression(b)

ans =
{% raw %}
<|"text" -> "hello world", "matrix" -> {{1, 0.5, 0.333333}, {0.5, 0.333333, 0.25}, {0.333333, 0.25, 0.2}}, "num" -> Infinity|>
{% endraw %}
```

+ SymExpression: generated a copy of the given SymExpression.

``` matlab

>> b_vec = SymExpression(a_vec)

ans =
{% raw %}
{{var$1$1}, {var$2$1}, {var$3$1}}
{% endraw %}
```

### Create with `DelayedSet` Option  ###

A `SymExpression` object can also be created with `DelayedSet` option. If this option is enabled, it will use the `SetDelayed` operation in Mathematica. For more information, see [here](http://reference.wolfram.com/language/ref/SetDelayed.html ).

To use this option, call the constructor function with additional option argument, e.g.,

``` matlab
>> a = SymExpression('RandomReal[10]','DelayedSet',true);
```

Unlike `Set`, `SetDelayed` will only store the expression without evaluating the expression. For example, in the above example, the variable is assigned to be a random number. When you using `SetDelayed`, the expression `RandomReal[10]` will be evaluated every time you access the variable. So the actual value of `a` will change very time.

``` matlab
>> a

ans =

2.604258849577189

>> a

ans =

1.9781292304644342
```

However, if you use `Set`, the the expression `RandomReal[10]` will be evaluated once at the time of assigning. So the value of `a` stays the same.

``` matlab
>> a = SymExpression('RandomReal[10]')

ans =

4.085516205158337

>> a

ans =

4.085516205158337
```



## Manipulating Symbolic Expression ##

Once a `SymExpression` object is created, you can perform many mathematical
calculation on the object, just like normal Matlab data types. 

### Basic Arithmetic Computation ###

`SymExpression` class overwrote the basic arithmetic operators, such as +, -, *, /, inv, transpose, etc.

``` matlab
>> a = SymVariable('a');
b = SymVariable('b');
c = a+b

ans =

a + b

>> d = b*c

ans =

b*(a + b)

>> e = d.^2

ans =

b^2*(a + b)^2
```

### Math Functions ###

You can also perform many math functions on the `SymExpression` objects. The return value is still a `SymExpression` object.

``` matlab
>> cos(e)

ans =

Cos[b^2*(a + b)^2]
```

For a complete list of available math functions, see [here](http://localhost:4000/pages/html/classSymExpression.html).

### Data Conversion ###

The return value of any symbolic calculation is always a `SymExpression` object. Sometimes, you may want to convert it to other data type, such as `double` or `char`.

#### Convert to Numeric Value ####

``` matlab
>> a = SymExpression('Cos[Pi]')

ans =

-1

>> b = double(a)

b =

    -1
```

Here, **a** is a `SymExpression` object but **b** is a `numeric` data.

#### Convert to Text ####

You can also convert the symbolic expression into text, which will print out the Mathematica symbolic expression in Matlab `char` data.

``` matlab
>> char(cos(e)) % e is from previous example

ans =

Cos[b^2*(a + b)^2]
```

The output here is a `char` data, not `SymExpression` object.


### Concatenate  ###

Two or more symbolic expressions can be concatenated (vertical or horizontal)
into an array of symbolic expression.

``` matlab
>> [c,d] % c,d are from the previous example

ans =
{% raw %}
{{a + b, b*(a + b)}}
{% endraw %}

>> [c;d]

ans =
{% raw %}
{{a + b}, {b*(a + b)}}
{% endraw %}

``` 

You can also call `horzcat` or `vertcat` function explicitly, e.g.,

``` matlab

>> horzcat(c,d)

ans =

{% raw %}
{{a + b, b*(a + b)}}
{% endraw %}
>> vertcat(c,d)

ans =
{% raw %}
{{a + b}, {b*(a + b)}}
{% endraw %}
```

### Subscripted Reference and Assign ###

You can reference or assign sub-element of an array using subscripted indices.

``` matlab
>> vec = [c;d] % c,d are from the previous example
>> vec(2)

ans =

{b*(a + b)}
```

``` matlab
>> vec(2) = 3

ans =

{% raw %}
{{a + b}, {3}}
{% endraw %}
```

### Find Symbolic Variables in an Expression ###

Sometimes it is useful to find all symbolic variables in a complicated expression. For this purpose, you can use `symvar` function:

``` matlab
>> tomatrix(e)*b_vec % tomatrix converts a scalar or 1-D array to a 2-D matrix

ans =
{% raw %}
{{b^2*(a + b)^2*var$1$1}, {b^2*(a + b)^2*var$2$1}, {b^2*(a + b)^2*var$3$1}}
{% endraw %}
>> symvar(ans)

ans =
{% raw %}
{{b, a, var$1$1, var$2$1, var$3$1}}
{% endraw %}
```

### Substitute Symbolic Variables in an Expression ###

You can also substitute a particular symbolic variable in an expression to something else, such as another variable, a complex expression or a numeric data. This can be done using function `subs`. The following example replace `a` and `b` with numeric value `1` and `2` in the previous example:

``` matlab
>> expr = tomatrix(e)*b_vec;
>> subs(expr, {SymVariable('a'),SymVariable('b')}, {1,2})

ans =

{% raw %}
{{36*var$1$1}, {36*var$2$1}, {36*var$3$1}}
{% endraw %}
```

Here, the first argument is the original expression, the second argument is the list of symbolic variable to be replaced, and the last argument is the new value. 

The symbolic variable can be also an array, e.g.,

``` matlab
>> subs(expr, b_vec, [1,2,3])

ans =
{% raw %}
{{b^2*(a + b)^2}, {2*b^2*(a + b)^2}, {3*b^2*(a + b)^2}}
{% endraw %}
```



















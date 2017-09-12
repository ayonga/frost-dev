---
title: Symbolic Variables
tags: [symbolic]
keywords: SymVariable 
summary: SymVariable is a special type of symbolic expression object for symbolic variables
author: Ayonga Hereid
---


{% include callout.html content="To manipulate a symbolic mathematical
expression, you would need to define the symbolic variables first. If using the
native Matlab symbolic math toolbox, you can create a symbolic variable by
calling <code>sym('var')</code> (scalar) or <code>sym('var',[2,3])</code>
(array). 

FROST uses the similar syntax to create a symbolic variable."
type="default"%}

## Overview ##

[SymVariable](http://localhost:4000/pages/html/classSymVariable.html) is an
inherited subclass
of [SymExpression](http://localhost:4000/pages/html/classSymExpression.html),
hence it can be used as any regular symbolic expression in the code. When a
`SymVariable` object is created, it will be associated with one or a group of
symbolic variables in Mathematica. You can:

+ create a scalar, 1-D or 2-D array variable
+ reference sub-elements using indices
+ assign special text labels for each elements and reference using labels

## Create SymVariable objects ##

+ Create a scalar variable

``` matlab
>> a = SymVariable('var'); % a is the matlab object that represents a symbolic variable 'var' in Mathematica


ans =

var
```

+ Create a 1-D array variables:

``` matlab
>> a_vec = SymVariable('var',3)

ans =

{var$1, var$2, var$3}
```

+ Create a 2-D array variables:

``` matlab
>> a_mat = SymVariable('var',[2,3])

ans =
{%raw%}
{{var$1$1, var$1$2, var$1$3}, {var$2$1, var$2$2, var$2$3}}
{%endraw%}
```

{{site.data.alerts.note}} The underscore symbol <code>_</code> is considered as
a special character in Mathematica, hence we use the dollar sign <code>$</code>
to isolate indices in different dimensions.  {{site.data.alerts.end}}

## Use SymVariable objects ##

Once a `SymVariable` object is created, you can use it as regular data to
perform symbolic math calculation. For example:

``` matlab
>> b = cos(a)

ans =

Cos[var]
```

``` matlab
>> b + a

ans =

var + Cos[var]
```

``` matlab
>> b_vec = cos(a_vec)

ans =

{Cos[var$1], Cos[var$2], Cos[var$3]}
```

``` matlab
>> b_mat = cos(a_mat)

ans =
{% raw %}
{{Cos[var$1$1], Cos[var$1$2], Cos[var$1$3]}, {Cos[var$2$1], Cos[var$2$2], Cos[var$2$3]}}
{% endraw %}
```

{{site.data.alerts.note}} Any resulting variable from a symbolic calculation is
a <code>SymExpression</code> object. <code>b</code>, <code>b_vec</code>,
<code>b_mat</code> are all <code>SymExpression</code> objects not
<code>SymVariable</code> objects. {{site.data.alerts.end}}

## Reference by index ##

You can access a sub-entries of an array of `SymVariable` using their indices
similar to other Matlab variables. For example:

``` matlab
>> a2 = a_vec(2)

ans =

{var$2}
```

``` matlab
>> a_1_3 = a_vec([1,3])

ans =

{var$1, var$3}
```

``` matlab
>> a2_1_3 = a_mat(2,[1,3])

ans =

{% raw %}
{{var$2$1, var$2$3}}
{% endraw %}
```

{{site.data.alerts.warning}}
The returned sub-entries are given as <code>SymExpression</code> objects. 
{{site.data.alerts.end}}

## Reference by label ##

Labels can be assigned to each entry of a 2-D array of `SymVariable` object at initialization.

``` matlab
>> a_vec = SymVariable('var',[3,1],{'alpha','beta','gamma'})

ans =

{% raw %}
{{var$1$1}, {var$2$1}, {var$3$1}}
{% endraw %}
```

If labels are assigned, then it can be used to reference the individual element in the array. For example:

``` matlab
>> alpha = a_vec('alpha')

ans =

{var$1$1}
```




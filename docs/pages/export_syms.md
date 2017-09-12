---
title: Exporing Symbolic Expressions to C++ 
tags: [symbolic]
keywords: SymExpression export C++ MEX
summary: Exporting symbolic expressions to C++ source code and compile as MEX binaries
author: Ayonga Hereid
---

## Introduction ##



Although you can substitute symbolic variables with numerical values to get a
particular numerical result from a symbolic expression, the process of doing
substitution is slow and inefficient. The best way to use these symbolic
expressions in the Matlab's numerical calculation is exporting them as C++
source code and compile them as MEX binaries (or use it on other C++ projects
directly).


When exporting to C++ code, the original expression will be first optimized
using
[Common Subexpression Elimination (CSE)](https://en.wikipedia.org/wiki/Common_subexpression_elimination) techniques, and then export to C++ files based on the given template. 

{{site.data.alerts.tip}} It is recommended NOT to use <code>Simplify</code>
method for Mathematica expressions, as the process would take very long time
potentially. The CSE optimization requires less time and provides almost the
same optimal solution at the end. {{site.data.alerts.end}}

There are two ways to export a `SymExpression` object: 
+ using `export` method of `SymExpression` class directly;
+ create a wrapper `SymFunction` object first and then use `export` method of `SymFunction` class. 

The first one is straightforward, but needs to provide many information at
exporting. The second approach stores some information at initiating the
`SymFunction` object, hence, less information is needed at exporting.

{{site.data.alerts.tip}} I recommend to use the second approach whenever
possible. The `SymFunction` class can be used as an extension of `SymExpression`
with additional information, and it can be exported whenever needed without
explicitly providing these information.  {{site.data.alerts.end}}

## Using `export` Method ##

The basic syntax of exporting would looks like this:

``` matlab
export(expr,'Param1','Value1',...);
```
where `Param1` and `Value1` is a pair of parameter-value (as of graphic commands in Matlab):

The following two parameters must be provided:

+ **Vars** : the list of symbolic variables.
+ **File** : the full path of the file to be exported to

{{site.data.alerts.note}} <code>Vars</code> should be a cell array of
`SymVariable` objects that cover all symbolic variables present in the
expression. Otherwise the exported code will result in undefined variables.
{{site.data.alerts.end}}

{{site.data.alerts.note}} <code>File</code> should be the full path of the file
name. If only the file name is given, it will be exported to the current folder.
{{site.data.alerts.end}}

``` matlab
>> a = SymVariable('a'); 
>> b = SymVariable('b');
>> b_vec = SymVaraible('var',[3,1]);
>> expr = tomatrix((b*(a+b)).^2) * b_vec;
>> export(expr,'Vars',{a,b,b_vec},'File','test'); % expr is from the previous example
Compiling: test.cc	Elapsed time is 0.321564 seconds.
``` 

To use the exported function, the order and dimensions of input arguments must
match the order in `Vars`.

``` matlab
>> test(1,2,[3,4,5])

ans =

   108
   144
   180
```

There are some optional parameters for different type of operations:

+ **ForceExport**: If `false` and the same file already exists, then the export
  process will be skipped with warning. However, if this option set to be
  `true`, then it will be exported regardless of the previous status. _Default_:
  `false`
+ **BuildMex**: If `true`, the exported C++ source code will be compiled as MEX
  binary so that can be used directly in Matlab. _Default_: `true`
+ **Namespace**: The exported function can be defined as a specific
  Namespace. _Default_: `SymExpression`
+ **TemplateFile**: The template file for the C++ source code. If empty, then
  use the default template file comes with FROST. _Default_: `[]`
+ **TemplateHeader**: The template file for the C++ header file. If empty, then
  use the default template file comes with FROST. _Default_: `[]`

## Use `SymFunction` Wrapper Class ##


### Creating `SymFunction` Objects ###



The main advantage of using `SymFunction` is to store the required information
(Namely, `Vars` and `File`) as initialization. In addition, you can compute the
first and second order partial derivatives (Jacobian and Hessian) with respect
to the dependent variables. In particular, the `SymFunction` separate dependent
symbolic variables in two main catagories: variables and parameters. The
automatic partial derivatives will be only computed with respect to variables;
parameters will be considered constants.

To initialize a `SymFunction` object, run:

``` matlab
>> func = SymFunction('test', expr, {b_vec}, {a,b});
```

Here, the function name of the symbolic expression `expr` is `'test'`, the
dependent variable is `b_vec` and parameters are `a` and `b`.

### Exporting `SymFunction` Objects ###

Exporting a `SymFunction` object is much easier:

``` matlab
>> export(func, export_path); % export_path is some path to be exported
```

{{site.data.alerts.note}}
If no export path is specified, it will be exported to the current folder.
{{site.data.alerts.end}}

To call the exported function (MEX) in Matlab, the orders and dimensions of
input arguments should matches the orders and dimensions of variables and
parameters (variables first), e.g.,

``` matlab
>> test([3,4,5],1,2)

ans =

   108
   144
   180
```

{{site.data.alerts.tip}} All additional options for the `SymExpression` can be
used as the same for the `SymFunction` class.  {{site.data.alerts.end}}

{{site.data.alerts.note}} All `SymFunction` objects are also `SymExpression`
objects, so it can be used as regular symbolic expressions.
{{site.data.alerts.end}}

``` matlab
>> sqrt(func)

ans =
{% raw %}
{{Sqrt[b^2*(a + b)^2*var$1$1]}, {Sqrt[b^2*(a + b)^2*var$2$1]}, {Sqrt[b^2*(a + b)^2*var$3$1]}}
{% endraw %}
```



### Exporting Jacobian and Hessian of Symbolic Expression ###


With `SymFunction`, users can directly export the first order partial
derivatives (Jacobian) and the second order partial derivatives (Hessian) of the
symbolic expression using `exportJacobian` and `exportHessian` methods. 

{{site.data.alerts.note}} The partial derivatives are performed only with
respect to variables, considering parameters are constant.
{{site.data.alerts.end}}

{{site.data.alerts.note}} If the symbolic expression is non-scalar or 1-D array,
it will be first flatten the expression to 1-D array.  {{site.data.alerts.end}}

{{site.data.alerts.important}}
These two functions will only export the sparse Jacobian/Hessian matrices. 
{{site.data.alerts.end}}

#### Exporting Jacobian ####

When exporting the Jacobian matrix, the method export two functions: one with
prefix "J_" and another with prefix "Js_". For example:

``` matlab
>> exportJacobian(func,pwd); % pwd is the current directory
Compiling: J_test.cc	Elapsed time is 0.239276 seconds.
Compiling: Js_test.cc	Elapsed time is 0.205092 seconds.
```

Where "Js_test" returns the indices of non-zero entries of the sparse Jacobian
matrix, and "J_test" returns the values of non-zero entries. To construct the actual Jacobian matrix:

``` matlab
>> idx = Js_test(0);
>> val = J_test([1,2,3],1,2);
>> jac_sparse = sparse(idx(:,1),idx(:,2),val);
>> jac_full = full(jac_sparse)

jac_full =

    36     0     0
     0    36     0
     0     0    36
```




#### Exporting Hessian ####

{{site.data.alerts.note}} The exported function returns the weighted summation
of each Hessian matrix with respected to each dependent variables. This hessian
matrix is only useful for NLP solvers to compute the second order derivatives.
{{site.data.alerts.end}}


When exporting the Hessian matrix, the method export two functions: one with
prefix "H_" and another with prefix "Hs_". 

``` matlab
>> exportHessian(func,pwd);
Compiling: H_test.cc	Elapsed time is 0.211086 seconds.
Compiling: Hs_test.cc	Elapsed time is 0.201248 seconds.
```

Similarly, "Hs_test" returns the indices of non-zero entries of the sparse Hessian
matrix, and "H_test" returns the values of non-zero entries.

To call "H_test", the last argument must be the weights `lambda`, e.g.,

``` matlab
idx = Hs_test(0);
val = H_test([1,2,3],1,2,[1,10,100]);
```



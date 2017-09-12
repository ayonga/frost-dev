---
title: Symbolic Math Toolbox Overview
tags: [symbolic]
keywords: Symbolic Math Toolbox Mathematica Mathlink
summary: An overview about the FROST's custom symbolic math toolbox
---

## Overview ##

Compared to MATLAB's
native
[Symbolic Math Toolbox](https://www.mathworks.com/help/symbolic/index.html),
[Wolfram Mathematica](https://www.wolfram.com/mathematica/) provides more
powerful symbolic math engine in terms of speed and performance. But, using
Mathematica directly from its graphic front-end interface is always a
challenging task for many users due to its special syntax and code structure.




Therefore, FROST provides a custom symbolic math toolbox for MATLAB that uses
the Mathematica Kernel as backend engine via Mathlink. FROST's symbolic math
toolbox has the following main features:

+ using similar syntax as MATLAB's native symbolic math toolbox
+ exporting the symbolic expression to C++/Matlab code
+ calling any Mathematica function from MATLAB directly

{{site.data.alerts.important}}
To use FROST's custom symbolic math toolbox, the user must have Wolfram
Mathematica 10.4 or newer version installed. 
{{site.data.alerts.end}}





## Dependencies ##

FROST's symbolic toolbox is based
on
[Ben Barrowes's](https://www.mathworks.com/matlabcentral/profile/authors/255424-ben-barrowes) open
source
project:
[Mathematica Symbolic Toolbox for MATLAB--Version 2.0](opeoehttps://www.mathworks.com/matlabcentral/fileexchange/6044-mathematica-symbolic-toolbox-for-matlab-version-2-0/). A
slightly modified version of the source code and pre-compiled binaries for Linux
and Windows machine are included with FROST (`third/mathlink/`). Alternatively,
you could also download the original source code and pre-compiled mex binaries
from Mathworks File Exchange server or Matlab's Addons manager. For more
information, please refer to the project
page
[here](opeoehttps://www.mathworks.com/matlabcentral/fileexchange/6044-mathematica-symbolic-toolbox-for-matlab-version-2-0/).

{% include note.html content="To use this toolbox, you must include the
directory of the mex binary, e.g., third/mathlink/, to your Matlab path. See
`frost_addpath()` in the root directory." %}






## Toolbox Structure ##

FROST extends Ben's symbolic toolbox to a more complete Matlab toolbox that can
be used almost like the native symbolic math toolbox. Our toolbox consists of
three Matlab **classes** defining custom data types and a few **utility** functions for convenient operations.  


### Symbolic Class Types ###


<!--
[functions](http://localhost:4000/pages/html/dir_70fcf45972686018cf73f211242311ab.html).
[classes](/pages/html/dir_fdba3f3ea5e8721cddb66cf833126086.html) -->


+ **SymExpression**: This basic class defines any symbolic Mathematica
  expression in Matlab (analogous
  to [sym](https://www.mathworks.com/help/symbolic/sym.html) in Matlab)

+ **SymVariable**: Inherited from `SymExpression`, this class defines one or a
  group of symbolic variables with a special syntax (analogous
  to [symvar](https://www.mathworks.com/help/matlab/ref/symvar.html)

+ **SymFunction**: This class works as a wrapper of a `SymExpression` object,
  storing some additional information regarding the `SymExpression` object that
  are mostly useful for exporting to C++ source code.
  
{{site.data.alerts.tip}} An object of SymVariable or SymFunction classes can be
used as any regular SymExpression object inside the mathematical operation.
{{site.data.alerts.end}}



{% include image.html file="/images/classSymExpressionInheritGraph.svg"
caption="Class Hierarchy of Symbolic Math Toolbox" max-width="600" %}


### Symbolic Utility Functions ###

In addition to these three classes, FROST also contains several utility
functions for communication with Mathematica Kernal and converting native Matlab
variables to an equivalent Mathematica expression. Please
read [this tutorial](/pages/symbolic_utility.html) for more detail.
























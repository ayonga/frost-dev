---
title: Installation
sidebar: home_sidebar
---


## Getting Started ##

FROST is a collection of MATLAB functions and Mathematica packages. Hence, there
is no need to build the source code. However, the Mathematica package will
export project-specific symbolic expressions to C++ source code which needs to
be compiled as *.MEX files for MATLAB. This requires a proper MATLAB MEX
compiler for C++ before using FROST.

## Prerequisites ##

FROST uses [MATLAB](https://www.mathworks.com/) as the frontend interface, and
uses [Wolfram Mathematica](https://www.wolfram.com/mathematica/>) as the backend
symbolic computation engine. To use FROST, we require the following software to
be installed apriori.

- **MATLAB R2015b or later**
- **Mathematica 10.0 or later**

{% include note.html content="FROST uses certain functions that are not supported
by older versions of MATLAB and Mathematica." %}

## Download FROST ##

FROST is an open-source toolbox hosted on GitHub. To download the source code,
run

``` shell
$ git clone https://github.com/ayonga/frost-dev.git frost-dev
```

Alternatively, you could download the archived **zip** file directly from
this [link](https://github.com/ayonga/frost-dev/archive/master.zip).



## System Configuration ##






### Setup Default MEX Compiler ###

The following instruction provides an example setup for the default mex
compilers on different platforms. For more information, please refer to the
official document
on
[www.mathworks.com](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html).

#### Linux ####

Setting up MEX compiler for Linux systems (tested on Ubuntu 14.04/16.04 LTS) is
relatively straight-fowrad. However, the default ``g++`` compiler might not be
supported by MATLAB, which sometimes causes unnecessary errors (e.g., g++5.4 is
case sensitive). Please visit [https://www.mathworks.com/support/compilers.html]
(https://www.mathworks.com/support/compilers.html) to find out the supported and
compatiable compilers for your MATLAB version.

First, install a suitable version of the `g++` compiler, for instance, we need
g++-4.9 for Ubuntu16.04:

``` shell
$ sudo apt-get install g++-4.9
```

Then change the symbolic link of the standard library in
`$matlabroot/sys/os/glnxa64` to prevent unnecessary mismatch between compiler
library and Matlab default library. To do this, run:
  
``` shell
$ cd $matlabroot/sys/os/glnxa64
$ sudo mv libstdc++.so.6 libstdc++.so.6.bak
$ sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so libstdc++.so.6
```

{% include tip.html content="`$matlabroot` is the directory where the MATLAB
software is installed. Please replace it with the actual path of the
directory. To find the folder, run `matlabroot` within MATLAB." %}

#### Windows ####

There are multiple compilers can be used on Windows machines. The following
instruction uses MinGW as an example on a Windows10 machine (VC++ is supported
for Windows7&8).

1. Install via MATLAB Add-Ons manager:

    On newer version of MATLAB (after MATLAB2015b), you can install MinGW
    support directly from the Add-Ons manager. Simply search for MinGW, and
    click `install`.

2. Directly install from TDM-GCC:

    If installing MinGW compiler via Add-On manager fails, you can also manually
    install the compiler from the
    official [TDM-GCC](http://tdm-gcc.tdragon.net/about) website.

    * Go to the [download](http://tdm-gcc.tdragon.net/download>) page, and download the version that works on your Windows PC. Please download the 64-bit version if possible.
    * After finished downloading, simply run the executable binary to install TDM-GCC compiler.
    * After the installation, you will need to add the system enviroment variable `MW_MINGW64_LOC` and specify it to the directory where you installed, for example `C:\TDM-GCC-64`.
    
{% include warning.html content="Do not have `space` in the installation path of
TDM-GCC compiler. The default path is recommended , for example
`C:\TDM-GCC-64`." %}





### MathLink ###


FROST uses MathLink libraries to communicate with the Mathematica kernel from
MATLAB. Thanks to the open-souce MATLAB package developed by `Ben Barrowes`
called
[Mathematica Symbolic Toolbox for MATLAB v2.0](https://www.mathworks.com/matlabcentral/fileexchange/6044-mathematica-symbolic-toolbox-for-matlab-version-2-0/).
This package could be downloaded directly from the MATLAB Add-Ons manager or the
Mathworks file exchange website.

The original package has a certain restriction on the maximum length of the
input string, which could cause the evaluation of some FROST functions fail. To
remove this restriction, we modified the original code and shipped the modified
version together with FROST. We also included pre-compiled MEX binaries, and the
compiled `.mex` file for different machines (some yet to come). Please use the
included MathLink instead of downloading it from other resources.

Because this package uses the MathLink libraries of Mathematica during runtime,
you must specifies the path of these libraries to your system path. To configure
this environment variable:

#### Ubuntu (or Other Linux distributions) ####

The easiest way to configure the `LD_LIBRARY_PATH` on your Linux machine for
MATLAB would be add the following to your `~/.bashrc` configuration file. For
instance, if the installed Mathematica version is `11.0`, then:

``` shell
LD_LIBRARY_PATH=/usr/local/Wolfram/Mathematica/11.0/SystemFiles/Links/MathLink/DeveloperKit/Linux-x86-64/CompilerAdditions:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
```
   

{% include note.html content="Please change the version in the above script as
the same as your installed Mathmetica version." %}

#### Windows ####


Setting up the library path on Windows PC sometimes very complicated, and not
always work. Therefore, we copied the all required the static/dynamic library
files to the folder where the mathlink source file resides.

We also includes a pre-compiled MEX binary on Windows machine. To use the
pre-compiled binary, you must include the path to Wolfram Mathematica kernal
executables to your system path.

To include the Wolfram path, edit your PATH variable (user) on your system
enviroment variables manager. The path to be added should looks like:

``` shell
C:Program Files\Wolfram Research\Mathematica\11.0\
```

{% include note.html content="When you first time call `math` function from
Matlab, there will appear a new console window of the Mathematica kernel. Do not
close this window, as it will close the running kernel." %}

### Test ###

To test if MathLink toolbox can sucessfully run, call the FROST initialization
function from MATLAB. I.e.,

``` matlab
>> frost_addpath();
```

If the Mathlink package is configured correctly, this function should print out the following messages:

``` matlab
Mathematica Kernel loading...
ans =

    11.0.0 for Linux x86 (64-bit) (July 28, 2016)

```


### IPOPT ###

We use [IPOPT](https://projects.coin-or.org/Ipopt/) as the default solver for
nonlinear constrained optimization problems. To
use [IPOPT](https://projects.coin-or.org/Ipopt/) from MATLAB, it is sufficient
to directly use the precompiled mex files for IPOPT Matlabinterface
from [www.coin-or.org](http://www.coin-or.org/download/binary/Ipopt/). The most
recent version of IPOPT as of writing this document is 3.11.8.


{% include note.html content="We have included the latest pre-compiled binaries
downloaded from the above link in FROST package. Therefore, you do not need to
download IPOPT, unless if you prefer to use other version of IPOPT." %}


### SuitSparse ###


The [SuitSparse](http://faculty.cse.tamu.edu/davis/suitesparse.html) is not a
required package to run FROST. However, the **sparse2** function comes with the
SuitSparse can be used as the replancement of Matlab's **sparse** function. The
former provides up to 2~3 times faster computation speed when compared to the
latter.


{% include note.html content="We have also included the latest pre-compiled
binaries for Win64 and Linux-64 systems in the FROST package. Therefore, there
is no need to install and compile it by your own." %}


{% include tip.html content="FROST will automatically detects if **sparse2**
 function exists in its path. If true, it will use **sparse2**."%}








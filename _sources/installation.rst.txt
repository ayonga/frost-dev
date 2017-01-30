.. _installation

***************************************
Installation
***************************************

Prerequisites
==============

FROST uses `MATLAB <https://www.mathworks.com/>`_ as the frontend interface, and uses `Wolfram Mathematica <https://www.wolfram.com/mathematica/>`_ as the backend symbolic computation engine. To use FROST, we require the following software to be installed apriori. 

- **MATLAB R2015b or later**
- **Mathematica 10.0 or later**

.. note:: FROST uses certain functions that are not supported by older versions of MATLAB and Mathematica.




Download FROST
==============

FROST is an open-source toolbox hosted on GitHub. To download the source code, run

.. code-block:: bash

   $ git clone https://github.com/ayonga/frost-dev.git frost-dev
..

Alternatively, you could download the archived *zip* file directly from this `link <https://github.com/ayonga/frost-dev/archive/master.zip>`_.


Getting Started
===============

FROST is a collection of MATLAB functions and Mathematica packages. Hence, there is no need to build the source code. However, the Mathematica package will export project-specific symbolic expressions to C++ source codes which need to be compiled as MEX files in MATLAB. This requires to setup a proper MATLAB MEX compiler for C++ before using FROST.


Setup Default MEX Compiler
------------------------------
The following instruction provides an example setup for default mex compilers on different platforms. For more information, please refer to the official document on `www.mathworks.com <https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html>`_. 

Linux
~~~~~~~~~~
Setting up MEX compiler for Linux systems (tested on Ubuntu 14.04 LTS and Ubuntu 16.04 LTS) is relatively straightfowrad. However, the default ``g++`` compiler might not be supported by MATLAB, which sometimes causes unnecessary errors. Please visit `https://www.mathworks.com/support/compilers.html <https://www.mathworks.com/support/compilers.html>`_ to find out the supported and compatiable compilers for your installed MATLAB version.

First, install a suitable version of the `g++` compiler, for instance:

.. code-block:: bash
   
   $ sudo apt-get install g++-4.9
..

Then change the symbolic link of the standard library in ``$matlabroot/sys/os/glnxa64`` to prevent unnecessary mismatch between compiler library and Matlab default library. To do this, run:
  
.. code:: bash

   $ cd $matlabroot/sys/os/glnxa64
   $ sudo mv libstdc++.so.6 libstdc++.so.6.bak
   $ sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so libstdc++.so.6
..

.. note:: ``$matlabroot`` is the directory where the MATLAB software is installed. Please replace it with the actual path of the directory. To find the folder, run ``matlabroot`` within MATLAB.

Windows
~~~~~~~
There are multiple compilers can be used on Windows machines. The following instruction uses MinGW as an example.





MathLink
------------------------

FROST uses MathLink libraries to communicate with the Mathematica kernel from MATLAB. Thanks to the open-souce MATLAB package developed by `Ben Barrowes` called `Mathematica Symbolic Toolbox for MATLAB v2.0
<https://www.mathworks.com/matlabcentral/fileexchange/6044-mathematica-symbolic-toolbox-for-matlab-version-2-0/>`_.
This package can be downloaded directly from the MATLAB Add-Ons manager or can be downloaded from the Mathworks file exchange website. 

The original package has a certain restriction on the maximum length of the input string, which could cause the evaluation of some FROST functions fail. To remove this restriction, we modified the original code and shipped the modified version together with FROST. We also included pre-compiled MEX binaries for different machines (some yet to come).

Because this package uses the MathLink libraries of Mathematica during runtime, you must specifies the path of these libraries to your system path.

Ubuntu (or Other Linux distributions)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The easiest way to configure the ``LD_LIBRARY_PATH`` on your Linux machine for MATLAB would be add the following to your `~/.bashrc` configuration file. For instance, if the installed Mathematica version is `11.0`, then:

.. code-block:: shell
   
   LD_LIBRARY_PATH=/usr/local/Wolfram/Mathematica/11.0/SystemFiles/Links/MathLink/DeveloperKit/Linux-x86-64/CompilerAdditions:$LD_LIBRARY_PATH
   export LD_LIBRARY_PATH
..

.. note:: Please change the version as the same as your installed Mathmetica version.

Windows
~~~~~~~
Comming soon ...


Test
~~~~

To test if MathLink toolbox can sucessfully run, you can call the function ``initialize_mathlink()`` from MATLAB. I.e.,

.. code-block:: matlab

   >> initialize_mathlink();
..

If it is configured correctly, it should print out the following messages:

.. code-block:: matlab

   Mathematica Kernel loading...

   ans =
   
   11.0.0 for Linux x86 (64-bit) (July 28, 2016)
..

IPOPT
------

We use `IPOPT <https://projects.coin-or.org/Ipopt/>`_ as the default solver for nonlinear constrained optimization problems. To use `IPOPT <https://projects.coin-or.org/Ipopt/>`_ from MATLAB, it is sufficient to directly use the precompiled mex files for IPOPT Matlabinterface from `www.coin-or.org <http://www.coin-or.org/download/binary/Ipopt/>`_. The most recent version of Linux machine as of writing this document is 3.11.8. Simply download the archived file of the most recent version, and extract it to the MATLAB ``path``. Then add the path to your Matlab search path by inserting the following line in the ``~/matlab/startup.m`` script. For instance, 

.. code-block:: matlab

   addpath('~/matlab/ipopt/')
..

where ``~/matlab/ipopt/`` is the directory where you extract the archived file.


SuitSparse
----------

The `SuitSparse <http://faculty.cse.tamu.edu/davis/suitesparse.html>`_ is not a
required package to run FROST. However, the **sparse2** function comes with the
SuitSparse can be used as the replancement of Matlab's **sparse** function. The
former provides up to 2~3 times faster computation speed when compared to the
latter. To install SuitSparse, please download the latest version of SuitSparse
to your Matlab `PATH`, and run

.. code-block:: matlab
   
   >> SuitSparse_install()
..

from Matlab. Press `n` when the installer prompts to run the demo, which would
skip the long demo of the package. Hit Enter if you are interested in the demo.

.. note:: FROST will automatically detects if **sparse2** function exists in its
 path. If true, it will use **sparse2**.






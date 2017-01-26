.. _installation

***************************************
Installation
***************************************

FROST is is a MATLAB toolbox for simulating and optimizing dynamic walking behaviors on bipedal robots. To run FROST in MATLAb, the following softwares/packages must be installed apriori. 

Wolfram Mathematica
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FROST uses Mathematica to generate symbolic expressions for:

- kinematics of multi-body models
- rigid body dynamics
- constraints and objective functions for gait optimization problems

The custom Mathematica packages requires to run on *Mathematica 10.0 or newer*
version. For more information how to obtain Wolfram Mathematica, please contact
your institution or Wolfram directly.


MathLink for Matlab v2.0
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FROST uses Wolfram Mathematica Kernel as the symbolic backend to Matlab through
MathLink libraries. MathLink for Matlab v2.0 is a Matlab add-on can be download
from the Matlab add-ons manager, or can be download it from
`here <https://www.mathworks.com/matlabcentral/fileexchange/6044-mathematica-symbolic-toolbox-for-matlab-version-2-0/>`_.
The package requires to compile the C source code to MEX binary file.

FROST comes with pre-compiled MEX binaries for different operating systems and
machines.

Setup C/C++ Compiler for Matlab
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Unix/MacOS
-------------------------

g++


Windows
-------------------------

MinGW



IPOPT Matlabinterface
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Note: It is sufficient to use the precompiled mex files for IPOPT
Matlabinterface, which could be found
`www.coin-or.org <http://www.coin-or.org/download/binary/Ipopt/>`_. The most recent version
of Linux machine at this moment is 3.11.8. Simply download the archived file of
the most recent version, and extract it to a directory that you normally put
other third-party libraries. Then add the path to your Matlab search path by
inserting the following line in the ~/matlab/startup.m script.

.. code-block:: matlab

   addpath('path_to_ipopt')
..

SuitSparse
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The `SuitSparse <http://faculty.cse.tamu.edu/davis/suitesparse.html>`_ is not a
required package to run FROST. However, the **sparse2** function comes with the
SuitSparse can be used as the replancement of Matlab's **sparse** function. The
former provides up to 2~3 times faster computation speed when compared to the
latter. To install SuitSparse, please download the latest version of SuitSparse
to your Matlab `PATH`, and run

.. code-block:: matlab
   
   SuitSparse_install()
..

from Matlab. Press `n` when the installer prompts to run the demo, which would
skip the long demo of the package. Hit Enter if you are interested in the demo.








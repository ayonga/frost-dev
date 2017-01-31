.. _mathematica:

==============================================
Mathematica
==============================================

This page contains the documentation for Mathematica packages shipped with FROST.

.. attention:: All methematica packages are located in the folder ``frost-dev/mathematica``. There are two sub-folders: `Source` and `Application`. The `Source` folder contains the source codes of the packages developed in Wolfram Workbench. `Application` contains the deployed packages used by other applications of FROST.

.. warning:: It is not recommended to directly modify the `Application` folder, as its content might be over-written by the source code when deploy it from `Source` folder. We suggest to use Wolfram WorkBench to develop the Mathematica package in `Source` folder and deploy it to `Application` folder.




MathToCpp
==========

Functions converts Mathematica expressions to C/C++ source code. The converted code is optimized via CSE (common sub-expression elimiation) techniques. The exported file could be either compiled as MEX binaries or directly used in other C/C++ applications.


RobotModel
==========

Functions to compute kinematics and dynamics of robotic systems.



URDFParser
==========

A parser package for reading ROS URDF files into Mathematica.

ExtraUtils
==========

Extra utility functions used throughout FROST project.


Screws
==========

A slightly modified version of Screw package originally developed by Richard Murray et al at Caltech [1]_.

SnakeYaml
==========

A parser package for YAML files, developed by Eric Cousineau.


.. [1] Murray, Richard M., Zexiang Li, S. Shankar Sastry, and S. Shankara Sastry. A mathematical introduction to robotic manipulation. CRC press, 1994.

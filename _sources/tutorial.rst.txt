.. _tutorial

***************************************
Examples
***************************************

This page contains a few working examples of using FROST to develop dynamic locomotion of multiple robots.

To run FROST examples, first change directories into the ``frost-dev`` folder and run (in MATLAB):

.. code-block:: matlab

   >> frost_addpath
..

In addition, run:

.. code-block:: matlab

   >> initialize_mathlink
..

to initialzie the MathLink enviroments if need to generate symbolic expressions in Mathematica and export to C++ files. 

2D AMBER Robot
======================================

**Coming Soom...**


3D ATLAS
======================================

To run the multi-contact dynamic walking simulation of 3D ATLAS, first change the MATLAB working directory to ``frost-dev/examples/atlas/`` and run:

.. code-block:: matlab

   >> main_sim
..

To run the multi-contact dynamic walking optimization of 3D ATLAS:

.. code-block:: matlab

   >> main_opt
..







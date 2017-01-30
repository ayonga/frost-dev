.. FROST documentation master file, created by
   sphinx-quickstart on Fri Sep 16 12:23:28 2016.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to FROST's documentation!
=================================

FROST (Fast Robot Simulation and Optimization Toolkit) for MATLAB provides a
general control development framework for dynamic bipedal walking robots using
virtual constraints based feedback controllers. The Wolfram Mathematica backend
enables generation of analytic expression of multi-body system dynamics and
kinematics symbolically, and then exported as C/C++ source could that could be
compiled as MEX files under MATLAB to boost the computational speed. FROST also
features state-of-the-art direct collocation approaches for the full-order
dynamic gait optimization problems to guarantee fast and reliable convergence.
Some key features includes:


* Use Mathematica Kernel as a backend, use 'MathLink' to send data/commands to Mathematica Kernel from Matlab.
* Dynamic bipedal walking is modelled as a hybrid system that consists of both continuous phases (domains) and discrete transitions (reset maps).
* The domain structure of the hybrid system is described via a Directed Graph (digraph).
* The directed graph could be either cyclic or acyclic.
* The default control law uses the virtual constraints based feedback controllers.

.. toctree::
   :maxdepth: 2
   :caption: Table of Contents:

   installation
   tutorial
   matlab
   mathematica
   developers
	   


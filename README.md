# FROST: Fast Robot Optimization and Simulation Toolkit

FROST (Fast Robot Optimization and Simulation Toolkit) for MATLAB provides a general full-body dynamics gait optimization and simulation framework for bipedal walking robots using virtual constraints based feedback controllers. The Wolfram Mathematica backend enables generation of analytic expressions for multi-domain system dynamics and kinematics symbolically, which are exported as C/C++ source that could be compiled as *.MEX files under MATLAB to boost the computational speed. FROST also features state-of-the-art direct collocation approaches for the full-order dynamics gait optimization problems to guarantee fast and reliable convergence. 

Some key features includes:

- Use Mathematica Kernel as a backend, use ‘MathLink’ to send data/commands to Mathematica Kernel from Matlab.
- Dynamic bipedal walking is modelled as a hybrid system that consists of both continuous phases (domains) and discrete transitions (reset maps).
- The domain structure of the hybrid system is described via a Directed Graph (digraph).
- The directed graph could be either cyclic or acyclic.
- The default control law uses the virtual constraints based feedback controllers.

Related literatures:
- Feedback control of dynamic bipedal robot locomotion, by E.R.Westervelt, J.W.Grizzle, C.Chevallereau, J.-H.Choi and B.Morris.
- etc...

For more information, please visit the official documentation webpage: http://ayonga.github.io/frost-dev



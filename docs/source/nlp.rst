.. _nlp:

*************************
Nonlinear Optimization
*************************

One of the key features of FROST is to provide a scalable fast nonlinear optimization framework for hybrid dynamical system with a particular interest in dynamic locomotion. The ``nlp`` and ``solver`` folder contains multiple class definition that are essential for developing such a fast trajectory optimization problem for legged robots.

NonlinearProgram_
==================

NonlinearProgram_ class provides an abstract super-class for general nonlinear programming problems. It consists of a general option structure and variable arrays for decision variables, constraints and cost functions which can be parsed by the SolverApplication_ objects to the actual NLP solver, such as IPOPT.

Register variables and functions
----------------------------------

Each NonlinearProgram_ object contains three cell arrays to store the information of decision variables, constraints, and cost function, respectively. These cell arrays must be 1-D cell arrays, so that we can index the variables and constraints based on their relative location within the corresponding array. In detail,

- ``VariableArray``: a cell array of decision variables, in which each decision variable is an object of class NlpVariable_
- ``CostArray``: a cell array of sub-functions of the cost function. The final cost of the problem is the total sum of the all sub-functions.
- ``ConstrArray``: a cell array of constraints (linear and nonlinear), in which each constraint is an object of class NlpFunction_ or inherited sub-classes of NlpFunction_.


.. warning:: It is not recommended to directly modify these three arrays. To add a new variable or constraint, please use the provided function for each of them.

To add a NLP decision variable to the problem, run (assume ``nlp`` is an object of NonlinearProgram_):

.. code-block:: matlab

   >> nlp.regVariable(new_vars);
..

The new variables can be either given as a 1-D cell array of NlpVariable_ objects (including single variable) or a table of 2-D cell array of NlpVariable_. An emtry entries in the input argument array will be ignored during the process.

.. hint:: If the input argument is a table (or a 2-D cell array), we convert it to an 1-D array with the order of first column then row. 

Similarly, to add a new constraint or a cost sub-function, run:

.. code-block:: matlab

   >> nlp.regConstraint(new_constrs);
   >> nlp.regObjective(new_funcs);
..

respectively. 

NlpVariable
==================


NlpFunction
==================


SymFunction
==================


HybridTrajectoryOptimization
===========================

SolverApplication
===========================

IpoptApplication
===========================



.. attention:: The implementation of these classes can be found in the folders ``frost-dev/matlab/nlp`` and ``frost-dev/matlab/solver``.

.. _NonlinearProgram: doxygen_matlab/class_nonlinear_program.html
.. _NlpFunction: doxygen_matlab/class_nlp_function.html
.. _NlpVariable: doxygen_matlab/class_nlp_variable.html
.. _HybridTrajectoryOptimization: doxygen_matlab/class_hybrid_trajectory_optimization.html
.. _SolverApplication: doxygen_matlab/class_solver_application.html
.. _IpoptApplication: doxygen_matlab/class_ipopt_application.html

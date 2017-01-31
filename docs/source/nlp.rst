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

Update variable incides
------------------------

Before associate a NonlinearProgram_ with a solver application, you should update the problem:

.. code-block:: matlab

   >> nlp.update();
..

This will generate the indices for all decision variables.



NlpVariable_
==================

NlpVariable_ provides a structured data type for NLP decision variables. A group of decision variables of a nonlinear programming problem (NonlinearProgram_) that have a distinctive identities should be represented as a NlpVariable_ object.

Properties
--------------

NlpVariable_ presents following properties of a variable:

- ``Name``: a string represent the unique ID of the variables.
- ``Dimension``: the dimension of the variable vector.
- ``InitialValue``: you could specify some typical initial values for the variables.
- ``LowerBound``: the lower boundary values of the variables.
- ``UpperBound``: the upper bonndary values of the variables.
- ``Indices``: stores the indices of the variables within the variable array of a NonlinearProgram_ problem.

Methods
----------
You can create a NlpVariable_ similar to create a struct data, For instance:

.. code-block:: matlab

   >> var = NlpVariable('Name', 'VarName', 'Dimension', 10, 'lb', -inf, 'ub', 0, 'x0', 0);
..

where `lb`, `ub`, and `x0` specify the lower, upper bound and initial values of the variable.

.. tip:: If the lower/upper bound or the initial values has different values over all members, then you can specify them by providing a vector data that has the length as the ``Dimension``.

.. note:: All properties are optional when create an object. You can specify them after you have created the object.

To specify or change the ``Name`` or the ``Dimension`` of an object, run:

.. code-block:: matlab

   >> var = var.setName('NewVarName');
   >> var = var.setDimension(20);
..

For other properties, you could use the function ``updateProp``, for example:

.. code-block:: matlab

   >> var = var.updateProp('lb', 0, 'ub', inf, 'x0', rand(1,var.Dimension));
..



   
NlpFunction_
==================

NlpFunction_ provides a structured data type for a group of NLP functions, which could be either constraints or a cost sub-functions, that share same set of properties.

Properties
--------------

NlpFunction_ presents following properties should be specified by users:

- ``Name``: a unique name string represent the unique ID of the function.
- ``Dimension``: the dimension of the vector function.
- ``LowerBound``: (optional) the lower boundary values of the function.
- ``UpperBound``: (optional) the upper bonndary values of the function.
- ``Type``: a logical variable indicates whether the function is `Linear` (true) or `Nonlinear` (false).
- ``DepVariables``: a cell array of dependent variables of type NlpVarible_.
- ``Fucs``: a struct contains the external function assosiated with the object that computes the function value, Jacobian, and Hessian if available.
- ``AuxData``: (optional) auxilary constant data to be used when call the external functions


In addition, the following properties will be updated automatically:

- ``FuncIndices``: the indices of the functions within its corresponding array of the NonlinearProgram_.
- ``nnzJacIndices``: stores the indices of non-zero entries of the Jacobian matrix
- ``nnzHessIndices``: stores the indices of non-zero entries of the Hessian matrix
- ``JacPattern``: stores the colomn-row indices of the non-zero entries of the Jacobian matrix
- ``HessPattern``: stores the colomn-row indices of the non-zero entries of the Hessian matrix
- ``nnzJac``: the total number of nonzeros in the Jacobian matrix
- ``nnzHess``: the total number of nonzeros in the Hessian matrix

Methods
------------

You can create a NlpFunction_ similar to create a struct data, For instance:

.. code-block:: matlab

   >> func = NlpFunction('Name', 'FuncName', 'Dimension', 10, 'lb', -inf, 'ub', 0, 'Type', NlpVariable.NONLINEAR, ...
		'DepVariables', {var1, var2, ...}, 'Funcs', func_struc, 'AuxData', [1,2,3]);
..

Similar to NlpVariable_ class, you can also specify each property after created the object. For more information, please see NlpFunction_.

SymFunction_
------------

SymFunction_ class provides a interface to the Mathematica Kernel for a function that can represents with symbolic expression. SymFunction_ is very useful for creating arbitray symbolic function and export associated functions to C++ source files from Mathematica. These functions can be used to associate the corresponding NlpFunction_ object.


To create a SymFunction_ object, you need to specify the following properties on-load or afterward:

- ``Name``: the name string of the function, it will use as the suffix of exported functions.
- ``Expression``: the symbolic expression of the function in Mathematica.
- ``DepSymbols``: the symbol names of the depedent variables.
- ``ParSymbols``: the symbol names of the constant parameters.
- ``PreCommands``: a series of Mathmatica expressions/commands to be ran before evaluating the ``Expression``.
- ``Description``: (optional) a descriptive pharse of the function just for reference.

For more detail of the class definition, please see SymFunction_.

Once you completely setup a SymFunction_ object, you can export it as a C++ source code. Run:

.. code-block:: matlab

   >> sym_func.export(export_path, do_build, derivative_level);
..

The derivative level determines the level of derivative functions to be exported. It could be either 1 or 2.


HybridTrajectoryOptimization_
==============================

HybridTrajectoryOptimization_ is an inherited class of NonlinearProgram_, particularly designed for trajectory optimization problem for hybrid dynamical system, for example the gait generation of legged robots. This class provides many extra features to the general NonlinearProgram_ class to enable a fast and reliable trajectory optimization of hybrid dynamical system specifically.

The overview of this class is coming soon. For more detail, please see the detailed documentation at HybridTrajectoryOptimization_.




SolverApplication_
===========================

SolverApplication_ is an abstract superclass that provides a "bridge" to the NLP solver (IPOPT, Fmincon, etc) and NonlinearProgram_ problem object. 

The intend of having this "bridge" is to make a NonlinearProgram_ problem to be solver by different solvers without changing the object itself. The SolverApplication_ object will parse the problem and convert it to a compatible problem for a specific solver to solve. The conversion also remove many features of original NonlinearProgram_ that affect the computation speed, make sure the converted problem is computationally efficient. 

Currently, we only have one sub-class implemention of type SolverApplication_. More are coming soon.

IpoptApplication_
----------------------

IpoptApplication_ generates a nonlinear optimization problem that can be solved by IPOPT solver from an NonlinearProgram_ object.

To create an application object, construct it with the NonlinearProgram_ object as the input argument:

.. code-block:: matlab

   >> solver = IpoptApplication(nlp, options); % 'options' will overwrite the default ipopt options. It is an optional argument.
..

.. attention:: The construction will initialize the solver application on construction. However, anytime you change the origianl NonlinearProgram_ object, you should initialize the solver application before run the optimization.

To initialize the solver application, run:

.. code-block:: matlab

   >> solver.initialize();
..

Once you initiazlied the solver application, you can run the following method to run the optimization:

.. code-blocks:: matlab

   >> [sol, extra] = solver.optimize(x0);
..

The ``x0`` is the (optional) initial guess for the problem. If not specified explicitly, the `solver` will use the initial guesses from each of the NlpVariable_ objectes. 



.. attention:: The implementation of these classes can be found in the folders ``frost-dev/matlab/nlp`` and ``frost-dev/matlab/solver``.

.. _NonlinearProgram: doxygen_matlab/class_nonlinear_program.html
.. _NlpFunction: doxygen_matlab/class_nlp_function.html
.. _NlpVariable: doxygen_matlab/class_nlp_variable.html
.. _HybridTrajectoryOptimization: doxygen_matlab/class_hybrid_trajectory_optimization.html
.. _SolverApplication: doxygen_matlab/class_solver_application.html
.. _IpoptApplication: doxygen_matlab/class_ipopt_application.html

.. _system:

****************
Hybrid System
****************

HybridSystem_ defines a hybrid dynamical system that has both continuous and discrete dynamics, such as bipedal locomotion. This class provides basic elements and functionalities of a hybrid dynamicsl system. The mathematical definition of the hybrid system is given as

.. math::

   \mathscr{HC} = \{\Gamma, \mathcal{D}, U, S, \Delta, FG\}
..

where,

- :math:`\Gamma=\{V,E\}` is a `directed graph` with a set of vertices :math:`V=\{v_1, v_2, \dots\}` and a set of edges :math:`E=\{e_1 = \{v_1 \to v_2\},\dots\}`;
- :math:`\mathcal{D}` is a set of admissible `domains` represents the continuous dynamics of the system;
- :math:`U` is a set of admissble controllers on each domain;
- :math:`S` is a set of `switching surfaces` or `guards` represents the conditions for discrete transitions;
- :math:`\Delta` is a set of `reset maps` of the discrete transitions;
- :math:`FG` is a set of `continuous dynamics` on the domain.

.. attention:: The implementation of these classes can be found in the folder ``frost-dev/matlab/system``.
   
To fully describe a hybrid system model, following classes are defined in FROST:

HybridSystem_
----------------

HybridSystem_ is the main class that describes a hybrid system model object. The implementation is heavily based on the Matlab's `digraph <https://www.mathworks.com/help/matlab/ref/digraph.html>`_ data type, with wrapper functions with additional validation.

A directed graph consists of two elements:

- Nodes: represent vertices in the hybrid system model. Each node has the following properties associated:

  - Domain_: a admissible domain configuration object
  - Control: a controller object
  - Param: the parameters associated with the Control and Domain
  - IsTerminal: an indicator of whether the vertex is an terminal node in the graph

- Edges: represent edges in the hybrid system model. Each edge has the following properties associated:

  - Guard_: an object of type Guard_, contains the guard condition and options for reset map associated.
  - Weight: a default property for MATLAB's `digraph` objects.

Construct a hybrid system object
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To construct a hybrid system object, you must specify a ``Name`` and associated RigidBodyModel_:

.. code-block:: matlab

   >> sys = HybridSystem('SystemName', model);
..

Once you create a HybridSystem_ object, you can add vertices/edges to complete the construction.

Add vertex to the graph
~~~~~~~~~~~~~~~~~~~~~~~

There are multiple ways to add a vertex to the directed graph of a hybrid system model:

- The simplest way to use (`prop`, value) pairs to specify a vertex:

.. code-block:: matlab

   >> sys = sys.addVertex('VertexName', 'Prop1', Value1, ...);
..

The ('prop', value) pairs are optional when adding a new vertex to the graph. You can modify the vertex property afterward by calling the function:

.. code-block:: matlab

   >> sys = sys.setVertexProperties('VertexName', 'Prop1', Value1, ...)
..

.. note:: You could also use the index of a vertex to replace the ``VertexName`` argument. 

- Use `table <https://www.mathworks.com/help/matlab/tables.html>`_ to specify a single or a group of vertices:

.. code-block:: matlab

   >> sys = sys.addVertex(T);
..

where ``T`` is a `table` argument which must have a variable named ``Names``. To specify the vertex properties in the input table, make sure to use the same set of variable names as the directed graph `Nodes` table.

- You can also add arbitrary number of vertices by specifing the number of vertices to be added:

.. code-block:: matlab

   >> sys = sys.addVertex(3);
..

The above command will add 3 empty vertices to the graph named `Node1`, `Node2`, and `Node3`. The properties of these vertices can be specified afterward using the function ``setVertexProperties``;

Remove vertex from the graph
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can also remove a single vertex or a group of vertices from the graph using the ``rmVertex`` function:

.. code-block:: matlab

   >> sys = sys.rmVertex(vertex_names);
..

`vertex_name` can be a string of the single vertex or a cell array of multiple vertices' name.

Add edges
~~~~~~~~~

There are two ways to add edges to the graph: you can either use a `table` or by specifying the source and target domains of the edge.

- The syntax is very similar to add vertex when using a table:

.. code-block:: matlab

   >> sys = sys.addEdge(T);
..
   
.. attention:: The input argument ``T`` must have a variable named ``EndNodes``, which is a `N x 2` array specifying source and target vertices.

- Edges can be also added by run:

.. code-block:: matlab

   >> sys = sys.addEdge(srcs, tars, 'Prop1', Value1, ...);
..

where ``srcs`` is a cell array of the name of source vertices, and ``tars`` is a cell array of the name of target vertices. The properties values are optional when first add an edge to the graph. You can specify the edge properties by using the function ``setEdgeProperties``:

.. code-block:: matlab

   >> sys = sys.setEdgeProperties(srcs, tars, 'Prop1', Value1, ...);
..

Remove edges
~~~~~~~~~~~~

Edges can be simply removed from the graph by running:

.. code-block:: matlab

   >> sys = sys.rmEdge(sys, srcs, tars);
..
  
Domain_
----------


Domain_ defines all admissible kinematic constraints of a continuous phase of the hybrid sytem model. There are two different types of constraints to be configured:

- Holonomic constraints: an object of KinematicGroup that describes the holonomic constraints (such as contacts and fixed kinematic joints) of the domain
- Unilateral constraints: a table of all unilateral constraints, which could be either force based (such as contact wrenches) or kinematics based (such as foot height).

To create a Domain_ object, run (in MATALB):

.. code-block:: matlab

   >> domain = Domain('DomainName');
..

The kinematic constraints of the domain object can be added as follows.

Add a contact constraint
~~~~~~~~~~~~~~~~~~~~~~~~~

You can add a contact constraint to a specific domain by first creating a KinematicContact_ object, and then:

.. code-block:: matlab

   >> domain = domain.addContact(kin_obj);
..

The kinematic of the contact will be formulated as parts of the holonomic constraints of the domain, and the conditions on the contact wrenches (such as friction code, positive normal forces, zero moment point, etc.) will be added to the unilateral constraints of the domain.

An existing contact can be also removed from the domain:

.. code-block:: matlab

   >> domain = domain.removeContact('ContactObjName');
..

.. tip:: You could also use the KinematicContact_ object directly as the input argument instead of ``ContactName`` string argument.
		

Add an auxilary holonomic constraint
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to the contact constraints, you can also add other holonomic constraints by directly call the function:

.. code-block:: matlab

   >> domain = domain.addHolonomicConstraint(kin_obj);
..

The input argument ``kin_obj`` must be a Kinematics_ type of object. For instance, a fixed joint of the robot or the kinematic four-bar loop can be modelled as *pure* holonomic constraints of the domain.

To remove an existing holonomic constraint, run:

.. code-block:: matlab

   >> domain = domain.removeHolonomicConstraint(kin_obj);
..

or

.. code-block:: matlab

   >> domain = domain.removeHolonomicConstraint('KinObjName');
..

Add an auxilary unilateral constraint
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Similarly, you can add a Kinematics_ based unilateral constraint to the domain by running:

.. code-block:: matlab

   >> domain = domain.addUnilateralConstraint(kin_obj);
..

For instance, the height of the swing foot can be formulated as an unilateral constraint.

To remove an existing unilateral constraint, run:

.. code-block:: matlab

   >> domain = domain.removeHolonomicConstraint(kin_obj);
..

or

.. code-block:: matlab

   >> domain = domain.removeHolonomicConstraint('KinObjName');
..

Compile and export symbolic expressions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Though you can compile and export symbolic expressions for a individual Kinematics_ object using its own `compile` and `export` functions, you can also compile and export all symbolic expressions related to a specific domain by running:

.. code-block:: matlab

   >> domain.compile(model, re_load); % 're_load' is an optinal argument
   >> domain.export(export_path, do_build);
..



Guard_
-----------

Guard_ defines the condition of the switching surface and options for reset map. To create a Guard_ object, run:

.. code-block:: matlab

   >> guard = Guard('GuardName', 'Prop1', Value1, ...);
..

The Guard_ class has three properties:

- Condition: This is a string that determines the condition of the guard (or the switching surface).
- Direction: This indicates in which direction the guard will be triggered. It could be either ``-1``, ``0``, or ``1``.
- ResetMap: This is a structure variable determines the specific options for computing the reset map. It has the following fields:

  - RigidImpact: ``true`` if the discrete transition involves a rigid impact; ``false`` otherwise.
  - RelabelMatrix: This is a square matrix used to relabel the coordiantes of the system. An empty value indicates there is no need to relable the coordinates.
  - ResetPoint: This is a physical point on the robot to which you want to reset the origin after the reset map. 

.. note:: The 'Condition' field must be one of the unilateral constraints name string of the source vertex (domain) of the associated edge.


VirtualConstrDomain_
------------------------

VirtualConstrDomain_ is an inherited subclass of Domain_, which contains extra definitions of virtual constraints for a particular continuous domain. There are three main properties need to be configured:

- PhaseVariable: the parameterized time variable
- PositionOutputs: a group of desired and actual position-modulating outputs
- VelocityOutput: a scalar velocity-modulating output

For more details of virtual constraints and hybrid zero dynamics (HZD) control framework, please refer to [1]_ [2]_. 

Configure the phase variable
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To configure the phase variable, run:

.. code-block:: matlab

   >> domain = domain.setPhaseVariable(type, var);
..

.. note:: The ``type`` can be either ``TimeBased`` or ``StateBased``. If the ``type`` is ``TimeBased``, then the second argument will be ignored.

.. note:: In the case of ``StateBased`` phase variable, the second argument ``var`` represents a kinematic object that will be used as the state-based phase variable.

Configure the velocity-modulating output
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A velocity-modulating output is optional for a domain that uses virtual constraints based controllers. A velocity-modulating output (or virtual constraint) is defined as the difference between the actual and desired output:

.. math::
   y_1 = \dot{y}_1^a(q,\dot{q}) - y_1^d(\tau, v)
..

where :math:`\tau` is the phase variable.

To configure a velocity-modulating output, run:

.. code-block:: matlab

   >> domain = domain.setVelocityOutput(act, des);
..

where

- ``act`` (:math:`y_1^a(q)`): represents the actual velocity-modulating output, given as a kinamatic object, and
- ``des`` (:math:`y_1^d(\tau, v)`): represents the desired velocity-modulating output, specified as its function form. Typically, we set the desired output as a **constant**.


Configure position-modulating outptus
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Position-modulating outputs define more general virtual constraints for a domain that uses virtual constraints based controllers. For each VirtualConstrDomain_, we specify a group of position-modulating outputs to our control objects. Position-modulating outputs are defined as the difference between the actual and desired 

.. math::
   y_2 = y_2^a(q) - y_2^d(\tau, a)
..

where :math:`\tau` is the phase variable.

The position-modulating outputs will be initialized as a KinematicGroup_ object that has zero dependent. To add a new output, run:

.. code-block:: matlab

   >> domain = domain.addPositionOutput(act, des);
..

where

- ``act`` (:math:`y_2^a(q)`): represents an actual position-modulating output, given as a kinamatic object, and
- ``des`` (:math:`y_2^d(\tau, a)`): represents the desired position-modulating output, specified as its function form. Typically, we set the desired output as a **Bezier Polynomial**.

You can also remove an existing output from the KinematicGroup_:

.. code-block:: matlab

   >> domain = domain.removePositionOutput(act);
..

You can also change the function form of the existing desired outputs:

.. code-block:: matlab

   >> domain = domain.changeDesiredOutputType('VelocityOutput', vel_type, 'PositionOutput', pos_type);
..

Compile and export symbolic expressions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

VirtualConstrDomain_ overloads the `compile` and `export` methods of its super-class, so that it can compile and export symbolic expressions for the virtual constraint domain simply run:

.. code-block:: matlab

   >> domain.compile(model, re_load); % 're_load' is an optinal argument
   >> domain.export(export_path, do_build);
..

.. _Kinematics: doxygen_matlab/class_kinematics.html
.. _KinematicContact: doxygen_matlab/class_kinematic_contact.html
.. _KinematicExpr: doxygen_matlab/class_kinematic_expr.html
.. _KinematicGroup: doxygen_matlab/class_kinematic_group.html
.. _KinematicCom: doxygen_matlab/class_kinematic_com.html
.. _KinematicDof: doxygen_matlab/class_kinematic_dof.html
.. _KinematicOrientation: doxygen_matlab/class_kinematic_orientation.html
.. _KinematicPosition: doxygen_matlab/class_kinematic_position.html
.. _HybridSystem: doxygen_matlab/class_hybrid_system.html
.. _RigidBodyModel: doxygen_matlab/class_rigid_body_model.html
.. _Domain: doxygen_matlab/class_domain.html
.. _Guard: doxygen_matlab/class_guard.html
.. _VirtualConstrDomain: doxygen_matlab/class_virtual_constr_domain.html
.. [1]  A.D. Ames. Human-inspired control of bipedal walking robots. *IEEE Transactions on Automatic Control*, 59(5):1115–1130, May 2014.
.. [2]  J.W. Grizzle, C. Chevallereau, R. W. Sinnet, and A. D. Ames. Models, feedback control, and open problems of 3D bipedal robotic walking. *Automatica*, 50(8):1955 – 1988, 2014.

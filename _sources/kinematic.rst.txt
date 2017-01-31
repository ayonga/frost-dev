.. _kinematic:

************
Kinematics
************

FROST provides multiple class definitions to describe a wide range of kinematic features of a rigid body model. All kinematics classes are inherite from the super class Kinematics_, which provides common interfaces and functionalities for kinematics objects. To construc a kinematic object, use the syntax:

.. code-block:: matlab

   >> kin_obj = Kinematics('Prop1', Value1, 'Prop2', Value2,...);
..

where `Prop1` and `Prop2` are the list of class properties, `Value1` and `Value2` are the values of the each properties. Different kinematic classes might have differet set of properties. You could also use a **struct** to replace the list of name-value pairs of input arguments. Assume a struct variable ``struc`` has fields `Porp1` and `Prop2`, then use the syntax:

.. code-block:: matlab

   >> kin_obj = Kinematics(struc);
..

Based on the information of each Kinematics_ object, FROST can generate associated symbolic expressions of the kinematic function and its derivatives in Mathematica and also can export to a C++ source code. These can be done by running:

.. code-block:: matlab

   >> kin_obj.compile(model, re_load); % 're_load' is an optinal argument
   >> kin_obj.export(export_path, do_build);
..

The following kinematic classes are currently implemented in FROST to describe different types of kinematic function. Here we only summarized the high-level definition of each class. For more information, please see the detailed MATLAB documentation from the associated links.

.. attention:: The implementation of these classes can be found in the folder ``frost-dev/matlab/kinematics``.

KinematicContact_
-------------------

KinematicContact_ describes a rigid physical contact of the robot with the external enviroment, such as foot-ground contacts. KinematicContact_ can support various types of contact condition, namely:

- PointContactWithFriction
- PointContactWithoutFriction
- LineContactWithFriction
- LineContactWithoutFriction
- PlanarContactWithFriction
- PlanarContactWithoutFriction
  
.. image:: images/contact1.png

To completely create a contact object, you need to specify the contact point of interest, normal/tangent axes and contact type. For more information, please check KinematicContact_.

.. note:: The dimension of the object of this class varies depends on the contact type. The rule of thumb is the total dimension = 6 - available degrees of freedom.
   
KinematicOrientation_
-----------------------
KinematicOrientation_ class describes an orientation, which is represented as one of the Euler angles, of a particular rigit link of the robot. To construct an object of this class, you must specify the link and the axis (``x``, ``y``, or ``z``) of interest.

.. note:: The dimension of this class is always 1.


KinematicPosition_
-----------------------
KinematicOrientation_ class describes a cartesian position of a particular point on the robot. To construct an object of this class, you must specify the parent link, the offset to the parent link and the axis (``x``, ``y``, or ``z``) of interest.

.. note:: The dimension of this class is always 1.

KinematicCom_
-----------------------
KinematicCom_ provides an interface with which you could specify the center of mass (CoM) of the robot as one of the kinematic function. You will only need to specify which axis (``x``, ``y``, or ``z``) you interest in when constructing an object. 

.. note:: The dimension of this class is always 1.

KinematicDof_
-----------------------
KinematicDof_ provides the simplest kinematic function, which is essentially is a particular coordinates (or joints) of the robot model. This class is designed for the generality of the composite kinematic classes, such as KinematicExpr_ and KinematicGroup_.

.. note:: The dimension of this class is always 1.


KinematicExpr_
-----------------------
KinematicExpr_ defines a scalar composite kinematic function which are functions of multiple other Kinematics_ objects, including KinematicExpr_ objects. We use **Mathematica** style string format to represent the symbolic expression of the function. The symbol used in the expression must match the `Name` of the `Dependents` objects.

KinematicExpr_ also supports including additional constant parameters in the composite expression, which enables this class being able to represent a very wide range of kinematic expression symbolically.

.. note:: The dimension of this class is always 1.


KinematicGroup_
-----------------------
KinematicGroup_ provides a 1-D vector consists of multiple Kinematics_ objects. It provides a convenient interface to defining non-scalar kinematic functions. 

.. note:: The dimension of this class equals to the summation of the dimensions of its dependent objects.
   

.. _Kinematics: doxygen_matlab/class_kinematics.html
.. _KinematicContact: doxygen_matlab/class_kinematic_contact.html
.. _KinematicExpr: doxygen_matlab/class_kinematic_expr.html
.. _KinematicGroup: doxygen_matlab/class_kinematic_group.html
.. _KinematicCom: doxygen_matlab/class_kinematic_com.html
.. _KinematicDof: doxygen_matlab/class_kinematic_dof.html
.. _KinematicOrientation: doxygen_matlab/class_kinematic_orientation.html
.. _KinematicPosition: doxygen_matlab/class_kinematic_position.html
.. _HybridSystem: doxygen_matlab/class_hybrid_system.html

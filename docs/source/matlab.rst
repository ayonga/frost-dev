.. _matlab

***************************************
MATLAB Documentation
***************************************

This page contains the high-level entries of the detailed MATLAB code documentation. 

The majority of FROST's Matlab code is written as the *object oriented programming* style. The following classes cover many aspects of dynamic locomotion from modelling, simulation, optimization and control development of legged robots. 

Model
======================

The mechanical system of a legged robot can be modelled as a rigid body model described in the class RigidBodyModel_. To construct a rigid body model object, pass the full path of the ROS URDF_ file of the robot as the first input argument:

.. code-block:: matlab

   >> model = RigidBodyModel(urdf_file_path);
..

The class constructor will parse the corresponding URDF_ file to obtain the model information of the robot, such as links and joints. The constructor function can also accept the following extra arguments as an auxilary information of the existing URDF_ file, such as the type of the model (`spatial` or `planar`) and the floating base coordinates.

For detailed information of the class, please see RigidBodyModel_.

The same configuration information, including the path of the URDF_ file and auxilary information, is also send to the Mathematica kernal to generate kinematics and dynamics expressions of the robot symbolically, and export as C++ source code. To initialize the robot model in Mathematica, run:

.. code-block:: matlab

   >> model.initialize();
..
   
After initialized the robot model in Mathematica, you can compile and export the natural dynamics of the model by running:

.. code-block:: matlab

   >> model.compileDynamics();
   >> model.exportDynamics(export_path, do_build); 
..

.. note:: The implementation of this class can be found in the folder ``frost-dev/matlab/model``.

Kinematics
==========

FROST provides multiple class definitions to describe a wide range of kinematic features of a rigid body model. All kinematics classes are inherite from the super class Kinematics_, which provides common interfaces and functionalities for kinematics objects. Based on the information of each Kinematics_ object, FROST can generate associated symbolic expression in Mathematica and also can export to a C++ source code. These can be done by running:

.. code-block:: matlab

   >> kin_obj.compile(model, re_load); % 're_load' is an optinal argument
   >> kin_obj.export(export_path, do_build);
..

The following type of kinematic classes are currently implemented in FROST.

- KinematicContact_:
- KinematicOrientation_:
- KinematicPosition_:
- KinematicDof_:
- KinematicCom_:
- KinematicExpr_:
- KinematicGroup_:

.. note:: The implementation of these classes can be found in the folder ``frost-dev/matlab/kinematics``.
Hybrid System
==============



Control
=======




Gait Optimization
=================


.. _RigidBodyModel: doxygen_matlab/class_rigid_body_model.html
.. _URDF: http://wiki.ros.org/urdf
.. _Kinematics: doxygen_matlab/class_kinematics.html
.. _KinematicContact: doxygen_matlab/class_kinematic_contact.html
.. _KinematicExpr: doxygen_matlab/class_kinematic_expr.html
.. _KinematicGroup: doxygen_matlab/class_kinematic_group.html
.. _KinematicCom: doxygen_matlab/class_kinematic_com.html
.. _KinematicDof: doxygen_matlab/class_kinematic_dof.html
.. _KinematicOrientation: doxygen_matlab/class_kinematic_orientation.html
.. _KinematicPosition: doxygen_matlab/class_kinematic_position.html

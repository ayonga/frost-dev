.. _model:

*********
Model
*********

Rigid Body Model
=================

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

.. attention:: The implementation of this class can be found in the folder ``frost-dev/matlab/model``.

.. _RigidBodyModel: doxygen_matlab/class_rigid_body_model.html
.. _URDF: http://wiki.ros.org/urdf

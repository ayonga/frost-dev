.. _control:

*************
Control
*************

We separate the controller objects from the system objects, so that we could develop general control framework for different model and systems using the same interface.

Controller_ superclass
========================

All control classes are inherited from the abstract super-class Controller_, which provides general interfaces to all controllers.

Controller_ class has two required properties:

- Name: the name of the controller
- Param: the parameter of the controller

In addition, it must provides a function to compute the control input with the syntax:

.. code-block:: matlab

   >> [u, extra] = obj.calcControl(t, q, dq, vfc, gfc, domain)
..

It takes the following input arguments:

- ``t``: the time instant
- ``q``: the coordiante configuration
- ``dq``: the velocities
- ``vfc``: the vector field :math:`f(x)` of an affine control system of the form :math:`\dot{x} = f(x) + g(x) u`
- ``gfc``: the vector field :math:`g(x)` of an affine control system of the form :math:`\dot{x} = f(x) + g(x) u`
- ``domain``: the continuous domain of interest

and returns:

- ``u``: the computed control input to the control system
- ``extra``: (optional) extra computation data


IOFeedback_ controller for virtual constraints
===============================================

IOFeedback_ class provides a classic Input-Output Feedback linearization controllers for virtual constraints enabled systems. 

An object of IOFeedback_ class requires two parameters ``kp`` and ``kd``. For more information on the implementation of this controller, please refer to [1]_.




.. attention:: The implementation of these classes can be found in the folder ``frost-dev/matlab/control``.



.. _Controller: doxygen_matlab/class_controller.html
.. _CLFQP: doxygen_matlab/class_c_l_f_q_p.html
.. _IOFeedback: doxygen_matlab/class_io_feedback.html
.. _JointPD: doxygen_matlab/class_joint_p_d.html
.. _OutputPD: doxygen_matlab/class_output_p_d.html
.. [1]  A.D. Ames. Human-inspired control of bipedal walking robots. *IEEE Transactions on Automatic Control*, 59(5):1115–1130, May 2014.

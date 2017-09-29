---
title: Introduction
sidebar: home_sidebar
---



Introduction
------------

<a href="#" data-toggle="tooltip"
data-original-title="{{site.data.glossary.frost}}">FROST</a> (**F**ast **R**obot
**O**ptimization and **S**imulation **T**oolkit) an open-source MATLAB toolkit
developed by [AMBER Lab](https://http://www.bipedalrobotics.com/) for dynamical
system modeling, trajectory optimization and model-based control design of
robotic systems, with a special focus in dynamic locomotion whose dynamics is
hybrid in nature. The design objective of <a href="#" data-toggle="tooltip"
data-original-title="{{site.data.glossary.frost}}">FROST</a> is to provide a
unified software environment for developing model based control and motion
planning algorithms based
on
[Hybrid Zero Dynamics](http://web.eecs.umich.edu/faculty/grizzle/web-book.html)
framework for robotic systems. 


Features
--------

+ Equipped with custom symbolic math toolbox for MATLAB using Mathematica Kernel
+ Hierarchical structures for describing general hybrid dynamical systems
+ Symbolic calculation of system dynamics, kinematics and other constraints
+ Specific supports for multibody systems described by
  standard [URDF](http://wiki.ros.org/urdf) files
+ Automatic construction of trajectory optimization problems
+ Fast, reliable and scalable optimization algorithms
+ Hybrid zero dynamics and virtual constraints
+ Extendable to other dynamical systems, such as **autonomous vehicles**




Structure and Functionality
---------------------------




* <a href="#" data-toggle="tooltip"
data-original-title="{{site.data.glossary.frost}}">FROST</a>
uses [directed graphs](https://www.mathworks.com/help/matlab/ref/digraph.html)
to describe the underlying discrete structure of hybrid system models, which
renders it capable of representing a wide variety of robotic systems.
* <a href="#" data-toggle="tooltip"
data-original-title="{{site.data.glossary.frost}}">FROST</a> is equipped with a
custom symbolic math toolbox in MATLAB using Wolfram Mathematica, enables users
to rapidly prototype the mathematical model of robot kinematics and dynamics and
generate optimized code of symbolic expressions to boost the speed of
optimization and simulation.
* <a href="#" data-toggle="tooltip"
data-original-title="{{site.data.glossary.frost}}">FROST</a> utilizes virtual
constraint based motion planning and feedback controllers for robotic systems to
exploit the full-order dynamics of the model for agile and dynamic behaviors.
* <a href="#" data-toggle="tooltip"
data-original-title="{{site.data.glossary.frost}}">FROST</a> provides a fast and
tractable framework for planning optimal trajectories of hybrid dynamical
systems using advanced direct collocation algorithms.



{% include image.html file="/images/frost_overview.png" alt="FROST Overview" caption="The block diagram illustration of the FROST architecture." %}


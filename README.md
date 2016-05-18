# Directly Collocated HZD Gait Optimization Package

This repository contains the optimization and simulation code for the DURUS-3D walking gaits.

## Install Required Softwares and Packages

-   MATLAB 2013a or newer
-   Wolfram Mathematica 10.0 or newer
-   IPOPT Matlabinterface [<https://projects.coin-or.org/Ipopt/wiki/MatlabInterface>](https://projects.coin-or.org/Ipopt/wiki/MatlabInterface)
-   SparseSuite [<http://faculty.cse.tamu.edu/davis/suitesparse.html>](http://faculty.cse.tamu.edu/davis/suitesparse.html)
-   Eigen 3 Library: [<http://eigen.tuxfamily.org/index.php>](http://eigen.tuxfamily.org/index.php?title%3DMain_Page)

Note: It is sufficient to use the precompiled mex files for IPOPT Matlabinterface, which could be found [here](http://www.coin-or.org/download/binary/Ipopt/). The most recent version of Linux machine at this moment is 3.11.8. Simply download the archived file of the most recent version, and extract it to a directory that you normally put other third-party libraries. Then add the path to your Matlab search path by inserting the following line in the ~/matlab/startup.m script.

    addpath('path_to_ipopt')

Note: To install SparseSuite, first download the archived file, and then run the script `SparseSuite_install.m` in MATALB. Press `n` when the installer prompts to run the demo, which would skip the long demo of the package. Hit Enter if you are interested in the demo. 

Note: Stable release of Eigen library is recommened to install. To install, please refer to the INSTALL document inside the archived file. For example, the following steps will install the eigen library in \`/usr/local/include/eigen3/\`.

    cd path_to_extracted_eigen_directory
    mkdir build
    cd build
    cmake ..
    sudo make install

Note: Matlab does not currently support GCC-4.8, which is the default compiler on Ubuntu 14.04. This will cause an array of warning messages when building. You can get rid of mex compilation GCC warnings by changing the Matlab MEX settings. To make Matlab point at the supported compiler version first install GCC-4.7 `$ sudo apt-get install gcc-4.7 g++-4.7` then:

    - $ sudo nano ${MATLAB_ROOT_PATH}/bin/mexopts.sh (example: /usr/local/MATLAB/R2015b/bin/mexopts.sh)
    - Locate the lines CC='gcc' and CXX=g++ (as of Matlab R2015b lines 58 and 73).
    - Replace the gcc and g++ versions with CC='gcc-4.7' and CXX='g++-4.7'
    - Matlab will not pull the new changes in unless you force it in most cases. To do this run the following line:
        >> mex -setup -f ${MATLAB_ROOT_PATH}/bin/mexopts.sh



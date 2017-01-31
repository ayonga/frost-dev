.. _developers:

***************************************
For Developers 
***************************************

We use Doxygen for Matlab to auto-generate the documents for Matlab classes and
functions. To use Doxygen for Matlab, it is required to install `mtoc++
<https://github.com/mdrohmann/mtocpp>`_ package from github.com or
Mathworks.com. For more information, please see `here
<https://github.com/mdrohmann/mtocpp>`_.

Install mtoc++
======================================

Windows
-----------

The package ships with pre-compiled MEX binaries for Windows machine. They can
be found in the folder 'win32' (for 32-bit machines) or 'win64' (for 64-bit
machines). Unpack the archive and add the binaries to your PATH.

Unix/Mac OS
-----------

The following procedures are based on the original README file in mtoc++ git
repository.

- Install dependencies

  .. code-block:: bash
     
     sudo apt-get install ragel cmake build-essential doxygen graphviz, libtiff-dev
  ..


- Download & Unzip in a folder

  .. code:: bash

     mkdir mtocpp
     cd mtocpp
     git clone https://github.com/mdrohmann/mtocpp.git
  ..
	    
- Compile mtoc++

  .. code:: bash

     mkdir build
     cd build
     
     cmake ..
     make
  ..
- Install mtoc++ on your system.

  - Before isntalling mtoc++, you need to copy the license file to a text file, otherwise mtoc++ will reports licensing error.

    .. code:: bash

       cp LICENSE License.txt
    ..
	      
  - Install

    .. code:: bash

       sudo make install
    ..

	


	      

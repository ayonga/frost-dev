**
Install mtoc++
**

* Configure Matlab
- missing `GLIBCXX_3.4.*'. It could be caused by the mismatch between the system libstdc++ and Matlab libstdc++. Change the symbolic link in $matlabroot/sys/os/glnxa64:
  `sudo mv libstdc++.so.6 libstdc++.so.6.bak`
  `sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21  ./libstdc++.so.6`

* Install required dependency
- doxygen
- graphviz

sudo apt-get install doxygen graphviz, libtiff-dev

* Install mtoc++


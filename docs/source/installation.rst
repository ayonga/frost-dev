.. _installation

***************************************
Installation
***************************************

* mtocpp

** Install dependence
sudo apt-get install ragel cmake build-essential doxygen

** download mtocpp
mkdir mtocpp
cd mtocpp
git clone https://github.com/mdrohmann/mtocpp.git

** install mtocpp
mkdir build
cd build

cmake ..
make

(*copy the license file*)
cp LICENSE License.txt
sudo make install

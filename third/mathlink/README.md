Mathematica Symbolic Toolbox (Version 3.0, 19 May 2018)
(not to be confused with the Symbolic Math Toolbox)
------------------------------------------------------------------
The contents of this repo consist of the source math.c for a MATLAB executable for connecting to Mathematica via its MathLink technology 
(more precisely, Wolfram Symbolic Transfer Protocol (WSTP) + C/Link) and related files.
WSTP can pass string commands and MATLAB matrices to Mathematica and return strings or MATLAB matrices.

When you run math, you may be prompted with a dialog box to browse for a Mathematica Kernel, which are named e.g. math.exe or MathKernel.exe.
(There may be multiple options in your Mathematica installation, 
including possibly 32 and 64 bit versions as reported by math('$Version').)

Distributed computing support: WSTP supports connecting programs on different computers.
    Simply run MATLAB on one computer, Mathematica on another; 
    the Mathematica Symbolic Toolbox transparently connects the
    two without imposing additional proprietary licensing
    restrictions.

Files
-----------------------------------------------------------------
README.md	- this file
math.c		- source
wstp.h		- C/Link header file
mathrun.m	- template for compiling math.c
testscript.m 	- one-line code math function call examples, also included below
LICENSE.md	- license governing all files in the repo except Mathematica files (wstp.h)
Version history.md - historical notes
   
Usage: Mathematica Symbolic Toolbox is called via the "math" function:
-----------------------------------------------------------------
math('string')          : 'string' is sent to Mathematica and evaluated as command; the
                        : result is returned as a string.
                        : For example, x=math('N[Pi,20]') will return the 
                        : numerical value of Pi with a 20 digits accuracy, but as a string.
                        :
                        : <Optional for Macintosh users>
                        : Mathematica will automatically be started if you
                        : make an alias of the "Mathematica Kernel" icon,
                        : call the alias "MathKernel", and place the alias 
                        : in the same folder as MATLAB itself. 
                        : If you don't make the alias, the MathLink library 
                        : will display a dialog box asking you to find a 
                        : Mathematica Kernel.

math('matlab2math', 'mname', mat)       : The MATLAB matrix mat is assigned
                                        : to the Mathematica symbol denoted
                                        : by the string 'mname'. The result
                                        : returned to MATLAB is 'mname'.
                                        : Note that scalars become 2-D
                                        : matrices in Mathematica.

math('math2matlab', 'expr')     : The matrix resulting from the evaluation
                                : of 'expr' by Mathematica is returned. If
                                : 'expr' doesn't yield a matrix, this function
                                : returns a MATLAB string containing '$Failed'.
                                : To retrieve a scalar from Mathematica, enclose 
                                : it in curly braces, e.g.
                                : >> a=math('math2matlab','{{scalar}}');

math('quit') or math('exit')    : These close the link and shut down Mathematica.


All of the above automatically open a MathLink connection with default arguments
if one hasn't already been opened. If the user wishes to open the connection
with particular arguments, the full form of the linkopen command is:

math('linkopen', 'linkname', 'linkmode', 'linkprotocol', 'swapEOL')
        : The first argument must be the string 'linkopen'.
        : The second argument must be the name of the link 
        :    defined as usual for WSOpenArgcArgv. Again, for simplicity, 
        :    math('linkopen') uses the default arguments.
        : The third argument is either 'Launch', 'Connect', or 'Listen'.
        : The fourth argument is either 'SharedMemory' (default), 'FileMap', 
        :    'TCP', or 'TCPIP' on Windows, and 'Pipes' on Unix. Refer to the
        :    documentation on MathLink for more information on these protocols.
        : If the fifth argument is 'swapEOL' then carriage-return and
        :    linefeed will be swapped; this is useful when connecting
        :    MATLAB and Mathematica processes residing on computers with
        :    different notions of end-of-line (for example, MATLAB on a Mac
        :    with Mathematica on a Sun SPARC). If the fifth argument is
        :    anything else, line termination will be unchanged.

In addition to the behavior above, any Mathematica warning or error messages
as well as the output from Mathematica's Print[] function will appear in the
MATLAB command window.

The following is sample output based on testscript.m.

-----------------MATLAB Transcript Begins--------------
>> math('$Version')
Mathematica Kernel loading...

ans =

'11.2.0 for Microsoft Windows (64-bit) (September 11, 2017)'

>> math('math2matlab', 'invHilbert');
>> % Returns 20x20 double
>> math('N[EulerGamma,40]')

ans =

'0.5772156649015328606065120900824024310422'

>> math('Integrate[Log[x]^(3/2),x]')  

ans =

'3 Sqrt[Pi] Erfi[Sqrt[Log[x]]]                 -3 x
     ----------------------------- + Sqrt[Log[x]] (---- + x Log[x])
                   4                                2'
>> math('InputForm[Integrate[Log[x]^(3/2),x]]')

ans =

'(3*Sqrt[Pi]*Erfi[Sqrt[Log[x]]])/4 + Sqrt[Log[x]]*((-3*x)/2 + x*Log[x])'

>> math(['Integrate[',ans,',x]'])              

ans =

'                                         Pi
                                       3 Sqrt[--] Erfi[Sqrt[2] Sqrt[Log[x]]]
     3 Sqrt[Pi] x Erfi[Sqrt[Log[x]]]          2
     ------------------------------- - ------------------------------------- + 
                    4                                   16
      
                           2
                       -9 x     2
         Sqrt[Log[x]] (----- + x  Log[x])
                         4
     >   --------------------------------
                        2'

>> math('matlab2math', 'hilbert',hilb(20))

ans =

'hilbert'

>> math('{Dimensions[hilbert],Det[hilbert]}')

ans =

    '                     -196
     {{20, 20}, 7.45342 10    }'

>> math('exactHilbert = Table[1/(i+j-1),{i,20},{j,20}];')

ans =

'Null'

>> math('Det[exactHilbert]')

ans =

'1 / 237745471676853450909164424342761644017541983775348649303318533123441975931\
      
     >    06445851875857668165737734405657598672655589717656384197107933033865823241\
      
     >    49811241023554489166154717809635257797836800000000000000000000000000000000\
      
     >    000'

>> math('N[Det[exactHilbert], 40]')

ans =

    '                                            -226
     4.206178956624722655882045573396941339798 10'

>> math('invHilbert = Inverse[hilbert];')
Inverse::luc: Result for Inverse of badly conditioned matrix 
    {{1., 0.5, 0.333333, 0.25, 0.2, 0.166667, 0.142857, 0.125, 0.111111, 0.1, 
      0.0909091, 0.0833333, 0.0769231, 0.0714286, 0.0666667, 0.0625, 
      0.0588235, 0.0555556, 0.0526316, 0.05}, <<19>>} may contain significant
     numerical errors.

ans =

    'Null'

>> math('quit')
Mathematica Kernel quitting per your request...
>> 
-----------------MATLAB Transcript Ends--------------   


How to build Mathematica Symbolic Toolbox
--------------------------------------------------------

Prerequisites: You need the WSTP header and library files for the machine on
which you are running MATLAB (since you are building a MEX-file to work
with that version of MATLAB).

General notes: after completing the other steps below,
make sure the Mathematica executable "math" and math.dll are on your Matlab path


Macintosh (Untested):
-----------
1)  Set argv[2] in math.c to point to your MathKernel, e.g.,
argv[2] = "'/Applications/Mathematica5.2/Mathematica 5.2.app/Contents/MacOS/MathKernel' -mathlink"

Then follow the directions for *NIX installation.


*NIX (Untested):
-----------
0) Make a directory to hold files required for compilation.
   You might want to put this directory on MATLAB's path using addpath in your
   startup.m
1) Find out where libWS.a and wstp.h are installed on your system.
2) Properly install the MEX tools for MATLAB. 
   The default settings in mexopts.sh should be sufficient.
   then type:

   mex -Iinclude_path -Llibrary_path -lWS math.c

   (where include_path is the path to mathlink.h and library_path
    is the path to libWS.a)

    
Windows:
--------
1)	Copy header files required by math.c and the wstp main library file from your Mathematica installation (files differ across Mathematica versions)
3)	Open Matlab command window and execute mex –setup. Choose a compiler (tested with MinGW64).
4)	Compile math.c by running mathrun.m.

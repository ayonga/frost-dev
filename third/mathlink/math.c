/*
**  MATLAB-to-Mathematica MathLink Connection
**  Version 2.0
**
**  Author:			Benjamin E. Barrowes (barrowes@alum.mit.edu)
**  Date:			6 October 2004
**  File:                       math.c
**  Description:                The MathLink MEX resource.
**  Platform:                   Linux, windows, others(?)
**
**  Version History
**      1.0 - Initial port for MATLAB 3.5 on the Macintosh
**      1.1 - Modifications for MATLAB 4.0 on all platforms
**		1.2 - Modifications to support K&R compilers and MATLAB 4.1
**				(Mac and Unix - Windows to come on next version)
**				This file only supports MATLAB 4.x. Support for
**				MATLAB 3.5 is implemented by the file math35.c.
**      2.0 - Updated to work with Mathematica 4.2/5.0 and Matlab 7.0 (R14), at
**                      least on x86 Linux
**
**
**  Prior version
**  Version 1.2
**  Author:			Douglas B. Stein (doug@wri.com)
**  Date:			17 January 1994
**  File:           math41.c
**  Description:    The MathLink MEX resource.
**  Platform:       Macintosh
**
**
*/

enum {false,true};

#include <mathlink.h>
#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned char Boolean;
#ifndef NULL
#define NULL ((void *) 0)
#endif

/* Global variables for this MEX-file */
Boolean registeredExitFunction = false;
Boolean first_time = true;
Boolean swapEOL = false;
MLINK mlp = NULL;
MLENV env;
int error;


/* Named constants */
#define MEXARGUMENTERROR            0
#define STRINGEVAL                  1
#define PUTARRAYTOMATHEMATICA       2
#define GETARRAYFROMMATHEMATICA     3
#define CLOSEMATHLINK               4
#define PROCESSEDOPENLINKARGUMENTS  5

#define LINKOPENCOMMAND             "linkopen"
#define PUTARRAYCOMMAND             "matlab2math"
#define GETARRAYCOMMAND             "math2matlab"
#define QUITCOMMAND                 "quit"
#define EXITCOMMAND                 "exit"
#define SWAPEOLSTRING               "swapEOL"

#ifdef __STDC__
extern void mexmain(void);
static Boolean OpenMathLink( int nlhs, mxArray *plhs[], 
                             int nrhs, const mxArray*prhs[] );
static void CloseMathLink(void);
static void MathLinkStringEval( int nlhs, mxArray *plhs[], 
                                int nrhs, const mxArray*prhs[] );
static int  ParseMatlabArgs( int nlhs, mxArray *plhs[], 
                             int nrhs, const mxArray*prhs[] );
static void PutArrayToMathematica( int nlhs, mxArray *plhs[], 
                                   int nrhs, const mxArray*prhs[] );
static void GetArrayFromMathematica( int nlhs, mxArray *plhs[], 
                                     int nrhs, const mxArray*prhs[] );
static void MatToStr(const mxArray *mat, char **str);
static void StrToMat(char *str, mxArray **mat);
static int  WaitForReturnPacket(MLINK mlp);
static void HandleMathLinkError(MLINK mlp, mxArray **mat);
static void SwapLineTerminators(char *str, unsigned int len);
#else
extern mexmain();
static Boolean OpenMathLink();
static CloseMathLink();
static MathLinkStringEval();
static int  ParseMatlabArgs();
static PutArrayToMathematica();
static GetArrayFromMathematica();
static MatToStr();
static StrToMat();
static int  WaitForReturnPacket();
static HandleMathLinkError();
static SwapLineTerminators();
#endif /* __STDC__ */

/* This is the main function for the MEX-file */
#ifdef __STDC__
void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
#else
     mexFunction(nlhs, plhs, nrhs, prhs)
     int nlhs, nrhs;
     mxArray *plhs[], *prhs[];
#endif
{
  /* Check for proper number of arguments */
  switch (ParseMatlabArgs(nlhs, plhs, nrhs, prhs)) {
  case MEXARGUMENTERROR:
    mexErrMsgTxt("Not valid format for math().");
    break;
  case STRINGEVAL:
    MathLinkStringEval(nlhs, plhs, nrhs, prhs);
    break;
  case PUTARRAYTOMATHEMATICA:
    PutArrayToMathematica(nlhs, plhs, nrhs, prhs);
    break;
  case GETARRAYFROMMATHEMATICA:
    GetArrayFromMathematica(nlhs, plhs, nrhs, prhs);
    break;
  case CLOSEMATHLINK:
    CloseMathLink();
    break;
  }
  return;
}

static
#ifdef __STDC__
int ParseMatlabArgs( int nlhs, mxArray *plhs[], 
                     int nrhs, const mxArray*prhs[] )
#else
     int ParseMatlabArgs(nlhs, plhs, nrhs, prhs)
     int nlhs, nrhs;
     mxArray *plhs[], *prhs[];
#endif
{
  int res = MEXARGUMENTERROR;
  char *str = NULL;
    
  if (!registeredExitFunction) {
    registeredExitFunction = (mexAtExit(CloseMathLink) == 0);
  }
    
  if (first_time) {
    if (OpenMathLink(nlhs, plhs, nrhs, prhs))
      return PROCESSEDOPENLINKARGUMENTS;
  }
    
  if (nlhs > 1)
    mexErrMsgTxt("math() requires zero or one output arguments.");
  else if (nrhs < 1)
    mexErrMsgTxt("math() requires at least one input argument.");
  else if (mxIsChar(prhs[0]) != 1)
    mexErrMsgTxt("The first input argument for math() must be a string.");
  else  {/* 1 or more rhs args - the first is a string */
    MatToStr(prhs[0], &str);
    if (nrhs == 1) {
      if (!strcmp(str, QUITCOMMAND) || !strcmp(str, EXITCOMMAND))
        res = CLOSEMATHLINK;
      else
        res = STRINGEVAL;
    } else {/* either matlab2math or math2matlab */
      if (!strcmp(str, PUTARRAYCOMMAND) && (nrhs == 3) &&
          (mxIsChar(prhs[1])==1) && !(mxIsChar(prhs[2])==1))
        res = PUTARRAYTOMATHEMATICA;
      else if (!strcmp(str, GETARRAYCOMMAND) && (nrhs == 2) &&
               (mxIsChar(prhs[1])==1))
        res = GETARRAYFROMMATHEMATICA;
      else
        res = MEXARGUMENTERROR;
    }
    free(str);
  }
    
  return res;
}

static
#ifdef __STDC__
Boolean OpenMathLink( int nlhs, mxArray *plhs[], 
                      int nrhs, const mxArray*prhs[] )
#else
     Boolean OpenMathLink(nlhs, plhs, nrhs, prhs)
     int nlhs, nrhs;
     mxArray *plhs[], *prhs[];
#endif
{
  long        localA5;
  int         argc;
  char        *argv[7], *commandStr, *swapOpt;
  int         mlres;
  Boolean     processedArgs = false;
    

  /****************************************************************/
  /* For Windows (thanks Radovan Palik)
   *
   * Mathematica 6 kernel loading
   *-----------------------------
   * ad1: set direct path to your MathKernel.exe
   *       no more stupid windows
   * ad2: set path to runkernel.bat
   *        universal, but 2 windows appears... :-(
   * ad3: remove argv[2] and set argc=2
   *        very universal :-)
   *        choose MathKernel.exe in dialog
   */ 
  //argc = 3;
  //argv[0] = "-linklaunch";
  //argv[1] = "-linkname";
  //argv[2] = "C:\\Program Files\\Wolfram Research\\Mathematica\\11.0\\MathKernel.exe";
    
  /****************************************************************/
  /* works for mathematica 7.0.0 and matlab R2009b */
  argc = 6;
  argv[0] = "MathLinkMex";
  argv[1] = "-linkname";      
  argv[2] = "MathKernel -mathlink";
  /* MAC, set argv[2] to point to your MathKernel, e.g.,
     argv[2] = "/Applications/Mathematica.app/Contents/MacOS/MathKernel -mathlink";        
  */
  /* (Tested on R14SP2 and MMA5.2 by GJE. Thanks!) */
  argv[3] = "-linkmode";      argv[4] = "Launch";
  argv[5] = "-linkprotocol";  argv[6] = "Pipes";

  /****************************************************************/
/* works for mathematica 5.2 and older */
/*   argc = 6; */
/*   argv[0] = "MathLinkMex"; */
/*   argv[1] = "-linkname";       */
/*   argv[2] = "math -mathlink"; */
/*   /\* MAC, set argv[2] to point to your MathKernel, e.g., */
/*   argv[2] = "'/Applications/Mathematica5.2/Mathematica 5.2.app/Contents/MacOS/MathKernel' -mathlink" */
/*   *\/ */
/*   /\* (Tested on R14SP2 and MMA5.2 by GJE. Thanks!) *\/ */
/*   argv[3] = "-linkmode";      argv[4] = "Launch"; */
/*   argv[5] = "-linkprotocol";  argv[6] = "Pipes"; */



  swapEOL = false;
  
  MatToStr(prhs[0], &commandStr);
  /* look for argument of the form                                    */
  /* ('linkopen', 'linkname', 'linkmode', 'linkprotocol', 'swapEOL')  */
  /* otherwise we'll use the default arguments above                  */
  if (!strcmp(commandStr, LINKOPENCOMMAND) && (nrhs == 5) &&
      (mxIsChar(prhs[1])==1) && (mxIsChar(prhs[2])==1) &&
      (mxIsChar(prhs[3])==1) && (mxIsChar(prhs[4])==1)) {
    MatToStr(prhs[1], &argv[2]);
    MatToStr(prhs[2], &argv[4]);
    MatToStr(prhs[3], &argv[6]);
    MatToStr(prhs[4], &swapOpt);
    if (!strcmp(swapOpt, SWAPEOLSTRING)) swapEOL = true;
    processedArgs = true;
  }

  /****************************************************************/
  /* works for mathematica 7.0.0 and matlab R2009b */
  env = MLInitialize(0);
  if(env == (MLENV)0)
    mexErrMsgTxt( " unable to initialize the MathLink environment ");
  mlp = MLOpenArgcArgv(env, argc, argv, &error);
  if(mlp == (MLINK)0 || error != MLEOK)
    mexErrMsgTxt("         unable to create the link ");
  MLActivate(mlp);


  /****************************************************************/
/* works for mathematica 5.2 and older */
/*   mlp = MLOpen(argc, argv); */



  if (processedArgs) {
    free(argv[2]);
    free(argv[4]);
    free(argv[6]);
    free(swapOpt);
  }
  free(commandStr);
    
  if (mlp == NULL) {
    mexErrMsgTxt("MathLink connection unexpectedly NULL! 1");
  }
    
  first_time = false;
  mexPrintf("Mathematica Kernel loading...\n");
    
  /* now preload some convenient definitions into the Mathematica kernel */
  MLPutFunction(mlp, "ToExpression", 1);
  MLPutFunction(mlp, "StringJoin", 5);
  MLPutString(mlp, "MathToMATLAB::badform = \"Second argument to math() not expressible as a MATLAB array.\";");
  MLPutString(mlp, "MATLABQ[x_]:=VectorQ[x,NumberQ[N[#]]&]||MatrixQ[x,NumberQ[N[#]]&];");
  MLPutString(mlp, "MathToMATLAB[x_?MATLABQ] := MATLABArray[N[x]];");
  MLPutString(mlp, "MathToMATLAB[x_] := (Message[MathToMATLAB::badform];$Failed);");
  MLPutString(mlp, "SetOptions[ToString, PageWidth->80];");
  MLEndPacket(mlp);
  mlres = WaitForReturnPacket(mlp);

  if (!mlres) {
    HandleMathLinkError(mlp, &plhs[0]);
  }
  MLNewPacket(mlp);
    
  return processedArgs;
}

static
#ifdef __STDC__
void CloseMathLink(void)
#else
     CloseMathLink()
#endif
{
  if (!first_time) {
    MLClose(mlp);
    mlp = NULL;
    first_time = true;
    mexPrintf("Mathematica Kernel quitting per your request...\n");
  }
    
  return;
}

static
#ifdef __STDC__ 
void MathLinkStringEval( int nlhs, mxArray *plhs[], 
                         int nrhs, const mxArray*prhs[] )
#else   
     MathLinkStringEval(nlhs, plhs, nrhs, prhs)
     int nlhs, nrhs;
     mxArray *plhs[], *prhs[];
#endif  
{
  int     mlres;
  char    *inStr = NULL;
  char    *outStr = NULL;
  int     len;

  if (mlp == NULL)
    mexErrMsgTxt("MathLink connection unexpectedly NULL! 2");
        
  MatToStr(prhs[0], &inStr);

  MLPutFunction(mlp, "ToString", 1);
  MLPutFunction(mlp, "ToExpression", 1);
  MLPutString(mlp, inStr);
  mlres = MLEndPacket(mlp);
  free(inStr);
    
  mlres = WaitForReturnPacket(mlp);
  if (mlres) {
    MLGetByteString(mlp, (const unsigned char **)&outStr, &len, '\0');
    StrToMat(outStr, &plhs[0]);
    MLDisownString(mlp, outStr);
  } else {
    HandleMathLinkError(mlp, &plhs[0]);
  }
  MLNewPacket(mlp);

  return;
}

static
#ifdef __STDC__
void PutArrayToMathematica( int nlhs, mxArray *plhs[], 
                            int nrhs, const mxArray*prhs[] )
#else
     PutArrayToMathematica(nlhs, plhs, nrhs, prhs)
     int nlhs, nrhs;
     mxArray *plhs[], *prhs[];
#endif
{
  int     mlres;
  char    *nameStr = NULL;
  double    *data, *currPtr, *realPtr, *imagPtr;
  long    dims[3];
  char    *heads[3];
  long    depth;
  int     row, col;

  /* I'd prefer to use aggregate initializers, but K&R compilers */
  /* such as that shipped standard by Sun are retarded in this */
  /* respect. */
  dims[0] = dims[1] = dims[2] = 0;
  heads[0] = "List"; heads[1] = "List"; heads[2] = "Complex";

  if (mlp == NULL)
    mexErrMsgTxt("MathLink connection unexpectedly NULL! 3");
        
  MatToStr(prhs[1], &nameStr);

  dims[0] = mxGetM(prhs[2]);
  dims[1] = mxGetN(prhs[2]);
  dims[2] = 2;
    
  /*   Originally, these double casts were to Real */
  if (mxGetPi(prhs[2]) == NULL) { /* real matrix */
    depth = 2;
    realPtr = mxGetPr(prhs[2]);
    data = (double *)malloc(dims[0] * dims[1] * sizeof(double));
    if (!data)
      mexErrMsgTxt("Memory allocation failed in PutArrayToMathematica!");
    for (currPtr = data, row = 0; row < dims[0]; row++)
      for (col = 0; col < dims[1]; col++)
        *(currPtr++) = realPtr[col*dims[0]+row];
  } else {    /* complex matrix */
    depth = 3;
    data = (double *)malloc(dims[0] * dims[1] * dims[2] * sizeof(double));
    if (!data)
      mexErrMsgTxt("Memory allocation failed in PutArrayToMathematica!");
    realPtr = mxGetPr(prhs[2]);
    imagPtr = mxGetPi(prhs[2]);
    for (currPtr = data, row = 0; row < dims[0]; row++)
      for (col = 0; col < dims[1]; col++) {
        *(currPtr++) = realPtr[col*dims[0]+row];
        *(currPtr++) = imagPtr[col*dims[0]+row];
      }
  }
    
  MLPutFunction(mlp, "CompoundExpression", 2);
  MLPutFunction(mlp, "Set", 2);
  MLPutSymbol(mlp, nameStr);
  MLPutDoubleArray(mlp, data, dims, heads, depth);
  free(data);
  MLPutSymbol(mlp, "Null");
  mlres = MLEndPacket(mlp);
    
  mlres = WaitForReturnPacket(mlp);

  if (mlres) {
    StrToMat(nameStr, &plhs[0]);
  } else {
    HandleMathLinkError(mlp, &plhs[0]);
  }
  MLNewPacket(mlp);
    
  free(nameStr);
  return;
}

static
#ifdef __STDC__
void GetArrayFromMathematica( int nlhs, mxArray *plhs[], 
                              int nrhs, const mxArray*prhs[] )
#else
     GetArrayFromMathematica(nlhs, plhs, nrhs, prhs)
     int nlhs, nrhs;
     mxArray *plhs[], *prhs[];
#endif
{
  int     mlres;
  char    *nameStr = NULL;
  double    *data, *currPtr, *realPtr, *imagPtr;
  long    *dims;
  char    **heads;
  long    depth, argcount;
  int     row, col;

  if (mlp == NULL)
    mexErrMsgTxt("MathLink connection unexpectedly NULL! 4");
        
  MatToStr(prhs[1], &nameStr);

  MLPutFunction(mlp, "MathToMATLAB", 1);
  MLPutFunction(mlp, "ToExpression", 1);
  MLPutString(mlp, nameStr);
  mlres = MLEndPacket(mlp);
    
  mlres = WaitForReturnPacket(mlp);

  if ((MLGetType(mlp) == MLTKFUNC) &&
      (MLCheckFunction(mlp, "MATLABArray", &argcount))) {
    mlres = mlres && MLGetDoubleArray(mlp, &data, &dims, &heads, &depth);
/*     mexPrintf("\n\n depth=%d \n\n",depth); */
    if (mlres) {
      switch (depth) {
      case 1: /* 1D real */
        plhs[0] = mxCreateDoubleMatrix(1, dims[0], mxREAL);/* create_matrix(1, dims[0], REAL); */
        realPtr = mxGetPr(plhs[0]);
        for (currPtr = data, col = 0; col < dims[0]; col++)
          realPtr[col] = *(currPtr++);
        break;
      case 2: /* 1D complex or 2D real */
        if (!strcmp(heads[1], "Complex")) {
          /* 1D complex */
          plhs[0] = mxCreateDoubleMatrix(1, dims[0], mxCOMPLEX);/* create_matrix(1, dims[0], COMPLEX); */
          realPtr = mxGetPr(plhs[0]);
          imagPtr = mxGetPi(plhs[0]);
          for (currPtr = data, col = 0; col < dims[0]; col++) {
            realPtr[col] = *(currPtr++);
            imagPtr[col] = *(currPtr++);
          }
        } else {
          /* 2D real */
          plhs[0] = mxCreateDoubleMatrix(dims[0], dims[1], mxREAL);/* create_matrix(dims[0], dims[1], REAL); */
          realPtr = mxGetPr(plhs[0]);
          for (currPtr = data, row = 0; row < dims[0]; row++)
            for (col = 0; col < dims[1]; col++)
              realPtr[col*dims[0]+row] = *(currPtr++);
        }
        break;
      case 3: /* 2D Complex */
        if (!strcmp(heads[2], "Complex")) {
          plhs[0] = mxCreateDoubleMatrix(dims[0], dims[1], mxCOMPLEX);/* create_matrix(dims[0], dims[1], COMPLEX); */
          realPtr = mxGetPr(plhs[0]);
          imagPtr = mxGetPi(plhs[0]);
          for (currPtr = data, row = 0; row < dims[0]; row++)
            for (col = 0; col < dims[1]; col++) {
              realPtr[col*dims[0]+row] = *(currPtr++);
              imagPtr[col*dims[0]+row] = *(currPtr++);
            }
        } else {
          mexPrintf("MATLAB can handle only 1D or 2D arrays!\n");
        }
        break;
      default:
        mexPrintf("MATLAB can handle only 1D or 2D arrays!\n");
      }
      MLDisownDoubleArray(mlp, data, dims, heads, depth);
    } else {
      HandleMathLinkError(mlp, &plhs[0]);
    }
  } else {
    StrToMat("$Failed", &plhs[0]);
  }
  MLNewPacket(mlp);
    
  free(nameStr);
  return;
}

static
#ifdef __STDC__
void MatToStr(const mxArray *mat, char **str)
#else
     MatToStr(mat, str)
     mxArray *mat;
     char **str;
#endif
{
  int     len, res;

  len = mxGetN(mat);
  *str = (char *)malloc((len + 1) * sizeof(char));
  res = mxGetString(mat, *str, len+1);
  if (swapEOL) 
    SwapLineTerminators(*str, len);
  return;
}

static
#ifdef __STDC__
void StrToMat(char *str, mxArray **mat)
#else
     StrToMat(str, mat)
     char *str;
     mxArray **mat;
#endif
{
  int     len;

  len = strlen(str);
    
  if (swapEOL)
    SwapLineTerminators(str, len);
        
  *mat = mxCreateString(str);
  return;
}

static
#ifdef __STDC__
int WaitForReturnPacket(MLINK mlp)
#else
     WaitForReturnPacket(mlp)
     MLINK mlp;
#endif
{
  int mlres;
  unsigned int len;
  char *msgStr, *destStr;
  int  msglen;

  while ((mlres = MLNextPacket(mlp)) && (mlres != RETURNPKT)) {
    if (mlres == TEXTPKT) {
      MLGetByteString(mlp, (const unsigned char **)&msgStr, &msglen, '\0');
      if (!swapEOL)
        mexPrintf("%s\n", msgStr); /* easy case */
      else { /* need to copy before mutating the string */
        len = strlen(msgStr);
        destStr = (char *)malloc((len + 1) * sizeof(char));
        if (destStr) { /* copied successfully - can mutate string */
          (void)strcpy(destStr, msgStr);
          SwapLineTerminators(destStr, len);
          mexPrintf("%s\n", destStr);
          free(destStr);
        } else /* couldn't copy - should at least output string as is */
          mexPrintf("%s\n", msgStr);
      }
      MLDisownString(mlp, msgStr);
    }
    MLNewPacket(mlp);
  }
  return mlres;
}

static
#ifdef __STDC__
void HandleMathLinkError(MLINK mlp, mxArray **mat)
#else
     HandleMathLinkError(mlp, mat)
     MLINK mlp;
     mxArray **mat;
#endif
{
  mexPrintf("%s\n", MLErrorMessage(mlp));
  MLClearError(mlp);
  StrToMat("$Failed", mat);
  return;
}

static
#ifdef __STDC__
void SwapLineTerminators(char *str, unsigned int len)
#else
     SwapLineTerminators(str, len)
     char *str;
     unsigned int len;
#endif
{
  unsigned int index;
  char *charPtr;
    
  for (charPtr = str, index = 0;
       index < len;
       index++)   {
    if (*charPtr == '\r')
      *charPtr = '\n';
    else if (*charPtr == '\n')
      *charPtr = '\r';
    charPtr++;
  }
  return;
}

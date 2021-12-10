// See README.md.

enum {false,true};

#include <assert.h>
#include <wstp.h>
#include <math.h>
#include <matrix.h>
#include <mex.h>

typedef unsigned char Boolean;
#ifndef NULL
#define NULL ((void *) 0)
#endif

/* Global variables for this MEX-file */
Boolean registeredExitFunction = false;
Boolean first_time = true;
Boolean swapEOL = false;
WSLINK mlp = NULL;

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
static int  WaitForReturnPacket(WSLINK mlp);
static void HandleMathLinkError(WSLINK mlp, mxArray **mat);
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
void mexFunction(nlhs, plhs, nrhs, prhs)
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
    

  argc = 6;
  argv[0] = "MathLinkMex";
  argv[1] = "-linkname";      argv[2] = "MathKernel -mathlink";
  argv[3] = "-linkmode";      argv[4] = "Launch";
  argv[5] = "-linkprotocol";  argv[6] = "Pipes";


  
  
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
  
  WSENV ep;
  WSLINK lp;
  int error;

  ep = WSInitialize((WSEnvironmentParameter)0);
  assert(ep != (WSENV)0);

  mlp = WSOpenArgcArgv(ep, argc, argv, &error);

  if (processedArgs) {
    free(argv[2]);
    free(argv[4]);
    free(argv[6]);
    free(swapOpt);
  }
  free(commandStr);
    
  if (mlp == NULL) {
    mexErrMsgTxt("MathLink connection unexpectedly NULL!");
  }
    
  first_time = false;
  mexPrintf("Mathematica Kernel loading...\n");
    
  /* now preload some convenient definitions into the Mathematica kernel */
  WSPutFunction(mlp, "ToExpression", 1);
  WSPutFunction(mlp, "StringJoin", 5);
  WSPutString(mlp, "MathToMATLAB::badform = \"Second argument to math() not expressible as a MATLAB array.\";");
  WSPutString(mlp, "MATLABQ[x_]:=VectorQ[x,NumberQ[N[#]]&]||MatrixQ[x,NumberQ[N[#]]&];");
  WSPutString(mlp, "MathToMATLAB[x_?MATLABQ] := MATLABArray[N[x]];");
  WSPutString(mlp, "MathToMATLAB[x_] := (Message[MathToMATLAB::badform];$Failed);");
  WSPutString(mlp, "SetOptions[ToString, PageWidth->80];");
  WSEndPacket(mlp);
  mlres = WaitForReturnPacket(mlp);

  if (!mlres) {
    HandleMathLinkError(mlp, &plhs[0]);
  }
  WSNewPacket(mlp);
    
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
    WSClose(mlp);
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
  long    len;

  if (mlp == NULL)
    mexErrMsgTxt("MathLink connection unexpectedly NULL!");
        
  MatToStr(prhs[0], &inStr);

  WSPutFunction(mlp, "ToString", 1);
  WSPutFunction(mlp, "ToExpression", 1);
  WSPutString(mlp, inStr);
  mlres = WSEndPacket(mlp);
  free(inStr);
    
  mlres = WaitForReturnPacket(mlp);
  if (mlres) {
    WSGetByteString(mlp, (const unsigned char **)&outStr, &len, '\0');
    StrToMat(outStr, &plhs[0]);
    WSReleaseString(mlp, outStr);
  } else {
    HandleMathLinkError(mlp, &plhs[0]);
  }
  WSNewPacket(mlp);

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
    mexErrMsgTxt("MathLink connection unexpectedly NULL!");
        
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
    
  WSPutFunction(mlp, "CompoundExpression", 2);
  WSPutFunction(mlp, "Set", 2);
  WSPutSymbol(mlp, nameStr);
  WSPutDoubleArray(mlp, data, dims, heads, depth);
  free(data);
  WSPutSymbol(mlp, "Null");
  mlres = WSEndPacket(mlp);
    
  mlres = WaitForReturnPacket(mlp);

  if (mlres) {
    StrToMat(nameStr, &plhs[0]);
  } else {
    HandleMathLinkError(mlp, &plhs[0]);
  }
  WSNewPacket(mlp);
    
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
    mexErrMsgTxt("MathLink connection unexpectedly NULL!");
        
  MatToStr(prhs[1], &nameStr);

  WSPutFunction(mlp, "MathToMATLAB", 1);
  WSPutFunction(mlp, "ToExpression", 1);
  WSPutString(mlp, nameStr);
  mlres = WSEndPacket(mlp);
    
  mlres = WaitForReturnPacket(mlp);

  if ((WSGetType(mlp) == WSTKFUNC) &&
      (WSCheckFunction(mlp, "MATLABArray", &argcount))) {
    mlres = mlres && WSGetDoubleArray(mlp, &data, &dims, &heads, &depth);
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
      WSReleaseDoubleArray(mlp, data, dims, heads, depth);
    } else {
      HandleMathLinkError(mlp, &plhs[0]);
    }
  } else {
    StrToMat("$Failed", &plhs[0]);
  }
  WSNewPacket(mlp);
    
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
int WaitForReturnPacket(WSLINK mlp)
#else
     WaitForReturnPacket(mlp)
     WSLINK mlp;
#endif
{
  int mlres;
  unsigned int len;
  char *msgStr, *destStr;
  long msglen;

  while ((mlres = WSNextPacket(mlp)) && (mlres != RETURNPKT)) {
    if (mlres == TEXTPKT) {
      WSGetByteString(mlp, (const unsigned char **)&msgStr, &msglen, '\0');
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
      WSReleaseString(mlp, msgStr);
    }
    WSNewPacket(mlp);
  }
  return mlres;
}

static
#ifdef __STDC__
void HandleMathLinkError(WSLINK mlp, mxArray **mat)
#else
     HandleMathLinkError(mlp, mat)
     WSLINK mlp;
     mxArray **mat;
#endif
{
  mexPrintf("%s\n", WSErrorMessage(mlp));
  WSClearError(mlp);
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

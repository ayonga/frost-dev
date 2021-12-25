/*
 * Automatically Generated from Mathematica.
 * <* DateString[] <> " " <> DateString["TimeZoneName"]  *>
 */

#ifdef MATLAB_MEX_FILE
#include <stdexcept>
#include <cmath>
#include<math.h>
/**
 * Copied from Wolfram Mathematica C Definitions file mdefs.hpp
 * Changed marcos to inline functions (Eric Cousineau)
 */
inline double Power(double x, double y) { return pow(x, y); }
inline double Sqrt(double x) { return sqrt(x); }

inline double Abs(double x) { return fabs(x); }

inline double Exp(double x) { return exp(x); }
inline double Log(double x) { return log(x); }

inline double Sin(double x) { return sin(x); }
inline double Cos(double x) { return cos(x); }
inline double Tan(double x) { return tan(x); }

inline double ArcSin(double x) { return asin(x); }
inline double ArcCos(double x) { return acos(x); }
inline double ArcTan(double x) { return atan(x); }

/* update ArcTan function to use atan2 instead. */
inline double ArcTan(double x, double y) { return atan2(y,x); }

inline double Sinh(double x) { return sinh(x); }
inline double Cosh(double x) { return cosh(x); }
inline double Tanh(double x) { return tanh(x); }

const double E	= 2.71828182845904523536029;
const double Pi = 3.14159265358979323846264;
const double Degree = 0.01745329251994329576924;

inline double Sec(double x) { return 1/cos(x); }
inline double Csc(double x) { return 1/sin(x); }

#endif

/*
 * Sub functions
 */
<* StringJoin@@Table[
"static void "<>TemplateSlot["argouts"][[i]]<>"(double *p_"<>TemplateSlot["argouts"][[i]]<>","<>StringJoin[Riffle[StringJoin["const double *", ToString[#]] & /@ TemplateSlot["argins"], ","]]<>")\n"<>
"{\n"<>
StringJoin[Riffle[StringJoin["  double ",ToString[#]]&/@TemplateSlot["lvars"][[i]],";\n"],";\n"]<>
StringJoin@@{"  ", Riffle[TemplateSlot["statements"][[i]], ";\n  "], ";\n"}<>
StringJoin@@{"  ", Riffle[TemplateSlot["final"][[i]], ";\n  "], ";\n"}<>
"}\n\n"
,
{i,Length[TemplateSlot["argouts"]]}]
*>

#ifdef MATLAB_MEX_FILE

#include "mex.h"
/*
 * Main function
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  size_t mrows, ncols;

  double <* StringJoin[Riffle[StringJoin["*", ToString[#]] & /@ TemplateSlot["argins"], ","]] *>;
  double <* StringJoin[Riffle[StringJoin["*p_", #] & /@ TemplateSlot["argouts"], ","]] *>;

  /*  Check for proper number of arguments.  */ 
  if( nrhs != <* Length[TemplateSlot["argins"]] *>)
    {
      mexErrMsgIdAndTxt("MATLAB:MShaped:invalidNumInputs", "<* Length[TemplateSlot["argins"]]/.{1 -> "One", 2 -> "Two", 3 -> "Three", 4 -> "Four", 5 -> "Five", 
 6 -> "Six", 7 -> "Seven", 8 -> "Eight", 9 -> "Nine"} *> input(s) required (<* StringJoin[ToString[#] & /@ Riffle[TemplateSlot["argins"], ","]] *>).");
    }
  else if( nlhs > <* Length[TemplateSlot["argouts"]] *>)
    {
      mexErrMsgIdAndTxt("MATLAB:MShaped:maxlhs", "Too many output arguments.");
    }

  /*  The input must be a noncomplex double vector or scaler.  */
<* StringJoin@@Table[
  "  mrows = mxGetM(prhs["<>ToString[i-1]<>"]);\n"<>
  "  ncols = mxGetN(prhs["<>ToString[i-1]<>"]);\n"<>
  "  if( !mxIsDouble(prhs["<>ToString[i-1]<>"]) || mxIsComplex(prhs["<>ToString[i-1]<>"]) ||\n"<>
  "    ( !(mrows == "<>ToString[TemplateSlot["arginDims"][[i,1]]]<>" && ncols == "<>ToString[TemplateSlot["arginDims"][[i,2]]]<>") && \n"<>
  "      !(mrows == "<>ToString[TemplateSlot["arginDims"][[i,2]]]<>" && ncols == "<>ToString[TemplateSlot["arginDims"][[i,1]]]<>"))) \n"<>
  "    {\n"<>
  "      mexErrMsgIdAndTxt( \"MATLAB:MShaped:inputNotRealVector\", \""<>ToString[TemplateSlot["argins"][[i]]]<>" is wrong.\");\n"<>
  "    }\n", {i, Length[TemplateSlot["argins"]]}]
*>
  /*  Assign pointers to each input.  */
<* StringJoin@@Table[
  "  "<>ToString[TemplateSlot["argins"][[i]]]<>" = mxGetPr(prhs["<>ToString[i-1]<>"]);\n", {i, Length[TemplateSlot["argins"]]}]
*>   


   
  /*  Create matrices for return arguments.  */
<* StringJoin@@Table[
  "  plhs["<>ToString[i-1]<>"] = mxCreateDoubleMatrix((mwSize) "<>ToString[TemplateSlot["argoutDims"][[i,1]]]<>", (mwSize) "<>ToString[TemplateSlot["argoutDims"][[i,2]]]<>", mxREAL);\n"<>
  "  p_"<>TemplateSlot["argouts"][[i]]<>" = mxGetPr(plhs["<>ToString[i-1]<>"]);\n", {i, Length[TemplateSlot["argouts"]]}]
*>

  /* Call the calculation subroutine. */
<* StringJoin@@Table[
  "  "<>TemplateSlot["argouts"][[i]]<>"(p_"<>TemplateSlot["argouts"][[i]]<>","<> StringJoin[ToString[#] & /@ Riffle[TemplateSlot["argins"], ","]]<>");\n", {i, Length[TemplateSlot["argouts"]]}]
*>

}

#else // MATLAB_MEX_FILE

#include "<*TemplateSlot["name"]*>.hh"

namespace <*TemplateSlot["namespace"]*>
{

void <*TemplateSlot["name"]*>_raw(<*StringImplode[Table["double *p_" <> TemplateSlot["argouts"][[i]], {i, Length[TemplateSlot["argouts"]]}], ", "]*>, <*StringImplode[Table["const double *"<>ToString[arg], {arg, TemplateSlot["argins"]}], ","]*>)
{
  // Call Subroutines
<*StringJoin@@Table[
"  "<>TemplateSlot["argouts"][[i]]<>"(p_"<>TemplateSlot["argouts"][[i]]<>", "<> StringImplode[Table[ToString[arg], {arg, TemplateSlot["argins"]}], ", "]<>");\n"
  , {i, Length[TemplateSlot["argouts"]]}
]*>
}

}

#endif // MATLAB_MEX_FILE

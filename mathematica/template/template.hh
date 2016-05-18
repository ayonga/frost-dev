/*
 * Automatically Generated from Mathematica.
 * <* DateString[] <> " " <> DateString["TimeZoneName"]  *>
 */
#include <Eigen/Dense>

#ifdef MATLAB_MEX_FILE
// No need for external definitions
#else // MATLAB_MEX_FILE

namespace `namespace`
{
  namespace `behavior`
  {

    void `name`_raw(<*StringImplode[Table["double *p_" <> TemplateSlot["argouts"][[i]], {i, Length[TemplateSlot["argouts"]]}], ", "]*>, <*StringImplode[Table["const double *"<>ToString[arg], {arg, TemplateSlot["argins"]}], ","]*>);

    inline void `name`(<*StringImplode[Table["Eigen::MatrixXd &p_" <> TemplateSlot["argouts"][[i]], {i, Length[TemplateSlot["argouts"]]}], ", "]*>, <*StringImplode[Table["const Eigen::VectorXd &"<>ToString[TemplateSlot["argins"][[i]]], {i, Length[TemplateSlot["argins"]]}], ","]*>)
    {
      // Check
      // - Inputs
      <*StringJoin@@Table[
			  "assert_size_matrix(" <> ToString[TemplateSlot["argins"][[i]]] <> ", " <> ToString[TemplateSlot["arginDims"][[i,1]]] <> ", " <> ToString[TemplateSlot["arginDims"][[i,2]]] <> ");\n"
			  , {i, Length[TemplateSlot["argins"]]}
			  ]*>
	
      // - Outputs
      <*StringJoin@@Table[
			  "assert_size_matrix(p_" <> ToString[TemplateSlot["argouts"][[i]]] <> ", " <> ToString[TemplateSlot["argoutDims"][[i,1]]] <> ", " <> ToString[TemplateSlot["argoutDims"][[i,2]]] <> ");\n"
			  , {i, Length[TemplateSlot["argouts"]]}
			  ]*>

      // set zero the matrix
      <*StringJoin@@Table["p_" <> TemplateSlot["argouts"][[i]] <> ".setZero();\n", {i, Length[TemplateSlot["argouts"]]}]*>

      // Call Subroutine with raw data
      `name`_raw(<*StringImplode[Table["p_" <> TemplateSlot["argouts"][[i]] <> ".data()", {i, Length[TemplateSlot["argouts"]]}], ", "]*>, <*StringImplode[Table[ToString[arg] <> ".data()", {arg, TemplateSlot["argins"]}], ","]*>);
    }
  
  }
}

#endif // MATLAB_MEX_FILE

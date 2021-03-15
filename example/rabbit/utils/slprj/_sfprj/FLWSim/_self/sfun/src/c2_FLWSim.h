#ifndef __c2_FLWSim_h__
#define __c2_FLWSim_h__

/* Type Definitions */
#ifndef typedef_SFc2_FLWSimInstanceStruct
#define typedef_SFc2_FLWSimInstanceStruct

typedef struct {
  SimStruct *S;
  ChartInfoStruct chartInfo;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  int32_T c2_sfEvent;
  boolean_T c2_doneDoubleBufferReInit;
  uint8_T c2_is_active_c2_FLWSim;
  void *c2_fEmlrtCtx;
  real_T (*c2_x)[14];
  real_T (*c2_u)[4];
  real_T (*c2_dx)[14];
  real_T (*c2_GRF)[6];
} SFc2_FLWSimInstanceStruct;

#endif                                 /*typedef_SFc2_FLWSimInstanceStruct*/

/* Named Constants */

/* Variable Declarations */
extern struct SfDebugInstanceStruct *sfGlobalDebugInstanceStruct;

/* Variable Definitions */

/* Function Declarations */
extern const mxArray *sf_c2_FLWSim_get_eml_resolved_functions_info(void);

/* Function Definitions */
extern void sf_c2_FLWSim_get_check_sum(mxArray *plhs[]);
extern void c2_FLWSim_method_dispatcher(SimStruct *S, int_T method, void *data);

#endif

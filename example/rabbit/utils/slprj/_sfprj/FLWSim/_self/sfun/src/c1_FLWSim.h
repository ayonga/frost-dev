#ifndef __c1_FLWSim_h__
#define __c1_FLWSim_h__

/* Type Definitions */
#ifndef typedef_SFc1_FLWSimInstanceStruct
#define typedef_SFc1_FLWSimInstanceStruct

typedef struct {
  SimStruct *S;
  ChartInfoStruct chartInfo;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  int32_T c1_sfEvent;
  boolean_T c1_doneDoubleBufferReInit;
  uint8_T c1_is_active_c1_FLWSim;
  void *c1_fEmlrtCtx;
  real_T (*c1_x)[14];
  real_T (*c1_GRF)[6];
  real_T (*c1_pL)[3];
  real_T (*c1_pR)[3];
} SFc1_FLWSimInstanceStruct;

#endif                                 /*typedef_SFc1_FLWSimInstanceStruct*/

/* Named Constants */

/* Variable Declarations */
extern struct SfDebugInstanceStruct *sfGlobalDebugInstanceStruct;

/* Variable Definitions */

/* Function Declarations */
extern const mxArray *sf_c1_FLWSim_get_eml_resolved_functions_info(void);

/* Function Definitions */
extern void sf_c1_FLWSim_get_check_sum(mxArray *plhs[]);
extern void c1_FLWSim_method_dispatcher(SimStruct *S, int_T method, void *data);

#endif

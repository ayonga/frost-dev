/* Include files */

#include "FLWSim_sfun.h"
#include "c1_FLWSim.h"
#include "mwmathutil.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "FLWSim_sfun_debug_macros.h"
#define _SF_MEX_LISTEN_FOR_CTRL_C(S)   sf_mex_listen_for_ctrl_c_with_debugger(S, sfGlobalDebugInstanceStruct);

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization);
static void chart_debug_initialize_data_addresses(SimStruct *S);
static const mxArray* sf_opaque_get_hover_data_for_msg(void *chartInstance,
  int32_T msgSSID);

/* Type Definitions */

/* Named Constants */
#define CALL_EVENT                     (-1)

/* Variable Declarations */

/* Variable Definitions */
static real_T _sfTime_;
static const char * c1_debug_family_names[18] = { "stiffness_v", "damping_v",
  "damping_h", "FC", "q", "dq", "vL", "vR", "GRF_Lx", "GRF_Lz", "GRF_Rx",
  "GRF_Rz", "nargin", "nargout", "x", "GRF", "pL", "pR" };

static const char * c1_b_debug_family_names[4] = { "nargin", "nargout", "var1",
  "output1" };

static const char * c1_c_debug_family_names[4] = { "nargin", "nargout", "var1",
  "output1" };

static const char * c1_d_debug_family_names[4] = { "nargin", "nargout", "var1",
  "output1" };

static const char * c1_e_debug_family_names[4] = { "nargin", "nargout", "var1",
  "output1" };

/* Function Declarations */
static void initialize_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance);
static void initialize_params_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance);
static void enable_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance);
static void disable_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance);
static void c1_update_debugger_state_c1_FLWSim(SFc1_FLWSimInstanceStruct
  *chartInstance);
static const mxArray *get_sim_state_c1_FLWSim(SFc1_FLWSimInstanceStruct
  *chartInstance);
static void set_sim_state_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_st);
static void finalize_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance);
static void sf_gateway_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance);
static void mdl_start_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance);
static void c1_chartstep_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance);
static void initSimStructsc1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber, uint32_T c1_instanceNumber);
static const mxArray *c1_sf_marshallOut(void *chartInstanceVoid, void *c1_inData);
static void c1_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance, const
  mxArray *c1_b_pR, const char_T *c1_identifier, real_T c1_y[3]);
static void c1_b_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[3]);
static void c1_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_b_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static void c1_c_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_b_GRF, const char_T *c1_identifier, real_T c1_y[6]);
static void c1_d_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[6]);
static void c1_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_c_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static const mxArray *c1_d_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static real_T c1_e_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_e_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static void c1_f_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[7]);
static void c1_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_f_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static void c1_g_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[21]);
static void c1_e_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static void c1_check_forloop_overflow_error(SFc1_FLWSimInstanceStruct
  *chartInstance, boolean_T c1_overflow);
static real_T c1_median(SFc1_FLWSimInstanceStruct *chartInstance, real_T c1_b_x
  [3]);
static const mxArray *c1_g_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static int32_T c1_h_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_f_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static uint8_T c1_i_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_b_is_active_c1_FLWSim, const char_T *c1_identifier);
static uint8_T c1_j_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void init_dsm_address_info(SFc1_FLWSimInstanceStruct *chartInstance);
static void init_simulink_io_address(SFc1_FLWSimInstanceStruct *chartInstance);

/* Function Definitions */
static void initialize_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance)
{
  if (sf_is_first_init_cond(chartInstance->S)) {
    initSimStructsc1_FLWSim(chartInstance);
    chart_debug_initialize_data_addresses(chartInstance->S);
  }

  chartInstance->c1_sfEvent = CALL_EVENT;
  _sfTime_ = sf_get_time(chartInstance->S);
  chartInstance->c1_is_active_c1_FLWSim = 0U;
}

static void initialize_params_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void enable_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void disable_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void c1_update_debugger_state_c1_FLWSim(SFc1_FLWSimInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static const mxArray *get_sim_state_c1_FLWSim(SFc1_FLWSimInstanceStruct
  *chartInstance)
{
  const mxArray *c1_st;
  const mxArray *c1_y = NULL;
  const mxArray *c1_b_y = NULL;
  const mxArray *c1_c_y = NULL;
  const mxArray *c1_d_y = NULL;
  uint8_T c1_hoistedGlobal;
  const mxArray *c1_e_y = NULL;
  c1_st = NULL;
  c1_st = NULL;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_createcellmatrix(4, 1), false);
  c1_b_y = NULL;
  sf_mex_assign(&c1_b_y, sf_mex_create("y", *chartInstance->c1_GRF, 0, 0U, 1U,
    0U, 1, 6), false);
  sf_mex_setcell(c1_y, 0, c1_b_y);
  c1_c_y = NULL;
  sf_mex_assign(&c1_c_y, sf_mex_create("y", *chartInstance->c1_pL, 0, 0U, 1U, 0U,
    1, 3), false);
  sf_mex_setcell(c1_y, 1, c1_c_y);
  c1_d_y = NULL;
  sf_mex_assign(&c1_d_y, sf_mex_create("y", *chartInstance->c1_pR, 0, 0U, 1U, 0U,
    1, 3), false);
  sf_mex_setcell(c1_y, 2, c1_d_y);
  c1_hoistedGlobal = chartInstance->c1_is_active_c1_FLWSim;
  c1_e_y = NULL;
  sf_mex_assign(&c1_e_y, sf_mex_create("y", &c1_hoistedGlobal, 3, 0U, 0U, 0U, 0),
                false);
  sf_mex_setcell(c1_y, 3, c1_e_y);
  sf_mex_assign(&c1_st, c1_y, false);
  return c1_st;
}

static void set_sim_state_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_st)
{
  const mxArray *c1_u;
  real_T c1_dv0[6];
  int32_T c1_i0;
  real_T c1_dv1[3];
  int32_T c1_i1;
  real_T c1_dv2[3];
  int32_T c1_i2;
  chartInstance->c1_doneDoubleBufferReInit = true;
  c1_u = sf_mex_dup(c1_st);
  c1_c_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 0)),
                        "GRF", c1_dv0);
  for (c1_i0 = 0; c1_i0 < 6; c1_i0++) {
    (*chartInstance->c1_GRF)[c1_i0] = c1_dv0[c1_i0];
  }

  c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 1)), "pL",
                      c1_dv1);
  for (c1_i1 = 0; c1_i1 < 3; c1_i1++) {
    (*chartInstance->c1_pL)[c1_i1] = c1_dv1[c1_i1];
  }

  c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 2)), "pR",
                      c1_dv2);
  for (c1_i2 = 0; c1_i2 < 3; c1_i2++) {
    (*chartInstance->c1_pR)[c1_i2] = c1_dv2[c1_i2];
  }

  chartInstance->c1_is_active_c1_FLWSim = c1_i_emlrt_marshallIn(chartInstance,
    sf_mex_dup(sf_mex_getcell(c1_u, 3)), "is_active_c1_FLWSim");
  sf_mex_destroy(&c1_u);
  c1_update_debugger_state_c1_FLWSim(chartInstance);
  sf_mex_destroy(&c1_st);
}

static void finalize_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void sf_gateway_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance)
{
  int32_T c1_i3;
  int32_T c1_i4;
  int32_T c1_i5;
  int32_T c1_i6;
  _SFD_SYMBOL_SCOPE_PUSH(0U, 0U);
  _sfTime_ = sf_get_time(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  for (c1_i3 = 0; c1_i3 < 14; c1_i3++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_x)[c1_i3], 0U);
  }

  chartInstance->c1_sfEvent = CALL_EVENT;
  c1_chartstep_c1_FLWSim(chartInstance);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_CHECK_FOR_STATE_INCONSISTENCY(_FLWSimMachineNumber_,
    chartInstance->chartNumber, chartInstance->instanceNumber);
  for (c1_i4 = 0; c1_i4 < 6; c1_i4++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_GRF)[c1_i4], 1U);
  }

  for (c1_i5 = 0; c1_i5 < 3; c1_i5++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_pL)[c1_i5], 2U);
  }

  for (c1_i6 = 0; c1_i6 < 3; c1_i6++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_pR)[c1_i6], 3U);
  }
}

static void mdl_start_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance)
{
  sim_mode_is_external(chartInstance->S);
}

static void c1_chartstep_c1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance)
{
  int32_T c1_i7;
  uint32_T c1_debug_family_var_map[18];
  real_T c1_b_x[14];
  real_T c1_stiffness_v;
  real_T c1_damping_v;
  real_T c1_damping_h;
  real_T c1_FC;
  real_T c1_q[7];
  real_T c1_dq[7];
  real_T c1_vL[3];
  real_T c1_vR[3];
  real_T c1_GRF_Lx;
  real_T c1_GRF_Lz;
  real_T c1_GRF_Rx;
  real_T c1_GRF_Rz;
  real_T c1_nargin = 1.0;
  real_T c1_nargout = 3.0;
  real_T c1_b_GRF[6];
  real_T c1_b_pL[3];
  real_T c1_b_pR[3];
  int32_T c1_i8;
  int32_T c1_i9;
  int32_T c1_i10;
  int32_T c1_i11;
  uint32_T c1_b_debug_family_var_map[4];
  real_T c1_var1[7];
  real_T c1_b_nargin = 1.0;
  real_T c1_b_nargout = 1.0;
  int32_T c1_i12;
  int32_T c1_i13;
  real_T c1_b_var1[7];
  real_T c1_c_nargin = 1.0;
  real_T c1_c_nargout = 1.0;
  int32_T c1_i14;
  int32_T c1_i15;
  real_T c1_c_var1[7];
  real_T c1_d_nargin = 1.0;
  real_T c1_d_nargout = 1.0;
  real_T c1_output1[21];
  int32_T c1_i16;
  int32_T c1_i17;
  int32_T c1_i18;
  real_T c1_a[21];
  int32_T c1_i19;
  real_T c1_b[7];
  int32_T c1_i20;
  int32_T c1_i21;
  int32_T c1_i22;
  int32_T c1_i23;
  real_T c1_d_var1[7];
  real_T c1_e_nargin = 1.0;
  real_T c1_e_nargout = 1.0;
  real_T c1_b_output1[21];
  int32_T c1_i24;
  int32_T c1_i25;
  int32_T c1_i26;
  int32_T c1_i27;
  int32_T c1_i28;
  int32_T c1_i29;
  int32_T c1_i30;
  real_T c1_varargin_1[2];
  int32_T c1_ixstart;
  real_T c1_mtmp;
  int32_T c1_ix;
  int32_T c1_b_ix;
  int32_T c1_b_ixstart;
  real_T c1_b_mtmp;
  int32_T c1_c_ix;
  int32_T c1_d_ix;
  real_T c1_c_GRF[3];
  real_T c1_d_GRF[3];
  int32_T c1_i31;
  int32_T c1_i32;
  int32_T c1_i33;
  boolean_T exitg1;
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  for (c1_i7 = 0; c1_i7 < 14; c1_i7++) {
    c1_b_x[c1_i7] = (*chartInstance->c1_x)[c1_i7];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 18U, 18U, c1_debug_family_names,
    c1_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_stiffness_v, 0U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_damping_v, 1U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_damping_h, 2U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_FC, 3U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_q, 4U, c1_e_sf_marshallOut,
    c1_d_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_dq, 5U, c1_e_sf_marshallOut,
    c1_d_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_vL, 6U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_vR, 7U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_GRF_Lx, 8U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_GRF_Lz, 9U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_GRF_Rx, 10U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_GRF_Rz, 11U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_nargin, 12U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_nargout, 13U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(c1_b_x, 14U, c1_c_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_GRF, 15U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_pL, 16U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_pR, 17U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  CV_EML_FCN(0, 0);
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 2);
  c1_stiffness_v = 60000.0;
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 3);
  c1_damping_v = 1000.0;
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 4);
  c1_damping_h = 10000.0;
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 5);
  c1_FC = 10.0;
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 6);
  for (c1_i8 = 0; c1_i8 < 7; c1_i8++) {
    c1_q[c1_i8] = c1_b_x[c1_i8];
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 7);
  for (c1_i9 = 0; c1_i9 < 7; c1_i9++) {
    c1_dq[c1_i9] = c1_b_x[c1_i9 + 7];
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 8);
  for (c1_i10 = 0; c1_i10 < 6; c1_i10++) {
    c1_b_GRF[c1_i10] = 0.0;
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 10);
  for (c1_i11 = 0; c1_i11 < 7; c1_i11++) {
    c1_var1[c1_i11] = c1_q[c1_i11];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 4U, 4U, c1_b_debug_family_names,
    c1_b_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_b_nargin, 0U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_b_nargout, 1U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_var1, 2U, c1_e_sf_marshallOut,
    c1_d_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_pL, 3U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  CV_SCRIPT_FCN(0, 0);
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 2);
  CV_SCRIPT_IF(0, 0, false);
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 5);
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 7);
  for (c1_i12 = 0; c1_i12 < 3; c1_i12++) {
    c1_b_pL[c1_i12] = 0.0;
  }

  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 10);
  p_LeftToe_src(c1_b_pL, c1_var1);
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, -10);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 11);
  for (c1_i13 = 0; c1_i13 < 7; c1_i13++) {
    c1_b_var1[c1_i13] = c1_q[c1_i13];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 4U, 4U, c1_c_debug_family_names,
    c1_b_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_c_nargin, 0U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_c_nargout, 1U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_var1, 2U, c1_e_sf_marshallOut,
    c1_d_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_pR, 3U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  CV_SCRIPT_FCN(1, 0);
  _SFD_SCRIPT_CALL(1U, chartInstance->c1_sfEvent, 2);
  CV_SCRIPT_IF(1, 0, false);
  _SFD_SCRIPT_CALL(1U, chartInstance->c1_sfEvent, 5);
  _SFD_SCRIPT_CALL(1U, chartInstance->c1_sfEvent, 7);
  for (c1_i14 = 0; c1_i14 < 3; c1_i14++) {
    c1_b_pR[c1_i14] = 0.0;
  }

  _SFD_SCRIPT_CALL(1U, chartInstance->c1_sfEvent, 10);
  p_RightToe_src(c1_b_pR, c1_b_var1);
  _SFD_SCRIPT_CALL(1U, chartInstance->c1_sfEvent, -10);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 12);
  for (c1_i15 = 0; c1_i15 < 7; c1_i15++) {
    c1_c_var1[c1_i15] = c1_q[c1_i15];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 4U, 4U, c1_d_debug_family_names,
    c1_b_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_d_nargin, 0U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_d_nargout, 1U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_c_var1, 2U, c1_e_sf_marshallOut,
    c1_d_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_output1, 3U, c1_f_sf_marshallOut,
    c1_e_sf_marshallIn);
  CV_SCRIPT_FCN(2, 0);
  _SFD_SCRIPT_CALL(2U, chartInstance->c1_sfEvent, 2);
  CV_SCRIPT_IF(2, 0, false);
  _SFD_SCRIPT_CALL(2U, chartInstance->c1_sfEvent, 5);
  _SFD_SCRIPT_CALL(2U, chartInstance->c1_sfEvent, 7);
  for (c1_i16 = 0; c1_i16 < 21; c1_i16++) {
    c1_output1[c1_i16] = 0.0;
  }

  _SFD_SCRIPT_CALL(2U, chartInstance->c1_sfEvent, 10);
  Jp_LeftToe_src(c1_output1, c1_c_var1);
  _SFD_SCRIPT_CALL(2U, chartInstance->c1_sfEvent, -10);
  _SFD_SYMBOL_SCOPE_POP();
  for (c1_i17 = 0; c1_i17 < 21; c1_i17++) {
    c1_a[c1_i17] = c1_output1[c1_i17];
  }

  for (c1_i18 = 0; c1_i18 < 7; c1_i18++) {
    c1_b[c1_i18] = c1_dq[c1_i18];
  }

  for (c1_i19 = 0; c1_i19 < 3; c1_i19++) {
    c1_vL[c1_i19] = 0.0;
  }

  for (c1_i20 = 0; c1_i20 < 3; c1_i20++) {
    c1_vL[c1_i20] = 0.0;
    c1_i22 = 0;
    for (c1_i23 = 0; c1_i23 < 7; c1_i23++) {
      c1_vL[c1_i20] += c1_a[c1_i22 + c1_i20] * c1_b[c1_i23];
      c1_i22 += 3;
    }
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 13);
  for (c1_i21 = 0; c1_i21 < 7; c1_i21++) {
    c1_d_var1[c1_i21] = c1_q[c1_i21];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 4U, 4U, c1_e_debug_family_names,
    c1_b_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_e_nargin, 0U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_e_nargout, 1U, c1_d_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_d_var1, 2U, c1_e_sf_marshallOut,
    c1_d_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_output1, 3U, c1_f_sf_marshallOut,
    c1_e_sf_marshallIn);
  CV_SCRIPT_FCN(3, 0);
  _SFD_SCRIPT_CALL(3U, chartInstance->c1_sfEvent, 2);
  CV_SCRIPT_IF(3, 0, false);
  _SFD_SCRIPT_CALL(3U, chartInstance->c1_sfEvent, 5);
  _SFD_SCRIPT_CALL(3U, chartInstance->c1_sfEvent, 7);
  for (c1_i24 = 0; c1_i24 < 21; c1_i24++) {
    c1_b_output1[c1_i24] = 0.0;
  }

  _SFD_SCRIPT_CALL(3U, chartInstance->c1_sfEvent, 10);
  Jp_RightToe_src(c1_b_output1, c1_d_var1);
  _SFD_SCRIPT_CALL(3U, chartInstance->c1_sfEvent, -10);
  _SFD_SYMBOL_SCOPE_POP();
  for (c1_i25 = 0; c1_i25 < 21; c1_i25++) {
    c1_a[c1_i25] = c1_b_output1[c1_i25];
  }

  for (c1_i26 = 0; c1_i26 < 7; c1_i26++) {
    c1_b[c1_i26] = c1_dq[c1_i26];
  }

  for (c1_i27 = 0; c1_i27 < 3; c1_i27++) {
    c1_vR[c1_i27] = 0.0;
  }

  for (c1_i28 = 0; c1_i28 < 3; c1_i28++) {
    c1_vR[c1_i28] = 0.0;
    c1_i29 = 0;
    for (c1_i30 = 0; c1_i30 < 7; c1_i30++) {
      c1_vR[c1_i28] += c1_a[c1_i29 + c1_i28] * c1_b[c1_i30];
      c1_i29 += 3;
    }
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 17);
  if (CV_EML_IF(0, 1, 0, CV_RELATIONAL_EVAL(4U, 0U, 0, c1_b_pL[2], 0.0, -1, 2U,
        c1_b_pL[2] < 0.0))) {
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 18);
    c1_GRF_Lx = -c1_damping_h * c1_vL[0];
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 19);
    c1_GRF_Lz = -c1_stiffness_v * c1_b_pL[2] - c1_damping_v * c1_vL[2];
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 20);
    c1_b_GRF[0] = c1_GRF_Lx;
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 21);
    c1_b_GRF[2] = c1_GRF_Lz;
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 24);
  if (CV_EML_IF(0, 1, 1, CV_RELATIONAL_EVAL(4U, 0U, 1, c1_b_pR[2], 0.0, -1, 2U,
        c1_b_pR[2] < 0.0))) {
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 25);
    c1_GRF_Rx = -c1_damping_h * c1_vR[0];
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 26);
    c1_GRF_Rz = -c1_stiffness_v * c1_b_pR[2] - c1_damping_v * c1_vR[2];
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 27);
    c1_b_GRF[3] = c1_GRF_Rx;
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 28);
    c1_b_GRF[5] = c1_GRF_Rz;
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 31);
  c1_varargin_1[0] = 0.0;
  c1_varargin_1[1] = c1_b_GRF[2];
  c1_ixstart = 1;
  c1_mtmp = c1_varargin_1[0];
  if (muDoubleScalarIsNaN(c1_varargin_1[0])) {
    c1_ix = 1;
    exitg1 = false;
    while ((!exitg1) && (c1_ix + 1 < 3)) {
      c1_ixstart = c1_ix + 1;
      if (!muDoubleScalarIsNaN(c1_varargin_1[c1_ix])) {
        c1_mtmp = c1_varargin_1[c1_ix];
        exitg1 = true;
      } else {
        c1_ix++;
      }
    }
  }

  if (c1_ixstart < 2) {
    for (c1_b_ix = c1_ixstart; c1_b_ix + 1 < 3; c1_b_ix++) {
      if (c1_varargin_1[c1_b_ix] > c1_mtmp) {
        c1_mtmp = c1_varargin_1[c1_b_ix];
      }
    }
  }

  c1_b_GRF[2] = c1_mtmp;
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 32);
  c1_varargin_1[0] = 0.0;
  c1_varargin_1[1] = c1_b_GRF[5];
  c1_b_ixstart = 1;
  c1_b_mtmp = c1_varargin_1[0];
  if (muDoubleScalarIsNaN(c1_varargin_1[0])) {
    c1_c_ix = 1;
    exitg1 = false;
    while ((!exitg1) && (c1_c_ix + 1 < 3)) {
      c1_b_ixstart = c1_c_ix + 1;
      if (!muDoubleScalarIsNaN(c1_varargin_1[c1_c_ix])) {
        c1_b_mtmp = c1_varargin_1[c1_c_ix];
        exitg1 = true;
      } else {
        c1_c_ix++;
      }
    }
  }

  if (c1_b_ixstart < 2) {
    for (c1_d_ix = c1_b_ixstart; c1_d_ix + 1 < 3; c1_d_ix++) {
      if (c1_varargin_1[c1_d_ix] > c1_b_mtmp) {
        c1_b_mtmp = c1_varargin_1[c1_d_ix];
      }
    }
  }

  c1_b_GRF[5] = c1_b_mtmp;
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 34);
  c1_c_GRF[0] = c1_b_GRF[0];
  c1_c_GRF[1] = c1_FC * c1_b_GRF[2];
  c1_c_GRF[2] = -c1_FC * c1_b_GRF[2];
  c1_b_GRF[0] = c1_median(chartInstance, c1_c_GRF);
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 35);
  c1_d_GRF[0] = c1_b_GRF[3];
  c1_d_GRF[1] = c1_FC * c1_b_GRF[5];
  c1_d_GRF[2] = -c1_FC * c1_b_GRF[5];
  c1_b_GRF[3] = c1_median(chartInstance, c1_d_GRF);
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, -35);
  _SFD_SYMBOL_SCOPE_POP();
  for (c1_i31 = 0; c1_i31 < 6; c1_i31++) {
    (*chartInstance->c1_GRF)[c1_i31] = c1_b_GRF[c1_i31];
  }

  for (c1_i32 = 0; c1_i32 < 3; c1_i32++) {
    (*chartInstance->c1_pL)[c1_i32] = c1_b_pL[c1_i32];
  }

  for (c1_i33 = 0; c1_i33 < 3; c1_i33++) {
    (*chartInstance->c1_pR)[c1_i33] = c1_b_pR[c1_i33];
  }

  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
}

static void initSimStructsc1_FLWSim(SFc1_FLWSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber, uint32_T c1_instanceNumber)
{
  (void)(c1_machineNumber);
  (void)(c1_chartNumber);
  (void)(c1_instanceNumber);
  _SFD_SCRIPT_TRANSLATION(c1_chartNumber, c1_instanceNumber, 0U,
    sf_debug_get_script_id(
    "C:\\Users\\mungam\\Documents\\GitHub\\Fault_Detection_Diagnostics\\FiveLinkWalker_Yukai\\Simulation\\Model\\kin\\m\\p_LeftToe.m"));
  _SFD_SCRIPT_TRANSLATION(c1_chartNumber, c1_instanceNumber, 1U,
    sf_debug_get_script_id(
    "C:\\Users\\mungam\\Documents\\GitHub\\Fault_Detection_Diagnostics\\FiveLinkWalker_Yukai\\Simulation\\Model\\kin\\m\\p_RightToe.m"));
  _SFD_SCRIPT_TRANSLATION(c1_chartNumber, c1_instanceNumber, 2U,
    sf_debug_get_script_id(
    "C:\\Users\\mungam\\Documents\\GitHub\\Fault_Detection_Diagnostics\\FiveLinkWalker_Yukai\\Simulation\\Model\\kin\\m\\Jp_LeftToe.m"));
  _SFD_SCRIPT_TRANSLATION(c1_chartNumber, c1_instanceNumber, 3U,
    sf_debug_get_script_id(
    "C:\\Users\\mungam\\Documents\\GitHub\\Fault_Detection_Diagnostics\\FiveLinkWalker_Yukai\\Simulation\\Model\\kin\\m\\Jp_RightToe.m"));
}

static const mxArray *c1_sf_marshallOut(void *chartInstanceVoid, void *c1_inData)
{
  const mxArray *c1_mxArrayOutData;
  int32_T c1_i34;
  const mxArray *c1_y = NULL;
  real_T c1_u[3];
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_mxArrayOutData = NULL;
  for (c1_i34 = 0; c1_i34 < 3; c1_i34++) {
    c1_u[c1_i34] = (*(real_T (*)[3])c1_inData)[c1_i34];
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 1, 3), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static void c1_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance, const
  mxArray *c1_b_pR, const char_T *c1_identifier, real_T c1_y[3])
{
  emlrtMsgIdentifier c1_thisId;
  c1_thisId.fIdentifier = (const char *)c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_pR), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_b_pR);
}

static void c1_b_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[3])
{
  real_T c1_dv3[3];
  int32_T c1_i35;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), c1_dv3, 1, 0, 0U, 1, 0U, 1, 3);
  for (c1_i35 = 0; c1_i35 < 3; c1_i35++) {
    c1_y[c1_i35] = c1_dv3[c1_i35];
  }

  sf_mex_destroy(&c1_u);
}

static void c1_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_pR;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y[3];
  int32_T c1_i36;
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_b_pR = sf_mex_dup(c1_mxArrayInData);
  c1_thisId.fIdentifier = (const char *)c1_varName;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_pR), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_b_pR);
  for (c1_i36 = 0; c1_i36 < 3; c1_i36++) {
    (*(real_T (*)[3])c1_outData)[c1_i36] = c1_y[c1_i36];
  }

  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_b_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData;
  int32_T c1_i37;
  const mxArray *c1_y = NULL;
  real_T c1_u[6];
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_mxArrayOutData = NULL;
  for (c1_i37 = 0; c1_i37 < 6; c1_i37++) {
    c1_u[c1_i37] = (*(real_T (*)[6])c1_inData)[c1_i37];
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 1, 6), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static void c1_c_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_b_GRF, const char_T *c1_identifier, real_T c1_y[6])
{
  emlrtMsgIdentifier c1_thisId;
  c1_thisId.fIdentifier = (const char *)c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_GRF), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_b_GRF);
}

static void c1_d_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[6])
{
  real_T c1_dv4[6];
  int32_T c1_i38;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), c1_dv4, 1, 0, 0U, 1, 0U, 1, 6);
  for (c1_i38 = 0; c1_i38 < 6; c1_i38++) {
    c1_y[c1_i38] = c1_dv4[c1_i38];
  }

  sf_mex_destroy(&c1_u);
}

static void c1_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_GRF;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y[6];
  int32_T c1_i39;
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_b_GRF = sf_mex_dup(c1_mxArrayInData);
  c1_thisId.fIdentifier = (const char *)c1_varName;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_GRF), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_b_GRF);
  for (c1_i39 = 0; c1_i39 < 6; c1_i39++) {
    (*(real_T (*)[6])c1_outData)[c1_i39] = c1_y[c1_i39];
  }

  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_c_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData;
  int32_T c1_i40;
  const mxArray *c1_y = NULL;
  real_T c1_u[14];
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_mxArrayOutData = NULL;
  for (c1_i40 = 0; c1_i40 < 14; c1_i40++) {
    c1_u[c1_i40] = (*(real_T (*)[14])c1_inData)[c1_i40];
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 1, 14), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static const mxArray *c1_d_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData;
  real_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_mxArrayOutData = NULL;
  c1_u = *(real_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static real_T c1_e_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  real_T c1_y;
  real_T c1_d0;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_d0, 1, 0, 0U, 0, 0U, 0);
  c1_y = c1_d0;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_nargout;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y;
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_nargout = sf_mex_dup(c1_mxArrayInData);
  c1_thisId.fIdentifier = (const char *)c1_varName;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_y = c1_e_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_nargout), &c1_thisId);
  sf_mex_destroy(&c1_nargout);
  *(real_T *)c1_outData = c1_y;
  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_e_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData;
  int32_T c1_i41;
  const mxArray *c1_y = NULL;
  real_T c1_u[7];
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_mxArrayOutData = NULL;
  for (c1_i41 = 0; c1_i41 < 7; c1_i41++) {
    c1_u[c1_i41] = (*(real_T (*)[7])c1_inData)[c1_i41];
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 1, 7), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static void c1_f_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[7])
{
  real_T c1_dv5[7];
  int32_T c1_i42;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), c1_dv5, 1, 0, 0U, 1, 0U, 1, 7);
  for (c1_i42 = 0; c1_i42 < 7; c1_i42++) {
    c1_y[c1_i42] = c1_dv5[c1_i42];
  }

  sf_mex_destroy(&c1_u);
}

static void c1_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_dq;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y[7];
  int32_T c1_i43;
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_dq = sf_mex_dup(c1_mxArrayInData);
  c1_thisId.fIdentifier = (const char *)c1_varName;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_f_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_dq), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_dq);
  for (c1_i43 = 0; c1_i43 < 7; c1_i43++) {
    (*(real_T (*)[7])c1_outData)[c1_i43] = c1_y[c1_i43];
  }

  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_f_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData;
  int32_T c1_i44;
  int32_T c1_i45;
  const mxArray *c1_y = NULL;
  int32_T c1_i46;
  real_T c1_u[21];
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_mxArrayOutData = NULL;
  c1_i44 = 0;
  for (c1_i45 = 0; c1_i45 < 7; c1_i45++) {
    for (c1_i46 = 0; c1_i46 < 3; c1_i46++) {
      c1_u[c1_i46 + c1_i44] = (*(real_T (*)[21])c1_inData)[c1_i46 + c1_i44];
    }

    c1_i44 += 3;
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 2, 3, 7), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static void c1_g_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[21])
{
  real_T c1_dv6[21];
  int32_T c1_i47;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), c1_dv6, 1, 0, 0U, 1, 0U, 2, 3, 7);
  for (c1_i47 = 0; c1_i47 < 21; c1_i47++) {
    c1_y[c1_i47] = c1_dv6[c1_i47];
  }

  sf_mex_destroy(&c1_u);
}

static void c1_e_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_output1;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y[21];
  int32_T c1_i48;
  int32_T c1_i49;
  int32_T c1_i50;
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_output1 = sf_mex_dup(c1_mxArrayInData);
  c1_thisId.fIdentifier = (const char *)c1_varName;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_g_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_output1), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_output1);
  c1_i48 = 0;
  for (c1_i49 = 0; c1_i49 < 7; c1_i49++) {
    for (c1_i50 = 0; c1_i50 < 3; c1_i50++) {
      (*(real_T (*)[21])c1_outData)[c1_i50 + c1_i48] = c1_y[c1_i50 + c1_i48];
    }

    c1_i48 += 3;
  }

  sf_mex_destroy(&c1_mxArrayInData);
}

const mxArray *sf_c1_FLWSim_get_eml_resolved_functions_info(void)
{
  const mxArray *c1_nameCaptureInfo = NULL;
  const char * c1_data[6] = {
    "789ced98df6eda3018c54dd555ebaa4eb99afa00d334eda25ed92a75bb5a4aa08cc2c4f833da4d531a12032eb6438953c2aef6207b9bee217ab947199484044f"
    "1693406941f9a4c8393ac6c7719c9f2c40ea63290500783aba3646d7de1eb8abdd490314bfdd00b325fa29bfdd1474508f7c6757f07ff9ad69338e3c3e110433",
    "f4c9a54dd41f096650341dc6b2296606e3b5610f813e726c728dac3ba78509aa618a8a7644e4f148d05cc49a8ab135becf7490d9adba14f43b4e385d121520b2"
    "3e1792e7df9cedfe8f2f96b83e62bf79795b73f2529236a86df038a29e7f08f27a92f1e63d5f30feb6244f11fc9e5e442d5eb38357bbe8fa06795b820ef3278e",
    "65bb4d82c2bcdb05f306d2bc59ff5bf67be63dac3ba8ef40eab2b641a1669b2e458c3bf004f3bcdb8439c3255cd7104726c736d3356cb499ed706c3a3087af51"
    "11b36ec3205dd4d7cfddae816115539718e3beb0645b88c02e6690c2e9daeed318f7d1cfdf373bb76abcfb36eeefe4fef23cc978ffbb4f9f49f214c1fffa7950",
    "21e7d9e3e141bd8e55875c79b4629d84f328cfc999370f20d1718d7f21f9fd6af3fbc5d2f8fd4492a7087e4fafe0762704f8aaf2db133410fa057ebcfc0ed676"
    "9f26fc5e8fbcb8f85dade44a6fd265867b07879dcb6ce3cc6951eb38e1b7580f8bdf2f63e77741388027fc5e1ebf0b9103788cfcbe49f8bdfafc66aae77a678d",
    "76e12afbc57a37787b79946f9af984df623d2c7ebf5a1abf7724798ae0178403f87df1fbcf82794369deac1f33bfc303b89f9f707c3df2e2e2f86939d3e0ea8f"
    "537ea865d3e9d76aadace58fd6e07f94bf05054dfb", "" };

  c1_nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(c1_data, 6192U, &c1_nameCaptureInfo);
  return c1_nameCaptureInfo;
}

static void c1_check_forloop_overflow_error(SFc1_FLWSimInstanceStruct
  *chartInstance, boolean_T c1_overflow)
{
  const mxArray *c1_y = NULL;
  static char_T c1_cv0[34] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'i', 'n', 't', '_', 'f', 'o', 'r', 'l', 'o', 'o', 'p',
    '_', 'o', 'v', 'e', 'r', 'f', 'l', 'o', 'w' };

  const mxArray *c1_b_y = NULL;
  static char_T c1_cv1[5] = { 'i', 'n', 't', '3', '2' };

  (void)chartInstance;
  if (!c1_overflow) {
  } else {
    c1_y = NULL;
    sf_mex_assign(&c1_y, sf_mex_create("y", c1_cv0, 10, 0U, 1U, 0U, 2, 1, 34),
                  false);
    c1_b_y = NULL;
    sf_mex_assign(&c1_b_y, sf_mex_create("y", c1_cv1, 10, 0U, 1U, 0U, 2, 1, 5),
                  false);
    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "error", 0U, 1U, 14,
                      sf_mex_call_debug(sfGlobalDebugInstanceStruct, "message",
      1U, 2U, 14, c1_y, 14, c1_b_y));
  }
}

static real_T c1_median(SFc1_FLWSimInstanceStruct *chartInstance, real_T c1_b_x
  [3])
{
  int32_T c1_k;
  boolean_T c1_p;
  real_T c1_d1;
  boolean_T c1_b_p;
  boolean_T c1_c_p;
  boolean_T c1_d_p;
  int32_T c1_j2;
  boolean_T c1_e_p;
  int32_T exitg1;
  (void)chartInstance;
  c1_k = 0;
  do {
    exitg1 = 0;
    if (c1_k + 1 < 4) {
      if (muDoubleScalarIsNaN(c1_b_x[c1_k])) {
        c1_d1 = rtNaN;
        exitg1 = 1;
      } else {
        c1_k++;
      }
    } else {
      c1_p = (c1_b_x[0] < c1_b_x[1]);
      if (c1_p) {
        c1_c_p = (c1_b_x[1] < c1_b_x[2]);
        if (c1_c_p) {
          c1_j2 = 1;
        } else {
          c1_e_p = (c1_b_x[0] < c1_b_x[2]);
          if (c1_e_p) {
            c1_j2 = 2;
          } else {
            c1_j2 = 0;
          }
        }
      } else {
        c1_b_p = (c1_b_x[0] < c1_b_x[2]);
        if (c1_b_p) {
          c1_j2 = 0;
        } else {
          c1_d_p = (c1_b_x[1] < c1_b_x[2]);
          if (c1_d_p) {
            c1_j2 = 2;
          } else {
            c1_j2 = 1;
          }
        }
      }

      c1_d1 = c1_b_x[c1_j2];
      exitg1 = 1;
    }
  } while (exitg1 == 0);

  return c1_d1;
}

static const mxArray *c1_g_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData;
  int32_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_mxArrayOutData = NULL;
  c1_u = *(int32_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 6, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static int32_T c1_h_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  int32_T c1_y;
  int32_T c1_i51;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_i51, 1, 6, 0U, 0, 0U, 0);
  c1_y = c1_i51;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_f_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_sfEvent;
  emlrtMsgIdentifier c1_thisId;
  int32_T c1_y;
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)chartInstanceVoid;
  c1_b_sfEvent = sf_mex_dup(c1_mxArrayInData);
  c1_thisId.fIdentifier = (const char *)c1_varName;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_y = c1_h_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_sfEvent),
    &c1_thisId);
  sf_mex_destroy(&c1_b_sfEvent);
  *(int32_T *)c1_outData = c1_y;
  sf_mex_destroy(&c1_mxArrayInData);
}

static uint8_T c1_i_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_b_is_active_c1_FLWSim, const char_T *c1_identifier)
{
  uint8_T c1_y;
  emlrtMsgIdentifier c1_thisId;
  c1_thisId.fIdentifier = (const char *)c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_y = c1_j_emlrt_marshallIn(chartInstance, sf_mex_dup
    (c1_b_is_active_c1_FLWSim), &c1_thisId);
  sf_mex_destroy(&c1_b_is_active_c1_FLWSim);
  return c1_y;
}

static uint8_T c1_j_emlrt_marshallIn(SFc1_FLWSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  uint8_T c1_y;
  uint8_T c1_u0;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_u0, 1, 3, 0U, 0, 0U, 0);
  c1_y = c1_u0;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void init_dsm_address_info(SFc1_FLWSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void init_simulink_io_address(SFc1_FLWSimInstanceStruct *chartInstance)
{
  chartInstance->c1_fEmlrtCtx = (void *)sfrtGetEmlrtCtx(chartInstance->S);
  chartInstance->c1_x = (real_T (*)[14])ssGetInputPortSignal_wrapper
    (chartInstance->S, 0);
  chartInstance->c1_GRF = (real_T (*)[6])ssGetOutputPortSignal_wrapper
    (chartInstance->S, 1);
  chartInstance->c1_pL = (real_T (*)[3])ssGetOutputPortSignal_wrapper
    (chartInstance->S, 2);
  chartInstance->c1_pR = (real_T (*)[3])ssGetOutputPortSignal_wrapper
    (chartInstance->S, 3);
}

/* SFunction Glue Code */
#ifdef utFree
#undef utFree
#endif

#ifdef utMalloc
#undef utMalloc
#endif

#ifdef __cplusplus

extern "C" void *utMalloc(size_t size);
extern "C" void utFree(void*);

#else

extern void *utMalloc(size_t size);
extern void utFree(void*);

#endif

void sf_c1_FLWSim_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(1082824881U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(1432476052U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(3239476306U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(109542644U);
}

mxArray* sf_c1_FLWSim_get_post_codegen_info(void);
mxArray *sf_c1_FLWSim_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs", "locals", "postCodegenInfo" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1, 1, sizeof
    (autoinheritanceFields)/sizeof(autoinheritanceFields[0]),
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateString("pLQfStlIiRCXjHKFpoZ6NE");
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,1,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(14);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxCreateDoubleMatrix(0,0,
                mxREAL));
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,3,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(6);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(3);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(3);
      mxSetField(mxData,2,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,2,"type",mxType);
    }

    mxSetField(mxData,2,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"locals",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  {
    mxArray* mxPostCodegenInfo = sf_c1_FLWSim_get_post_codegen_info();
    mxSetField(mxAutoinheritanceInfo,0,"postCodegenInfo",mxPostCodegenInfo);
  }

  return(mxAutoinheritanceInfo);
}

mxArray *sf_c1_FLWSim_third_party_uses_info(void)
{
  mxArray * mxcell3p = mxCreateCellMatrix(1,0);
  return(mxcell3p);
}

mxArray *sf_c1_FLWSim_jit_fallback_info(void)
{
  const char *infoFields[] = { "fallbackType", "fallbackReason",
    "hiddenFallbackType", "hiddenFallbackReason", "incompatibleSymbol" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 5, infoFields);
  mxArray *fallbackType = mxCreateString("late");
  mxArray *fallbackReason = mxCreateString("ir_function_calls");
  mxArray *hiddenFallbackType = mxCreateString("");
  mxArray *hiddenFallbackReason = mxCreateString("");
  mxArray *incompatibleSymbol = mxCreateString("p_LeftToe_src");
  mxSetField(mxInfo, 0, infoFields[0], fallbackType);
  mxSetField(mxInfo, 0, infoFields[1], fallbackReason);
  mxSetField(mxInfo, 0, infoFields[2], hiddenFallbackType);
  mxSetField(mxInfo, 0, infoFields[3], hiddenFallbackReason);
  mxSetField(mxInfo, 0, infoFields[4], incompatibleSymbol);
  return mxInfo;
}

mxArray *sf_c1_FLWSim_updateBuildInfo_args_info(void)
{
  mxArray *mxBIArgs = mxCreateCellMatrix(1,0);
  return mxBIArgs;
}

mxArray* sf_c1_FLWSim_get_post_codegen_info(void)
{
  const char* fieldNames[] = { "exportedFunctionsUsedByThisChart",
    "exportedFunctionsChecksum" };

  mwSize dims[2] = { 1, 1 };

  mxArray* mxPostCodegenInfo = mxCreateStructArray(2, dims, sizeof(fieldNames)/
    sizeof(fieldNames[0]), fieldNames);

  {
    mxArray* mxExportedFunctionsChecksum = mxCreateString("");
    mwSize exp_dims[2] = { 0, 1 };

    mxArray* mxExportedFunctionsUsedByThisChart = mxCreateCellArray(2, exp_dims);
    mxSetField(mxPostCodegenInfo, 0, "exportedFunctionsUsedByThisChart",
               mxExportedFunctionsUsedByThisChart);
    mxSetField(mxPostCodegenInfo, 0, "exportedFunctionsChecksum",
               mxExportedFunctionsChecksum);
  }

  return mxPostCodegenInfo;
}

static const mxArray *sf_get_sim_state_info_c1_FLWSim(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x4'type','srcId','name','auxInfo'{{M[1],M[5],T\"GRF\",},{M[1],M[6],T\"pL\",},{M[1],M[7],T\"pR\",},{M[8],M[0],T\"is_active_c1_FLWSim\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 4, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c1_FLWSim_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc1_FLWSimInstanceStruct *chartInstance = (SFc1_FLWSimInstanceStruct *)
      sf_get_chart_instance_ptr(S);
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (sfGlobalDebugInstanceStruct,
           _FLWSimMachineNumber_,
           1,
           1,
           1,
           0,
           4,
           0,
           0,
           0,
           0,
           4,
           &chartInstance->chartNumber,
           &chartInstance->instanceNumber,
           (void *)S);

        /* Each instance must initialize its own list of scripts */
        init_script_number_translation(_FLWSimMachineNumber_,
          chartInstance->chartNumber,chartInstance->instanceNumber);
        if (chartAlreadyPresent==0) {
          /* this is the first instance */
          sf_debug_set_chart_disable_implicit_casting
            (sfGlobalDebugInstanceStruct,_FLWSimMachineNumber_,
             chartInstance->chartNumber,1);
          sf_debug_set_chart_event_thresholds(sfGlobalDebugInstanceStruct,
            _FLWSimMachineNumber_,
            chartInstance->chartNumber,
            0,
            0,
            0);
          _SFD_SET_DATA_PROPS(0,1,1,0,"x");
          _SFD_SET_DATA_PROPS(1,2,0,1,"GRF");
          _SFD_SET_DATA_PROPS(2,2,0,1,"pL");
          _SFD_SET_DATA_PROPS(3,2,0,1,"pR");
          _SFD_STATE_INFO(0,0,2);
          _SFD_CH_SUBSTATE_COUNT(0);
          _SFD_CH_SUBSTATE_DECOMP(0);
        }

        _SFD_CV_INIT_CHART(0,0,0,0);

        {
          _SFD_CV_INIT_STATE(0,0,0,0,0,0,NULL,NULL);
        }

        _SFD_CV_INIT_TRANS(0,0,NULL,NULL,0,NULL);

        /* Initialization of MATLAB Function Model Coverage */
        _SFD_CV_INIT_EML(0,1,1,0,2,0,0,0,0,0,0,0);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,680);
        _SFD_CV_INIT_EML_IF(0,1,0,246,256,-1,382);
        _SFD_CV_INIT_EML_IF(0,1,1,384,394,-1,520);
        _SFD_CV_INIT_EML_RELATIONAL(0,1,0,249,256,-1,2);
        _SFD_CV_INIT_EML_RELATIONAL(0,1,1,387,394,-1,2);
        _SFD_CV_INIT_SCRIPT(0,1,0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(0,0,"p_LeftToe",0,-1,331);
        _SFD_CV_INIT_SCRIPT_IF(0,0,41,66,112,327);
        _SFD_CV_INIT_SCRIPT(1,1,0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(1,0,"p_RightToe",0,-1,335);
        _SFD_CV_INIT_SCRIPT_IF(1,0,42,67,114,331);
        _SFD_CV_INIT_SCRIPT(2,1,0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(2,0,"Jp_LeftToe",0,-1,335);
        _SFD_CV_INIT_SCRIPT_IF(2,0,42,67,114,331);
        _SFD_CV_INIT_SCRIPT(3,1,0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(3,0,"Jp_RightToe",0,-1,339);
        _SFD_CV_INIT_SCRIPT_IF(3,0,43,68,116,335);

        {
          unsigned int dimVector[1];
          dimVector[0]= 14U;
          _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_c_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 6U;
          _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_b_sf_marshallOut,(MexInFcnForType)
            c1_b_sf_marshallIn);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 3U;
          _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)
            c1_sf_marshallIn);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 3U;
          _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)
            c1_sf_marshallIn);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration(sfGlobalDebugInstanceStruct,
        _FLWSimMachineNumber_,chartInstance->chartNumber,
        chartInstance->instanceNumber);
    }
  }
}

static void chart_debug_initialize_data_addresses(SimStruct *S)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc1_FLWSimInstanceStruct *chartInstance = (SFc1_FLWSimInstanceStruct *)
      sf_get_chart_instance_ptr(S);
    if (ssIsFirstInitCond(S)) {
      /* do this only if simulation is starting and after we know the addresses of all data */
      {
        _SFD_SET_DATA_VALUE_PTR(0U, (void *)chartInstance->c1_x);
        _SFD_SET_DATA_VALUE_PTR(1U, (void *)chartInstance->c1_GRF);
        _SFD_SET_DATA_VALUE_PTR(2U, (void *)chartInstance->c1_pL);
        _SFD_SET_DATA_VALUE_PTR(3U, (void *)chartInstance->c1_pR);
      }
    }
  }
}

static const char* sf_get_instance_specialization(void)
{
  return "s61EKGexVDQKXzSZIqJQ9ZD";
}

static void sf_opaque_initialize_c1_FLWSim(void *chartInstanceVar)
{
  chart_debug_initialization(((SFc1_FLWSimInstanceStruct*) chartInstanceVar)->S,
    0);
  initialize_params_c1_FLWSim((SFc1_FLWSimInstanceStruct*) chartInstanceVar);
  initialize_c1_FLWSim((SFc1_FLWSimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c1_FLWSim(void *chartInstanceVar)
{
  enable_c1_FLWSim((SFc1_FLWSimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_disable_c1_FLWSim(void *chartInstanceVar)
{
  disable_c1_FLWSim((SFc1_FLWSimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_gateway_c1_FLWSim(void *chartInstanceVar)
{
  sf_gateway_c1_FLWSim((SFc1_FLWSimInstanceStruct*) chartInstanceVar);
}

static const mxArray* sf_opaque_get_sim_state_c1_FLWSim(SimStruct* S)
{
  return get_sim_state_c1_FLWSim((SFc1_FLWSimInstanceStruct *)
    sf_get_chart_instance_ptr(S));     /* raw sim ctx */
}

static void sf_opaque_set_sim_state_c1_FLWSim(SimStruct* S, const mxArray *st)
{
  set_sim_state_c1_FLWSim((SFc1_FLWSimInstanceStruct*)sf_get_chart_instance_ptr
    (S), st);
}

static void sf_opaque_terminate_c1_FLWSim(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc1_FLWSimInstanceStruct*) chartInstanceVar)->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
      unload_FLWSim_optimization_info();
    }

    finalize_c1_FLWSim((SFc1_FLWSimInstanceStruct*) chartInstanceVar);
    utFree(chartInstanceVar);
    if (ssGetUserData(S)!= NULL) {
      sf_free_ChartRunTimeInfo(S);
    }

    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  initSimStructsc1_FLWSim((SFc1_FLWSimInstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c1_FLWSim(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c1_FLWSim((SFc1_FLWSimInstanceStruct*)
      sf_get_chart_instance_ptr(S));
  }
}

static void mdlSetWorkWidths_c1_FLWSim(SimStruct *S)
{
  /* Set overwritable ports for inplace optimization */
  ssSetInputPortDirectFeedThrough(S, 0, 1);
  ssSetStatesModifiedOnlyInUpdate(S, 1);
  ssSetBlockIsPurelyCombinatorial_wrapper(S, 1);
  ssMdlUpdateIsEmpty(S, 1);
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    mxArray *infoStruct = load_FLWSim_optimization_info(sim_mode_is_rtw_gen(S),
      sim_mode_is_modelref_sim(S), sim_mode_is_external(S));
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(sf_get_instance_specialization(),infoStruct,1);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,1);
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop
      (sf_get_instance_specialization(),infoStruct,1,
       "gatewayCannotBeInlinedMultipleTimes"));
    sf_set_chart_accesses_machine_info(S, sf_get_instance_specialization(),
      infoStruct, 1);
    sf_update_buildInfo(S, sf_get_instance_specialization(),infoStruct,1);
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,sf_get_instance_specialization(),
        infoStruct,1,1);
      sf_mark_chart_reusable_outputs(S,sf_get_instance_specialization(),
        infoStruct,1,3);
    }

    {
      unsigned int outPortIdx;
      for (outPortIdx=1; outPortIdx<=3; ++outPortIdx) {
        ssSetOutputPortOptimizeInIR(S, outPortIdx, 1U);
      }
    }

    {
      unsigned int inPortIdx;
      for (inPortIdx=0; inPortIdx < 1; ++inPortIdx) {
        ssSetInputPortOptimizeInIR(S, inPortIdx, 1U);
      }
    }

    sf_set_rtw_dwork_info(S,sf_get_instance_specialization(),infoStruct,1);
    sf_register_codegen_names_for_scoped_functions_defined_by_chart(S);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(3150598780U));
  ssSetChecksum1(S,(2787085115U));
  ssSetChecksum2(S,(3620686937U));
  ssSetChecksum3(S,(4136320985U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
  ssSetStateSemanticsClassicAndSynchronous(S, true);
  ssSupportsMultipleExecInstances(S,1);
}

static void mdlRTW_c1_FLWSim(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c1_FLWSim(SimStruct *S)
{
  SFc1_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FLWSimInstanceStruct *)utMalloc(sizeof
    (SFc1_FLWSimInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  memset(chartInstance, 0, sizeof(SFc1_FLWSimInstanceStruct));
  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway = sf_opaque_gateway_c1_FLWSim;
  chartInstance->chartInfo.initializeChart = sf_opaque_initialize_c1_FLWSim;
  chartInstance->chartInfo.terminateChart = sf_opaque_terminate_c1_FLWSim;
  chartInstance->chartInfo.enableChart = sf_opaque_enable_c1_FLWSim;
  chartInstance->chartInfo.disableChart = sf_opaque_disable_c1_FLWSim;
  chartInstance->chartInfo.getSimState = sf_opaque_get_sim_state_c1_FLWSim;
  chartInstance->chartInfo.setSimState = sf_opaque_set_sim_state_c1_FLWSim;
  chartInstance->chartInfo.getSimStateInfo = sf_get_sim_state_info_c1_FLWSim;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c1_FLWSim;
  chartInstance->chartInfo.mdlStart = mdlStart_c1_FLWSim;
  chartInstance->chartInfo.mdlSetWorkWidths = mdlSetWorkWidths_c1_FLWSim;
  chartInstance->chartInfo.callGetHoverDataForMsg = NULL;
  chartInstance->chartInfo.extModeExec = NULL;
  chartInstance->chartInfo.restoreLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.restoreBeforeLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.storeCurrentConfiguration = NULL;
  chartInstance->chartInfo.callAtomicSubchartUserFcn = NULL;
  chartInstance->chartInfo.callAtomicSubchartAutoFcn = NULL;
  chartInstance->chartInfo.debugInstance = sfGlobalDebugInstanceStruct;
  chartInstance->S = S;
  sf_init_ChartRunTimeInfo(S, &(chartInstance->chartInfo), false, 0);
  init_dsm_address_info(chartInstance);
  init_simulink_io_address(chartInstance);
  if (!sim_mode_is_rtw_gen(S)) {
  }

  chart_debug_initialization(S,1);
  mdl_start_c1_FLWSim(chartInstance);
}

void c1_FLWSim_method_dispatcher(SimStruct *S, int_T method, void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c1_FLWSim(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c1_FLWSim(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c1_FLWSim(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c1_FLWSim_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}

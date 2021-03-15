/* Include files */

#include "FLWSim_sfun.h"
#include "c2_FLWSim.h"
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
static const char * c2_debug_family_names[16] = { "q", "dq", "M", "C", "G", "B",
  "JgL", "JgR", "Jg", "ddq", "nargin", "nargout", "x", "u", "GRF", "dx" };

static const char * c2_b_debug_family_names[4] = { "nargin", "nargout", "var1",
  "output1" };

static const char * c2_c_debug_family_names[5] = { "nargin", "nargout", "var1",
  "var2", "output1" };

static const char * c2_d_debug_family_names[4] = { "nargin", "nargout", "var1",
  "output1" };

static const char * c2_e_debug_family_names[4] = { "nargin", "nargout", "var1",
  "output1" };

static const char * c2_f_debug_family_names[4] = { "nargin", "nargout", "var1",
  "output1" };

/* Function Declarations */
static void initialize_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance);
static void initialize_params_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance);
static void enable_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance);
static void disable_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance);
static void c2_update_debugger_state_c2_FLWSim(SFc2_FLWSimInstanceStruct
  *chartInstance);
static const mxArray *get_sim_state_c2_FLWSim(SFc2_FLWSimInstanceStruct
  *chartInstance);
static void set_sim_state_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_st);
static void finalize_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance);
static void sf_gateway_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance);
static void mdl_start_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance);
static void initSimStructsc2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber, uint32_T c2_instanceNumber);
static const mxArray *c2_sf_marshallOut(void *chartInstanceVoid, void *c2_inData);
static void c2_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance, const
  mxArray *c2_b_dx, const char_T *c2_identifier, real_T c2_y[14]);
static void c2_b_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[14]);
static void c2_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_b_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static const mxArray *c2_c_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static const mxArray *c2_d_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static real_T c2_c_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_e_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static void c2_d_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[7]);
static void c2_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_f_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static void c2_e_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[42]);
static void c2_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_g_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static void c2_f_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[21]);
static void c2_e_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_h_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static const mxArray *c2_i_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static void c2_g_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[49]);
static void c2_f_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static void c2_invNxN(SFc2_FLWSimInstanceStruct *chartInstance, real_T c2_b_x[49],
                      real_T c2_y[49]);
static void c2_check_forloop_overflow_error(SFc2_FLWSimInstanceStruct
  *chartInstance, boolean_T c2_overflow);
static real_T c2_norm(SFc2_FLWSimInstanceStruct *chartInstance, real_T c2_b_x[49]);
static void c2_warning(SFc2_FLWSimInstanceStruct *chartInstance);
static void c2_b_warning(SFc2_FLWSimInstanceStruct *chartInstance, char_T
  c2_varargin_1[14]);
static void c2_h_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_sprintf, const char_T *c2_identifier, char_T c2_y[14]);
static void c2_i_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, char_T c2_y[14]);
static const mxArray *c2_j_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static int32_T c2_j_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_g_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static uint8_T c2_k_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_is_active_c2_FLWSim, const char_T *c2_identifier);
static uint8_T c2_l_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId);
static void init_dsm_address_info(SFc2_FLWSimInstanceStruct *chartInstance);
static void init_simulink_io_address(SFc2_FLWSimInstanceStruct *chartInstance);

/* Function Definitions */
static void initialize_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance)
{
  if (sf_is_first_init_cond(chartInstance->S)) {
    initSimStructsc2_FLWSim(chartInstance);
    chart_debug_initialize_data_addresses(chartInstance->S);
  }

  chartInstance->c2_sfEvent = CALL_EVENT;
  _sfTime_ = sf_get_time(chartInstance->S);
  chartInstance->c2_is_active_c2_FLWSim = 0U;
}

static void initialize_params_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void enable_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void disable_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void c2_update_debugger_state_c2_FLWSim(SFc2_FLWSimInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static const mxArray *get_sim_state_c2_FLWSim(SFc2_FLWSimInstanceStruct
  *chartInstance)
{
  const mxArray *c2_st;
  const mxArray *c2_y = NULL;
  const mxArray *c2_b_y = NULL;
  uint8_T c2_hoistedGlobal;
  const mxArray *c2_c_y = NULL;
  c2_st = NULL;
  c2_st = NULL;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_createcellmatrix(2, 1), false);
  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", *chartInstance->c2_dx, 0, 0U, 1U, 0U,
    1, 14), false);
  sf_mex_setcell(c2_y, 0, c2_b_y);
  c2_hoistedGlobal = chartInstance->c2_is_active_c2_FLWSim;
  c2_c_y = NULL;
  sf_mex_assign(&c2_c_y, sf_mex_create("y", &c2_hoistedGlobal, 3, 0U, 0U, 0U, 0),
                false);
  sf_mex_setcell(c2_y, 1, c2_c_y);
  sf_mex_assign(&c2_st, c2_y, false);
  return c2_st;
}

static void set_sim_state_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_st)
{
  const mxArray *c2_b_u;
  real_T c2_dv0[14];
  int32_T c2_i0;
  chartInstance->c2_doneDoubleBufferReInit = true;
  c2_b_u = sf_mex_dup(c2_st);
  c2_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_b_u, 0)), "dx",
                      c2_dv0);
  for (c2_i0 = 0; c2_i0 < 14; c2_i0++) {
    (*chartInstance->c2_dx)[c2_i0] = c2_dv0[c2_i0];
  }

  chartInstance->c2_is_active_c2_FLWSim = c2_k_emlrt_marshallIn(chartInstance,
    sf_mex_dup(sf_mex_getcell(c2_b_u, 1)), "is_active_c2_FLWSim");
  sf_mex_destroy(&c2_b_u);
  c2_update_debugger_state_c2_FLWSim(chartInstance);
  sf_mex_destroy(&c2_st);
}

static void finalize_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void sf_gateway_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance)
{
  int32_T c2_i1;
  int32_T c2_i2;
  int32_T c2_i3;
  int32_T c2_i4;
  int32_T c2_i5;
  real_T c2_b_x[14];
  int32_T c2_i6;
  real_T c2_b_u[4];
  uint32_T c2_debug_family_var_map[16];
  real_T c2_b_GRF[6];
  real_T c2_q[7];
  real_T c2_dq[7];
  real_T c2_M[49];
  real_T c2_C[7];
  real_T c2_G[7];
  real_T c2_B[28];
  real_T c2_JgL[21];
  real_T c2_JgR[21];
  real_T c2_Jg[42];
  real_T c2_ddq[7];
  real_T c2_nargin = 3.0;
  real_T c2_nargout = 1.0;
  real_T c2_b_dx[14];
  int32_T c2_i7;
  int32_T c2_i8;
  int32_T c2_i9;
  int32_T c2_i10;
  uint32_T c2_b_debug_family_var_map[4];
  real_T c2_var1[7];
  real_T c2_b_nargin = 1.0;
  real_T c2_b_nargout = 1.0;
  int32_T c2_i11;
  int32_T c2_i12;
  int32_T c2_i13;
  real_T c2_b_var1[7];
  uint32_T c2_c_debug_family_var_map[5];
  real_T c2_var2[7];
  real_T c2_c_nargin = 2.0;
  real_T c2_c_nargout = 1.0;
  int32_T c2_i14;
  int32_T c2_i15;
  real_T c2_c_var1[7];
  real_T c2_d_nargin = 1.0;
  real_T c2_d_nargout = 1.0;
  int32_T c2_i16;
  int32_T c2_i17;
  static real_T c2_a[28] = { 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 1.0 };

  int32_T c2_i18;
  real_T c2_d_var1[7];
  real_T c2_e_nargin = 1.0;
  real_T c2_e_nargout = 1.0;
  int32_T c2_i19;
  int32_T c2_i20;
  real_T c2_e_var1[7];
  real_T c2_f_nargin = 1.0;
  real_T c2_f_nargout = 1.0;
  int32_T c2_i21;
  int32_T c2_i22;
  int32_T c2_i23;
  int32_T c2_i24;
  int32_T c2_i25;
  int32_T c2_i26;
  int32_T c2_i27;
  int32_T c2_i28;
  int32_T c2_i29;
  int32_T c2_i30;
  int32_T c2_i31;
  real_T c2_b_a[49];
  real_T c2_c_a[49];
  real_T c2_c[49];
  real_T c2_n1x;
  int32_T c2_i32;
  real_T c2_n1xinv;
  real_T c2_b_c[49];
  real_T c2_rc;
  real_T c2_c_x;
  int32_T c2_i33;
  const mxArray *c2_y = NULL;
  static char_T c2_rfmt[6] = { '%', '1', '4', '.', '6', 'e' };

  const mxArray *c2_b_y = NULL;
  int32_T c2_i34;
  real_T c2_b[4];
  int32_T c2_i35;
  char_T c2_str[14];
  int32_T c2_i36;
  int32_T c2_i37;
  int32_T c2_i38;
  int32_T c2_i39;
  real_T c2_b_b[6];
  real_T c2_d_a[42];
  int32_T c2_i40;
  real_T c2_d0;
  int32_T c2_i41;
  int32_T c2_i42;
  int32_T c2_i43;
  real_T c2_e_a[7];
  int32_T c2_i44;
  int32_T c2_i45;
  real_T c2_b_C[7];
  int32_T c2_i46;
  real_T c2_c_b[7];
  int32_T c2_i47;
  int32_T c2_i48;
  int32_T c2_i49;
  int32_T c2_i50;
  int32_T c2_i51;
  int32_T c2_i52;
  int32_T c2_i53;
  _SFD_SYMBOL_SCOPE_PUSH(0U, 0U);
  _sfTime_ = sf_get_time(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 1U, chartInstance->c2_sfEvent);
  for (c2_i1 = 0; c2_i1 < 6; c2_i1++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c2_GRF)[c2_i1], 2U);
  }

  for (c2_i2 = 0; c2_i2 < 4; c2_i2++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c2_u)[c2_i2], 1U);
  }

  for (c2_i3 = 0; c2_i3 < 14; c2_i3++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c2_x)[c2_i3], 0U);
  }

  chartInstance->c2_sfEvent = CALL_EVENT;
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 1U, chartInstance->c2_sfEvent);
  for (c2_i4 = 0; c2_i4 < 14; c2_i4++) {
    c2_b_x[c2_i4] = (*chartInstance->c2_x)[c2_i4];
  }

  for (c2_i5 = 0; c2_i5 < 4; c2_i5++) {
    c2_b_u[c2_i5] = (*chartInstance->c2_u)[c2_i5];
  }

  for (c2_i6 = 0; c2_i6 < 6; c2_i6++) {
    c2_b_GRF[c2_i6] = (*chartInstance->c2_GRF)[c2_i6];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 16U, 16U, c2_debug_family_names,
    c2_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_q, 0U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_dq, 1U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_M, 2U, c2_i_sf_marshallOut,
    c2_f_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_C, 3U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_G, 4U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(c2_B, 5U, c2_h_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_JgL, 6U, c2_g_sf_marshallOut,
    c2_e_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_JgR, 7U, c2_g_sf_marshallOut,
    c2_e_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_Jg, 8U, c2_f_sf_marshallOut,
    c2_d_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_ddq, 9U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_nargin, 10U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_nargout, 11U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(c2_b_x, 12U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(c2_b_u, 13U, c2_c_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(c2_b_GRF, 14U, c2_b_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_b_dx, 15U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  CV_EML_FCN(0, 0);
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 2);
  for (c2_i7 = 0; c2_i7 < 14; c2_i7++) {
    c2_b_dx[c2_i7] = 0.0;
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 3);
  for (c2_i8 = 0; c2_i8 < 7; c2_i8++) {
    c2_q[c2_i8] = c2_b_x[c2_i8];
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 4);
  for (c2_i9 = 0; c2_i9 < 7; c2_i9++) {
    c2_dq[c2_i9] = c2_b_x[c2_i9 + 7];
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 6);
  for (c2_i10 = 0; c2_i10 < 7; c2_i10++) {
    c2_var1[c2_i10] = c2_q[c2_i10];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 4U, 4U, c2_b_debug_family_names,
    c2_b_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_b_nargin, 0U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_b_nargout, 1U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_var1, 2U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_M, 3U, c2_i_sf_marshallOut,
    c2_f_sf_marshallIn);
  CV_SCRIPT_FCN(0, 0);
  _SFD_SCRIPT_CALL(0U, chartInstance->c2_sfEvent, 2);
  CV_SCRIPT_IF(0, 0, false);
  _SFD_SCRIPT_CALL(0U, chartInstance->c2_sfEvent, 5);
  _SFD_SCRIPT_CALL(0U, chartInstance->c2_sfEvent, 7);
  for (c2_i11 = 0; c2_i11 < 49; c2_i11++) {
    c2_M[c2_i11] = 0.0;
  }

  _SFD_SCRIPT_CALL(0U, chartInstance->c2_sfEvent, 10);
  InertiaMatrix_src(c2_M, c2_var1);
  _SFD_SCRIPT_CALL(0U, chartInstance->c2_sfEvent, -10);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 7);
  for (c2_i12 = 0; c2_i12 < 7; c2_i12++) {
    c2_b_var1[c2_i12] = c2_q[c2_i12];
  }

  for (c2_i13 = 0; c2_i13 < 7; c2_i13++) {
    c2_var2[c2_i13] = c2_dq[c2_i13];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 5U, 5U, c2_c_debug_family_names,
    c2_c_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_c_nargin, 0U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_c_nargout, 1U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_b_var1, 2U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_var2, 3U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_C, 4U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  CV_SCRIPT_FCN(1, 0);
  _SFD_SCRIPT_CALL(1U, chartInstance->c2_sfEvent, 2);
  CV_SCRIPT_IF(1, 0, false);
  _SFD_SCRIPT_CALL(1U, chartInstance->c2_sfEvent, 5);
  _SFD_SCRIPT_CALL(1U, chartInstance->c2_sfEvent, 7);
  for (c2_i14 = 0; c2_i14 < 7; c2_i14++) {
    c2_C[c2_i14] = 0.0;
  }

  _SFD_SCRIPT_CALL(1U, chartInstance->c2_sfEvent, 10);
  CoriolisTerm_src(c2_C, c2_b_var1, c2_var2);
  _SFD_SCRIPT_CALL(1U, chartInstance->c2_sfEvent, -10);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 8);
  for (c2_i15 = 0; c2_i15 < 7; c2_i15++) {
    c2_c_var1[c2_i15] = c2_q[c2_i15];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 4U, 4U, c2_d_debug_family_names,
    c2_b_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_d_nargin, 0U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_d_nargout, 1U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_c_var1, 2U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_G, 3U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  CV_SCRIPT_FCN(2, 0);
  _SFD_SCRIPT_CALL(2U, chartInstance->c2_sfEvent, 2);
  CV_SCRIPT_IF(2, 0, false);
  _SFD_SCRIPT_CALL(2U, chartInstance->c2_sfEvent, 5);
  _SFD_SCRIPT_CALL(2U, chartInstance->c2_sfEvent, 7);
  for (c2_i16 = 0; c2_i16 < 7; c2_i16++) {
    c2_G[c2_i16] = 0.0;
  }

  _SFD_SCRIPT_CALL(2U, chartInstance->c2_sfEvent, 10);
  GravityVector_src(c2_G, c2_c_var1);
  _SFD_SCRIPT_CALL(2U, chartInstance->c2_sfEvent, -10);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 9);
  for (c2_i17 = 0; c2_i17 < 28; c2_i17++) {
    c2_B[c2_i17] = c2_a[c2_i17];
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 11);
  for (c2_i18 = 0; c2_i18 < 7; c2_i18++) {
    c2_d_var1[c2_i18] = c2_q[c2_i18];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 4U, 4U, c2_e_debug_family_names,
    c2_b_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_e_nargin, 0U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_e_nargout, 1U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_d_var1, 2U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_JgL, 3U, c2_g_sf_marshallOut,
    c2_e_sf_marshallIn);
  CV_SCRIPT_FCN(3, 0);
  _SFD_SCRIPT_CALL(3U, chartInstance->c2_sfEvent, 2);
  CV_SCRIPT_IF(3, 0, false);
  _SFD_SCRIPT_CALL(3U, chartInstance->c2_sfEvent, 5);
  _SFD_SCRIPT_CALL(3U, chartInstance->c2_sfEvent, 7);
  for (c2_i19 = 0; c2_i19 < 21; c2_i19++) {
    c2_JgL[c2_i19] = 0.0;
  }

  _SFD_SCRIPT_CALL(3U, chartInstance->c2_sfEvent, 10);
  Jp_LeftToe_src(c2_JgL, c2_d_var1);
  _SFD_SCRIPT_CALL(3U, chartInstance->c2_sfEvent, -10);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 12);
  for (c2_i20 = 0; c2_i20 < 7; c2_i20++) {
    c2_e_var1[c2_i20] = c2_q[c2_i20];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 4U, 4U, c2_f_debug_family_names,
    c2_b_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_f_nargin, 0U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_f_nargout, 1U, c2_d_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_e_var1, 2U, c2_e_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_JgR, 3U, c2_g_sf_marshallOut,
    c2_e_sf_marshallIn);
  CV_SCRIPT_FCN(4, 0);
  _SFD_SCRIPT_CALL(4U, chartInstance->c2_sfEvent, 2);
  CV_SCRIPT_IF(4, 0, false);
  _SFD_SCRIPT_CALL(4U, chartInstance->c2_sfEvent, 5);
  _SFD_SCRIPT_CALL(4U, chartInstance->c2_sfEvent, 7);
  for (c2_i21 = 0; c2_i21 < 21; c2_i21++) {
    c2_JgR[c2_i21] = 0.0;
  }

  _SFD_SCRIPT_CALL(4U, chartInstance->c2_sfEvent, 10);
  Jp_RightToe_src(c2_JgR, c2_e_var1);
  _SFD_SCRIPT_CALL(4U, chartInstance->c2_sfEvent, -10);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 13);
  c2_i22 = 0;
  c2_i23 = 0;
  for (c2_i24 = 0; c2_i24 < 7; c2_i24++) {
    for (c2_i26 = 0; c2_i26 < 3; c2_i26++) {
      c2_Jg[c2_i26 + c2_i22] = c2_JgL[c2_i26 + c2_i23];
    }

    c2_i22 += 6;
    c2_i23 += 3;
  }

  c2_i25 = 0;
  c2_i27 = 0;
  for (c2_i28 = 0; c2_i28 < 7; c2_i28++) {
    for (c2_i29 = 0; c2_i29 < 3; c2_i29++) {
      c2_Jg[(c2_i29 + c2_i25) + 3] = c2_JgR[c2_i29 + c2_i27];
    }

    c2_i25 += 6;
    c2_i27 += 3;
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 15);
  for (c2_i30 = 0; c2_i30 < 49; c2_i30++) {
    c2_b_a[c2_i30] = c2_M[c2_i30];
  }

  for (c2_i31 = 0; c2_i31 < 49; c2_i31++) {
    c2_c_a[c2_i31] = c2_b_a[c2_i31];
  }

  c2_invNxN(chartInstance, c2_c_a, c2_c);
  c2_n1x = c2_norm(chartInstance, c2_b_a);
  for (c2_i32 = 0; c2_i32 < 49; c2_i32++) {
    c2_b_c[c2_i32] = c2_c[c2_i32];
  }

  c2_n1xinv = c2_norm(chartInstance, c2_b_c);
  c2_rc = 1.0 / (c2_n1x * c2_n1xinv);
  if ((c2_n1x == 0.0) || (c2_n1xinv == 0.0) || (c2_rc == 0.0)) {
    c2_warning(chartInstance);
  } else {
    if (muDoubleScalarIsNaN(c2_rc) || (c2_rc < 2.2204460492503131E-16)) {
      c2_c_x = c2_rc;
      c2_y = NULL;
      sf_mex_assign(&c2_y, sf_mex_create("y", c2_rfmt, 10, 0U, 1U, 0U, 2, 1, 6),
                    false);
      c2_b_y = NULL;
      sf_mex_assign(&c2_b_y, sf_mex_create("y", &c2_c_x, 0, 0U, 0U, 0U, 0),
                    false);
      c2_h_emlrt_marshallIn(chartInstance, sf_mex_call_debug
                            (sfGlobalDebugInstanceStruct, "sprintf", 1U, 2U, 14,
        c2_y, 14, c2_b_y), "sprintf", c2_str);
      c2_b_warning(chartInstance, c2_str);
    }
  }

  for (c2_i33 = 0; c2_i33 < 4; c2_i33++) {
    c2_b[c2_i33] = c2_b_u[c2_i33];
  }

  c2_i34 = 0;
  for (c2_i35 = 0; c2_i35 < 6; c2_i35++) {
    c2_i37 = 0;
    for (c2_i38 = 0; c2_i38 < 7; c2_i38++) {
      c2_d_a[c2_i38 + c2_i34] = c2_Jg[c2_i37 + c2_i35];
      c2_i37 += 6;
    }

    c2_i34 += 7;
  }

  for (c2_i36 = 0; c2_i36 < 6; c2_i36++) {
    c2_b_b[c2_i36] = c2_b_GRF[c2_i36];
  }

  for (c2_i39 = 0; c2_i39 < 7; c2_i39++) {
    c2_d0 = 0.0;
    c2_i41 = 0;
    for (c2_i42 = 0; c2_i42 < 4; c2_i42++) {
      c2_d0 += c2_a[c2_i41 + c2_i39] * c2_b[c2_i42];
      c2_i41 += 7;
    }

    c2_b_C[c2_i39] = (-c2_C[c2_i39] - c2_G[c2_i39]) + c2_d0;
  }

  for (c2_i40 = 0; c2_i40 < 7; c2_i40++) {
    c2_e_a[c2_i40] = 0.0;
    c2_i44 = 0;
    for (c2_i45 = 0; c2_i45 < 6; c2_i45++) {
      c2_e_a[c2_i40] += c2_d_a[c2_i44 + c2_i40] * c2_b_b[c2_i45];
      c2_i44 += 7;
    }
  }

  for (c2_i43 = 0; c2_i43 < 7; c2_i43++) {
    c2_c_b[c2_i43] = c2_b_C[c2_i43] + c2_e_a[c2_i43];
  }

  for (c2_i46 = 0; c2_i46 < 7; c2_i46++) {
    c2_ddq[c2_i46] = 0.0;
  }

  for (c2_i47 = 0; c2_i47 < 7; c2_i47++) {
    c2_ddq[c2_i47] = 0.0;
    c2_i49 = 0;
    for (c2_i50 = 0; c2_i50 < 7; c2_i50++) {
      c2_ddq[c2_i47] += c2_c[c2_i49 + c2_i47] * c2_c_b[c2_i50];
      c2_i49 += 7;
    }
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 17);
  for (c2_i48 = 0; c2_i48 < 7; c2_i48++) {
    c2_b_dx[c2_i48] = c2_dq[c2_i48];
  }

  for (c2_i51 = 0; c2_i51 < 7; c2_i51++) {
    c2_b_dx[c2_i51 + 7] = c2_ddq[c2_i51];
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, -17);
  _SFD_SYMBOL_SCOPE_POP();
  for (c2_i52 = 0; c2_i52 < 14; c2_i52++) {
    (*chartInstance->c2_dx)[c2_i52] = c2_b_dx[c2_i52];
  }

  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 1U, chartInstance->c2_sfEvent);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_CHECK_FOR_STATE_INCONSISTENCY(_FLWSimMachineNumber_,
    chartInstance->chartNumber, chartInstance->instanceNumber);
  for (c2_i53 = 0; c2_i53 < 14; c2_i53++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c2_dx)[c2_i53], 3U);
  }
}

static void mdl_start_c2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance)
{
  sim_mode_is_external(chartInstance->S);
}

static void initSimStructsc2_FLWSim(SFc2_FLWSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber, uint32_T c2_instanceNumber)
{
  (void)(c2_machineNumber);
  (void)(c2_chartNumber);
  (void)(c2_instanceNumber);
  _SFD_SCRIPT_TRANSLATION(c2_chartNumber, c2_instanceNumber, 0U,
    sf_debug_get_script_id(
    "C:\\Users\\mungam\\Documents\\GitHub\\Fault_Detection_Diagnostics\\FiveLinkWalker_Yukai\\Simulation\\Model\\dyn\\m\\InertiaMatrix.m"));
  _SFD_SCRIPT_TRANSLATION(c2_chartNumber, c2_instanceNumber, 1U,
    sf_debug_get_script_id(
    "C:\\Users\\mungam\\Documents\\GitHub\\Fault_Detection_Diagnostics\\FiveLinkWalker_Yukai\\Simulation\\Model\\dyn\\m\\CoriolisTerm.m"));
  _SFD_SCRIPT_TRANSLATION(c2_chartNumber, c2_instanceNumber, 2U,
    sf_debug_get_script_id(
    "C:\\Users\\mungam\\Documents\\GitHub\\Fault_Detection_Diagnostics\\FiveLinkWalker_Yukai\\Simulation\\Model\\dyn\\m\\GravityVector.m"));
  _SFD_SCRIPT_TRANSLATION(c2_chartNumber, c2_instanceNumber, 3U,
    sf_debug_get_script_id(
    "C:\\Users\\mungam\\Documents\\GitHub\\Fault_Detection_Diagnostics\\FiveLinkWalker_Yukai\\Simulation\\Model\\kin\\m\\Jp_LeftToe.m"));
  _SFD_SCRIPT_TRANSLATION(c2_chartNumber, c2_instanceNumber, 4U,
    sf_debug_get_script_id(
    "C:\\Users\\mungam\\Documents\\GitHub\\Fault_Detection_Diagnostics\\FiveLinkWalker_Yukai\\Simulation\\Model\\kin\\m\\Jp_RightToe.m"));
}

static const mxArray *c2_sf_marshallOut(void *chartInstanceVoid, void *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  int32_T c2_i54;
  const mxArray *c2_y = NULL;
  real_T c2_b_u[14];
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  for (c2_i54 = 0; c2_i54 < 14; c2_i54++) {
    c2_b_u[c2_i54] = (*(real_T (*)[14])c2_inData)[c2_i54];
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 1, 14), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static void c2_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance, const
  mxArray *c2_b_dx, const char_T *c2_identifier, real_T c2_y[14])
{
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = (const char *)c2_identifier;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_dx), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_b_dx);
}

static void c2_b_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[14])
{
  real_T c2_dv1[14];
  int32_T c2_i55;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_b_u), c2_dv1, 1, 0, 0U, 1, 0U, 1, 14);
  for (c2_i55 = 0; c2_i55 < 14; c2_i55++) {
    c2_y[c2_i55] = c2_dv1[c2_i55];
  }

  sf_mex_destroy(&c2_b_u);
}

static void c2_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_b_dx;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y[14];
  int32_T c2_i56;
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_b_dx = sf_mex_dup(c2_mxArrayInData);
  c2_thisId.fIdentifier = (const char *)c2_varName;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_dx), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_b_dx);
  for (c2_i56 = 0; c2_i56 < 14; c2_i56++) {
    (*(real_T (*)[14])c2_outData)[c2_i56] = c2_y[c2_i56];
  }

  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_b_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  int32_T c2_i57;
  const mxArray *c2_y = NULL;
  real_T c2_b_u[6];
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  for (c2_i57 = 0; c2_i57 < 6; c2_i57++) {
    c2_b_u[c2_i57] = (*(real_T (*)[6])c2_inData)[c2_i57];
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 1, 6), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static const mxArray *c2_c_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  int32_T c2_i58;
  const mxArray *c2_y = NULL;
  real_T c2_b_u[4];
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  for (c2_i58 = 0; c2_i58 < 4; c2_i58++) {
    c2_b_u[c2_i58] = (*(real_T (*)[4])c2_inData)[c2_i58];
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 1, 4), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static const mxArray *c2_d_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  real_T c2_b_u;
  const mxArray *c2_y = NULL;
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  c2_b_u = *(real_T *)c2_inData;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_b_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static real_T c2_c_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId)
{
  real_T c2_y;
  real_T c2_d1;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_b_u), &c2_d1, 1, 0, 0U, 0, 0U, 0);
  c2_y = c2_d1;
  sf_mex_destroy(&c2_b_u);
  return c2_y;
}

static void c2_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_nargout;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y;
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_nargout = sf_mex_dup(c2_mxArrayInData);
  c2_thisId.fIdentifier = (const char *)c2_varName;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_y = c2_c_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_nargout), &c2_thisId);
  sf_mex_destroy(&c2_nargout);
  *(real_T *)c2_outData = c2_y;
  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_e_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  int32_T c2_i59;
  const mxArray *c2_y = NULL;
  real_T c2_b_u[7];
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  for (c2_i59 = 0; c2_i59 < 7; c2_i59++) {
    c2_b_u[c2_i59] = (*(real_T (*)[7])c2_inData)[c2_i59];
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 1, 7), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static void c2_d_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[7])
{
  real_T c2_dv2[7];
  int32_T c2_i60;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_b_u), c2_dv2, 1, 0, 0U, 1, 0U, 1, 7);
  for (c2_i60 = 0; c2_i60 < 7; c2_i60++) {
    c2_y[c2_i60] = c2_dv2[c2_i60];
  }

  sf_mex_destroy(&c2_b_u);
}

static void c2_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_ddq;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y[7];
  int32_T c2_i61;
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_ddq = sf_mex_dup(c2_mxArrayInData);
  c2_thisId.fIdentifier = (const char *)c2_varName;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_ddq), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_ddq);
  for (c2_i61 = 0; c2_i61 < 7; c2_i61++) {
    (*(real_T (*)[7])c2_outData)[c2_i61] = c2_y[c2_i61];
  }

  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_f_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  int32_T c2_i62;
  int32_T c2_i63;
  const mxArray *c2_y = NULL;
  int32_T c2_i64;
  real_T c2_b_u[42];
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  c2_i62 = 0;
  for (c2_i63 = 0; c2_i63 < 7; c2_i63++) {
    for (c2_i64 = 0; c2_i64 < 6; c2_i64++) {
      c2_b_u[c2_i64 + c2_i62] = (*(real_T (*)[42])c2_inData)[c2_i64 + c2_i62];
    }

    c2_i62 += 6;
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 2, 6, 7), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static void c2_e_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[42])
{
  real_T c2_dv3[42];
  int32_T c2_i65;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_b_u), c2_dv3, 1, 0, 0U, 1, 0U, 2, 6,
                7);
  for (c2_i65 = 0; c2_i65 < 42; c2_i65++) {
    c2_y[c2_i65] = c2_dv3[c2_i65];
  }

  sf_mex_destroy(&c2_b_u);
}

static void c2_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_Jg;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y[42];
  int32_T c2_i66;
  int32_T c2_i67;
  int32_T c2_i68;
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_Jg = sf_mex_dup(c2_mxArrayInData);
  c2_thisId.fIdentifier = (const char *)c2_varName;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_e_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_Jg), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_Jg);
  c2_i66 = 0;
  for (c2_i67 = 0; c2_i67 < 7; c2_i67++) {
    for (c2_i68 = 0; c2_i68 < 6; c2_i68++) {
      (*(real_T (*)[42])c2_outData)[c2_i68 + c2_i66] = c2_y[c2_i68 + c2_i66];
    }

    c2_i66 += 6;
  }

  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_g_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  int32_T c2_i69;
  int32_T c2_i70;
  const mxArray *c2_y = NULL;
  int32_T c2_i71;
  real_T c2_b_u[21];
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  c2_i69 = 0;
  for (c2_i70 = 0; c2_i70 < 7; c2_i70++) {
    for (c2_i71 = 0; c2_i71 < 3; c2_i71++) {
      c2_b_u[c2_i71 + c2_i69] = (*(real_T (*)[21])c2_inData)[c2_i71 + c2_i69];
    }

    c2_i69 += 3;
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 2, 3, 7), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static void c2_f_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[21])
{
  real_T c2_dv4[21];
  int32_T c2_i72;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_b_u), c2_dv4, 1, 0, 0U, 1, 0U, 2, 3,
                7);
  for (c2_i72 = 0; c2_i72 < 21; c2_i72++) {
    c2_y[c2_i72] = c2_dv4[c2_i72];
  }

  sf_mex_destroy(&c2_b_u);
}

static void c2_e_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_JgR;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y[21];
  int32_T c2_i73;
  int32_T c2_i74;
  int32_T c2_i75;
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_JgR = sf_mex_dup(c2_mxArrayInData);
  c2_thisId.fIdentifier = (const char *)c2_varName;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_f_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_JgR), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_JgR);
  c2_i73 = 0;
  for (c2_i74 = 0; c2_i74 < 7; c2_i74++) {
    for (c2_i75 = 0; c2_i75 < 3; c2_i75++) {
      (*(real_T (*)[21])c2_outData)[c2_i75 + c2_i73] = c2_y[c2_i75 + c2_i73];
    }

    c2_i73 += 3;
  }

  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_h_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  int32_T c2_i76;
  int32_T c2_i77;
  const mxArray *c2_y = NULL;
  int32_T c2_i78;
  real_T c2_b_u[28];
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  c2_i76 = 0;
  for (c2_i77 = 0; c2_i77 < 4; c2_i77++) {
    for (c2_i78 = 0; c2_i78 < 7; c2_i78++) {
      c2_b_u[c2_i78 + c2_i76] = (*(real_T (*)[28])c2_inData)[c2_i78 + c2_i76];
    }

    c2_i76 += 7;
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 2, 7, 4), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static const mxArray *c2_i_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  int32_T c2_i79;
  int32_T c2_i80;
  const mxArray *c2_y = NULL;
  int32_T c2_i81;
  real_T c2_b_u[49];
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  c2_i79 = 0;
  for (c2_i80 = 0; c2_i80 < 7; c2_i80++) {
    for (c2_i81 = 0; c2_i81 < 7; c2_i81++) {
      c2_b_u[c2_i81 + c2_i79] = (*(real_T (*)[49])c2_inData)[c2_i81 + c2_i79];
    }

    c2_i79 += 7;
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 2, 7, 7), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static void c2_g_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, real_T c2_y[49])
{
  real_T c2_dv5[49];
  int32_T c2_i82;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_b_u), c2_dv5, 1, 0, 0U, 1, 0U, 2, 7,
                7);
  for (c2_i82 = 0; c2_i82 < 49; c2_i82++) {
    c2_y[c2_i82] = c2_dv5[c2_i82];
  }

  sf_mex_destroy(&c2_b_u);
}

static void c2_f_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_M;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y[49];
  int32_T c2_i83;
  int32_T c2_i84;
  int32_T c2_i85;
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_M = sf_mex_dup(c2_mxArrayInData);
  c2_thisId.fIdentifier = (const char *)c2_varName;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_g_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_M), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_M);
  c2_i83 = 0;
  for (c2_i84 = 0; c2_i84 < 7; c2_i84++) {
    for (c2_i85 = 0; c2_i85 < 7; c2_i85++) {
      (*(real_T (*)[49])c2_outData)[c2_i85 + c2_i83] = c2_y[c2_i85 + c2_i83];
    }

    c2_i83 += 7;
  }

  sf_mex_destroy(&c2_mxArrayInData);
}

const mxArray *sf_c2_FLWSim_get_eml_resolved_functions_info(void)
{
  const mxArray *c2_nameCaptureInfo = NULL;
  const char * c2_data[7] = {
    "789ced98dd6ed3301886dd694cc000f5087100124788a305959f0e8e284d7fd6b550d6b06e42a84b53af3589ed2e71daa49c7021dc053780b49bd82197c025d0"
    "bfb48d27ab482d5e3be59322f7cbebf8b53f398fdc80d85e290600b8d7bf36fad79f47601877470d888fdb0d100e5e8f8ddb1b5c0e26f73743cf05fa8f716b50",
    "c2a0c7468985087cefe23ab4fb09d1319c0cd3a018119d30cd6f436043875a1dd8182aa7c8821ac2b04867923cea27383b234d928134f89d6e41c3acb818d82d"
    "673a5d6b360133f53911ac7f734e7df8e0ebc3f79be7b735c72f266883b8056ece640fde067e6dc178f3d617e3ee8bd617e87b04da0ce9259dd9c8038bd737f0",
    "dbe2f2a9ff486950b76ec1a9dfef05fdbe09fdc2fae7cc97f41be593036d47c12e69ea5851a9e1624898a3e410cbbb7525abbb16aba9904183214a6a2ad29b84"
    "3a0c198e92451d5844c4acea9609eddab16bea48a920ec5afaa0af52a20d68290d9f285809d576070ffd25eea79fbfb62f5272f7afecf7e5eafc3cc178ffba5f",
    "ef0bfce29cae754dd56f97b395d4590a25d31f9fd374cf7d379d47798ecfbc7900412e6bfc13c1f3ebcdf1874be3f81d815f9cd3d3d446d4428e06ed2168d695"
    "e33da15f5897c9f1d9da8e311e71fc9af8c9e2b8eaf4b09f4cb4b54436a9665ed183a3c207271f719c8fd5e2f863e9e7f19cad7710f30ffbc8a2837f5debcaf1",
    "553c8f876a1b9dc7af959f2c8ee7ba6517e708cda0a45d342ac70973b7588e387e29568be34f96c6f1db02bf38a717dab5223c651a1d7f33bb2a8e5f2ce8e771"
    "39e0fa05ba1c8e9b68c0f1696d77b0bc7df4fdfc3ce2f7daf39ba43cd73baa360b6799c3c6ebee8bafbbf9ba11f1fb52ac16bf9f2e8ddfdb02bf38a7f7197380",
    "9aad09c0d7f51cee0bfdc2ba647e07b50d3ea748dc4f11c7ffa79f2c8eef97d35596eaedb3976a26917896d2ca6a7e37b7fe1cff0bebd19e0e",
    "" };

  c2_nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(c2_data, 7688U, &c2_nameCaptureInfo);
  return c2_nameCaptureInfo;
}

static void c2_invNxN(SFc2_FLWSimInstanceStruct *chartInstance, real_T c2_b_x[49],
                      real_T c2_y[49])
{
  int32_T c2_i86;
  int32_T c2_i87;
  int32_T c2_i88;
  real_T c2_A[49];
  int32_T c2_j;
  int32_T c2_ipiv[7];
  int32_T c2_i89;
  int32_T c2_c;
  int32_T c2_idxmax;
  int32_T c2_k;
  int32_T c2_p[7];
  int32_T c2_ix;
  real_T c2_smax;
  int32_T c2_b_k;
  boolean_T c2_overflow;
  int32_T c2_jA;
  int32_T c2_pipk;
  int32_T c2_jy;
  int32_T c2_b;
  int32_T c2_b_ix;
  boolean_T c2_b_overflow;
  boolean_T c2_c_overflow;
  int32_T c2_iy;
  int32_T c2_b_j;
  int32_T c2_b_c;
  int32_T c2_c_k;
  int32_T c2_d_k;
  int32_T c2_c_j;
  int32_T c2_d_j;
  int32_T c2_i;
  int32_T c2_jBcol;
  real_T c2_temp;
  int32_T c2_e_k;
  real_T c2_s;
  real_T c2_yjy;
  int32_T c2_b_i;
  int32_T c2_kAcol;
  int32_T c2_c_ix;
  int32_T c2_b_b;
  boolean_T c2_d_overflow;
  boolean_T c2_e_overflow;
  int32_T c2_ijA;
  int32_T c2_c_i;
  for (c2_i86 = 0; c2_i86 < 49; c2_i86++) {
    c2_y[c2_i86] = 0.0;
  }

  for (c2_i87 = 0; c2_i87 < 49; c2_i87++) {
    c2_A[c2_i87] = c2_b_x[c2_i87];
  }

  for (c2_i88 = 0; c2_i88 < 7; c2_i88++) {
    c2_ipiv[c2_i88] = 1 + c2_i88;
  }

  for (c2_j = 0; c2_j < 6; c2_j++) {
    c2_c = c2_j << 3;
    if (7 - c2_j < 1) {
      c2_idxmax = 0;
    } else {
      c2_idxmax = 1;
      if (7 - c2_j > 1) {
        c2_ix = c2_c;
        c2_smax = muDoubleScalarAbs(c2_A[c2_c]) + muDoubleScalarAbs(0.0);
        c2_overflow = ((!(2 > 7 - c2_j)) && (7 - c2_j > 2147483646));
        if (c2_overflow) {
          c2_check_forloop_overflow_error(chartInstance, c2_overflow);
        }

        for (c2_c_k = 2; c2_c_k <= 7 - c2_j; c2_c_k++) {
          c2_ix++;
          c2_s = muDoubleScalarAbs(c2_A[c2_ix]) + muDoubleScalarAbs(0.0);
          if (c2_s > c2_smax) {
            c2_idxmax = c2_c_k;
            c2_smax = c2_s;
          }
        }
      }
    }

    if (c2_A[(c2_c + c2_idxmax) - 1] != 0.0) {
      if (c2_idxmax - 1 != 0) {
        c2_ipiv[c2_j] = c2_j + c2_idxmax;
        c2_b_ix = c2_j;
        c2_iy = (c2_j + c2_idxmax) - 1;
        for (c2_d_k = 0; c2_d_k < 7; c2_d_k++) {
          c2_temp = c2_A[c2_b_ix];
          c2_A[c2_b_ix] = c2_A[c2_iy];
          c2_A[c2_iy] = c2_temp;
          c2_b_ix += 7;
          c2_iy += 7;
        }
      }

      c2_b = (c2_c - c2_j) + 7;
      c2_c_overflow = ((!(c2_c + 2 > c2_b)) && (c2_b > 2147483646));
      if (c2_c_overflow) {
        c2_check_forloop_overflow_error(chartInstance, c2_c_overflow);
      }

      for (c2_i = c2_c + 1; c2_i + 1 <= c2_b; c2_i++) {
        c2_A[c2_i] /= c2_A[c2_c];
      }
    }

    c2_jA = c2_c + 9;
    c2_jy = c2_c + 7;
    c2_b_overflow = ((!(1 > 6 - c2_j)) && (6 - c2_j > 2147483646));
    if (c2_b_overflow) {
      c2_check_forloop_overflow_error(chartInstance, c2_b_overflow);
    }

    for (c2_d_j = 1; c2_d_j <= 6 - c2_j; c2_d_j++) {
      c2_yjy = c2_A[c2_jy];
      if (c2_A[c2_jy] != 0.0) {
        c2_c_ix = c2_c;
        c2_b_b = (c2_jA - c2_j) + 5;
        c2_d_overflow = ((!(c2_jA > c2_b_b)) && (c2_b_b > 2147483646));
        if (c2_d_overflow) {
          c2_check_forloop_overflow_error(chartInstance, c2_d_overflow);
        }

        for (c2_ijA = c2_jA - 1; c2_ijA + 1 <= c2_b_b; c2_ijA++) {
          c2_A[c2_ijA] += c2_A[c2_c_ix + 1] * -c2_yjy;
          c2_c_ix++;
        }
      }

      c2_jy += 7;
      c2_jA += 7;
    }
  }

  for (c2_i89 = 0; c2_i89 < 7; c2_i89++) {
    c2_p[c2_i89] = 1 + c2_i89;
  }

  for (c2_k = 0; c2_k < 6; c2_k++) {
    if ((real_T)c2_ipiv[c2_k] > 1.0 + (real_T)c2_k) {
      c2_pipk = c2_p[c2_ipiv[c2_k] - 1];
      c2_p[c2_ipiv[c2_k] - 1] = c2_p[c2_k];
      c2_p[c2_k] = c2_pipk;
    }
  }

  for (c2_b_k = 0; c2_b_k < 7; c2_b_k++) {
    c2_b_c = c2_p[c2_b_k] - 1;
    c2_y[c2_b_k + 7 * (c2_p[c2_b_k] - 1)] = 1.0;
    for (c2_c_j = c2_b_k; c2_c_j + 1 < 8; c2_c_j++) {
      if (c2_y[c2_c_j + 7 * c2_b_c] != 0.0) {
        for (c2_b_i = c2_c_j + 1; c2_b_i + 1 < 8; c2_b_i++) {
          c2_y[c2_b_i + 7 * c2_b_c] -= c2_y[c2_c_j + 7 * c2_b_c] * c2_A[c2_b_i +
            7 * c2_c_j];
        }
      }
    }
  }

  for (c2_b_j = 0; c2_b_j < 7; c2_b_j++) {
    c2_jBcol = 7 * c2_b_j;
    for (c2_e_k = 6; c2_e_k > -1; c2_e_k--) {
      c2_kAcol = 7 * c2_e_k;
      if (c2_y[c2_e_k + c2_jBcol] != 0.0) {
        c2_y[c2_e_k + c2_jBcol] /= c2_A[c2_e_k + c2_kAcol];
        c2_e_overflow = ((!(1 > c2_e_k)) && (c2_e_k > 2147483646));
        if (c2_e_overflow) {
          c2_check_forloop_overflow_error(chartInstance, c2_e_overflow);
        }

        for (c2_c_i = 0; c2_c_i + 1 <= c2_e_k; c2_c_i++) {
          c2_y[c2_c_i + c2_jBcol] -= c2_y[c2_e_k + c2_jBcol] * c2_A[c2_c_i +
            c2_kAcol];
        }
      }
    }
  }
}

static void c2_check_forloop_overflow_error(SFc2_FLWSimInstanceStruct
  *chartInstance, boolean_T c2_overflow)
{
  const mxArray *c2_y = NULL;
  static char_T c2_cv0[34] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'i', 'n', 't', '_', 'f', 'o', 'r', 'l', 'o', 'o', 'p',
    '_', 'o', 'v', 'e', 'r', 'f', 'l', 'o', 'w' };

  const mxArray *c2_b_y = NULL;
  static char_T c2_cv1[5] = { 'i', 'n', 't', '3', '2' };

  (void)chartInstance;
  if (!c2_overflow) {
  } else {
    c2_y = NULL;
    sf_mex_assign(&c2_y, sf_mex_create("y", c2_cv0, 10, 0U, 1U, 0U, 2, 1, 34),
                  false);
    c2_b_y = NULL;
    sf_mex_assign(&c2_b_y, sf_mex_create("y", c2_cv1, 10, 0U, 1U, 0U, 2, 1, 5),
                  false);
    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "error", 0U, 1U, 14,
                      sf_mex_call_debug(sfGlobalDebugInstanceStruct, "message",
      1U, 2U, 14, c2_y, 14, c2_b_y));
  }
}

static real_T c2_norm(SFc2_FLWSimInstanceStruct *chartInstance, real_T c2_b_x[49])
{
  real_T c2_y;
  int32_T c2_j;
  real_T c2_s;
  int32_T c2_i;
  boolean_T exitg1;
  (void)chartInstance;
  c2_y = 0.0;
  c2_j = 0;
  exitg1 = false;
  while ((!exitg1) && (c2_j < 7)) {
    c2_s = 0.0;
    for (c2_i = 0; c2_i < 7; c2_i++) {
      c2_s += muDoubleScalarAbs(c2_b_x[c2_i + 7 * c2_j]);
    }

    if (muDoubleScalarIsNaN(c2_s)) {
      c2_y = rtNaN;
      exitg1 = true;
    } else {
      if (c2_s > c2_y) {
        c2_y = c2_s;
      }

      c2_j++;
    }
  }

  return c2_y;
}

static void c2_warning(SFc2_FLWSimInstanceStruct *chartInstance)
{
  const mxArray *c2_y = NULL;
  static char_T c2_cv2[7] = { 'w', 'a', 'r', 'n', 'i', 'n', 'g' };

  const mxArray *c2_b_y = NULL;
  static char_T c2_cv3[7] = { 'm', 'e', 's', 's', 'a', 'g', 'e' };

  const mxArray *c2_c_y = NULL;
  static char_T c2_msgID[27] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T',
    'L', 'A', 'B', ':', 's', 'i', 'n', 'g', 'u', 'l', 'a', 'r', 'M', 'a', 't',
    'r', 'i', 'x' };

  (void)chartInstance;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_cv2, 10, 0U, 1U, 0U, 2, 1, 7),
                false);
  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", c2_cv3, 10, 0U, 1U, 0U, 2, 1, 7),
                false);
  c2_c_y = NULL;
  sf_mex_assign(&c2_c_y, sf_mex_create("y", c2_msgID, 10, 0U, 1U, 0U, 2, 1, 27),
                false);
  sf_mex_call_debug(sfGlobalDebugInstanceStruct, "feval", 0U, 2U, 14, c2_y, 14,
                    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "feval", 1U,
    2U, 14, c2_b_y, 14, c2_c_y));
}

static void c2_b_warning(SFc2_FLWSimInstanceStruct *chartInstance, char_T
  c2_varargin_1[14])
{
  const mxArray *c2_y = NULL;
  static char_T c2_cv4[7] = { 'w', 'a', 'r', 'n', 'i', 'n', 'g' };

  const mxArray *c2_b_y = NULL;
  static char_T c2_cv5[7] = { 'm', 'e', 's', 's', 'a', 'g', 'e' };

  const mxArray *c2_c_y = NULL;
  static char_T c2_msgID[33] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T',
    'L', 'A', 'B', ':', 'i', 'l', 'l', 'C', 'o', 'n', 'd', 'i', 't', 'i', 'o',
    'n', 'e', 'd', 'M', 'a', 't', 'r', 'i', 'x' };

  const mxArray *c2_d_y = NULL;
  (void)chartInstance;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_cv4, 10, 0U, 1U, 0U, 2, 1, 7),
                false);
  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", c2_cv5, 10, 0U, 1U, 0U, 2, 1, 7),
                false);
  c2_c_y = NULL;
  sf_mex_assign(&c2_c_y, sf_mex_create("y", c2_msgID, 10, 0U, 1U, 0U, 2, 1, 33),
                false);
  c2_d_y = NULL;
  sf_mex_assign(&c2_d_y, sf_mex_create("y", c2_varargin_1, 10, 0U, 1U, 0U, 2, 1,
    14), false);
  sf_mex_call_debug(sfGlobalDebugInstanceStruct, "feval", 0U, 2U, 14, c2_y, 14,
                    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "feval", 1U,
    3U, 14, c2_b_y, 14, c2_c_y, 14, c2_d_y));
}

static void c2_h_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_sprintf, const char_T *c2_identifier, char_T c2_y[14])
{
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = (const char *)c2_identifier;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_i_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_sprintf), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_sprintf);
}

static void c2_i_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId, char_T c2_y[14])
{
  char_T c2_cv6[14];
  int32_T c2_i90;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_b_u), c2_cv6, 1, 10, 0U, 1, 0U, 2, 1,
                14);
  for (c2_i90 = 0; c2_i90 < 14; c2_i90++) {
    c2_y[c2_i90] = c2_cv6[c2_i90];
  }

  sf_mex_destroy(&c2_b_u);
}

static const mxArray *c2_j_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData;
  int32_T c2_b_u;
  const mxArray *c2_y = NULL;
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_mxArrayOutData = NULL;
  c2_b_u = *(int32_T *)c2_inData;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_b_u, 6, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static int32_T c2_j_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId)
{
  int32_T c2_y;
  int32_T c2_i91;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_b_u), &c2_i91, 1, 6, 0U, 0, 0U, 0);
  c2_y = c2_i91;
  sf_mex_destroy(&c2_b_u);
  return c2_y;
}

static void c2_g_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_b_sfEvent;
  emlrtMsgIdentifier c2_thisId;
  int32_T c2_y;
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)chartInstanceVoid;
  c2_b_sfEvent = sf_mex_dup(c2_mxArrayInData);
  c2_thisId.fIdentifier = (const char *)c2_varName;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_y = c2_j_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_sfEvent),
    &c2_thisId);
  sf_mex_destroy(&c2_b_sfEvent);
  *(int32_T *)c2_outData = c2_y;
  sf_mex_destroy(&c2_mxArrayInData);
}

static uint8_T c2_k_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_is_active_c2_FLWSim, const char_T *c2_identifier)
{
  uint8_T c2_y;
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = (const char *)c2_identifier;
  c2_thisId.fParent = NULL;
  c2_thisId.bParentIsCell = false;
  c2_y = c2_l_emlrt_marshallIn(chartInstance, sf_mex_dup
    (c2_b_is_active_c2_FLWSim), &c2_thisId);
  sf_mex_destroy(&c2_b_is_active_c2_FLWSim);
  return c2_y;
}

static uint8_T c2_l_emlrt_marshallIn(SFc2_FLWSimInstanceStruct *chartInstance,
  const mxArray *c2_b_u, const emlrtMsgIdentifier *c2_parentId)
{
  uint8_T c2_y;
  uint8_T c2_u0;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_b_u), &c2_u0, 1, 3, 0U, 0, 0U, 0);
  c2_y = c2_u0;
  sf_mex_destroy(&c2_b_u);
  return c2_y;
}

static void init_dsm_address_info(SFc2_FLWSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void init_simulink_io_address(SFc2_FLWSimInstanceStruct *chartInstance)
{
  chartInstance->c2_fEmlrtCtx = (void *)sfrtGetEmlrtCtx(chartInstance->S);
  chartInstance->c2_x = (real_T (*)[14])ssGetInputPortSignal_wrapper
    (chartInstance->S, 0);
  chartInstance->c2_u = (real_T (*)[4])ssGetInputPortSignal_wrapper
    (chartInstance->S, 1);
  chartInstance->c2_dx = (real_T (*)[14])ssGetOutputPortSignal_wrapper
    (chartInstance->S, 1);
  chartInstance->c2_GRF = (real_T (*)[6])ssGetInputPortSignal_wrapper
    (chartInstance->S, 2);
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

void sf_c2_FLWSim_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(4222118896U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3824978780U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(3964621852U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(916785067U);
}

mxArray* sf_c2_FLWSim_get_post_codegen_info(void);
mxArray *sf_c2_FLWSim_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs", "locals", "postCodegenInfo" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1, 1, sizeof
    (autoinheritanceFields)/sizeof(autoinheritanceFields[0]),
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateString("PrjMG1jUtWyjzdw0vQ02vH");
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,3,3,dataFields);

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

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
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
      pr[0] = (double)(6);
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
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxCreateDoubleMatrix(0,0,
                mxREAL));
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
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"locals",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  {
    mxArray* mxPostCodegenInfo = sf_c2_FLWSim_get_post_codegen_info();
    mxSetField(mxAutoinheritanceInfo,0,"postCodegenInfo",mxPostCodegenInfo);
  }

  return(mxAutoinheritanceInfo);
}

mxArray *sf_c2_FLWSim_third_party_uses_info(void)
{
  mxArray * mxcell3p = mxCreateCellMatrix(1,0);
  return(mxcell3p);
}

mxArray *sf_c2_FLWSim_jit_fallback_info(void)
{
  const char *infoFields[] = { "fallbackType", "fallbackReason",
    "hiddenFallbackType", "hiddenFallbackReason", "incompatibleSymbol" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 5, infoFields);
  mxArray *fallbackType = mxCreateString("late");
  mxArray *fallbackReason = mxCreateString("ir_function_calls");
  mxArray *hiddenFallbackType = mxCreateString("");
  mxArray *hiddenFallbackReason = mxCreateString("");
  mxArray *incompatibleSymbol = mxCreateString("InertiaMatrix_src");
  mxSetField(mxInfo, 0, infoFields[0], fallbackType);
  mxSetField(mxInfo, 0, infoFields[1], fallbackReason);
  mxSetField(mxInfo, 0, infoFields[2], hiddenFallbackType);
  mxSetField(mxInfo, 0, infoFields[3], hiddenFallbackReason);
  mxSetField(mxInfo, 0, infoFields[4], incompatibleSymbol);
  return mxInfo;
}

mxArray *sf_c2_FLWSim_updateBuildInfo_args_info(void)
{
  mxArray *mxBIArgs = mxCreateCellMatrix(1,0);
  return mxBIArgs;
}

mxArray* sf_c2_FLWSim_get_post_codegen_info(void)
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

static const mxArray *sf_get_sim_state_info_c2_FLWSim(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x2'type','srcId','name','auxInfo'{{M[1],M[5],T\"dx\",},{M[8],M[0],T\"is_active_c2_FLWSim\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 2, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c2_FLWSim_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc2_FLWSimInstanceStruct *chartInstance = (SFc2_FLWSimInstanceStruct *)
      sf_get_chart_instance_ptr(S);
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (sfGlobalDebugInstanceStruct,
           _FLWSimMachineNumber_,
           2,
           1,
           1,
           0,
           4,
           0,
           0,
           0,
           0,
           5,
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
          _SFD_SET_DATA_PROPS(1,1,1,0,"u");
          _SFD_SET_DATA_PROPS(2,1,1,0,"GRF");
          _SFD_SET_DATA_PROPS(3,2,0,1,"dx");
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
        _SFD_CV_INIT_EML(0,1,1,0,0,0,0,0,0,0,0,0);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,293);
        _SFD_CV_INIT_SCRIPT(0,1,0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(0,0,"InertiaMatrix",0,-1,347);
        _SFD_CV_INIT_SCRIPT_IF(0,0,45,70,120,343);
        _SFD_CV_INIT_SCRIPT(1,1,0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(1,0,"CoriolisTerm",0,-1,371);
        _SFD_CV_INIT_SCRIPT_IF(1,0,49,74,128,367);
        _SFD_CV_INIT_SCRIPT(2,1,0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(2,0,"GravityVector",0,-1,347);
        _SFD_CV_INIT_SCRIPT_IF(2,0,45,70,120,343);
        _SFD_CV_INIT_SCRIPT(3,1,0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(3,0,"Jp_LeftToe",0,-1,335);
        _SFD_CV_INIT_SCRIPT_IF(3,0,42,67,114,331);
        _SFD_CV_INIT_SCRIPT(4,1,0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(4,0,"Jp_RightToe",0,-1,339);
        _SFD_CV_INIT_SCRIPT_IF(4,0,43,68,116,335);

        {
          unsigned int dimVector[1];
          dimVector[0]= 14U;
          _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 4U;
          _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_c_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 6U;
          _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_b_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 14U;
          _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)
            c2_sf_marshallIn);
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
    SFc2_FLWSimInstanceStruct *chartInstance = (SFc2_FLWSimInstanceStruct *)
      sf_get_chart_instance_ptr(S);
    if (ssIsFirstInitCond(S)) {
      /* do this only if simulation is starting and after we know the addresses of all data */
      {
        _SFD_SET_DATA_VALUE_PTR(0U, (void *)chartInstance->c2_x);
        _SFD_SET_DATA_VALUE_PTR(1U, (void *)chartInstance->c2_u);
        _SFD_SET_DATA_VALUE_PTR(3U, (void *)chartInstance->c2_dx);
        _SFD_SET_DATA_VALUE_PTR(2U, (void *)chartInstance->c2_GRF);
      }
    }
  }
}

static const char* sf_get_instance_specialization(void)
{
  return "slOBIBzBdOLhO8I0pLCG8MB";
}

static void sf_opaque_initialize_c2_FLWSim(void *chartInstanceVar)
{
  chart_debug_initialization(((SFc2_FLWSimInstanceStruct*) chartInstanceVar)->S,
    0);
  initialize_params_c2_FLWSim((SFc2_FLWSimInstanceStruct*) chartInstanceVar);
  initialize_c2_FLWSim((SFc2_FLWSimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c2_FLWSim(void *chartInstanceVar)
{
  enable_c2_FLWSim((SFc2_FLWSimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_disable_c2_FLWSim(void *chartInstanceVar)
{
  disable_c2_FLWSim((SFc2_FLWSimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_gateway_c2_FLWSim(void *chartInstanceVar)
{
  sf_gateway_c2_FLWSim((SFc2_FLWSimInstanceStruct*) chartInstanceVar);
}

static const mxArray* sf_opaque_get_sim_state_c2_FLWSim(SimStruct* S)
{
  return get_sim_state_c2_FLWSim((SFc2_FLWSimInstanceStruct *)
    sf_get_chart_instance_ptr(S));     /* raw sim ctx */
}

static void sf_opaque_set_sim_state_c2_FLWSim(SimStruct* S, const mxArray *st)
{
  set_sim_state_c2_FLWSim((SFc2_FLWSimInstanceStruct*)sf_get_chart_instance_ptr
    (S), st);
}

static void sf_opaque_terminate_c2_FLWSim(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc2_FLWSimInstanceStruct*) chartInstanceVar)->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
      unload_FLWSim_optimization_info();
    }

    finalize_c2_FLWSim((SFc2_FLWSimInstanceStruct*) chartInstanceVar);
    utFree(chartInstanceVar);
    if (ssGetUserData(S)!= NULL) {
      sf_free_ChartRunTimeInfo(S);
    }

    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  initSimStructsc2_FLWSim((SFc2_FLWSimInstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c2_FLWSim(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c2_FLWSim((SFc2_FLWSimInstanceStruct*)
      sf_get_chart_instance_ptr(S));
  }
}

static void mdlSetWorkWidths_c2_FLWSim(SimStruct *S)
{
  /* Set overwritable ports for inplace optimization */
  ssSetInputPortDirectFeedThrough(S, 0, 1);
  ssSetInputPortDirectFeedThrough(S, 1, 1);
  ssSetInputPortDirectFeedThrough(S, 2, 1);
  ssSetStatesModifiedOnlyInUpdate(S, 1);
  ssSetBlockIsPurelyCombinatorial_wrapper(S, 1);
  ssMdlUpdateIsEmpty(S, 1);
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    mxArray *infoStruct = load_FLWSim_optimization_info(sim_mode_is_rtw_gen(S),
      sim_mode_is_modelref_sim(S), sim_mode_is_external(S));
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(sf_get_instance_specialization(),infoStruct,2);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,1);
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop
      (sf_get_instance_specialization(),infoStruct,2,
       "gatewayCannotBeInlinedMultipleTimes"));
    sf_set_chart_accesses_machine_info(S, sf_get_instance_specialization(),
      infoStruct, 2);
    sf_update_buildInfo(S, sf_get_instance_specialization(),infoStruct,2);
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,sf_get_instance_specialization(),
        infoStruct,2,3);
      sf_mark_chart_reusable_outputs(S,sf_get_instance_specialization(),
        infoStruct,2,1);
    }

    {
      unsigned int outPortIdx;
      for (outPortIdx=1; outPortIdx<=1; ++outPortIdx) {
        ssSetOutputPortOptimizeInIR(S, outPortIdx, 1U);
      }
    }

    {
      unsigned int inPortIdx;
      for (inPortIdx=0; inPortIdx < 3; ++inPortIdx) {
        ssSetInputPortOptimizeInIR(S, inPortIdx, 1U);
      }
    }

    sf_set_rtw_dwork_info(S,sf_get_instance_specialization(),infoStruct,2);
    sf_register_codegen_names_for_scoped_functions_defined_by_chart(S);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(65582734U));
  ssSetChecksum1(S,(185214930U));
  ssSetChecksum2(S,(2956335273U));
  ssSetChecksum3(S,(695140627U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
  ssSetStateSemanticsClassicAndSynchronous(S, true);
  ssSupportsMultipleExecInstances(S,1);
}

static void mdlRTW_c2_FLWSim(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c2_FLWSim(SimStruct *S)
{
  SFc2_FLWSimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FLWSimInstanceStruct *)utMalloc(sizeof
    (SFc2_FLWSimInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  memset(chartInstance, 0, sizeof(SFc2_FLWSimInstanceStruct));
  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway = sf_opaque_gateway_c2_FLWSim;
  chartInstance->chartInfo.initializeChart = sf_opaque_initialize_c2_FLWSim;
  chartInstance->chartInfo.terminateChart = sf_opaque_terminate_c2_FLWSim;
  chartInstance->chartInfo.enableChart = sf_opaque_enable_c2_FLWSim;
  chartInstance->chartInfo.disableChart = sf_opaque_disable_c2_FLWSim;
  chartInstance->chartInfo.getSimState = sf_opaque_get_sim_state_c2_FLWSim;
  chartInstance->chartInfo.setSimState = sf_opaque_set_sim_state_c2_FLWSim;
  chartInstance->chartInfo.getSimStateInfo = sf_get_sim_state_info_c2_FLWSim;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c2_FLWSim;
  chartInstance->chartInfo.mdlStart = mdlStart_c2_FLWSim;
  chartInstance->chartInfo.mdlSetWorkWidths = mdlSetWorkWidths_c2_FLWSim;
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
  mdl_start_c2_FLWSim(chartInstance);
}

void c2_FLWSim_method_dispatcher(SimStruct *S, int_T method, void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c2_FLWSim(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c2_FLWSim(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c2_FLWSim(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c2_FLWSim_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}

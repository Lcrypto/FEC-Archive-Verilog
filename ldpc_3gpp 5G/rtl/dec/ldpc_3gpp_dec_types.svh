//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_types.svh
// Description   : decoder parameters/types & etc
//

  //------------------------------------------------------------------------------------------------------
  // common code context parameter to contstraint fixed or variable decoder
  //------------------------------------------------------------------------------------------------------

  parameter bit pIDX_GR   =   0 ; // use graph1/graph2 (0) or graph2 only (1)
  parameter int pIDX_LS   =   0 ;
  parameter int pIDX_ZC   =   7 ;
  parameter int pCODE     =   4 ; // maximum code rate using (46 for graph1 and 42 for graph2)
  parameter bit pDO_PUNCT =   0 ; // use puncture any time (1) or context defined (0)

  //------------------------------------------------------------------------------------------------------
  // code context for variable decoder
  //------------------------------------------------------------------------------------------------------

  typedef struct packed {
    logic   idxGr;       // graph 1/2
    idxLs_t idxLs;       // 0...7
    idxZc_t idxZc;       // 0...7 use only Zc multiply by pLLR_BY_CYCLE
    code_t  code;        // graph1/graph2 [4:46]/[4:42]
    logic   do_punct;    // do 3GPP puncture (1)
  } code_ctx_t;

  // matrix multiply value type
  typedef struct packed {
    hb_zc_t bshift;     // bit  shift == Hb[c][t] % pLLR_BY_CYCLE
    hb_zc_t wshift;     // word shift == Hb[c][t] / pLLR_BY_CYCLE
    logic   is_masked;  // Hb[c][t] < 0s
  } mm_hb_value_t;

  //------------------------------------------------------------------------------------------------------
  // decoder parameters
  //
  // the decoder performance rate is pLLR_BY_CYCLE * pROW_BY_CYCLE * pCOL_BY_CYCLE cnode/vnode per clock cycle
  // maximum amount of nodes per code block is
  //  graph 1 zc*(4*26 + 42*(26+1))
  //  graph 2 zc*(4*14 + 42*(14+1))
  //
  //------------------------------------------------------------------------------------------------------

  // arithmetic bitwidth
  parameter int pLLR_W          = 4;
  parameter int pNODE_W         = pLLR_W; // extend internal node bitwidth to increase fixed point part when normaliation used

  // parallelization settings
  parameter int pLLR_BY_CYCLE   = 1;      // amount of metric per clock cycle. only 1 support. TODO :: 1/2/4/8 suport
  parameter int pROW_BY_CYCLE   = 8;      // amount of rows per cycle. maximum number of row for graph1/2 is 46/42
  // fixed. don't change
  localparam int cCOL_BY_CYCLE  = 26;     // amount of major decoder collumns per cycle. maximum number of col for graph1/2 is 26/14

  parameter bit pUSE_SC_MODE    = 1;      // use self corrected mode (with vnode erasure)

  //------------------------------------------------------------------------------------------------------
  // used data types
  //------------------------------------------------------------------------------------------------------

  typedef logic signed  [pLLR_W-1 : 0] llr_t;
  typedef logic signed [pNODE_W-1 : 0] node_t;

  typedef struct packed {
    logic pre_sign, pre_zero;
  } node_state_t;

  // control strobes type
  typedef struct packed {
    logic sof;  // start of node frame working (row == 0 & zc == 0)
    logic sop;  // start of node block working cnode_mode ? (zc  == 0)         : (row == 0)
    logic eop;  // end   of node block working cnode_mode ? (zc  == used_zc-1) : (row == used_row-1)
    logic eof;  // end   of node frame working (row == used_row-1 & zc == used_zc-1)
  } strb_t;

  //------------------------------------------------------------------------------------------------------
  // node/LLR memory parameters
  //------------------------------------------------------------------------------------------------------

  parameter int pMAX_ROW_STEP_NUM   = ceil((pIDX_GR ? 42 : 46), pROW_BY_CYCLE);

  localparam int cMAX_COL_STEP_NUM  = 26/cCOL_BY_CYCLE;

  // node mem : pMAX_ROW_STEP_NUM of Zc*Zc block
  localparam int cMEM_ADDR_MAX    = pMAX_ROW_STEP_NUM * cMAX_COL_STEP_NUM * cZC_MAX/pLLR_BY_CYCLE;
  localparam int cMEM_ADDR_W      = clogb2(cMEM_ADDR_MAX);

  // data LLR mem : one Zc*Zc block
  localparam int cD_MEM_ADDR_MAX  = cMAX_COL_STEP_NUM * cZC_MAX/pLLR_BY_CYCLE;
  localparam int cD_MEM_ADDR_W    = clogb2(cD_MEM_ADDR_MAX);

  // parity LLR mem : pMAX_ROW_STEP_NUM of Zc*Zc block
  localparam int cP_MEM_ADDR_MAX  = cMEM_ADDR_MAX;
  localparam int cP_MEM_ADDR_W    = clogb2(cP_MEM_ADDR_MAX);

  //------------------------------------------------------------------------------------------------------
  // horizontal step (cnode engine) node types
  //------------------------------------------------------------------------------------------------------

  typedef logic       [pNODE_W-1 : 0] vnode_t; // != node_t because unsigned !!!!!
  typedef logic [cCOL_BY_CYCLE-1 : 0] vnode_sign_t;

  typedef struct packed {
    // common fields
    logic        prod_sign;
    vnode_sign_t vn_sign;
    // partial fields
    vnode_t      min1;
    vnode_t      min2;
    hb_col_t     min1_col;
  } vn_min_t;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

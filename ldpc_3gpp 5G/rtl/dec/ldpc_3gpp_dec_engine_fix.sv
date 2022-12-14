/*



  parameter int pIDX_GR       =  0 ;
  parameter int pIDX_LS       =  0 ;
  parameter int pIDX_ZC       =  2 ;
  parameter int pCODE         =  4 ;
  parameter int pDO_PUNCT     =  0 ;
  //
  parameter int pLLR_W        =  8 ;
  parameter int pNODE_W       =  8 ;
  //
  parameter int pADDR_W       =  8 ;
  //
  parameter int pTAG_W        =  4 ;
  //
  parameter int pERR_W        = 16 ;
  parameter int pERR_SFACTOR  =  2 ;
  //
  parameter int pLLR_BY_CYCLE =  1 ;
  parameter int pROW_BY_CYCLE =  8 ;
  //
  parameter int pVNORM_FACTOR =  7 ;
  parameter int pCNORM_FACTOR =  7 ;
  parameter bit pUSE_SC_MODE  =  1 ;



  logic                            ldpc_3gpp_dec_engine_fix__iclk                                                      ;
  logic                            ldpc_3gpp_dec_engine_fix__ireset                                                    ;
  logic                            ldpc_3gpp_dec_engine_fix__iclkena                                                   ;
  //
  logic                    [7 : 0] ldpc_3gpp_dec_engine_fix__iNiter                                                    ;
  logic                            ldpc_3gpp_dec_engine_fix__ifmode                                                    ;
  //
  logic                            ldpc_3gpp_dec_engine_fix__ibuf_full                                                 ;
  logic                            ldpc_3gpp_dec_engine_fix__obuf_rempty                                               ;
  //
  code_ctx_t                       ldpc_3gpp_dec_engine_fix__icode_ctx                                                 ;
  //
  logic             [pTAG_W-1 : 0] ldpc_3gpp_dec_engine_fix__itag                                                      ;
  llr_t                            ldpc_3gpp_dec_engine_fix__iLLR                       [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  llr_t                            ldpc_3gpp_dec_engine_fix__ipLLR       [pROW_BY_CYCLE]               [pLLR_BY_CYCLE] ;
  logic            [pADDR_W-1 : 0] ldpc_3gpp_dec_engine_fix__oLLR_raddr                                                ;
  //
  logic                            ldpc_3gpp_dec_engine_fix__iobuf_empty                                               ;
  //
  code_ctx_t                       ldpc_3gpp_dec_engine_fix__ocode_ctx                                                 ;
  //
  logic                            ldpc_3gpp_dec_engine_fix__oval                                                      ;
  logic                            ldpc_3gpp_dec_engine_fix__osop                                                      ;
  logic                            ldpc_3gpp_dec_engine_fix__oeop                                                      ;
  logic      [pLLR_BY_CYCLE-1 : 0] ldpc_3gpp_dec_engine_fix__odat                       [cCOL_BY_CYCLE]                ;
  logic             [pTAG_W-1 : 0] ldpc_3gpp_dec_engine_fix__otag                                                      ;
  //
  logic                            ldpc_3gpp_dec_engine_fix__odecfail                                                  ;
  logic             [pERR_W-1 : 0] ldpc_3gpp_dec_engine_fix__oerr                                                      ;



  ldpc_3gpp_dec_engine_fix
  #(
    .pIDX_GR       ( pIDX_GR       ) ,
    .pIDX_LS       ( pIDX_LS       ) ,
    .pIDX_ZC       ( pIDX_ZC       ) ,
    .pCODE         ( pCODE         ) ,
    .pDO_PUNCT     ( pDO_PUNCT     ) ,
    //
    .pLLR_W        ( pLLR_W        ) ,
    .pNODE_W       ( pNODE_W       ) ,
    //
    .pADDR_W       ( pADDR_W       ) ,
    .pTAG_W        ( pTAG_W        ) ,
    //
    .pERR_W        ( pERR_W        ) ,
    .pERR_SFACTOR  ( pERR_SFACTOR  ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE ) ,
    //
    .pVNORM_FACTOR ( pVNORM_FACTOR ) ,
    .pCNORM_FACTOR ( pCNORM_FACTOR ) ,
    .pUSE_SC_MODE  ( pUSE_SC_MODE  )
  )
  ldpc_3gpp_dec_engine_fix
  (
    .iclk        ( ldpc_3gpp_dec_engine_fix__iclk        ) ,
    .ireset      ( ldpc_3gpp_dec_engine_fix__ireset      ) ,
    .iclkena     ( ldpc_3gpp_dec_engine_fix__iclkena     ) ,
    //
    .iNiter      ( ldpc_3gpp_dec_engine_fix__iNiter      ) ,
    .ifmode      ( ldpc_3gpp_dec_engine_fix__ifmode      ) ,
    //
    .ibuf_full   ( ldpc_3gpp_dec_engine_fix__ibuf_full   ) ,
    .obuf_rempty ( ldpc_3gpp_dec_engine_fix__obuf_rempty ) ,
    //
    .icode_ctx   ( ldpc_3gpp_dec_engine_fix__icode_ctx   ) ,
    //
    .itag        ( ldpc_3gpp_dec_engine_fix__itag        ) ,
    .iLLR        ( ldpc_3gpp_dec_engine_fix__iLLR        ) ,
    .ipLLR       ( ldpc_3gpp_dec_engine_fix__ipLLR       ) ,
    .oLLR_raddr  ( ldpc_3gpp_dec_engine_fix__oLLR_raddr  ) ,
    //
    .iobuf_empty ( ldpc_3gpp_dec_engine_fix__iobuf_empty ) ,
    //
    .ocode_ctx   ( ldpc_3gpp_dec_engine_fix__ocode_ctx   ) ,
    //
    .oval        ( ldpc_3gpp_dec_engine_fix__oval        ) ,
    .osop        ( ldpc_3gpp_dec_engine_fix__osop        ) ,
    .oeop        ( ldpc_3gpp_dec_engine_fix__oeop        ) ,
    .odat        ( ldpc_3gpp_dec_engine_fix__odat        ) ,
    .otag        ( ldpc_3gpp_dec_engine_fix__otag        ) ,
    //
    .odecfail    ( ldpc_3gpp_dec_engine_fix__odecfail    ) ,
    .oerr        ( ldpc_3gpp_dec_engine_fix__oerr        )
  );


  assign ldpc_3gpp_dec_engine_fix__iclk        = '0 ;
  assign ldpc_3gpp_dec_engine_fix__ireset      = '0 ;
  assign ldpc_3gpp_dec_engine_fix__iclkena     = '0 ;
  assign ldpc_3gpp_dec_engine_fix__iNiter      = '0 ;
  assign ldpc_3gpp_dec_engine_fix__ifmode      = '0 ;
  assign ldpc_3gpp_dec_engine_fix__ibuf_full   = '0 ;
  assign ldpc_3gpp_dec_engine_fix__icode_ctx   = '0 ;
  assign ldpc_3gpp_dec_engine_fix__itag        = '0 ;
  assign ldpc_3gpp_dec_engine_fix__iLLR        = '0 ;
  assign ldpc_3gpp_dec_engine_fix__ipLLR       = '0 ;
  assign ldpc_3gpp_dec_engine_fix__iobuf_empty = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_engine.sv
// Description   : LDPC decoder engine with fixed parameters
//


`include "define.vh"

module ldpc_3gpp_dec_engine_fix
(
  iclk        ,
  ireset      ,
  iclkena     ,
  //
  iNiter      ,
  ifmode      ,
  //
  ibuf_full   ,
  obuf_rempty ,
  //
  icode_ctx   ,
  //
  itag        ,
  iLLR        ,
  ipLLR       ,
  oLLR_raddr  ,
  //
  iobuf_empty ,
  //
  ocode_ctx   ,
  //
  oval        ,
  osop        ,
  oeop        ,
  odat        ,
  otag        ,
  //
  odecfail    ,
  oerr
);

  parameter int pADDR_W       =  8 ;
  parameter int pTAG_W        =  4 ;
  //
  parameter int pERR_W        = 16 ;
  parameter int pERR_SFACTOR  =  2 ;
  //
  parameter int pVNORM_FACTOR =  7 ;
  parameter int pCNORM_FACTOR =  7 ;

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_dec_types.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                            iclk                                                      ;
  input  logic                            ireset                                                    ;
  input  logic                            iclkena                                                   ;
  //
  input  logic                    [7 : 0] iNiter                                                    ;
  input  logic                            ifmode                                                    ; // fast work mode with early stop
  //
  input  logic                            ibuf_full                                                 ;
  output logic                            obuf_rempty                                               ;
  //
  input  code_ctx_t                       icode_ctx                                                 ;
  //
  input  logic             [pTAG_W-1 : 0] itag                                                      ;
  input  llr_t                            iLLR                       [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  input  llr_t                            ipLLR       [pROW_BY_CYCLE]               [pLLR_BY_CYCLE] ;
  output logic            [pADDR_W-1 : 0] oLLR_raddr                                                ;
  //
  input  logic                            iobuf_empty                                               ;
  //
  output code_ctx_t                       ocode_ctx                                                 ;
  //
  output logic                            oval                                                      ;
  output logic                            osop                                                      ;
  output logic                            oeop                                                      ;
  output logic      [pLLR_BY_CYCLE-1 : 0] odat                       [cCOL_BY_CYCLE]                ;
  output logic             [pTAG_W-1 : 0] otag                                                      ;
  //
  output logic                            odecfail                                                  ;
  output logic             [pERR_W-1 : 0] oerr                                                      ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  //
  // ctrl
  logic                            ctrl__ibuf_full      ;
  logic                            ctrl__iobuf_empty    ;
  logic                            ctrl__obuf_rempty    ;
  //
  hb_zc_t                          ctrl__iused_zc       ;
  hb_row_t                         ctrl__iused_row      ;
  //
  logic                            ctrl__ivnode_busy    ;
  //
  logic                            ctrl__icnode_busy    ;
  logic                            ctrl__icnode_decfail ;
  //
  logic                            ctrl__oload_mode     ;
  logic                            ctrl__oc_nv_mode     ;
  //
  logic                            ctrl__oread          ;
  logic                            ctrl__orstart        ;
  logic                            ctrl__orval          ;
  strb_t                           ctrl__orstrb         ;
  hb_row_t                         ctrl__orrow          ;

  logic                            ctrl__olast_iter     ;
  //
  // hb
  hb_zc_t                          hb_tab__oused_zc                       ;
  hb_row_t                         hb_tab__oused_row                      ;
  //
  hb_row_t                         hb_tab__iwrow                          ;
  hb_row_t                         hb_tab__irrow                          ;
  //
  mm_hb_value_t                    hb_tab__orHb       [pROW_BY_CYCLE][26] ;
  mm_hb_value_t                    hb_tab__owHb       [pROW_BY_CYCLE][26] ;
  logic                            hb_tab__orHb_pmask [pROW_BY_CYCLE]     ;

  //
  // address gen
  logic                            LLR_addr_gen__ic_nv_mode                 ;
  hb_zc_t                          LLR_addr_gen__iused_zc                   ;
  //
  logic                            LLR_addr_gen__iread                      ;
  logic                            LLR_addr_gen__irstart                    ;
  logic                            LLR_addr_gen__irmask     [pROW_BY_CYCLE] ;
  logic                            LLR_addr_gen__irval                      ;
  strb_t                           LLR_addr_gen__irstrb                     ;

  logic                            LLR_addr_gen__orval                      ;
  strb_t                           LLR_addr_gen__orstrb                     ;
  logic                            LLR_addr_gen__ormask     [pROW_BY_CYCLE] ;

  //
  // mem
  hb_zc_t                          mem__iused_zc                                                 ;
  logic                            mem__ic_nv_mode                                               ;
  //
  logic                            mem__iwrite                                                   ;
  mm_hb_value_t                    mem__iwHb       [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  strb_t                           mem__iwstrb                                                   ;
  node_t                           mem__iwdat      [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  node_state_t                     mem__iwstate    [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  logic                            mem__iread                                                    ;
  logic                            mem__irstart                                                  ;
  mm_hb_value_t                    mem__irHb       [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  logic                            mem__irval                                                      ;
  strb_t                           mem__irstrb                                                   ;
  //
  logic                            mem__orval                                                    ;
  strb_t                           mem__orstrb                                                   ;
  logic                            mem__ormask     [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  node_t                           mem__ordat      [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  node_state_t                     mem__orstate    [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;

  //
  // cnode
  logic                            cnode__ival                                                   ;
  strb_t                           cnode__istrb                                                  ;
  logic                            cnode__ivmask   [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  node_t                           cnode__ivnode   [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  logic                            cnode__ipmask   [pROW_BY_CYCLE]                               ;
  llr_t                            cnode__ipLLR    [pROW_BY_CYCLE]               [pLLR_BY_CYCLE] ;
  //
  logic                            cnode__oval                                                   ;
  strb_t                           cnode__ostrb                                                  ;
  hb_row_t                         cnode__orow                                                   ;
  node_t                           cnode__ocnode   [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  logic                            cnode__odecfail                                               ;
  logic                            cnode__obusy                                                  ;

  //
  // vnode
  logic                            vnode__iidxGr                                                ;
  logic                            vnode__ido_punct                                             ;
  hb_row_t                         vnode__iused_row                                             ;
  //
  logic                            vnode__ival                                                  ;
  strb_t                           vnode__istrb                                                 ;
  llr_t                            vnode__iLLR                   [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  node_t                           vnode__icnode  [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  logic                            vnode__icmask  [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  node_state_t                     vnode__icstate [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  logic                            vnode__iuval                                                 ;
  strb_t                           vnode__iustrb                                                ;
  llr_t                            vnode__iuLLR                  [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  logic                            vnode__oval                                                  ;
  strb_t                           vnode__ostrb                                                 ;
  node_t                           vnode__ovnode  [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  node_state_t                     vnode__ovstate [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  logic                            vnode__obitval                                               ;
  logic                            vnode__obitsop                                               ;
  logic                            vnode__obiteop                                               ;
  logic      [pLLR_BY_CYCLE-1 : 0] vnode__obitdat                [cCOL_BY_CYCLE]                ;
  logic             [pERR_W-1 : 0] vnode__obiterr                                               ;
  //
  logic                            vnode__obusy                                                 ;

  //------------------------------------------------------------------------------------------------------
  // hb
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_Hb_fix
  #(
    .pIDX_GR       ( pIDX_GR       ) ,
    .pIDX_LS       ( pIDX_LS       ) ,
    .pIDX_ZC       ( pIDX_ZC       ) ,
    .pCODE         ( pCODE         ) ,
    .pDO_PUNCT     ( pDO_PUNCT     ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE )
  )
  hb_tab
  (
    .iclk       ( iclk               ) ,
    .ireset     ( ireset             ) ,
    .iclkena    ( iclkena            ) ,
    //
    .oused_zc   ( hb_tab__oused_zc   ) ,
    .oused_row  ( hb_tab__oused_row  ) ,
    //
    .irrow      ( hb_tab__irrow      ) ,
    .iwrow      ( hb_tab__iwrow      ) ,
    //
    .orHb       ( hb_tab__orHb       ) ,
    .owHb       ( hb_tab__owHb       ) ,
    .orHb_pmask ( hb_tab__orHb_pmask )
  );

  //------------------------------------------------------------------------------------------------------
  // ctrl
  //------------------------------------------------------------------------------------------------------

  logic cnode_start_busy;
  logic vnode_start_busy;

  ldpc_3gpp_dec_ctrl
  #(
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE )
  )
  ctrl
  (
    .iclk           ( iclk                 ) ,
    .ireset         ( ireset               ) ,
    .iclkena        ( iclkena              ) ,
    //
    .iNiter         ( iNiter               ) ,
    .ifmode         ( ifmode               ) ,
    //
    .ibuf_full      ( ctrl__ibuf_full      ) ,
    .iobuf_empty    ( ctrl__iobuf_empty    ) ,
    .obuf_rempty    ( ctrl__obuf_rempty    ) ,
    //
    .iused_zc       ( ctrl__iused_zc       ) ,
    .iused_row      ( ctrl__iused_row      ) ,
    //
    .ivnode_busy    ( ctrl__ivnode_busy    ) ,
    //
    .icnode_busy    ( ctrl__icnode_busy    ) ,
    .icnode_decfail ( ctrl__icnode_decfail ) ,
    //
    .oload_mode     ( ctrl__oload_mode     ) ,
    .oc_nv_mode     ( ctrl__oc_nv_mode     ) ,
    //
    .oread          ( ctrl__oread          ) ,
    .orstart        ( ctrl__orstart        ) ,
    .orval          ( ctrl__orval          ) ,
    .orstrb         ( ctrl__orstrb         ) ,
    .orrow          ( ctrl__orrow          ) ,
    //
    .olast_iter     ( ctrl__olast_iter     )
  );

  assign ctrl__ibuf_full      = ibuf_full   ;
  assign ctrl__iobuf_empty    = iobuf_empty ;

  assign obuf_rempty          = ctrl__obuf_rempty ;

  assign ctrl__iused_zc       = hb_tab__oused_zc;
  assign ctrl__iused_row      = hb_tab__oused_row ;

  assign ctrl__ivnode_busy    = vnode_start_busy | vnode__obusy;

  assign ctrl__icnode_busy    = cnode_start_busy | cnode__obusy;
  assign ctrl__icnode_decfail = cnode__odecfail;

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      vnode_start_busy <= 1'b0;
      cnode_start_busy <= 1'b0;
    end
    else if (iclkena) begin
      if (ctrl__oread & ctrl__orstrb.sof & !ctrl__oc_nv_mode)
        vnode_start_busy <= 1'b1;
      else if (vnode__oval)
        vnode_start_busy <= 1'b0;
      //
      if (ctrl__oread & ctrl__orstrb.sof &  ctrl__oc_nv_mode)
        cnode_start_busy <= 1'b1;
      else if (cnode__oval)
        cnode_start_busy <= 1'b0;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // LLR/pLLR read address generator
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_LLR_addr_gen
  #(
    .pADDR_W       ( pADDR_W       ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE )
  )
  LLR_addr_gen
  (
    .iclk       ( iclk                     ) ,
    .ireset     ( ireset                   ) ,
    .iclkena    ( iclkena                  ) ,
    //
    .iused_zc   ( LLR_addr_gen__iused_zc   ) ,
    .ic_nv_mode ( LLR_addr_gen__ic_nv_mode ) ,
    //
    .iread      ( LLR_addr_gen__iread      ) ,
    .irstart    ( LLR_addr_gen__irstart    ) ,
    .irmask     ( LLR_addr_gen__irmask     ) ,
    .irval      ( LLR_addr_gen__irval      ) ,
    .irstrb     ( LLR_addr_gen__irstrb     ) ,
    //
    .oLLR_raddr ( oLLR_raddr               ) ,
    //
    .orval      ( LLR_addr_gen__orval      ) ,
    .orstrb     ( LLR_addr_gen__orstrb     ) ,
    .ormask     ( LLR_addr_gen__ormask     )
  );

  assign LLR_addr_gen__ic_nv_mode = ctrl__oc_nv_mode;

  assign LLR_addr_gen__iused_zc   = hb_tab__oused_zc;

  assign LLR_addr_gen__iread      = ctrl__oread;
  assign LLR_addr_gen__irstart    = ctrl__orstart;

  assign LLR_addr_gen__irmask     = hb_tab__orHb_pmask;

  assign LLR_addr_gen__irval      = ctrl__orval;
  assign LLR_addr_gen__irstrb     = ctrl__orstrb;

  //------------------------------------------------------------------------------------------------------
  // mem
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_mem
  #(
    .pIDX_GR       ( pIDX_GR       ) ,
    .pCODE         ( pCODE         ) ,
    //
    .pADDR_W       ( pADDR_W       ) ,
    //
    .pLLR_W        ( pLLR_W        ) ,
    .pNODE_W       ( pNODE_W       ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE ) ,
    //
    .pUSE_SC_MODE  ( pUSE_SC_MODE  )
  )
  mem
  (
    .iclk       ( iclk            ) ,
    .ireset     ( ireset          ) ,
    .iclkena    ( iclkena         ) ,
    //
    .iused_zc   ( mem__iused_zc   ) ,
    .ic_nv_mode ( mem__ic_nv_mode ) ,
    //
    .iwrite     ( mem__iwrite     ) ,
    .iwHb       ( mem__iwHb       ) ,
    .iwstrb     ( mem__iwstrb     ) ,
    .iwdat      ( mem__iwdat      ) ,
    .iwstate    ( mem__iwstate    ) ,
    //
    .iread      ( mem__iread      ) ,
    .irstart    ( mem__irstart    ) ,
    .irHb       ( mem__irHb       ) ,
    .irval      ( mem__irval      ) ,
    .irstrb     ( mem__irstrb     ) ,
    //
    .orval      ( mem__orval      ) ,
    .orstrb     ( mem__orstrb     ) ,
    .ormask     ( mem__ormask     ) ,
    .ordat      ( mem__ordat      ) ,
    .orstate    ( mem__orstate    )
  );

  assign hb_tab__iwrow    = cnode__orow;

  assign mem__iused_zc    = hb_tab__oused_zc;
  assign mem__iwHb        = hb_tab__owHb ;    // 1 tick read delay

  assign mem__ic_nv_mode  = ctrl__oc_nv_mode;

  // align Hb table read delay
  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ctrl__oc_nv_mode) begin
        mem__iwrite <= cnode__oval  ;
        mem__iwstrb <= cnode__ostrb ;
        mem__iwdat  <= cnode__ocnode;
      end
      else begin
        mem__iwrite <= vnode__oval  ;
        mem__iwstrb <= vnode__ostrb ;
        mem__iwdat  <= vnode__ovnode;
      end
      //
      mem__iwstate  <= vnode__ovstate ;  // write only at vnode phase
    end
  end

  assign hb_tab__irrow  = ctrl__orrow;

  assign mem__irHb      = hb_tab__orHb ;  // 1 tick read delay

  assign mem__iread     = ctrl__oread  ;
  assign mem__irstart   = ctrl__orstart;
  assign mem__irval     = ctrl__orval  ;
  assign mem__irstrb    = ctrl__orstrb ;

  //------------------------------------------------------------------------------------------------------
  // cnode
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_cnode
  #(
    .pIDX_GR       ( pIDX_GR       ) ,
    //
    .pLLR_W        ( pLLR_W        ) ,
    .pNODE_W       ( pNODE_W       ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE ) ,
    //
    .pNORM_FACTOR  ( pCNORM_FACTOR )
  )
  cnode
  (
    .iclk     ( iclk            ) ,
    .ireset   ( ireset          ) ,
    .iclkena  ( iclkena         ) ,
    //
    .ival     ( cnode__ival     ) ,
    .istrb    ( cnode__istrb    ) ,
    .ivmask   ( cnode__ivmask   ) ,
    .ivnode   ( cnode__ivnode   ) ,
    .ipmask   ( cnode__ipmask   ) ,
    .ipLLR    ( cnode__ipLLR    ) ,
    //
    .oval     ( cnode__oval     ) ,
    .ostrb    ( cnode__ostrb    ) ,
    .orow     ( cnode__orow     ) ,
    .ocnode   ( cnode__ocnode   ) ,
    //
    .odecfail ( cnode__odecfail ) ,
    .obusy    ( cnode__obusy    )
  );

  assign cnode__ival    = mem__orval & ctrl__oc_nv_mode;
  assign cnode__istrb   = mem__orstrb ;

  assign cnode__ivmask  = mem__ormask ;
  assign cnode__ivnode  = mem__ordat ;

  assign cnode__ipLLR   = ipLLR ;

  assign cnode__ipmask  = LLR_addr_gen__ormask;

  //------------------------------------------------------------------------------------------------------
  // vnode
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_vnode
  #(
    .pIDX_GR       ( pIDX_GR       ) ,
    .pDO_PUNCT     ( pDO_PUNCT     ) ,
    //
    .pLLR_W        ( pLLR_W        ) ,
    .pNODE_W       ( pNODE_W       ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE ) ,
    //
    .pERR_W        ( pERR_W        ) ,
    .pERR_SFACTOR  ( pERR_SFACTOR  ) ,
    //
    .pNORM_FACTOR  ( pVNORM_FACTOR ) ,
    .pUSE_SC_MODE  ( pUSE_SC_MODE  )
  )
  vnode
  (
    .iclk      ( iclk             ) ,
    .ireset    ( ireset           ) ,
    .iclkena   ( iclkena          ) ,
    //
    .iidxGr    ( vnode__iidxGr    ) ,
    .ido_punct ( vnode__ido_punct ) ,
    .iused_row ( vnode__iused_row ) ,
    //
    .ival      ( vnode__ival      ) ,
    .istrb     ( vnode__istrb     ) ,
    .iLLR      ( vnode__iLLR      ) ,
    .icnode    ( vnode__icnode    ) ,
    .icmask    ( vnode__icmask    ) ,
    .icstate   ( vnode__icstate   ) ,
    //
    .iuval     ( vnode__iuval     ) ,
    .iustrb    ( vnode__iustrb    ) ,
    .iuLLR     ( vnode__iuLLR     ) ,
    //
    .oval      ( vnode__oval      ) ,
    .ostrb     ( vnode__ostrb     ) ,
    .ovnode    ( vnode__ovnode    ) ,
    .ovstate   ( vnode__ovstate   ) ,
    //
    .obitval   ( vnode__obitval   ) ,
    .obitsop   ( vnode__obitsop   ) ,
    .obiteop   ( vnode__obiteop   ) ,
    .obitdat   ( vnode__obitdat   ) ,
    .obiterr   ( vnode__obiterr   ) ,
    //
    .obusy     ( vnode__obusy     )
  );

  assign vnode__iidxGr    = pIDX_GR;
  assign vnode__ido_punct = pDO_PUNCT;
  assign vnode__iused_row = hb_tab__oused_row;

  assign vnode__ival      = mem__orval & !ctrl__oload_mode & !ctrl__oc_nv_mode;
  assign vnode__istrb     = mem__orstrb ;

  assign vnode__iLLR      = iLLR ;

  assign vnode__icnode    = mem__ordat ;
  assign vnode__icmask    = mem__ormask ;
  assign vnode__icstate   = mem__orstate ;

  assign vnode__iuval     = mem__orval & ctrl__oload_mode ;
  assign vnode__iustrb    = mem__orstrb ;
  assign vnode__iuLLR     = iLLR ;

  //------------------------------------------------------------------------------------------------------
  // output mapping
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      oval <= 1'b0;
    end
    else if (iclkena) begin
      oval <= vnode__obitval & ctrl__olast_iter;
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      osop <= vnode__obitsop & ctrl__olast_iter;
      oeop <= vnode__obiteop & ctrl__olast_iter;
      odat <= vnode__obitdat;
      oerr <= vnode__obiterr;
      //
      odecfail <= cnode__odecfail;
      // output tags hold for all cycle
      if (ctrl__obuf_rempty) begin
        otag      <= itag;
        ocode_ctx <= icode_ctx;
      end
    end
  end

endmodule

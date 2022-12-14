/*



  parameter int pIDX_GR       =  0 ;
  parameter int pIDX_LS       =  0 ;
  parameter int pIDX_ZC       =  3 ;
  parameter int pCODE         =  4 ;
  parameter int pDO_PUNCT     =  0 ;
  //
  parameter int pLLR_W        =  8 ;
  parameter int pNODE_W       =  8 ;
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



  logic                ldpc_3gpp_dec_fix__iclk                     ;
  logic                ldpc_3gpp_dec_fix__ireset                   ;
  logic                ldpc_3gpp_dec_fix__iclkena                  ;
  //
  logic        [7 : 0] ldpc_3gpp_dec_fix__iNiter                   ;
  logic                ldpc_3gpp_dec_fix__ifmode                   ;
  //
  logic                ldpc_3gpp_dec_fix__ival                     ;
  logic                ldpc_3gpp_dec_fix__isop                     ;
  logic                ldpc_3gpp_dec_fix__ieop                     ;
  logic [pTAG_W-1 : 0] ldpc_3gpp_dec_fix__itag                     ;
  llr_t                ldpc_3gpp_dec_fix__iLLR     [pLLR_BY_CYCLE] ;
  //
  logic                ldpc_3gpp_dec_fix__obusy                    ;
  logic                ldpc_3gpp_dec_fix__ordy                     ;
  //
  logic                ldpc_3gpp_dec_fix__ireq                     ;
  logic                ldpc_3gpp_dec_fix__ofull                    ;
  //
  logic                ldpc_3gpp_dec_fix__oval                     ;
  logic                ldpc_3gpp_dec_fix__osop                     ;
  logic                ldpc_3gpp_dec_fix__oeop                     ;
  logic [pTAG_W-1 : 0] ldpc_3gpp_dec_fix__otag                     ;
  logic        [7 : 0] ldpc_3gpp_dec_fix__odat                     ;
  //
  logic                ldpc_3gpp_dec_fix__odecfail                 ;
  logic [pERR_W-1 : 0] ldpc_3gpp_dec_fix__oerr                     ;



  ldpc_3gpp_dec_fix
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
  ldpc_3gpp_dec_fix
  (
    .iclk     ( ldpc_3gpp_dec_fix__iclk     ) ,
    .ireset   ( ldpc_3gpp_dec_fix__ireset   ) ,
    .iclkena  ( ldpc_3gpp_dec_fix__iclkena  ) ,
    //
    .iNiter   ( ldpc_3gpp_dec_fix__iNiter   ) ,
    .ifmode   ( ldpc_3gpp_dec_fix__ifmode   ) ,
    //
    .ival     ( ldpc_3gpp_dec_fix__ival     ) ,
    .isop     ( ldpc_3gpp_dec_fix__isop     ) ,
    .ieop     ( ldpc_3gpp_dec_fix__ieop     ) ,
    .itag     ( ldpc_3gpp_dec_fix__itag     ) ,
    .iLLR     ( ldpc_3gpp_dec_fix__iLLR     ) ,
    //
    .obusy    ( ldpc_3gpp_dec_fix__obusy    ) ,
    .ordy     ( ldpc_3gpp_dec_fix__ordy     ) ,
    //
    .ireq     ( ldpc_3gpp_dec_fix__ireq     ) ,
    .ofull    ( ldpc_3gpp_dec_fix__ofull    ) ,
    //
    .oval     ( ldpc_3gpp_dec_fix__oval     ) ,
    .osop     ( ldpc_3gpp_dec_fix__osop     ) ,
    .oeop     ( ldpc_3gpp_dec_fix__oeop     ) ,
    .otag     ( ldpc_3gpp_dec_fix__otag     ) ,
    .odat     ( ldpc_3gpp_dec_fix__odat     ) ,
    //
    .odecfail ( ldpc_3gpp_dec_fix__odecfail ) ,
    .oerr     ( ldpc_3gpp_dec_fix__oerr     )
  );


  assign ldpc_3gpp_dec_fix__iclk    = '0 ;
  assign ldpc_3gpp_dec_fix__ireset  = '0 ;
  assign ldpc_3gpp_dec_fix__iclkena = '0 ;
  assign ldpc_3gpp_dec_fix__iNiter  = '0 ;
  assign ldpc_3gpp_dec_fix__ifmode  = '0 ;
  assign ldpc_3gpp_dec_fix__ival    = '0 ;
  assign ldpc_3gpp_dec_fix__isop    = '0 ;
  assign ldpc_3gpp_dec_fix__ieop    = '0 ;
  assign ldpc_3gpp_dec_fix__itag    = '0 ;
  assign ldpc_3gpp_dec_fix__iLLR    = '0 ;
  assign ldpc_3gpp_dec_fix__ireq    = '0 ;



*/

`include "define.vh"

module ldpc_3gpp_dec_fix
(
  iclk     ,
  ireset   ,
  iclkena  ,
  //
  iNiter   ,
  ifmode   ,
  //
  ival     ,
  isop     ,
  ieop     ,
  itag     ,
  iLLR     ,
  //
  obusy    ,
  ordy     ,
  //
  ireq     ,
  ofull    ,
  //
  oval     ,
  osop     ,
  oeop     ,
  otag     ,
  odat     ,
  //
  odecfail ,
  oerr
);

  parameter int pDAT_W        =  8 ;  // >= pLLR_BY_CYCLE
  //
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

  input  logic                       iclk                     ;
  input  logic                       ireset                   ;
  input  logic                       iclkena                  ;
  //
  input  logic               [7 : 0] iNiter                   ;
  input  logic                       ifmode                   ; // fast work mode with early stop
  //
  input  logic                       ival                     ;
  input  logic                       isop                     ;
  input  logic                       ieop                     ;
  input  logic        [pTAG_W-1 : 0] itag                     ;
  input  logic signed [pLLR_W-1 : 0] iLLR     [pLLR_BY_CYCLE] ;
  //
  output logic                       obusy                    ;
  output logic                       ordy                     ;
  //
  input  logic                       ireq                     ;
  output logic                       ofull                    ;
  //
  output logic                       oval                     ;
  output logic                       osop                     ;
  output logic                       oeop                     ;
  output logic        [pTAG_W-1 : 0] otag                     ;
  output logic        [pDAT_W-1 : 0] odat                     ;
  //
  output logic                       odecfail                 ;
  output logic        [pERR_W-1 : 0] oerr                     ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cZC            = cZC_TAB[pIDX_LS][pIDX_ZC];

  localparam int cIBUF_D_NUM    = cMAX_COL_STEP_NUM * cZC/pLLR_BY_CYCLE;
  localparam int cIBUF_D_ADDR_W = clogb2(cIBUF_D_NUM);

  localparam int cIBUF_P_NUM    = pMAX_ROW_STEP_NUM * cMAX_COL_STEP_NUM * cZC/pLLR_BY_CYCLE;
  localparam int cIBUF_P_ADDR_W = clogb2(cIBUF_P_NUM);

  localparam int cIBUF_TAG_W    = pTAG_W + $bits(code_ctx_t) + 8 + 1;

  // do simple remapping
  localparam int cOBUF_DAT_W    = pDAT_W;
  localparam int cOBUF_DAT_NUM  = ceil(cGR_SYST_BIT_COL[pIDX_GR], pDAT_W/pLLR_BY_CYCLE); // cGR_SYST_BIT_COL[pIDX_GR];
  //
  localparam int cOBUF_NUM      = ceil(cCOL_BY_CYCLE, cOBUF_DAT_NUM) * cZC/cOBUF_DAT_W;
  localparam int cOBUF_ADDR_W   = (cOBUF_NUM == 1) ? 1 : clogb2(cOBUF_NUM);

  localparam int cOBUF_TAG_W    = pTAG_W + $bits(code_ctx_t) + pERR_W + 1; // {decfail, err}

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  ///
  // source
  code_ctx_t                       source__icode_ctx                                                 ;

  logic      [cCOL_BY_CYCLE-1 : 0] source__owrite                                                    ;
  logic                    [1 : 0] source__oclear                                                    ;
  logic      [pROW_BY_CYCLE-1 : 0] source__opwrite                                                   ;
  logic      [pROW_BY_CYCLE-1 : 0] source__opclear                                                   ;
  logic                            source__owfull                                                    ;
  logic     [cIBUF_P_ADDR_W-1 : 0] source__owaddr                                                    ;
  llr_t                            source__owLLR                                     [pLLR_BY_CYCLE] ;

  //
  // ibuf
  logic      [cCOL_BY_CYCLE-1 : 0] ibuffer__iwrite                                                   ;
  logic                    [1 : 0] ibuffer__iclear                                                   ;
  logic      [pROW_BY_CYCLE-1 : 0] ibuffer__ipwrite                                                  ;
  logic      [pROW_BY_CYCLE-1 : 0] ibuffer__ipclear                                                  ;
  logic                            ibuffer__iwfull                                                   ;
  logic     [cIBUF_P_ADDR_W-1 : 0] ibuffer__iwaddr                                                   ;
  llr_t                            ibuffer__iLLR                                     [pLLR_BY_CYCLE] ;
  logic        [cIBUF_TAG_W-1 : 0] ibuffer__iwtag                                                    ;
  //
  logic                            ibuffer__irempty                                                  ;
  logic     [cIBUF_P_ADDR_W-1 : 0] ibuffer__iraddr                                                   ;
  llr_t                            ibuffer__oLLR                      [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  llr_t                            ibuffer__opLLR      [pROW_BY_CYCLE]               [pLLR_BY_CYCLE] ;
  logic        [cIBUF_TAG_W-1 : 0] ibuffer__ortag                                                    ;
  //
  logic                            ibuffer__oempty                                                   ;
  logic                            ibuffer__oemptya                                                  ;
  logic                            ibuffer__ofull                                                    ;
  logic                            ibuffer__ofulla                                                   ;

  //
  // engine
  logic                    [7 : 0] engine__iNiter                                                    ;
  logic                            engine__ifmode                                                    ;
  code_ctx_t                       engine__icode_ctx                                                 ;
  logic             [pTAG_W-1 : 0] engine__itag                                                      ;
  //
  logic                            engine__ibuf_full                                                 ;
  logic                            engine__obuf_rempty                                               ;
  //
  logic                            engine__iobuf_empty                                               ;
  //
  llr_t                            engine__iLLR                       [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  llr_t                            engine__ipLLR       [pROW_BY_CYCLE]               [pLLR_BY_CYCLE] ;
  logic     [cIBUF_P_ADDR_W-1 : 0] engine__oLLR_raddr                                                ;
  //
  code_ctx_t                       engine__ocode_ctx                                                 ;
  //
  logic                            engine__oval                                                      ;
  logic                            engine__osop                                                      ;
  logic                            engine__oeop                                                      ;
  logic      [pLLR_BY_CYCLE-1 : 0] engine__odat                       [cCOL_BY_CYCLE]                ;

  logic             [pTAG_W-1 : 0] engine__otag                                                      ;
  logic                            engine__odecfail                                                  ;
  logic             [pERR_W-1 : 0] engine__oerr                                                      ;

  //
  // engine sink
  code_ctx_t                       engine_sink__icode_ctx                 ;
  //
  logic                            engine_sink__ival                      ;
  logic                            engine_sink__isop                      ;
  logic                            engine_sink__ieop                      ;
  logic      [pLLR_BY_CYCLE-1 : 0] engine_sink__idat      [cCOL_BY_CYCLE] ;
  //
  logic             [pTAG_W-1 : 0] engine_sink__itag                      ;
  logic                            engine_sink__idecfail                  ;
  logic             [pERR_W-1 : 0] engine_sink__ierr                      ;
  //
  code_ctx_t                       engine_sink__ocode_ctx                 ;
  //
  logic                            engine_sink__owrite                    ;
  logic                            engine_sink__owfull                    ;
  logic       [cOBUF_ADDR_W-1 : 0] engine_sink__owaddr                    ;
  logic        [cOBUF_DAT_W-1 : 0] engine_sink__owdat     [cOBUF_DAT_NUM] ;
  //
  logic             [pTAG_W-1 : 0] engine_sink__otag                      ;
  logic                            engine_sink__odecfail                  ;
  logic             [pERR_W-1 : 0] engine_sink__oerr                      ;

  //
  // obuf
  logic                            obuffer__iwrite                  ;
  logic                            obuffer__iwfull                  ;
  logic       [cOBUF_ADDR_W-1 : 0] obuffer__iwaddr                  ;
  logic        [cOBUF_DAT_W-1 : 0] obuffer__iwdat   [cOBUF_DAT_NUM] ;
  logic        [cOBUF_TAG_W-1 : 0] obuffer__iwtag                   ;
  //
  logic                            obuffer__irempty                 ;
  logic       [cOBUF_ADDR_W-1 : 0] obuffer__iraddr                  ;
  logic        [cOBUF_DAT_W-1 : 0] obuffer__ordat   [cOBUF_DAT_NUM] ;
  logic        [cOBUF_TAG_W-1 : 0] obuffer__ortag                   ;
  //
  logic                            obuffer__oempty                  ;
  logic                            obuffer__oemptya                 ;
  logic                            obuffer__ofull                   ;
  logic                            obuffer__ofulla                  ;

  //
  // sink
  code_ctx_t                       sink__icode_ctx                  ;
  //
  logic                            sink__irfull                     ;
  logic        [cOBUF_DAT_W-1 : 0] sink__irdat      [cOBUF_DAT_NUM] ;
  logic             [pTAG_W-1 : 0] sink__irtag                      ;
  //
  logic                            sink__irdecfail                  ;
  logic             [pERR_W-1 : 0] sink__irerr                      ;
  //
  logic                            sink__orempty                    ;
  logic       [cOBUF_ADDR_W-1 : 0] sink__oraddr                     ;


  //------------------------------------------------------------------------------------------------------
  // input source
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_source
  #(
    .pADDR_W       ( cIBUF_P_ADDR_W ) ,
    //
    .pLLR_W        ( pLLR_W         ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE  ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE  )
  )
  source
  (
    .iclk       ( iclk              ) ,
    .ireset     ( ireset            ) ,
    .iclkena    ( iclkena           ) ,
    //
    .isop       ( isop              ) ,
    .ieop       ( ieop              ) ,
    .ival       ( ival              ) ,
    .iLLR       ( iLLR              ) ,
    //
    .icode_ctx  ( source__icode_ctx ) ,
    //
    .obusy      ( obusy             ) ,
    .ordy       ( ordy              ) ,
    //
    .iempty     ( ibuffer__oempty   ) ,
    .iemptya    ( ibuffer__oemptya  ) ,
    .ifull      ( ibuffer__ofull    ) ,
    .ifulla     ( ibuffer__ofulla   ) ,
    //
    .owrite     ( source__owrite    ) ,
    .oclear     ( source__oclear    ) ,
    .opwrite    ( source__opwrite   ) ,
    .opclear    ( source__opclear   ) ,
    .owfull     ( source__owfull    ) ,
    .owaddr     ( source__owaddr    ) ,
    .owLLR      ( source__owLLR     )
  );

  assign source__icode_ctx.idxGr    = pIDX_GR;
  assign source__icode_ctx.idxLs    = pIDX_LS;
  assign source__icode_ctx.idxZc    = pIDX_ZC;
  assign source__icode_ctx.code     = pCODE;
  assign source__icode_ctx.do_punct = pDO_PUNCT;

  //------------------------------------------------------------------------------------------------------
  // input buffer
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_ibuffer
  #(
    .pIDX_GR       ( pIDX_GR        ) ,
    .pCODE         ( pCODE          ) ,
    .pDO_PUNCT     ( pDO_PUNCT      ) ,
    //
    .pD_ADDR_W     ( cIBUF_D_ADDR_W ) ,
    .pP_ADDR_W     ( cIBUF_P_ADDR_W ) ,
    //
    .pLLR_W        ( pLLR_W         ) ,
    //
    .pROW_BY_CYCLE ( pROW_BY_CYCLE  ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE  ) ,
    //
    .pTAG_W        ( cIBUF_TAG_W    )
  )
  ibuffer
  (
    .iclk    ( iclk             ) ,
    .ireset  ( ireset           ) ,
    .iclkena ( iclkena          ) ,
    //
    .iwrite  ( ibuffer__iwrite  ) ,
    .iclear  ( ibuffer__iclear  ) ,
    .ipwrite ( ibuffer__ipwrite ) ,
    .ipclear ( ibuffer__ipclear ) ,
    .iwfull  ( ibuffer__iwfull  ) ,
    .iwaddr  ( ibuffer__iwaddr  ) ,
    .iLLR    ( ibuffer__iLLR    ) ,
    .iwtag   ( ibuffer__iwtag   ) ,
    //
    .irempty ( ibuffer__irempty ) ,
    .iraddr  ( ibuffer__iraddr  ) ,
    .oLLR    ( ibuffer__oLLR    ) ,
    .opLLR   ( ibuffer__opLLR   ) ,
    .ortag   ( ibuffer__ortag   ) ,
    //
    .oempty  ( ibuffer__oempty  ) ,
    .oemptya ( ibuffer__oemptya ) ,
    .ofull   ( ibuffer__ofull   ) ,
    .ofulla  ( ibuffer__ofulla  )
  );

  assign ibuffer__iwrite  = source__owrite;
  assign ibuffer__iclear  = source__oclear;
  assign ibuffer__ipwrite = source__opwrite;
  assign ibuffer__ipclear = source__opclear;
  assign ibuffer__iwfull  = source__owfull;
  assign ibuffer__iwaddr  = source__owaddr;
  assign ibuffer__iLLR    = source__owLLR;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival & isop) begin
        ibuffer__iwtag <= {ifmode, iNiter, source__icode_ctx, itag};
      end
    end
  end

  assign ibuffer__irempty = engine__obuf_rempty;
  assign ibuffer__iraddr  = engine__oLLR_raddr;

  //------------------------------------------------------------------------------------------------------
  // engine
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_engine_fix
  #(
    .pIDX_GR       ( pIDX_GR        ) ,
    .pIDX_LS       ( pIDX_LS        ) ,
    .pIDX_ZC       ( pIDX_ZC        ) ,
    .pCODE         ( pCODE          ) ,
    .pDO_PUNCT     ( pDO_PUNCT      ) ,
    //
    .pLLR_W        ( pLLR_W         ) ,
    .pNODE_W       ( pNODE_W        ) ,
    //
    .pADDR_W       ( cIBUF_P_ADDR_W ) ,
    //
    .pTAG_W        ( pTAG_W         ) ,
    //
    .pERR_W        ( pERR_W         ) ,
    .pERR_SFACTOR  ( pERR_SFACTOR   ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE  ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE  ) ,
    //
    .pVNORM_FACTOR ( pVNORM_FACTOR  ) ,
    .pCNORM_FACTOR ( pCNORM_FACTOR  ) ,
    .pUSE_SC_MODE  ( pUSE_SC_MODE   )
  )
  engine
  (
    .iclk        ( iclk                ) ,
    .ireset      ( ireset              ) ,
    .iclkena     ( iclkena             ) ,
    //
    .iNiter      ( engine__iNiter      ) ,
    .ifmode      ( engine__ifmode      ) ,
    //
    .ibuf_full   ( engine__ibuf_full   ) ,
    .obuf_rempty ( engine__obuf_rempty ) ,
    //
    .icode_ctx   ( engine__icode_ctx   ) ,
    //
    .itag        ( engine__itag        ) ,
    .iLLR        ( engine__iLLR        ) ,
    .ipLLR       ( engine__ipLLR       ) ,
    .oLLR_raddr  ( engine__oLLR_raddr  ) ,
    //
    .iobuf_empty ( engine__iobuf_empty ) ,
    //
    .ocode_ctx   ( engine__ocode_ctx   ) ,
    //
    .oval        ( engine__oval        ) ,
    .osop        ( engine__osop        ) ,
    .oeop        ( engine__oeop        ) ,
    .odat        ( engine__odat        ) ,
    .otag        ( engine__otag        ) ,
    //
    .odecfail    ( engine__odecfail    ) ,
    .oerr        ( engine__oerr        )
  );

  assign {engine__ifmode,
          engine__iNiter,
          engine__icode_ctx,
          engine__itag      } = ibuffer__ortag;

  assign engine__iLLR         = ibuffer__oLLR;
  assign engine__ipLLR        = ibuffer__opLLR;

  assign engine__ibuf_full    = ibuffer__ofull;
  assign engine__iobuf_empty  = obuffer__oempty;

  //------------------------------------------------------------------------------------------------------
  // engine DWC sink
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_engine_sink
  #(
    .pIDX_GR       ( pIDX_GR        ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE  ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE  ) ,
    //
    .pDAT_W        ( cOBUF_DAT_W    ) ,
    .pDAT_NUM      ( cOBUF_DAT_NUM  ) ,
    //
    .pADDR_W       ( cOBUF_ADDR_W   ) ,
    //
    .pERR_W        ( pERR_W         ) ,
    .pTAG_W        ( pTAG_W         )
  )
  engine_sink
  (
    .iclk      ( iclk                   ) ,
    .ireset    ( ireset                 ) ,
    .iclkena   ( iclkena                ) ,
    //
    .icode_ctx ( engine_sink__icode_ctx ) ,
    //
    .ival      ( engine_sink__ival      ) ,
    .isop      ( engine_sink__isop      ) ,
    .ieop      ( engine_sink__ieop      ) ,
    .idat      ( engine_sink__idat      ) ,
    //
    .itag      ( engine_sink__itag      ) ,
    .idecfail  ( engine_sink__idecfail  ) ,
    .ierr      ( engine_sink__ierr      ) ,
    //
    .ocode_ctx ( engine_sink__ocode_ctx ) ,
    //
    .owrite    ( engine_sink__owrite    ) ,
    .owfull    ( engine_sink__owfull    ) ,
    .owaddr    ( engine_sink__owaddr    ) ,
    .owdat     ( engine_sink__owdat     ) ,
    //
    .otag      ( engine_sink__otag      ) ,
    .odecfail  ( engine_sink__odecfail  ) ,
    .oerr      ( engine_sink__oerr      )
  );

  assign engine_sink__ival      = engine__oval;
  assign engine_sink__isop      = engine__osop;
  assign engine_sink__ieop      = engine__oeop;
  assign engine_sink__idat      = engine__odat;

  assign engine_sink__itag      = engine__otag;
  assign engine_sink__idecfail  = engine__odecfail;
  assign engine_sink__ierr      = engine__oerr;

  always_comb begin
    engine_sink__icode_ctx = engine__ocode_ctx;
    //
    engine_sink__icode_ctx.idxGr    = pIDX_GR;
    engine_sink__icode_ctx.idxLs    = pIDX_LS;
    engine_sink__icode_ctx.idxZc    = pIDX_ZC;
    engine_sink__icode_ctx.code     = pCODE;
    engine_sink__icode_ctx.do_punct = pDO_PUNCT;
  end

  //------------------------------------------------------------------------------------------------------
  // output buffer
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_obuffer
  #(
    .pADDR_W  ( cOBUF_ADDR_W  ) ,
    //
    .pDAT_W   ( cOBUF_DAT_W   ) ,
    .pDAT_NUM ( cOBUF_DAT_NUM ) ,
    //
    .pTAG_W   ( cOBUF_TAG_W   )
  )
  obuffer
  (
    .iclk    ( iclk             ) ,
    .ireset  ( ireset           ) ,
    .iclkena ( iclkena          ) ,
    //
    .iwrite  ( obuffer__iwrite  ) ,
    .iwfull  ( obuffer__iwfull  ) ,
    .iwaddr  ( obuffer__iwaddr  ) ,
    .iwdat   ( obuffer__iwdat   ) ,
    .iwtag   ( obuffer__iwtag   ) ,
    //
    .irempty ( obuffer__irempty ) ,
    .iraddr  ( obuffer__iraddr  ) ,
    .ordat   ( obuffer__ordat   ) ,
    .ortag   ( obuffer__ortag   ) ,
    //
    .oempty  ( obuffer__oempty  ) ,
    .oemptya ( obuffer__oemptya ) ,
    .ofull   ( obuffer__ofull   ) ,
    .ofulla  ( obuffer__ofulla  )
  );

  assign obuffer__iwrite  = engine_sink__owrite;
  assign obuffer__iwfull  = engine_sink__owfull;
  assign obuffer__iwaddr  = engine_sink__owaddr;
  assign obuffer__iwdat   = engine_sink__owdat ;

  assign obuffer__iwtag   = { engine_sink__ocode_ctx,
                              engine_sink__odecfail,
                              engine_sink__oerr,
                              engine_sink__otag};

  assign obuffer__irempty = sink__orempty;
  assign obuffer__iraddr  = sink__oraddr;

  //------------------------------------------------------------------------------------------------------
  // sink
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_sink
  #(
    .pIDX_GR  ( pIDX_GR       ) ,
    //
    .pADDR_W  ( cOBUF_ADDR_W  ) ,
    //
    .pDAT_W   ( cOBUF_DAT_W   ) ,
    .pDAT_NUM ( cOBUF_DAT_NUM ) ,
    //
    .pERR_W   ( pERR_W        ) ,
    .pTAG_W   ( pTAG_W        )
  )
  sink
  (
    .iclk      ( iclk            ) ,
    .ireset    ( ireset          ) ,
    .iclkena   ( iclkena         ) ,
    //
    .icode_ctx ( sink__icode_ctx ) ,
    //
    .irfull    ( sink__irfull    ) ,
    .irdat     ( sink__irdat     ) ,
    .irtag     ( sink__irtag     ) ,
    //
    .irdecfail ( sink__irdecfail ) ,
    .irerr     ( sink__irerr     ) ,
    //
    .orempty   ( sink__orempty   ) ,
    .oraddr    ( sink__oraddr    ) ,
    //
    .ireq      ( ireq            ) ,
    .ofull     ( ofull           ) ,
    //
    .oval      ( oval            ) ,
    .osop      ( osop            ) ,
    .oeop      ( oeop            ) ,
    .odat      ( odat            ) ,
    .otag      ( otag            ) ,
    //
    .odecfail  ( odecfail        ) ,
    .oerr      ( oerr            )
  );

  assign sink__irfull = obuffer__ofull;
  assign sink__irdat  = obuffer__ordat;

  always_comb begin
    { sink__icode_ctx ,
      sink__irdecfail ,
      sink__irerr     ,
      sink__irtag     } = obuffer__ortag;
    //
    sink__icode_ctx.idxGr    = pIDX_GR;
    sink__icode_ctx.idxLs    = pIDX_LS;
    sink__icode_ctx.idxZc    = pIDX_ZC;
    sink__icode_ctx.code     = pCODE;
    sink__icode_ctx.do_punct = pDO_PUNCT;
  end

endmodule

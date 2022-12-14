/*



  parameter int pIDX_GR   = 0 ;
  parameter int pIDX_LS   = 0 ;
  parameter int pIDX_ZC   = 3 ;
  parameter int pCODE     = 4 ;
  parameter int pDO_PUNCT = 0 ;
  //
  parameter int pRADDR_W  = 8 ;
  parameter int pWADDR_W  = 8 ;
  parameter int pDAT_W    = 8 ;
  parameter int pTAG_W    = 4 ;



  logic                       ldpc_3gpp_enc_engine_fix__iclk        ;
  logic                       ldpc_3gpp_enc_engine_fix__ireset      ;
  logic                       ldpc_3gpp_enc_engine_fix__iclkena     ;
  //
  logic                       ldpc_3gpp_enc_engine_fix__irbuf_full  ;
  //
  logic        [pDAT_W-1 : 0] ldpc_3gpp_enc_engine_fix__irdat       ;
  logic        [pTAG_W-1 : 0] ldpc_3gpp_enc_engine_fix__irtag       ;
  logic                       ldpc_3gpp_enc_engine_fix__orempty     ;
  logic      [pRADDR_W-1 : 0] ldpc_3gpp_enc_engine_fix__oraddr      ;
  //
  logic                       ldpc_3gpp_enc_engine_fix__iwbuf_empty ;
  //
  code_ctx_t                  ldpc_3gpp_enc_engine_fix__ocode_ctx   ;
  //
  logic                       ldpc_3gpp_enc_engine_fix__owrite      ;
  logic                       ldpc_3gpp_enc_engine_fix__owfull      ;
  logic      [pWADDR_W-1 : 0] ldpc_3gpp_enc_engine_fix__owaddr      ;
  logic        [pDAT_W-1 : 0] ldpc_3gpp_enc_engine_fix__owdat       ;
  logic        [pTAG_W-1 : 0] ldpc_3gpp_enc_engine_fix__owtag       ;



  ldpc_3gpp_enc_engine_fix
  #(
    .pIDX_GR   ( pIDX_GR   ) ,
    .pIDX_LS   ( pIDX_LS   ) ,
    .pIDX_ZC   ( pIDX_ZC   ) ,
    .pCODE     ( pCODE     ) ,
    .pDO_PUNCT ( pDO_PUNCT ) ,
    //
    .pRADDR_W  ( pRADDR_W  ) ,
    .pWADDR_W  ( pWADDR_W  ) ,
    .pDAT_W    ( pDAT_W    ) ,
    .pTAG_W    ( pTAG_W    )
  )
  ldpc_3gpp_enc_engine_fix
  (
    .iclk        ( ldpc_3gpp_enc_engine_fix__iclk        ) ,
    .ireset      ( ldpc_3gpp_enc_engine_fix__ireset      ) ,
    .iclkena     ( ldpc_3gpp_enc_engine_fix__iclkena     ) ,
    //
    .irbuf_full  ( ldpc_3gpp_enc_engine_fix__irbuf_full  ) ,
    //
    .irdat       ( ldpc_3gpp_enc_engine_fix__irdat       ) ,
    .irtag       ( ldpc_3gpp_enc_engine_fix__irtag       ) ,
    .orempty     ( ldpc_3gpp_enc_engine_fix__orempty     ) ,
    .oraddr      ( ldpc_3gpp_enc_engine_fix__oraddr      ) ,
    //
    .iwbuf_empty ( ldpc_3gpp_enc_engine_fix__iwbuf_empty ) ,
    //
    .ocode_ctx   ( ldpc_3gpp_enc_engine_fix__ocode_ctx   ) ,
    //
    .owrite      ( ldpc_3gpp_enc_engine_fix__owrite      ) ,
    .owfull      ( ldpc_3gpp_enc_engine_fix__owfull      ) ,
    .owaddr      ( ldpc_3gpp_enc_engine_fix__owaddr      ) ,
    .owdat       ( ldpc_3gpp_enc_engine_fix__owdat       ) ,
    .owtag       ( ldpc_3gpp_enc_engine_fix__owtag       )
  );


  assign ldpc_3gpp_enc_engine_fix__iclk        = '0 ;
  assign ldpc_3gpp_enc_engine_fix__ireset      = '0 ;
  assign ldpc_3gpp_enc_engine_fix__iclkena     = '0 ;
  assign ldpc_3gpp_enc_engine_fix__irbuf_full  = '0 ;
  assign ldpc_3gpp_enc_engine_fix__irdat       = '0 ;
  assign ldpc_3gpp_enc_engine_fix__irtag       = '0 ;
  assign ldpc_3gpp_enc_engine_fix__iwbuf_empty = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_enc_engine fix.sv
// Description   : fixed mode 3GPP LDPC RTL encoder engine
//

`include "define.vh"

module ldpc_3gpp_enc_engine_fix
(
  iclk        ,
  ireset      ,
  iclkena     ,
  //
  irbuf_full  ,
  //
  irdat       ,
  irtag       ,
  orempty     ,
  oraddr      ,
  //
  iwbuf_empty ,
  //
  ocode_ctx   ,
  //
  owrite      ,
  owfull      ,
  owaddr      ,
  owdat       ,
  owtag
);

  parameter int pRADDR_W  = 8 ;
  parameter int pWADDR_W  = 8 ;
  parameter int pTAG_W    = 4 ;

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_enc_types.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                       iclk        ;
  input  logic                       ireset      ;
  input  logic                       iclkena     ;
  //
  input  logic                       irbuf_full  ;
  //
  input  logic        [pDAT_W-1 : 0] irdat       ;
  input  logic        [pTAG_W-1 : 0] irtag       ;
  output logic                       orempty     ;
  output logic      [pRADDR_W-1 : 0] oraddr      ;
  //
  input  logic                       iwbuf_empty ;
  //
  output code_ctx_t                  ocode_ctx   ;
  //
  output logic                       owrite      ;
  output logic                       owfull      ;
  output logic      [pWADDR_W-1 : 0] owaddr      ;
  output logic        [pDAT_W-1 : 0] owdat       ;
  output logic        [pTAG_W-1 : 0] owtag       ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cZC            = cZC_TAB[pIDX_LS][pIDX_ZC]/pDAT_W;

  localparam int cCODE          = (pCODE < 4) ? 4 : pCODE;

  localparam int cMATRIX_ADDR_W = clogb2(cZC);
  localparam bit cMATRIX_PIPE   = 1;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  //
  // table
  hb_row_t      hb_tab__irow              ;
  //
  hb_zc_t       hb_tab__oused_zc          ;
  hb_row_t      hb_tab__oused_row         ;
  hb_col_t      hb_tab__oused_col         ;
  //
  mm_hb_value_t hb_tab__ou_AC     [4][22] ;

  mm_hb_value_t hb_tab__oinvPsi           ;
  logic         hb_tab__oinvPsi_zero      ;

  mm_hb_value_t hb_tab__op1_B         [3] ;
  mm_hb_value_t hb_tab__op12_P        [3] ;

  //
  // ctrl
  logic         ctrl__ibuf_full    ;
  logic         ctrl__obuf_rempty  ;
  logic         ctrl__iobuf_empty  ;
  //
  logic         ctrl__iinvPsi_zero ;
  hb_zc_t       ctrl__iused_zc     ;
  hb_row_t      ctrl__iused_row    ;
  hb_col_t      ctrl__iused_col    ;
  //
  logic         ctrl__oaddr_clear  ;
  logic         ctrl__oaddr_enable ;
  //
  hb_row_t      ctrl__ohb_row      ;
  //
  logic         ctrl__oacu_write   ;
  logic         ctrl__oacu_wstart  ;
  strb_t        ctrl__oacu_wstrb   ;
  hb_col_t      ctrl__oacu_wcol    ;
  //
  logic         ctrl__oacu_read    ;
  logic         ctrl__oacu_rstart  ;
  logic         ctrl__oacu_rval    ;
  strb_t        ctrl__oacu_rstrb   ;
  //
  logic         ctrl__op1_read     ;
  logic         ctrl__op1_rstart   ;
  logic         ctrl__op1_rval     ;
  strb_t        ctrl__op1_rstrb    ;
  //
  logic         ctrl__op2_read     ;
  logic         ctrl__op2_rstart   ;
  logic         ctrl__op2_rval     ;
  strb_t        ctrl__op2_rstrb    ;
  hb_row_t      ctrl__op2_rrow     ;
  //
  logic         ctrl__op3_read     ;
  logic         ctrl__op3_rstart   ;
  logic         ctrl__op3_rval     ;
  strb_t        ctrl__op3_rstrb    ;

  //
  // acu
  hb_zc_t       acu__iused_zc            ;
  //
  logic         acu__iwrite              ;
  logic         acu__iwstart             ;
  strb_t        acu__iwstrb              ;
  hb_col_t      acu__iwcol               ;
  dat_t         acu__iwdat               ;
  //
  logic         acu__ip_nm_mode          ;
  //
  logic         acu__iread               ;
  logic         acu__irstart             ;
  logic         acu__irval               ;
  strb_t        acu__irstrb              ;
  mm_hb_value_t acu__irHb        [4][22] ;
  //
  logic         acu__oval                ;
  strb_t        acu__ostrb               ;
  dat_t         acu__odat                ;
  //
  logic         acu__owrite2p1           ;
  logic         acu__owstart2p1          ;
  dat_t         acu__owdat2p1            ;
  //
  logic         acu__owrite2p2           ;
  logic         acu__owstart2p2          ;
  dat_t         acu__owdat2p2        [3] ;
  //
  logic         acu__owrite2p3           ;
  logic         acu__owstart2p3          ;
  dat_t         acu__owdat2p3            ;

  //
  // p1
  hb_zc_t       p1__iused_zc   ;
  logic         p1__ibypass    ;
  //
  logic         p1__iwrite     ;
  logic         p1__iwstart    ;
  dat_t         p1__iwdat      ;
  //
  logic         p1__iread      ;
  logic         p1__irstart    ;
  logic         p1__irval      ;
  strb_t        p1__irstrb     ;
  mm_hb_value_t p1__iinvPsi    ;
  //
  logic         p1__oval       ;
  strb_t        p1__ostrb      ;
  dat_t         p1__odat       ;
  //
  logic         p1__owrite2p2  ;
  logic         p1__owstart2p2 ;
  dat_t         p1__owdat2p2   ;

  //
  // p2
  logic         p2__iclk              ;
  logic         p2__ireset            ;
  logic         p2__iclkena           ;
  //
  hb_zc_t       p2__iused_zc          ;
  //
  logic         p2__iwrite4au         ;
  logic         p2__iwstart4au        ;
  dat_t         p2__iwdat4au      [3] ;
  //
  logic         p2__iwrite4p1         ;
  logic         p2__iwstart4p1        ;
  dat_t         p2__iwdat4p1          ;
  //
  logic         p2__iread             ;
  logic         p2__irstart           ;
  logic         p2__irval             ;
  strb_t        p2__irstrb            ;
  hb_row_t      p2__irrow             ;
  mm_hb_value_t p2__irHb          [3] ;
  //
  logic         p2__oval              ;
  strb_t        p2__ostrb             ;
  dat_t         p2__odat              ;
  //
  logic         p2__owrite2p3_p1      ;
  logic         p2__owstart2p3_p1     ;
  dat_t         p2__owdat2p3_p1       ;
  //
  logic         p2__owrite2p3_p2      ;
  logic         p2__owstart2p3_p2     ;
  dat_t         p2__owdat2p3_p2   [3] ;

  //
  // p3
  hb_zc_t       p3__iused_zc       ;

  logic         p3__iwrite4p2      ;
  logic         p3__iwstart4p2     ;
  dat_t         p3__iwdat4p2   [3] ;
  //
  logic         p3__iread          ;
  logic         p3__irstart        ;
  logic         p3__irval          ;
  strb_t        p3__irstrb         ;
  mm_hb_value_t p3__irHb       [3] ;
  //
  dat_t         p3__irdat4acu      ;
  dat_t         p3__irdat4p1       ;
  //
  logic         p3__oval           ;
  strb_t        p3__ostrb          ;
  dat_t         p3__odat           ;

  //------------------------------------------------------------------------------------------------------
  // input buffer addres generator
  //------------------------------------------------------------------------------------------------------

  assign orempty = ctrl__obuf_rempty;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ctrl__oaddr_clear)
        oraddr <= '0;
      else if (ctrl__oaddr_enable)
        oraddr <= oraddr + 1'b1;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // Hb table
  //-----------------------------------------------------------------------------------------------------

  ldpc_3gpp_enc_Hb_fix
  #(
    .pDAT_W    ( pDAT_W    ) ,
    //
    .pIDX_GR   ( pIDX_GR   ) ,
    .pIDX_LS   ( pIDX_LS   ) ,
    .pIDX_ZC   ( pIDX_ZC   ) ,
    .pCODE     ( pCODE     ) ,
    .pDO_PUNCT ( pDO_PUNCT )
  )
  hb_tab
  (
    .iclk         ( iclk                 ) ,
    .ireset       ( ireset               ) ,
    .iclkena      ( iclkena              ) ,
    //
    .irow         ( hb_tab__irow         ) ,
    //
    .oused_zc     ( hb_tab__oused_zc     ) ,
    .oused_row    ( hb_tab__oused_row    ) ,
    .oused_col    ( hb_tab__oused_col    ) ,
    //
    .ou_AC        ( hb_tab__ou_AC        ) ,
    //
    .oinvPsi      ( hb_tab__oinvPsi      ) ,
    .oinvPsi_zero ( hb_tab__oinvPsi_zero ) ,
    //
    .op1_B        ( hb_tab__op1_B        ) ,
    .op12_P       ( hb_tab__op12_P       )
  );

  assign hb_tab__irow = ctrl__ohb_row;

  //------------------------------------------------------------------------------------------------------
  // ctrl
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_enc_ctrl
  #(
    .pDAT_W ( pDAT_W       ) ,
    .pPIPE  ( cMATRIX_PIPE )
  )
  ctrl
  (
    .iclk         ( iclk               ) ,
    .ireset       ( ireset             ) ,
    .iclkena      ( iclkena            ) ,
    //
    .ibuf_full    ( ctrl__ibuf_full    ) ,
    .obuf_rempty  ( ctrl__obuf_rempty  ) ,
    .iobuf_empty  ( ctrl__iobuf_empty  ) ,
    //
    .iinvPsi_zero ( ctrl__iinvPsi_zero ) ,
    .iused_zc     ( ctrl__iused_zc     ) ,
    .iused_row    ( ctrl__iused_row    ) ,
    .iused_col    ( ctrl__iused_col    ) ,
    //
    .oaddr_clear  ( ctrl__oaddr_clear  ) ,
    .oaddr_enable ( ctrl__oaddr_enable ) ,
    //
    .ohb_row      ( ctrl__ohb_row      ) ,
    //
    .oacu_write   ( ctrl__oacu_write   ) ,
    .oacu_wstart  ( ctrl__oacu_wstart  ) ,
    .oacu_wstrb   ( ctrl__oacu_wstrb   ) ,
    .oacu_wcol    ( ctrl__oacu_wcol    ) ,
    //
    .oacu_read    ( ctrl__oacu_read    ) ,
    .oacu_rstart  ( ctrl__oacu_rstart  ) ,
    .oacu_rval    ( ctrl__oacu_rval    ) ,
    .oacu_rstrb   ( ctrl__oacu_rstrb   ) ,
    //
    .op1_read     ( ctrl__op1_read     ) ,
    .op1_rstart   ( ctrl__op1_rstart   ) ,
    .op1_rval     ( ctrl__op1_rval     ) ,
    .op1_rstrb    ( ctrl__op1_rstrb    ) ,
    //
    .op2_read     ( ctrl__op2_read     ) ,
    .op2_rstart   ( ctrl__op2_rstart   ) ,
    .op2_rval     ( ctrl__op2_rval     ) ,
    .op2_rstrb    ( ctrl__op2_rstrb    ) ,
    .op2_rrow     ( ctrl__op2_rrow     ) ,
    //
    .op3_read     ( ctrl__op3_read     ) ,
    .op3_rstart   ( ctrl__op3_rstart   ) ,
    .op3_rval     ( ctrl__op3_rval     ) ,
    .op3_rstrb    ( ctrl__op3_rstrb    )
  );

  assign ctrl__ibuf_full    = irbuf_full;

  assign ctrl__iobuf_empty  = iwbuf_empty;

  assign ctrl__iinvPsi_zero = hb_tab__oinvPsi_zero;
  assign ctrl__iused_zc     = hb_tab__oused_zc;
  assign ctrl__iused_row    = hb_tab__oused_row;
  assign ctrl__iused_col    = hb_tab__oused_col;

  //------------------------------------------------------------------------------------------------------
  // A*u'
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_enc_acu
  #(
    .pADDR_W ( cMATRIX_ADDR_W ) ,
    .pDAT_W  ( pDAT_W         ) ,
    .pIDX_GR ( pIDX_GR        ) ,
    .pPIPE   ( cMATRIX_PIPE   )
  )
  acu
  (
    .iclk        ( iclk            ) ,
    .ireset      ( ireset          ) ,
    .iclkena     ( iclkena         ) ,
    //
    .iused_zc    ( acu__iused_zc   ) ,
    //
    .iwrite      ( acu__iwrite     ) ,
    .iwstart     ( acu__iwstart    ) ,
    .iwstrb      ( acu__iwstrb     ) ,
    .iwcol       ( acu__iwcol      ) ,
    .iwdat       ( acu__iwdat      ) ,
    //
    .iread       ( acu__iread      ) ,
    .irstart     ( acu__irstart    ) ,
    .irval       ( acu__irval      ) ,
    .irstrb      ( acu__irstrb     ) ,
    .irHb        ( acu__irHb       ) ,
    //
    .oval        ( acu__oval       ) ,
    .ostrb       ( acu__ostrb      ) ,
    .odat        ( acu__odat       ) ,
    //
    .owrite2p1   ( acu__owrite2p1  ) ,
    .owstart2p1  ( acu__owstart2p1 ) ,
    .owdat2p1    ( acu__owdat2p1   ) ,
    //
    .owrite2p2   ( acu__owrite2p2  ) ,
    .owstart2p2  ( acu__owstart2p2 ) ,
    .owdat2p2    ( acu__owdat2p2   ) ,
    //
    .owrite2p3   ( acu__owrite2p3  ) ,
    .owstart2p3  ( acu__owstart2p3 ) ,
    .owdat2p3    ( acu__owdat2p3   )
  );

  assign acu__iused_zc  = hb_tab__oused_zc;

  //
  // align input buffer delay
  always_ff @(posedge iclk) begin
    if (iclkena) begin
      acu__iwrite   <= ctrl__oacu_write  ;
      acu__iwstart  <= ctrl__oacu_wstart ;
      acu__iwstrb   <= ctrl__oacu_wstrb  ;
      acu__iwcol    <= ctrl__oacu_wcol   ;
    end
  end

  assign acu__iwdat     = irdat             ;
  //
  assign acu__iread     = ctrl__oacu_read   ;
  assign acu__irstart   = ctrl__oacu_rstart ;
  assign acu__irval     = ctrl__oacu_rval   ;
  assign acu__irstrb    = ctrl__oacu_rstrb  ;

  assign acu__irHb      = hb_tab__ou_AC     ;

  //------------------------------------------------------------------------------------------------------
  // p1 = inv(-E*T^-1*B+D)*(E*(T^-1)*A*u' + C*u')
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_enc_p1
  #(
    .pADDR_W ( cMATRIX_ADDR_W ) ,
    .pDAT_W  ( pDAT_W         ) ,
    .pPIPE   ( cMATRIX_PIPE   )
  )
  p1
  (
    .iclk       ( iclk           ) ,
    .ireset     ( ireset         ) ,
    .iclkena    ( iclkena        ) ,
    //
    .iused_zc   ( p1__iused_zc   ) ,
    .ibypass    ( p1__ibypass    ) ,
    //
    .iwrite     ( p1__iwrite     ) ,
    .iwstart    ( p1__iwstart    ) ,
    .iwdat      ( p1__iwdat      ) ,
    //
    .iread      ( p1__iread      ) ,
    .irstart    ( p1__irstart    ) ,
    .irval      ( p1__irval      ) ,
    .irstrb     ( p1__irstrb     ) ,
    .iinvPsi    ( p1__iinvPsi    ) ,
    //
    .oval       ( p1__oval       ) ,
    .ostrb      ( p1__ostrb      ) ,
    .odat       ( p1__odat       ) ,
    //
    .owrite2p2  ( p1__owrite2p2  ) ,
    .owstart2p2 ( p1__owstart2p2 ) ,
    .owdat2p2   ( p1__owdat2p2   )
  );

  assign p1__iused_zc = hb_tab__oused_zc;
  assign p1__ibypass  = hb_tab__oinvPsi_zero;

  assign p1__iwrite   = acu__owrite2p1  ;
  assign p1__iwstart  = acu__owstart2p1 ;
  assign p1__iwdat    = acu__owdat2p1   ;

  assign p1__iread    = ctrl__op1_read  ;
  assign p1__irstart  = ctrl__op1_rstart;
  assign p1__irval    = ctrl__op1_rval  ;
  assign p1__irstrb   = ctrl__op1_rstrb ;

  assign p1__iinvPsi  = hb_tab__oinvPsi ;

  //------------------------------------------------------------------------------------------------------
  // p2 = (T^-1)*(A*u'+B*p1')
  // T*p1
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_enc_p2
  #(
    .pADDR_W ( cMATRIX_ADDR_W ) ,
    .pDAT_W  ( pDAT_W         ) ,
    .pPIPE   ( cMATRIX_PIPE   )
  )
  p2
  (
    .iclk          ( iclk              ) ,
    .ireset        ( ireset            ) ,
    .iclkena       ( iclkena           ) ,
    //
    .iused_zc      ( p2__iused_zc      ) ,
    //
    .iwrite4au     ( p2__iwrite4au     ) ,
    .iwstart4au    ( p2__iwstart4au    ) ,
    .iwdat4au      ( p2__iwdat4au      ) ,
    //
    .iwrite4p1     ( p2__iwrite4p1     ) ,
    .iwstart4p1    ( p2__iwstart4p1    ) ,
    .iwdat4p1      ( p2__iwdat4p1      ) ,
    //
    .iread         ( p2__iread         ) ,
    .irstart       ( p2__irstart       ) ,
    .irval         ( p2__irval         ) ,
    .irstrb        ( p2__irstrb        ) ,
    .irrow         ( p2__irrow         ) ,
    .irHb          ( p2__irHb          ) ,
    //
    .oval          ( p2__oval          ) ,
    .ostrb         ( p2__ostrb         ) ,
    .odat          ( p2__odat          ) ,
    //
    .owrite2p3_p1  ( p2__owrite2p3_p1  ) ,
    .owstart2p3_p1 ( p2__owstart2p3_p1 ) ,
    .owdat2p3_p1   ( p2__owdat2p3_p1   ) ,
    //
    .owrite2p3_p2  ( p2__owrite2p3_p2  ) ,
    .owstart2p3_p2 ( p2__owstart2p3_p2 ) ,
    .owdat2p3_p2   ( p2__owdat2p3_p2   )
  );

  assign p2__iused_zc   = hb_tab__oused_zc;

  assign p2__iwrite4au  = acu__owrite2p2  ;
  assign p2__iwstart4au = acu__owstart2p2 ;
  assign p2__iwdat4au   = acu__owdat2p2   ;
  //
  assign p2__iwrite4p1  = p1__owrite2p2   ;
  assign p2__iwstart4p1 = p1__owstart2p2  ;
  assign p2__iwdat4p1   = p1__owdat2p2    ;

  //
  assign p2__iread      = ctrl__op2_read  ;
  assign p2__irstart    = ctrl__op2_rstart;
  assign p2__irval      = ctrl__op2_rval  ;
  assign p2__irstrb     = ctrl__op2_rstrb ;
  assign p2__irrow      = ctrl__op2_rrow  ;
  //
  assign p2__irHb       = hb_tab__op1_B   ;

  //------------------------------------------------------------------------------------------------------
  // T*p2
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_enc_p3
  #(
    .pADDR_W ( cMATRIX_ADDR_W ) ,
    .pDAT_W  ( pDAT_W         ) ,
    .pPIPE   ( cMATRIX_PIPE   )
  )
  p3
  (
    .iclk       ( iclk           ) ,
    .ireset     ( ireset         ) ,
    .iclkena    ( iclkena        ) ,
    //
    .iused_zc   ( p3__iused_zc   ) ,
    //
    .iwrite4p2  ( p3__iwrite4p2  ) ,
    .iwstart4p2 ( p3__iwstart4p2 ) ,
    .iwdat4p2   ( p3__iwdat4p2   ) ,
    //
    .iread      ( p3__iread      ) ,
    .irstart    ( p3__irstart    ) ,
    .irval      ( p3__irval      ) ,
    .irstrb     ( p3__irstrb     ) ,
    .irHb       ( p3__irHb       ) ,
    //
    .irdat4acu  ( p3__irdat4acu  ) ,
    .irdat4p1   ( p3__irdat4p1   ) ,
    //
    .oval       ( p3__oval       ) ,
    .ostrb      ( p3__ostrb      ) ,
    .odat       ( p3__odat       )
  );

  assign p3__iused_zc   = hb_tab__oused_zc  ;
  //
  assign p3__iwrite4p2  = p2__owrite2p3_p2  ;
  assign p3__iwstart4p2 = p2__owstart2p3_p2 ;
  assign p3__iwdat4p2   = p2__owdat2p3_p2   ;
  //
  assign p3__iread      = ctrl__op3_read    ;
  assign p3__irstart    = ctrl__op3_rstart  ;
  assign p3__irval      = ctrl__op3_rval    ;
  assign p3__irstrb     = ctrl__op3_rstrb   ;

  assign p3__irHb       = hb_tab__op12_P    ;
  //
  assign p3__irdat4acu  = acu__owdat2p3     ;

  assign p3__irdat4p1   = p2__owdat2p3_p1   ;

  //------------------------------------------------------------------------------------------------------
  // output multiplexer
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      owrite <= '0;
      owfull <= '0;
    end
    else if (iclkena) begin
      owrite <= acu__oval | p1__oval | p2__oval | p3__oval;
      owfull <= (p2__oval & p2__ostrb.eof) | (p3__oval & p3__ostrb.eof);
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (p3__oval) begin
        owdat <= p3__odat;
      end
      else if (p2__oval) begin
        owdat <= p2__odat;
      end
      else if (p1__oval) begin
        owdat <= p1__odat;
      end
      else begin
        owdat <= acu__odat;
      end
      //
      if (acu__oval & acu__ostrb.sof) begin
        owaddr <= '0;
      end
      else if (acu__oval | p1__oval | p2__oval | p3__oval) begin
        owaddr <= owaddr + 1'b1;
      end
      //
      if (acu__oval & acu__ostrb.sof) begin
        owtag               <= irtag;
        //
        ocode_ctx.idxGr     <= pIDX_GR;
        ocode_ctx.idxLs     <= pIDX_LS;
        ocode_ctx.idxZc     <= pIDX_ZC;
        ocode_ctx.code      <= pCODE;
        ocode_ctx.do_punct  <= pDO_PUNCT;
      end
    end
  end

endmodule

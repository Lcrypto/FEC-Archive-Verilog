/*



  parameter bit pIDX_GR       =  0 ;
  parameter bit pCODE         =  0 ;
  //
  parameter int pADDR_W       =  8 ;
  //
  parameter int pLLR_W        =  8 ;
  parameter int pNODE_W       =  8 ;
  //
  parameter int pLLR_BY_CYCLE =  1 ;
  parameter int pROW_BY_CYCLE =  8 ;
  //
  parameter bit pUSE_SC_MODE  =  1 ;



  logic         ldpc_3gpp_dec_mem__iclk                                                     ;
  logic         ldpc_3gpp_dec_mem__ireset                                                   ;
  logic         ldpc_3gpp_dec_mem__iclkena                                                  ;
  //
  hb_zc_t       ldpc_3gpp_dec_mem__iused_zc                                                 ;
  logic         ldpc_3gpp_dec_mem__ic_nv_mode                                               ;
  //
  logic         ldpc_3gpp_dec_mem__iwrite                                                   ;
  mm_hb_value_t ldpc_3gpp_dec_mem__iwHb       [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  strb_t        ldpc_3gpp_dec_mem__iwstrb                                                   ;
  node_t        ldpc_3gpp_dec_mem__iwdat      [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  node_state_t  ldpc_3gpp_dec_mem__iwstate    [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  logic         ldpc_3gpp_dec_mem__iread                                                    ;
  logic         ldpc_3gpp_dec_mem__irstart                                                  ;
  mm_hb_value_t ldpc_3gpp_dec_mem__irHb       [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  logic         ldpc_3gpp_dec_mem__irval                                                    ;
  strb_t        ldpc_3gpp_dec_mem__irstrb                                                   ;
  //
  logic         ldpc_3gpp_dec_mem__orval                                                    ;
  strb_t        ldpc_3gpp_dec_mem__orstrb                                                   ;
  logic         ldpc_3gpp_dec_mem__ormask     [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  node_t        ldpc_3gpp_dec_mem__ordat      [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  node_state_t  ldpc_3gpp_dec_mem__orstate    [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;



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
  ldpc_3gpp_dec_mem
  (
    .iclk       ( ldpc_3gpp_dec_mem__iclk       ) ,
    .ireset     ( ldpc_3gpp_dec_mem__ireset     ) ,
    .iclkena    ( ldpc_3gpp_dec_mem__iclkena    ) ,
    //
    .iused_zc   ( ldpc_3gpp_dec_mem__iused_zc   ) ,
    .ic_nv_mode ( ldpc_3gpp_dec_mem__ic_nv_mode ) ,
    //
    .iwrite     ( ldpc_3gpp_dec_mem__iwrite     ) ,
    .iwHb       ( ldpc_3gpp_dec_mem__iwHb       ) ,
    .iwstrb     ( ldpc_3gpp_dec_mem__iwstrb     ) ,
    .iwdat      ( ldpc_3gpp_dec_mem__iwdat      ) ,
    .iwstate    ( ldpc_3gpp_dec_mem__iwstate    ) ,
    //
    .iread      ( ldpc_3gpp_dec_mem__iread      ) ,
    .irstart    ( ldpc_3gpp_dec_mem__irstart    ) ,
    .irHb       ( ldpc_3gpp_dec_mem__irHb       ) ,
    .irval      ( ldpc_3gpp_dec_mem__irval      ) ,
    .irstrb     ( ldpc_3gpp_dec_mem__irstrb     ) ,
    //
    .orval      ( ldpc_3gpp_dec_mem__orval      ) ,
    .orstrb     ( ldpc_3gpp_dec_mem__orstrb     ) ,
    .ormask     ( ldpc_3gpp_dec_mem__ormask     ) ,
    .ordat      ( ldpc_3gpp_dec_mem__ordat      ) ,
    .orstate    ( ldpc_3gpp_dec_mem__orstate    )
  );


  assign ldpc_3gpp_dec_mem__iclk       = '0 ;
  assign ldpc_3gpp_dec_mem__ireset     = '0 ;
  assign ldpc_3gpp_dec_mem__iclkena    = '0 ;
  assign ldpc_3gpp_dec_mem__iused_zc   = '0 ;
  assign ldpc_3gpp_dec_mem__ic_nv_mode = '0 ;
  assign ldpc_3gpp_dec_mem__iwrite     = '0 ;
  assign ldpc_3gpp_dec_mem__iwHb       = '0 ;
  assign ldpc_3gpp_dec_mem__iwstrb     = '0 ;
  assign ldpc_3gpp_dec_mem__iwdat      = '0 ;
  assign ldpc_3gpp_dec_mem__iwstate    = '0 ;
  assign ldpc_3gpp_dec_mem__iread      = '0 ;
  assign ldpc_3gpp_dec_mem__irstart    = '0 ;
  assign ldpc_3gpp_dec_mem__irHb       = '0 ;
  assign ldpc_3gpp_dec_mem__irval      = '0 ;
  assign ldpc_3gpp_dec_mem__irstrb     = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_mem.sv
// Description   : node multidimentsion mem top level
//

`include "define.vh"

module ldpc_3gpp_dec_mem
(
  iclk       ,
  ireset     ,
  iclkena    ,
  //
  iused_zc   ,
  ic_nv_mode ,
  //
  iwrite     ,
  iwHb       ,
  iwstrb     ,
  iwdat      ,
  iwstate    ,
  //
  iread      ,
  irstart    ,
  irHb       ,
  irval      ,
  irstrb     ,
  //
  orval      ,
  orstrb     ,
  ormask     ,
  ordat      ,
  orstate
);

  `include "../ldpc_3gpp_constants.svh"
  `include "../ldpc_3gpp_hc.svh"

  `include "ldpc_3gpp_dec_types.svh"
  `include "ldpc_3gpp_dec_hc.svh"

  parameter int pADDR_W = cMEM_ADDR_W;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 iclk                                                     ;
  input  logic                 ireset                                                   ;
  input  logic                 iclkena                                                  ;
  //
  input  hb_zc_t               iused_zc                                                 ;
  input  logic                 ic_nv_mode                                               ;
  //
  input  logic                 iwrite                                                   ;
  input  mm_hb_value_t         iwHb       [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  input  strb_t                iwstrb                                                   ;
  input  node_t                iwdat      [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  input  node_state_t          iwstate    [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  input  logic                 iread                                                    ;
  input  logic                 irstart                                                  ;
  input  mm_hb_value_t         irHb       [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  input  logic                 irval                                                    ;
  input  strb_t                irstrb                                                   ;
  //
  output logic                 orval                                                    ;
  output strb_t                orstrb                                                   ;
  output logic                 ormask     [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  output node_t                ordat      [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  output node_state_t          orstate    [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic                 memb__orval         [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  strb_t                memb__orstrb        [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  logic                 memb__ormask        [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  node_t                memb__ordat         [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;

  logic                 memb_state__iwrite                                                ;
  strb_t                memb_state__iwstrb                                                ;
  node_state_t          memb_state__iwstate [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;

  logic                 memb_state__orval                                                 ;
  strb_t                memb_state__orstrb                                                ;
  node_state_t          memb_state__orstate [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  // synthesis translate_off
  bit [pLLR_BY_CYCLE*pNODE_W-1 : 0] mem_mirrow [pROW_BY_CYCLE][cCOL_BY_CYCLE][2**pADDR_W];
  // synthesis translate_on

  //------------------------------------------------------------------------------------------------------
  // node ram
  //------------------------------------------------------------------------------------------------------

  genvar grow, gcol;

  generate
    for (grow = 0; grow < pROW_BY_CYCLE; grow++) begin : node_mem_row_inst
      for (gcol = 0; gcol < cCOL_BY_CYCLE; gcol++) begin : node_mem_col_inst
        if ((gcol < cGR_MAJOR_BIT_COL[pIDX_GR]) & !cHC_MASK[grow][gcol]) begin : inst
          ldpc_3gpp_dec_mem_block
          #(
            .pADDR_W       ( pADDR_W       ) ,
            //
            .pLLR_W        ( pLLR_W        ) ,
            .pNODE_W       ( pNODE_W       ) ,
            //
            .pLLR_BY_CYCLE ( pLLR_BY_CYCLE )
          )
          memb
          (
            .iclk       ( iclk                       ) ,
            .ireset     ( ireset                     ) ,
            .iclkena    ( iclkena                    ) ,
            //
            .iused_zc   ( iused_zc                   ) ,
            .ic_nv_mode ( ic_nv_mode                 ) ,
            //
            .iwrite     ( iwrite                     ) ,
            .iwHb       ( iwHb          [grow][gcol] ) ,
            .iwstrb     ( iwstrb                     ) ,
            .iwdat      ( iwdat         [grow][gcol] ) ,
            //
            .iread      ( iread                      ) ,
            .irstart    ( irstart                    ) ,
            .irHb       ( irHb          [grow][gcol] ) ,
            .irval      ( irval                      ) ,
            .irstrb     ( irstrb                     ) ,
            //
            .orval      ( memb__orval   [grow][gcol] ) ,
            .orstrb     ( memb__orstrb  [grow][gcol] ) ,
            .ormask     ( memb__ormask  [grow][gcol] ) ,
            .ordat      ( memb__ordat   [grow][gcol] )
          );
          // synthesis translate_off
          assign mem_mirrow[grow][gcol] = memb.memb.mem;
          // synthesis translate_on
        end
        else begin
          assign memb__orval  [grow][gcol] = 1'b0;
          assign memb__orstrb [grow][gcol] = '0;
          assign memb__ormask [grow][gcol] = 1'b1;
          assign memb__ordat  [grow][gcol] = '{default : '0};
        end
      end
    end
  endgenerate

  //------------------------------------------------------------------------------------------------------
  // node state ram. use only at vertical step with linear access. that's why can use single ram
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_mem_state_block
  #(
    .pADDR_W       ( pADDR_W       ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE )
  )
  memb_state
  (
    .iclk       ( iclk                  ) ,
    .ireset     ( ireset                ) ,
    .iclkena    ( iclkena               ) ,
    //
    .iused_zc   ( iused_zc              ) ,
    //
    .iwrite     ( memb_state__iwrite    ) ,
    .iwstrb     ( memb_state__iwstrb    ) ,
    .iwstate    ( memb_state__iwstate   ) ,
    //
    .iread      ( iread                 ) ,
    .irstart    ( irstart               ) ,
    .irval      ( irval                 ) ,
    .irstrb     ( irstrb                ) ,
    //
    .orval      ( memb_state__orval     ) ,
    .orstrb     ( memb_state__orstrb    ) ,
    .orstate    ( memb_state__orstate   )
  );

  assign memb_state__iwrite  = pUSE_SC_MODE & iwrite & !ic_nv_mode ;
  assign memb_state__iwstrb  = pUSE_SC_MODE ? iwstrb  : '0  ;
  assign memb_state__iwstate = pUSE_SC_MODE ? iwstate : '{default : '{default : '{default : '0}}};

  assign orval      = memb_state__orval;
  assign orstrb     = memb_state__orstrb;

  assign ormask     = memb__ormask;
  assign ordat      = memb__ordat;

  assign orstate    = pUSE_SC_MODE ? memb_state__orstate : '{default : '{default : '{default : '0}}};

endmodule

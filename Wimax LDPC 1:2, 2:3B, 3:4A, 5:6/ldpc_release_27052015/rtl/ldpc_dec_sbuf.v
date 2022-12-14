/*



  parameter int pCODE         =  1 ;
  parameter int pN            = 48 ;
  parameter int pLLR_W        =  5 ;
  parameter int pLLR_BY_CYCLE =  2 ;
  parameter int pTAG_W        =  4 ;



  logic                         ldpc_dec__iclk                     ;
  logic                         ldpc_dec__ireset                   ;
  logic                         ldpc_dec__iclkena                  ;
  logic                 [7 : 0] ldpc_dec__iNiter                   ;
  logic                         ldpc_dec__isop                     ;
  logic                         ldpc_dec__ieop                     ;
  logic                         ldpc_dec__ival                     ;
  logic          [pTAG_W-1 : 0] ldpc_dec__itag                     ;
  logic signed   [pLLR_W-1 : 0] ldpc_dec__iLLR    [0 : pLLR_NUM-1] ;
  logic                         ldpc_dec__obusy                    ;
  logic                         ldpc_dec__ordy                     ;
  logic                         ldpc_dec__osop                     ;
  logic                         ldpc_dec__oeop                     ;
  logic                         ldpc_dec__oval                     ;
  logic          [pTAG_W-1 : 0] ldpc_dec__otag                     ;
  logic   [pLLR_BY_CYCLE-1 : 0] ldpc_dec__odat                     ;
  logic                [15 : 0] ldpc_dec__oerr                     ;



  ldpc_dec_sbuf
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pTAG_W        ( pTAG_W        )
  )
  ldpc_dec
  (
    .iclk    ( ldpc_dec__iclk    ) ,
    .ireset  ( ldpc_dec__ireset  ) ,
    .iclkena ( ldpc_dec__iclkena ) ,
    .iNiter  ( ldpc_dec__iNiter  ) ,
    .isop    ( ldpc_dec__isop    ) ,
    .ieop    ( ldpc_dec__ieop    ) ,
    .ival    ( ldpc_dec__ival    ) ,
    .itag    ( ldpc_dec__itag    ) ,
    .iLLR    ( ldpc_dec__iLLR    ) ,
    .obusy   ( ldpc_dec__obusy   ) ,
    .ordy    ( ldpc_dec__ordy    ) ,
    .osop    ( ldpc_dec__osop    ) ,
    .oeop    ( ldpc_dec__oeop    ) ,
    .oval    ( ldpc_dec__oval    ) ,
    .otag    ( ldpc_dec__otag    ) ,
    .odat    ( ldpc_dec__odat    ) ,
    .oerr    ( ldpc_dec__oerr    )
  );


  assign ldpc_dec__iclk    = '0 ;
  assign ldpc_dec__ireset  = '0 ;
  assign ldpc_dec__iclkena = '0 ;
  assign ldpc_dec__iNiter  = '0 ;
  assign ldpc_dec__isop    = '0 ;
  assign ldpc_dec__ieop    = '0 ;
  assign ldpc_dec__ival    = '0 ;
  assign ldpc_dec__itag    = '0 ;
  assign ldpc_dec__iLLR    = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_dec_sbuf.v
// Description   : LDPC decoder with static code parameters. Normalized 2D min-sum algorithm is used. Input metrics is straight(!!!). The metric saturation is inside.
//                 The iNiter port and any input tag info latched inside at isop & ival signal. Decoder use 2D input buffer and no any output buffers or output handshake
//                 The decoded systematic bits output during decoding on fly with error counting. Only systematic bit error is take into acount(!!!). The actual oerr value is valid at oeop tag.
//                 Decoder use splitted input buffer to merge ram update & last decoder iteration
//

`include "define.vh"

module ldpc_dec_sbuf
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  iNiter  ,
  //
  isop    ,
  ieop    ,
  ival    ,
  itag    ,
  iLLR    ,
  //
  obusy   ,
  ordy    ,
  //
  osop    ,
  oeop    ,
  oval    ,
  otag    ,
  odat    ,
  oerr
);

  parameter int pLLR_W        = 5 ;
  parameter int pLLR_BY_CYCLE = 8 ; // number of LLR processing at one cycle
  parameter int pTAG_W        = 4 ;

  parameter bit pNORM_VNODE   = 1 ; // 1/0 vnode noramlization coefficient is 0.75/1
  parameter bit pNORM_CNODE   = 1 ; // 1/0 cnode noramlization coefficient is 0.75/1

  `include "ldpc_parameters.vh"
  `include "ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                         iclk                     ;
  input  logic                         ireset                   ;
  input  logic                         iclkena                  ;
  //
  input  logic                 [7 : 0] iNiter                   ;
  //
  input  logic                         isop                     ;
  input  logic                         ieop                     ;
  input  logic                         ival                     ;
  input  logic          [pTAG_W-1 : 0] itag                     ;
  input  logic signed   [pLLR_W-1 : 0] iLLR    [pLLR_BY_CYCLE]  ;
  //
  output logic                         obusy                    ;
  output logic                         ordy                     ;
  //
  output logic                         osop                     ;
  output logic                         oeop                     ;
  output logic                         oval                     ;
  output logic          [pTAG_W-1 : 0] otag                     ;
  output logic   [pLLR_BY_CYCLE-1 : 0] odat                     ;
  //
  output logic                [15 : 0] oerr                     ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cIBUF_TAG_W  = 8 + pTAG_W; // Niter + tag
  localparam int cMEM_TAG_W   = cZCNT_W + cTCNT_W + 3 + 3; // zidx + tidx + cnode_{sop, val, eop} + vnode_{sop, val, eop};

  localparam int cCTRL_CV_OFFSET = 4; // 4 - optimal for used cnode/vnode module latencies at 3/4 and 5/6 coderate
                                      // 5 - optimal for used cnode/vnode module latencies at 1/2 and 2/3 coderate

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  //
  // source

  logic                         source__owrite                  ;
  logic                         source__owfull                  ;
  logic         [cADDR_W-1 : 0] source__owaddr                  ;
  logic signed   [pLLR_W-1 : 0] source__owLLR   [pLLR_BY_CYCLE] ;

  //
  // input buffer
  logic     [cIBUF_TAG_W-1 : 0] ibuf__iwtag                     ;

  logic                         ibuf__iudone                    ;
  logic         [cADDR_W-1 : 0] ibuf__iuraddr                   ;
  logic signed   [pLLR_W-1 : 0] ibuf__ouLLR     [pLLR_BY_CYCLE] ;

  logic                         ibuf__irbusy                    ;
  logic                         ibuf__irempty                   ;
  logic         [cADDR_W-1 : 0] ibuf__iraddr                    ;
  logic signed   [pLLR_W-1 : 0] ibuf__oLLR      [pLLR_BY_CYCLE] ;
  logic     [cIBUF_TAG_W-1 : 0] ibuf__ortag                     ;

  logic                         ibuf__oempty                    ;
  logic                         ibuf__oemptya                   ;
  logic                         ibuf__ofull                     ;
  logic                         ibuf__ofulla                    ;

  //
  // uctrl
  logic                         uctrl__oudone      ;

  mem_addr_t                    uctrl__obuf_addr   ;

  logic                         uctrl__oval        ;
  logic                         uctrl__osop        ;

  //
  // ctrl
  logic                         ctrl__obusy        ;
  logic                         ctrl__obuf_rempty  ;
  logic                         ctrl__oload_mode   ;
  logic                         ctrl__oc_nv_mode   ;

  logic                         ctrl__oaddr_clear  ;
  logic                         ctrl__oaddr_enable ;

  logic                         ctrl__ovnode_sop   ;
  logic                         ctrl__ovnode_val   ;
  logic                         ctrl__ovnode_eop   ;

  logic                         ctrl__ocnode_sop   ;
  logic                         ctrl__ocnode_val   ;
  logic                         ctrl__ocnode_eop   ;

  logic                         ctrl__olast_iter   ;

  //
  // address generator
  mem_addr_t                    addr_gen__obuf_addr                  ;
  mem_addr_t                    addr_gen__oaddr  [pC][pLLR_BY_CYCLE] ;
  mem_sela_t                    addr_gen__osela  [pC][pLLR_BY_CYCLE] ;
  logic                         addr_gen__omask  [pC]                ;
  tcnt_t                        addr_gen__otcnt                      ;
  zcnt_t                        addr_gen__ozcnt                      ;

  //
  // shift mem
  logic      [cMEM_TAG_W-1 : 0] mem__irtag                        ;
  mem_addr_t                    mem__iraddr   [pC][pLLR_BY_CYCLE] ;
  mem_sela_t                    mem__irsela   [pC][pLLR_BY_CYCLE] ;
  logic                         mem__irmask   [pC]                ;
  logic      [cMEM_TAG_W-1 : 0] mem__ortag                        ;
  logic                         mem__ormask   [pC]                ;
  node_t                        mem__ordat    [pC][pLLR_BY_CYCLE] ;

  logic                         mem__iwrite                       ;
  mem_addr_t                    mem__iwaddr   [pC][pLLR_BY_CYCLE] ;
  mem_sela_t                    mem__iwsela   [pC][pLLR_BY_CYCLE] ;
  logic                         mem__iwmask   [pC]                ;
  node_t                        mem__iwdat    [pC][pLLR_BY_CYCLE] ;

  //
  // vertical step
  logic                         vnode__isop                        ;
  logic                         vnode__ival                        ;
  logic                         vnode__ieop                        ;
  logic                         vnode__iload                       ;
  tcnt_t                        vnode__itcnt                       ;
  llr_t                         vnode__iLLR        [pLLR_BY_CYCLE] /* synthesis keep */;
  node_t                        vnode__icnode  [pC][pLLR_BY_CYCLE] ;

  logic                         vnode__oval                        ;
  mem_addr_t                    vnode__oaddr   [pC][pLLR_BY_CYCLE] ;
  mem_sela_t                    vnode__osela   [pC][pLLR_BY_CYCLE] ;
  logic                         vnode__omask   [pC]                ;
  node_t                        vnode__ovnode  [pC][pLLR_BY_CYCLE] ;

  logic                         vnode__obitsop                     ;
  logic                         vnode__obitval                     ;
  logic                         vnode__obiteop                     ;
  logic   [pLLR_BY_CYCLE-1 : 0] vnode__obitdat                     ;
  logic   [pLLR_BY_CYCLE-1 : 0] vnode__obiterr                     ;

  logic                         vnode__obusy                       ;

  //
  // horizontal step
  logic                         cnode__isop                        ;
  logic                         cnode__ival                        ;
  logic                         cnode__ieop                        ;
  tcnt_t                        cnode__itcnt                       ;
  zcnt_t                        cnode__izcnt                       ;
  logic                         cnode__ivmask  [pC]                ;
  node_t                        cnode__ivnode  [pC][pLLR_BY_CYCLE] ;

  logic                         cnode__oval                        ;
  mem_addr_t                    cnode__oaddr   [pC][pLLR_BY_CYCLE] ;
  mem_sela_t                    cnode__osela   [pC][pLLR_BY_CYCLE] ;
  logic                         cnode__omask   [pC]                ;
  node_t                        cnode__ocnode  [pC][pLLR_BY_CYCLE] ;

  logic                         cnode__obusy                       ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  ldpc_dec_source
  #(
    .pADDR_W       ( cADDR_W       ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE )
  )
  source
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    //
    .isop    ( isop    ) ,
    .ieop    ( ieop    ) ,
    .ival    ( ival    ) ,
    .iLLR    ( iLLR    ) ,
    //
    .obusy   ( obusy   ) ,
    .ordy    ( ordy    ) ,
    //
    .iempty  ( ibuf__oempty   ) ,
    .iemptya ( ibuf__oemptya  ) ,
    .ifull   ( ibuf__ofull    ) ,
    .ifulla  ( ibuf__ofulla   ) ,
    //
    .owrite  ( source__owrite ) ,
    .owfull  ( source__owfull ) ,
    .owaddr  ( source__owaddr ) ,
    .owLLR   ( source__owLLR  )
  );

  //------------------------------------------------------------------------------------------------------
  // input buffer : 4 cycle read delay
  //------------------------------------------------------------------------------------------------------

  ldpc_dec_sbuf_input_buffer
  #(
    .pADDR_W       ( cADDR_W       ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pTAG_W        ( cIBUF_TAG_W   )
  )
  ibuf
  (
    .iclk    ( iclk           ) ,
    .ireset  ( ireset         ) ,
    .iclkena ( iclkena        ) ,
    //
    .iwrite  ( source__owrite ) ,
    .iwfull  ( source__owfull ) ,
    .iwaddr  ( source__owaddr ) ,
    .iLLR    ( source__owLLR  ) ,
    //
    .iwtag   ( ibuf__iwtag    ) ,
    //
    .iudone  ( ibuf__iudone   ) ,
    .iuraddr ( ibuf__iuraddr  ) ,
    .ouLLR   ( ibuf__ouLLR    ) ,
    //
    .irbusy  ( ibuf__irbusy   ) ,
    .irempty ( ibuf__irempty  ) ,
    .iraddr  ( ibuf__iraddr   ) ,
    .oLLR    ( ibuf__oLLR     ) ,
    .ortag   ( ibuf__ortag    ) ,
    //
    .oempty  ( ibuf__oempty   ) ,
    .oemptya ( ibuf__oemptya  ) ,
    .ofull   ( ibuf__ofull    ) ,
    .ofulla  ( ibuf__ofulla   )
  );

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival & isop)
        ibuf__iwtag <= {iNiter, itag};
    end
  end

  assign ibuf__iudone   = uctrl__oudone;
  assign ibuf__iuraddr  = uctrl__obuf_addr;

  assign ibuf__iraddr   = addr_gen__obuf_addr;
  assign ibuf__irbusy   = ctrl__obusy;
  assign ibuf__irempty  = ctrl__obuf_rempty;

  //------------------------------------------------------------------------------------------------------
  // Upload controller
  //------------------------------------------------------------------------------------------------------

  ldpc_dec_sbuf_uctrl
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE )
  )
  uctrl
  (
    .iclk        ( iclk              ) ,
    .ireset      ( ireset            ) ,
    .iclkena     ( iclkena           ) ,
    //
    .ibuf_full   ( ibuf__ofull       ) ,
    .obuf_addr   ( uctrl__obuf_addr  ) ,
    //
    .ibuf_rempty ( ctrl__obuf_rempty ) ,
    .oudone      ( uctrl__oudone     ) ,
    //
    .oval        ( uctrl__oval       ) ,
    .osop        ( uctrl__osop       )
  );

  //------------------------------------------------------------------------------------------------------
  // controller
  //------------------------------------------------------------------------------------------------------

  ldpc_dec_sbuf_ctrl
  #(
    .pCODE         ( pCODE           ) ,
    .pN            ( pN              ) ,
    .pLLR_W        ( pLLR_W          ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE   ) ,
    .pCV_OFFSET    ( cCTRL_CV_OFFSET )
  )
  ctrl
  (
    .iclk         ( iclk                     ) ,
    .ireset       ( ireset                   ) ,
    .iclkena      ( iclkena                  ) ,
    //
    .iNiter       ( ibuf__ortag[pTAG_W +: 8] ) ,
    //
    .ibuf_full    ( uctrl__oudone            ) ,
    .obuf_rempty  ( ctrl__obuf_rempty        ) ,
    //
    .obusy        ( ctrl__obusy              ) ,
    //
    .oload_mode   ( ctrl__oload_mode         ) ,
    .oc_nv_mode   ( ctrl__oc_nv_mode         ) ,
    //
    .oaddr_clear  ( ctrl__oaddr_clear        ) ,
    .oaddr_enable ( ctrl__oaddr_enable       ) ,
    //
    .ivnode_busy  ( vnode__obusy             ) ,
    .ovnode_sop   ( ctrl__ovnode_sop         ) ,
    .ovnode_val   ( ctrl__ovnode_val         ) ,
    .ovnode_eop   ( ctrl__ovnode_eop         ) ,
    //
    .icnode_busy  ( cnode__obusy             ) ,
    .ocnode_sop   ( ctrl__ocnode_sop         ) ,
    .ocnode_val   ( ctrl__ocnode_val         ) ,
    .ocnode_eop   ( ctrl__ocnode_eop         ) ,
    //
    .olast_iter   ( ctrl__olast_iter         )
  );

  //------------------------------------------------------------------------------------------------------
  // address generator : 2 cycle delay
  //------------------------------------------------------------------------------------------------------

  ldpc_dec_addr_gen
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE )
  )
  addr_gen
  (
    .iclk       ( iclk                ) ,
    .ireset     ( ireset              ) ,
    .iclkena    ( iclkena             ) ,
    //
    .iclear     ( ctrl__oaddr_clear   ) ,
    .ienable    ( ctrl__oaddr_enable  ) ,
    //
    .iload_mode ( ctrl__oload_mode    ) ,
    .ic_nv_mode ( ctrl__oc_nv_mode    ) ,
    //
    .obuf_addr  ( addr_gen__obuf_addr ) ,
    .oaddr      ( addr_gen__oaddr     ) ,
    .osela      ( addr_gen__osela     ) ,
    .omask      ( addr_gen__omask     ) ,
    .otcnt      ( addr_gen__otcnt     ) ,
    .ozcnt      ( addr_gen__ozcnt     )
  );

  //------------------------------------------------------------------------------------------------------
  // shift ram array :
  //    2 cycle write delay
  //    4 cycle read delay
  //------------------------------------------------------------------------------------------------------

  ldpc_dec_mem
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pTAG_W        ( cMEM_TAG_W    )
  )
  mem
  (
    .iclk    ( iclk         ) ,
    .ireset  ( ireset       ) ,
    .iclkena ( iclkena      ) ,
    //
    .irtag   ( mem__irtag   ) ,
    .iraddr  ( mem__iraddr  ) ,
    .irsela  ( mem__irsela  ) ,
    .irmask  ( mem__irmask  ) ,
    .ortag   ( mem__ortag   ) ,
    .ormask  ( mem__ormask  ) ,
    .ordat   ( mem__ordat   ) ,
    //
    .iwrite  ( mem__iwrite  ) ,
    .iwaddr  ( mem__iwaddr  ) ,
    .iwsela  ( mem__iwsela  ) ,
    .iwmask  ( mem__iwmask  ) ,
    .iwdat   ( mem__iwdat   )
  );

//assign mem__irtag[2 : 0]            = {ctrl__ovnode_eop, ctrl__ovnode_val, ctrl__ovnode_sop};
//assign mem__irtag[5 : 3]            = {ctrl__ocnode_eop, ctrl__ocnode_val, ctrl__ocnode_sop};
  always_ff @(posedge iclk) begin
    if (iclkena) begin
      mem__irtag[2 : 0] <= {ctrl__ovnode_eop, ctrl__ovnode_val, ctrl__ovnode_sop};
      mem__irtag[5 : 3] <= {ctrl__ocnode_eop, ctrl__ocnode_val, ctrl__ocnode_sop};
    end
  end

  assign mem__irtag[cMEM_TAG_W-1 : 6] = {addr_gen__otcnt, addr_gen__ozcnt};

  assign mem__iraddr  = addr_gen__oaddr ;
  assign mem__irsela  = addr_gen__osela ;
  assign mem__irmask  = addr_gen__omask ;

  assign mem__iwrite  = vnode__oval ? vnode__oval   : cnode__oval  ;
  assign mem__iwaddr  = vnode__oval ? vnode__oaddr  : cnode__oaddr ;
  assign mem__iwsela  = vnode__oval ? vnode__osela  : cnode__osela ;
  assign mem__iwmask  = vnode__oval ? vnode__omask  : cnode__omask ;
  assign mem__iwdat   = vnode__oval ? vnode__ovnode : cnode__ocnode;

  //------------------------------------------------------------------------------------------------------
  // Vertical step : read cnode/iLLR -> write vnode
  //------------------------------------------------------------------------------------------------------

  ldpc_dec_sbuf_vnode
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pUSE_NORM     ( pNORM_VNODE   )
  )
  vnode
  (
    .iclk    ( iclk           ) ,
    .ireset  ( ireset         ) ,
    .iclkena ( iclkena        ) ,
    //
    .isop    ( vnode__isop    ) ,
    .ival    ( vnode__ival    ) ,
    .ieop    ( vnode__ieop    ) ,
    .itcnt   ( vnode__itcnt   ) ,
    .iLLR    ( vnode__iLLR    ) ,
    .icnode  ( vnode__icnode  ) ,
    //
    .iusop   ( uctrl__osop    ) ,
    .iuval   ( uctrl__oval    ) ,
    .iuLLR   ( ibuf__ouLLR    ) ,
    //
    .oval    ( vnode__oval    ) ,
    .oaddr   ( vnode__oaddr   ) ,
    .osela   ( vnode__osela   ) ,
    .omask   ( vnode__omask   ) ,
    .ovnode  ( vnode__ovnode  ) ,
    //
    .obitsop ( vnode__obitsop ) ,
    .obitval ( vnode__obitval ) ,
    .obiteop ( vnode__obiteop ) ,
    .obitdat ( vnode__obitdat ) ,
    .obiterr ( vnode__obiterr ) ,
    //
    .obusy   ( vnode__obusy   )
  );

  assign vnode__isop   = mem__ortag[0];
  assign vnode__ival   = mem__ortag[1];
  assign vnode__ieop   = mem__ortag[2];
  assign vnode__itcnt  = mem__ortag[6+cZCNT_W +: cTCNT_W];

  assign vnode__icnode = mem__ordat;

  assign vnode__iLLR   = ibuf__oLLR;

  //------------------------------------------------------------------------------------------------------
  // horizontal step : read vnode -> write cnode
  //------------------------------------------------------------------------------------------------------

  ldpc_dec_cnode
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pUSE_NORM     ( pNORM_CNODE   )
  )
  cnode
  (
    .iclk    ( iclk           ) ,
    .ireset  ( ireset         ) ,
    .iclkena ( iclkena        ) ,
    //
    .isop    ( cnode__isop    ) ,
    .ival    ( cnode__ival    ) ,
    .ieop    ( cnode__ieop    ) ,
    .itcnt   ( cnode__itcnt   ) ,
    .izcnt   ( cnode__izcnt   ) ,
    .ivmask  ( cnode__ivmask  ) ,
    .ivnode  ( cnode__ivnode  ) ,
    //
    .oval    ( cnode__oval    ) ,
    .oaddr   ( cnode__oaddr   ) ,
    .osela   ( cnode__osela   ) ,
    .omask   ( cnode__omask   ) ,
    .ocnode  ( cnode__ocnode  ) ,
    //
    .obusy   ( cnode__obusy   )
  );

  assign cnode__isop    = mem__ortag[3];
  assign cnode__ival    = mem__ortag[4];
  assign cnode__ieop    = mem__ortag[5];
  assign cnode__itcnt   = mem__ortag[6+cZCNT_W +: cTCNT_W];
  assign cnode__izcnt   = mem__ortag[6         +: cZCNT_W];
  assign cnode__ivmask  = mem__ormask;
  assign cnode__ivnode  = mem__ordat;

  //------------------------------------------------------------------------------------------------------
  // output mapping
  //------------------------------------------------------------------------------------------------------

  logic last_iter;

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      oval      <= 1'b0;
      last_iter <= 1'b0;
    end
    else if (iclkena) begin
      oval <= vnode__obitval & (ctrl__olast_iter | last_iter);
      if (vnode__obitval) begin
        if (vnode__obitsop & ctrl__olast_iter)
          last_iter <= 1'b1;
        else if (vnode__obiteop)
          last_iter <= 1'b0;
      end
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (vnode__obitval) begin
        osop <= vnode__obitsop;
        oeop <= vnode__obiteop;
        odat <= vnode__obitdat;
        oerr <= vnode__obitsop ? erracc(vnode__obiterr) : (oerr + erracc(vnode__obiterr));
        if (vnode__obitsop)
          otag <= ibuf__ortag[pTAG_W-1 : 0];
      end
    end
  end

  function logic [15 : 0] erracc (input logic [pLLR_BY_CYCLE-1 : 0] err);
    erracc = 0;
    for (int i = 0; i < pLLR_BY_CYCLE; i++) begin
      erracc = erracc + err[i];
    end
  endfunction

endmodule

/*



  parameter int pCODE         =  1 ;
  parameter int pN            =  1 ;
  parameter int pLLR_W        =  1 ;
  parameter int pLLR_BY_CYCLE =  1 ;
  parameter bit pUSE_NORM     =  1 ;



  logic                            ldpc_dec_vnode__iclk                        ;
  logic                            ldpc_dec_vnode__ireset                      ;
  logic                            ldpc_dec_vnode__iclkena                     ;
  logic                            ldpc_dec_vnode__isop                        ;
  logic                            ldpc_dec_vnode__ival                        ;
  logic                            ldpc_dec_vnode__ieop                        ;
  logic                            ldpc_dec_vnode__iload                       ;
  tcnt_t                           ldpc_dec_vnode__itcnt                       ;
  llr_t                            ldpc_dec_vnode__iLLR        [pLLR_BY_CYCLE] ;
  node_t                           ldpc_dec_vnode__icnode  [pC][pLLR_BY_CYCLE] ;
  logic                            ldpc_dec_vnode__oval                        ;
  mem_addr_t                       ldpc_dec_vnode__oaddr   [pC][pLLR_BY_CYCLE] ;
  mem_sela_t                       ldpc_dec_vnode__osela   [pC][pLLR_BY_CYCLE] ;
  logic                            ldpc_dec_vnode__omask   [pC]                ;
  node_t                           ldpc_dec_vnode__ovnode  [pC][pLLR_BY_CYCLE] ;
  logic                             ldpc_dec_vnode__obitsop                     ;
  logic                            ldpc_dec_vnode__obitval                     ;
  logic                            ldpc_dec_vnode__obiteop                     ;
  logic      [pLLR_BY_CYCLE-1 : 0] ldpc_dec_vnode__obitdat                     ;
  logic      [pLLR_BY_CYCLE-1 : 0] ldpc_dec_vnode__obiterr                     ;
  logic                            ldpc_dec_vnode__obusy                       ;



  ldpc_dec_vnode
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pUSE_NORM     ( pUSE_NORM     )
  )
  ldpc_dec_vnode
  (
    .iclk    ( ldpc_dec_vnode__iclk    ) ,
    .ireset  ( ldpc_dec_vnode__ireset  ) ,
    .iclkena ( ldpc_dec_vnode__iclkena ) ,
    .isop    ( ldpc_dec_vnode__isop    ) ,
    .ival    ( ldpc_dec_vnode__ival    ) ,
    .ieop    ( ldpc_dec_vnode__ieop    ) ,
    .iload   ( ldpc_dec_vnode__iload   ) ,
    .itcnt   ( ldpc_dec_vnode__itcnt   ) ,
    .iLLR    ( ldpc_dec_vnode__iLLR    ) ,
    .icnode  ( ldpc_dec_vnode__icnode  ) ,
    .oval    ( ldpc_dec_vnode__oval    ) ,
    .oaddr   ( ldpc_dec_vnode__oaddr   ) ,
    .osela   ( ldpc_dec_vnode__osela   ) ,
    .omask   ( ldpc_dec_vnode__omask   ) ,
    .ovnode  ( ldpc_dec_vnode__ovnode  ) ,
    .obitsop ( ldpc_dec_vnode__obitsop ) ,
    .obitval ( ldpc_dec_vnode__obitval ) ,
    .obiteop ( ldpc_dec_vnode__obiteop ) ,
    .obitdat ( ldpc_dec_vnode__obitdat ) ,
    .obiterr ( ldpc_dec_vnode__obiterr ) ,
    .obusy   ( ldpc_dec_vnode__obusy   )
  );


  assign ldpc_dec_vnode__iclk    = '0 ;
  assign ldpc_dec_vnode__ireset  = '0 ;
  assign ldpc_dec_vnode__iclkena = '0 ;
  assign ldpc_dec_vnode__isop    = '0 ;
  assign ldpc_dec_vnode__ival    = '0 ;
  assign ldpc_dec_vnode__ieop    = '0 ;
  assign ldpc_dec_vnode__iload   = '0 ;
  assign ldpc_dec_vnode__itcnt   = '0 ;
  assign ldpc_dec_vnode__iLLR    = '0 ;
  assign ldpc_dec_vnode__icnode  = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_dec_vnode.v
// Description   : LDPC decoder variable node arithmetic top module: read cnode and count vnode. Consist of pLLR_BY_CYCLE engines.
//

`include "define.vh"

module ldpc_dec_vnode
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  isop    ,
  ival    ,
  ieop    ,
  iload   ,
  itcnt   ,
  iLLR    ,
  icnode  ,
  //
  oval    ,
  oaddr   ,
  osela   ,
  omask   ,
  ovnode  ,
  //
  obitsop ,
  obitval ,
  obiteop ,
  obitdat ,
  obiterr ,
  //
  obusy
);

  parameter int pLLR_W        = 4;
  parameter int pLLR_BY_CYCLE = 2;
  parameter bit pUSE_NORM     = 1; // use normalization

  `include "ldpc_parameters.vh"
  `include "ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                        iclk                        ;
  input  logic                        ireset                      ;
  input  logic                        iclkena                     ;
  //
  input  logic                        isop                        ;
  input  logic                        ival                        ;
  input  logic                        ieop                        ;
  input  logic                        iload                       ;
  input  tcnt_t                       itcnt                       ;
  input  llr_t                        iLLR        [pLLR_BY_CYCLE] ;
  input  node_t                       icnode  [pC][pLLR_BY_CYCLE] ;
  //
  output logic                        oval                        ;
  output mem_addr_t                   oaddr   [pC][pLLR_BY_CYCLE] ;
  output mem_sela_t                   osela   [pC][pLLR_BY_CYCLE] ;
  output logic                        omask   [pC] /* synthesis keep */ ;
  output node_t                       ovnode  [pC][pLLR_BY_CYCLE] ;
  //
  output logic                        obitsop                     ;
  output logic                        obitval                     ;
  output logic                        obiteop                     ;
  output logic  [pLLR_BY_CYCLE-1 : 0] obitdat                     ;
  output logic  [pLLR_BY_CYCLE-1 : 0] obiterr                     ;
  //
  output logic                        obusy                       ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  node_t                       engine__icnode  [pLLR_BY_CYCLE][pC] ;

  logic  [pLLR_BY_CYCLE-1 : 0] engine__osop                        ;
  logic  [pLLR_BY_CYCLE-1 : 0] engine__oval                        ;
  logic  [pLLR_BY_CYCLE-1 : 0] engine__oeop                        ;
  tcnt_t                       engine__otcnt   [pLLR_BY_CYCLE]     ;
  node_t                       engine__ovnode  [pLLR_BY_CYCLE][pC] ;

  logic  [pLLR_BY_CYCLE-1 : 0] engine__obitsop                     ;
  logic  [pLLR_BY_CYCLE-1 : 0] engine__obitval                     ;
  logic  [pLLR_BY_CYCLE-1 : 0] engine__obiteop                     ;
  logic  [pLLR_BY_CYCLE-1 : 0] engine__obitdat                     ;
  logic  [pLLR_BY_CYCLE-1 : 0] engine__obiterr                     ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  generate
    genvar i;
    for (i = 0; i < pLLR_BY_CYCLE; i++) begin : v_engine_inst
      ldpc_dec_vnode_engine
      #(
        .pCODE         ( pCODE         ) ,
        .pN            ( pN            ) ,
        .pLLR_W        ( pLLR_W        ) ,
        .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
        .pUSE_NORM     ( pUSE_NORM     )
      )
      engine
      (
        .iclk    ( iclk    ) ,
        .ireset  ( ireset  ) ,
        .iclkena ( iclkena ) ,
        //
        .isop    ( isop                ) ,
        .ival    ( ival                ) ,
        .ieop    ( ieop                ) ,
        .iload   ( iload               ) ,
        .itcnt   ( itcnt               ) ,
        .iLLR    ( iLLR            [i] ) ,
        .icnode  ( engine__icnode  [i] ) ,
        //
        .osop    ( engine__osop    [i] ) ,
        .oval    ( engine__oval    [i] ) ,
        .oeop    ( engine__oeop    [i] ) ,
        .otcnt   ( engine__otcnt   [i] ) ,
        .ovnode  ( engine__ovnode  [i] ) ,
        //
        .obitsop ( engine__obitsop [i] ) ,
        .obitval ( engine__obitval [i] ) ,
        .obiteop ( engine__obiteop [i] ) ,
        .obitdat ( engine__obitdat [i] ) ,
        .obiterr ( engine__obiterr [i] )
      );

      always_comb begin
        for (int c = 0; c < pC; c++) begin
          engine__icnode[i][c] = icnode[c][i];
        end
      end

    end
  endgenerate

  assign obitsop  = engine__obitsop[0];
  assign obitval  = engine__obitval[0];
  assign obiteop  = engine__obiteop[0];
  assign obitdat  = engine__obitdat;
  assign obiterr  = engine__obiterr;

  assign obusy    = 1'b0; // not need to wait

  //------------------------------------------------------------------------------------------------------
  // output data and address generation
  //------------------------------------------------------------------------------------------------------

  mem_addr_t waddr;

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= engine__oval[0];
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (engine__oval[0]) begin
        for (int c = 0; c < pC; c++) begin
//        omask[c]  <= Hb[c][engine__otcnt[0]][31];
          for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
            ovnode[c][llra] <= engine__ovnode[llra][c];
            waddr           <= engine__osop[0] ? '0 : (waddr + 1'b1);
          end
        end
      end
    end
  end

  always_comb begin
    for (int c = 0; c < pC; c++) begin
      omask[c] = 1'b0; // not need, this mask moved to cnode input
      for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
        osela[c][llra] = llra[cSELA_W-1 : 0];
        oaddr[c][llra] = waddr;
      end
    end
  end

endmodule

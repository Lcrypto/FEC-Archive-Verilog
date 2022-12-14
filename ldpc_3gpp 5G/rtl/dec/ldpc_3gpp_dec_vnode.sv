/*


  parameter bit pIDX_GR       =  0 ;
  parameter bit pDO_PUNCT     =  0 ;
  //
  parameter int pLLR_W        =  4 ;
  parameter int pNODE_W       =  4 ;
  //
  parameter int pROW_BY_CYCLE =  8 ;
  parameter int pLLR_BY_CYCLE =  1 ;
  //
  parameter int pERR_W        = 16 ;
  parameter int pERR_SFACTOR  =  2 ;
  //
  parameter int pNORM_FACTOR  =  7 ;
  parameter bit pUSE_SC_MODE  =  1 ;




  logic                            ldpc_3gpp_dec_vnode__iclk                                                  ;
  logic                            ldpc_3gpp_dec_vnode__ireset                                                ;
  logic                            ldpc_3gpp_dec_vnode__iclkena                                               ;
  //
  logic                            ldpc_3gpp_dec_vnode__iidxGr                                                ;
  logic                            ldpc_3gpp_dec_vnode__ido_punct                                             ;
  hb_row_t                         ldpc_3gpp_dec_vnode__iused_row                                             ;
  //
  logic                            ldpc_3gpp_dec_vnode__ival                                                  ;
  strb_t                           ldpc_3gpp_dec_vnode__istrb                                                 ;
  llr_t                            ldpc_3gpp_dec_vnode__iLLR                   [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  node_t                           ldpc_3gpp_dec_vnode__icnode  [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  logic                            ldpc_3gpp_dec_vnode__icmask  [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  node_state_t                     ldpc_3gpp_dec_vnode__icstate [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  logic                            ldpc_3gpp_dec_vnode__iuval                                                 ;
  strb_t                           ldpc_3gpp_dec_vnode__iustrb                                                ;
  llr_t                            ldpc_3gpp_dec_vnode__iuLLR                  [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  logic                            ldpc_3gpp_dec_vnode__oval                                                  ;
  strb_t                           ldpc_3gpp_dec_vnode__ostrb                                                 ;
  node_t                           ldpc_3gpp_dec_vnode__ovnode  [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  node_state_t                     ldpc_3gpp_dec_vnode__ovstate [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  logic                            ldpc_3gpp_dec_vnode__obitval                                               ;
  logic                            ldpc_3gpp_dec_vnode__obitsop                                               ;
  logic                            ldpc_3gpp_dec_vnode__obiteop                                               ;
  logic      [pLLR_BY_CYCLE-1 : 0] ldpc_3gpp_dec_vnode__obitdat                [cCOL_BY_CYCLE]                ;
  logic             [pERR_W-1 : 0] ldpc_3gpp_dec_vnode__obiterr                                               ;
  //
  logic                            ldpc_3gpp_dec_vnode__obusy                                                 ;



  ldpc_3gpp_dec_vnode
  #(
    .pIDX_GR       ( pIDX_GR       ) ,
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
    .pNORM_FACTOR  ( pNORM_FACTOR  ) ,
    .pUSE_SC_MODE  ( pUSE_SC_MODE  )
  )
  ldpc_3gpp_dec_vnode
  (
    .iclk      ( ldpc_3gpp_dec_vnode__iclk      ) ,
    .ireset    ( ldpc_3gpp_dec_vnode__ireset    ) ,
    .iclkena   ( ldpc_3gpp_dec_vnode__iclkena   ) ,
    //
    .iidxGr    ( ldpc_3gpp_dec_vnode__iidxGr    ) ,
    .ido_punct ( ldpc_3gpp_dec_vnode__ido_punct ) ,
    .iused_row ( ldpc_3gpp_dec_vnode__iused_row ) ,
    //
    .ival      ( ldpc_3gpp_dec_vnode__ival      ) ,
    .istrb     ( ldpc_3gpp_dec_vnode__istrb     ) ,
    .iLLR      ( ldpc_3gpp_dec_vnode__iLLR      ) ,
    .icnode    ( ldpc_3gpp_dec_vnode__icnode    ) ,
    .icmask    ( ldpc_3gpp_dec_vnode__icmask    ) ,
    .icstate   ( ldpc_3gpp_dec_vnode__icstate   ) ,
    //
    .iuval     ( ldpc_3gpp_dec_vnode__iuval     ) ,
    .iustrb    ( ldpc_3gpp_dec_vnode__iustrb    ) ,
    .iuLLR     ( ldpc_3gpp_dec_vnode__iuLLR     ) ,
    //
    .oval      ( ldpc_3gpp_dec_vnode__oval      ) ,
    .ostrb     ( ldpc_3gpp_dec_vnode__ostrb     ) ,
    .ovnode    ( ldpc_3gpp_dec_vnode__ovnode    ) ,
    .ovstate   ( ldpc_3gpp_dec_vnode__ovstate   ) ,
    //
    .obitsop   ( ldpc_3gpp_dec_vnode__obitsop   ) ,
    .obitval   ( ldpc_3gpp_dec_vnode__obitval   ) ,
    .obiteop   ( ldpc_3gpp_dec_vnode__obiteop   ) ,
    .obitdat   ( ldpc_3gpp_dec_vnode__obitdat   ) ,
    .obiterr   ( ldpc_3gpp_dec_vnode__obiterr   ) ,
    //
    .obusy     ( ldpc_3gpp_dec_vnode__obusy     )
  );


  assign ldpc_3gpp_dec_vnode__iclk      = '0 ;
  assign ldpc_3gpp_dec_vnode__ireset    = '0 ;
  assign ldpc_3gpp_dec_vnode__iclkena   = '0 ;
  assign ldpc_3gpp_dec_vnode__iidxGr    = '0 ;
  assign ldpc_3gpp_dec_vnode__ido_punct = '0 ;
  assign ldpc_3gpp_dec_vnode__iused_row = '0 ;
  assign ldpc_3gpp_dec_vnode__ival      = '0 ;
  assign ldpc_3gpp_dec_vnode__istrb     = '0 ;
  assign ldpc_3gpp_dec_vnode__iLLR      = '0 ;
  assign ldpc_3gpp_dec_vnode__icnode    = '0 ;
  assign ldpc_3gpp_dec_vnode__icmask    = '0 ;
  assign ldpc_3gpp_dec_vnode__icstate   = '0 ;
  assign ldpc_3gpp_dec_vnode__iuval     = '0 ;
  assign ldpc_3gpp_dec_vnode__iustrb    = '0 ;
  assign ldpc_3gpp_dec_vnode__iuLLR     = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_vnode.sv
// Description   : LDPC decoder variable node arithmetic top module: read cnode and count vnode and output bits.
//                 Consist of pLLR_BY_CYCLE*cCOL_BY_CYCLE engines by pROW_BY_CYCLE nodes
//

`include "define.vh"

module ldpc_3gpp_dec_vnode
(
  iclk      ,
  ireset    ,
  iclkena   ,
  //
  iidxGr    ,
  ido_punct ,
  iused_row ,
  //
  ival      ,
  istrb     ,
  iLLR      ,
  icnode    ,
  icmask    ,
  icstate   ,
  //
  iuval     ,
  iustrb    ,
  iuLLR     ,
  //
  oval      ,
  ostrb     ,
  ovnode    ,
  ovstate   ,
  //
  obitval   ,
  obitsop   ,
  obiteop   ,
  obitdat   ,
  obiterr   ,
  //
  obusy
);

  parameter int pNORM_FACTOR     = 7;  // pNORM_FACTOR/8 - normalization factor

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_dec_types.svh"

  localparam int cERR_MAX = cCOL_BY_CYCLE * pLLR_BY_CYCLE;

  parameter int pERR_W        = clogb2(cERR_MAX + 1);
  parameter int pERR_SFACTOR  = 2;  // wide error vector split factor on two adder stage

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                        iclk                                                  ;
  input  logic                        ireset                                                ;
  input  logic                        iclkena                                               ;
  //
  input  logic                        iidxGr                                                ;
  input  logic                        ido_punct                                             ;
  input  hb_row_t                     iused_row                                             ;
  // cycle work interface
  input  logic                        ival                                                  ;
  input  strb_t                       istrb                                                 ;
  input  llr_t                        iLLR                   [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  input  node_t                       icnode  [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  input  logic                        icmask  [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  input  node_state_t                 icstate [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  // initial upload interface
  input  logic                        iuval                                                 ;
  input  strb_t                       iustrb                                                ;
  input  llr_t                        iuLLR                  [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  // vnode interface
  output logic                        oval                                                  ;
  output strb_t                       ostrb                                                 ;
  output node_t                       ovnode  [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  output node_state_t                 ovstate [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  output logic                        obitval                                               ;
  output logic                        obitsop                                               ;
  output logic                        obiteop                                               ;
  output logic  [pLLR_BY_CYCLE-1 : 0] obitdat                [cCOL_BY_CYCLE]                ;
  output logic         [pERR_W-1 : 0] obiterr                                               ;
  //
  output logic                        obusy                                                 ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cERR_STAGE   = ceil(cERR_MAX, pERR_SFACTOR);
  localparam int cERR_STAGE_W = clogb2(cERR_STAGE+ 1); // +1 to prevent overflow if cERR_MAX = 2^N

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic                          engine__ival                                                  ;
  strb_t                         engine__istrb                                                 ;
  llr_t                          engine__iLLR    [cCOL_BY_CYCLE][pLLR_BY_CYCLE]                ;
  node_t                         engine__icnode  [cCOL_BY_CYCLE][pLLR_BY_CYCLE][pROW_BY_CYCLE] ;
  logic                          engine__icmask  [cCOL_BY_CYCLE][pLLR_BY_CYCLE][pROW_BY_CYCLE] ;
  node_state_t                   engine__icstate [cCOL_BY_CYCLE][pLLR_BY_CYCLE][pROW_BY_CYCLE] ;

  logic                          engine__oval    [cCOL_BY_CYCLE][pLLR_BY_CYCLE]                ;
  strb_t                         engine__ostrb   [cCOL_BY_CYCLE][pLLR_BY_CYCLE]                ;
  node_t                         engine__ovnode  [cCOL_BY_CYCLE][pLLR_BY_CYCLE][pROW_BY_CYCLE] ;
  node_state_t                   engine__ovstate [cCOL_BY_CYCLE][pLLR_BY_CYCLE][pROW_BY_CYCLE] ;

  logic    [pLLR_BY_CYCLE-1 : 0] engine__obitsop [cCOL_BY_CYCLE]                               ;
  logic    [pLLR_BY_CYCLE-1 : 0] engine__obitval [cCOL_BY_CYCLE]                               ;
  logic    [pLLR_BY_CYCLE-1 : 0] engine__obiteop [cCOL_BY_CYCLE]                               ;
  logic    [pLLR_BY_CYCLE-1 : 0] engine__obitdat [cCOL_BY_CYCLE]                               ;
  logic    [pLLR_BY_CYCLE-1 : 0] engine__obiterr [cCOL_BY_CYCLE]                               ;

  logic                          bitsop                 ;
  logic                          bitval                 ;
  logic                          biteop                 ;
  logic    [pLLR_BY_CYCLE-1 : 0] bitdat [cCOL_BY_CYCLE] ;
  logic     [cERR_STAGE_W-1 : 0] biterr [pERR_SFACTOR]  ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      engine__ival <= 1'b0 ;
    else if (iclkena)
      engine__ival <= ival ;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      engine__istrb <= istrb;
      engine__iLLR  <= iLLR ;
    end
  end

  genvar gcol, gllr;

  generate
    for (gcol = 0; gcol < cCOL_BY_CYCLE; gcol++) begin : v_engine_col_inst
      for (gllr = 0; gllr < pLLR_BY_CYCLE; gllr++) begin : v_engine_llr_inst
        if (gcol < cGR_MAJOR_BIT_COL[pIDX_GR]) begin
          ldpc_3gpp_dec_vnode_engine
          #(
            .pLLR_W        ( pLLR_W        ) ,
            .pNODE_W       ( pNODE_W       ) ,
            //
            .pROW_BY_CYCLE ( pROW_BY_CYCLE ) ,
            //
            .pNORM_FACTOR  ( pNORM_FACTOR  ) ,
            .pUSE_SC_MODE  ( pUSE_SC_MODE  )
          )
          engine
          (
            .iclk      ( iclk                        ) ,
            .ireset    ( ireset                      ) ,
            .iclkena   ( iclkena                     ) ,
            //
            .iused_row ( iused_row                   ) ,
            //
            .ival      ( engine__ival                ) ,
            .istrb     ( engine__istrb               ) ,
            .iLLR      ( engine__iLLR    [gcol][gllr] ) ,
            .icnode    ( engine__icnode  [gcol][gllr] ) ,
            .icmask    ( engine__icmask  [gcol][gllr] ) ,
            .icstate   ( engine__icstate [gcol][gllr] ) ,
            //
            .oval      ( engine__oval    [gcol][gllr] ) ,
            .ostrb     ( engine__ostrb   [gcol][gllr] ) ,
            .ovnode    ( engine__ovnode  [gcol][gllr] ) ,
            .ovstate   ( engine__ovstate [gcol][gllr] ) ,
            //
            .obitsop   ( engine__obitsop [gcol][gllr] ) ,
            .obitval   ( engine__obitval [gcol][gllr] ) ,
            .obiteop   ( engine__obiteop [gcol][gllr] ) ,
            .obitdat   ( engine__obitdat [gcol][gllr] ) ,
            .obiterr   ( engine__obiterr [gcol][gllr] )
          );

          always_ff @(posedge iclk) begin
            if (iclkena) begin
              for (int row = 0; row < pROW_BY_CYCLE; row++) begin
                engine__icnode  [gcol][gllr][row] <= icnode  [row][gcol][gllr];
                engine__icmask  [gcol][gllr][row] <= icmask  [row][gcol];
                engine__icstate [gcol][gllr][row] <= icstate [row][gcol][gllr];
              end
            end
          end
        end
        else begin
          assign engine__oval    [gcol][gllr] = '0;
          assign engine__ostrb   [gcol][gllr] = '0;
          assign engine__ovnode  [gcol][gllr] = '{default : '0};
          assign engine__ovstate [gcol][gllr] = '{default : '0};

          assign engine__obitsop [gcol][gllr] = '0;
          assign engine__obitval [gcol][gllr] = '0;
          assign engine__obiteop [gcol][gllr] = '0;
          assign engine__obitdat [gcol][gllr] = '0;
          assign engine__obiterr [gcol][gllr] = '0;
        end

      end // gllr
    end // gcol
  endgenerate

  //------------------------------------------------------------------------------------------------------
  // vnode interface
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= iuval | engine__oval[0][0];
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      ostrb <= iuval ? iustrb : engine__ostrb[0][0];
      //
      for (int row = 0; row < pROW_BY_CYCLE; row++) begin
        for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
          for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
            ovstate[row][col][llra].pre_sign  <= iuval ? 1'b0                                      : engine__ovstate[col][llra][row].pre_sign;
            ovstate[row][col][llra].pre_zero  <= iuval ? 1'b1                                      : engine__ovstate[col][llra][row].pre_zero;
            ovnode [row][col][llra]           <= iuval ? (iuLLR[col][llra] <<< (pNODE_W - pLLR_W)) : engine__ovnode [col][llra][row];
          end
        end
      end
    end
  end

  assign obusy = oval;

  //------------------------------------------------------------------------------------------------------
  // bit interface
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      bitval  <= 1'b0;
      obitval <= 1'b0;
    end
    else if (iclkena) begin
      bitval  <= engine__obitval[0][0];
      obitval <= bitval;
    end
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [cERR_MAX-1 : 0] biterr_vector;

  always_comb begin
    for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
      if ((pDO_PUNCT | ido_punct) & (col < 2))
        biterr_vector[col*pLLR_BY_CYCLE +: pLLR_BY_CYCLE] = '0;
      else if (col >= cGR_MAJOR_BIT_COL[iidxGr])
        biterr_vector[col*pLLR_BY_CYCLE +: pLLR_BY_CYCLE] = '0;
      else
        biterr_vector[col*pLLR_BY_CYCLE +: pLLR_BY_CYCLE] = engine__obiterr[col];
    end
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      // local sum
      bitsop  <= engine__obitsop[0][0];
      biteop  <= engine__obiteop[0][0];
      bitdat  <= engine__obitdat;
      for (int i = 0; i < pERR_SFACTOR; i++) begin
        biterr[i] <= erracc_stage0(biterr_vector[i*cERR_STAGE +: cERR_STAGE]);
      end
      // final sum
      obitsop <= bitsop;
      obiteop <= biteop;
      obitdat <= bitdat;
      obiterr <= erracc_stage1(biterr);
    end
  end

  //------------------------------------------------------------------------------------------------------
  // used function
  //------------------------------------------------------------------------------------------------------

  function logic [cERR_STAGE_W-1 : 0] erracc_stage0 (input logic [cERR_STAGE-1 : 0] err);
    erracc_stage0 = '0;
    for (int n = 0; n < cERR_STAGE; n++) begin
      erracc_stage0 = erracc_stage0 + err[n];
    end
  endfunction

  function logic [pERR_W-1 : 0] erracc_stage1 (input logic [cERR_STAGE_W-1 : 0] err [pERR_SFACTOR]);
    erracc_stage1 = '0;
    for (int n = 0; n < pERR_SFACTOR; n++) begin
      erracc_stage1 = erracc_stage1 + err[n];
    end
  endfunction

endmodule

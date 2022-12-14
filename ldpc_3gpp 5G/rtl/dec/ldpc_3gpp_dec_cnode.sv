/*



  parameter int pLLR_W         = 4 ;
  parameter int pNODE_W        = 4 ;
  //
  parameter int pLLR_BY_CYCLE  = 1 ;
  parameter int pROW_BY_CYCLE  = 8 ;
  //
  parameter bit pNORM_FACTOR   = 7 ;


  logic  ldpc_3gpp_dec_cnode__iclk                                                   ;
  logic  ldpc_3gpp_dec_cnode__ireset                                                 ;
  logic  ldpc_3gpp_dec_cnode__iclkena                                                ;
  //
  logic  ldpc_3gpp_dec_cnode__ival                                                   ;
  strb_t ldpc_3gpp_dec_cnode__istrb                                                  ;
  logic  ldpc_3gpp_dec_cnode__ivmask   [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  node_t ldpc_3gpp_dec_cnode__ivnode   [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  logic  ldpc_3gpp_dec_cnode__ipmask   [pROW_BY_CYCLE]                               ;
  llr_t  ldpc_3gpp_dec_cnode__ipLLR    [pROW_BY_CYCLE]               [pLLR_BY_CYCLE] ;
  //
  logic  ldpc_3gpp_dec_cnode__oval                                                   ;
  strb_t ldpc_3gpp_dec_cnode__ostrb                                                  ;
  node_t ldpc_3gpp_dec_cnode__ocnode   [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  logic  ldpc_3gpp_dec_cnode__odecfail                                               ;
  logic  ldpc_3gpp_dec_cnode__obusy                                                  ;



  ldpc_3gpp_dec_cnode
  #(
    .pLLR_W        ( pLLR_W        ) ,
    .pNODE_W       ( pNODE_W       ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE ) ,
    //
    .pNORM_FACTOR  ( pNORM_FACTOR  )
  )
  ldpc_3gpp_dec_cnode
  (
    .iclk     ( ldpc_3gpp_dec_cnode__iclk     ) ,
    .ireset   ( ldpc_3gpp_dec_cnode__ireset   ) ,
    .iclkena  ( ldpc_3gpp_dec_cnode__iclkena  ) ,
    //
    .ival     ( ldpc_3gpp_dec_cnode__ival     ) ,
    .istrb    ( ldpc_3gpp_dec_cnode__istrb    ) ,
    .ivmask   ( ldpc_3gpp_dec_cnode__ivmask   ) ,
    .ivnode   ( ldpc_3gpp_dec_cnode__ivnode   ) ,
    .ipmask   ( ldpc_3gpp_dec_cnode__ipmask   ) ,
    .ipLLR    ( ldpc_3gpp_dec_cnode__ipLLR    ) ,
    //
    .oval     ( ldpc_3gpp_dec_cnode__oval     ) ,
    .ostrb    ( ldpc_3gpp_dec_cnode__ostrb    ) ,
    .ocnode   ( ldpc_3gpp_dec_cnode__ocnode   ) ,
    //
    .odecfail ( ldpc_3gpp_dec_cnode__odecfail ) ,
    .obusy    ( ldpc_3gpp_dec_cnode__obusy    )
  );


  assign ldpc_3gpp_dec_cnode__iclk    = '0 ;
  assign ldpc_3gpp_dec_cnode__ireset  = '0 ;
  assign ldpc_3gpp_dec_cnode__iclkena = '0 ;
  assign ldpc_3gpp_dec_cnode__ival    = '0 ;
  assign ldpc_3gpp_dec_cnode__istrb   = '0 ;
  assign ldpc_3gpp_dec_cnode__ivmask  = '0 ;
  assign ldpc_3gpp_dec_cnode__ivnode  = '0 ;
  assign ldpc_3gpp_dec_cnode__ipmask  = '0 ;
  assign ldpc_3gpp_dec_cnode__ipLLR   = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_cnode.sv
// Description   : LDPC decoder check node arithmetic top module: read vnode and count cnode.
//                 Consist of pROW_BY_CYCLE*pLLR_BY_CYCLE engines with cCOL_BY_CYCLE + 1 vnodes
//

`include "define.vh"

module ldpc_3gpp_dec_cnode
(
  iclk     ,
  ireset   ,
  iclkena  ,
  //
  ival     ,
  istrb    ,
  ivmask   ,
  ivnode   ,
  ipmask   ,
  ipLLR    ,
  //
  oval     ,
  ostrb    ,
  orow     ,
  ocnode   ,
  //
  odecfail ,
  obusy
);

  parameter int pNORM_FACTOR  = 7;  // pNORM_FACTOR/8 - normalization factor

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_dec_types.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic    iclk                                                  ;
  input  logic    ireset                                                ;
  input  logic    iclkena                                               ;
  //
  input  logic    ival                                                  ;
  input  strb_t   istrb                                                 ;
  input  logic    ivmask  [pROW_BY_CYCLE][cCOL_BY_CYCLE]                ;
  input  node_t   ivnode  [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  input  logic    ipmask  [pROW_BY_CYCLE]                               ;
  input  llr_t    ipLLR   [pROW_BY_CYCLE]               [pLLR_BY_CYCLE] ;
  //
  output logic    oval                                                  ;
  output strb_t   ostrb                                                 ;
  output hb_row_t orow                                                  ;
  output node_t   ocnode  [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  output logic    odecfail                                              ;
  output logic    obusy                                                 ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic  engine__ival                                                   ;
  strb_t engine__istrb                                                  ;
  logic  engine__ivmask   [pROW_BY_CYCLE]               [cCOL_BY_CYCLE] ;
  node_t engine__ivnode   [pROW_BY_CYCLE][pLLR_BY_CYCLE][cCOL_BY_CYCLE] ;

  logic  engine__ipmask   [pROW_BY_CYCLE]                               ;
  node_t engine__ipnode   [pROW_BY_CYCLE][pLLR_BY_CYCLE]                ;

  logic  engine__oval     [pROW_BY_CYCLE][pLLR_BY_CYCLE]                ;
  strb_t engine__ostrb    [pROW_BY_CYCLE][pLLR_BY_CYCLE]                ;
  node_t engine__ocnode   [pROW_BY_CYCLE][pLLR_BY_CYCLE][cCOL_BY_CYCLE] ;

  logic  engine__odecfail [pROW_BY_CYCLE][pLLR_BY_CYCLE]                ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  assign engine__ival  = ival;
  assign engine__istrb = istrb;

  always_comb begin
    for (int row = 0; row < pROW_BY_CYCLE; row++) begin
      engine__ipmask[row] = ipmask[row];
      for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
        engine__ipnode[row][llra] = ipLLR[row][llra] <<< (pNODE_W - pLLR_W);  // align fixed point
        for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
          if (col < cGR_MAJOR_BIT_COL[pIDX_GR]) begin
            engine__ivmask[row]      [col] = ivmask[row][col];
            engine__ivnode[row][llra][col] = ivnode[row][col][llra];
          end
          else begin
            engine__ivmask[row]      [col] = 1'b1;
            engine__ivnode[row][llra][col] = '0;
          end
        end // col
      end // llra
    end // row
  end

  genvar grow, gllr;

  generate
    for (grow = 0; grow < pROW_BY_CYCLE; grow++) begin : engine_inst_row_gen
      for (gllr = 0; gllr < pLLR_BY_CYCLE; gllr++) begin : engine_inst_llr_gen
        ldpc_3gpp_dec_cnode_p_engine
        #(
          .pLLR_W         ( pLLR_W         ) ,
          .pNODE_W        ( pNODE_W        ) ,
          .pNORM_FACTOR   ( pNORM_FACTOR   )
        )
        engine
        (
          .iclk       ( iclk                          ) ,
          .ireset     ( ireset                        ) ,
          .iclkena    ( iclkena                       ) ,
          //
          .ival       ( engine__ival                  ) ,
          .istrb      ( engine__istrb                 ) ,
          .ivmask     ( engine__ivmask   [grow]       ) ,
          .ivnode     ( engine__ivnode   [grow][gllr] ) ,
          .ipmask     ( engine__ipmask   [grow]       ) ,
          .ipnode     ( engine__ipnode   [grow][gllr] ) ,
          //
          .oval       ( engine__oval     [grow][gllr] ) ,
          .ostrb      ( engine__ostrb    [grow][gllr] ) ,
          .ocnode     ( engine__ocnode   [grow][gllr] ) ,
          //
          .odecfail   ( engine__odecfail [grow][gllr] )
        );

      end
    end
  endgenerate

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic   used_val;
  strb_t  used_strb;

  assign used_val   = engine__oval [0][0];
  assign used_strb  = engine__ostrb[0][0];

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= used_val;
  end

  assign obusy = used_val;  // 1 tick before

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      ostrb <= used_strb;
      //
      for (int row = 0; row < pROW_BY_CYCLE; row++) begin
        for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
          for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
            ocnode[row][col][llra] <= engine__ocnode[row][llra][col];
          end
        end
      end
      //
      if (used_val) begin
        odecfail <= get_decfail(engine__odecfail);
      end
      //
      if (used_val & used_strb.sop) begin
        orow <= (used_strb.sof & used_strb.sop) ? '0 : (orow + 1'b1);
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // used function
  //------------------------------------------------------------------------------------------------------

  function logic get_decfail (input logic decfail [pROW_BY_CYCLE][pLLR_BY_CYCLE]);
    get_decfail = '0;
    for (int row = 0; row < pROW_BY_CYCLE; row++) begin
      for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
        get_decfail |= decfail[row][llra];
      end
    end
  endfunction

endmodule

/*



  parameter int pLLR_W         = 4 ;
  parameter int pLLR_BY_CYCLE  = 1 ;


  logic     gsfc_ldpc_dec_cnode_pre_engine__iclk               ;
  logic     gsfc_ldpc_dec_cnode_pre_engine__ireset             ;
  logic     gsfc_ldpc_dec_cnode_pre_engine__iclkena            ;
  logic     gsfc_ldpc_dec_cnode_pre_engine__isop               ;
  logic     gsfc_ldpc_dec_cnode_pre_engine__ival               ;
  logic     gsfc_ldpc_dec_cnode_pre_engine__ieop               ;
  zcnt_t    gsfc_ldpc_dec_cnode_pre_engine__izcnt              ;
  logic     gsfc_ldpc_dec_cnode_pre_engine__ivmask  [0 : pW-1] ;
  node_t    gsfc_ldpc_dec_cnode_pre_engine__ivnode  [0 : pW-1] ;
  logic     gsfc_ldpc_dec_cnode_pre_engine__osop               ;
  logic     gsfc_ldpc_dec_cnode_pre_engine__oval               ;
  logic     gsfc_ldpc_dec_cnode_pre_engine__oeop               ;
  vn_min_t  gsfc_ldpc_dec_cnode_pre_engine__ovn                ;



  gsfc_ldpc_dec_cnode_pre_engine
  #(
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE )
  )
  gsfc_ldpc_dec_cnode_pre_engine
  (
    .iclk    ( gsfc_ldpc_dec_cnode_pre_engine__iclk    ) ,
    .ireset  ( gsfc_ldpc_dec_cnode_pre_engine__ireset  ) ,
    .iclkena ( gsfc_ldpc_dec_cnode_pre_engine__iclkena ) ,
    .isop    ( gsfc_ldpc_dec_cnode_pre_engine__isop    ) ,
    .ival    ( gsfc_ldpc_dec_cnode_pre_engine__ival    ) ,
    .ieop    ( gsfc_ldpc_dec_cnode_pre_engine__ieop    ) ,
    .izcnt   ( gsfc_ldpc_dec_cnode_pre_engine__izcnt   ) ,
    .ivmask  ( gsfc_ldpc_dec_cnode_pre_engine__ivmask  ) ,
    .ivnode  ( gsfc_ldpc_dec_cnode_pre_engine__ivnode  ) ,
    .osop    ( gsfc_ldpc_dec_cnode_pre_engine__osop    ) ,
    .oval    ( gsfc_ldpc_dec_cnode_pre_engine__oval    ) ,
    .oeop    ( gsfc_ldpc_dec_cnode_pre_engine__oeop    ) ,
    .ovn     ( gsfc_ldpc_dec_cnode_pre_engine__ovn     )
  );


  assign gsfc_ldpc_dec_cnode_pre_engine__iclk    = '0 ;
  assign gsfc_ldpc_dec_cnode_pre_engine__ireset  = '0 ;
  assign gsfc_ldpc_dec_cnode_pre_engine__iclkena = '0 ;
  assign gsfc_ldpc_dec_cnode_pre_engine__isop    = '0 ;
  assign gsfc_ldpc_dec_cnode_pre_engine__ival    = '0 ;
  assign gsfc_ldpc_dec_cnode_pre_engine__ieop    = '0 ;
  assign gsfc_ldpc_dec_cnode_pre_engine__izcnt   = '0 ;
  assign gsfc_ldpc_dec_cnode_pre_engine__ivmask  = '0 ;
  assign gsfc_ldpc_dec_cnode_pre_engine__ivnode  = '0 ;



*/
//

// Project       : GSFC ldpc (7154, 8176)
// Author        : Shekhalev Denis (des00)
// Workfile      : gsfc_ldpc_dec_cnode_engine.v
// Description   : LDPC decoder preliminary check node arithmetic engine. Prepare data for search reduce the
//                 amount of data by weigth factor
//

`include "define.vh"

module gsfc_ldpc_dec_cnode_pre_engine
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  isop    ,
  ival    ,
  ieop    ,
  izcnt   ,
  ivmask  ,
  ivnode  ,
  //
  osop    ,
  oval    ,
  oeop    ,
  ovn
);

  `include "gsfc_ldpc_parameters.vh"
  `include "gsfc_ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic     iclk         ;
  input  logic     ireset       ;
  input  logic     iclkena      ;
  //
  input  logic     isop         ;
  input  logic     ival         ;
  input  logic     ieop         ;
  input  zcnt_t    izcnt        ;
  input            ivmask  [pW] ;
  input  node_t    ivnode  [pW] ;
  //
  output logic     osop         ;
  output logic     oval         ;
  output logic     oeop         ;
  output vn_min_t  ovn          ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic            sop;
  logic            val;
  logic            eop;

  zcnt_t           zcnt;

  logic [pW-1 : 0] sign_vnode      ;
  vnode_t          abs_vnode  [pW] ;

  //------------------------------------------------------------------------------------------------------
  // prepare data
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      val <= 1'b0;
    else if (iclkena)
      val <= ival;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival) begin
        sop   <= isop;
        eop   <= ieop;
        zcnt  <= izcnt;
        //
        for (int w = 0; w < pW; w++) begin
          sign_vnode[w] <=  ivnode[w][cNODE_W-1];
          abs_vnode [w] <= (ivnode[w] ^ {cNODE_W{ivnode[w][cNODE_W-1]}}) + ivnode[w][cNODE_W-1];
        end
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // search
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= val;
  end

  wire check = (abs_vnode[1] < abs_vnode[0]);

  always_comb ovn.min1_idx  = '0; // detect in follow modules
  always_comb ovn.min1_node = '0;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (val) begin
        osop <= sop;
        oeop <= eop;
        //
        ovn.prod_sign <= ^sign_vnode;
        ovn.vn_sign   <=  sign_vnode;
        ovn.vn_zcnt   <=  zcnt;
        //
        if (check) begin
          ovn.min1        <= abs_vnode[1];
          ovn.min2        <= abs_vnode[0];
          ovn.min1_weigth <= 1'b1;
        end
        else begin
          ovn.min1        <= abs_vnode[0];
          ovn.min2        <= abs_vnode[1];
          ovn.min1_weigth <= 1'b0;
        end
      end
    end
  end

endmodule

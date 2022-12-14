/*



  parameter int pLLR_W        =  5 ;
  parameter int pLLR_BY_CYCLE =  2 ;
  parameter int pTAG_W        =  4 ;



  logic                         gsfc_ldpc_dec__iclk                    ;
  logic                         gsfc_ldpc_dec__ireset                  ;
  logic                         gsfc_ldpc_dec__iclkena                 ;
  logic                 [7 : 0] gsfc_ldpc_dec__iNiter                  ;
  logic                         gsfc_ldpc_dec__isop                    ;
  logic                         gsfc_ldpc_dec__ieop                    ;
  logic                         gsfc_ldpc_dec__ival                    ;
  logic          [pTAG_W-1 : 0] gsfc_ldpc_dec__itag                    ;
  logic signed   [pLLR_W-1 : 0] gsfc_ldpc_dec__iLLR    [pLLR_BY_CYCLE] ;
  logic                         gsfc_ldpc_dec__obusy                   ;
  logic                         gsfc_ldpc_dec__ordy                    ;
  logic                         gsfc_ldpc_dec__osop                    ;
  logic                         gsfc_ldpc_dec__oeop                    ;
  logic                         gsfc_ldpc_dec__oval                    ;
  logic          [pTAG_W-1 : 0] gsfc_ldpc_dec__otag                    ;
  logic   [pLLR_BY_CYCLE-1 : 0] gsfc_ldpc_dec__odat                    ;
  logic                [15 : 0] gsfc_ldpc_dec__oerr                    ;



  gsfc_ldpc_dec
  #(
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pNORM_VNODE   ( pNORM_VNODE   ) ,
    .pNORM_CNODE   ( pNORM_CNODE   ) ,
    .pTAG_W        ( pTAG_W        )
  )
  gsfc_ldpc_dec
  (
    .iclk    ( gsfc_ldpc_dec__iclk    ) ,
    .ireset  ( gsfc_ldpc_dec__ireset  ) ,
    .iclkena ( gsfc_ldpc_dec__iclkena ) ,
    .iNiter  ( gsfc_ldpc_dec__iNiter  ) ,
    .isop    ( gsfc_ldpc_dec__isop    ) ,
    .ieop    ( gsfc_ldpc_dec__ieop    ) ,
    .ival    ( gsfc_ldpc_dec__ival    ) ,
    .itag    ( gsfc_ldpc_dec__itag    ) ,
    .iLLR    ( gsfc_ldpc_dec__iLLR    ) ,
    .obusy   ( gsfc_ldpc_dec__obusy   ) ,
    .ordy    ( gsfc_ldpc_dec__ordy    ) ,
    .osop    ( gsfc_ldpc_dec__osop    ) ,
    .oeop    ( gsfc_ldpc_dec__oeop    ) ,
    .oval    ( gsfc_ldpc_dec__oval    ) ,
    .otag    ( gsfc_ldpc_dec__otag    ) ,
    .odat    ( gsfc_ldpc_dec__odat    ) ,
    .oerr    ( gsfc_ldpc_dec__oerr    )
  );


  assign gsfc_ldpc_dec__iclk    = '0 ;
  assign gsfc_ldpc_dec__ireset  = '0 ;
  assign gsfc_ldpc_dec__iclkena = '0 ;
  assign gsfc_ldpc_dec__iNiter  = '0 ;
  assign gsfc_ldpc_dec__isop    = '0 ;
  assign gsfc_ldpc_dec__ieop    = '0 ;
  assign gsfc_ldpc_dec__ival    = '0 ;
  assign gsfc_ldpc_dec__itag    = '0 ;
  assign gsfc_ldpc_dec__iLLR    = '0 ;



*/

//
// Project       : GSFC ldpc (7154, 8176)
// Author        : Shekhalev Denis (des00)
// Workfile      : gsfc_ldpc_dec.v
// Description   : LDPC decoder with static code parameters. Normalized 2D min-sum algorithm is used. Input metrics is straight(!!!). The metric saturation is inside.
//                 The iNiter port and any input tag info latched inside at isop & ival signal. Decoder use 2D input buffer and no any output buffers or output handshake
//                 The decoded systematic bits go output during decoding on fly with error counting. Only systematic bit error is take into acount(!!!). The actual oerr value is valid at oeop tag.
//

`include "define.vh"

module gsfc_ldpc_dec
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

  parameter bit pNORM_VNODE = 1 ; // 1/0 vnode noramlization coefficient is 0.75/1
  parameter bit pNORM_CNODE = 1 ; // 1/0 cnode noramlization coefficient is 0.75/1
  parameter int pTAG_W      = 4 ;

  `include "gsfc_ldpc_parameters.vh"
  `include "gsfc_ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                         iclk                    ;
  input  logic                         ireset                  ;
  input  logic                         iclkena                 ;
  //
  input  logic                 [7 : 0] iNiter                  ;
  //
  input  logic                         isop                    ;
  input  logic                         ieop                    ;
  input  logic                         ival                    ;
  input  logic          [pTAG_W-1 : 0] itag                    ;
  input  logic signed   [pLLR_W-1 : 0] iLLR    [pLLR_BY_CYCLE] ;
  //
  output logic                         obusy                   ;
  output logic                         ordy                    ;
  //
  output logic                         osop                    ;
  output logic                         oeop                    ;
  output logic                         oval                    ;
  output logic          [pTAG_W-1 : 0] otag                    ;
  output logic   [pLLR_BY_CYCLE-1 : 0] odat                    ;
  //
  output logic                [15 : 0] oerr                    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [pLLR_BY_CYCLE-1 : 0] engine__odat [1] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  gsfc_ldpc_dec_engine
  #(
    .pLLR_W         ( pLLR_W         ) ,
    .pLLR_BY_CYCLE  ( pLLR_BY_CYCLE  ) ,
    .pLLR_NUM       ( pLLR_BY_CYCLE  ) ,
    .pNODE_BY_CYCLE ( 1              ) ,
    .pUSE_MN_MODE   ( 0              ) ,
    //
    .pNORM_VNODE    ( pNORM_VNODE    ) ,
    .pNORM_CNODE    ( pNORM_CNODE    ) ,
    //
    .pTAG_W         ( pTAG_W         )
  )
  engine
  (
    .iclk    ( iclk         ) ,
    .ireset  ( ireset       ) ,
    .iclkena ( iclkena      ) ,
    //
    .iNiter  ( iNiter       ) ,
    //
    .isop    ( isop         ) ,
    .ieop    ( ieop         ) ,
    .ival    ( ival         ) ,
    .itag    ( itag         ) ,
    .iLLR    ( iLLR         ) ,
    //
    .obusy   ( obusy        ) ,
    .ordy    ( ordy         ) ,
    //
    .irdy    ( 1'b1         ) , // no output buffer
    //
    .osop    ( osop         ) ,
    .oeop    ( oeop         ) ,
    .oval    ( oval         ) ,
    .oaddr   (              ) ,
    .otag    ( otag         ) ,
    .odat    ( engine__odat ) ,
    .oerr    ( oerr         )
  );

  assign odat = engine__odat[0];

endmodule

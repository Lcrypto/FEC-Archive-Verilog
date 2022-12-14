/*



  parameter int pTAG_W =  8 ;
  parameter int pCODE  =  0 ;
  parameter int pN_IDX =  0 ;



  logic                ccsds_turbo_enc__iclk    ;
  logic                ccsds_turbo_enc__ireset  ;
  logic                ccsds_turbo_enc__iclkena ;
  logic [pTAG_W-1 : 0] ccsds_turbo_enc__itag    ;
  logic                ccsds_turbo_enc__isop    ;
  logic                ccsds_turbo_enc__ieop    ;
  logic                ccsds_turbo_enc__ival    ;
  logic                ccsds_turbo_enc__idat    ;
  logic                ccsds_turbo_enc__obusy   ;
  logic                ccsds_turbo_enc__ordy    ;
  logic [pTAG_W-1 : 0] ccsds_turbo_enc__otag    ;
  logic                ccsds_turbo_enc__osop    ;
  logic                ccsds_turbo_enc__oeop    ;
  logic                ccsds_turbo_enc__oval    ;
  logic                ccsds_turbo_enc__odat    ;



  ccsds_turbo_enc
  #(
    .pTAG_W ( pTAG_W ) ,
    .pCODE  ( pCODE  ) ,
    .pN_IDX ( pN_IDX )
  )
  ccsds_turbo_enc
  (
    .iclk    ( ccsds_turbo_enc__iclk    ) ,
    .ireset  ( ccsds_turbo_enc__ireset  ) ,
    .iclkena ( ccsds_turbo_enc__iclkena ) ,
    .itag    ( ccsds_turbo_enc__itag    ) ,
    .isop    ( ccsds_turbo_enc__isop    ) ,
    .ieop    ( ccsds_turbo_enc__ieop    ) ,
    .ival    ( ccsds_turbo_enc__ival    ) ,
    .idat    ( ccsds_turbo_enc__idat    ) ,
    .obusy   ( ccsds_turbo_enc__obusy   ) ,
    .ordy    ( ccsds_turbo_enc__ordy    ) ,
    .otag    ( ccsds_turbo_enc__otag    ) ,
    .osop    ( ccsds_turbo_enc__osop    ) ,
    .oeop    ( ccsds_turbo_enc__oeop    ) ,
    .oval    ( ccsds_turbo_enc__oval    ) ,
    .odat    ( ccsds_turbo_enc__odat    )
  );


  assign ccsds_turbo_enc__iclk    = '0 ;
  assign ccsds_turbo_enc__ireset  = '0 ;
  assign ccsds_turbo_enc__iclkena = '0 ;
  assign ccsds_turbo_enc__itag    = '0 ;
  assign ccsds_turbo_enc__isop    = '0 ;
  assign ccsds_turbo_enc__ieop    = '0 ;
  assign ccsds_turbo_enc__ival    = '0 ;
  assign ccsds_turbo_enc__idat    = '0 ;


*/

//
// Project       : ccsds_turbo
// Author        : Shekhalev Denis (des00)
// Workfile      : ccsds_turbo_enc.v
// Description   : ccsds_turbo encoder with static encoding parameters
//

`include "define.vh"

module ccsds_turbo_enc
#(
  parameter int pTAG_W = 8 ,
  parameter int pCODE  = 0 , // 0/1/2/3 :: 1/2, 1/3, 1/4, 1/6
  parameter int pN_IDX = 0   // 0/1/2/3 :: 223*8*1, 223*8*2, 223*8*4, 223*8*5
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  itag    ,
  isop    ,
  ieop    ,
  ival    ,
  idat    ,
  //
  obusy   ,
  ordy    ,
  //
  otag    ,
  osop    ,
  oeop    ,
  oval    ,
  odat
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                iclk    ;
  input  logic                ireset  ;
  input  logic                iclkena ;
  //
  input  logic [pTAG_W-1 : 0] itag    ;
  input  logic                isop    ;
  input  logic                ieop    ;
  input  logic                ival    ;
  input  logic                idat    ;
  //
  output logic                obusy   ;
  output logic                ordy    ;
  //
  output logic [pTAG_W-1 : 0] otag    ;
  output logic                osop    ;
  output logic                oeop    ;
  output logic                oval    ;
  output logic                odat    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  `include "../ccsds_turbo_parameters.vh"

  localparam int cBADDR_W = clogb2(cN_TAB[pN_IDX]);

  localparam int cTAG_W   = pTAG_W;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic   [pTAG_W-1 : 0] tag ;

  // parameter table
  ptab_dat_t             used_N           ;
  ptab_dat_t             used_Nm1         ;
  ptab_dat_t             used_K2          ;
  ptab_dat_t             used_P       [4] ;

  // input buffer
  logic                  buffin__iwrite   ;
  logic                  buffin__iwfull   ;
  logic [cBADDR_W-1 : 0] buffin__iwaddr   ;
  logic                  buffin__iwdata   ;
  logic   [cTAG_W-1 : 0] buffin__iwtag    ;

  logic                  buffin__iread    ;
  logic                  buffin__irempty  ;
  logic [cBADDR_W-1 : 0] buffin__iraddr0  ;
  logic                  buffin__ordata0  ;
  logic [cBADDR_W-1 : 0] buffin__iraddr1  ;
  logic                  buffin__ordata1  ;
  logic   [cTAG_W-1 : 0] buffin__ortag    ;

  logic                  buffin__oempty   ;
  logic                  buffin__oemptya  ;
  logic                  buffin__ofull    ;
  logic                  buffin__ofulla   ;

  // address generator
  logic                  paddr_gen__iclear  ;
  logic                  paddr_gen__ienable ;

  ptab_dat_t             paddr_gen__oaddr   ;
  ptab_dat_t             paddr_gen__opaddr  ;

  // encoder engine
  logic                  enc__isop       ;
  logic                  enc__ival       ;
  logic                  enc__ieop       ;
  logic                  enc__iterm      ;
  logic                  enc__idat   [2] ;

  logic                  enc__osop   [2] ;
  logic                  enc__oval   [2] ;
  logic                  enc__oeop   [2] ;
  logic          [3 : 0] enc__odat   [2] ;

  // puncture modules
  logic                  enc_ctrl__oval;
  logic                  enc_ctrl__osop;
  logic                  enc_ctrl__oeop;
  logic                  enc_ctrl__oterm;

  //------------------------------------------------------------------------------------------------------
  // input data buffer
  //------------------------------------------------------------------------------------------------------

  ccsds_turbo_enc_buffer
  #(
    .pADDR_W ( cBADDR_W ) ,
    .pDATA_W ( 1        ) ,
    .pTAG_W  ( cTAG_W   ) ,
    .pBNUM_W ( 1        ) , // 2D
    .pPIPE   ( 0        )
  )
  buffin
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    //
    .iwrite  ( buffin__iwrite  ) ,
    .iwfull  ( buffin__iwfull  ) ,
    .iwaddr  ( buffin__iwaddr  ) ,
    .iwdata  ( buffin__iwdata  ) ,
    .iwtag   ( buffin__iwtag   ) ,
    //
    .iread   ( buffin__iread   ) ,
    .irempty ( buffin__irempty ) ,
    .iraddr0 ( buffin__iraddr0 ) ,
    .ordata0 ( buffin__ordata0 ) ,
    .iraddr1 ( buffin__iraddr1 ) ,
    .ordata1 ( buffin__ordata1 ) ,
    .ortag   ( buffin__ortag   ) ,
    //
    .oempty  ( buffin__oempty  ) ,
    .oemptya ( buffin__oemptya ) ,
    .ofull   ( buffin__ofull   ) ,
    .ofulla  ( buffin__ofulla  )
  );

  //
  // write side
  logic [cBADDR_W-1 : 0] waddr;

  assign buffin__iwrite = ival;
  assign buffin__iwfull = ival & ieop;
  assign buffin__iwaddr = isop ? '0 : waddr;
  assign buffin__iwdata = idat;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival) begin
        waddr <= isop ? 1'b1 : (waddr + 1'b1);
      end
    end
  end

  assign buffin__iwtag = itag;

  //
  // acknowledge
  assign ordy  = !buffin__ofulla;   // not ready if all buffers is full
  assign obusy = !buffin__oemptya;  // busy if any buffer is not empty

  // read side
  assign buffin__iread    = 1'b1;
  assign buffin__iraddr0  = paddr_gen__oaddr [cBADDR_W-1 : 0];
  assign buffin__iraddr1  = paddr_gen__opaddr[cBADDR_W-1 : 0];

  assign tag = buffin__ortag;

  //------------------------------------------------------------------------------------------------------
  // decode permutation type decoder
  //------------------------------------------------------------------------------------------------------

  ccsds_turbo_ptable
  #(
    .pCODE  ( pCODE  ) ,
    .pN_IDX ( pN_IDX )
  )
  ptab
  (
    .iclk    ( iclk     ) ,
    .ireset  ( ireset   ) ,
    .iclkena ( iclkena  ) ,
    //
    .oN      ( used_N   ) ,
    .oNm1    ( used_Nm1 ) ,
    .oK2     ( used_K2  ) ,
    //
    .oP      ( used_P   ) ,
    .oPcomp  (          )
  );

  //------------------------------------------------------------------------------------------------------
  // input data buffer address generator
  //------------------------------------------------------------------------------------------------------

  ccsds_turbo_enc_paddr_gen
  paddr_gen
  (
    .iclk     ( iclk    ) ,
    .ireset   ( ireset  ) ,
    .iclkena  ( iclkena ) ,
    //
    .iclear   ( paddr_gen__iclear  ) ,
    .ienable  ( paddr_gen__ienable ) ,
    //
    .iP       ( used_P             ) ,
    .iK2      ( used_K2            ) ,
    //
    .oaddr    ( paddr_gen__oaddr   ) ,
    .opaddr   ( paddr_gen__opaddr  )
  );

  //------------------------------------------------------------------------------------------------------
  // main FSM
  //------------------------------------------------------------------------------------------------------

  ccsds_turbo_enc_ctrl
  enc_ctrl
  (
    .iclk         ( iclk               ) ,
    .ireset       ( ireset             ) ,
    .iclkena      ( iclkena            ) ,
    //
    .icode        ( pCODE              ) ,
    .iN           ( used_N             ) ,
    //
    .ifull        ( buffin__ofull      ) ,
    .orempty      ( buffin__irempty    ) ,
    //
    .oaddr_clear  ( paddr_gen__iclear  ) ,
    .oaddr_enable ( paddr_gen__ienable ) ,
    //
    .osop         ( enc_ctrl__osop     ) ,
    .oeop         ( enc_ctrl__oeop     ) ,
    .oval         ( enc_ctrl__oval     ) ,
    .oterm        ( enc_ctrl__oterm    )
  );

  //------------------------------------------------------------------------------------------------------
  // convolution coders with SC counters
  //------------------------------------------------------------------------------------------------------

  generate
    genvar i;
    for (i = 0; i < 2; i++) begin : engine_inst
      ccsds_turbo_enc_engine
      enc
      (
        .iclk    ( iclk             ) ,
        .ireset  ( ireset           ) ,
        .iclkena ( iclkena          ) ,
        //
        .isop    ( enc__isop        ) ,
        .ival    ( enc__ival        ) ,
        .ieop    ( enc__ieop        ) ,
        .iterm   ( enc__iterm       ) ,
        .idat    ( enc__idat    [i] ) ,
        //
        .osop    ( enc__osop    [i] ) ,
        .oval    ( enc__oval    [i] ) ,
        .oeop    ( enc__oeop    [i] ) ,
        .odat    ( enc__odat    [i] )
      );
    end
  endgenerate

  assign enc__idat[0] = buffin__ordata0;
  assign enc__idat[1] = buffin__ordata1;

  //
  // align buffin delay
  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      enc__ival <= 1'b0;
    else if (iclkena)
      enc__ival <= enc_ctrl__oval;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      enc__isop   <= enc_ctrl__osop;
      enc__ieop   <= enc_ctrl__oeop;
      enc__iterm  <= enc_ctrl__oterm;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // puncture
  //------------------------------------------------------------------------------------------------------

  ccsds_turbo_enc_punct
  punct
  (
    .iclk    ( iclk          ) ,
    .ireset  ( ireset        ) ,
    .iclkena ( iclkena       ) ,
    //
    .icode   ( pCODE         ) ,
    //
    .isop    ( enc__osop [0] ) ,
    .ival    ( enc__oval [0] ) ,
    .ieop    ( enc__oeop [0] ) ,
    .idat    ( enc__odat     ) ,
    //
    .osop    ( osop          ) ,
    .oval    ( oval          ) ,
    .oeop    ( oeop          ) ,
    .odat    ( odat          )
  );

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      // capture once
      if (enc__oval[0] & enc__osop[0]) begin
        otag <= tag;
      end
    end
  end

endmodule

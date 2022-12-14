/*



  parameter int pCODE  =  0 ;
  parameter int pPTYPE =  0 ;
  parameter int pN     = 56 ;
  parameter int pTAG_W =  8 ;



  logic                rsc2_enc__iclk    ;
  logic                rsc2_enc__ireset  ;
  logic                rsc2_enc__iclkena ;
  logic [pTAG_W-1 : 0] rsc2_enc__itag    ;
  logic                rsc2_enc__isop    ;
  logic                rsc2_enc__ieop    ;
  logic                rsc2_enc__ival    ;
  logic        [1 : 0] rsc2_enc__idat    ;
  logic                rsc2_enc__obusy   ;
  logic                rsc2_enc__ordy    ;
  logic [pTAG_W-1 : 0] rsc2_enc__otag    ;
  logic                rsc2_enc__osop    ;
  logic                rsc2_enc__oeop    ;
  logic                rsc2_enc__oeof    ;
  logic                rsc2_enc__oval    ;
  logic        [1 : 0] rsc2_enc__odat    ;



  rsc2_enc
  #(
    .pCODE  ( pCODE  ) ,
    .pPTYPE ( pPTYPE ) ,
    .pN     ( pN     ) ,
    .pTAG_W ( pTAG_W ) ,
  )
  rsc2_enc
  (
    .iclk    ( rsc2_enc__iclk    ) ,
    .ireset  ( rsc2_enc__ireset  ) ,
    .iclkena ( rsc2_enc__iclkena ) ,
    .itag    ( rsc2_enc__itag    ) ,
    .isop    ( rsc2_enc__isop    ) ,
    .ieop    ( rsc2_enc__ieop    ) ,
    .ival    ( rsc2_enc__ival    ) ,
    .idat    ( rsc2_enc__idat    ) ,
    .obusy   ( rsc2_enc__obusy   ) ,
    .ordy    ( rsc2_enc__ordy    ) ,
    .otag    ( rsc2_enc__otag    ) ,
    .osop    ( rsc2_enc__osop    ) ,
    .oeop    ( rsc2_enc__oeop    ) ,
    .oeof    ( rsc2_enc__oeof    ) ,
    .oval    ( rsc2_enc__oval    ) ,
    .odat    ( rsc2_enc__odat    )
  );


  assign rsc2_enc__iclk    = '0 ;
  assign rsc2_enc__ireset  = '0 ;
  assign rsc2_enc__iclkena = '0 ;
  assign rsc2_enc__itag    = '0 ;
  assign rsc2_enc__isop    = '0 ;
  assign rsc2_enc__ieop    = '0 ;
  assign rsc2_enc__ival    = '0 ;
  assign rsc2_enc__idat    = '0 ;
  assign rsc2_enc__idbsclk = '0 ;


*/

//
// Project       : rsc2
// Author        : Shekhalev Denis (des00)
// Workfile      : rsc2_enc.v
// Description   : RSC encoder with dynamic encoding parameters change on fly : coderate/permutation type vs packet length.
//

`include "define.vh"

module rsc2_enc
#(
  parameter int pCODE  =  0 , // coderate [0 : 7] - [1/3; 1/2; 2/3; 3/4; 4/5; 5/6; 6/7; 7/8]
  parameter int pPTYPE =  0 , // permutation type [0: 33] - reordered Table A-1/2/4/5
  parameter int pN     = 56 ,
  parameter int pTAG_W =  8
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
  oeof    ,
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
  input  logic        [1 : 0] idat    ;
  //
  output logic                obusy   ;
  output logic                ordy    ;
  //
  output logic [pTAG_W-1 : 0] otag    ;
  output logic                osop    ;
  output logic                oeop    ;
  output logic                oeof    ;
  output logic                oval    ;
  output logic        [1 : 0] odat    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cBADDR_W = clogb2(pN);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  // parameter table
  logic         [12 : 0] used_N               ;
  logic          [3 : 0] used_Nmod15          ;
  logic         [12 : 0] used_P       [0 : 3] ;
  logic         [12 : 0] used_Pincr           ;


  // input buffer
  logic                  buffin__iwrite   ;
  logic                  buffin__iwfull   ;
  logic [cBADDR_W-1 : 0] buffin__iwaddr   ;
  logic          [1 : 0] buffin__iwdata   ;
  logic   [pTAG_W-1 : 0] buffin__iwtag    ;

  logic                  buffin__iread    ;
  logic                  buffin__irempty  ;
  logic [cBADDR_W-1 : 0] buffin__iraddr0  ;
  logic          [1 : 0] buffin__ordata0  ;
  logic [cBADDR_W-1 : 0] buffin__iraddr1  ;
  logic          [1 : 0] buffin__ordata1  ;
  logic   [pTAG_W-1 : 0] buffin__ortag    ;

  logic                  buffin__oempty   ;
  logic                  buffin__oemptya  ;
  logic                  buffin__ofull    ;
  logic                  buffin__ofulla   ;

  // address generator
  logic                  paddr_gen__iclear  ;
  logic                  paddr_gen__ienable ;

  logic         [12 : 0] paddr_gen__oaddr   ;
  logic         [12 : 0] paddr_gen__opaddr  ;
  logic                  paddr_gen__obitinv ;

  // encoder engine
  logic                  enc__iclear         ;
  logic                  enc__iload          ;
  logic          [3 : 0] enc__istate [0 : 1] ;
  logic                  enc__isop           ;
  logic                  enc__ival           ;
  logic                  enc__ieop           ;
  logic          [2 : 0] enc__itag           ;
  logic          [1 : 0] enc__idat   [0 : 1] ;

  logic                  enc__osop   [0 : 1] ;
  logic                  enc__oval   [0 : 1] ;
  logic                  enc__oeop   [0 : 1] ;
  logic          [2 : 0] enc__otag   [0 : 1] ;
  logic          [1 : 0] enc__odat   [0 : 1] ;
  logic          [1 : 0] enc__odaty          ;
  logic          [1 : 0] enc__odatw          ;
  logic          [3 : 0] enc__ostate [0 : 1] ;

  // puncture modules
  logic                  punct_sop;
  logic                  punct_val;
  logic                  punct_eop;
  logic                  punct_eof;
  logic          [1 : 0] punct_dat;
  logic          [1 : 0] punct_type;


  logic                  puncty__oval;
  logic          [1 : 0] puncty__odat;

  logic                  punctw__oval;
  logic          [1 : 0] punctw__odat;

  // ctrl
  logic                  enc_ctrl__ostate_clear;
  logic                  enc_ctrl__ostate_load ;

  logic                  enc_ctrl__oval;
  logic                  enc_ctrl__osop;
  logic                  enc_ctrl__oeop;
  logic                  enc_ctrl__olast;
  logic          [1 : 0] enc_ctrl__ostage;

  //------------------------------------------------------------------------------------------------------
  // input data buffer
  //------------------------------------------------------------------------------------------------------

  rsc_enc_buffer
  #(
    .pADDR_W ( cBADDR_W ) ,
    .pDATA_W ( 2        ) , // duobit
    .pTAG_W  ( pTAG_W   ) ,
    .pBNUM_W ( 1        ) , // double buffering
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
  assign buffin__iraddr1  = paddr_gen__oaddr  [cBADDR_W-1 : 0];
  assign buffin__iraddr0  = paddr_gen__opaddr [cBADDR_W-1 : 0];

  logic buffin_bit_inv;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      buffin_bit_inv <= paddr_gen__obitinv; // align ram read latency
    end
  end

  assign otag = buffin__ortag; // otag is slow data valid at osop

  //------------------------------------------------------------------------------------------------------
  // decode permutation type decoder
  //------------------------------------------------------------------------------------------------------

  rsc2_ptable
  ptab
  (
    .iclk       ( iclk         ) ,
    .ireset     ( ireset       ) ,
    .iclkena    ( iclkena      ) ,
    //
    .iptype     ( pPTYPE       ) ,
    //
    .oN         ( used_N       ) ,
    .oNm1       (              ) , // n.u.
    .oNmod15    ( used_Nmod15  ) ,
    //
    .oP         ( used_P       ) ,
    .oP0comp    (              ) , // n.u.
    .oPincr     ( used_Pincr   )
  );

  //------------------------------------------------------------------------------------------------------
  // input data buffer address generator
  //------------------------------------------------------------------------------------------------------

  rsc_enc_paddr_gen
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
    .iN       ( used_N             ) ,
    .iPincr   ( used_Pincr         ) ,
    .iPdvbinv ( 1'b1               ) ,
    //
    .oaddr    ( paddr_gen__oaddr   ) ,
    .opaddr   ( paddr_gen__opaddr  ) ,
    .obitinv  ( paddr_gen__obitinv )
  );

  //------------------------------------------------------------------------------------------------------
  // main FSM
  //------------------------------------------------------------------------------------------------------

  rsc_enc_ctrl
  enc_ctrl
  (
    .iclk         ( iclk                   ) ,
    .ireset       ( ireset                 ) ,
    .iclkena      ( iclkena                ) ,
    .idbsclk      ( 1'b1                   ) ,
    //
    .icode        ( pCODE                  ) ,
    .iN           ( used_N                 ) ,
    //
    .ifull        ( buffin__ofull          ) ,
    .orempty      ( buffin__irempty        ) ,
    //
    .oaddr_clear  ( paddr_gen__iclear      ) ,
    .oaddr_enable ( paddr_gen__ienable     ) ,
    //
    .ostate_clear ( enc_ctrl__ostate_clear ) ,
    .ostate_load  ( enc_ctrl__ostate_load  ) ,
    //
    .osop         ( enc_ctrl__osop         ) ,
    .oeop         ( enc_ctrl__oeop         ) ,
    .oval         ( enc_ctrl__oval         ) ,
    .olast        ( enc_ctrl__olast        ) ,
    .ostage       ( enc_ctrl__ostage       )
  );

  //------------------------------------------------------------------------------------------------------
  // convolution coders with SC counters
  //------------------------------------------------------------------------------------------------------

  generate
    genvar i;
    for (i = 0; i < 2; i++) begin : engine_inst
      rsc2_enc_engine
      #(
        .pTAG_W ( 3 )
      )
      enc
      (
        .iclk    ( iclk             ) ,
        .ireset  ( ireset           ) ,
        .iclkena ( iclkena          ) ,
        //
        .iclear  ( enc__iclear      ) ,
        .iload   ( enc__iload       ) ,
        .istate  ( enc__istate  [i] ) ,
        //
        .isop    ( enc__isop        ) ,
        .ival    ( enc__ival        ) ,
        .ieop    ( enc__ieop        ) ,
        .idat    ( enc__idat    [i] ) ,
        .itag    ( enc__itag        ) ,
        //
        .osop    ( enc__osop    [i] ) ,
        .oval    ( enc__oval    [i] ) ,
        .oeop    ( enc__oeop    [i] ) ,
        .otag    ( enc__otag    [i] ) ,
        .odat    ( enc__odat    [i] ) ,
        .odaty   ( enc__odaty   [i] ) ,
        .odatw   ( enc__odatw   [i] ) ,
        .ostate  ( enc__ostate  [i] )
      );

      rsc2_sctable
      sctab0
      (
        .iclk     ( iclk            ) ,
        .ireset   ( ireset          ) ,
        .iclkena  ( iclkena         ) ,
        //
        .iNmod15  ( used_Nmod15     ) ,
        //
        .istate   ( enc__ostate [i] ) ,
        .ostate   ( enc__istate [i] ) ,
        .ostate_r (                 )
      );
    end
  endgenerate

  assign enc__idat[1] = buffin__ordata1;
  assign enc__idat[0] = buffin_bit_inv ? {buffin__ordata0[0], buffin__ordata0[1]} : buffin__ordata0;

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
      enc__iclear <= enc_ctrl__ostate_clear;
      enc__iload  <= enc_ctrl__ostate_load ;
      //
      enc__isop <= enc_ctrl__osop;
      enc__ieop <= enc_ctrl__oeop;
      enc__itag <= {enc_ctrl__olast, enc_ctrl__ostage};
    end
  end

  //------------------------------------------------------------------------------------------------------
  // puncture modules
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      punct_val <= 1'b0;
    else if (iclkena)
      punct_val <= enc__oval [1];
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      punct_dat   <= enc__odat [1];
      punct_sop   <= enc__osop [1] & (enc__otag[1][1 : 0] == 0);
      punct_eop   <= enc__oeop [1] & (enc__otag[1][1 : 0] == 0);
      punct_eof   <= enc__oeop [1] &  enc__otag[1][2];
      punct_type  <= enc__otag [1][1 : 0] ;
    end
  end

  rsc2_enc_punct
  #(
    .pWnY ( 0 )
  )
  puncty
  (
    .iclk    ( iclk           ) ,
    .ireset  ( ireset         ) ,
    .iclkena ( iclkena        ) ,
    //
    .icode   ( pCODE          ) ,
    //
    .isop    ( enc__osop  [1] ) ,
    .ival    ( enc__oval  [1] ) ,
    .idat    ( enc__odaty     ) ,
    //
    .oval    ( puncty__oval   ) ,
    .odat    ( puncty__odat   )
  );

  rsc2_enc_punct
  #(
    .pWnY ( 1 )
  )
  punctw
  (
    .iclk    ( iclk           ) ,
    .ireset  ( ireset         ) ,
    .iclkena ( iclkena        ) ,
    //
    .icode   ( pCODE          ) ,
    //
    .isop    ( enc__osop  [1] ) ,
    .ival    ( enc__oval  [1] ) ,
    .idat    ( enc__odatw     ) ,
    //
    .oval    ( punctw__oval   ) ,
    .odat    ( punctw__odat   )
  );

  //------------------------------------------------------------------------------------------------------
  // output stream assembler
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      osop <= punct_sop;
      oeop <= punct_eop;
      //
      if (punct_val) begin
        case (punct_type)
          2'b00   : odat <= punct_dat;
          2'b01   : odat <= puncty__odat;
          2'b10   : odat <= punctw__odat;
          default : begin end
        endcase
      end
    end
  end

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      oval <= 1'b0;
      oeof <= 1'b0; // is single strobe too
    end
    else if (iclkena) begin
      oeof <= punct_eof;
      case (punct_type)
        2'b00   : oval <= punct_val;
        2'b01   : oval <= puncty__oval;
        2'b10   : oval <= punctw__oval;
        default : oval <= punct_val;
      endcase
    end
  end

endmodule

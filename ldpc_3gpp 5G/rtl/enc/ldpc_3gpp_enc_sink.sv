/*



  parameter int pADDR_W = 1 ;
  parameter int pDAT_W  = 2 ;
  parameter int pTAG_W  = 4 ;



  logic                 ldpc_3gpp_enc_sink__iclk      ;
  logic                 ldpc_3gpp_enc_sink__ireset    ;
  logic                 ldpc_3gpp_enc_sink__iclkena   ;
  //
  code_ctx_t            ldpc_3gpp_enc_sink__icode_ctx ;
  //
  logic                 ldpc_3gpp_enc_sink__ifull     ;
  logic  [pDAT_W-1 : 0] ldpc_3gpp_enc_sink__irdat     ;
  logic  [pTAG_W-1 : 0] ldpc_3gpp_enc_sink__irtag     ;
  logic                 ldpc_3gpp_enc_sink__orempty   ;
  logic [pADDR_W-1 : 0] ldpc_3gpp_enc_sink__oraddr    ;
  //
  logic                 ldpc_3gpp_enc_sink__ireq      ;
  logic                 ldpc_3gpp_enc_sink__ofull     ;
  //
  logic                 ldpc_3gpp_enc_sink__osop      ;
  logic                 ldpc_3gpp_enc_sink__oeop      ;
  logic                 ldpc_3gpp_enc_sink__oval      ;
  logic  [pDAT_W-1 : 0] ldpc_3gpp_enc_sink__odat      ;
  logic  [pTAG_W-1 : 0] ldpc_3gpp_enc_sink__otag      ;



  ldpc_3gpp_enc_sink
  #(
    .pADDR_W ( pADDR_W ) ,
    .pDAT_W  ( pDAT_W  ) ,
    .pTAG_W  ( pTAG_W  )
  )
  ldpc_3gpp_enc_sink
  (
    .iclk      ( ldpc_3gpp_enc_sink__iclk      ) ,
    .ireset    ( ldpc_3gpp_enc_sink__ireset    ) ,
    .iclkena   ( ldpc_3gpp_enc_sink__iclkena   ) ,
    //
    .icode_ctx ( ldpc_3gpp_enc_sink__icode_ctx ) ,
    //
    .ifull     ( ldpc_3gpp_enc_sink__ifull     ) ,
    .irdat     ( ldpc_3gpp_enc_sink__irdat     ) ,
    .irtag     ( ldpc_3gpp_enc_sink__irtag     ) ,
    .orempty   ( ldpc_3gpp_enc_sink__orempty   ) ,
    .oraddr    ( ldpc_3gpp_enc_sink__oraddr    ) ,
    //
    .ireq      ( ldpc_3gpp_enc_sink__ireq      ) ,
    .ofull     ( ldpc_3gpp_enc_sink__ofull     ) ,
    //
    .osop      ( ldpc_3gpp_enc_sink__osop      ) ,
    .oeop      ( ldpc_3gpp_enc_sink__oeop      ) ,
    .oval      ( ldpc_3gpp_enc_sink__oval      ) ,
    .odat      ( ldpc_3gpp_enc_sink__odat      ) ,
    .otag      ( ldpc_3gpp_enc_sink__otag      )
  );


  assign ldpc_3gpp_enc_sink__iclk      = '0 ;
  assign ldpc_3gpp_enc_sink__ireset    = '0 ;
  assign ldpc_3gpp_enc_sink__iclkena   = '0 ;
  //
  assign ldpc_3gpp_enc_sink__icode_ctx = '0 ;
  //
  assign ldpc_3gpp_enc_sink__ifull     = '0 ;
  assign ldpc_3gpp_enc_sink__irdat     = '0 ;
  assign ldpc_3gpp_enc_sink__irtag     = '0 ;
  assign ldpc_3gpp_enc_sink__ireq      = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_enc_sink.sv
// Description   : ouput encoder interface module with optional output puncture
//


`include "define.vh"

module ldpc_3gpp_enc_sink
(
  iclk      ,
  ireset    ,
  iclkena   ,
  //
  icode_ctx ,
  //
  ifull     ,
  irdat     ,
  irtag     ,
  orempty   ,
  oraddr    ,
  //
  ireq      ,
  ofull     ,
  //
  osop      ,
  oeop      ,
  oval      ,
  odat      ,
  otag
);

  parameter int pADDR_W = 1 ;
  parameter int pTAG_W  = 4 ;

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_enc_types.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                   iclk      ;
  input  logic                   ireset    ;
  input  logic                   iclkena   ;
  //
  input  code_ctx_t              icode_ctx ;
  //
  input  logic                   ifull     ;
  input  logic    [pDAT_W-1 : 0] irdat     ;
  input  logic    [pTAG_W-1 : 0] irtag     ;
  output logic                   orempty   ;
  output logic   [pADDR_W-1 : 0] oraddr    ;
  //
  input  logic                   ireq      ;
  output logic                   ofull     ;
  //
  output logic                   osop      ;
  output logic                   oeop      ;
  output logic                   oval      ;
  output logic    [pDAT_W-1 : 0] odat      ;
  output logic    [pTAG_W-1 : 0] otag      ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  enum bit {
    cRESET_STATE,
    cDO_STATE
  } state;

  struct packed {
    logic   done;
    hb_zc_t value;
  } z_cnt;

  struct packed {
    logic     done;
    hb_col_t  value;
  } col_cnt;

  hb_zc_t   used_zc;
  hb_col_t  used_col;

  logic     used_zc_less2;
  hb_zc_t   used_zc_m2;

  hb_row_t  used_col_m2;

  logic        [2 : 0] val;
  logic        [2 : 0] eop;

  logic        [1 : 0] set_sf; // set sop/full

  //------------------------------------------------------------------------------------------------------
  // FSM
  //------------------------------------------------------------------------------------------------------

  wire block_done = z_cnt.done & col_cnt.done;

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      state <= cRESET_STATE;
    end
    else if (iclkena) begin
      case (state)
        cRESET_STATE : state <=  ifull              ? cDO_STATE    : cRESET_STATE;
        cDO_STATE    : state <= (ireq & block_done) ? cRESET_STATE : cDO_STATE;
      endcase
    end
  end

  assign orempty = (state == cDO_STATE & ireq & block_done);

  //------------------------------------------------------------------------------------------------------
  // read ram side
  //------------------------------------------------------------------------------------------------------

  assign used_zc  = cZC_TAB[icode_ctx.idxLs][icode_ctx.idxZc] / pDAT_W;
  assign used_col = (icode_ctx.idxGr ? 10 : 22) + ((icode_ctx.code < 4) ? 4 : icode_ctx.code);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (state == cRESET_STATE) begin
        z_cnt       <= '0;
        z_cnt.done <= (used_zc < 2);
        //
        col_cnt     <= '0;  // iused_col >= 10/22
        //
        used_zc_less2 <= (used_zc < 2);
        used_zc_m2    <=  used_zc - 2;
        //
        oraddr      <= icode_ctx.do_punct ? (used_zc << 1) : '0;
        used_col_m2 <= icode_ctx.do_punct ? (used_col - 4) : (used_col - 2);
      end
      else if (state == cDO_STATE & ireq) begin
        z_cnt.value <= z_cnt.done      ?   '0 : (z_cnt.value + 1'b1);
        z_cnt.done  <= (used_zc_less2) ? 1'b1 : (z_cnt.value == used_zc_m2);
        //
        if (z_cnt.done) begin
          col_cnt.value <=  col_cnt.value + 1'b1;
          col_cnt.done  <= (col_cnt.value == used_col_m2);
        end
        //
        oraddr <= oraddr + 1'b1;
      end
    end
  end

  wire start = (state == cRESET_STATE & ifull);

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      val     <= '0;
      set_sf  <= '0;
      //
      ofull   <= 1'b0;
      osop    <= 1'b0;
    end
    else if (iclkena) begin
      val     <= (val << 1) | (state == cDO_STATE & ireq);
      //
      set_sf  <= (set_sf << 1) | start;
      //
      if (set_sf[1])
        ofull <= 1'b1;
      else if (orempty)
        ofull <= 1'b0;
      //
      if (set_sf[1])
        osop <= 1'b1;
      else if (oval)
        osop <= 1'b0;
    end
  end

  assign oval = val[2];

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      eop <= (eop << 1) | (state == cDO_STATE & block_done);
      //
      odat <= irdat;
      if (start) begin
        otag <= irtag;
      end
    end
  end

  assign oeop = eop[2];

endmodule

/*



  parameter int pADDR_W       = 8 ;
  parameter int pLLR_W        = 5 ;
  parameter int pLLR_BY_CYCLE = 1 ;
  parameter int pTAG_W        = 8 ;



  logic                 ldpc_dec_input_buffer__iclk                    ;
  logic                 ldpc_dec_input_buffer__ireset                  ;
  logic                 ldpc_dec_input_buffer__iclkena                 ;
  logic                 ldpc_dec_input_buffer__iwrite                  ;
  logic                 ldpc_dec_input_buffer__iwfull                  ;
  logic [pADDR_W-1 : 0] ldpc_dec_input_buffer__iwaddr                  ;
  logic  [pLLR_W-1 : 0] ldpc_dec_input_buffer__iLLR    [pLLR_BY_CYCLE] ;
  logic  [pTAG_W-1 : 0] ldpc_dec_input_buffer__iwtag                   ;
  logic                 ldpc_dec_input_buffer__irempty                 ;
  logic [pADDR_W-1 : 0] ldpc_dec_input_buffer__iraddr                  ;
  logic  [pLLR_W-1 : 0] ldpc_dec_input_buffer__oLLR    [pLLR_BY_CYCLE] ;
  logic  [pTAG_W-1 : 0] ldpc_dec_input_buffer__ortag                   ;
  logic                 ldpc_dec_input_buffer__oempty                  ;
  logic                 ldpc_dec_input_buffer__oemptya                 ;
  logic                 ldpc_dec_input_buffer__ofull                   ;
  logic                 ldpc_dec_input_buffer__ofulla                  ;



  ldpc_dec_sbuf_input_buffer
  #(
    .pADDR_W       ( pADDR_W       ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pTAG_W        ( pTAG_W        )
  )
  ldpc_dec_input_buffer
  (
    .iclk    ( ldpc_dec_input_buffer__iclk    ) ,
    .ireset  ( ldpc_dec_input_buffer__ireset  ) ,
    .iclkena ( ldpc_dec_input_buffer__iclkena ) ,
    .iwrite  ( ldpc_dec_input_buffer__iwrite  ) ,
    .iwfull  ( ldpc_dec_input_buffer__iwfull  ) ,
    .iwaddr  ( ldpc_dec_input_buffer__iwaddr  ) ,
    .iLLR    ( ldpc_dec_input_buffer__iLLR    ) ,
    .iwtag   ( ldpc_dec_input_buffer__iwtag   ) ,
    .irempty ( ldpc_dec_input_buffer__irempty ) ,
    .iraddr  ( ldpc_dec_input_buffer__iraddr  ) ,
    .oLLR    ( ldpc_dec_input_buffer__oLLR    ) ,
    .ortag   ( ldpc_dec_input_buffer__ortag   ) ,
    .oempty  ( ldpc_dec_input_buffer__oempty  ) ,
    .oemptya ( ldpc_dec_input_buffer__oemptya ) ,
    .ofull   ( ldpc_dec_input_buffer__ofull   ) ,
    .ofulla  ( ldpc_dec_input_buffer__ofulla  )
  );


  assign ldpc_dec_input_buffer__iclk    = '0 ;
  assign ldpc_dec_input_buffer__ireset  = '0 ;
  assign ldpc_dec_input_buffer__iclkena = '0 ;
  assign ldpc_dec_input_buffer__iwrite  = '0 ;
  assign ldpc_dec_input_buffer__iwfull  = '0 ;
  assign ldpc_dec_input_buffer__iwaddr  = '0 ;
  assign ldpc_dec_input_buffer__iLLR    = '0 ;
  assign ldpc_dec_input_buffer__iwtag   = '0 ;
  assign ldpc_dec_input_buffer__irempty = '0 ;
  assign ldpc_dec_input_buffer__iraddr  = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_dec_input_buffer.v
// Description   : input nD ram buffer with nD tag interface with splitter read interface.
//                 Using this buffer it's possible to merge last vnode operations with shift ram update.
//                 Ram read latency is 4 tick
//

`include "define.vh"

module ldpc_dec_sbuf_input_buffer
#(
  parameter int pADDR_W       = 8 ,
  parameter int pLLR_W        = 5 ,
  parameter int pLLR_BY_CYCLE = 1 ,
  parameter int pTAG_W        = 8
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  iwrite  ,
  iwfull  ,
  iwaddr  ,
  iLLR    ,
  iwtag   ,
  //
  iudone  ,
  iuraddr ,
  ouLLR   ,
  //
  irbusy  ,
  irempty ,
  iraddr  ,
  oLLR    ,
  ortag   ,
  //
  oempty  ,
  oemptya ,
  ofull   ,
  ofulla
);

//`include "ldpc_parameters.vh"
//`include "ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                        iclk                    ;
  input  logic                        ireset                  ;
  input  logic                        iclkena                 ;
  //
  input  logic                        iwrite                  ;
  input  logic                        iwfull                  ;
  input  logic        [pADDR_W-1 : 0] iwaddr                  ;
  input  logic signed  [pLLR_W-1 : 0] iLLR    [pLLR_BY_CYCLE] ;
  input  logic         [pTAG_W-1 : 0] iwtag                   ;
  // uploader interface
  input  logic                        iudone                  ;
  input  logic        [pADDR_W-1 : 0] iuraddr                 ;
  output logic signed  [pLLR_W-1 : 0] ouLLR   [pLLR_BY_CYCLE] ;
  // decoder interface
  input  logic                        irbusy                  ;
  input  logic                        irempty                 ;
  input  logic        [pADDR_W-1 : 0] iraddr                  ;
  output logic signed  [pLLR_W-1 : 0] oLLR    [pLLR_BY_CYCLE] ;
  output logic         [pTAG_W-1 : 0] ortag                   ;
  //
  output logic                        oempty                  ; // any buffer is empty
  output logic                        oemptya                 ; // all buffers is empty
  output logic                        ofull                   ; // any buffer is full
  output logic                        ofulla                  ; // all buffers is full

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic b_wused ; // bank write used
  logic b_rused ; // bank read used
  logic db_used ; // decoder bank read used

  //------------------------------------------------------------------------------------------------------
  // buffer logic
  //------------------------------------------------------------------------------------------------------

  ldpc_buffer_nD_slogic
  #(
    .pBNUM_W ( 1 )
  )
  nD_slogic
  (
    .iclk     ( iclk    ) ,
    .ireset   ( ireset  ) ,
    .iclkena  ( iclkena ) ,
    //
    .iwfull   ( iwfull  ) ,
    .ob_wused ( b_wused ) ,
    .irempty  ( irempty ) ,
    .ob_rused ( b_rused ) ,
    //
    .oempty   ( oempty  ) ,
    .oemptya  ( oemptya ) ,
    .ofull    ( ofull   ) ,
    .ofulla   ( ofulla  )
  );

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (iudone & !irbusy)
        db_used <= b_rused;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // LLR ram
  //------------------------------------------------------------------------------------------------------

  localparam int cDAT_W = pLLR_BY_CYCLE*pLLR_W;

  logic  [cDAT_W-1 : 0] ram0 [2**pADDR_W] /* synthesis ramstyle = "no_rw_check" */;
  logic  [cDAT_W-1 : 0] ram1 [2**pADDR_W] /* synthesis ramstyle = "no_rw_check" */;

  logic  [cDAT_W-1 : 0] wdat     ;

  logic [pADDR_W-1 : 0] raddr0   ;
  logic [pADDR_W-1 : 0] raddr1   ;

  logic         [2 : 0] brsel    ;

  logic  [cDAT_W-1 : 0] rdat0_r0 ;
  logic  [cDAT_W-1 : 0] rdat1_r0 ;

  logic  [cDAT_W-1 : 0] rdat0    ;
  logic  [cDAT_W-1 : 0] rdat1    ;

  logic  [cDAT_W-1 : 0] uLLR     ;
  logic  [cDAT_W-1 : 0]  LLR     ;

  always_comb begin
    for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
      wdat[llra*pLLR_W +: pLLR_W] = iLLR[llra]; // stupid QUA
      //
      ouLLR[llra] = uLLR[llra*pLLR_W +: pLLR_W];
      oLLR[llra]  =  LLR[llra*pLLR_W +: pLLR_W];
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      // read side
      if (irbusy) begin
        raddr1    <=  db_used ? iraddr : iuraddr;
        raddr0    <= !db_used ? iraddr : iuraddr;
        brsel[0]  <=  db_used;
      end
      else begin
        raddr1    <=  b_rused ? iuraddr : iraddr;
        raddr0    <= !b_rused ? iuraddr : iraddr;
        brsel[0]  <= !b_rused;
      end
      //
      rdat0_r0  <= ram0[raddr0];
      rdat1_r0  <= ram1[raddr1];
      brsel[1]  <= brsel[0];
      //
      rdat0     <= rdat0_r0;
      rdat1     <= rdat1_r0;
      brsel[2]  <= brsel[1];
      //
      uLLR      <= brsel[2] ? rdat0 : rdat1;
      LLR       <= brsel[2] ? rdat1 : rdat0;
      // write side
      if (iwrite & !b_wused) begin
        ram0[iwaddr] <= wdat;
      end
      if (iwrite & b_wused) begin
        ram1[iwaddr] <= wdat;
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // tag ram
  //------------------------------------------------------------------------------------------------------

  logic [pTAG_W-1 : 0] tram [0 : 1] /* synthesis ramstyle = "logic" */;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (iwfull)
        tram [b_wused] <= iwtag;
    end
  end

  assign ortag = tram[b_rused];

endmodule

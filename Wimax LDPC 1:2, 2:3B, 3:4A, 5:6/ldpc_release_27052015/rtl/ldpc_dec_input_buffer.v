/*



  parameter int pADDR_W       = 8 ;
  parameter int pLLR_W        = 5 ;
  parameter int pLLR_BY_CYCLE = 1 ;
  parameter int pTAG_W        = 8 ;
  parameter int pBNUM_W       = 1 ;



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



  ldpc_dec_input_buffer
  #(
    .pADDR_W       ( pADDR_W       ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pTAG_W        ( pTAG_W        ) ,
    .pBNUM_W       ( pBNUM_W       )
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
// Description   : input nD ram buffer with nD tag interface. Ram read latency is 2 tick
//

module ldpc_dec_input_buffer
#(
  parameter int pADDR_W       = 8 ,
  parameter int pLLR_W        = 5 ,
  parameter int pLLR_BY_CYCLE = 1 ,
  parameter int pTAG_W        = 8 ,
  parameter int pBNUM_W       = 1
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
  //
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

  localparam int cADDR_W = pADDR_W + pBNUM_W;

  logic [pBNUM_W-1 : 0] b_wused ; // bank write used
  logic [pBNUM_W-1 : 0] b_rused ; // bank read used

  //------------------------------------------------------------------------------------------------------
  // buffer logic
  //------------------------------------------------------------------------------------------------------

  ldpc_buffer_nD_slogic
  #(
    .pBNUM_W ( pBNUM_W )
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

  //------------------------------------------------------------------------------------------------------
  // LLR ram
  //------------------------------------------------------------------------------------------------------

  localparam int cDAT_W = pLLR_BY_CYCLE*pLLR_W;

  logic  [cDAT_W-1 : 0] ram [2**cADDR_W] /* synthesis ramstyle = "no_rw_check" */;

  logic  [cDAT_W-1 : 0] wdat    ;
  logic  [cDAT_W-1 : 0] rdat_r0 ;
  logic  [cDAT_W-1 : 0] rdat    ;

  always_comb begin
    for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
      wdat[llra*pLLR_W +: pLLR_W] = iLLR[llra]; // stupid QUA
      //
      oLLR[llra] = rdat[llra*pLLR_W +: pLLR_W];
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      rdat_r0 <= ram[{b_rused, iraddr}];
      rdat    <= rdat_r0;
      //
      if (iwrite) begin
        ram[{b_wused, iwaddr}] <= wdat;
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // tag ram
  //------------------------------------------------------------------------------------------------------

  logic [pTAG_W-1 : 0] tram [0 : (2**pBNUM_W)-1] /* synthesis ramstyle = "logic" */;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (iwfull)
        tram [b_wused] <= iwtag;
    end
  end

  assign ortag = tram[b_rused];

endmodule

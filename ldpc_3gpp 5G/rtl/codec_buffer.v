/*



  parameter int pADDR_W = 8 ;
  parameter int pDAT_W  = 5 ;
  parameter int pTAG_W  = 8 ;
  parameter int pPIPE   = 1 ;



  logic                 codec_buffer__iclk    ;
  logic                 codec_buffer__ireset  ;
  logic                 codec_buffer__iclkena ;
  logic                 codec_buffer__iwrite  ;
  logic                 codec_buffer__iwfull  ;
  logic [pADDR_W-1 : 0] codec_buffer__iwaddr  ;
  logic  [pDAT_W-1 : 0] codec_buffer__iwdat   ;
  logic  [pTAG_W-1 : 0] codec_buffer__iwtag   ;
  logic                 codec_buffer__irempty ;
  logic [pADDR_W-1 : 0] codec_buffer__iraddr  ;
  logic  [pDAT_W-1 : 0] codec_buffer__ordat   ;
  logic  [pTAG_W-1 : 0] codec_buffer__ortag   ;
  logic                 codec_buffer__oempty  ;
  logic                 codec_buffer__oemptya ;
  logic                 codec_buffer__ofull   ;
  logic                 codec_buffer__ofulla  ;



  codec_buffer
  #(
    .pADDR_W ( pADDR_W ) ,
    .pDAT_W  ( pDAT_W  ) ,
    .pTAG_W  ( pTAG_W  ) ,
    .pPIPE   ( pPIPE   )
  )
  codec_buffer
  (
    .iclk    ( codec_buffer__iclk    ) ,
    .ireset  ( codec_buffer__ireset  ) ,
    .iclkena ( codec_buffer__iclkena ) ,
    .iwrite  ( codec_buffer__iwrite  ) ,
    .iwfull  ( codec_buffer__iwfull  ) ,
    .iwaddr  ( codec_buffer__iwaddr  ) ,
    .iwdat   ( codec_buffer__iwdat   ) ,
    .iwtag   ( codec_buffer__iwtag   ) ,
    .irempty ( codec_buffer__irempty ) ,
    .iraddr  ( codec_buffer__iraddr  ) ,
    .ordat   ( codec_buffer__ordat   ) ,
    .ortag   ( codec_buffer__ortag   ) ,
    .oempty  ( codec_buffer__oempty  ) ,
    .oemptya ( codec_buffer__oemptya ) ,
    .ofull   ( codec_buffer__ofull   ) ,
    .ofulla  ( codec_buffer__ofulla  )
  );


  assign codec_buffer__iclk    = '0 ;
  assign codec_buffer__ireset  = '0 ;
  assign codec_buffer__iclkena = '0 ;
  assign codec_buffer__iwrite  = '0 ;
  assign codec_buffer__iwfull  = '0 ;
  assign codec_buffer__iwaddr  = '0 ;
  assign codec_buffer__iwdat   = '0 ;
  assign codec_buffer__iwtag   = '0 ;
  assign codec_buffer__irempty = '0 ;
  assign codec_buffer__iraddr  = '0 ;



*/

//
// Project       : coding library
// Author        : Shekhalev Denis (des00)
// Workfile      : codec_buffer.v
// Description   : synchronus 2D ram buffer with 2D tag interface. Ram read latency is 2 tick
//

module codec_buffer
#(
  parameter int pADDR_W = 8 ,
  parameter int pDAT_W  = 8 ,
  parameter int pTAG_W  = 8 ,
  parameter int pPIPE   = 1
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  iwrite  ,
  iwfull  ,
  iwaddr  ,
  iwdat   ,
  iwtag   ,
  //
  irempty ,
  iraddr  ,
  ordat   ,
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

  input  logic                 iclk    ;
  input  logic                 ireset  ;
  input  logic                 iclkena ;
  //
  input  logic                 iwrite  ;
  input  logic                 iwfull  ;
  input  logic [pADDR_W-1 : 0] iwaddr  ;
  input  logic  [pDAT_W-1 : 0] iwdat   ;
  input  logic  [pTAG_W-1 : 0] iwtag   ;
  //
  input  logic                 irempty ;
  input  logic [pADDR_W-1 : 0] iraddr  ;
  output logic  [pDAT_W-1 : 0] ordat   ;
  output logic  [pTAG_W-1 : 0] ortag   ;
  //
  output logic                 oempty  ; // any buffer is empty
  output logic                 oemptya ; // all buffers is empty
  output logic                 ofull   ; // any buffer is full
  output logic                 ofulla  ; // all buffers is full

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cADDR_W  = pADDR_W + 1;
  localparam int cDAT_W   = pDAT_W;

  logic b_wused ; // bank write used
  logic b_rused ; // bank read used

  //------------------------------------------------------------------------------------------------------
  // buffer logic
  //------------------------------------------------------------------------------------------------------

  codec_buffer_nD_slogic
  #(
    .pBNUM_W ( 1 )  // 2D buffer
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
  // ram
  //------------------------------------------------------------------------------------------------------

  codec_mem_block
  #(
    .pADDR_W ( cADDR_W ) ,
    .pDAT_W  ( pDAT_W  ) ,
    .pPIPE   ( pPIPE   )
  )
  mem
  (
    .iclk    ( iclk              ) ,
    .ireset  ( ireset            ) ,
    .iclkena ( iclkena           ) ,
    //
    .iwrite  ( iwrite            ) ,
    .iwaddr  ( {b_wused, iwaddr} ) ,
    .iwdat   ( iwdat             ) ,
    //
    .iraddr  ( {b_rused, iraddr} ) ,
    .ordat   ( ordat             )
  );

  //------------------------------------------------------------------------------------------------------
  // tag ram
  //------------------------------------------------------------------------------------------------------

  logic [pTAG_W-1 : 0] tram [2] /* synthesis ramstyle = "logic" */ = '{default : '0};

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (iwfull) begin
        tram [b_wused] <= iwtag;
      end
    end
  end

  assign ortag = tram[b_rused];

endmodule

/*



  parameter int pADDR_W  = 8 ;
  parameter int pDAT_W   = 8 ;
  parameter int pTAG_W   = 4 ;
  parameter int pBNUM_W  = 2 ;



  logic                 pc_3gpp_dec_int_buff__iclk     ;
  logic                 pc_3gpp_dec_int_buff__ireset   ;
  logic                 pc_3gpp_dec_int_buff__iclkena  ;
  logic                 pc_3gpp_dec_int_buff__iwrite   ;
  logic                 pc_3gpp_dec_int_buff__iwfull   ;
  logic [pADDR_W-1 : 0] pc_3gpp_dec_int_buff__iwaddr   ;
  logic  [pDAT_W-1 : 0] pc_3gpp_dec_int_buff__iwdat    ;
  logic  [pTAG_W-1 : 0] pc_3gpp_dec_int_buff__iwtag    ;
  logic                 pc_3gpp_dec_int_buff__irempty  ;
  logic [pADDR_W-1 : 0] pc_3gpp_dec_int_buff__iraddr   ;
  logic  [pDAT_W-1 : 0] pc_3gpp_dec_int_buff__ordat    ;
  logic  [pTAG_W-1 : 0] pc_3gpp_dec_int_buff__ortag    ;
  logic                 pc_3gpp_dec_int_buff__oempty   ;
  logic                 pc_3gpp_dec_int_buff__oemptya  ;
  logic                 pc_3gpp_dec_int_buff__ofull    ;
  logic                 pc_3gpp_dec_int_buff__ofulla   ;



  pc_3gpp_dec_int_buff
  #(
    .pADDR_W ( pADDR_W ) ,
    .pDAT_W  ( pDAT_W  ) ,
    .pTAG_W  ( pTAG_W  ) ,
    .pBNUM_W ( pBNUM_W )
  )
  pc_3gpp_dec_int_buff
  (
    .iclk    ( pc_3gpp_dec_int_buff__iclk    ) ,
    .ireset  ( pc_3gpp_dec_int_buff__ireset  ) ,
    .iclkena ( pc_3gpp_dec_int_buff__iclkena ) ,
    .iwrite  ( pc_3gpp_dec_int_buff__iwrite  ) ,
    .iwfull  ( pc_3gpp_dec_int_buff__iwfull  ) ,
    .iwaddr  ( pc_3gpp_dec_int_buff__iwaddr  ) ,
    .iwdat   ( pc_3gpp_dec_int_buff__iwdat   ) ,
    .iwtag   ( pc_3gpp_dec_int_buff__iwtag   ) ,
    .irempty ( pc_3gpp_dec_int_buff__irempty ) ,
    .iraddr  ( pc_3gpp_dec_int_buff__iraddr  ) ,
    .ordat   ( pc_3gpp_dec_int_buff__ordat   ) ,
    .ortag   ( pc_3gpp_dec_int_buff__ortag   ) ,
    .oempty  ( pc_3gpp_dec_int_buff__oempty  ) ,
    .oemptya ( pc_3gpp_dec_int_buff__oemptya ) ,
    .ofull   ( pc_3gpp_dec_int_buff__ofull   ) ,
    .ofulla  ( pc_3gpp_dec_int_buff__ofulla  )
  );


  assign pc_3gpp_dec_int_buff__iclk    = '0 ;
  assign pc_3gpp_dec_int_buff__ireset  = '0 ;
  assign pc_3gpp_dec_int_buff__iclkena = '0 ;
  assign pc_3gpp_dec_int_buff__iwrite  = '0 ;
  assign pc_3gpp_dec_int_buff__iwfull  = '0 ;
  assign pc_3gpp_dec_int_buff__iwaddr  = '0 ;
  assign pc_3gpp_dec_int_buff__iwdat   = '0 ;
  assign pc_3gpp_dec_int_buff__iwtag   = '0 ;
  assign pc_3gpp_dec_int_buff__irempty = '0 ;
  assign pc_3gpp_dec_int_buff__iraddr  = '0 ;



*/

//
// Project       : polar code 3gpp
// Author        : Shekhalev Denis (des00)
// Workfile      : pc_3gpp_dec_int_buf.v
// Description   : Polar deocde internal nD buffer for reencoding to get decoded frame from decoded non systematic coding frame
//

module pc_3gpp_dec_int_buff
#(
  parameter int pADDR_W  = 8 ,
  parameter int pDAT_W   = 8 ,
  parameter int pTAG_W   = 4 ,
  parameter int pBNUM_W  = 2
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

  input  logic                 iclk     ;
  input  logic                 ireset   ;
  input  logic                 iclkena  ;
  //
  input  logic                 iwrite   ;
  input  logic                 iwfull   ;
  input  logic [pADDR_W-1 : 0] iwaddr   ;
  input  logic  [pDAT_W-1 : 0] iwdat    ;
  input  logic  [pTAG_W-1 : 0] iwtag    ;
  //
  input  logic                 irempty  ;
  input  logic [pADDR_W-1 : 0] iraddr   ;
  output logic  [pDAT_W-1 : 0] ordat    ;
  output logic  [pTAG_W-1 : 0] ortag    ;
  //
  output logic                 oempty   ;
  output logic                 oemptya  ;
  output logic                 ofull    ;
  output logic                 ofulla   ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cRAM_ADDR_W = pADDR_W + pBNUM_W;
  localparam int cRAM_DATA_W = pDAT_W;

  logic [pBNUM_W-1 : 0] b_wused ; // bank write used
  logic [pBNUM_W-1 : 0] b_rused ; // bank read used

  logic [cRAM_ADDR_W-1 : 0] ram_waddr;
  logic [cRAM_ADDR_W-1 : 0] ram_raddr;

  //------------------------------------------------------------------------------------------------------
  // buffer logic
  //------------------------------------------------------------------------------------------------------

  polar_buffer_nD_slogic
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

  assign ram_waddr  = {b_wused, iwaddr};
  assign ram_raddr  = {b_rused, iraddr};

  //------------------------------------------------------------------------------------------------------
  // data ram
  //------------------------------------------------------------------------------------------------------

  polar_mem_block
  #(
    .pADDR_W ( cRAM_ADDR_W ) ,
    .pDAT_W  ( cRAM_DATA_W ) ,
    .pPIPE   ( 0           )
  )
  mem
  (
    .iclk    ( iclk       ) ,
    .ireset  ( ireset     ) ,
    .iclkena ( iclkena    ) ,
    //
    .iwrite  ( iwrite     ) ,
    .iwaddr  ( ram_waddr  ) ,
    .iwdat   ( iwdat      ) ,
    //
    .iraddr  ( ram_raddr  ) ,
    .ordat   ( ordat      )
  );

  //------------------------------------------------------------------------------------------------------
  // tag ram
  //------------------------------------------------------------------------------------------------------

  logic [pTAG_W-1 : 0] tram [0 : (2**pBNUM_W)-1] /*synthesis ramstyle = "logic"*/;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (iwfull)
        tram [b_wused] <= iwtag;
    end
  end

  assign ortag = tram[b_rused];

endmodule

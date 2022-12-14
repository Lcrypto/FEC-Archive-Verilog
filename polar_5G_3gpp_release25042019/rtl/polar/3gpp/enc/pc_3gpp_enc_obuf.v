/*



  parameter int pWADDR_W  = 8 ;
  parameter int pWDAT_W   = 8 ;
  parameter int pRADDR_W  = 8 ;
  parameter int pRDAT_W   = 8 ;
  parameter int pTAG_W    = 4 ;
  parameter int pBNUM_W   = 2 ;



  logic                  pc_3gpp_enc_obuf__iclk     ;
  logic                  pc_3gpp_enc_obuf__ireset   ;
  logic                  pc_3gpp_enc_obuf__iclkena  ;
  logic                  pc_3gpp_enc_obuf__iwrite   ;
  logic                  pc_3gpp_enc_obuf__iwfull   ;
  logic [pWADDR_W-1 : 0] pc_3gpp_enc_obuf__iwaddr   ;
  logic  [pWDAT_W-1 : 0] pc_3gpp_enc_obuf__iwdat    ;
  logic   [pTAG_W-1 : 0] pc_3gpp_enc_obuf__iwtag    ;
  logic                  pc_3gpp_enc_obuf__irempty  ;
  logic [pRADDR_W-1 : 0] pc_3gpp_enc_obuf__iraddr   ;
  logic  [RpDAT_W-1 : 0] pc_3gpp_enc_obuf__ordat    ;
  logic   [pTAG_W-1 : 0] pc_3gpp_enc_obuf__ortag    ;
  logic                  pc_3gpp_enc_obuf__oempty   ;
  logic                  pc_3gpp_enc_obuf__oemptya  ;
  logic                  pc_3gpp_enc_obuf__ofull    ;
  logic                  pc_3gpp_enc_obuf__ofulla   ;



  pc_3gpp_enc_obuf
  #(
    .pWADDR_W ( pWADDR_W ) ,
    .pWDAT_W  ( pWDAT_W  ) ,
    .pRADDR_W ( pRADDR_W ) ,
    .pRDAT_W  ( pRDAT_W  ) ,
    .pTAG_W   ( pTAG_W   ) ,
    .pBNUM_W  ( pBNUM_W  )
  )
  pc_3gpp_enc_obuf
  (
    .iclk    ( pc_3gpp_enc_obuf__iclk    ) ,
    .ireset  ( pc_3gpp_enc_obuf__ireset  ) ,
    .iclkena ( pc_3gpp_enc_obuf__iclkena ) ,
    .iwrite  ( pc_3gpp_enc_obuf__iwrite  ) ,
    .iwfull  ( pc_3gpp_enc_obuf__iwfull  ) ,
    .iwaddr  ( pc_3gpp_enc_obuf__iwaddr  ) ,
    .iwdat   ( pc_3gpp_enc_obuf__iwdat   ) ,
    .iwtag   ( pc_3gpp_enc_obuf__iwtag   ) ,
    .irempty ( pc_3gpp_enc_obuf__irempty ) ,
    .iraddr  ( pc_3gpp_enc_obuf__iraddr  ) ,
    .ordat   ( pc_3gpp_enc_obuf__ordat   ) ,
    .ortag   ( pc_3gpp_enc_obuf__ortag   ) ,
    .oempty  ( pc_3gpp_enc_obuf__oempty  ) ,
    .oemptya ( pc_3gpp_enc_obuf__oemptya ) ,
    .ofull   ( pc_3gpp_enc_obuf__ofull   ) ,
    .ofulla  ( pc_3gpp_enc_obuf__ofulla  )
  );


  assign pc_3gpp_enc_obuf__iclk    = '0 ;
  assign pc_3gpp_enc_obuf__ireset  = '0 ;
  assign pc_3gpp_enc_obuf__iclkena = '0 ;
  assign pc_3gpp_enc_obuf__iwrite  = '0 ;
  assign pc_3gpp_enc_obuf__iwfull  = '0 ;
  assign pc_3gpp_enc_obuf__iwaddr  = '0 ;
  assign pc_3gpp_enc_obuf__iwdat   = '0 ;
  assign pc_3gpp_enc_obuf__iwtag   = '0 ;
  assign pc_3gpp_enc_obuf__irempty = '0 ;
  assign pc_3gpp_enc_obuf__iraddr  = '0 ;



*/

//
// Project       : polar code 3gpp
// Author        : Shekhalev Denis (des00)
// Workfile      : pc_3gpp_enc_obuf.v
// Description   : Encoder output nD buffer with manual coded DWC at reading
//

module pc_3gpp_enc_obuf
#(
  parameter int pWADDR_W  = 8 ,
  parameter int pWDAT_W   = 8 ,
  //
  parameter int pRADDR_W  = 8 , // >= pWADDR_W
  parameter int pRDAT_W   = 8 , // <= pWDAT_W, must be multiple of pWDAT_W
  //
  parameter int pTAG_W    = 4 ,
  parameter int pBNUM_W   = 2
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

  input  logic                  iclk     ;
  input  logic                  ireset   ;
  input  logic                  iclkena  ;
  //
  input  logic                  iwrite   ;
  input  logic                  iwfull   ;
  input  logic [pWADDR_W-1 : 0] iwaddr   ;
  input  logic  [pWDAT_W-1 : 0] iwdat    ;
  input  logic   [pTAG_W-1 : 0] iwtag    ;
  //
  input  logic                  irempty  ;
  input  logic [pRADDR_W-1 : 0] iraddr   ;
  output logic  [pRDAT_W-1 : 0] ordat    ;
  output logic   [pTAG_W-1 : 0] ortag    ;
  //
  output logic                  oempty   ;
  output logic                  oemptya  ;
  output logic                  ofull    ;
  output logic                  ofulla   ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cRAM_ADDR_W    = pWADDR_W + pBNUM_W;
  localparam int cRAM_DATA_W    = pWDAT_W;

  localparam int cDWC_FACTOR    = pWDAT_W/pRDAT_W;
  localparam int cDWC_FACTOR_W  = pRADDR_W - pWADDR_W;

  logic [pBNUM_W-1 : 0] b_wused ; // bank write used
  logic [pBNUM_W-1 : 0] b_rused ; // bank read used

  logic [cRAM_ADDR_W-1 : 0] ram_waddr;
  logic [cRAM_ADDR_W-1 : 0] ram_raddr;
  logic [cRAM_DATA_W-1 : 0] ram_rdat;

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
  assign ram_raddr  = {b_rused, iraddr[pRADDR_W-1 -: pWADDR_W]};

  //------------------------------------------------------------------------------------------------------
  // data ram
  //------------------------------------------------------------------------------------------------------
`ifdef __USE_ALTERA_MACRO__

  localparam int cRAM_RADDR_W = pRADDR_W + pBNUM_W;
  localparam int cRAM_RDAT_W  = pRDAT_W;

  altsyncram
  #(
    .address_aclr_b                     ( "NONE"          ) ,
    .address_reg_b                      ( "CLOCK0"        ) ,
    //
    .lpm_type                           ( "altsyncram"    ) ,
    //
    .numwords_a                         ( 2**cRAM_ADDR_W  ) ,
    .numwords_b                         ( 2**cRAM_RADDR_W ) ,
    //
    .operation_mode                     ( "DUAL_PORT"     ) ,
    .outdata_aclr_b                     ( "NONE"          ) ,
    .outdata_reg_b                      ( "UNREGISTERED"  ) ,
    .power_up_uninitialized             ( "FALSE"         ) ,
    .read_during_write_mode_mixed_ports ( "DONT_CARE"     ) ,
    //
    .widthad_a                          ( cRAM_ADDR_W     ) ,
    .widthad_b                          ( cRAM_RADDR_W    ) ,
    //
    .width_a                            ( cRAM_DATA_W     ) ,
    .width_b                            ( cRAM_RDAT_W     ) ,
    //
    .width_byteena_a                    ( 1               )
  )
  ram
  (
    .address_a      ( ram_waddr           ),
    .address_b      ( {b_rused, iraddr}   ),
    .clock0         ( iclk                ),
    .data_a         ( iwdat               ),
    .wren_a         ( iwrite              ),
    .q_b            ( ordat               ),
    //
    .aclr0          ( 1'b0                ),
    .aclr1          ( 1'b0                ),
    .addressstall_a ( 1'b0                ),
    .addressstall_b ( 1'b0                ),
    .byteena_a      ( 1'b1                ),
    .byteena_b      ( 1'b1                ),
    .clock1         ( 1'b1                ),
    .clocken0       ( iclkena             ),
    .clocken1       ( 1'b1                ),
    .clocken2       ( 1'b1                ),
    .clocken3       ( 1'b1                ),
    .data_b         ( {cRAM_RDAT_W{1'b1}} ),
    .eccstatus      (                     ),
    .q_a            (                     ),
    .rden_a         ( 1'b1                ),
    .rden_b         ( 1'b1                ),
    .wren_b         ( 1'b0                )
  );
`else
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
    .ordat   ( ram_rdat   )
  );

  //------------------------------------------------------------------------------------------------------
  // manual read DWC converter
  //------------------------------------------------------------------------------------------------------

  logic [cDWC_FACTOR_W-1 : 0] rsel;

  generate
    if (cDWC_FACTOR <= 1) begin
      assign ordat = ram_rdat;
    end
    else begin
      always_ff @(posedge iclk) begin
        if (iclkena) begin
          rsel <= iraddr[cDWC_FACTOR_W-1 : 0];
        end
      end

      assign ordat = ram_rdat[rsel*pRDAT_W +: pRDAT_W];
    end
  endgenerate
`endif
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

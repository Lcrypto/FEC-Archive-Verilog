/*



  parameter int pWADDR_W  = 8 ;
  parameter int pWDAT_W   = 1 ;
  parameter int pRADDR_W  = 8 ;
  parameter int pRDAT_W   = 8 ;
  parameter int pTAG_W    = 4 ;
  parameter int pBNUM_W   = 2 ;



  logic                  pc_3gpp_enc_ibuf__iclk     ;
  logic                  pc_3gpp_enc_ibuf__ireset   ;
  logic                  pc_3gpp_enc_ibuf__iclkena  ;
  logic                  pc_3gpp_enc_ibuf__iwrite   ;
  logic                  pc_3gpp_enc_ibuf__iwfull   ;
  logic [pWADDR_W-1 : 0] pc_3gpp_enc_ibuf__iwaddr   ;
  logic  [pWDAT_W-1 : 0] pc_3gpp_enc_ibuf__iwdat    ;
  logic   [pTAG_W-1 : 0] pc_3gpp_enc_ibuf__iwtag    ;
  logic                  pc_3gpp_enc_ibuf__irempty  ;
  logic [pRADDR_W-1 : 0] pc_3gpp_enc_ibuf__iraddr   ;
  logic  [pRDAT_W-1 : 0] pc_3gpp_enc_ibuf__ordat    ;
  logic   [pTAG_W-1 : 0] pc_3gpp_enc_ibuf__ortag    ;
  logic                  pc_3gpp_enc_ibuf__oempty   ;
  logic                  pc_3gpp_enc_ibuf__oemptya  ;
  logic                  pc_3gpp_enc_ibuf__ofull    ;
  logic                  pc_3gpp_enc_ibuf__ofulla   ;



  pc_3gpp_enc_ibuf
  #(
    .pWADDR_W ( pWADDR_W ) ,
    .pWDAT_W  ( pWDAT_W  ) ,
    .pRADDR_W ( pRADDR_W ) ,
    .pRDAT_W  ( pRDAT_W  ) ,
    .pTAG_W   ( pTAG_W   ) ,
    .pBNUM_W  ( pBNUM_W  )
  )
  pc_3gpp_enc_ibuf
  (
    .iclk    ( pc_3gpp_enc_ibuf__iclk    ) ,
    .ireset  ( pc_3gpp_enc_ibuf__ireset  ) ,
    .iclkena ( pc_3gpp_enc_ibuf__iclkena ) ,
    .iwrite  ( pc_3gpp_enc_ibuf__iwrite  ) ,
    .iwfull  ( pc_3gpp_enc_ibuf__iwfull  ) ,
    .iwaddr  ( pc_3gpp_enc_ibuf__iwaddr  ) ,
    .iwdat   ( pc_3gpp_enc_ibuf__iwdat   ) ,
    .iwtag   ( pc_3gpp_enc_ibuf__iwtag   ) ,
    .irempty ( pc_3gpp_enc_ibuf__irempty ) ,
    .iraddr  ( pc_3gpp_enc_ibuf__iraddr  ) ,
    .ordat   ( pc_3gpp_enc_ibuf__ordat   ) ,
    .ortag   ( pc_3gpp_enc_ibuf__ortag   ) ,
    .oempty  ( pc_3gpp_enc_ibuf__oempty  ) ,
    .oemptya ( pc_3gpp_enc_ibuf__oemptya ) ,
    .ofull   ( pc_3gpp_enc_ibuf__ofull   ) ,
    .ofulla  ( pc_3gpp_enc_ibuf__ofulla  )
  );


  assign pc_3gpp_enc_ibuf__iclk    = '0 ;
  assign pc_3gpp_enc_ibuf__ireset  = '0 ;
  assign pc_3gpp_enc_ibuf__iclkena = '0 ;
  assign pc_3gpp_enc_ibuf__iwrite  = '0 ;
  assign pc_3gpp_enc_ibuf__iwfull  = '0 ;
  assign pc_3gpp_enc_ibuf__iwaddr  = '0 ;
  assign pc_3gpp_enc_ibuf__iwdat   = '0 ;
  assign pc_3gpp_enc_ibuf__iwtag   = '0 ;
  assign pc_3gpp_enc_ibuf__irempty = '0 ;
  assign pc_3gpp_enc_ibuf__iraddr  = '0 ;



*/

//
// Project       : polar code 3gpp
// Author        : Shekhalev Denis (des00)
// Workfile      : pc_3gpp_enc_ibuf.v
// Description   : Encoder input nD buffer with manual coded DWC at writing
//

module pc_3gpp_enc_ibuf
#(
  parameter int pWADDR_W  = 8 ,
  parameter int pWDAT_W   = 1 ,
  //
  parameter int pRADDR_W  = 8 ,
  parameter int pRDAT_W   = 8 ,
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

  localparam int cRAM_WADDR_W = pWADDR_W + pBNUM_W;
  localparam int cRAM_WDAT_W  = pWDAT_W;

  localparam int cRAM_RADDR_W = pRADDR_W + pBNUM_W;
  localparam int cRAM_RDAT_W  = pRDAT_W;

  localparam int cRAMB_N      = pRDAT_W/pWDAT_W;
  localparam int cLSB_W       = cRAM_WADDR_W - cRAM_RADDR_W;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [pBNUM_W-1 : 0] b_wused ; // bank write used
  logic [pBNUM_W-1 : 0] b_rused ; // bank read used

  logic [cRAM_WADDR_W-1 : 0] ram_waddr;
  logic [cRAM_RADDR_W-1 : 0] ram_raddr;

  logic                      mem__iwrite [cRAMB_N];
  logic [cRAM_RADDR_W-1 : 0] mem__iwaddr [cRAMB_N];
  logic  [cRAM_WDAT_W-1 : 0] mem__iwdat  [cRAMB_N];

  logic [cRAM_RADDR_W-1 : 0] mem__iraddr [cRAMB_N];
  logic  [cRAM_WDAT_W-1 : 0] mem__ordat  [cRAMB_N];

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
  // data/frozen bit ram
  //------------------------------------------------------------------------------------------------------
`ifdef __USE_ALTERA_MACRO__
  altsyncram
  #(
    .address_aclr_b                     ( "NONE"          ) ,
    .address_reg_b                      ( "CLOCK0"        ) ,
    //
    .lpm_type                           ( "altsyncram"    ) ,
    //
    .numwords_a                         ( 2**cRAM_WADDR_W ) ,
    .numwords_b                         ( 2**cRAM_RADDR_W ) ,
    //
    .operation_mode                     ( "DUAL_PORT"     ) ,
    .outdata_aclr_b                     ( "NONE"          ) ,
    .outdata_reg_b                      ( "UNREGISTERED"  ) ,
    .power_up_uninitialized             ( "FALSE"         ) ,
    .read_during_write_mode_mixed_ports ( "DONT_CARE"     ) ,
    //
    .widthad_a                          ( cRAM_WADDR_W    ) ,
    .widthad_b                          ( cRAM_RADDR_W    ) ,
    //
    .width_a                            ( cRAM_WDAT_W     ) ,
    .width_b                            ( cRAM_RDAT_W     ) ,
    //
    .width_byteena_a                    ( 1               )
  )
  ram
  (
    .address_a      ( ram_waddr           ),
    .address_b      ( ram_raddr           ),
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
  generate
    genvar i;
    for (i = 0; i < cRAMB_N; i++) begin : ram_inst_gen

      polar_mem_block
      #(
        .pADDR_W ( cRAM_RADDR_W ) ,
        .pDAT_W  ( cRAM_WDAT_W  ) ,
        .pPIPE   ( 0            )
      )
      mem
      (
        .iclk    ( iclk            ) ,
        .ireset  ( ireset          ) ,
        .iclkena ( iclkena         ) ,
        //
        .iwrite  ( mem__iwrite [i] ) ,
        .iwaddr  ( mem__iwaddr [i] ) ,
        .iwdat   ( mem__iwdat  [i] ) ,
        //
        .iraddr  ( mem__iraddr [i] ) ,
        .ordat   ( mem__ordat  [i] )
      );

      assign mem__iwrite[i] = iwrite & (ram_waddr[cLSB_W-1 : 0] == i);
      assign mem__iwaddr[i] = ram_waddr[cRAM_WADDR_W-1 -: cRAM_RADDR_W];
      assign mem__iwdat [i] = iwdat;

      assign mem__iraddr[i] = ram_raddr;

      assign ordat[i*pWDAT_W +: pWDAT_W] = mem__ordat[i];
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

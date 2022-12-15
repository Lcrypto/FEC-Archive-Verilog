/*



  parameter int pDATA_W  = 32 ;
  parameter int pADDR_W  =  8 ;



  logic                 rsc_dec_extr_ram__iclk     ;
  logic                 rsc_dec_extr_ram__ireset   ;
  logic                 rsc_dec_extr_ram__iclkena  ;
  logic                 rsc_dec_extr_ram__iwrite   ;
  logic [pADDR_W-1 : 0] rsc_dec_extr_ram__iwaddr0  ;
  logic [pDATA_W-1 : 0] rsc_dec_extr_ram__iwdata0  ;
  logic [pADDR_W-1 : 0] rsc_dec_extr_ram__iwaddr1  ;
  logic [pDATA_W-1 : 0] rsc_dec_extr_ram__iwdata1  ;
  logic                 rsc_dec_extr_ram__iread    ;
  logic [pADDR_W-1 : 0] rsc_dec_extr_ram__iraddr0  ;
  logic [pDATA_W-1 : 0] rsc_dec_extr_ram__ordata0  ;
  logic [pADDR_W-1 : 0] rsc_dec_extr_ram__iraddr1  ;
  logic [pDATA_W-1 : 0] rsc_dec_extr_ram__ordata1  ;



  rsc_dec_extr_ram
  #(
    .pDATA_W ( pDATA_W ) ,
    .pADDR_W ( pADDR_W )
  )
  rsc_dec_extr_ram
  (
    .iclk    ( rsc_dec_extr_ram__iclk    ) ,
    .ireset  ( rsc_dec_extr_ram__ireset  ) ,
    .iclkena ( rsc_dec_extr_ram__iclkena ) ,
    .iwrite  ( rsc_dec_extr_ram__iwrite  ) ,
    .iwaddr0 ( rsc_dec_extr_ram__iwaddr0 ) ,
    .iwdata0 ( rsc_dec_extr_ram__iwdata0 ) ,
    .iwaddr1 ( rsc_dec_extr_ram__iwaddr1 ) ,
    .iwdata1 ( rsc_dec_extr_ram__iwdata1 ) ,
    .iread   ( rsc_dec_extr_ram__iread   ) ,
    .iraddr0 ( rsc_dec_extr_ram__iraddr0 ) ,
    .ordata0 ( rsc_dec_extr_ram__ordata0 ) ,
    .iraddr1 ( rsc_dec_extr_ram__iraddr1 ) ,
    .ordata1 ( rsc_dec_extr_ram__ordata1 )
  );


  assign rsc_dec_extr_ram__iclk    = '0 ;
  assign rsc_dec_extr_ram__ireset  = '0 ;
  assign rsc_dec_extr_ram__iclkena = '0 ;
  assign rsc_dec_extr_ram__iwrite  = '0 ;
  assign rsc_dec_extr_ram__iwaddr0 = '0 ;
  assign rsc_dec_extr_ram__iwdata0 = '0 ;
  assign rsc_dec_extr_ram__iwaddr1 = '0 ;
  assign rsc_dec_extr_ram__iwdata1 = '0 ;
  assign rsc_dec_extr_ram__iread   = '0 ;
  assign rsc_dec_extr_ram__iraddr0 = '0 ;
  assign rsc_dec_extr_ram__iraddr1 = '0 ;



*/

//
// Project       : rsc
// Author        : Shekhalev Denis (des00)
// Workfile      : rsc_dec_extr_ram.v
// Description   : extrinsic ram with two concurrent switched write and read ports
//

module rsc_dec_extr_ram
#(
  parameter int pDATA_W  = 32 ,
  parameter int pADDR_W  =  8
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  iwrite  ,
  iwaddr0 ,
  iwdata0 ,
  iwaddr1 ,
  iwdata1 ,
  //
  iread   ,
  iraddr0 ,
  ordata0 ,
  iraddr1 ,
  ordata1
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 iclk     ;
  input  logic                 ireset   ;
  input  logic                 iclkena  ;
  //
  input  logic                 iwrite   ;
  input  logic [pADDR_W-1 : 0] iwaddr0  ;
  input  logic [pDATA_W-1 : 0] iwdata0  ;
  input  logic [pADDR_W-1 : 0] iwaddr1  ;
  input  logic [pDATA_W-1 : 0] iwdata1  ;
  //
  input  logic                 iread    ;
  input  logic [pADDR_W-1 : 0] iraddr0  ;
  output logic [pDATA_W-1 : 0] ordata0  ;
  input  logic [pADDR_W-1 : 0] iraddr1  ;
  output logic [pDATA_W-1 : 0] ordata1  ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cADDR_W  = pADDR_W - 1;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [pDATA_W-1 : 0] ram0 [0 : 2**cADDR_W-1] /*synthesis syn_ramstyle = "no_rw_check"*/;
  logic [pDATA_W-1 : 0] ram1 [0 : 2**cADDR_W-1] /*synthesis syn_ramstyle = "no_rw_check"*/;

  logic [pDATA_W-1 : 0] wdata0;
  logic [pDATA_W-1 : 0] wdata1;

  logic [pDATA_W-1 : 0] rdata0;
  logic [pDATA_W-1 : 0] rdata1;

  logic [cADDR_W-1 : 0] waddr0;
  logic [cADDR_W-1 : 0] waddr1;

  logic [cADDR_W-1 : 0] raddr0;
  logic [cADDR_W-1 : 0] raddr1;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  wire wsel = iwaddr0[0];

  assign waddr0 = wsel ? iwaddr0[pADDR_W-1 : 1] : iwaddr1[pADDR_W-1 : 1];
  assign wdata0 = wsel ? iwdata0                : iwdata1;

  assign waddr1 = wsel ? iwaddr1[pADDR_W-1 : 1] : iwaddr0[pADDR_W-1 : 1];
  assign wdata1 = wsel ? iwdata1                : iwdata0;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (iwrite) begin
        ram0[waddr0] <= wdata0;
        ram1[waddr1] <= wdata1;
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  wire rsel = iraddr0[0];

  assign raddr0 = rsel ? iraddr0[pADDR_W-1 : 1] : iraddr1[pADDR_W-1 : 1];
  assign raddr1 = rsel ? iraddr1[pADDR_W-1 : 1] : iraddr0[pADDR_W-1 : 1];

  logic rsel_out;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      rsel_out  <= rsel;
      rdata0    <= ram0[raddr0];
      rdata1    <= ram1[raddr1];
    end
  end

  assign ordata0 = rsel_out ? rdata0 : rdata1;
  assign ordata1 = rsel_out ? rdata1 : rdata0;

endmodule

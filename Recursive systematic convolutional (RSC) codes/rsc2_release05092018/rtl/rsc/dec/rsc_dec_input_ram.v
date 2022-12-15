/*



  parameter int pDATA_W  = 32 ;
  parameter int pADDR_W  =  8 ;


  logic                 rsc_dec_input_ram__ireset   ;
  logic                 rsc_dec_input_ram__iwclk    ;
  logic                 rsc_dec_input_ram__iwclkena ;
  logic                 rsc_dec_input_ram__iwrite   ;
  logic [pADDR_W-1 : 0] rsc_dec_input_ram__iwaddr   ;
  logic [pDATA_W-1 : 0] rsc_dec_input_ram__iwdata   ;
  logic                 rsc_dec_input_ram__irclk    ;
  logic                 rsc_dec_input_ram__irclkena ;
  logic                 rsc_dec_input_ram__iread    ;
  logic [pADDR_W-1 : 0] rsc_dec_input_ram__iraddr0  ;
  logic [pDATA_W-1 : 0] rsc_dec_input_ram__ordata0  ;
  logic [pADDR_W-1 : 0] rsc_dec_input_ram__iraddr1  ;
  logic [pDATA_W-1 : 0] rsc_dec_input_ram__ordata1  ;


  rsc_dec_input_ram
  #(
    .pDATA_W ( pDATA_W ) ,
    .pADDR_W ( pADDR_W )
  )
  rsc_dec_input_ram
  (
    .ireset   ( rsc_dec_input_ram__ireset   ) ,
    .iwclk    ( rsc_dec_input_ram__iwclk    ) ,
    .iwclkena ( rsc_dec_input_ram__iwclkena ) ,
    .iwrite   ( rsc_dec_input_ram__iwrite   ) ,
    .iwaddr   ( rsc_dec_input_ram__iwaddr   ) ,
    .iwdata   ( rsc_dec_input_ram__iwdata   ) ,
    .irclk    ( rsc_dec_input_ram__irclk    ) ,
    .irclkena ( rsc_dec_input_ram__irclkena ) ,
    .iread    ( rsc_dec_input_ram__iread    ) ,
    .iraddr0  ( rsc_dec_input_ram__iraddr0  ) ,
    .ordata0  ( rsc_dec_input_ram__ordata0  ) ,
    .iraddr1  ( rsc_dec_input_ram__iraddr1  ) ,
    .ordata1  ( rsc_dec_input_ram__ordata1  )
  );


  assign rsc_dec_input_ram__ireset   = '0 ;
  assign rsc_dec_input_ram__iwclk    = '0 ;
  assign rsc_dec_input_ram__iwclkena = '0 ;
  assign rsc_dec_input_ram__iwrite   = '0 ;
  assign rsc_dec_input_ram__iwaddr   = '0 ;
  assign rsc_dec_input_ram__iwdata   = '0 ;
  assign rsc_dec_input_ram__irclk    = '0 ;
  assign rsc_dec_input_ram__irclkena = '0 ;
  assign rsc_dec_input_ram__iread    = '0 ;
  assign rsc_dec_input_ram__iraddr0  = '0 ;
  assign rsc_dec_input_ram__iraddr1  = '0 ;



*/

//
// Project       : rsc
// Author        : Shekhalev Denis (des00)
// Workfile      : rsc_dec_input_ram.v
// Description   : input ram with one write port and two concurrent switched read ports
//

module rsc_dec_input_ram
#(
  parameter int pDATA_W  = 32 ,
  parameter int pADDR_W  =  8
)
(
  ireset   ,
  //
  iwclk    ,
  iwclkena ,
  //
  iwrite   ,
  iwaddr   ,
  iwdata   ,
  //
  irclk    ,
  irclkena ,
  //
  iread    ,
  iraddr0  ,
  ordata0  ,
  iraddr1  ,
  ordata1
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 ireset   ;
  //
  input  logic                 iwclk    ;
  input  logic                 iwclkena ;
  //
  input  logic                 iwrite   ;
  input  logic [pADDR_W-1 : 0] iwaddr   ;
  input  logic [pDATA_W-1 : 0] iwdata   ;
  //
  input  logic                 irclk    ;
  input  logic                 irclkena ;
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

  logic [cADDR_W-1 : 0] waddr;

  logic [cADDR_W-1 : 0] raddr0;
  logic [cADDR_W-1 : 0] raddr1;

  logic [pDATA_W-1 : 0] rdata0;
  logic [pDATA_W-1 : 0] rdata1;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  wire wsel = iwaddr[0];

  wire write0 = iwrite &  wsel;
  wire write1 = iwrite & !wsel;

  assign waddr = iwaddr[pADDR_W-1 : 1];

  always_ff @(posedge iwclk) begin
    if (iwclkena) begin
      if (write0) begin
        ram0[waddr] <= iwdata;
      end
      if (write1) begin
        ram1[waddr] <= iwdata;
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

  always_ff @(posedge irclk) begin
    if (irclkena) begin
      rsel_out  <= rsel;
      rdata0    <= ram0[raddr0];
      rdata1    <= ram1[raddr1];
    end
  end

  assign ordata0 = rsel_out ? rdata0 : rdata1;
  assign ordata1 = rsel_out ? rdata1 : rdata0;

endmodule

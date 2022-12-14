/*



  parameter int pDATA_W  = 2 ;
  parameter int pRDATA_W = 2 ;
  parameter int pADDR_W  = 8 ;



  logic                 rsc_dec_output_ram__ireset   ;
  logic                 rsc_dec_output_ram__iwclk    ;
  logic                 rsc_dec_output_ram__iwclkena ;
  logic                 rsc_dec_output_ram__iwrite   ;
  logic [pADDR_W-1 : 0] rsc_dec_output_ram__iwaddr0  ;
  logic [pDATA_W-1 : 0] rsc_dec_output_ram__iwdata0  ;
  logic [pADDR_W-1 : 0] rsc_dec_output_ram__iwaddr1  ;
  logic [pDATA_W-1 : 0] rsc_dec_output_ram__iwdata1  ;
  logic                 rsc_dec_output_ram__irclk    ;
  logic                 rsc_dec_output_ram__irclkena ;
  logic                 rsc_dec_output_ram__iread    ;
  logic [pADDR_W-1 : 0] rsc_dec_output_ram__iraddr   ;
  logic [pDATA_W-1 : 0] rsc_dec_output_ram__ordata   ;



  rsc_dec_output_ram
  #(
    .pDATA_W  ( pDATA_W  ) ,
    .pRDATA_W ( pRDATA_W ) ,
    .pADDR_W  ( pADDR_W  )
  )
  rsc_dec_output_ram
  (
    .ireset   ( rsc_dec_output_ram__ireset   ) ,
    .iwclk    ( rsc_dec_output_ram__iwclk    ) ,
    .iwclkena ( rsc_dec_output_ram__iwclkena ) ,
    .iwrite   ( rsc_dec_output_ram__iwrite   ) ,
    .iwaddr0  ( rsc_dec_output_ram__iwaddr0  ) ,
    .iwdata0  ( rsc_dec_output_ram__iwdata0  ) ,
    .iwaddr1  ( rsc_dec_output_ram__iwaddr1  ) ,
    .iwdata1  ( rsc_dec_output_ram__iwdata1  ) ,
    .irclk    ( rsc_dec_output_ram__irclk    ) ,
    .irclkena ( rsc_dec_output_ram__irclkena ) ,
    .iread    ( rsc_dec_output_ram__iread    ) ,
    .iraddr   ( rsc_dec_output_ram__iraddr   ) ,
    .ordata   ( rsc_dec_output_ram__ordata   )
  );


  assign rsc_dec_output_ram__ireset   = '0 ;
  assign rsc_dec_output_ram__iwclk    = '0 ;
  assign rsc_dec_output_ram__iwclkena = '0 ;
  assign rsc_dec_output_ram__iwrite   = '0 ;
  assign rsc_dec_output_ram__iwaddr0  = '0 ;
  assign rsc_dec_output_ram__iwdata0  = '0 ;
  assign rsc_dec_output_ram__iwaddr1  = '0 ;
  assign rsc_dec_output_ram__iwdata1  = '0 ;
  assign rsc_dec_output_ram__irclk    = '0 ;
  assign rsc_dec_output_ram__irclkena = '0 ;
  assign rsc_dec_output_ram__iread    = '0 ;
  assign rsc_dec_output_ram__iraddr   = '0 ;



*/

//
// Project       : rsc
// Author        : Shekhalev Denis (des00)
// Workfile      : rsc_dec_output_ram.v
// Description   : output ram with two concurrent switched write ports and one read port
//

module rsc_dec_output_ram
#(
  parameter int pDATA_W  =  2 , // don't change
  parameter int pRDATA_W =  2 , // 2/4/8
  parameter int pADDR_W  =  8
)
(
  ireset   ,
  //
  iwclk    ,
  iwclkena ,
  //
  iwrite   ,
  iwaddr0  ,
  iwdata0  ,
  iwaddr1  ,
  iwdata1  ,
  //
  irclk    ,
  irclkena ,
  //
  iread    ,
  iraddr   ,
  ordata
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                  ireset   ;
  //
  input  logic                  iwclk    ;
  input  logic                  iwclkena ;
  //
  input  logic                  iwrite   ;
  input  logic  [pADDR_W-1 : 0] iwaddr0  ;
  input  logic  [pDATA_W-1 : 0] iwdata0  ;
  input  logic  [pADDR_W-1 : 0] iwaddr1  ;
  input  logic  [pDATA_W-1 : 0] iwdata1  ;
  //
  input  logic                  irclk    ;
  input  logic                  irclkena ;
  //
  input  logic                  iread    ;
  input  logic  [pADDR_W-1 : 0] iraddr   ;
  output logic [pRDATA_W-1 : 0] ordata   ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cADDR_W  = pADDR_W - 1;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [pDATA_W-1 : 0] wdata0;
  logic [pDATA_W-1 : 0] wdata1;

  logic [cADDR_W-1 : 0] waddr0;
  logic [cADDR_W-1 : 0] waddr1;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  wire wsel = iwaddr0[0];

  assign waddr0 = wsel ? iwaddr0[pADDR_W-1 : 1] : iwaddr1[pADDR_W-1 : 1];
  assign wdata0 = wsel ? iwdata0                : iwdata1;

  assign waddr1 = wsel ? iwaddr1[pADDR_W-1 : 1] : iwaddr0[pADDR_W-1 : 1];
  assign wdata1 = wsel ? iwdata1                : iwdata0;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  generate
    if (pRDATA_W/pDATA_W == 4) begin

      logic [pDATA_W-1 : 0] ram00 [0 : 2**(cADDR_W-1)-1]  /*synthesis syn_ramstyle = "no_rw_check"*/;
      logic [pDATA_W-1 : 0] ram01 [0 : 2**(cADDR_W-1)-1]  /*synthesis syn_ramstyle = "no_rw_check"*/;

      logic [pDATA_W-1 : 0] ram10 [0 : 2**(cADDR_W-1)-1]  /*synthesis syn_ramstyle = "no_rw_check"*/;
      logic [pDATA_W-1 : 0] ram11 [0 : 2**(cADDR_W-1)-1]  /*synthesis syn_ramstyle = "no_rw_check"*/;

      logic [pDATA_W-1 : 0] rdata00;
      logic [pDATA_W-1 : 0] rdata01;

      logic [pDATA_W-1 : 0] rdata10;
      logic [pDATA_W-1 : 0] rdata11;

      always_ff @(posedge iwclk) begin
        if (iwrite) begin
          if (waddr0[0])
            ram01[waddr0[cADDR_W-1 : 1]] <= wdata0;
          else
            ram00[waddr0[cADDR_W-1 : 1]] <= wdata0;
          //
          if (waddr1[0])
            ram11[waddr1[cADDR_W-1 : 1]] <= wdata1;
          else
            ram10[waddr1[cADDR_W-1 : 1]] <= wdata1;
        end
      end

      always_ff @(posedge irclk) begin
        if (irclkena) begin
          rdata00 <= ram00[iraddr[pADDR_W-3 : 0]];
          rdata01 <= ram01[iraddr[pADDR_W-3 : 0]];
          //
          rdata10 <= ram10[iraddr[pADDR_W-3 : 0]];
          rdata11 <= ram11[iraddr[pADDR_W-3 : 0]];
        end
      end

      assign ordata = {rdata01, rdata11,
                       rdata00, rdata10};

    end
    else if (pRDATA_W/pDATA_W == 2) begin

      logic [pDATA_W-1 : 0] ram0 [0 : 2**cADDR_W-1] /*synthesis syn_ramstyle = "no_rw_check"*/;
      logic [pDATA_W-1 : 0] ram1 [0 : 2**cADDR_W-1] /*synthesis syn_ramstyle = "no_rw_check"*/;

      logic [pDATA_W-1 : 0] rdata0;
      logic [pDATA_W-1 : 0] rdata1;

      //------------------------------------------------------------------------------------------------------
      //
      //------------------------------------------------------------------------------------------------------

      always_ff @(posedge iwclk) begin
        if (iwclkena) begin
          if (iwrite) begin
            ram0[waddr0] <= wdata0;
            ram1[waddr1] <= wdata1;
          end
        end
      end

      //------------------------------------------------------------------------------------------------------
      //
      //------------------------------------------------------------------------------------------------------

      always_ff @(posedge irclk) begin
        if (irclkena) begin
          rdata0 <= ram0[iraddr[pADDR_W-2 : 0]];
          rdata1 <= ram1[iraddr[pADDR_W-2 : 0]];
        end
      end

      assign ordata = {rdata0, rdata1};

    end
    else begin // pRDATA_W == pDATA_W

      logic [pDATA_W-1 : 0] ram0 [0 : 2**cADDR_W-1] /*synthesis syn_ramstyle = "no_rw_check"*/;
      logic [pDATA_W-1 : 0] ram1 [0 : 2**cADDR_W-1] /*synthesis syn_ramstyle = "no_rw_check"*/;

      logic [pDATA_W-1 : 0] rdata0;
      logic [pDATA_W-1 : 0] rdata1;
      logic                 rsel_out;

      //------------------------------------------------------------------------------------------------------
      //
      //------------------------------------------------------------------------------------------------------

      always_ff @(posedge iwclk) begin
        if (iwclkena) begin
          if (iwrite) begin
            ram0[waddr0] <= wdata0;
            ram1[waddr1] <= wdata1;
          end
        end
      end

      //------------------------------------------------------------------------------------------------------
      //
      //------------------------------------------------------------------------------------------------------

      always_ff @(posedge irclk) begin
        if (irclkena) begin
          rsel_out  <= iraddr[0];
          rdata0    <= ram0[iraddr[pADDR_W-1 : 1]];
          rdata1    <= ram1[iraddr[pADDR_W-1 : 1]];
        end
      end

      assign ordata = rsel_out ? rdata0 : rdata1;

    end
  endgenerate




endmodule

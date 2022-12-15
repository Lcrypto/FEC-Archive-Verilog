/*



  parameter int pBNUM_W  = 1 ;



  logic                 rsc_buffer_nD_slogic__iclk      ;
  logic                 rsc_buffer_nD_slogic__ireset    ;
  logic                 rsc_buffer_nD_slogic__iclkena   ;
  logic                 rsc_buffer_nD_slogic__iwfull    ;
  logic [pBNUM_W-1 : 0] rsc_buffer_nD_slogic__ob_wused  ;
  logic                 rsc_buffer_nD_slogic__irempty   ;
  logic [pBNUM_W-1 : 0] rsc_buffer_nD_slogic__ob_rused  ;
  logic                 rsc_buffer_nD_slogic__oempty    ;
  logic                 rsc_buffer_nD_slogic__oemptya   ;
  logic                 rsc_buffer_nD_slogic__ofull     ;
  logic                 rsc_buffer_nD_slogic__ofulla    ;



  rsc_buffer_nD_slogic
  #(
    .pBNUM_W ( pBNUM_W )
  )
  rsc_buffer_nD_slogic
  (
    .iclk     ( rsc_buffer_nD_slogic__iclk     ) ,
    .ireset   ( rsc_buffer_nD_slogic__ireset   ) ,
    .iclkena  ( rsc_buffer_nD_slogic__iclkena  ) ,
    .iwfull   ( rsc_buffer_nD_slogic__iwfull   ) ,
    .ob_wused ( rsc_buffer_nD_slogic__ob_wused ) ,
    .irempty  ( rsc_buffer_nD_slogic__irempty  ) ,
    .ob_rused ( rsc_buffer_nD_slogic__ob_rused ) ,
    .oempty   ( rsc_buffer_nD_slogic__oempty   ) ,
    .oemptya  ( rsc_buffer_nD_slogic__oemptya  ) ,
    .ofull    ( rsc_buffer_nD_slogic__ofull    ) ,
    .ofulla   ( rsc_buffer_nD_slogic__ofulla   )
  );


  assign rsc_buffer_nD_slogic__iclk    = '0 ;
  assign rsc_buffer_nD_slogic__ireset  = '0 ;
  assign rsc_buffer_nD_slogic__iclkena = '0 ;
  assign rsc_buffer_nD_slogic__iwfull  = '0 ;
  assign rsc_buffer_nD_slogic__irempty = '0 ;



*/

//
// Project       : rsc
// Author        : Shekhalev Denis (des00)
// Workfile      : rsc_buffer_nD_slogic.v
// Description   : Single clock multi buffering logic for RAM address pointers
//


module rsc_buffer_nD_slogic
#(
  parameter int pBNUM_W  = 1
)
(
  iclk     ,
  ireset   ,
  iclkena  ,
  //
  iwfull   ,
  ob_wused ,
  //
  irempty  ,
  ob_rused ,
  //
  oempty   ,
  oemptya  ,
  ofull    ,
  ofulla
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 iclk      ;
  input  logic                 ireset    ;
  input  logic                 iclkena   ;
  //
  input  logic                 iwfull    ;
  output logic [pBNUM_W-1 : 0] ob_wused  ;  // bank used for write
  //
  input  logic                 irempty   ;
  output logic [pBNUM_W-1 : 0] ob_rused  ;  // bank used for read read
  //
  output logic                 oempty    ;  // any bank is empty
  output logic                 oemptya   ;  // all banks is empty
  output logic                 ofull     ;  // any bank is full
  output logic                 ofulla    ;  // all banks is full

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cBNUM = 2**pBNUM_W;

  logic   [cBNUM-1 : 0] b_is_busy ; // bank busy
  logic [pBNUM_W-1 : 0] b_wused   ; // bank write used
  logic [pBNUM_W-1 : 0] b_rused   ; // bank read used

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  initial begin : ini
    b_is_busy = '0;
    b_wused   = '0;
    b_rused   = '0;
  end
  // synthesis translate_on
  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin : flip_flop_logic
    if (ireset) begin
      b_is_busy <= '0;
      b_wused   <= '0;
      b_rused   <= '0;
    end
    else if (iclkena) begin
      for (int i = 0; i < cBNUM; i++) begin
        if (iwfull & (b_wused == i))
          b_is_busy[i] <= 1'b1;
        else if (irempty & (b_rused == i))
          b_is_busy[i] <= 1'b0;
      end
      // switch only if there is next empty bank or full bank is ready to empty
      if ((iwfull & irempty) | (iwfull & ~b_is_busy[b_wused + 1'b1]) | (irempty & b_is_busy[b_wused])) begin
        b_wused <= b_wused + 1'b1;
      end
      // switch only if there is next full bank
      if ((iwfull & irempty) | (irempty & b_is_busy[b_rused])) begin
        b_rused <= b_rused + 1'b1;
      end
    end
  end

  assign ob_wused = b_wused;
  assign ob_rused = b_rused;

  assign oempty   = |(~b_is_busy);
  assign oemptya  = &(~b_is_busy);

  assign ofull    = |b_is_busy;
  assign ofulla   = &b_is_busy;

endmodule


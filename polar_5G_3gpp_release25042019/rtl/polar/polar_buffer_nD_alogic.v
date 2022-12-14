/*



  parameter int pBNUM_W  = 1 ;



  logic                 polar_buffer_nD_alogic__iwclk      ;
  logic                 polar_buffer_nD_alogic__iwreset    ;
  logic                 polar_buffer_nD_alogic__iwfull     ;
  logic [pBNUM_W-1 : 0] polar_buffer_nD_alogic__ob_wused   ;
  logic                 polar_buffer_nD_alogic__ob_wempty  ;
  logic                 polar_buffer_nD_alogic__ob_wemptya ;
  logic                 polar_buffer_nD_alogic__ob_wfull   ;
  logic                 polar_buffer_nD_alogic__ob_wfulla  ;
  logic                 polar_buffer_nD_alogic__irclk      ;
  logic                 polar_buffer_nD_alogic__irreset    ;
  logic                 polar_buffer_nD_alogic__irempty    ;
  logic [pBNUM_W-1 : 0] polar_buffer_nD_alogic__ob_rused   ;
  logic                 polar_buffer_nD_alogic__ob_rempty  ;
  logic                 polar_buffer_nD_alogic__ob_remptya ;
  logic                 polar_buffer_nD_alogic__ob_rfull   ;
  logic                 polar_buffer_nD_alogic__ob_rfulla  ;



  polar_buffer_nD_alogic
  #(
    .pBNUM_W ( pBNUM_W )
  )
  polar_buffer_nD_alogic
  (
    .iwclk      ( polar_buffer_nD_alogic__iwclk      ) ,
    .iwreset    ( polar_buffer_nD_alogic__iwreset    ) ,
    .iwfull     ( polar_buffer_nD_alogic__iwfull     ) ,
    .ob_wused   ( polar_buffer_nD_alogic__ob_wused   ) ,
    .ob_wempty  ( polar_buffer_nD_alogic__ob_wempty  ) ,
    .ob_wemptya ( polar_buffer_nD_alogic__ob_wemptya ) ,
    .ob_wfull   ( polar_buffer_nD_alogic__ob_wfull   ) ,
    .ob_wfulla  ( polar_buffer_nD_alogic__ob_wfulla  ) ,
    .irclk      ( polar_buffer_nD_alogic__irclk      ) ,
    .irreset    ( polar_buffer_nD_alogic__irreset    ) ,
    .irempty    ( polar_buffer_nD_alogic__irempty    ) ,
    .ob_rused   ( polar_buffer_nD_alogic__ob_rused   ) ,
    .ob_rempty  ( polar_buffer_nD_alogic__ob_rempty  ) ,
    .ob_remptya ( polar_buffer_nD_alogic__ob_remptya ) ,
    .ob_rfull   ( polar_buffer_nD_alogic__ob_rfull   ) ,
    .ob_rfulla  ( polar_buffer_nD_alogic__ob_rfulla  )
  );


  assign polar_buffer_nD_alogic__iwclk   = '0 ;
  assign polar_buffer_nD_alogic__iwreset = '0 ;
  assign polar_buffer_nD_alogic__iwfull  = '0 ;
  assign polar_buffer_nD_alogic__irclk   = '0 ;
  assign polar_buffer_nD_alogic__irreset = '0 ;
  assign polar_buffer_nD_alogic__irempty = '0 ;



*/

//
// Project       : polar code
// Author        : Shekhalev Denis (des00)
// Workfile      : polar_buffer_nD_alogic.v
// Description   : Dual clock multi buffering logic for RAM address pointers
//

module polar_buffer_nD_alogic
#(
  parameter int pBNUM_W  = 1
)
(
  iwclk      ,
  iwreset    ,
  iwfull     ,
  ob_wused   ,
  ob_wempty  ,
  ob_wemptya ,
  ob_wfull   ,
  ob_wfulla  ,
  //
  irclk      ,
  irreset    ,
  irempty    ,
  ob_rused   ,
  ob_rempty  ,
  ob_remptya ,
  ob_rfull   ,
  ob_rfulla
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 iwclk      ;
  input  logic                 iwreset    ;
  input  logic                 iwfull     ;
  output logic [pBNUM_W-1 : 0] ob_wused   ;  // bank used for write
  output logic                 ob_wempty  ;  // any write buffer is empty
  output logic                 ob_wemptya ;  // all write buffers is empty
  output logic                 ob_wfull   ;  // any write buffer is full
  output logic                 ob_wfulla  ;  // all write buffers is full
  //
  input  logic                 irclk      ;
  input  logic                 irreset    ;
  input  logic                 irempty    ;
  output logic [pBNUM_W-1 : 0] ob_rused   ;  // bank used for read
  output logic                 ob_rempty  ;  // any read bank is empty
  output logic                 ob_remptya ;  // all read banks is empty
  output logic                 ob_rfull   ;  // any read bank is full
  output logic                 ob_rfulla  ;  // all read banks is full

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cBNUM = 2**pBNUM_W;

  logic   [cBNUM-1 : 0] b_w_is_busy   ; // bank busy at write side
  logic [pBNUM_W-1 : 0] b_wused       ; // bank used for write
  logic   [cBNUM-1 : 0] rempty_at_wclk;

  logic   [cBNUM-1 : 0] b_r_is_busy   ; // bank busy at read side
  logic [pBNUM_W-1 : 0] b_rused       ; // bank used for read
  logic   [cBNUM-1 : 0] wfull_at_rclk ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  initial begin : ini
    b_w_is_busy = '0;
    b_wused     = '0;
    //
    b_r_is_busy = '0;
    b_rused     = '0;
  end
  // synthesis translate_on
  //------------------------------------------------------------------------------------------------------
  // write side
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iwclk or posedge iwreset) begin : write_ff_logic
    if (iwreset) begin
      b_w_is_busy  <= '0;
      b_wused      <= '0;
    end
    else begin
      for (int i = 0; i < cBNUM; i++) begin
        if (iwfull & (b_wused == i))
          b_w_is_busy[i] <= 1'b1;
        else if (rempty_at_wclk[i])
          b_w_is_busy[i] <= 1'b0;
      end
      // switch only if there is next empty bank or full bank is ready to empty
      if ((iwfull & (rempty_at_wclk != 0)) | (iwfull & ~b_w_is_busy[b_wused + 1'b1]) | ((rempty_at_wclk != 0) & b_w_is_busy[b_wused])) begin
        b_wused <= b_wused + 1'b1;
      end
    end
  end

  assign ob_wused  = b_wused;

  assign ob_wempty  = |(~b_w_is_busy);
  assign ob_wemptya = &(~b_w_is_busy);

  assign ob_wfull   = |b_w_is_busy;
  assign ob_wfulla  = &b_w_is_busy;

  //------------------------------------------------------------------------------------------------------
  // read side
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge irclk or posedge irreset) begin : read_ff_logic
    if (irreset) begin
      b_r_is_busy <= '0;
      b_rused     <= '0;
    end
    else begin
      for (int i = 0; i < cBNUM; i++) begin
        if (wfull_at_rclk[i])
          b_r_is_busy[i] <= 1'b1;
        else if (irempty & (b_rused == i))
          b_r_is_busy[i] <= 1'b0;
      end
      // switch only if there is next full bank
      if (((wfull_at_rclk != 0) & irempty) | (irempty & b_r_is_busy[b_rused])) begin
        b_rused <= b_rused + 1'b1;
      end
    end
  end

  assign ob_rused   = b_rused;

  assign ob_rempty  = |(~b_r_is_busy);
  assign ob_remptya = &(~b_r_is_busy);

  assign ob_rfull   = |b_r_is_busy;
  assign ob_rfulla  = &b_r_is_busy;

  //------------------------------------------------------------------------------------------------------
  // synchronizers
  //------------------------------------------------------------------------------------------------------

  generate
    genvar g;
    for (g = 0; g < cBNUM; g++) begin : sync_inst_gen
      pulse_synchronizer
      #(
        .pLENGTH ( 3 )
      )
      wsync
      (
        .clkin  ( iwclk ) , .resetin  ( iwreset ) ,
        .clkout ( irclk ) , .resetout ( irreset ) ,
        //
        .sin    ( iwfull & (b_wused == g) ) ,
        .sout   ( wfull_at_rclk [g]       )
      );
      //
      pulse_synchronizer
      #(
        .pLENGTH ( 3 )
      )
      rsync
      (
        .clkin  ( irclk ) , .resetin  ( irreset ) ,
        .clkout ( iwclk ) , .resetout ( iwreset ) ,
        //
        .sin    ( irempty & (b_rused == g) ) ,
        .sout   ( rempty_at_wclk [g]       )
      );
    end
  endgenerate


endmodule

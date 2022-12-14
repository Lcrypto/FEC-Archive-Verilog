/*



  parameter int pDAT_W   = 18 ;
  parameter int pGAIN_W  =  8 ;



  logic                 gaus_mult__iclk     ;
  logic                 gaus_mult__ireset   ;
  logic                 gaus_mult__iclkena  ;
  logic        [17 : 0] gaus_mult__ilog     ;
  logic        [17 : 0] gaus_mult__icos     ;
  logic        [17 : 0] gaus_mult__isin     ;
  logic [pGAIN_W-1 : 0] gaus_mult__igain    ;
  logic                 gaus_mult__oval     ;
  logic  [pDAT_W-1 : 0] gaus_mult__odat_re  ;
  logic  [pDAT_W-1 : 0] gaus_mult__odat_im  ;



  gaus_mult
  #(
    .pDAT_W  ( pDAT_W  ) ,
    .pGAIN_W ( pGAIN_W )
  )
  gaus_mult
  (
    .iclk    ( gaus_mult__iclk    ) ,
    .ireset  ( gaus_mult__ireset  ) ,
    .iclkena ( gaus_mult__iclkena ) ,
    .ilog    ( gaus_mult__ilog    ) ,
    .icos    ( gaus_mult__icos    ) ,
    .isin    ( gaus_mult__isin    ) ,
    .igain   ( gaus_mult__igain   ) ,
    .oval    ( gaus_mult__oval    ) ,
    .odat_re ( gaus_mult__odat_re ) ,
    .odat_im ( gaus_mult__odat_im )
  );


  assign gaus_mult__iclk    = '0 ;
  assign gaus_mult__ireset  = '0 ;
  assign gaus_mult__iclkena = '0 ;
  assign gaus_mult__ilog    = '0 ;
  assign gaus_mult__icos    = '0 ;
  assign gaus_mult__isin    = '0 ;
  assign gaus_mult__igain   = '0 ;



*/

//
// Project       : gaus_mult
// Author        : Shekhalev Denis (des00)
// Revision      : $Revision$
// Date          : $Date$
// Workfile      : gaus_mult.v
// Description   : ampliture*cos/sim mult and amplifier for simple Box-Muller algorithm
//

module gaus_mult
#(
  parameter int pDAT_W   = 18 ,
  parameter int pGAIN_W  =  8   // <= 17 is optimal
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  ilog    ,
  icos    ,
  isin    ,
  igain   ,
  //
  oval    ,
  odat_re ,
  odat_im
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 iclk     ;
  input  logic                 ireset   ;
  input  logic                 iclkena  ;
  //
  input  logic        [17 : 0] ilog     ;
  input  logic        [17 : 0] icos     ;
  input  logic        [17 : 0] isin     ;
  input  logic [pGAIN_W-1 : 0] igain    ;
  //
  output logic                 oval     ;
  output logic  [pDAT_W-1 : 0] odat_re  ;
  output logic  [pDAT_W-1 : 0] odat_im  ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cMULT_W = 18 + pGAIN_W;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic signed        [17 : 0] log2mult_re;
  logic signed        [17 : 0] log2mult_im;

  logic signed        [17 : 0] cos2mult;
  logic signed        [17 : 0] sin2mult;

  logic signed        [35 : 0] mult_re;
  logic signed        [35 : 0] mult_im;

  logic signed [pGAIN_W   : 0] gain_re;
  logic signed [pGAIN_W   : 0] gain_im;

  logic signed        [17 : 0] mult_re_scaled;
  logic signed        [17 : 0] mult_im_scaled;

  logic signed [cMULT_W-1 : 0] mult_gain_re;
  logic signed [cMULT_W-1 : 0] mult_gain_im;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      log2mult_re <= ilog;
      log2mult_im <= ilog;
      cos2mult    <= icos;
      sin2mult    <= isin;
      //
      mult_re     <= log2mult_re * cos2mult;
      mult_im     <= log2mult_im * sin2mult;
      //
      gain_re         <= {1'b0, igain};
      gain_im         <= {1'b0, igain};
      mult_re_scaled  <= mult_re[34 -: 18];
      mult_im_scaled  <= mult_im[34 -: 18];

      mult_gain_re    <= gain_re * mult_re_scaled;
      mult_gain_im    <= gain_im * mult_im_scaled;
    end
  end

  assign oval    = 1'b1;
  assign odat_re = mult_gain_re[cMULT_W-1 -: pDAT_W];
  assign odat_im = mult_gain_im[cMULT_W-1 -: pDAT_W];

endmodule

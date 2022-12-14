/*



  parameter int pSEED0   =  0 ;
  parameter int pSEED1   =  0 ;
  parameter int pSEED2   =  0 ;
  parameter int pDAT_W   = 18 ;
  parameter int pGAIN_W  =  8 ;



  logic                 gaus_rng__iclk     ;
  logic                 gaus_rng__ireset   ;
  logic                 gaus_rng__iclkena  ;
  logic                 gaus_rng__ienable  ;
  logic [pGAIN_W-1 : 0] gaus_rng__igain    ;
  logic                 gaus_rng__oval     ;
  logic  [pDAT_W-1 : 0] gaus_rng__odat_re  ;
  logic  [pDAT_W-1 : 0] gaus_rng__odat_im  ;



  gaus_rng
  #(
    .pSEED0  ( pSEED0  ) ,
    .pSEED1  ( pSEED1  ) ,
    .pSEED2  ( pSEED2  ) ,
    .pDAT_W  ( pDAT_W  ) ,
    .pGAIN_W ( pGAIN_W )
  )
  gaus_rng
  (
    .iclk    ( gaus_rng__iclk    ) ,
    .ireset  ( gaus_rng__ireset  ) ,
    .iclkena ( gaus_rng__iclkena ) ,
    .ienable ( gaus_rng__ienable ) ,
    .igain   ( gaus_rng__igain   ) ,
    .oval    ( gaus_rng__oval    ) ,
    .odat_re ( gaus_rng__odat_re ) ,
    .odat_im ( gaus_rng__odat_im )
  );


  assign gaus_rng__iclk    = '0 ;
  assign gaus_rng__ireset  = '0 ;
  assign gaus_rng__iclkena = '0 ;
  assign gaus_rng__ienable = '0 ;
  assign gaus_rng__igain   = '0 ;



*/

//
// Project       : gaus_rng
// Author        : Shekhalev Denis (des00)
// Revision      : $Revision$
// Date          : $Date$
// Workfile      : gaus_rng.v
// Description   : gaus noise generator based upon simple Box-Muller algorithm top level
//

module gaus_rng
#(
  parameter int pSEED0   =  0 ,
  parameter int pSEED1   =  0 ,
  parameter int pSEED2   =  0 ,
  parameter int pDAT_W   = 18 ,
  parameter int pGAIN_W  =  8    // <= 17 is optimal
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  ienable ,
  igain   ,
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
  input  logic                 ienable  ;
  input  logic [pGAIN_W-1 : 0] igain    ;
  //
  output logic                 oval     ;
  output logic  [pDAT_W-1 : 0] odat_re  ;
  output logic  [pDAT_W-1 : 0] odat_im  ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cPH_W = 11;
  localparam bit [cPH_W-2 : 0] cROM_ADDR_MAX = {1'b1, {(cPH_W-2){1'b0}}};

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [31 : 0] urng_x__odat   ;
  logic [31 : 0] urng_y__odat   ;

  logic  [8 : 0] log__iaddr0    ;
  logic  [8 : 0] log__iaddr1    ;
  logic [17 : 0] log__odat0     ;
  logic [17 : 0] log__odat1     ;

  logic [10 : 0] cordic__iphase ;
  logic [17 : 0] cordic__ocos   ;
  logic [17 : 0] cordic__osin   ;

  //------------------------------------------------------------------------------------------------------
  // URNG generator
  //------------------------------------------------------------------------------------------------------

  tausworthe_urng
  #(
    .pSEED0 ( pSEED0 ) ,
    .pSEED1 ( pSEED1 ) ,
    .pSEED2 ( pSEED2 )
  )
  urng_x
  (
    .iclk    ( iclk         ) ,
    .ireset  ( ireset       ) ,
    .iclkena ( iclkena      ) ,
    .ienable ( ienable      ) ,
    //
    .odat    ( urng_x__odat )
  );

  tausworthe_urng
  #(
    .pSEED0 ( ~pSEED0 ) ,
    .pSEED1 ( ~pSEED1 ) ,
    .pSEED2 ( ~pSEED2 )
  )
  urng_y
  (
    .iclk    ( iclk         ) ,
    .ireset  ( ireset       ) ,
    .iclkena ( iclkena      ) ,
    .ienable ( ienable      ) ,
    //
    .odat    ( urng_y__odat )
  );

  //------------------------------------------------------------------------------------------------------
  // box-muller converter : log
  //------------------------------------------------------------------------------------------------------

  gaus_log_tab
  log
  (
    .iclk    ( iclk        ) ,
    .ireset  ( ireset      ) ,
    .iclkena ( iclkena     ) ,
    //
    .iaddr0  ( log__iaddr0 ) ,
    .iaddr1  ( log__iaddr1 ) ,
    .odat0   ( log__odat0  ) ,
    .odat1   ( log__odat1  )
  );

  assign log__iaddr0 = urng_x__odat[31 : 23];
  assign log__iaddr1 = urng_x__odat[31 : 23];

  //------------------------------------------------------------------------------------------------------
  // box-muller converter : cos
  //------------------------------------------------------------------------------------------------------

  gaus_cordic
  cordic
  (
    .iclk      ( iclk           ) ,
    .ireset    ( ireset         ) ,
    .iclkena   ( iclkena        ) ,
    //
    .iphase    ( cordic__iphase )  ,
    //
    .ocos      ( cordic__ocos   ) ,
    .osin      ( cordic__osin   )
  );

  assign cordic__iphase = urng_y__odat[31 : 21];

  //------------------------------------------------------------------------------------------------------
  // output results
  //------------------------------------------------------------------------------------------------------

  gaus_mult
  #(
    .pDAT_W  ( pDAT_W  ) ,
    .pGAIN_W ( pGAIN_W )
  )
  mult
  (
    .iclk    ( iclk         ) ,
    .ireset  ( ireset       ) ,
    .iclkena ( iclkena      ) ,
    //
    .ilog    ( log__odat0   ) ,
    .icos    ( cordic__ocos ) ,
    .isin    ( cordic__osin ) ,
    .igain   ( igain        ) ,
    //
    .oval    ( oval         ) ,
    .odat_re ( odat_re      ) ,
    .odat_im ( odat_im      )
  );

endmodule

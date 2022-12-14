/*






  logic          gaus_cordic__iclk    ;
  logic          gaus_cordic__ireset  ;
  logic          gaus_cordic__iclkena ;
  logic [10 : 0] gaus_cordic__iphase  ;
  logic [17 : 0] gaus_cordic__ocos    ;
  logic [17 : 0] gaus_cordic__osin    ;



  gaus_cordic
  gaus_cordic
  (
    .iclk    ( gaus_cordic__iclk    ) ,
    .ireset  ( gaus_cordic__ireset  ) ,
    .iclkena ( gaus_cordic__iclkena ) ,
    .iphase  ( gaus_cordic__iphase  ) ,
    .ocos    ( gaus_cordic__ocos    ) ,
    .osin    ( gaus_cordic__osin    )
  );


  assign gaus_cordic__iclk      = '0 ;
  assign gaus_cordic__ireset    = '0 ;
  assign gaus_cordic__iclkena   = '0 ;
  assign gaus_cordic__icos_addr = '0 ;
  assign gaus_cordic__isin_addr = '0 ;



*/

//
// Project       : gaus_rng
// Author        : Shekhalev Denis (des00)
// Revision      : $Revision$
// Date          : $Date$
// Workfile      : gaus_cordic.v
// Description   : ROM based "cordic" for simple Box-Muller algorithm
//

module gaus_cordic
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  iphase  ,
  //
  ocos    ,
  osin
);

  localparam int cPH_W = 11;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic               iclk    ;
  input  logic               ireset  ;
  input  logic               iclkena ;
  //
  input  logic [cPH_W-1 : 0] iphase  ;
  //
  output logic      [17 : 0] ocos    ;
  output logic      [17 : 0] osin    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam bit [cPH_W-2 : 0] cROM_ADDR_MAX = {1'b1, {(cPH_W-2){1'b0}}};

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic       [3 : 0] sin_sign /* synthesis keep */;
  logic       [3 : 0] cos_sign /* synthesis keep */;

  logic [cPH_W-2 : 0] cos_addr2sat = '0;
  logic [cPH_W-2 : 0] sin_addr2sat = '0;

  logic [cPH_W-3 : 0] cos_addr = '0;
  logic [cPH_W-3 : 0] sin_addr = '0;

  logic      [17 : 0] cordic__ocos ;
  logic      [17 : 0] cordic__osin ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      //
      case (iphase[cPH_W-1 : cPH_W-2])
        2'b00   : begin sin_sign[0] <= 1'b0; sin_addr2sat <=                  iphase[cPH_W-3 : 0]; end
        2'b01   : begin sin_sign[0] <= 1'b0; sin_addr2sat <= cROM_ADDR_MAX -  iphase[cPH_W-3 : 0]; end
        2'b10   : begin sin_sign[0] <= 1'b1; sin_addr2sat <=                  iphase[cPH_W-3 : 0]; end
        2'b11   : begin sin_sign[0] <= 1'b1; sin_addr2sat <= cROM_ADDR_MAX -  iphase[cPH_W-3 : 0]; end
        default : begin end
      endcase
      //
      case (iphase[cPH_W-1 : cPH_W-2])
        2'b00   : begin cos_sign[0] <= 1'b0; cos_addr2sat <= cROM_ADDR_MAX -  iphase[cPH_W-3 : 0]; end
        2'b01   : begin cos_sign[0] <= 1'b1; cos_addr2sat <=                  iphase[cPH_W-3 : 0]; end
        2'b10   : begin cos_sign[0] <= 1'b1; cos_addr2sat <= cROM_ADDR_MAX -  iphase[cPH_W-3 : 0]; end
        2'b11   : begin cos_sign[0] <= 1'b0; cos_addr2sat <=                  iphase[cPH_W-3 : 0]; end
        default : begin end
      endcase
      //
      sin_addr    <= sin_addr2sat[cPH_W-2] ? '1 : sin_addr2sat[cPH_W-3 : 0];
      sin_sign[1] <= sin_sign[0];

      cos_addr    <= cos_addr2sat[cPH_W-2] ? '1 : cos_addr2sat[cPH_W-3 : 0];
      cos_sign[1] <= cos_sign[0];
    end
  end

  gaus_cordic_tab
  cordic
  (
    .iclk      ( iclk         ) ,
    .ireset    ( ireset       ) ,
    .iclkena   ( iclkena      ) ,
    //
    .icos_addr ( cos_addr     ) ,
    .isin_addr ( sin_addr     ) ,
    //
    .ocos      ( cordic__ocos ) ,
    .osin      ( cordic__osin )
  );

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      sin_sign[3 : 2] <= sin_sign[2 : 1];
      cos_sign[3 : 2] <= cos_sign[2 : 1];
      //
      osin <= (cordic__osin ^ {18{sin_sign[3]}}) + sin_sign[3];
      ocos <= (cordic__ocos ^ {18{cos_sign[3]}}) + cos_sign[3];
    end
  end

endmodule

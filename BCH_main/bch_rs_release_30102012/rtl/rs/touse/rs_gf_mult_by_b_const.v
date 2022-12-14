/*



  parameter int m       =   8 ;
  parameter int irrpol  = 285 ;



  logic [m-1 : 0] rs_gf_mult_by_b__idat_a  ;
  logic [m-1 : 0] rs_gf_mult_by_b__idat_b  ;
  logic [m-1 : 0] rs_gf_mult_by_b__odat    ;



  rs_gf_mult_by_b_const
  #(
    .m      ( m      ) ,
    .irrpol ( irrpol )
  )
  rs_gf_mult_by_b
  (
    .idat_a ( rs_gf_mult_by_b__idat_a ) ,
    .idat_b ( rs_gf_mult_by_b__idat_b ) ,
    .odat   ( rs_gf_mult_by_b__odat   )
  );


  assign rs_gf_mult_by_b__idat_a = '0 ;



*/



module rs_gf_mult_by_b_const
(
  idat_a ,
  idat_b ,
  odat
);

  `include "rs_parameters.vh"
  `include "rs_functions.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic [m-1 : 0] idat_a  ;
  input  logic [m-1 : 0] idat_b  ;  // must be constant
  output logic [m-1 : 0] odat    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  assign odat = gf_mult_a_by_b_const(idat_a, idat_b);

endmodule

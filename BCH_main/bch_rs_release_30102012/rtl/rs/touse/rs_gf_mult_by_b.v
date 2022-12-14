/*



  parameter int m       =   8 ;
  parameter int irrpol  = 285 ;
  parameter int dat_b   =   1 ;



  logic [m-1 : 0] rs_gf_mult_by_b__idat_a  ;
  logic [m-1 : 0] rs_gf_mult_by_b__odat    ;



  rs_gf_mult_by_b
  #(
    .m      ( m      ) ,
    .irrpol ( irrpol ) ,
    .dat_b  ( dat_b  )
  )
  rs_gf_mult_by_b
  (
    .idat_a ( rs_gf_mult_by_b__idat_a ) ,
    .odat   ( rs_gf_mult_by_b__odat   )
  );


  assign rs_gf_mult_by_b__idat_a = '0 ;



*/



module rs_gf_mult_by_b
(
  idat_a ,
  odat
);

  parameter int dat_b   = 3;

  `include "rs_parameters.vh"
  `include "rs_functions.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic [m-1 : 0] idat_a  ;
  output logic [m-1 : 0] odat    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  assign odat = gf_mult_a_by_b_const(idat_a, dat_b);

endmodule

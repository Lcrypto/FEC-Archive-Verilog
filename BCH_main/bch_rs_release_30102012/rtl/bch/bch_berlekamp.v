/*



  parameter int m         =   4 ;
  parameter int k_max     =   5 ;
  parameter int d         =   7 ;
  parameter int n         =  15 ;
  parameter int irrpol    = 285 ;
  parameter     pTYPE     = "ibm_2t";



  logic   bch_berlekamp__iclk                     ;
  logic   bch_berlekamp__iclkena                  ;
  logic   bch_berlekamp__ireset                   ;
  logic   bch_berlekamp__isyndrome_val            ;
  ptr_t   bch_berlekamp__isyndrome_ptr            ;
  data_t  bch_berlekamp__isyndrome       [1 : t2] ;
  logic   bch_berlekamp__oloc_poly_val            ;
  data_t  bch_berlekamp__oloc_poly       [0 : t]  ;
  data_t  bch_berlekamp__oloc_poly_deg            ;
  ptr_t   bch_berlekamp__oloc_poly_ptr            ;
  logic   bch_berlekamp__oloc_decfail             ;



  bch_berlekamp
  #(
    .m        ( m        ) ,
    .k_max    ( k_max    ) ,
    .d        ( d        ) ,
    .n        ( n        ) ,
    .irrpol   ( irrpol   ) ,
    .pTYPE    ( pTYPE    )
  )
  bch_berlekamp
  (
    .iclk          ( bch_berlekamp__iclk          ) ,
    .iclkena       ( bch_berlekamp__iclkena       ) ,
    .ireset        ( bch_berlekamp__ireset        ) ,
    .isyndrome_val ( bch_berlekamp__isyndrome_val ) ,
    .isyndrome_ptr ( bch_berlekamp__isyndrome_ptr ) ,
    .isyndrome     ( bch_berlekamp__isyndrome     ) ,
    .oloc_poly_val ( bch_berlekamp__oloc_poly_val ) ,
    .oloc_poly     ( bch_berlekamp__oloc_poly     ) ,
    .oloc_poly_deg ( bch_berlekamp__oloc_poly_deg ) ,
    .oloc_poly_ptr ( bch_berlekamp__oloc_poly_ptr ) ,
    .oloc_decfail  ( bch_berlekamp__oloc_decfail  )
  );


  assign bch_berlekamp__iclk          = '0 ;
  assign bch_berlekamp__iclkena       = '0 ;
  assign bch_berlekamp__ireset        = '0 ;
  assign bch_berlekamp__isyndrome_val = '0 ;
  assign bch_berlekamp__isyndrome_ptr = '0 ;
  assign bch_berlekamp__isyndrome     = '0 ;



*/

//
// Project       : bch
// Author        : Shekhalev Denis (des00)
// Revision      : $Revision: 10758 $
// Date          : $Date$
// Workfile      : bch_berlekamp.v
// Description   : file with configuration of berlekamp modules
//



module bch_berlekamp
(
  iclk          ,
  iclkena       ,
  ireset        ,
  isyndrome_val ,
  isyndrome_ptr ,
  isyndrome     ,
  oloc_poly_val ,
  oloc_poly     ,
  oloc_poly_deg ,
  oloc_poly_ptr ,
  oloc_decfail
);

  `include "bch_parameters.vh"

  parameter pTYPE = "ibm_2t";

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic   iclk                   ;
  input  logic   iclkena                ;
  input  logic   ireset                 ;
  //
  input  logic   isyndrome_val          ;
  input  ptr_t   isyndrome_ptr          ;
  input  data_t  isyndrome     [1 : t2] ;
  //
  output logic   oloc_poly_val          ;
  output data_t  oloc_poly     [0 : t]  ;
  output data_t  oloc_poly_deg          ;
  output ptr_t   oloc_poly_ptr          ;
  output logic   oloc_decfail           ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  assign oloc_poly_deg = '0;  // count this logis is move to cheiny module

  generate
    if (pTYPE == "ibm_2t") begin
      bch_berlekamp_ibm_2t
      #(
        .m        ( m        ) ,
        .k_max    ( k_max    ) ,
        .d        ( d        ) ,
        .n        ( n        ) ,
        .irrpol   ( irrpol   )
      )
      bch_berlekamp
      (
        .iclk          ( iclk          ) ,
        .iclkena       ( iclkena       ) ,
        .ireset        ( ireset        ) ,
        .isyndrome_val ( isyndrome_val ) ,
        .isyndrome_ptr ( isyndrome_ptr ) ,
        .isyndrome     ( isyndrome     ) ,
        .oloc_poly_val ( oloc_poly_val ) ,
        .oloc_poly     ( oloc_poly     ) ,
        .oloc_poly_ptr ( oloc_poly_ptr ) ,
        .oloc_decfail  ( oloc_decfail  )
      );
    end
    else if (pTYPE == "ibm_4t") begin
      bch_berlekamp_ibm_4t
      #(
        .m        ( m        ) ,
        .k_max    ( k_max    ) ,
        .d        ( d        ) ,
        .n        ( n        ) ,
        .irrpol   ( irrpol   )
      )
      bch_berlekamp
      (
        .iclk          ( iclk          ) ,
        .iclkena       ( iclkena       ) ,
        .ireset        ( ireset        ) ,
        .isyndrome_val ( isyndrome_val ) ,
        .isyndrome_ptr ( isyndrome_ptr ) ,
        .isyndrome     ( isyndrome     ) ,
        .oloc_poly_val ( oloc_poly_val ) ,
        .oloc_poly     ( oloc_poly     ) ,
        .oloc_poly_ptr ( oloc_poly_ptr ) ,
        .oloc_decfail  ( oloc_decfail  )
      );
    end
    else if (pTYPE == "ibm_2t_by_t") begin
      bch_berlekamp_ibm_2t_by_t
      #(
        .m        ( m        ) ,
        .k_max    ( k_max    ) ,
        .d        ( d        ) ,
        .n        ( n        ) ,
        .irrpol   ( irrpol   )
      )
      bch_berlekamp
      (
        .iclk          ( iclk          ) ,
        .iclkena       ( iclkena       ) ,
        .ireset        ( ireset        ) ,
        .isyndrome_val ( isyndrome_val ) ,
        .isyndrome_ptr ( isyndrome_ptr ) ,
        .isyndrome     ( isyndrome     ) ,
        .oloc_poly_val ( oloc_poly_val ) ,
        .oloc_poly     ( oloc_poly     ) ,
        .oloc_poly_ptr ( oloc_poly_ptr ) ,
        .oloc_decfail  ( oloc_decfail  )
      );
    end
    else if (pTYPE == "ribm_1t") begin
      bch_berlekamp_ribm_1t
      #(
        .m        ( m        ) ,
        .k_max    ( k_max    ) ,
        .d        ( d        ) ,
        .n        ( n        ) ,
        .irrpol   ( irrpol   )
      )
      bch_berlekamp
      (
        .iclk          ( iclk          ) ,
        .iclkena       ( iclkena       ) ,
        .ireset        ( ireset        ) ,
        .isyndrome_val ( isyndrome_val ) ,
        .isyndrome_ptr ( isyndrome_ptr ) ,
        .isyndrome     ( isyndrome     ) ,
        .oloc_poly_val ( oloc_poly_val ) ,
        .oloc_poly     ( oloc_poly     ) ,
        .oloc_poly_ptr ( oloc_poly_ptr ) ,
        .oloc_decfail  ( oloc_decfail  )
      );
    end
    else if (pTYPE == "ribm_2t") begin
      bch_berlekamp_ribm_2t
      #(
        .m        ( m        ) ,
        .k_max    ( k_max    ) ,
        .d        ( d        ) ,
        .n        ( n        ) ,
        .irrpol   ( irrpol   )
      )
      bch_berlekamp
      (
        .iclk          ( iclk          ) ,
        .iclkena       ( iclkena       ) ,
        .ireset        ( ireset        ) ,
        .isyndrome_val ( isyndrome_val ) ,
        .isyndrome_ptr ( isyndrome_ptr ) ,
        .isyndrome     ( isyndrome     ) ,
        .oloc_poly_val ( oloc_poly_val ) ,
        .oloc_poly     ( oloc_poly     ) ,
        .oloc_poly_ptr ( oloc_poly_ptr ) ,
        .oloc_decfail  ( oloc_decfail  )
      );
    end
    else if (pTYPE == "ribm_t_by_t") begin
      bch_berlekamp_ribm_t_by_t
      #(
        .m        ( m        ) ,
        .k_max    ( k_max    ) ,
        .d        ( d        ) ,
        .n        ( n        ) ,
        .irrpol   ( irrpol   )
      )
      bch_berlekamp
      (
        .iclk          ( iclk          ) ,
        .iclkena       ( iclkena       ) ,
        .ireset        ( ireset        ) ,
        .isyndrome_val ( isyndrome_val ) ,
        .isyndrome_ptr ( isyndrome_ptr ) ,
        .isyndrome     ( isyndrome     ) ,
        .oloc_poly_val ( oloc_poly_val ) ,
        .oloc_poly     ( oloc_poly     ) ,
        .oloc_poly_ptr ( oloc_poly_ptr ) ,
        .oloc_decfail  ( oloc_decfail  )
      );
    end
    else begin
      assign oloc_poly     [-1] = 1'bx; // use incorrect berlekamp messey module type (!!!)
    end
  endgenerate

endmodule

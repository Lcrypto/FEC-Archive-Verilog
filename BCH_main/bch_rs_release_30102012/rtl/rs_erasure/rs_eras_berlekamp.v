/*



  parameter int n         = 240 ;
  parameter int check     =  30 ;
  parameter int m         =   8 ;
  parameter int irrpol    = 285 ;
  parameter int genstart  =   0 ;
  parameter     pTYPE     = "ribm_6check";



  logic   rs_berlekamp__iclk                        ;
  logic   rs_berlekamp__iclkena                     ;
  logic   rs_berlekamp__ireset                      ;
  logic   rs_berlekamp__isyndrome_val               ;
  ptr_t   rs_berlekamp__isyndrome_ptr               ;
  data_t  rs_berlekamp__isyndrome       [1 : check] ;
  data_t  rs_berlekamp__ieras_root      [1 : check] ;
  data_t  rs_berlekamp__ieras_num                   ;
  logic   rs_berlekamp__oloc_poly_val               ;
  data_t  rs_berlekamp__oloc_poly       [0 : check] ;
  data_t  rs_berlekamp__oomega_poly     [1 : check] ;
  ptr_t   rs_berlekamp__oloc_poly_ptr               ;
  logic   rs_berlekamp__oloc_decfail                ;



  rs_eras_berlekamp
  #(
    .n        ( n        ) ,
    .check    ( check    ) ,
    .m        ( m        ) ,
    .irrpol   ( irrpol   ) ,
    .genstart ( genstart ) ,
    .pTYPE    ( pTYPE    )
  )
  rs_berlekamp
  (
    .iclk          ( rs_berlekamp__iclk          ) ,
    .iclkena       ( rs_berlekamp__iclkena       ) ,
    .ireset        ( rs_berlekamp__ireset        ) ,
    .isyndrome_val ( rs_berlekamp__isyndrome_val ) ,
    .isyndrome_ptr ( rs_berlekamp__isyndrome_ptr ) ,
    .isyndrome     ( rs_berlekamp__isyndrome     ) ,
    .ieras_root    ( rs_berlekamp__ieras_root    ) ,
    .ieras_num     ( rs_berlekamp__ieras_num     ) ,
    .oloc_poly_val ( rs_berlekamp__oloc_poly_val ) ,
    .oloc_poly     ( rs_berlekamp__oloc_poly     ) ,
    .oomega_poly   ( rs_berlekamp__oomega_poly   ) ,
    .oloc_poly_ptr ( rs_berlekamp__oloc_poly_ptr ) ,
    .oloc_decfail  ( rs_berlekamp__oloc_decfail  )
  );


  assign rs_berlekamp__iclk          = '0 ;
  assign rs_berlekamp__iclkena       = '0 ;
  assign rs_berlekamp__ireset        = '0 ;
  assign rs_berlekamp__isyndrome_val = '0 ;
  assign rs_berlekamp__isyndrome_ptr = '0 ;
  assign rs_berlekamp__isyndrome     = '0 ;
  assign rs_berlekamp__ieras_root    = '0 ;
  assign rs_berlekamp__ieras_num     = '0 ;


*/

//
// Project       : bch
// Author        : Shekhalev Denis (des00)
// Revision      : $Revision: 11036 $
// Date          : $Date$
// Workfile      : rs_berlekamp.v
// Description   : file with configuration of berlekamp modules
//



module rs_eras_berlekamp
(
  iclk          ,
  iclkena       ,
  ireset        ,
  isyndrome_val ,
  isyndrome_ptr ,
  isyndrome     ,
  ieras_root    ,
  ieras_num     ,
  oloc_poly_val ,
  oloc_poly     ,
  oloc_poly_deg ,
  oomega_poly   ,
  oloc_poly_ptr ,
  oloc_decfail
);

  `include "rs_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  parameter pTYPE = "ribm_2check";
//parameter pTYPE = "ribm_2check_by_check";

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic   iclk                      ;
  input  logic   iclkena                   ;
  input  logic   ireset                    ;
  //
  input  logic   isyndrome_val             ;
  input  ptr_t   isyndrome_ptr             ;
  input  data_t  isyndrome     [1 : check] ;
  input  data_t  ieras_root    [1 : check] ;
  input  data_t  ieras_num                 ;
  //
  output logic   oloc_poly_val             ;
  output data_t  oloc_poly     [0 : check] ;
  output data_t  oloc_poly_deg             ;
  output data_t  oomega_poly   [1 : check] ;
  output ptr_t   oloc_poly_ptr             ;
  output logic   oloc_decfail              ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  assign oloc_poly_deg = '0;  // count this logis is move to cheiny module

  generate
    if (pTYPE == "ribm_2check") begin
      rs_eras_berlekamp_ribm_2check
      #(
        .n        ( n        ) ,
        .check    ( check    ) ,
        .m        ( m        ) ,
        .irrpol   ( irrpol   ) ,
        .genstart ( genstart )
      )
      rs_berlekamp
      (
        .iclk          ( iclk          ) ,
        .iclkena       ( 1'b1          ) ,
        .ireset        ( ireset        ) ,
        //
        .isyndrome_val ( isyndrome_val ) ,
        .isyndrome_ptr ( isyndrome_ptr ) ,
        .isyndrome     ( isyndrome     ) ,
        .ieras_root    ( ieras_root    ) ,
        .ieras_num     ( ieras_num     ) ,
        //
        .oloc_poly_val ( oloc_poly_val ) ,
        .oloc_poly     ( oloc_poly     ) ,
        .oomega_poly   ( oomega_poly   ) ,
        .oloc_poly_ptr ( oloc_poly_ptr ) ,
        .oloc_decfail  ( oloc_decfail  )
      );
    end
    else if (pTYPE == "ribm_2check_by_check") begin
      rs_eras_berlekamp_ribm_2check_by_check
      #(
        .n        ( n        ) ,
        .check    ( check    ) ,
        .m        ( m        ) ,
        .irrpol   ( irrpol   ) ,
        .genstart ( genstart )
      )
      rs_berlekamp
      (
        .iclk          ( iclk          ) ,
        .iclkena       ( 1'b1          ) ,
        .ireset        ( ireset        ) ,
        //
        .isyndrome_val ( isyndrome_val ) ,
        .isyndrome_ptr ( isyndrome_ptr ) ,
        .isyndrome     ( isyndrome     ) ,
        .ieras_root    ( ieras_root    ) ,
        .ieras_num     ( ieras_num     ) ,
        //
        .oloc_poly_val ( oloc_poly_val ) ,
        .oloc_poly     ( oloc_poly     ) ,
        .oomega_poly   ( oomega_poly   ) ,
        .oloc_poly_ptr ( oloc_poly_ptr ) ,
        .oloc_decfail  ( oloc_decfail  )
      );
    end
    else begin
      assign oloc_poly     [-1] = 1'bx; // use incorrect berlekamp messey module type (!!!)
      assign oomega_poly   [-1] = 1'bx; // use incorrect berlekamp messey module type (!!!)
      // synthesis translate_off
      initial begin
        $display("use incorrect berlekamp messey module type %s", pTYPE);
        $stop;
      end
      // synthesis translate_on
    end
  endgenerate

endmodule

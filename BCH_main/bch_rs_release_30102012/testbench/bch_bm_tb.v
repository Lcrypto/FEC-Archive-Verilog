//
// Project       : bch
// Author        : Shekhalev Denis (des00)
// Revision      : $Revision: 10362 $
// Date          : $Date$
// Workfile      : bch_enc_tb.v
// Description   :
//


module tb ;

  `include "bch_parameters.vh"

  logic   iclk                   ;
  logic   ireset                 ;
  //
  //
  logic   isyndrome_val          ;
  data_t  isyndrome     [1 : t2] ;
  //
  logic   ibm__oloc_poly_val          ;
  data_t  ibm__oloc_poly      [0 : t] ;
  data_t  ibm__oloc_poly_deg          ;
  logic   ibm__oloc_decfail           ;
  //
  //
  logic   s_isyndrome_val          ;
  data_t  s_isyndrome     [1 : t2] ;
  //
  logic   sibm__oloc_poly_val          ;
  data_t  sibm__oloc_poly      [0 : t] ;
  data_t  sibm__oloc_poly_deg          ;
  logic   sibm__oloc_decfail           ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
//`define __IBM_PAIR__
  `define __SRIBM_PAIR__

`ifdef __IBM_PAIR__
  bch_berlekamp_ibm
`elsif __SRIBM_PAIR__
//bch_berlekamp_sribm2
//bch_berlekamp_sribm2_s
  bch_berlekamp_sribm2_sm
`else
  bch_berlekamp_ribm2
`endif
  ibm
  (
    .iclk          ( iclk          ) ,
    .iclkena       ( 1'b1          ) ,
    .ireset        ( ireset        ) ,
    .isyndrome_val ( isyndrome_val ) ,
    .isyndrome     ( isyndrome     ) ,
    //
    .oloc_poly_val ( ibm__oloc_poly_val ) ,
    .oloc_poly     ( ibm__oloc_poly     ) ,
    .oloc_poly_deg ( ibm__oloc_poly_deg ) ,
    .oloc_decfail  ( ibm__oloc_decfail  )
  );

  bch_chieny_search
  ibm_chieny
  (
    .iclk          ( iclk          ) ,
    .ireset        ( ireset        ) ,
    .iclkena       ( 1'b1          ) ,
    .iloc_poly_val ( ibm__oloc_poly_val ) ,
    .iloc_poly     ( ibm__oloc_poly     ) ,
    .iloc_decfail  ( 1'b0               )
  );

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

`ifdef __IBM_PAIR__
  bch_berlekamp_sibm
`elsif __SRIBM_PAIR__
//bch_berlekamp_sribm2_s
//bch_berlekamp_ribm_1t
//bch_berlekamp_sribm2_sm
//bch_berlekamp_ribm_2t
  bch_berlekamp_ribm_2t_by_t
`else
  bch_berlekamp_sribm2
`endif
  sibm
  (
    .iclk          ( iclk            ) ,
    .iclkena       ( 1'b1            ) ,
    .ireset        ( ireset          ) ,
    .isyndrome_val ( s_isyndrome_val ) ,
    .isyndrome     ( s_isyndrome     ) ,
    //
    .oloc_poly_val ( sibm__oloc_poly_val ) ,
    .oloc_poly     ( sibm__oloc_poly     ) ,
//  .oloc_poly_deg ( sibm__oloc_poly_deg ) ,
    .oloc_decfail  ( sibm__oloc_decfail  )
  );

  bch_chieny_search
  sibm_chieny
  (
    .iclk          ( iclk          ) ,
    .ireset        ( ireset        ) ,
    .iclkena       ( 1'b1          ) ,
    .iloc_poly_val ( sibm__oloc_poly_val ) ,
    .iloc_poly     ( sibm__oloc_poly     ) ,
    .iloc_decfail  ( 1'b0                )
  );

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  initial begin
    iclk <= 1'b0;
    #5ns forever #5ns iclk = ~iclk;
  end

  initial begin
    ireset <= 1'b1;
    repeat (2) @(negedge iclk) ireset <= 1'b0;
  end

  initial begin : main
    isyndrome_val  = 1'b0;
    isyndrome     = '{default : 0};

    s_isyndrome_val  = 1'b0;
    s_isyndrome     = '{default : 0};

    repeat (5) @(posedge iclk);
/*
    isyndrome     <= '{13, 14, 10, 11, 6, 8};
    s_isyndrome   <= '{13, 14, 10, 11, 6, 8};
    go();
    isyndrome     <= '{ 9, 13,  6, 14,  1,  7};
    s_isyndrome   <= '{ 9, 13,  6, 14,  1,  7};
    go();
    isyndrome     <= '{ 8, 12,  7, 15,  0,  6};
    s_isyndrome   <= '{ 8, 12,  7, 15,  0,  6};
    go();
*/

    isyndrome     <= '{45,  73, 121,  33, 121,  63,  37,  25, 100,  63, 118,  75,  39,   9,  53,  71,  50, 104,  52,  75};
    s_isyndrome   <= '{45,  73, 121,  33, 121,  63,  37,  25, 100,  63, 118,  75,  39,   9,  53,  71,  50, 104,  52,  75};
    go();

    isyndrome     <= '{15,  85,  72, 119,  41,  32, 114, 107, 103,  89,  82,  24,  94, 122,  20,  61,  39, 109,  29,  39};
    s_isyndrome   <= '{15,  85,  72, 119,  41,  32, 114, 107, 103,  89,  82,  24,  94, 122,  20,  61,  39, 109,  29,  39};
    go();

    isyndrome     <= '{110,  44,  20,  72,  24,  22, 121,  32, 126,  70,  54,  18,  38,  63,  79,  24,  10,  42,  30, 116};
    s_isyndrome   <= '{110,  44,  20,  72,  24,  22, 121,  32, 126,  70,  54,  18,  38,  63,  79,  24,  10,  42,  30, 116};
    go();


    $stop;
  end

  task go (int delay = 3*gf_n_max);
    isyndrome_val  <= 1'b1;
    @(posedge iclk);
    isyndrome_val <= 1'b0;
    repeat (delay) @(posedge iclk);

    $display();
    $display();
    $display();

    s_isyndrome_val  <= 1'b1;
    @(posedge iclk);
    s_isyndrome_val <= 1'b0;
    repeat (delay) @(posedge iclk);

    $display();
    $display();
    $display();

  endtask

endmodule

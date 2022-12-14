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



module bch_berlekamp_sribm2
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
  `include "bch_functions.vh"
  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic   iclk                    ;
  input  logic   iclkena                 ;
  input  logic   ireset                  ;
  input  logic   isyndrome_val           ;
  input  ptr_t   isyndrome_ptr           ;
  input  data_t  isyndrome      [1 : t2] ;
  output logic   oloc_poly_val           ;
  output data_t  oloc_poly      [0 : t]  ;
  output data_t  oloc_poly_deg           ;
  output ptr_t   oloc_poly_ptr           ;
  output logic   oloc_decfail            ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int t3 = 3*t;

  data_t syndrome [-t : t2-1];

  data_t delta      [0 : t3+2];
  data_t delta_next [0 : t3];

  data_t tetta      [0 : t3+1];
  data_t tetta_next [0 : t3];

  typedef data_t vector_t [0 : t3];

  function void vector_logout (input string is, input vector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 0; i < $size(vector); i++) begin
      $sformat(s, " %d", vector[i]);
      str = {str, s};
    end
    $display(str);
  end
  endfunction

  typedef data_t svector_t [0 : t];

  function int deg (input svector_t vector);
    string str, s;
  begin
    deg = 0;
    for (int i = 0; i < $size(vector); i++) begin
      if (vector[i] != 0)
        deg = i;
    end
  end
  endfunction
  //------------------------------------------------------------------------------------------------------
  // first time write behaviour model
  //------------------------------------------------------------------------------------------------------

  initial begin : main
    data_t sigma;
    int kv;

    string str, s;
    //
    forever begin
      oloc_poly_val <= 1'b0;
      @(posedge iclk iff (iclkena & isyndrome_val));
      for (int i = $low(syndrome); i <= $high(syndrome); i++) begin
        syndrome[i] = (i < 0) ? 0 : isyndrome[i+1];
      end
      //
      $sformat(str, "sRibma get syndromes : ");
      for (int i = 0; i < t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      $display(str);
      //
      sigma   = 1;
      kv      = 0;

      delta[0  : t2-1] = syndrome[0 : t2-1];
      delta[t2 : t3+2] = '{t3 : 1, default : 0};
      delta[t2-1] = 0;

      tetta[0  : t2-1] = syndrome[0 : t2-1];
      tetta[t2 : t3+1] = '{t3 : 1, default : 0};
      tetta[t2-1] = 0;
      //
      $display("init step, delta %0d sigma %0d kv %0d", delta[0], sigma, kv);
      vector_logout("d poly ", delta [0 : t3]);
      vector_logout("t poly ", tetta [0 : t3]);
      //
      for (int r = 0; r <= t-1; r += 1) begin
        // step 1
        for (int i = 0; i <= t3; i++) begin
          delta_next[i] = gf_mult_a_by_b(sigma, delta[i+2]) ^ gf_mult_a_by_b(delta[0], tetta[i+1]);
//        $display("mult(%0d, %0d) ^ mult(%0d, %0d)", sigma, delta[i+2], delta[0], tetta[i+1]);
        end
        // step 2
        if ((delta[0] != 0) && (kv >= 0)) begin
          tetta [0 : t3] = delta [1 : t3+1]; // mult by z^2
          sigma          = delta[0];
          kv             = -kv;
        end
        else begin
          kv          = kv + 2;
        end
        delta [0 : t3]  = delta_next  [0 : t3];

        $display("step %0d, delta %0d sigma %0d kv %0d", r, delta[0], sigma, kv);
        vector_logout("d poly ", delta [0 : t3]);
        vector_logout("t poly ", tetta [0 : t3]);
      end
      //
      oloc_poly     <= delta[t : t2];
      oloc_poly_deg <= deg(delta[t : t2]);
      oloc_decfail  <= 1'b0;
      oloc_poly_val <= 1'b1;
      @(posedge iclk iff iclkena);
    end
  end

endmodule

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



module bch_berlekamp_ibm
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

  data_t syndrome [-t : t2-1];

  data_t l_poly       [0 : t];
  data_t l_poly_next  [0 : t];

  data_t b_poly         [-1 : t];
  data_t b_poly_next    [0 : t];

  typedef data_t vector_t [0 : t];

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

  function int deg (input vector_t vector);
    string str, s;
  begin
    deg = 0;
    for (int i = 0; i <= t; i++) begin
      if (vector[i] != 0)
        deg = i;
    end
  end
  endfunction
  //------------------------------------------------------------------------------------------------------
  // first time write behaviour model
  //------------------------------------------------------------------------------------------------------

  initial begin : main
    data_t delta;
    data_t sigma;
    int kv;

    string str, s;
    //
    forever begin
      oloc_poly_val <= 1'b0;
      @(posedge iclk iff (iclkena & isyndrome_val));
      //
      syndrome[0  : t2-1] = isyndrome[1 : t2];
      syndrome[-t : -1]   = '{default : 0};
      //
      $sformat(str, "ibma get syndromes : ");
      for (int i = 1; i <= t2; i++) begin
        $sformat(s, " %d", isyndrome[i]);
        str = {str, s};
      end
      $display(str);
      //
      l_poly  = '{0 : 1, default : 0};
      b_poly  = '{0 : 1, default : 0};
      sigma   = 1;
      kv      = 0;
      //
      for (int r = 0; r <= t2-1; r += 1) begin
        // step 1
        delta = 0;
        for (int j = 0; j <= t; j++) begin
          delta ^= gf_mult_a_by_b(l_poly[j], syndrome[r-j]);
        end
        // step 2
        for (int i = 0; i <= t; i++) begin
          l_poly_next[i]  = gf_mult_a_by_b(sigma, l_poly[i]) ^ gf_mult_a_by_b(delta, b_poly[i-1]);
        end
        // step 3
        if ((delta != 0) && (kv >= 0)) begin
          b_poly_next[0 : t]  = l_poly[0 : t];
          sigma               = delta;
          kv                  = -kv - 1;
        end
        else begin
          b_poly_next[0 : t]  = b_poly[-1 : t-1];  // mult by z
          kv                  = kv + 1;
        end
        l_poly[0 : t] = l_poly_next [0 : t];
        b_poly[0 : t] = b_poly_next   [0 : t];

        $display("step %0d, delta %0d sigma %0d kv %0d", r, delta, sigma, kv);
        vector_logout("l poly ", l_poly[0 : t]);
        vector_logout("b poly ", b_poly[0 : t]);
      end
      //
      oloc_poly     <= l_poly[0 : t];
      oloc_poly_deg <= deg(l_poly);
      oloc_decfail  <= 1'b0;
      oloc_poly_val <= 1'b1;
      @(posedge iclk iff iclkena);
    end
  end

endmodule

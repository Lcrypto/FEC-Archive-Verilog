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



module bch_berlekamp_sribm2_sm
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

//data_t delta      [0 : t2+2];
//data_t delta_next [0 : t2];
//
//data_t tetta      [0 : t2+1];
//data_t tetta_next [0 : t2];

  data_t delta      [0 : t2+2];
  data_t delta_next [0 : t2];

  data_t tetta       [0 : t2+1];
  data_t tetta_next  [0 : t2];

  logic  tetta_clear      [0 : t2+2];
  logic  tetta_clear_next [0 : t2+2];


  typedef data_t vector_t [0 : t2];

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
    int a, b;

    string str, s;
    //
    forever begin
      oloc_poly_val <= 1'b0;
      @(posedge iclk iff (iclkena & isyndrome_val));
      for (int i = $low(syndrome); i <= $high(syndrome); i++) begin
        syndrome[i] = (i < 0) ? 0 : isyndrome[i+1];
      end
      //
      $sformat(str, "sRibma_sm get syndromes : ");
      for (int i = 0; i < t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      $display(str);
      //
      sigma   = 1;
      kv      = 0;
      //
      delta[0 : t2+2] = '{t2 : 1, default : 0};
      tetta[0 : t2+1] = '{t2 : 1, default : 0};

      for (int i = 0; i < t2-1; i++) begin
        if (~i[0]) // use even, remove odd
          delta[i] = syndrome[i];
        else      // use odd, remove even
          tetta[i] = syndrome[i];
      end
      tetta_clear = '{t2-3 : 1, t2-4 : 1, default : 0};
      // result is same
//    delta[0 : t2-2] = syndrome[0 : t2-2];
//    tetta[0 : t2-2] = syndrome[0 : t2-2];
      //
      //
      $display("init step, delta %0d sigma %0d kv %0d", delta[0], sigma, kv);
      vector_logout("d poly ", delta [0 : t2]);
      vector_logout("t poly ", tetta [0 : t2]);
      vector_logout("c poly ", tetta_clear [0 : t2]);
      //
      // this algorithm count true sigma & delta[0] value
      //
      for (int r = 0; r <= t-1; r += 1) begin
        // step 1
        for (int i = 0; i <= t2; i++) begin
          delta_next[i] = gf_mult_a_by_b(sigma, delta[i+2]) ^ gf_mult_a_by_b(delta[0], tetta[i+1]);
//        $display("mult(%0d, %0d) ^ mult(%0d, %0d)", sigma, delta[i+2], delta[0], tetta[i+1]);
        end
        // step 2
        if ((delta[0] != 0) && (kv >= 0)) begin
          tetta [0 : t2]  = delta [1 : t2+1];   // mult by z

          sigma           = delta[0];
          kv              = -kv;
        end
        else begin
          kv            = kv + 2;
        end
        //
        //tetta_clear_next[0 : t2] = tetta_clear[1 : t2+1];
        tetta_clear_next[0 : t2] = tetta_clear[2 : t2+2];
        //
        a = t2-2*r-3;
        b = t2-2*r-4;
        $display("clear %0d & %0d", a, b);
        if (a >= 0) tetta[a] = 0;
        if (b >= 0) tetta[b] = 0;
        // not fully wrong
//      $display("clear %0d & %0d", t-r-1, t-r);
//      tetta[t-r-1] = 0;
//      tetta[t-r] = 0;
        // fully wrong
//      if (r == t-2) begin
//        tetta[0] = 0;
//        tetta[1] = 0;
//      end
        //
        delta [0 : t2] = delta_next  [0 : t2];
        tetta_clear[0 : t2] = tetta_clear_next[0 : t2];

        $display("step %0d, delta %0d sigma %0d kv %0d", r, delta[0], sigma, kv);
        vector_logout("d poly ", delta [0 : t2]);
        vector_logout("t poly ", tetta [0 : t2]);
        vector_logout("c poly ", tetta_clear [0 : t2]);

      end
      //
      oloc_poly     <= delta[0 : t];
      oloc_poly_deg <= deg(delta[0 : t]);
      oloc_decfail  <= 1'b0;
      oloc_poly_val <= 1'b1;
      @(posedge iclk iff iclkena);
    end
  end

endmodule

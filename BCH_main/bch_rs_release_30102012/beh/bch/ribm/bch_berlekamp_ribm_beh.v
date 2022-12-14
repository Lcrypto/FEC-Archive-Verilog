/*






  logic   bch_berlekamp__iclk                     ;
  logic   bch_berlekamp__ireset                   ;
  logic   bch_berlekamp__isyndome_val             ;
  data_t  bch_berlekamp__isyndrome     [0 : t2-1] ;
  logic   bch_berlekamp__oloc_poly_val            ;
  data_t  bch_berlekamp__oloc_poly      [0 : t-1] ;
  data_t  bch_berlekamp__oloc_poly_deg            ;
  logic   bch_berlekamp__odecfail                 ;



  bch_berlekamp
  bch_berlekamp
  (
    .iclk          ( bch_berlekamp__iclk          ) ,
    .ireset        ( bch_berlekamp__ireset        ) ,
    .isyndome_val  ( bch_berlekamp__isyndome_val  ) ,
    .isyndrome     ( bch_berlekamp__isyndrome     ) ,
    .oloc_poly_val ( bch_berlekamp__oloc_poly_val ) ,
    .oloc_poly     ( bch_berlekamp__oloc_poly     ) ,
    .oloc_poly_deg ( bch_berlekamp__oloc_poly_deg ) ,
    .odecfail      ( bch_berlekamp__odecfail      )
  );


  assign bch_berlekamp__iclk         = '0 ;
  assign bch_berlekamp__ireset       = '0 ;
  assign bch_berlekamp__isyndome_val = '0 ;
  assign bch_berlekamp__isyndrome    = '0 ;



*/



module bch_berlekamp_ribm
(
  iclk          ,
  iclkena       ,
  ireset        ,
  isyndrome_val ,
  isyndrome     ,
  oloc_poly_val ,
  oloc_poly     ,
  oloc_poly_deg ,
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
  input  data_t  isyndrome      [1 : t2] ;
  output logic   oloc_poly_val           ;
  output data_t  oloc_poly      [0 : t]  ;
  output data_t  oloc_poly_deg           ;
  output logic   oloc_decfail            ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  data_t syndrome [-t : t2-1];

  data_t l_poly       [0 : t];
  data_t l_poly_next  [0 : t];

  data_t b_poly         [-1 : t];
  data_t b_poly_next    [0 : t];

  data_t delta      [0 : t2];
  data_t delta_next [0 : t2-1];

  data_t tetta      [0 : t2-1];
  data_t tetta_next [0 : t2-1];

  typedef data_t vector_t [0 : t];

  function void vector_logout (input string is, input vector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 0; i <= t; i++) begin
      $sformat(s, " %d", vector[i]);
      str = {str, s};
    end
    $display(str);
  end
  endfunction

  typedef data_t lvector_t [0 : t2-1];

  function void lvector_logout (input string is, input lvector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 0; i <= t2-1; i++) begin
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
    data_t sigma;
    int kv;

    string str, s;
    //
    forever begin
      oloc_poly_val <= 1'b0;
      @(posedge iclk iff isyndrome_val);
      for (int i = $low(syndrome); i <= $high(syndrome); i++) begin
        syndrome[i] = (i < 0) ? 0 : isyndrome[i+1];
      end
      //
      $sformat(str, "ribma get syndromes : ");
      for (int i = 0; i < t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      $display(str);
      //
      l_poly  = '{0 : 1, default : 0};
      b_poly  = '{0 : 1, default : 0};
      sigma   = 1;
      kv      = 0;

      delta[0 : t2-1] = syndrome[0 : t2-1];
      delta[t2]       = 0;

      tetta   = syndrome[0 : t2-1];
      $display("init step, delta %0d sigma %0d kv %0d", delta[0], sigma, kv);
      vector_logout("l poly ", l_poly[0 : t]);
      vector_logout("b poly ", b_poly[0 : t]);
      lvector_logout("d poly ", delta [0 : t2-1]);
      lvector_logout("t poly ", tetta [0 : t2-1]);
      //
      for (int r = 0; r <= t2-1; r += 1) begin
        // step 1
        for (int i = 0; i <= t; i++) begin
          l_poly_next[i] = gf_mult_a_by_b(sigma, l_poly[i]) ^ gf_mult_a_by_b(delta[0], b_poly[i-1]);
          $display("loc mult(%0d, %0d) ^ mult(%0d, %0d) = %0d", sigma, l_poly[i], delta[0], b_poly[i-1], l_poly_next[i]);
        end
        for (int i = 0; i <= t2-1; i++) begin
          delta_next[i] = gf_mult_a_by_b(sigma, delta[i+1]) ^ gf_mult_a_by_b(delta[0], tetta[i]);
          $display("delta mult(%0d, %0d) ^ mult(%0d, %0d) = %0d", sigma, delta[i+1], delta[0], tetta[i], delta_next[i]);
        end
        // step 2
        if ((delta[0] != 0) && (kv >= 0)) begin
          b_poly_next[0 : t]    = l_poly[0 : t];
          tetta_next [0 : t2-1] = delta [1 : t2]; // mult by z
          sigma                 = delta[0];
          kv                    = -kv - 1;
        end
        else begin
          b_poly_next[0 : t]  = b_poly[-1 : t-1];  // mult by z
          tetta_next          = tetta;
          //
          kv    = kv + 1;
        end
        l_poly[0 : t]     = l_poly_next [0 : t];
        b_poly[0 : t]     = b_poly_next [0 : t];
        delta [0 : t2-1]  = delta_next  [0 : t2-1];
        tetta [0 : t2-1]  = tetta_next  [0 : t2-1];

        $display("step %0d, delta %0d sigma %0d kv %0d", r, delta[0], sigma, kv);
        vector_logout("l poly ", l_poly[0 : t]);
        vector_logout("b poly ", b_poly[0 : t]);
        lvector_logout("d poly ", delta [0 : t2-1]);
        lvector_logout("t poly ", tetta [0 : t2-1]);
      end
      //
      oloc_poly     <= l_poly[0 : t];
      oloc_poly_deg <= deg(l_poly);
      oloc_decfail  <= 1'b0;
      oloc_poly_val <= 1'b1;
      @(posedge iclk);
    end
  end

endmodule

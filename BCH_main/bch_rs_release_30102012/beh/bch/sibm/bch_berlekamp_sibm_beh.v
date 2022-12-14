/*






  logic   bch_berlekamp__iclk                     ;
  logic   bch_berlekamp__ireset                   ;
  logic   bch_berlekamp__isyndome_val             ;
  data_t  bch_berlekamp__isyndrome     [0 : t2-1] ;
  logic   bch_berlekamp__oloc_poly_val            ;
  data_t  bch_berlekamp__oloc_poly      [0 : t-1] ;
  ptr_t   bch_berlekamp__oloc_poly_ptr            ;
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
    .oloc_poly_ptr ( bch_berlekamp__oloc_poly_ptr ) ,
    .odecfail      ( bch_berlekamp__odecfail      )
  );


  assign bch_berlekamp__iclk         = '0 ;
  assign bch_berlekamp__ireset       = '0 ;
  assign bch_berlekamp__isyndome_val = '0 ;
  assign bch_berlekamp__isyndrome    = '0 ;



*/



module bch_berlekamp_sibm_beh
(
  iclk          ,
  ireset        ,
  isyndome_val  ,
  isyndrome     ,
  oloc_poly_val ,
  oloc_poly     ,
  oloc_poly_ptr ,
  oloc_failed
);

  `include "bch_parameters.vh"
  `include "bch_functions.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic   iclk                    ;
  input  logic   ireset                  ;
  input  logic   isyndome_val            ;
  input  data_t  isyndrome      [1 : t2] ;
  output logic   oloc_poly_val           ;
  output data_t  oloc_poly      [0 : t]  ;
  output ptr_t   oloc_poly_ptr           ;
  output logic   oloc_failed             ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  data_t l_poly        [0 : t];

  data_t gamma      [0 : t2 + 2];
  data_t gamma_next [0 : t2 + 2];

  data_t tetta      [0 : t2 + 1];

  data_t syndrome      [0 : t2-1];
  ptr_t  syndrome_ptr_latched ;

//data_t syndrome [-t+1 : t2];
//
//data_t l_poly       [-1 : t];
//data_t l_poly_next  [0 : t];
//
//data_t b_poly         [-2 : t];
//data_t b_poly_next    [0 : t];

  typedef data_t gvector_t [0 : t2];

  function void gvector_logout (input string is, input gvector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 0; i <= t2; i++) begin
      $sformat(s, " %d", vector[i]);
      str = {str, s};
    end
    $display(str);
  end
  endfunction


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
      @(posedge iclk iff isyndome_val);
      //
      syndrome[0  : t2-1] = isyndrome[1 : t2];
      //
      $sformat(str, "Sibma get syndromes : ");
      for (int i = 0; i < t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      $display(str);
      //
      // initialization
      gamma[0 : t2-2] = syndrome[0 : t2-2];
      gamma[t2-1]     = 0;
      gamma[t2]       = 1;
      gamma[t2+1]     = 0;
      gamma[t2+2]     = 0;
      //
      tetta[0 : t2-2] = syndrome[0 : t2-2];
      tetta[t2-1]     = 0;
      tetta[t2]       = 1;
      tetta[t2+1]     = 0;
      //
      sigma   = 1;
      kv      = 0;
      //
      for (int r = 0; r <= t-1; r += 1) begin
        // step 1
        for (int i = 0; i <= t2; i++) begin
          gamma_next[i] = gf_mult_a_by_b(sigma, gamma[i+2]) ^ gf_mult_a_by_b(gamma[0], tetta[i+1]);
        end
        // step 2
        if ((gamma[0] != 0) && (kv >= 0)) begin
          tetta [0 : t2-4] = gamma [1 : t2-3];
          sigma            = gamma[0];
          kv               = -kv;
        end
        else begin
          kv             = kv + 2;
        end
        tetta[t2 - 3] = 0;
        tetta[t2 - 2] = 0;

        $display("Sibma %0d, delta %0d sigma %0d kv %0d", r, gamma[0], sigma, kv);

        gamma [0 : t2] = gamma_next  [0 : t2];

        gvector_logout  ("Sibma g poly"  ,gamma [0 : t2]);
      end
      l_poly[0 : t] = gamma[0 : t];
      vector_logout   ("Sibma l poly ", l_poly[0 : t]);

      oloc_poly     <= l_poly[0 : t];
      oloc_poly_ptr <= 0;
      oloc_failed   <= 1'b0;
      oloc_poly_val <= 1'b1;
      @(posedge iclk);
    end
  end

endmodule

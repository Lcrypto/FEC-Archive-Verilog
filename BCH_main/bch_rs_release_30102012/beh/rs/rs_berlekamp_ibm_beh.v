/*



  parameter int n         = 240 ;
  parameter int check     =  30 ;
  parameter int m         =   8 ;
  parameter int irrpol    = 285 ;
  parameter int genstart  =   0 ;



  logic   rs_berlekamp__iclk                        ;
  logic   rs_berlekamp__iclkena                     ;
  logic   rs_berlekamp__ireset                      ;
  logic   rs_berlekamp__isyndrome_val               ;
  ptr_t   rs_berlekamp__isyndrome_ptr               ;
  data_t  rs_berlekamp__isyndrome     [0 : check-1] ;
  logic   rs_berlekamp__oloc_poly_val               ;
  data_t  rs_berlekamp__oloc_poly      [0 : errs-1] ;
  data_t  rs_berlekamp__oloc_poly_deg               ;
  data_t  rs_berlekamp__oomega_poly    [0 : errs-1] ;
  ptr_t   rs_berlekamp__oloc_poly_ptr               ;
  logic   rs_berlekamp__oloc_decfail                ;



  rs_berlekamp_2t
  #(
    .n        ( n        ) ,
    .check    ( check    ) ,
    .m        ( m        ) ,
    .irrpol   ( irrpol   ) ,
    .genstart ( genstart )
  )
  rs_berlekamp
  (
    .iclk          ( rs_berlekamp__iclk          ) ,
    .iclkena       ( rs_berlekamp__iclkena       ) ,
    .ireset        ( rs_berlekamp__ireset        ) ,
    .isyndrome_val ( rs_berlekamp__isyndrome_val ) ,
    .isyndrome_ptr ( rs_berlekamp__isyndrome_ptr ) ,
    .isyndrome     ( rs_berlekamp__isyndrome     ) ,
    .oloc_poly_val ( rs_berlekamp__oloc_poly_val ) ,
    .oloc_poly     ( rs_berlekamp__oloc_poly     ) ,
    .oloc_poly_deg ( rs_berlekamp__oloc_poly_deg ) ,
    .oomega_poly   ( rs_berlekamp__oomega_poly   ) ,
    .oloc_poly_ptr ( rs_berlekamp__oloc_poly_ptr ) ,
    .oloc_decfail  ( rs_berlekamp__oloc_decfail  )
  );


  assign rs_berlekamp__iclk         = '0 ;
  assign rs_berlekamp__iclkena      = '0 ;
  assign rs_berlekamp__ireset       = '0 ;
  assign rs_berlekamp__isyndrome_val = '0 ;
  assign rs_berlekamp__isyndrome_ptr = '0 ;
  assign rs_berlekamp__isyndrome    = '0 ;



*/


`include "define.vh"

module rs_berlekamp_ibm_beh
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
  oomega_poly   ,
  oloc_poly_ptr ,
  oloc_decfail
);

  `include "rs_parameters.vh"
  `include "rs_functions.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic   iclk                       ;
  input  logic   iclkena                    ;
  input  logic   ireset                     ;
  //
  input  logic   isyndrome_val              ;
  input  ptr_t   isyndrome_ptr              ;
  input  data_t  isyndrome      [1 : check] ;
  //
  output logic   oloc_poly_val              ;
  output data_t  oloc_poly      [0 : errs]  ;
  output data_t  oloc_poly_deg              ;
  output data_t  oomega_poly    [1 : errs]  ;
  output ptr_t   oloc_poly_ptr              ;
  output logic   oloc_decfail               ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int t3 = check + errs;
  localparam int t2 = check;
  localparam int t  = errs;

  data_t syndrome    [-t : t2-1];
  ptr_t  syndrome_ptr_latched ;

  data_t omega_poly    [0 : t-1];

  data_t l_poly        [0 : t];
  data_t l_poly_next   [0 : t];

  data_t b_poly       [-1 : t];
  data_t b_poly_next   [0 : t];

  data_t delta;
  data_t sigma;
  data_t kv;

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

  typedef data_t evector_t [0 : t-1];

  function void evector_logout (input string is, input evector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 0; i < t; i++) begin
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
  //
  //------------------------------------------------------------------------------------------------------

    initial begin : main
    data_t delta;
    data_t sigma;
    int kv;

    string str, s;
    //
    forever begin
      oloc_poly_val <= 1'b0;
      @(posedge iclk iff isyndrome_val);
      //
      syndrome[0  : t2-1] = isyndrome[1 : t2];
      syndrome[-t : -1]   = '{default : 0};
      //
      $sformat(str, "ibma get syndromes : ");
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
      //
      for (int r = 0; r <= t2-1; r += 1) begin
        // step 1
        delta = 0;
        for (int j = 0; j <= t; j++) begin
          delta ^= gf_mult_a_by_b(l_poly[j], syndrome[r-j]);
        end
        // step 2
        for (int i = 0; i <= t; i++) begin
          l_poly_next[i] = gf_mult_a_by_b(sigma, l_poly[i]) ^ gf_mult_a_by_b(delta, b_poly[i-1]);
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
        b_poly[0 : t] = b_poly_next [0 : t];

        $display("ibma step %0d, delta %0d sigma %0d kv %0d", r, delta, sigma, kv);

        vector_logout("ibma l poly ", l_poly[0 : t]);
        vector_logout("ibma b poly ", b_poly[0 : t]);
      end
      // count error value polynome
      for (int i = 0; i <= t-1; i++) begin
        omega_poly[i] = 0;
        for (int j = 0; j <= t-1; j++) begin
          omega_poly[i] ^= gf_mult_a_by_b(syndrome[i-j], l_poly[j]);
        end
        evector_logout("ibma omega_poly ", omega_poly[0 : t-1]);
      end
      //
      oloc_poly     <= l_poly[0 : t];
      oomega_poly   <= omega_poly[0 : t-1];
      oloc_poly_deg <= deg(l_poly);
      oloc_decfail  <= 1'b0;
      oloc_poly_val <= 1'b1;
      @(posedge iclk);
    end
  end
endmodule

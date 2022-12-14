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



  rs_berlekamp_ribm2_beh
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

module rs_berlekamp_ribm2_beh
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

  parameter bit pLOG_ON = 1;
  parameter int pTYPE   = "beh";

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

  data_t syndrome      [0 : t2-1];
  ptr_t  syndrome_ptr_latched ;

  data_t omega_poly    [0 : t-1];

  data_t l_poly        [0 : t];
  data_t l_poly_next   [0 : t];

  //data_t delta;
  data_t tetta      [0 : t3];

  data_t sigma;

  data_t gamma      [0 : t3+1];
  data_t gamma_next [0 : t3+1] ;

  data_t kv;

  typedef data_t gvector_t [0 : t3];

  function void gvector_logout (input string is, input gvector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 0; i <= t3; i++) begin
      $sformat(s, " %d", vector[i]);
      str = {str, s};
    end
    if (pLOG_ON) $display(str);
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
    if (pLOG_ON) $display(str);
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
    if (pLOG_ON) $display(str);
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
      //
      $sformat(str, "Ribma get syndromes : ");
      for (int i = 0; i < t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      if (pLOG_ON) $display(str);
      //
      gamma[0 : t2-1]   = syndrome[0 : t2-1];
      gamma[t2 : t3-1]  = '{default : 0};
      gamma[t3]         = 1;
      gamma[t3+1]       = 0;

      tetta[0   : t2-1] = syndrome[0 : t2-1];
      tetta[t2  : t3-1] = '{default : 0};
      tetta[t3]         = 1;

      //
      sigma   = 1;
      kv      = 0;
      //
      for (int r = 0; r <= t2-1; r += 1) begin
        // step 1
        for (int i = 0; i <= t3; i++) begin
          gamma_next[i] = gf_mult_a_by_b(sigma, gamma[i+1]) ^ gf_mult_a_by_b(gamma[0], tetta[i]);
        end
        // step 2
        if ((gamma[0] != 0) && (kv >= 0)) begin
          tetta [0 : t3] = gamma [1 : t3+1];
          sigma          = gamma[0];
          kv             = -kv - 1;
        end
        else begin
          kv             = kv + 1;
        end

        if (pLOG_ON) $display("Ribma step %0d, delta %0d sigma %0d kv %0d", r, gamma[0], sigma, kv);

        gamma [0 : t3] = gamma_next  [0 : t3];

        gvector_logout  ("Ribma g poly"  ,gamma [0 : t3]);
      end
      // count error value polynome
      l_poly[0 : t]       = gamma[t : t2];
      omega_poly[0 : t-1] = gamma[0 : t-1];
      vector_logout ("Ribma l poly ", l_poly[0 : t]);
      evector_logout("Ribma omega_poly ", omega_poly[0 : t-1]);
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

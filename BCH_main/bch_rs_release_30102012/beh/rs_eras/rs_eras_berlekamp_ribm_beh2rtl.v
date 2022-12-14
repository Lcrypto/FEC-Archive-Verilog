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
  data_t  rs_berlekamp__isyndrome       [1 : check] ;
  data_t  rs_berlekamp__ieras_root      [1 : check] ;
  data_t  rs_berlekamp__ieras_num                   ;
  logic   rs_berlekamp__oloc_poly_val               ;
  data_t  rs_berlekamp__oloc_poly       [0 : check] ;
  data_t  rs_berlekamp__oloc_poly_deg               ;
  data_t  rs_berlekamp__oomega_poly     [1 : check] ;
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
    .ieras_root    ( rs_berlekamp__ieras_root    ) ,
    .ieras_num     ( rs_berlekamp__ieras_num     ) ,
    .oloc_poly_val ( rs_berlekamp__oloc_poly_val ) ,
    .oloc_poly     ( rs_berlekamp__oloc_poly     ) ,
    .oloc_poly_deg ( rs_berlekamp__oloc_poly_deg ) ,
    .oomega_poly   ( rs_berlekamp__oomega_poly   ) ,
    .oloc_poly_ptr ( rs_berlekamp__oloc_poly_ptr ) ,
    .oloc_decfail  ( rs_berlekamp__oloc_decfail  )
  );


  assign rs_berlekamp__iclk           = '0 ;
  assign rs_berlekamp__iclkena        = '0 ;
  assign rs_berlekamp__ireset         = '0 ;
  assign rs_berlekamp__isyndrome_val  = '0 ;
  assign rs_berlekamp__isyndrome_ptr  = '0 ;
  assign rs_berlekamp__isyndrome      = '0 ;
  assign rs_berlekamp__ieras_root     = '0 ;
  assign rs_berlekamp__ieras_num      = '0 ;


*/


`include "define.vh"

module rs_eras_berlekamp_ribm_beh2rtl
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
  input  data_t  ieras_root     [1 : check] ;
  input  data_t  ieras_num                  ;
  //
  output logic   oloc_poly_val              ;
  output data_t  oloc_poly      [0 : check] ;
  output data_t  oloc_poly_deg              ;
  output data_t  oomega_poly    [1 : check] ;
  output ptr_t   oloc_poly_ptr              ;
  output logic   oloc_decfail               ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

//rom_t   ALPHA_TO;
//rom_t   INDEX_OF;
//
//initial begin
//  ALPHA_TO = generate_gf_alpha_to_power(irrpol);
//  INDEX_OF = generate_gf_index_of_alpha(ALPHA_TO);
//end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int t3 = check + errs;
  localparam int t2 = check;
  localparam int t  = errs;

  data_t syndrome   [0 : t2-1];
  data_t msyndrome  [0 : t2-1];

  data_t temp_sh_reg [1 : t2] ;

  data_t eras_num             ;
  data_t eras_num2decfail     ;

  ptr_t  syndrome_ptr_latched ;

  data_t omega_poly    [0 : t2-1];

  data_t l_poly       [-1 : t2];
  data_t l_poly_next   [0 : t2];

  data_t b_poly       [-1 : t2];
  data_t b_poly_next   [0 : t2];

  //data_t delta;
  data_t tetta      [0 : t2-1];

  data_t sigma;

  data_t gamma      [0 : t2];
  data_t gamma_next [0 : t2] ;

  data_t kv;

  typedef data_t gvector_t [0 : t2];

  function void gvector_logout (input string is, input gvector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 0; i <= $high(vector); i++) begin
      $sformat(s, " %d", vector[i]);
      str = {str, s};
    end
    if (pLOG_ON) $display(str);
  end
  endfunction

  typedef data_t vector_t [0 : t2];

  function void vector_logout (input string is, input vector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 0; i <= $high(vector); i++) begin
      $sformat(s, " %d", vector[i]);
      str = {str, s};
    end
    if (pLOG_ON) $display(str);
  end
  endfunction

  typedef data_t evector_t [0 : t2-1];

  function void evector_logout (input string is, input evector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 0; i <= $high(vector); i++) begin
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
      oloc_poly_ptr       = isyndrome_ptr;
      //
      syndrome[0  : t2-1] = isyndrome[1 : t2];
      temp_sh_reg[1 : t2] = ieras_root;
      eras_num            = (ieras_num > check) ? check : ieras_num;
      eras_num2decfail    = ieras_num;
      //------------------------------------------------------------------------------------------------------
      //
      //------------------------------------------------------------------------------------------------------
      $sformat(str, "ribma2rtl get syndromes : ");
      for (int i = 0; i < t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      if (pLOG_ON) $display(str);
      //
      $sformat(str, "ribma2rtl get %0d erasures : ", eras_num);
      for (int i = 1; i <= t2; i++) begin
        $sformat(s, " %d", temp_sh_reg[i]);
        str = {str, s};
      end
      if (pLOG_ON) $display(str);
      //------------------------------------------------------------------------------------------------------
      // count Ã(x) init value
      //------------------------------------------------------------------------------------------------------
      sigma   = 1;
      l_poly  = '{0 : 1, default : 0};
      b_poly  = '{0 : 1, default : 0};
      /*
      for (int r = 1; r <= eras_num; r++) begin
        l_poly_next = l_poly;
        for (int j = 1; j <= r; j++) begin
          l_poly_next[j] = l_poly[j] ^ gf_mult_a_by_b(eras_root[r], l_poly[j-1]);
        end
        l_poly  = l_poly_next;
      end
      b_poly[0 : t2]  = l_poly;
      */
      /*
      for (int r = 1; r <= eras_num; r++) begin
        for (int i = 0; i <= t2; i++) begin
          l_poly_next[i] = gf_mult_a_by_b(1, l_poly[i]) ^ gf_mult_a_by_b(eras_root[r], b_poly[i-1]);
        end
        l_poly          = l_poly_next;
        b_poly[0 : t2]  = l_poly_next;
      end
      */
      //for (int r = 1; r <= eras_num; r++) begin
      for (int r = 1; r <= t2; r++) begin
        for (int i = 0; i <= t2; i++) begin
          l_poly_next[i] = gf_mult_a_by_b(sigma, l_poly[i]) ^ gf_mult_a_by_b(temp_sh_reg[1], l_poly[i-1]);
//        if (pLOG_ON) $display("ribma2rtl step {%0d %0d}, %0d = %0d ^ (%0d * %0d)", r, i, l_poly_next[i], l_poly[i], temp_sh_reg[1], l_poly[i-1]);
        end
        l_poly[0 : t2]  = l_poly_next;
        temp_sh_reg[1 : t2-1] = temp_sh_reg[2 : t2]; // shift left
//      vector_logout("ribma2rtl l poly ",  l_poly[0 : t2]);
      end
      //------------------------------------------------------------------------------------------------------
      // count OMEGA init value
      //------------------------------------------------------------------------------------------------------
      sigma           = 1;
      gamma           = '{default : 0};
      gamma_next      = '{default : 0};
      gamma[0 : t2-1] = syndrome[0 : t2-1];
      tetta[0 : t2-1] = syndrome[0 : t2-1];

      temp_sh_reg     = l_poly[1 : t2];
      b_poly[0 : t2]  = l_poly[0 : t2];

      for (int r = 1; r <= eras_num; r++) begin
        for (int i = 0; i <= t2-1; i++) begin
          gamma_next[i] = gf_mult_a_by_b(sigma, gamma[i+1]) ^ gf_mult_a_by_b(temp_sh_reg[1], tetta[i]);
        end
        gamma = gamma_next;
        temp_sh_reg[1 : t2-1] = temp_sh_reg[2 : t2];
      end

      tetta = gamma[0 : t2-1];

      vector_logout("ribma2rtl init l poly ",  l_poly[0 : t2]);
      vector_logout("ribma2rtl init b poly ",  b_poly[0 : t2]);
//    vector_logout   ("ribma2rtl modify l poly ", l_poly[0 : t2]);
//    vector_logout   ("ribma2rtl modify b poly ", b_poly[0 : t2]);
      gvector_logout  ("ribma2rtl modify g poly ", gamma [0 : t2]);

      //------------------------------------------------------------------------------------------------------
      //
      //------------------------------------------------------------------------------------------------------
      //
      sigma   = 1;
//    gamma[0 : t2-1] = msyndrome[0 : t2-1];
//    gamma[t2]       = 0;
//    tetta[0 : t2-1] = msyndrome[0 : t2-1];
      kv      = 0;
      //
      for (int r = eras_num; r  <= t2-1; r += 1) begin
        // step 1
        for (int i = 0; i <= t2; i++) begin
          l_poly_next[i] = gf_mult_a_by_b(sigma, l_poly[i]) ^ gf_mult_a_by_b(gamma[0], b_poly[i-1]);
        end
        // step 2
        for (int i = 0; i <= t2-1; i++) begin
          gamma_next[i] = gf_mult_a_by_b(sigma, gamma[i+1]) ^ gf_mult_a_by_b(gamma[0], tetta[i]);
        end
        // step 3
        if ((gamma[0] != 0) && (kv >= 0)) begin
          b_poly_next[0 : t2]   = l_poly[0 : t2];
          tetta      [0 : t2-1] = gamma [1 : t2];
          sigma                 = gamma[0];
          kv                    = -kv - 1;
        end
        else begin
          b_poly_next[0 : t2] = b_poly[-1 : t2-1];  // mult by z
          kv                  = kv + 1;
        end

        if (pLOG_ON) $display("ribma2rtl step %0d, delta %0d sigma %0d kv %0d", r, gamma[0], sigma, kv);

        gamma [0 : t2-1]  = gamma_next  [0 : t2-1];
        l_poly[0 : t2]    = l_poly_next [0 : t2];
        b_poly[0 : t2]    = b_poly_next [0 : t2];

        vector_logout   ("ribma2rtl l poly ", l_poly[0 : t2]);
        vector_logout   ("ribma2rtl b poly ", b_poly[0 : t2]);
        gvector_logout  ("ribma2rtl g poly"  ,gamma [0 : t2]);

      end
      // count error value polynome
      omega_poly[0 : t2-1] = gamma[0 : t2-1];

      vector_logout ("ribma2rtl l poly ", l_poly[0 : t2]);
      evector_logout("ribma2rtl omega poly ", omega_poly[0 : t2-1]);
/*
      for (int i = 0; i <= t2; i++)
        l_poly_next[i] = gf_div(l_poly[i], l_poly[0], INDEX_OF, ALPHA_TO);

      vector_logout ("ribma2rtl norm l poly ", l_poly_next[0 : t2]);
*/
      //
      oloc_poly     <= l_poly[0 : t2];
      oomega_poly   <= omega_poly[0 : t2-1];
      oloc_poly_deg <= deg(l_poly[0 : t2]);
      oloc_decfail  <= (eras_num2decfail > check);
      oloc_poly_val <= 1'b1;
      @(posedge iclk);
    end
  end
endmodule

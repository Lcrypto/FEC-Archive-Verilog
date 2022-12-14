/*



  parameter int n         = 240 ;
  parameter int check     =  30 ;
  parameter int m         =   8 ;
  parameter int irrpol    = 285 ;
  parameter int genstart  =   0 ;



  logic   rs_eras_berlekamp_ribm_beh__iclk                      ;
  logic   rs_eras_berlekamp_ribm_beh__ireset                    ;
  logic   rs_eras_berlekamp_ribm_beh__isyndrome_val             ;
  ptr_t   rs_eras_berlekamp_ribm_beh__isyndrome_ptr             ;
  data_t  rs_eras_berlekamp_ribm_beh__isyndrome     [1 : check] ;
  data_t  rs_eras_berlekamp_ribm_beh__ieras_root    [1 : check] ;
  data_t  rs_eras_berlekamp_ribm_beh__ieras_num                 ;
  logic   rs_eras_berlekamp_ribm_beh__oloc_poly_val             ;
  data_t  rs_eras_berlekamp_ribm_beh__oloc_poly     [0 : check] ;
  data_t  rs_eras_berlekamp_ribm_beh__oomega_poly   [1 : check] ;
  ptr_t   rs_eras_berlekamp_ribm_beh__oloc_ptr                  ;
  data_t  rs_eras_berlekamp_ribm_beh__oloc_poly_deg             ;
  logic   rs_eras_berlekamp_ribm_beh__oloc_decfail              ;



  rs_eras_berlekamp_ribm2_beh
  rs_eras_berlekamp_ribm2_beh
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


  assign rs_eras_berlekamp_ribm_beh__iclk          = '0 ;
  assign rs_eras_berlekamp_ribm_beh__ireset        = '0 ;
  assign rs_eras_berlekamp_ribm_beh__isyndrome_val = '0 ;
  assign rs_eras_berlekamp_ribm_beh__isyndrome_ptr = '0 ;
  assign rs_eras_berlekamp_ribm_beh__isyndrome     = '0 ;
  assign rs_eras_berlekamp_ribm_beh__ieras_root    = '0 ;
  assign rs_eras_berlekamp_ribm_beh__ieras_num     = '0 ;



*/


`include "define.vh"

module rs_eras_berlekamp_ribm2_beh
(
  iclk          ,
  iclkena       ,
  ireset        ,
  //
  isyndrome_val ,
  isyndrome_ptr ,
  isyndrome     ,
  ieras_root    ,
  ieras_num     ,
  //
  oloc_poly_val ,
  oloc_poly     ,
  oomega_poly   ,
  oloc_poly_ptr ,
  oloc_poly_deg ,
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
  input  logic   ireset                     ;
  input  logic   iclkena                    ;
  //
  input  logic   isyndrome_val              ;
  input  ptr_t   isyndrome_ptr              ;
  input  data_t  isyndrome      [1 : check] ;
  input  data_t  ieras_root     [1 : check] ;
  input  data_t  ieras_num                  ;
  //
  output logic   oloc_poly_val              ;
  output data_t  oloc_poly      [0 : check] ;
  output data_t  oomega_poly    [1 : check] ;
  output ptr_t   oloc_poly_ptr              ;
  output data_t  oloc_poly_deg              ;
  output logic   oloc_decfail               ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  rom_t   ALPHA_TO;
  rom_t   INDEX_OF;

  initial begin
    ALPHA_TO = generate_gf_alpha_to_power(irrpol);
    INDEX_OF = generate_gf_index_of_alpha(ALPHA_TO);
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int t6 = check + check + check;
  localparam int t5 = check + check + errs;
  localparam int t4 = check + check;
  localparam int t3 = check + errs;
  localparam int t2 = check;
  localparam int t  = errs;

  data_t syndrome   [0 : t2-1];
  data_t msyndrome  [0 : t2-1];
  data_t eras_root  [0 : t2];
  data_t eras_num           ;
  data_t eras_num2decfail   ;
  ptr_t  syndrome_ptr_latched ;

  data_t omega_poly    [0 : t2-1];

  data_t l_poly       [0 : t2];
  data_t l_poly_next  [0 : t2];
  data_t L ;

  //data_t delta;
  data_t tetta      [0 : t4];

  data_t sigma;

  data_t gamma      [0 : t4+1];
  data_t gamma_next [0 : t4+1] ;

  data_t kv;

  typedef data_t gvector_t [0 : t4];

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
    for (int i = 0; i <= t2; i++) begin
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
    for (int i = 0; i < t2; i++) begin
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
    for (int i = 0; i <= t2; i++) begin
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
    int r;
    string str, s;
    //
    forever begin
      oloc_poly_val <= 1'b0;
      @(posedge iclk iff isyndrome_val);
      oloc_poly_ptr       = isyndrome_ptr;
      //
      syndrome[0  : t2-1] = isyndrome[1 : t2];
      eras_root[1 : t2]   = ieras_root;
      eras_root[0]        = 1;
      eras_num            = (ieras_num > check) ? check : ieras_num;
      eras_num2decfail    = ieras_num;
      //
      //
      $sformat(str, "Ribma_eras get syndromes : ");
      for (int i = 0; i < t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      if (pLOG_ON) $display(str);

      $sformat(str, "Ribma_eras eras get %0d erasures : ", eras_num);
      for (int i = 1; i <= t2; i++) begin
        $sformat(s, " %d", eras_root[i]);
        str = {str, s};
      end
      if (pLOG_ON) $display(str);
      //------------------------------------------------------------------------------------------------------
      // count Ã(x)
      //------------------------------------------------------------------------------------------------------
      l_poly = '{0 : 1, default : 0};
      for (r = 1; r <= eras_num; r++) begin
        l_poly_next = l_poly;
        for (int j = 1; j <= r; j++) begin
          l_poly_next[j] = l_poly[j] ^ gf_mul(eras_root[r], l_poly[j-1], INDEX_OF, ALPHA_TO);
        end
        l_poly  = l_poly_next;
      end
      vector_logout("Ribma init l poly ",  l_poly[0 : t2]);
      //------------------------------------------------------------------------------------------------------
      // count OMEGA init value
      //------------------------------------------------------------------------------------------------------
      msyndrome = '{default : 0};
      for (int i = 0; i <= t2-1; i++) begin
        for (int j = 0; j <= eras_num; j++) begin
          data_t temp;
          temp = 0;
          if ((i + eras_num - j) <= t2-1 && (i + eras_num - j) >= 0) begin
            temp = gf_mult_a_by_b(l_poly[j], syndrome[i + eras_num - j]);
//          $display("step %0d == %0d * %0d = %0d", i, l_poly[j], syndrome[i + eras_num - j], temp);
          end
          msyndrome[i] ^= temp; //gf_mult_a_by_b(syndrome[i-j], l_poly[j]);
        end
      end
      evector_logout("Ribma init modify syndrome", msyndrome);
      //------------------------------------------------------------------------------------------------------
      //
      //------------------------------------------------------------------------------------------------------
      //
      //
      gamma             = '{default : 0};
      gamma[0 : t2-1]   = msyndrome[0 : t2-1];
      for (int i = 0; i <= eras_num; i++) begin
        gamma[t4 - i] = l_poly[eras_num - i];
      end

      tetta             = '{default : 0};
      tetta[0   : t2-1] = msyndrome[0 : t2-1];
      for (int i = 0; i <= eras_num; i++) begin
        tetta[t4 - i] = l_poly[eras_num - i];
      end
      gvector_logout  ("Ribma init g poly", gamma [0 : t4]);
      gvector_logout  ("Ribma init t poly", tetta [0 : t4]);
      //
      sigma   = 1;
      kv      = 0;
      //
      for (r = eras_num; r <= t2-1; r += 1) begin
        // step 1
        for (int i = 0; i <= t4; i++) begin
          gamma_next[i] = gf_mult_a_by_b(sigma, gamma[i+1]) ^ gf_mult_a_by_b(gamma[0], tetta[i]);
        end
        // step 2
        if ((gamma[0] != 0) && (kv >= 0)) begin
          tetta [0 : t4] = gamma [1 : t4+1];
          sigma          = gamma[0];
          kv             = -kv - 1;
        end
        else begin
          kv             = kv + 1;
        end

        if (pLOG_ON) $display("Ribma step %0d, delta %0d sigma %0d kv %0d", r, gamma[0], sigma, kv);

        gamma [0 : t4] = gamma_next  [0 : t4];

        gvector_logout  ("Ribma g poly"  ,gamma [0 : t4]);
      end
      // count error value polynome
      l_poly[0 : t2]       = gamma[t2 : t4];
      omega_poly[0 : t2-1] = gamma[0  : t2-1];
      vector_logout ("Ribma l poly ", l_poly[0 : t2]);
      evector_logout("Ribma omega poly ", omega_poly[0 : t2-1]);
      //
      oloc_poly     <= l_poly[0 : t2];
      oomega_poly   <= omega_poly[0 : t2-1];
      oloc_poly_deg <= deg(l_poly);
      oloc_decfail  <= (eras_num2decfail > check);
      oloc_poly_val <= 1'b1;
      @(posedge iclk);
    end
  end
endmodule

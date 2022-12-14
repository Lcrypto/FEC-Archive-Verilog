/*






  logic   rs_eras_berlekamp_beh__iclk                      ;
  logic   rs_eras_berlekamp_beh__ireset                    ;
  logic   rs_eras_berlekamp_beh__isyndrome_val             ;
  ptr_t   rs_eras_berlekamp_beh__isyndrome_ptr             ;
  data_t  rs_eras_berlekamp_beh__isyndrome     [1 : check] ;
  data_t  rs_eras_berlekamp_beh__ieras_root    [1 : check] ;
  data_t  rs_eras_berlekamp_beh__ieras_num                 ;
  logic   rs_eras_berlekamp_beh__oloc_poly_val             ;
  data_t  rs_eras_berlekamp_beh__oloc_poly     [0 : check] ;
  data_t  rs_eras_berlekamp_beh__oomega_poly   [1 : check] ;
  ptr_t   rs_eras_berlekamp_beh__oloc_ptr                  ;
  data_t  rs_eras_berlekamp_beh__oloc_poly_deg             ;
  logic   rs_eras_berlekamp_beh__oloc_decfail              ;



  rs_eras_berlekamp_beh
  rs_eras_berlekamp_beh
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


  assign rs_eras_berlekamp_beh__iclk          = '0 ;
  assign rs_eras_berlekamp_beh__ireset        = '0 ;
  assign rs_eras_berlekamp_beh__isyndrome_val = '0 ;
  assign rs_eras_berlekamp_beh__isyndrome_ptr = '0 ;
  assign rs_eras_berlekamp_beh__isyndrome     = '0 ;
  assign rs_eras_berlekamp_beh__ieras_root    = '0 ;
  assign rs_eras_berlekamp_beh__ieras_num     = '0 ;



*/



module rs_eras_berlekamp_beh
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

  localparam int t3 = check + errs;
  localparam int t2 = check;
  localparam int t  = errs;

  data_t syndrome   [1 : t2];
  data_t eras_root  [0 : t2];
  data_t eras_num           ;
  data_t eras_num2decfail   ;

  data_t l_poly       [0 : t2];
  data_t l_poly_next  [0 : t2];

  data_t b_poly      [-1 : t2];
  data_t b_poly_next  [0 : t2];

  data_t t_poly   [0 : t2];

  data_t omega_poly    [1 : t2];

  data_t L ;

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

  typedef data_t svector_t [1 : t2];

  function void svector_logout (input string is, input svector_t vector);
    string str, s;
  begin
    str = is;
    for (int i = 1; i <= t2; i++) begin
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
  // first time write behaviour model
  //------------------------------------------------------------------------------------------------------

  initial begin : main
    data_t delta;
    string str, s;
    int r;
    //
    forever begin
      oloc_poly_val <= 1'b0;
      @(posedge iclk iff isyndrome_val);
      oloc_poly_ptr     = isyndrome_ptr;
      //
      syndrome          = isyndrome;
      eras_root[1 : t2] = ieras_root;
      eras_root[0]      = 1;
      eras_num          = (ieras_num > check) ? check : ieras_num;
      eras_num2decfail  = ieras_num;
      //
      $sformat(str, "bma get syndromes : ");
      for (int i = 1; i <= t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      if (pLOG_ON) $display(str);
      //
      $sformat(str, "bma get %0d erasures : ", eras_num);
      for (int i = 1; i <= t2; i++) begin
        $sformat(s, " %d", eras_root[i]);
        str = {str, s};
      end
      if (pLOG_ON) $display(str);
      //------------------------------------------------------------------------------------------------------
      // count Ã(x)
      //------------------------------------------------------------------------------------------------------
      l_poly  = '{0 : 1, default : 0};
      b_poly  = '{0 : 1, default : 0};
      L       = 0;

      for (r = 1; r <= eras_num; r++) begin
        l_poly_next = l_poly;
        for (int j = 1; j <= r; j++) begin
//        $display("step {%d, %d} before :: %d * %d", r, j, eras_root[r], l_poly[j-1]);
          l_poly_next[j] = l_poly[j] ^ gf_mul(eras_root[r], l_poly[j-1], INDEX_OF, ALPHA_TO);
//        $display("step {%d, %d} after:: %d", r, j, l_poly_next[j]);
        end
        l_poly = l_poly_next;
        L      = L + 1;
        vector_logout("l poly ",  l_poly[0 : t2]);
      end
      b_poly[0 : t2]  = l_poly[0 : t2];
      vector_logout("bma init l poly ",  l_poly[0 : t2]);
      vector_logout("bma init b poly ",  b_poly[0 : t2]);
      //------------------------------------------------------------------------------------------------------
      // main algorithm
      //------------------------------------------------------------------------------------------------------
      for (r = 1 + eras_num; r <= t2; r += 1) begin
        // step 1
        delta = 0;
        for (int j = 0; j <= L; j++) begin
          delta ^= gf_mul(l_poly[j], syndrome[r-j], INDEX_OF, ALPHA_TO);
//        $display("delta %d :: %d * %d ^ = %d ", j, l_poly[j], syndrome[r-j], delta);
        end
        // step 2
        if (delta == 0) begin
          b_poly_next[0 : t2] = b_poly[-1 : t2-1]; // mult by z
          l_poly_next         = l_poly;
        end
        else begin
          for (int i = 0; i <= t2; i++) begin
            t_poly[i] = l_poly[i] ^ gf_mul(delta, b_poly[i-1], INDEX_OF, ALPHA_TO);
          end
          //
          if ((2*L) <= (eras_num + r-1)) begin // yes
            for (int i = 0; i <= t2; i++) begin
              b_poly_next[i] = gf_div(l_poly[i], delta, INDEX_OF, ALPHA_TO);
            end
            l_poly_next = t_poly;
            L = r + eras_num - L;
          end
          else begin  // no
            l_poly_next         = t_poly;
            b_poly_next[0 : t2] = b_poly[-1 : t2-1]; // mult by z
          end
        end
        l_poly         = l_poly_next;
        b_poly[0 : t2] = b_poly_next;

        if (pLOG_ON) $display("bma step %0d, delta %0d L %0d", r, delta, L);
        vector_logout("bma t poly ",  t_poly);
        vector_logout("bma b poly ",  b_poly[0 : t2]);
        vector_logout("bma l poly ",  l_poly);
      end

      // count error value polynome
      omega_poly = '{default : 0};
      for (int i = 1; i <= t2; i++) begin
        for (int j = 0; j <= i-1; j++) begin
            omega_poly[i] ^= gf_mult_a_by_b(syndrome[i-j], l_poly[j]);
        end
//      vector_logout("omega_poly ", omega_poly);
      end
      vector_logout("bma l poly ",  l_poly);
      svector_logout("bma omega poly ", omega_poly);
      //
      oloc_poly     <= l_poly;
      oomega_poly   <= omega_poly;
      oloc_poly_deg <= deg(l_poly);
      oloc_decfail  <= (deg(l_poly) != L) | (eras_num2decfail > check);
      oloc_poly_val <= 1'b1;

      @(posedge iclk);
    end
  end

endmodule

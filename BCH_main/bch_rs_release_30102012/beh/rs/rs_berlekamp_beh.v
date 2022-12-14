/*






  logic   rs_berlekamp_beh__iclk                      ;
  logic   rs_berlekamp_beh__ireset                    ;
  logic   rs_berlekamp_beh__isyndome_val              ;
  data_t  rs_berlekamp_beh__isyndrome     [1 : check] ;
  logic   rs_berlekamp_beh__oloc_poly_val             ;
  data_t  rs_berlekamp_beh__oloc_poly      [0 : errs] ;
  data_t  rs_berlekamp_beh__oloc_poly_deg             ;
  logic   rs_berlekamp_beh__oloc_decfail              ;



  rs_berlekamp_beh
  rs_berlekamp_beh
  (
    .iclk          ( rs_berlekamp_beh__iclk          ) ,
    .ireset        ( rs_berlekamp_beh__ireset        ) ,
    .isyndome_val  ( rs_berlekamp_beh__isyndome_val  ) ,
    .isyndrome     ( rs_berlekamp_beh__isyndrome     ) ,
    .oloc_poly_val ( rs_berlekamp_beh__oloc_poly_val ) ,
    .oloc_poly     ( rs_berlekamp_beh__oloc_poly     ) ,
    .oloc_poly_deg ( rs_berlekamp_beh__oloc_poly_deg ) ,
    .oloc_decfail  ( rs_berlekamp_beh__oloc_decfail  )
  );


  assign rs_berlekamp_beh__iclk         = '0 ;
  assign rs_berlekamp_beh__ireset       = '0 ;
  assign rs_berlekamp_beh__isyndome_val = '0 ;
  assign rs_berlekamp_beh__isyndrome    = '0 ;



*/



module rs_berlekamp_beh
(
  iclk          ,
  ireset        ,
  isyndome_val  ,
  isyndrome     ,
  oloc_poly_val ,
  oloc_poly     ,
  oomega_poly   ,
  oloc_poly_deg ,
  oloc_failed
);

  `include "rs_parameters.vh"
  `include "rs_functions.vh"

  parameter bit pLOG_ON = 1;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic   iclk                       ;
  input  logic   ireset                     ;
  input  logic   isyndome_val               ;
  input  data_t  isyndrome      [1 : check] ;
  output logic   oloc_poly_val              ;
  output data_t  oloc_poly      [0 : errs]  ;
  output data_t  oomega_poly    [1 : errs]  ;
  output data_t  oloc_poly_deg              ;
  output logic   oloc_failed                ;

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

  data_t l_poly       [0 : t];
  data_t l_poly_next  [0 : t];

  data_t b_poly      [-1 : t];
  data_t b_poly_next  [0 : t];

  data_t t_poly   [0 : t];

  data_t omega_poly    [0 : t];

  data_t L ;

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
    string str, s;
    //
    forever begin
      oloc_poly_val <= 1'b0;
      @(posedge iclk iff isyndome_val);
      syndrome    = isyndrome;
      //
      $sformat(str, "bma get syndromes : ");
      for (int i = 1; i <= t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      if (pLOG_ON) $display(str);
      //
      l_poly  = '{0 : 1, default : 0};
      b_poly  = '{0 : 1, default : 0};
      L       = 0;
      //
      //
      for (int r = 1; r <= t2; r += 1) begin

        // step 1
        delta = 0;
        for (int j = 0; j <= L; j++) begin
          delta ^= gf_mul(l_poly[j], syndrome[r-j], INDEX_OF, ALPHA_TO);
        end
        // step 2
        if (delta == 0) begin
          b_poly_next[0 : t] = b_poly[-1 : t-1]; // mult by x/z
          l_poly_next        = l_poly;
        end
        else begin
          for (int i = 0; i <= t; i++) begin
            t_poly[i] = l_poly[i] ^ gf_mul(delta, b_poly[i-1], INDEX_OF, ALPHA_TO);
          end
          //
          if ((2*L) <= (r-1)) begin // yes
            for (int i = 0; i <= t; i++) begin
              b_poly_next[i] = gf_div(l_poly[i], delta, INDEX_OF, ALPHA_TO);
            end
            l_poly_next = t_poly;
            L = r - L;
          end
          else begin  // no
            l_poly_next         = t_poly;
            b_poly_next[0 : t]  = b_poly[-1 : t-1]; // mult by x/z
          end
        end
        l_poly        = l_poly_next;
        b_poly[0 : t] = b_poly_next;

        if (pLOG_ON) $display("bma step %0d, delta %0d L %0d", r, delta, L);
        vector_logout("bma t poly ",  t_poly);
        vector_logout("bma b poly ",  b_poly[0 : t]);
        vector_logout("bma l poly ",  l_poly);
      end
      // count error value polynome
      omega_poly = '{default : 0};
      for (int i = 1; i <= t; i++) begin
        for (int j = 0; j <= t; j++) begin
          if (i-j >= 1)
            omega_poly[i] ^= gf_mult_a_by_b(syndrome[i-j], l_poly[j]);
        end
      end
      vector_logout("omega_poly ", omega_poly);
      //
      oloc_poly[0]      <= 1;
      oloc_poly[1 : t]  <= l_poly[1 : t];
      oomega_poly       <= omega_poly[1 : t];
      oloc_poly_deg     <= deg(l_poly[0 : t]);
      oloc_failed       <= (deg(l_poly[0 : t]) != L);
      oloc_poly_val     <= 1'b1;

      @(posedge iclk);
    end
  end

endmodule

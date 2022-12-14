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



module bch_berlekamp
(
  iclk          ,
  ireset        ,
  isyndome_val  ,
  isyndrome     ,
  oloc_poly_val ,
  oloc_poly     ,
  oloc_poly_deg ,
  oloc_failed
);

  `include "bch_parameters.vh"
  `include "bch_table.vh"
  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic   iclk                    ;
  input  logic   ireset                  ;
  input  logic   isyndome_val            ;
  input  data_t  isyndrome      [1 : t2] ;
  output logic   oloc_poly_val           ;
  output data_t  oloc_poly      [0 : t]  ;
  output data_t  oloc_poly_deg           ;
  output logic   oloc_failed             ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  data_t syndrome [1 : t2];

  data_t l_poly       [0 : t];
  data_t l_poly_next  [0 : t];

  data_t b_poly      [-2 : t];
  data_t b_poly_next  [0 : t];

  data_t t_poly   [0 : t];

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
    string str, s;
    //
    forever begin
      oloc_poly_val <= 1'b0;
      @(posedge iclk iff isyndome_val);
      syndrome = isyndrome;
      //
      $sformat(str, "true BMA with step +2 get syndromes : ");
      for (int i = 1; i <= t2; i++) begin
        $sformat(s, " %d", syndrome[i]);
        str = {str, s};
      end
      $display(str);
      //
      l_poly  = '{0 : 1, default : 0};
      b_poly  = '{0 : 1, default : 0};
      L       = 0;
      //
      for (int r = 1; r <= t2; r += 2) begin
        // step 1
        delta = 0;
        for (int j = 0; j <= L; j++) begin
          delta ^= ALPHA_TO[mult(INDEX_OF[l_poly[j]], INDEX_OF[syndrome[r-j]])];
        end
        // step 2
        if (delta == 0) begin
          b_poly_next[0 : t] = b_poly[-2 : t-2]; // mult by z^2
          l_poly_next        = l_poly;
        end
        else begin
          for (int i = 0; i <= t; i++) begin
            if (r == 1)
              l_poly_next[i] = l_poly[i] ^ ALPHA_TO[mult(INDEX_OF[delta], INDEX_OF[b_poly[i-1]])];
            else
              l_poly_next[i] = l_poly[i] ^ ALPHA_TO[mult(INDEX_OF[delta], INDEX_OF[b_poly[i-2]])];
          end
          //
          if ((2*L) <= (r-1)) begin // yes
            for (int i = 0; i <= t; i++) begin
              b_poly_next[i] = ALPHA_TO[mult(n - INDEX_OF[delta], INDEX_OF[l_poly[i]])];
            end
            L = r - L;
          end
          else begin  // no
            b_poly_next[0 : t]  = b_poly[-2 : t-2]; // mult by z^2
          end
        end
        l_poly        = l_poly_next;
        b_poly[0 : t] = b_poly_next;

        $display("step %0d, delta %0d L %0d", r, delta, L);
        vector_logout("b poly ",  b_poly[0 : t]);
        vector_logout("l poly ",  l_poly);
      end
      //
      oloc_poly     <= l_poly[0 : t];
      oloc_poly_deg <= deg(l_poly[0 : t]);
      oloc_failed   <= (deg(l_poly[0 : t]) != L);
      oloc_poly_val <= 1'b1;
      @(posedge iclk);
    end
  end

  //------------------------------------------------------------------------------------------------------
  // syndrome register logic
  //------------------------------------------------------------------------------------------------------

/*
  always_ff @(posedge iclk) begin
    if (syndrome_reg_load) begin
      for (int i = 1; i <= t2; i++) begin
        syndrome_reg <= isyndrome[t2 + 1 -i]; // copy at inverted order
      end
    end
    else if (syndrome_reg_shift) begin
      if (syndrome_reg_shift_rigth)
        for (int i = 1; i <= t2; i++) begin

        end
    end

      for (int i = $low(syndrome_reg); i < $high(syndrome_reg); i++)
        syndrome_reg[i] <= isyndrome[t2 - i];
    else if (syndrome_reg_shift) begin
      for (int i = $low(syndrome_reg) + 1; i < $high(syndrome_reg); i++)
        syndrome_reg[i] <= syndrome_reg[i-1];
    end
  end

  //------------------------------------------------------------------------------------------------------
  // delta count logic
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    for (int i = 0; i < t2; i++) begin

    end
  end
*/
endmodule

/*






  logic   bch_chieny_search__iclk                    ;
  logic   bch_chieny_search__ireset                  ;
  logic   bch_chieny_search__iloc_poly_val           ;
  data_t  bch_chieny_search__iloc_poly     [0 : t-1] ;
  data_t  bch_chieny_search__iloc_poly_deg           ;
  logic   bch_chieny_search__oloc_val                ;
  logic   bch_chieny_search__onoroots                ;
  data_t  bch_chieny_search__oloc          [0 : t-1] ;



  bch_chieny_search
  bch_chieny_search
  (
    .iclk          ( bch_chieny_search__iclk          ) ,
    .ireset        ( bch_chieny_search__ireset        ) ,
    .iloc_poly_val ( bch_chieny_search__iloc_poly_val ) ,
    .iloc_poly     ( bch_chieny_search__iloc_poly     ) ,
    .iloc_poly_deg ( bch_chieny_search__iloc_poly_deg ) ,
    .oloc_val      ( bch_chieny_search__oloc_val      ) ,
    .onoroots      ( bch_chieny_search__onoroots      ) ,
    .oloc          ( bch_chieny_search__oloc          )
  );


  assign bch_chieny_search__iclk          = '0 ;
  assign bch_chieny_search__ireset        = '0 ;
  assign bch_chieny_search__iloc_poly_val = '0 ;
  assign bch_chieny_search__iloc_poly     = '0 ;
  assign bch_chieny_search__iloc_poly_deg = '0 ;



*/



module bch_chieny_search_beh
(
  iclk          ,
  ireset        ,
  iloc_poly_val ,
  iloc_poly     ,
  iloc_poly_deg ,
  iloc_failed   ,
  oram_radr     ,
  oram_read     ,
  oram_done     ,
  iram_rdat     ,
  osop          ,
  oval          ,
  oeop          ,
  odat          ,
  decfail       ,
  biterr
);

  `include "bch_parameters.vh"
  `include "bch_table.vh"
  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic           iclk                  ;
  input  logic           ireset                ;
  //
  input  logic           iloc_poly_val         ;
  input  data_t          iloc_poly     [0 : t] ;
  input  logic [m-1 : 0] iloc_poly_deg         ;
  input  logic           iloc_failed           ;
  // ram interface
  output logic [m-1 : 0] oram_radr             ;
  output logic           oram_read             ;
  output logic           oram_done             ;
  input  data_t          iram_rdat             ;
  // output interface
  output logic           osop                  ;
  output logic           oval                  ;
  output logic           oeop                  ;
  output logic           odat                  ;
  output logic           decfail               ;
  output logic [m-1 : 0] biterr                ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic   mult__iload         ;
  logic   mult__iena          ;
  data_t  mult__idat  [1 : t] ;
  logic   mult__oena  [1 : t] ;
  data_t  mult__odat  [1 : t] ;

  //
  // "FSM"
  logic [m-1 : 0] cnt;
  logic           search_ena;
  logic   [3 : 0] search_ena_reg;
  logic   [3 : 0] search_start;
  logic   [3 : 0] search_end;

  data_t           poly_value;
  data_t           poly_value_next;
  logic            poly_value_is_zero;

  logic [m-1 : 0]  loc_poly_deg_latched;
  logic            loc_failed_latched;

  logic [m-1 : 0]  root_cnt;

  logic dat_fixed;
  logic ram_rdata;


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

  //------------------------------------------------------------------------------------------------------
  // static multiplyers
  //------------------------------------------------------------------------------------------------------

  initial begin : main
    forever begin
      @(posedge iclk iff iloc_poly_val);
      // initialization
      for (int j = 1; j < t; j++) begin
        mult__odat = iloc_poly[1 : t];
      end
      vector_logout("get locator", iloc_poly);
      /*
      for (int i = 1; i <= n; i++) begin
        // start to count
        poly_value = iloc_poly[0];
        for (int j = 1; j <= t; j++) begin
          mult__odat[j] = ALPHA_TO[mult(INDEX_OF[mult__odat[j]], j)]; // alpha^j
          poly_value ^= mult__odat[j];
        end
        poly_value_is_zero = (poly_value == 0);
        //
        if (poly_value_is_zero) begin
          $display("found root at position = %0d, %p", n-i, mult__odat);
        end
      end
      */
      for (int j = 1; j < t; j++) begin
        mult__odat[j] = ALPHA_TO[mult(INDEX_OF[mult__odat[j]], j*(n-block_n-0))]; // alpha^j
      end
      $display("chieny start position %p", mult__odat);
      for (int i = (n - block_n + 1); i <= n; i++) begin
        // start to count
        poly_value = iloc_poly[0];
        for (int j = 1; j <= t; j++) begin
          mult__odat[j] = ALPHA_TO[mult(INDEX_OF[mult__odat[j]], j)]; // alpha^j
          poly_value ^= mult__odat[j];
        end
        poly_value_is_zero = (poly_value == 0);
        //
        if (poly_value_is_zero) begin
          $display("found root at position = %0d, %p", n-i, mult__odat);
        end
//      $display("chieny position %p", mult__odat);
      end

    end
  end

endmodule

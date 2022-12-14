/*



  parameter int pALPHA_IDX  = 1 ;



  logic   bch_syndrome_count_mult_beh__iclk       ;
  logic   bch_syndrome_count_mult_beh__ireset     ;
  logic   bch_syndrome_count_mult_beh__isop       ;
  logic   bch_syndrome_count_mult_beh__ival       ;
  logic   bch_syndrome_count_mult_beh__ieop       ;
  logic   bch_syndrome_count_mult_beh__idat       ;
  data_t  bch_syndrome_count_mult_beh__osyndrome  ;



  bch_syndrome_count_mult_beh
  #(
    .pALPHA_IDX ( pALPHA_IDX )
  )
  bch_syndrome_count_mult_beh
  (
    .iclk          ( bch_syndrome_count_mult_beh__iclk          ) ,
    .ireset        ( bch_syndrome_count_mult_beh__ireset        ) ,
    .isop          ( bch_syndrome_count_mult_beh__isop          ) ,
    .ival          ( bch_syndrome_count_mult_beh__ival          ) ,
    .ieop          ( bch_syndrome_count_mult_beh__ieop          ) ,
    .idat          ( bch_syndrome_count_mult_beh__idat          ) ,
    .osyndrome_val ( bch_syndrome_count_mult_beh__osyndrome_val ) ,
    .osyndrome     ( bch_syndrome_count_mult_beh__osyndrome     )
  );


  assign bch_syndrome_count_mult_beh__iclk   = '0 ;
  assign bch_syndrome_count_mult_beh__ireset = '0 ;
  assign bch_syndrome_count_mult_beh__isop   = '0 ;
  assign bch_syndrome_count_mult_beh__ival   = '0 ;
  assign bch_syndrome_count_mult_beh__ieop   = '0 ;
  assign bch_syndrome_count_mult_beh__idat   = '0 ;



*/



module bch_syndrome_count_mult_beh
#(
  parameter int pALPHA_IDX  = 1 // index of primitive GF element a^pALPHA_IDX
)
(
  iclk          ,
  ireset        ,
  isop          ,
  ival          ,
  ieop          ,
  idat          ,
  osyndrome_val ,
  osyndrome
);

  `include "bch_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic   iclk          ;
  input  logic   ireset        ;
  input  logic   isop          ;
  input  logic   ival          ;
  input  logic   ieop          ;
  input  logic   idat          ;
  output logic   osyndrome_val ;
  output data_t  osyndrome     ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [2 : 0] sop;
  logic [2 : 0] val;
  logic [2 : 0] eop;
  logic [2 : 0] dat;

  data_p1_t alpha_idx;
  data_p1_t alpha_idx_mod;

  data_t alpha2syndrome;
  data_t syndrome;

  `include "bch_table.vh"
  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  initial begin : ini
    sop <= '0;
    val <= '0;
    eop <= '0;
    dat <= '0;
    alpha_idx       <= '0;
    alpha_idx_mod   <= '0;
    alpha2syndrome  <= '0;
    syndrome        <= '0;
  end
  // synthesis translate_on
  //------------------------------------------------------------------------------------------------------
  // index -> index_mod -> alpha_to -> syndrome
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      sop <= '0;
      val <= '0;
      eop <= '0;
      dat <= '0;
      //
      osyndrome_val <= '0;
    end
    else begin
      sop <= (sop << 1) | isop;
      val <= (val << 1) | ival;
      eop <= (eop << 1) | ieop;
      dat <= (dat << 1) | idat;
      //
      osyndrome_val <= val[1] & eop[1];
    end
  end

  always_ff @(posedge iclk) begin
    //
    if (val[0]) begin
      if (sop[0])
        syndrome <= dat[0];
      else
        syndrome <= {{{m-1}{1'b0}}, dat[0]} ^ ALPHA_TO[mult(INDEX_OF[syndrome], pALPHA_IDX)];
    end
    if (val[1])
      osyndrome <= syndrome;
  end

endmodule

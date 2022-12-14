/*



  parameter int pLLR_W     = 5 ;
  parameter int pLLR_FP    = 3 ;
  parameter int pMMAX_TYPE = 0 ;



  logic              rsc2_dec_Lextr__iclk      ;
  logic              rsc2_dec_Lextr__ireset    ;
  logic              rsc2_dec_Lextr__iclkena   ;
  logic              rsc2_dec_Lextr__ival      ;
  logic              rsc2_dec_Lextr__ibitswap  ;
  logic      [1 : 0] rsc2_dec_Lextr__idat      ;
  Lapri_t            rsc2_dec_Lextr__iLapri    ;
  Lapo_t             rsc2_dec_Lextr__iLapo     ;
  logic              rsc2_dec_Lextr__oval      ;
  Lextr_t            rsc2_dec_Lextr__oLextr    ;
  logic      [1 : 0] rsc2_dec_Lextr__odat      ;
  logic      [1 : 0] rsc2_dec_Lextr__oerr      ;



  rsc2_dec_Lextr
  #(
    .pLLR_W     ( pLLR_W     ) ,
    .pLLR_FP    ( pLLR_FP    ) ,
    .pMMAX_TYPE ( pMMAX_TYPE )
  )
  rsc2_dec_Lextr
  (
    .iclk     ( rsc2_dec_Lextr__iclk     ) ,
    .ireset   ( rsc2_dec_Lextr__ireset   ) ,
    .iclkena  ( rsc2_dec_Lextr__iclkena  ) ,
    .ival     ( rsc2_dec_Lextr__ival     ) ,
    .ibitswap ( rsc2_dec_Lextr__ibitswap ) ,
    .idat     ( rsc2_dec_Lextr__idat     ) ,
    .iLapri   ( rsc2_dec_Lextr__iLapri   ) ,
    .iLapo    ( rsc2_dec_Lextr__iLapo    ) ,
    .oval     ( rsc2_dec_Lextr__oval     ) ,
    .oLextr   ( rsc2_dec_Lextr__oLextr   ) ,
    .odat     ( rsc2_dec_Lextr__odat     ) ,
    .oerr     ( rsc2_dec_Lextr__oerr     )
  );


  assign rsc2_dec_Lextr__iclk     = '0 ;
  assign rsc2_dec_Lextr__ireset   = '0 ;
  assign rsc2_dec_Lextr__iclkena  = '0 ;
  assign rsc2_dec_Lextr__ival     = '0 ;
  assign rsc2_dec_Lextr__ibitswap = '0 ;
  assign rsc2_dec_Lextr__idat     = '0 ;
  assign rsc2_dec_Lextr__iLapri   = '0 ;
  assign rsc2_dec_Lextr__iLapo    = '0 ;



*/

//
// Project       : rsc2
// Author        : Shekhalev Denis (des00)
// Workfile      : rsc2_dec_Lextr.v
// Description   : module to count sub iteration results : Lextr, bit pairs and estimated corrected errror.
//                 Module latency is 2 tick.
//

module rsc2_dec_Lextr
#(
  parameter int pLLR_W      = 5 ,
  parameter int pLLR_FP     = 3 ,
  parameter int pMMAX_TYPE  = 0
)
(
  iclk     ,
  ireset   ,
  iclkena  ,
  //
  ival     ,
  ibitswap ,
  idat     ,
  iLapri   ,
  iLapo    ,
  //
  oval     ,
  oLextr   ,
  odat     ,
  oerr
);

  `include "rsc2_dec_types.vh"
  `include "rsc2_trellis.vh"
  `include "rsc2_mmax.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic              iclk      ;
  input  logic              ireset    ;
  input  logic              iclkena   ;
  //
  input  logic              ival      ;
  input  logic              ibitswap  ;
  input  logic      [1 : 0] idat      ;
  input  Lapri_t            iLapri    ;
  input  Lapo_t             iLapo     ;
  //
  output logic              oval      ;
  output Lextr_t            oLextr    ;
  output logic      [1 : 0] odat      ;
  output logic      [1 : 0] oerr      ;

  //------------------------------------------------------------------------------------------------------
  // reverse pair permutation
  //------------------------------------------------------------------------------------------------------

  Lapri_t ind ;
  Lapo_t  outd;

  assign ind[1]   = ibitswap ? iLapri [2] : iLapri[1] ;
  assign ind[2]   = ibitswap ? iLapri [1] : iLapri[2] ;
  assign ind[3]   =                         iLapri[3] ;

  assign outd[1]  = ibitswap ? iLapo  [2] : iLapo [1] ;
  assign outd[2]  = ibitswap ? iLapo  [1] : iLapo [2] ;
  assign outd[3]  =                         iLapo [3] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [1 : 0] val;

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      val <= '0;
    else if (iclkena)
      val <= (val << 1) | ival;
  end

  //------------------------------------------------------------------------------------------------------
  // Lext
  //------------------------------------------------------------------------------------------------------

  Lapo_t Lext;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival) begin
        for (int i = 1; i < 4; i++) begin
          Lext[i] <= outd[i] - ind[i];
        end
      end // ival
    end // iclk
  end

  Lapo_t  Lext_scale;
  logic   Lext_scale_sign [1:3];
  logic   Lext_scale_ovf  [1:3];
  Lextr_t Lext_scale_ovf_value;

  always_comb begin
    for (int i = 1; i < 4; i++) begin
      Lext_scale          [i] = Lext[i] - (Lext[i] >>> 2); // 0.75
      //
      Lext_scale_sign     [i] = Lext_scale[i][cGAMMA_W-1];
      Lext_scale_ovf      [i] = Lext_scale_sign[i] ? !(&Lext_scale[i][cGAMMA_W-1 : cL_EXT_W-1]) :
                                                      (|Lext_scale[i][cGAMMA_W-1 : cL_EXT_W-1]) ;

      Lext_scale_ovf_value[i] = {Lext_scale_sign[i], ~{{cL_EXT_W-2}{Lext_scale_sign[i]}}, 1'b1};
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (val[0]) begin
        for (int i = 1; i < 4; i++) begin
          oLextr[i] <= Lext_scale_ovf[i] ? Lext_scale_ovf_value[i] : (Lext_scale[i][cL_EXT_W-1:0] + Lext_scale_sign[i]);
        end
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // odat
  //------------------------------------------------------------------------------------------------------

  trel_branch_t tmp10, tmp11, tmp1;
  trel_branch_t tmp00, tmp01, tmp0;

  logic [1 : 0] dat, tdat;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival) begin
        dat <= idat;
        if (pMMAX_TYPE == 1) begin
          // b1 - LLR(11), LLR(10) vs LLR(01), LLR(00)
          tmp10 <= bm_mmax1(outd[3], outd[2]);
          tmp11 <= bm_mmax1(outd[1], 0);
          // b0 - LLR(11), LLR(01) vs LLR(10), LLR(00)
          tmp00 <= bm_mmax1(outd[3], outd[1]);
          tmp01 <= bm_mmax1(outd[2], 0);
        end
        else begin
          // b1 - LLR(11), LLR(10) vs LLR(01), LLR(00)
          tmp10 <= bm_mmax(outd[3], outd[2]);
          tmp11 <= bm_mmax(outd[1], 0);
          // b0 - LLR(11), LLR(01) vs LLR(10), LLR(00)
          tmp00 <= bm_mmax(outd[3], outd[1]);
          tmp01 <= bm_mmax(outd[2], 0);
        end
      end
      if (val[0]) begin
        tdat  <= dat;
        tmp1  <= tmp10 - tmp11;
        tmp0  <= tmp00 - tmp01;
      end
    end
  end

  assign odat = ~{tmp1[$high(tmp1)], tmp0[$high(tmp0)]};
  assign oerr = odat ^ tdat;
  assign oval = val[1];

endmodule

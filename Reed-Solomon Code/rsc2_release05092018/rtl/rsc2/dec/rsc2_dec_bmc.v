/*



  parameter int pLLR_W   = 5 ;
  parameter int pLLR_FP  = 3 ;



  logic               rsc2_dec_bmc__iclk             ;
  logic               rsc2_dec_bmc__ireset           ;
  logic               rsc2_dec_bmc__iclkena          ;
  logic               rsc2_dec_bmc__ival             ;
  logic               rsc2_dec_bmc__ieven            ;
  logic               rsc2_dec_bmc__ibitswap         ;
  logic               rsc2_dec_bmc__iLextr_clr       ;
  bit_llr_t           rsc2_dec_bmc__isLLR    [0 : 1] ;
  bit_llr_t           rsc2_dec_bmc__iyLLR    [0 : 1] ;
  bit_llr_t           rsc2_dec_bmc__iwLLR    [0 : 1] ;
  Lextr_t             rsc2_dec_bmc__iLextr           ;
  logic               rsc2_dec_bmc__oval             ;
  gamma_t             rsc2_dec_bmc__ogamma           ;
  Lapri_t             rsc2_dec_bmc__oLapri           ;
  logic       [1 : 0] rsc2_dec_bmc__ohd              ;
  logic               rsc2_dec_bmc__ila_norm         ;



  rsc2_dec_bmc
  #(
    .pLLR_W  ( pLLR_W  ) ,
    .pLLR_FP ( pLLR_FP )
  )
  rsc2_dec_bmc
  (
    .iclk       ( rsc2_dec_bmc__iclk       ) ,
    .ireset     ( rsc2_dec_bmc__ireset     ) ,
    .iclkena    ( rsc2_dec_bmc__iclkena    ) ,
    .ival       ( rsc2_dec_bmc__ival       ) ,
    .ieven      ( rsc2_dec_bmc__ieven      ) ,
    .ibitswap   ( rsc2_dec_bmc__ibitswap   ) ,
    .iLextr_clr ( rsc2_dec_bmc__iLextr_clr ) ,
    .isLLR      ( rsc2_dec_bmc__isLLR      ) ,
    .iyLLR      ( rsc2_dec_bmc__iyLLR      ) ,
    .iwLLR      ( rsc2_dec_bmc__iwLLR      ) ,
    .iLextr     ( rsc2_dec_bmc__iLextr     ) ,
    .oval       ( rsc2_dec_bmc__oval       ) ,
    .ogamma     ( rsc2_dec_bmc__ogamma     ) ,
    .oLapri     ( rsc2_dec_bmc__oLapri     ) ,
    .ohd        ( rsc2_dec_bmc__ohd        ) ,
    .ila_norm   ( rsc2_dec_bmc__ila_norm   )
  );


  assign rsc2_dec_bmc__iclk       = '0 ;
  assign rsc2_dec_bmc__ireset     = '0 ;
  assign rsc2_dec_bmc__iclkena    = '0 ;
  assign rsc2_dec_bmc__ival       = '0 ;
  assign rsc2_dec_bmc__ieven      = '0 ;
  assign rsc2_dec_bmc__ibitswap   = '0 ;
  assign rsc2_dec_bmc__iLextr_clr = '0 ;
  assign rsc2_dec_bmc__isLLR      = '0 ;
  assign rsc2_dec_bmc__iyLLR      = '0 ;
  assign rsc2_dec_bmc__iwLLR      = '0 ;
  assign rsc2_dec_bmc__iLextr     = '0 ;
  assgin rsc2_dec_bmc__ila_norm   = '0 ;



*/

//
// Project       : rsc2
// Author        : Shekhalev Denis (des00)
// Workfile      : rsc2_dec_bmc.v
// Description   : data/parity duobit LLR & branch metric LLR calculator with look ahead normalization
//

module rsc2_dec_bmc
#(
  parameter int pLLR_W   = 5 ,
  parameter int pLLR_FP  = 3
)
(
  iclk       ,
  ireset     ,
  iclkena    ,
  //
  ival       ,
  ieven      ,
  ibitswap   ,
  iLextr_clr ,
  isLLR      ,
  iyLLR      ,
  iwLLR      ,
  iLextr     ,
  //
  oval       ,
  ogamma     ,
  oLapri     ,
  ohd        ,
  //
  ila_norm
);

  `include "rsc2_dec_types.vh"
  `include "rsc2_trellis.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic             iclk             ;
  input  logic             ireset           ;
  input  logic             iclkena          ;
  //
  input  logic             ival             ;
  input  logic             ieven            ; // 1/0 - no permutate(even)/permutate (odd)
  input  logic             ibitswap         ; // swap systematic duobit pair for permutation
  input  logic             iLextr_clr       ; // clear extrinsic info (first half iteration)
  //
  input  bit_llr_t         isLLR    [0 : 1] ; // systematic bit LLR
  input  bit_llr_t         iyLLR    [0 : 1] ; // parity y-bit LLR
  input  bit_llr_t         iwLLR    [0 : 1] ; // parity w-bit LLR
  input  Lextr_t           iLextr           ; // apriory extrinsic info
  //
  output logic             oval             ;
  output gamma_t           ogamma           ; // transition metric
  output Lapri_t           oLapri           ; // data apriory duobit LLR
  output logic     [1 : 0] ohd              ; // systematic hard decision
  //
  input  logic             ila_norm         ; // look ahead normalization

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [2 : 0] val;

  dbit_allr_t   dLLR;
  dbit_allr_t   pLLR;

  Lextr_t       Lextr;

  Lapri_t       Lapri;

  logic [1 : 0] hd;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      val <= '0;
    end
    else if (iclkena) begin
      val <= (val << 1) | ival;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // get systematic duobits and prepare parity & Lext
  //------------------------------------------------------------------------------------------------------

  wire bitswap = !ieven & ibitswap;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival) begin
        // systematic bits & extrinsic
        if (iLextr_clr) begin
          Lextr[1] <= '0;
          Lextr[2] <= '0;
          Lextr[3] <= '0;
        end
        else begin
          Lextr[1] <= bitswap ? iLextr[2] : iLextr[1];
          Lextr[2] <= bitswap ? iLextr[1] : iLextr[2];
          Lextr[3] <=                       iLextr[3];
        end

        dLLR[1] <= bitswap ? get_duobit_LLR(isLLR[1], isLLR[0], 2) : get_duobit_LLR(isLLR[1], isLLR[0], 1);
        dLLR[2] <= bitswap ? get_duobit_LLR(isLLR[1], isLLR[0], 1) : get_duobit_LLR(isLLR[1], isLLR[0], 2);
        dLLR[3] <=                                                   get_duobit_LLR(isLLR[1], isLLR[0], 3);
        // hard decicion
        hd      <= ~{isLLR[1][pLLR_W-1], isLLR[0][pLLR_W-1]};

        // parity bits
        pLLR [1] <= ieven ? get_duobit_LLR(iyLLR[1], iwLLR[1], 1) : get_duobit_LLR(iyLLR[0], iwLLR[0], 1);
        pLLR [2] <= ieven ? get_duobit_LLR(iyLLR[1], iwLLR[1], 2) : get_duobit_LLR(iyLLR[0], iwLLR[0], 2);
        pLLR [3] <= ieven ? get_duobit_LLR(iyLLR[1], iwLLR[1], 3) : get_duobit_LLR(iyLLR[0], iwLLR[0], 3);
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // get transition metric
  //------------------------------------------------------------------------------------------------------

  always_comb begin
    for (int i = 1; i < 4; i++) begin
      Lapri [i] = dLLR[i] + Lextr[i];
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (val[0]) begin
        ogamma  <= get_gamma(Lapri, pLLR, ila_norm);
        oLapri  <= Lapri;
        ohd     <= hd;
      end
    end
  end

  assign oval = val[1];

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  // function to get duobit LLR.
  //    b1/b0 - LLR of bits
  //    t   - 2'b01/2'b10/2'b11 duobit type
  function automatic dbit_llr_t get_duobit_LLR (input bit_llr_t b1, b0, input int t);
    case (t)
      2'b01   : return b0;
      2'b10   : return b1;
      2'b11   : return b1 + b0;
      default : return 0;
    endcase
  endfunction

  //
  // function to get branch metric
  function automatic gamma_t get_gamma (input Lapri_t ind, input dbit_allr_t inp, input bit norm);
    int outb;
    trel_state_t sub;
  begin
    sub = norm ? (1'b1 << (cSTATE_W-3)) : '0; // 1/2 of norm value inside rsc2_dec_rp module
    //
    for (int state = 0; state < 16; state++) begin
      for (int inb = 0; inb < 4; inb++) begin
        outb = trel.outputs[state][inb];
        // systematic + parity bits
        if (inb == 0)
          get_gamma[state][inb] = ((outb == 0) ? 0 : inp[outb]) - sub;
        else if (outb == 0)
          get_gamma[state][inb] = ind[inb] - sub;
        else
          get_gamma[state][inb] = ind[inb] + inp[outb] - sub;
      end
    end
  end
  endfunction

endmodule

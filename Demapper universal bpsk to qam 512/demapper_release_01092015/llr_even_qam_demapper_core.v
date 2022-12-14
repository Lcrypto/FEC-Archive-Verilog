/*



  parameter int pDAT_W  = 8 ;
  parameter int pLLR_W  = 4 ;



  logic                       llr_even_qam_demapper_core__iclk            ;
  logic                       llr_even_qam_demapper_core__ireset          ;
  logic                       llr_even_qam_demapper_core__iclkena         ;
  logic                       llr_even_qam_demapper_core__ival            ;
  logic                       llr_even_qam_demapper_core__isop            ;
  logic               [3 : 0] llr_even_qam_demapper_core__iqam            ;
  logic signed [pDAT_W-1 : 0] llr_even_qam_demapper_core__idat            ;
  logic                       llr_even_qam_demapper_core__oval            ;
  logic                       llr_even_qam_demapper_core__osop            ;
  logic               [3 : 0] llr_even_qam_demapper_core__oqam            ;
  logic signed [pLLR_W-1 : 0] llr_even_qam_demapper_core__oLLR    [0 : 4] ;



  llr_even_qam_demapper_core
  #(
    .pDAT_W ( pDAT_W ) ,
    .pLLR_W ( pLLR_W )
  )
  llr_even_qam_demapper_core
  (
    .iclk    ( llr_even_qam_demapper_core__iclk    ) ,
    .ireset  ( llr_even_qam_demapper_core__ireset  ) ,
    .iclkena ( llr_even_qam_demapper_core__iclkena ) ,
    .ival    ( llr_even_qam_demapper_core__ival    ) ,
    .isop    ( llr_even_qam_demapper_core__isop    ) ,
    .iqam    ( llr_even_qam_demapper_core__iqam    ) ,
    .idat    ( llr_even_qam_demapper_core__idat    ) ,
    .oval    ( llr_even_qam_demapper_core__oval    ) ,
    .osop    ( llr_even_qam_demapper_core__osop    ) ,
    .oqam    ( llr_even_qam_demapper_core__oqam    ) ,
    .oLLR    ( llr_even_qam_demapper_core__oLLR    )
  );


  assign llr_even_qam_demapper_core__iclk    = '0 ;
  assign llr_even_qam_demapper_core__ireset  = '0 ;
  assign llr_even_qam_demapper_core__iclkena = '0 ;
  assign llr_even_qam_demapper_core__ival    = '0 ;
  assign llr_even_qam_demapper_core__isop    = '0 ;
  assign llr_even_qam_demapper_core__iqam    = '0 ;
  assign llr_even_qam_demapper_core__idat    = '0 ;



*/

//------------------------------------------------------------------------------------------------------
// even QAM : QPSK, QAM16, QAM64, QAM256, QAM1024 LLR demapper
// Module work with LSB first endian. Module delay is 5 tick.
//------------------------------------------------------------------------------------------------------

module llr_even_qam_demapper_core
#(
  parameter int pDAT_W  = 8 , // must be pLLR_W + (bits_per_symbol/2-1)
  parameter int pLLR_W  = 4   //
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  ival    ,
  isop    ,
  iqam    ,
  idat    ,
  //
  oval    ,
  osop    ,
  oqam    ,
  oLLR
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                       iclk            ;
  input  logic                       ireset          ;
  input  logic                       iclkena         ;
  //
  input  logic                       ival            ;
  input  logic                       isop            ;
  input  logic               [3 : 0] iqam            ;
  input  logic signed [pDAT_W-1 : 0] idat            ;
  //
  output logic                       oval            ;
  output logic                       osop            ;
  output logic               [3 : 0] oqam            ;
  output logic signed [pLLR_W-1 : 0] oLLR    [0 : 4] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  typedef logic signed [pDAT_W-1 : 0] this_t;

  localparam this_t cEDGE_4 = 2**(pLLR_W-1);
  localparam this_t cEDGE_3 = 2*cEDGE_4;
  localparam this_t cEDGE_2 = 2*cEDGE_3;
  localparam this_t cEDGE_1 = 2*cEDGE_2;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [3 : 0] sop;
  logic [3 : 0] val;
  logic [3 : 0] qam [4];

  this_t        bit0_llr [0 : 3];
  this_t        bit1_llr [0 : 3];
  this_t        bit2_llr [1 : 3];
  this_t        bit3_llr [2 : 3];
  this_t        bit4_llr [3 : 3];

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      sop <= (sop << 1) | isop;
      qam[0] <= iqam;
      for (int i = 1; i < 4; i++) begin
        qam[i] <= qam[i-1];
      end
      // stage 0
      bit0_llr[0] <= (iqam <= 2) ? (idat >>> 1) : (idat);
      bit1_llr[0] <= sub_abs(cEDGE_1, idat);
      // stage 1
      bit0_llr[1] <= (qam[0] <= 4) ? (bit0_llr[0] >>> 1) : bit0_llr[0];
      bit1_llr[1] <= (qam[0] <= 4) ? (bit1_llr[0] >>> 1) : bit1_llr[0];
      bit2_llr[1] <= sub_abs(cEDGE_2, bit1_llr[0]);
      // stage 2
      bit0_llr[2] <= (qam[1] <= 6) ? (bit0_llr[1] >>> 1) : bit0_llr[1];
      bit1_llr[2] <= (qam[1] <= 6) ? (bit1_llr[1] >>> 1) : bit1_llr[1];
      bit2_llr[2] <= (qam[1] <= 6) ? (bit2_llr[1] >>> 1) : bit2_llr[1];
      bit3_llr[2] <= sub_abs(cEDGE_3, bit2_llr[1]);
      // stage 3
      bit0_llr[3] <= (qam[2] <= 8) ? (bit0_llr[2] >>> 1) : bit0_llr[2];
      bit1_llr[3] <= (qam[2] <= 8) ? (bit1_llr[2] >>> 1) : bit1_llr[2];
      bit2_llr[3] <= (qam[2] <= 8) ? (bit2_llr[2] >>> 1) : bit2_llr[2];
      bit3_llr[3] <= (qam[2] <= 8) ? (bit3_llr[2] >>> 1) : bit3_llr[2];
      bit4_llr[3] <= sub_abs(cEDGE_4, bit3_llr[2]);
    end
  end

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      val   <= '0;
      oval  <= 1'b0;
    end
    else if (iclkena) begin
      val   <= (val << 1) | ival;
      oval  <= val[3];
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (val[3]) begin
        osop    <= sop[3];
        oqam    <= qam[3];
        oLLR[0] <= saturate(bit0_llr[3]);
        oLLR[1] <= saturate(bit1_llr[3]);
        oLLR[2] <= saturate(bit2_llr[3]);
        oLLR[3] <= saturate(bit3_llr[3]);
        oLLR[4] <= saturate(bit4_llr[3]);
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // function to count internale metrics :
  //  result = level - abs(dat) --> sign ? (cE + dat) : (cE - dat)
  //------------------------------------------------------------------------------------------------------

  function automatic this_t sub_abs (input this_t level, input this_t dat);
    logic sign;
  begin
    sign    = dat[pDAT_W-1];
    sub_abs = (sign ? level : (level+1)) + (dat ^ {pDAT_W{!sign}});
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  // function to saturate metrics :
  //  result = (dat > cMAX_POS) ? cMAX_POS : ((dat < cMIN_NEG) ? cMIN_NEG : dat);
  //------------------------------------------------------------------------------------------------------

  localparam this_t cMAX_POS =  cEDGE_4-1;
  localparam this_t cMIN_NEG = -cEDGE_4;

  function automatic logic signed [pLLR_W-1 : 0] saturate (input this_t dat);
    logic poverflow;
    logic noverflow;
  begin
    poverflow = (dat > cMAX_POS);
    noverflow = (dat < cMIN_NEG);
//  poverflow = !dat[pDAT_W-1] & ( dat[pDAT_W-2 : pLLR_W-1] != 0);
//  noverflow =  dat[pDAT_W-1] & (~dat[pDAT_W-2 : pLLR_W-1] != 0);
    //
    if (poverflow | noverflow)
      saturate = poverflow ? cMAX_POS[pLLR_W-1 : 0] : cMIN_NEG[pLLR_W-1 : 0];
    else
      saturate = dat[pLLR_W-1 : 0];
  end
  endfunction

endmodule

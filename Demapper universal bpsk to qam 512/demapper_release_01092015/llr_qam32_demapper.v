/*



  parameter int pDAT_W  = 8 ;
  parameter int pLLR_W  = 4 ;



  logic                       llr_qam32_demapper__iclk            ;
  logic                       llr_qam32_demapper__ireset          ;
  logic                       llr_qam32_demapper__iclkena         ;
  logic                       llr_qam32_demapper__ival            ;
  logic                       llr_qam32_demapper__isop            ;
  logic               [3 : 0] llr_qam32_demapper__iqam            ;
  logic signed [pDAT_W-1 : 0] llr_qam32_demapper__idat_re         ;
  logic signed [pDAT_W-1 : 0] llr_qam32_demapper__idat_im         ;
  logic                       llr_qam32_demapper__oval            ;
  logic                       llr_qam32_demapper__osop            ;
  logic               [3 : 0] llr_qam32_demapper__oqam            ;
  logic signed [pLLR_W-1 : 0] llr_qam32_demapper__oLLR    [0 : 4] ;



  llr_qam32_demapper
  #(
    .pDAT_W ( pDAT_W ) ,
    .pLLR_W ( pLLR_W )
  )
  llr_qam32_demapper
  (
    .iclk    ( llr_qam32_demapper__iclk    ) ,
    .ireset  ( llr_qam32_demapper__ireset  ) ,
    .iclkena ( llr_qam32_demapper__iclkena ) ,
    .ival    ( llr_qam32_demapper__ival    ) ,
    .isop    ( llr_qam32_demapper__isop    ) ,
    .iqam    ( llr_qam32_demapper__iqam    ) ,
    .idat_re ( llr_qam32_demapper__idat_re ) ,
    .idat_im ( llr_qam32_demapper__idat_im ) ,
    .oval    ( llr_qam32_demapper__oval    ) ,
    .osop    ( llr_qam32_demapper__osop    ) ,
    .oqam    ( llr_qam32_demapper__oqam    ) ,
    .oLLR    ( llr_qam32_demapper__oLLR    )
  );


  assign llr_qam32_demapper__iclk    = '0 ;
  assign llr_qam32_demapper__ireset  = '0 ;
  assign llr_qam32_demapper__iclkena = '0 ;
  assign llr_qam32_demapper__ival    = '0 ;
  assign llr_qam32_demapper__isop    = '0 ;
  assign llr_qam32_demapper__iqam    = '0 ;
  assign llr_qam32_demapper__idat_re = '0 ;
  assign llr_qam32_demapper__idat_im = '0 ;



*/



module llr_qam32_demapper
#(
  parameter int pDAT_W  = 6 , // fixed, don't change
  parameter int pLLR_W  = 4   // fixed, don't change
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  ival    ,
  isop    ,
  iqam    ,
  idat_re ,
  idat_im ,
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
  input  logic signed [pDAT_W-1 : 0] idat_re         ;
  input  logic signed [pDAT_W-1 : 0] idat_im         ;
  //
  output logic                       oval            ;
  output logic                       osop            ;
  output logic               [3 : 0] oqam            ;
  output logic signed [pLLR_W-1 : 0] oLLR    [0 : 4] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  typedef logic signed [pDAT_W-1 : 0] this_t;

  localparam this_t cONE      =  2**(pLLR_W-2);

  localparam this_t cEDGE_POS =  6*cONE-1;
  localparam this_t cEDGE_NEG = -6*cONE+1;  // it's pointers, not data

  localparam this_t cMAX_POS  =  2*cONE-1;
`ifdef MODEL_TECH
  localparam this_t cMIN_NEG  = -2*cONE+1;
`else
  localparam this_t cMIN_NEG  = -2*cONE;    // can do so, it's data
`endif

  //------------------------------------------------------------------------------------------------------
  // QAM32 complex bit partial tables
  //------------------------------------------------------------------------------------------------------

  localparam this_t cQAM32_BIT4_LLR[24][24] =
  '{
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -5, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -4, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -3, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -2, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1,  0,  1,  2,  3,  4,  5,  6,  7},
    '{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  0,  0,  1,  2,  3,  4,  5,  6,  7},
    '{ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  2,  3,  4,  5,  6,  7},
    '{ 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  3,  4,  5,  6,  7},
    '{ 2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  4,  5,  6,  7},
    '{ 3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  4,  4,  5,  6,  7},
    '{ 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  5,  5,  6,  7},
    '{ 5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  6,  6,  7},
    '{ 6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  7,  7},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7}
  };

  localparam this_t cQAM32_BIT2_LLR[24][24] =
  '{
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7,  7,  7,  7,  7,  7,  7,  7,  7},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7,  7,  7,  7,  7,  7,  7,  7,  7},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7,  7,  6,  6,  6,  6,  6,  6,  6},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  6,  6,  5,  5,  5,  5,  5,  5,  5},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  5,  5,  5,  4,  4,  4,  4,  4,  4,  4},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  5,  4,  4,  3,  3,  3,  3,  3,  3,  3},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  4,  4,  3,  3,  2,  2,  2,  2,  2,  2,  2},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  4,  3,  3,  2,  1,  1,  1,  1,  1,  1,  1},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  3,  3,  2,  1,  1,  0,  0,  0,  0,  0,  0},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  3,  3,  2,  1,  1,  0, -1, -1, -1, -1, -1, -1},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  3,  3,  2,  1,  0, -1, -1, -2, -2, -2, -2, -2},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  3,  3,  2,  1,  0, -1, -2, -2, -3, -3, -3, -3},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  3,  3,  2,  1,  0, -1, -2, -3, -3, -4, -4, -4},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  3,  3,  2,  1,  0, -1, -2, -3, -4, -4, -5, -5},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  3,  3,  2,  1,  0, -1, -2, -3, -4, -5, -5, -6},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  3,  3,  2,  1,  0, -1, -2, -3, -4, -5, -5, -6},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  3,  3,  2,  1,  0, -1, -2, -3, -4, -5, -6},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  4,  3,  2,  1,  0, -1, -2, -3, -4, -5, -6},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  4,  4,  3,  2,  1,  0, -1, -2, -3, -4, -5},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  5,  4,  3,  2,  1,  0, -1, -2, -3, -4},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  5,  5,  4,  3,  2,  1,  0, -1, -2, -3},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  6,  5,  4,  3,  2,  1,  0, -1, -2},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  6,  6,  5,  4,  3,  2,  1,  0, -1},
    '{-7, -7, -6, -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5,  6,  7,  7,  6,  5,  4,  3,  2,  1,  0}
  };

  localparam this_t cQAM32_BIT0_LLR[24][24] =
  '{
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7},
    '{-7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7},
    '{-6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -7, -7, -7, -7, -7, -7, -7, -7},
    '{-5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -6, -6, -7, -7, -7, -7, -7, -7},
    '{-4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -5, -5, -6, -7, -7, -7, -7, -7},
    '{-3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -4, -4, -5, -6, -7, -7, -7, -7},
    '{-2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -3, -3, -4, -5, -6, -7, -7, -7},
    '{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -2, -3, -3, -4, -5, -6, -7, -7},
    '{ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1, -2, -3, -4, -5, -6, -7, -7},
    '{ 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  0, -1, -1, -2, -3, -4, -5, -6, -7},
    '{ 2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  1,  1,  0, -1, -2, -3, -4, -5, -6, -7},
    '{ 3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  2,  2,  1,  0, -1, -2, -3, -4, -5, -6, -7},
    '{ 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  3,  3,  2,  1,  0, -1, -2, -3, -4, -5, -6, -7},
    '{ 5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  4,  4,  3,  2,  1,  0, -1, -2, -3, -4, -5, -6, -7},
    '{ 6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  5,  5,  4,  3,  2,  1,  0, -1, -2, -3, -4, -5, -6, -7},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  5,  4,  3,  2,  1,  0, -1, -2, -3, -4, -5, -6, -7},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  5,  4,  3,  2,  1,  0, -1, -2, -3, -4, -5, -6},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  5,  4,  3,  2,  1,  0, -1, -2, -3, -4, -5, -6},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  5,  4,  3,  2,  1,  0, -1, -2, -3, -4, -5},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  5,  4,  3,  2,  1,  0, -1, -2, -3, -4},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  5,  4,  3,  2,  1,  0, -1, -2, -3},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  5,  4,  3,  2,  1,  0, -1, -2},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  5,  4,  3,  2,  1,  0, -1},
    '{ 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  5,  4,  3,  2,  1,  0}
  };

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [3 : 0] sop;
  logic [3 : 0] val;
  logic [3 : 0] qam [4];

  this_t        dat_re, dat4sat_re;
  this_t        dat_im, dat4sat_im;

  this_t        adat_re, are;
  this_t        adat_im, aim;

  this_t        bit0_llr [3 : 3];
  this_t        bit1_llr [2 : 3] /*synthesis keep*/;
  this_t        bit2_llr [3 : 3];
  this_t        bit3_llr [2 : 3] /*synthesis keep*/;
  this_t        bit4_llr [3 : 3];

  this_t        bit4_llr_sub_tab[3][3];
  this_t        bit2_llr_sub_tab[3][3];
  this_t        bit0_llr_sub_tab[3][3];

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------


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
      sop     <= (sop << 1) | isop;
      qam[0]  <= iqam;
      for (int i = 1; i < 4; i++) begin
        qam[i] <= qam[i-1];
      end
      //
      // ival
      dat_re      <= idat_re;
      dat_im      <= idat_im;
      //
      // val[0]
      dat4sat_re  <= saturate(dat_re, cEDGE_NEG, cEDGE_POS);
      dat4sat_im  <= saturate(dat_im, cEDGE_NEG, cEDGE_POS);
      //
      // val[1]
      bit3_llr[2] <= saturate_llr(dat4sat_re);
      bit1_llr[2] <= saturate_llr(dat4sat_im);

      adat_re     <= (dat4sat_re < 0) ? -dat4sat_re : dat4sat_re;
      adat_im     <= (dat4sat_im < 0) ? -dat4sat_im : dat4sat_im;
      //
      // val[2]
      bit3_llr[3] <= bit3_llr[2];
      bit1_llr[3] <= bit1_llr[2];

      aim         <= adat_im;
      are         <= adat_re;
    end
  end

  genvar im, re;

  generate
    for (im = 0; im < 3; im++) begin : im_gen
      for (re = 0; re < 3; re++) begin : re_gen
        always_ff @(posedge iclk) begin
          if (iclkena) begin
            // val[2]
            bit4_llr_sub_tab[im[1:0]][re[1:0]] <= cQAM32_BIT4_LLR[{im[1:0], adat_im[2:0]}][{re[1:0], adat_re[2:0]}];
            bit2_llr_sub_tab[im[1:0]][re[1:0]] <= cQAM32_BIT2_LLR[{im[1:0], adat_im[2:0]}][{re[1:0], adat_re[2:0]}];
            bit0_llr_sub_tab[im[1:0]][re[1:0]] <= cQAM32_BIT0_LLR[{im[1:0], adat_im[2:0]}][{re[1:0], adat_re[2:0]}];
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (val[3]) begin
        osop    <= sop[3];
        oqam    <= qam[3];

        oLLR[0] <= bit0_llr_sub_tab[aim[4:3]][are[4:3]][pLLR_W-1 : 0];

        oLLR[1] <= bit1_llr[3][pLLR_W-1 : 0];

        oLLR[2] <= bit2_llr_sub_tab[aim[4:3]][are[4:3]][pLLR_W-1 : 0];

        oLLR[3] <= bit3_llr[3][pLLR_W-1 : 0];

        oLLR[4] <= bit4_llr_sub_tab[aim[4:3]][are[4:3]][pLLR_W-1 : 0];
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  function automatic this_t saturate (input this_t dat, this_t min, max);
    logic poverflow;
    logic noverflow;
  begin
    poverflow = (dat > max);
    noverflow = (dat < min);
    //
    if (poverflow | noverflow)
      saturate = poverflow ? max : min;
    else
      saturate = dat;
  end
  endfunction

  function automatic logic signed [pLLR_W-1 : 0] saturate_llr (input this_t dat);
    logic poverflow;
    logic noverflow;
  begin
    poverflow = (dat > cMAX_POS);
    noverflow = (dat < cMIN_NEG);
    //
    if (poverflow | noverflow)
      saturate_llr = poverflow ? cMAX_POS[pLLR_W-1 : 0] : cMIN_NEG[pLLR_W-1 : 0];
    else
      saturate_llr = dat[pLLR_W-1 : 0];
  end
  endfunction


endmodule

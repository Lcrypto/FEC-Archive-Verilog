/*



  parameter int pDAT_W  = 8 ;
  parameter int pLLR_W  = 4 ;



  logic                       llr_odd_qam_demapper__iclk            ;
  logic                       llr_odd_qam_demapper__ireset          ;
  logic                       llr_odd_qam_demapper__iclkena         ;
  logic                       llr_odd_qam_demapper__ival            ;
  logic                       llr_odd_qam_demapper__isop            ;
  logic               [3 : 0] llr_odd_qam_demapper__iqam            ;
  logic signed [pDAT_W-1 : 0] llr_odd_qam_demapper__idat_re         ;
  logic signed [pDAT_W-1 : 0] llr_odd_qam_demapper__idat_im         ;
  logic                       llr_odd_qam_demapper__oval            ;
  logic                       llr_odd_qam_demapper__osop            ;
  logic               [3 : 0] llr_odd_qam_demapper__oqam            ;
  logic signed [pLLR_W-1 : 0] llr_odd_qam_demapper__oLLR    [0 : 9] ;



  llr_odd_qam_demapper
  #(
    .pDAT_W ( pDAT_W ) ,
    .pLLR_W ( pLLR_W )
  )
  llr_odd_qam_demapper
  (
    .iclk    ( llr_odd_qam_demapper__iclk    ) ,
    .ireset  ( llr_odd_qam_demapper__ireset  ) ,
    .iclkena ( llr_odd_qam_demapper__iclkena ) ,
    .ival    ( llr_odd_qam_demapper__ival    ) ,
    .isop    ( llr_odd_qam_demapper__isop    ) ,
    .iqam    ( llr_odd_qam_demapper__iqam    ) ,
    .idat_re ( llr_odd_qam_demapper__idat_re ) ,
    .idat_im ( llr_odd_qam_demapper__idat_im ) ,
    .oval    ( llr_odd_qam_demapper__oval    ) ,
    .osop    ( llr_odd_qam_demapper__osop    ) ,
    .oqam    ( llr_odd_qam_demapper__oqam    ) ,
    .oLLR    ( llr_odd_qam_demapper__oLLR    )
  );


  assign llr_odd_qam_demapper__iclk    = '0 ;
  assign llr_odd_qam_demapper__ireset  = '0 ;
  assign llr_odd_qam_demapper__iclkena = '0 ;
  assign llr_odd_qam_demapper__ival    = '0 ;
  assign llr_odd_qam_demapper__isop    = '0 ;
  assign llr_odd_qam_demapper__iqam    = '0 ;
  assign llr_odd_qam_demapper__idat_re = '0 ;
  assign llr_odd_qam_demapper__idat_im = '0 ;



*/

//------------------------------------------------------------------------------------------------------
// odd QAM : BPSK, 8PSK, QAM32, QAM128, QAM512 LLR demapper
// Module work with LSB first endian. Module delay is 5+1 tick.
//------------------------------------------------------------------------------------------------------

module llr_odd_qam_demapper
#(
  parameter int pDAT_W  = 8 , // fixed, don't change
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
  output logic signed [pLLR_W-1 : 0] oLLR    [0 : 9] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [4 : 0] val;
  logic [4 : 0] sop;
  logic [3 : 0] qam [5];

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic signed [3 : 0] bpsk_8psk_demapper__oLLR [3] ;

  logic                qam32_demapper__oval         ;
  logic                qam32_demapper__osop         ;
  logic        [3 : 0] qam32_demapper__oqam         ;
  logic signed [3 : 0] qam32_demapper__oLLR     [5] ;

  logic signed [3 : 0] qam128_demapper__oLLR    [7] ;

  logic signed [3 : 0] qam512_demapper__oLLR    [9] ;

  //------------------------------------------------------------------------------------------------------
  // bpsk/8psk
  //------------------------------------------------------------------------------------------------------

  llr_bpsk_8psk_demapper
  #(
    .pDAT_W ( 5 ) ,
    .pLLR_W ( 4 )
  )
  bpsk_8psk_demapper
  (
    .iclk    ( iclk           ) ,
    .ireset  ( ireset         ) ,
    .iclkena ( iclkena        ) ,
    //
    .ival    ( ival           ) ,
    .isop    ( isop           ) ,
    .iqam    ( iqam           ) ,
    .idat_re ( idat_re[7 : 3] ) ,
    .idat_im ( idat_im[7 : 3] ) ,
    //
    .oval    (  ) , // n.u.
    .osop    (  ) , // n.u.
    .oqam    (  ) , // n.u.
    .oLLR    ( bpsk_8psk_demapper__oLLR )
  );

  //------------------------------------------------------------------------------------------------------
  // qam32
  //------------------------------------------------------------------------------------------------------

  llr_qam32_demapper
  qam32_demapper
  (
    .iclk    ( iclk           ) ,
    .ireset  ( ireset         ) ,
    .iclkena ( iclkena        ) ,
    //
    .ival    ( ival           ) ,
    .isop    ( isop           ) ,
    .iqam    ( iqam           ) ,
    .idat_re ( idat_re[7 : 2] ) ,
    .idat_im ( idat_im[7 : 2] ) ,
    //
    .oval    ( qam32_demapper__oval ) ,
    .osop    ( qam32_demapper__osop ) ,
    .oqam    ( qam32_demapper__oqam ) ,
    .oLLR    ( qam32_demapper__oLLR )
  );

  //------------------------------------------------------------------------------------------------------
  // qam128
  //------------------------------------------------------------------------------------------------------

  llr_qam128_demapper
  qam128_demapper
  (
    .iclk    ( iclk           ) ,
    .ireset  ( ireset         ) ,
    .iclkena ( iclkena        ) ,
    //
    .ival    ( ival           ) ,
    .isop    ( isop           ) ,
    .iqam    ( iqam           ) ,
    .idat_re ( idat_re[7 : 1] ) ,
    .idat_im ( idat_im[7 : 1] ) ,
    //
    .oval    (  ) , // n.u.
    .osop    (  ) , // n.u.
    .oqam    (  ) , // n.u.
    .oLLR    ( qam128_demapper__oLLR )
  );

  //------------------------------------------------------------------------------------------------------
  // qam512
  //------------------------------------------------------------------------------------------------------

  llr_qam512_demapper
  qam512_demapper
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    //
    .ival    ( ival    ) ,
    .isop    ( isop    ) ,
    .iqam    ( iqam    ) ,
    .idat_re ( idat_re ) ,
    .idat_im ( idat_im ) ,
    //
    .oval    (  ) , // n.u.
    .osop    (  ) , // n.u.
    .oqam    (  ) , // n.u.
    .oLLR    ( qam512_demapper__oLLR )
  );

  //------------------------------------------------------------------------------------------------------
  // ouput muxer
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= qam32_demapper__oval;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      osop <= qam32_demapper__osop;
      oqam <= qam32_demapper__oqam;
      //
      oLLR <= '{default : '0};
      case (qam32_demapper__oqam)
        4'd5    : oLLR[0 : 4] <= qam32_demapper__oLLR;
        4'd7    : oLLR[0 : 6] <= qam128_demapper__oLLR;
        4'd9    : oLLR[0 : 8] <= qam512_demapper__oLLR;
        default : oLLR[0 : 2] <= bpsk_8psk_demapper__oLLR;
      endcase
    end
  end

endmodule

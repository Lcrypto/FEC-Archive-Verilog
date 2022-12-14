/*



  parameter int pDAT_W  =  8 ;
  parameter int pLLR_W  =  4 ;



  logic                       demapper__iclk            ;
  logic                       demapper__ireset          ;
  logic                       demapper__iclkena         ;
  logic                       demapper__ival            ;
  logic                       demapper__isop            ;
  logic               [3 : 0] demapper__iqam            ;
  logic signed [pDAT_W-1 : 0] demapper__idat_re         ;
  logic signed [pDAT_W-1 : 0] demapper__idat_im         ;
  logic                       demapper__oval            ;
  logic                       demapper__osop            ;
  logic               [3 : 0] demapper__oqam            ;
  logic signed [pLLR_W-1 : 0] demapper__oLLR    [0 : 9] ;



  demapper
  #(
    .pDAT_W ( pDAT_W ) ,
    .pLLR_W ( pLLR_W )
  )
  demapper
  (
    .iclk    ( demapper__iclk    ) ,
    .ireset  ( demapper__ireset  ) ,
    .iclkena ( demapper__iclkena ) ,
    .ival    ( demapper__ival    ) ,
    .isop    ( demapper__isop    ) ,
    .iqam    ( demapper__iqam    ) ,
    .idat_re ( demapper__idat_re ) ,
    .idat_im ( demapper__idat_im ) ,
    .oval    ( demapper__oval    ) ,
    .osop    ( demapper__osop    ) ,
    .oqam    ( demapper__oqam    ) ,
    .oLLR    ( demapper__oLLR    )
  );


  assign demapper__iclk    = '0 ;
  assign demapper__ireset  = '0 ;
  assign demapper__iclkena = '0 ;
  assign demapper__ival    = '0 ;
  assign demapper__isop    = '0 ;
  assign demapper__iqam    = '0 ;
  assign demapper__idat_re = '0 ;
  assign demapper__idat_im = '0 ;



*/

//------------------------------------------------------------------------------------------------------
// any QAM : BPSK, QPSK, 8PSK, QAM16, QAM32, QAM64, QAM128, QAM256, QAM1024 LLR demapper
// Module work with LSB first endian. Module delay is 6+1 tick.
//------------------------------------------------------------------------------------------------------

module demapper
#(
  parameter int pDAT_W  = 8 ,
  parameter int pLLR_W  = 4
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

  logic                       even_qam_demapper__oval         ;
  logic                       even_qam_demapper__osop         ;
  logic               [3 : 0] even_qam_demapper__oqam         ;
  logic signed [pLLR_W-1 : 0] even_qam_demapper__oLLR [0 : 9] ;
  logic signed [pLLR_W-1 : 0] odd_qam_demapper__oLLR  [0 : 9] ;

  //------------------------------------------------------------------------------------------------------
  // even qam demapper
  //------------------------------------------------------------------------------------------------------

  llr_even_qam_demapper
  #(
    .pDAT_W ( pDAT_W ) ,
    .pLLR_W ( pLLR_W )
  )
  even_qam_demapper
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
    .oval    ( even_qam_demapper__oval ) ,
    .osop    ( even_qam_demapper__osop ) ,
    .oqam    ( even_qam_demapper__oqam ) ,
    .oLLR    ( even_qam_demapper__oLLR )
  );

  //------------------------------------------------------------------------------------------------------
  // odd qam demapper
  //------------------------------------------------------------------------------------------------------

  llr_odd_qam_demapper
  #(
    .pDAT_W ( pDAT_W ) ,
    .pLLR_W ( pLLR_W )
  )
  odd_qam_demapper
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
    .oLLR    ( odd_qam_demapper__oLLR )
  );

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= even_qam_demapper__oval;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      oqam <= even_qam_demapper__oqam;
      osop <= even_qam_demapper__osop;
      oLLR <= even_qam_demapper__oqam[0] ? odd_qam_demapper__oLLR : even_qam_demapper__oLLR;
    end
  end

endmodule

/*



  parameter int pDAT_W  = 12 ;



  logic                mapper__iclk     ;
  logic                mapper__ireset   ;
  logic                mapper__iclkena  ;
  logic                mapper__ival     ;
  logic        [3 : 0] mapper__iqam     ;
  logic        [4 : 0] mapper__idat_re  ;
  logic        [4 : 0] mapper__idat_im  ;
  logic                mapper__oval     ;
  logic [pDAT_W-1 : 0] mapper__odat_re  ;
  logic [pDAT_W-1 : 0] mapper__odat_im  ;



  mapper
  #(
    .pDAT_W ( pDAT_W )
  )
  mapper
  (
    .iclk    ( mapper__iclk    ) ,
    .ireset  ( mapper__ireset  ) ,
    .iclkena ( mapper__iclkena ) ,
    .ival    ( mapper__ival    ) ,
    .iqam    ( mapper__iqam    ) ,
    .idat_re ( mapper__idat_re ) ,
    .idat_im ( mapper__idat_im ) ,
    .oval    ( mapper__oval    ) ,
    .odat_re ( mapper__odat_re ) ,
    .odat_im ( mapper__odat_im )
  );


  assign mapper__iclk    = '0 ;
  assign mapper__ireset  = '0 ;
  assign mapper__iclkena = '0 ;
  assign mapper__ival    = '0 ;
  assign mapper__iqam    = '0 ;
  assign mapper__idat_re = '0 ;
  assign mapper__idat_im = '0 ;



*/

module mapper
#(
  parameter int pDAT_W  = 8
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  ival    ,
  iqam    ,
  idat_re ,
  idat_im ,
  oval    ,
  odat_re ,
  odat_im
);

  `include "mapper_tab.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                iclk     ;
  input  logic                ireset   ;
  input  logic                iclkena  ;
  //
  input  logic                ival     ;
  input  logic        [3 : 0] iqam     ;
  input  logic        [4 : 0] idat_re  ;
  input  logic        [4 : 0] idat_im  ;
  //
  output logic                oval     ;
  output logic [pDAT_W-1 : 0] odat_re  ;
  output logic [pDAT_W-1 : 0] odat_im  ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  initial oval = 1'b0;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      oval <= ival;
      if (ival) begin
        case (iqam)
          1       : begin odat_re <= cQPSK_TAB    [idat_re]; odat_im <= cQPSK_TAB    [idat_re]; end
          2       : begin odat_re <= cQPSK_TAB    [idat_re]; odat_im <= cQPSK_TAB    [idat_im]; end
          //
          3       : begin odat_re <= cQAM8_TAB    [idat_re]; odat_im <= cQAM8_TAB    [idat_im]; end
          4       : begin odat_re <= cQAM16_TAB   [idat_re]; odat_im <= cQAM16_TAB   [idat_im]; end
          //
          5       : begin odat_re <= cQAM32_TAB   [idat_re]; odat_im <= cQAM32_TAB   [idat_im]; end
          6       : begin odat_re <= cQAM64_TAB   [idat_re]; odat_im <= cQAM64_TAB   [idat_im]; end
          //
          7       : begin odat_re <= cQAM128_TAB  [idat_re]; odat_im <= cQAM128_TAB  [idat_im]; end
          8       : begin odat_re <= cQAM256_TAB  [idat_re]; odat_im <= cQAM256_TAB  [idat_im]; end
          //
          9       : begin odat_re <= cQAM512_TAB  [idat_re]; odat_im <= cQAM512_TAB  [idat_im]; end
          10      : begin odat_re <= cQAM1024_TAB [idat_re]; odat_im <= cQAM1024_TAB [idat_im]; end
          //
          default : begin odat_re <= cQPSK_TAB    [idat_re]; odat_im <= cQPSK_TAB    [idat_im]; end
        endcase
      end
    end
  end

endmodule

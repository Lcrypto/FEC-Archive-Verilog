/*



  parameter int pSEED0  =      0 ;
  parameter int pSEED1  = pSEED0 ;
  parameter int pSEED2  = pSEED1 ;



  logic          tausworthe_urng__iclk     ;
  logic          tausworthe_urng__ireset   ;
  logic          tausworthe_urng__iclkena  ;
  logic          tausworthe_urng__ienable  ;
  logic [31 : 0] tausworthe_urng__odat     ;



  tausworthe_urng
  #(
    .pSEED0 ( pSEED0 ) ,
    .pSEED1 ( pSEED1 ) ,
    .pSEED2 ( pSEED2 )
  )
  tausworthe_urng
  (
    .iclk    ( tausworthe_urng__iclk    ) ,
    .ireset  ( tausworthe_urng__ireset  ) ,
    .iclkena ( tausworthe_urng__iclkena ) ,
    .ienable ( tausworthe_urng__ienable ) ,
    .odat    ( tausworthe_urng__odat    )
  );


  assign tausworthe_urng__iclk    = '0 ;
  assign tausworthe_urng__ireset  = '0 ;
  assign tausworthe_urng__iclkena = '0 ;
  assign tausworthe_urng__ienable = '0 ;



*/

//
// Project       : tausworthe_urng
// Author        : Shekhalev Denis (des00)
// Revision      : $Revision$
// Date          : $Date$
// Workfile      : tausworthe_urng.v
// Description   : tausworthe random number generator
//

module tausworthe_urng
#(
  parameter int pSEED0  =      0 ,
  parameter int pSEED1  = pSEED0 ,
  parameter int pSEED2  = pSEED1
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  ienable ,
  odat
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic          iclk     ;
  input  logic          ireset   ;
  input  logic          iclkena  ;
  input  logic          ienable  ;
  output logic [31 : 0] odat     ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  typedef logic [31 : 0] dat_t;

  dat_t s0 = get_seed(pSEED0, 0);
  dat_t s1 = get_seed(pSEED1, 1);
  dat_t s2 = get_seed(pSEED2, 2);

  dat_t b0;
  dat_t b1;
  dat_t b2;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  assign b0 = (((s0 << 13) ^ s0) >> 19);
  assign b1 = (((s1 <<  2) ^ s1) >> 25);
  assign b2 = (((s2 <<  3) ^ s2) >> 11);

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (!ienable) begin
        s0   <= get_seed(pSEED0, 0);
        s1   <= get_seed(pSEED1, 1);
        s2   <= get_seed(pSEED2, 2);
        odat <= '0;
      end
      else begin
        s0 <= (((s0 & 32'hFFFFFFFE) << 12) ^ b0);
        s1 <= (((s1 & 32'hFFFFFFF8) <<  4) ^ b1);
        s2 <= (((s2 & 32'hFFFFFFF0) << 17) ^ b2);
        //
        odat <= s0 ^ s1 ^ s2;
      end
    end
  end

  function automatic logic [31 : 0] get_seed (input logic [31 : 0] seed, input int id = 0);
    case (id)
      1       : get_seed = (seed <  8) ? (seed +  8) : seed;
      2       : get_seed = (seed < 16) ? (seed + 16) : seed;
      default : get_seed = (seed <  2) ? (seed +  2) : seed;
    endcase
  endfunction

endmodule

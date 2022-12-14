/*



  parameter int pCODE  =  0 ;
  parameter int pN_IDX =  0 ;



  logic         ccsds_turbo_ptable__iclk
  logic         ccsds_turbo_ptable__ireset      ;
  logic         ccsds_turbo_ptable__iclkena     ;
  ptab_dat_t    ccsds_turbo_ptable__oN          ;
  ptab_dat_t    ccsds_turbo_ptable__oNm1        ;
  ptab_dat_t    ccsds_turbo_ptable__oK2         ;
  ptab_dat_t    ccsds_turbo_ptable__oP      [4] ;
  ptab_dat_t    ccsds_turbo_ptable__oPcomp  [4] ;




  ccsds_turbo_ptable
  #(
    .pCODE  ( pCODE  ) ,
    .pN_IDX ( pN_IDX )
  )
  ccsds_turbo_ptable
  (
    .iclk     ( ccsds_turbo_ptable__iclk    ) ,
    .ireset   ( ccsds_turbo_ptable__ireset  ) ,
    .iclkena  ( ccsds_turbo_ptable__iclkena ) ,
    .oN       ( ccsds_turbo_ptable__oN      ) ,
    .oNm1     ( ccsds_turbo_ptable__oNm1    ) ,
    .oK2      ( ccsds_turbo_ptable__oK2     ) ,
    .oP       ( ccsds_turbo_ptable__oP      ) ,
    .oPcomp   ( ccsds_turbo_ptable__oPcomp  )
  );


  assign ccsds_turbo_ptable__iclk    = '0 ;
  assign ccsds_turbo_ptable__ireset  = '0 ;
  assign ccsds_turbo_ptable__iclkena = '0 ;



*/

//
// Project       : ccsds_turbo
// Author        : Shekhalev Denis (des00)
// Workfile      : ccsds_turbo_ptable.v
// Description   : Permutation parameters table. It takes 1 clock cycles to apply new parameters
//

module ccsds_turbo_ptable
#(
  parameter int pCODE  = 0 , // 0/1/2/3 :: 1/2, 1/3, 1/4, 1/6
  parameter int pN_IDX = 0   // 0/1/2/3 :: 223*8*1, 223*8*2, 223*8*4, 223*8*5
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  oN      ,
  oNm1    ,
  //
  oK2     ,
  oP      ,
  oPcomp
);

  `include "ccsds_turbo_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic            iclk        ;
  input  logic            ireset      ;
  input  logic            iclkena     ;
  //
  output ptab_dat_t       oN          ;
  output ptab_dat_t       oNm1        ;
  output ptab_dat_t       oK2         ;
  //
  output ptab_dat_t       oP      [4] ;
  output ptab_dat_t       oPcomp  [4] ; // complement oP for backward recursion address process

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cK2_TAB    [4] = '{223*1, 223*2, 223*4, 223*5};

  localparam int cP_TAB     [4] = '{31, 37, 43, 47};

  localparam int cPCOMP_TAB [4][4] = '{
                                      '{ 192,  186,  180,  176} ,
                                      '{ 415,  409,  403,  399} ,
                                      '{ 861,  855,  849,  845} ,
                                      '{1084, 1078, 1072, 1068}};

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      oN    <= cN_TAB [pN_IDX];
      oNm1  <= cN_TAB [pN_IDX] - 1;
      oK2   <= cK2_TAB[pN_IDX];
      //
      for (int i = 0; i < 4; i++) begin
        oP    [i] <= cP_TAB            [i];
        oPcomp[i] <= cPCOMP_TAB [pN_IDX][i];
      end
    end
  end

endmodule

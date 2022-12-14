/*



  parameter int pDAT_W    = 8 ;
  parameter int pIDX_GR   = 0 ;
  parameter int pIDX_LS   = 0 ;
  parameter int pIDX_ZC   = 3 ;
  parameter int pCODE     = 4 ;
  parameter int pDO_PUNCT = 0 ;



  logic         ldpc_3gpp_enc_Hb_fix__iclk              ;
  logic         ldpc_3gpp_enc_Hb_fix__ireset            ;
  logic         ldpc_3gpp_enc_Hb_fix__iclkena           ;
  //
  hb_row_t      ldpc_3gpp_enc_Hb_fix__irow              ;
  //
  hb_zc_t       ldpc_3gpp_enc_Hb_fix__oused_zc          ;
  hb_row_t      ldpc_3gpp_enc_Hb_fix__oused_row         ;
  hb_col_t      ldpc_3gpp_enc_Hb_fix__oused_col         ;
  //
  mm_hb_value_t ldpc_3gpp_enc_Hb_fix__ou_AC     [4][22] ;
  //
  mm_hb_value_t ldpc_3gpp_enc_Hb_fix__oinvPsi           ;
  logic         ldpc_3gpp_enc_Hb_fix__oinvPsi_zero      ;
  //
  mm_hb_value_t ldpc_3gpp_enc_Hb_fix__op1_B             ;
  mm_hb_value_t ldpc_3gpp_enc_Hb_fix__op12_P        [3] ;



  ldpc_3gpp_enc_Hb_fix
  #(
    .pDAT_W    ( pDAT_W    ) ,
    .pIDX_GR   ( pIDX_GR   ) ,
    .pIDX_LS   ( pIDX_LS   ) ,
    .pIDX_ZC   ( pIDX_ZC   ) ,
    .pCODE     ( pCODE     ) ,
    .pDO_PUNCT ( pDO_PUNCT )
  )
  ldpc_3gpp_enc_Hb_fix
  (
    .iclk         ( ldpc_3gpp_enc_Hb_fix__iclk         ) ,
    .ireset       ( ldpc_3gpp_enc_Hb_fix__ireset       ) ,
    .iclkena      ( ldpc_3gpp_enc_Hb_fix__iclkena      ) ,
    //
    .irow         ( ldpc_3gpp_enc_Hb_fix__irow         ) ,
    //
    .oused_zc     ( ldpc_3gpp_enc_Hb_fix__oused_zc     ) ,
    .oused_row    ( ldpc_3gpp_enc_Hb_fix__oused_row    ) ,
    .oused_col    ( ldpc_3gpp_enc_Hb_fix__oused_col    ) ,
    //
    .ou_AC        ( ldpc_3gpp_enc_Hb_fix__ou_AC        ) ,
    //
    .oinvPsi      ( ldpc_3gpp_enc_Hb_fix__oinvPsi      ) ,
    .oinvPsi_zero ( ldpc_3gpp_enc_Hb_fix__oinvPsi_zero ) ,
    //
    .op1_B        ( ldpc_3gpp_enc_Hb_fix__op1_B        ) ,
    .op12_P       ( ldpc_3gpp_enc_Hb_fix__op12_P       )
  );


  assign ldpc_3gpp_enc_Hb_fix__iclk    = '0 ;
  assign ldpc_3gpp_enc_Hb_fix__ireset  = '0 ;
  assign ldpc_3gpp_enc_Hb_fix__iclkena = '0 ;
  assign ldpc_3gpp_enc_Hb_fix__irow    = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_enc_Hb_fix.sv
// Description   : fixed mode 3GPP LDPC RTL encoder tables
//

module ldpc_3gpp_enc_Hb_fix
(
  iclk         ,
  ireset       ,
  iclkena      ,
  //
  irow         ,
  //
  oused_zc     ,
  oused_row    ,
  oused_col    ,
  //
  ou_AC        ,
  //
  oinvPsi      ,
  oinvPsi_zero ,
  //
  op1_B        ,
  op12_P
);

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_enc_types.svh"

  `include "../ldpc_3gpp_hc.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic         iclk             ;
  input  logic         ireset           ;
  input  logic         iclkena          ;
  //
  input  hb_row_t      irow             ;
  //
  output hb_zc_t       oused_zc         ;
  output hb_row_t      oused_row        ;
  output hb_col_t      oused_col        ;
  //
  output mm_hb_value_t ou_AC    [4][22] ;  // A C P matrix for parallel data engine
  //
  output mm_hb_value_t oinvPsi          ;  // inverted psi matrix
  output logic         oinvPsi_zero     ;
  //
  output mm_hb_value_t op1_B        [3] ;  // B matrix for p1
  output mm_hb_value_t op12_P       [3] ;  // P matrix for p1 and p2

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  mm_hb_value_t uHb [46][26];

  hb_zc_t       used_zc;
  hb_row_t      used_row;
  hb_col_t      used_col;

  //------------------------------------------------------------------------------------------------------
  // get and convert Hb table
  //------------------------------------------------------------------------------------------------------

  always_comb begin
    baseHc_t Hb;
    //
    Hb = get_scaled_Hc(pIDX_GR, pIDX_LS, pIDX_ZC);
    //
    for (int row = 0; row < 46; row++) begin
      for (int col = 0; col < 26; col++) begin
        if ((row > 4) & (row > pCODE)) begin
          uHb[row][col]           = '0;
          uHb[row][col].is_masked = 1'b1;
        end
        else begin
          uHb[row][col].bshift    =  Hb[row][col] % pDAT_W;
          uHb[row][col].wshift    =  Hb[row][col] / pDAT_W;
          uHb[row][col].is_masked = (Hb[row][col] < 0);
        end
      end
    end
    //
    used_zc   = cZC_TAB[pIDX_LS][pIDX_ZC] / pDAT_W;
    used_row  = (pCODE < 4) ? 4 : pCODE;
    used_col  = pIDX_GR ? 10 : 22;
  end

  //------------------------------------------------------------------------------------------------------
  // sequential read
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      oused_zc  <= used_zc;
      oused_row <= used_row;
      oused_col <= used_col;
      // AC
      for (int row = 0; row < 4; row++) begin
        for (int col = 0; col < 22; col++) begin
          if (row == 0) begin
            ou_AC[row][col].bshift    <= uHb[irow][col].bshift;
            ou_AC[row][col].wshift    <= uHb[irow][col].wshift;
            ou_AC[row][col].is_masked <= uHb[irow][col].is_masked;
          end
          else begin
            ou_AC[row][col].bshift    <= uHb[row][col].bshift;
            ou_AC[row][col].wshift    <= uHb[row][col].wshift;
            ou_AC[row][col].is_masked <= uHb[row][col].is_masked;
          end
          if (pIDX_GR & col >= 14) begin
            ou_AC[row][col].is_masked <= 1'b1; // short graph
          end
        end
      end
      // invPsi
      oinvPsi.bshift    <= cINV_PSI[pIDX_GR][pIDX_LS][pIDX_ZC] % pDAT_W;
      oinvPsi.wshift    <= cINV_PSI[pIDX_GR][pIDX_LS][pIDX_ZC] / pDAT_W;
      oinvPsi.is_masked <= 1'b0;
      //
      oinvPsi_zero      <= (cINV_PSI[pIDX_GR][pIDX_LS][pIDX_ZC] == 0);
      // p1_B : (0 x x), (0 1 x), (0 1 2), (x x 4)...(x x 45)
      for (int row = 0; row < 3; row++) begin
        if (pIDX_GR) begin
          op1_B[row].bshift    <= (row == 2) ? uHb[irow][10].bshift    : uHb[row][10].bshift;
          op1_B[row].wshift    <= (row == 2) ? uHb[irow][10].wshift    : uHb[row][10].wshift;
          op1_B[row].is_masked <= (row == 2) ? uHb[irow][10].is_masked : uHb[row][10].is_masked;
        end
        else begin
          op1_B[row].bshift    <= (row == 2) ? uHb[irow][22].bshift    : uHb[row][22].bshift;
          op1_B[row].wshift    <= (row == 2) ? uHb[irow][22].wshift    : uHb[row][22].wshift;
          op1_B[row].is_masked <= (row == 2) ? uHb[irow][22].is_masked : uHb[row][22].is_masked;
        end
      end
      // p12_P
      for (int col = 0; col < 3; col++) begin
        if (pIDX_GR) begin
          op12_P[col].bshift    <= uHb[irow][11 + col].bshift;
          op12_P[col].wshift    <= uHb[irow][11 + col].wshift;
          op12_P[col].is_masked <= uHb[irow][11 + col].is_masked;
        end
        else begin
          op12_P[col].bshift    <= uHb[irow][23 + col].bshift;
          op12_P[col].wshift    <= uHb[irow][23 + col].wshift;
          op12_P[col].is_masked <= uHb[irow][23 + col].is_masked;
        end
      end
    end
  end

endmodule

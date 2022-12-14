/*



  parameter int pADDR_W = 8 ;
  parameter int pDAT_W  = 8 ;
  parameter bit pIDX_GR = 0 ;
  parameter bit pPIPE   = 1 ;



  logic          ldpc_3gpp_enc_acu__iclk                ;
  logic          ldpc_3gpp_enc_acu__ireset              ;
  logic          ldpc_3gpp_enc_acu__iclkena             ;
  //
  hb_zc_t        ldpc_3gpp_enc_acu__iused_zc            ;
  //
  logic          ldpc_3gpp_enc_acu__iwrite              ;
  logic          ldpc_3gpp_enc_acu__iwstart             ;
  strb_t         ldpc_3gpp_enc_acu__iwstrb              ;
  hb_col_t       ldpc_3gpp_enc_acu__iwcol               ;
  dat_t          ldpc_3gpp_enc_acu__iwdat               ;
  //
  logic          ldpc_3gpp_enc_acu__iread               ;
  logic          ldpc_3gpp_enc_acu__irstart             ;
  logic          ldpc_3gpp_enc_acu__irval               ;
  strb_t         ldpc_3gpp_enc_acu__irstrb              ;
  mm_hb_value_t  ldpc_3gpp_enc_acu__irHb        [4][22] ;
  //
  logic          ldpc_3gpp_enc_acu__oval                ;
  strb_t         ldpc_3gpp_enc_acu__ostrb               ;
  dat_t          ldpc_3gpp_enc_acu__odat                ;
  //
  logic          ldpc_3gpp_enc_acu__owrite2p1           ;
  logic          ldpc_3gpp_enc_acu__owstart2p1          ;
  dat_t          ldpc_3gpp_enc_acu__owdat2p1            ;
  //
  logic          ldpc_3gpp_enc_acu__owrite2p2           ;
  logic          ldpc_3gpp_enc_acu__owstart2p2          ;
  dat_t          ldpc_3gpp_enc_acu__owdat2p2        [3] ;
  //
  logic          ldpc_3gpp_enc_acu__owrite2p3           ;
  logic          ldpc_3gpp_enc_acu__owstart2p3          ;
  dat_t          ldpc_3gpp_enc_acu__owdat2p3            ;



  ldpc_3gpp_enc_acu
  #(
    .pADDR_W ( pADDR_W ) ,
    .pDAT_W  ( pDAT_W  ) ,
    .pIDX_GR ( pIDX_GR ) ,
    .pPIPE   ( pPIPE   )
  )
  ldpc_3gpp_enc_acu
  (
    .iclk        ( ldpc_3gpp_enc_acu__iclk       ) ,
    .ireset      ( ldpc_3gpp_enc_acu__ireset     ) ,
    .iclkena     ( ldpc_3gpp_enc_acu__iclkena    ) ,
    //
    .iused_zf    ( ldpc_3gpp_enc_acu__iused_zc   ) ,
    //
    .iwrite      ( ldpc_3gpp_enc_acu__iwrite     ) ,
    .iwstart     ( ldpc_3gpp_enc_acu__iwstart    ) ,
    .iwstrb      ( ldpc_3gpp_enc_acu__iwstrb     ) ,
    .iwcol       ( ldpc_3gpp_enc_acu__iwcol      ) ,
    .iwdat       ( ldpc_3gpp_enc_acu__iwdat      ) ,
    //
    .iread       ( ldpc_3gpp_enc_acu__iread      ) ,
    .irstart     ( ldpc_3gpp_enc_acu__irstart    ) ,
    .irval       ( ldpc_3gpp_enc_acu__irval      ) ,
    .irstrb      ( ldpc_3gpp_enc_acu__irstrb     ) ,
    .irHb        ( ldpc_3gpp_enc_acu__irHb       ) ,
    //
    .oval        ( ldpc_3gpp_enc_acu__oval       ) ,
    .ostrb       ( ldpc_3gpp_enc_acu__ostrb      ) ,
    .odat        ( ldpc_3gpp_enc_acu__odat       ) ,
    //
    .owrite2p1   ( ldpc_3gpp_enc_acu__owrite2p1  ) ,
    .owstart2p1  ( ldpc_3gpp_enc_acu__owstart2p1 ) ,
    .owdat2p1    ( ldpc_3gpp_enc_acu__owdat2p1   ) ,
    //
    .owrite2p2   ( ldpc_3gpp_enc_acu__owrite2p2  ) ,
    .owstart2p2  ( ldpc_3gpp_enc_acu__owstart2p2 ) ,
    .owdat2p2    ( ldpc_3gpp_enc_acu__owdat2p2   ) ,
    //
    .owrite2p3   ( ldpc_3gpp_enc_acu__owrite2p3  ) ,
    .owstart2p3  ( ldpc_3gpp_enc_acu__owstart2p3 ) ,
    .owdat2p3    ( ldpc_3gpp_enc_acu__owdat2p3   )
  );


  assign ldpc_3gpp_enc_acu__iclk     = '0 ;
  assign ldpc_3gpp_enc_acu__ireset   = '0 ;
  assign ldpc_3gpp_enc_acu__iclkena  = '0 ;
  //
  assign ldpc_3gpp_enc_acu__iused_zc = '0 ;
  //
  assign ldpc_3gpp_enc_acu__iwrite   = '0 ;
  assign ldpc_3gpp_enc_acu__iwstart  = '0 ;
  assign ldpc_3gpp_enc_acu__iwstrb   = '0 ;
  assign ldpc_3gpp_enc_acu__iwcol    = '0 ;
  assign ldpc_3gpp_enc_acu__iwdat    = '0 ;
  //
  assign ldpc_3gpp_enc_acu__iread    = '0 ;
  assign ldpc_3gpp_enc_acu__irstart  = '0 ;
  assign ldpc_3gpp_enc_acu__irval    = '0 ;
  assign ldpc_3gpp_enc_acu__irsstrb  = '0 ;
  assign ldpc_3gpp_enc_acu__irHb     = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_enc_acu.sv
// Description   : A*u' and C*u' matrix multiply & get (E*(T^-1)*A*u' + C*u') for p1 and A*u' for p2
//                 A*u' for p3
//

`include "define.vh"

module ldpc_3gpp_enc_acu
(
  iclk        ,
  ireset      ,
  iclkena     ,
  //
  iused_zc    ,
  //
  iwrite      ,
  iwstart     ,
  iwstrb      ,
  iwcol       ,
  iwdat       ,
  //
  iread       ,
  irstart     ,
  irval       ,
  irstrb      ,
  irHb        ,
  //
  oval        ,
  ostrb       ,
  odat        ,
  //
  owrite2p1   ,
  owstart2p1  ,
  owdat2p1    ,
  //
  owrite2p2   ,
  owstart2p2  ,
  owdat2p2    ,
  //
  owrite2p3   ,
  owstart2p3  ,
  owdat2p3
);

  parameter int pADDR_W = 8 ;
  parameter bit pPIPE   = 0 ; // use matrix multiply pipeline or not

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_enc_types.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic          iclk           ;
  input  logic          ireset         ;
  input  logic          iclkena        ;
  //
  input  hb_zc_t        iused_zc       ;
  // upload interface
  input  logic          iwrite         ;
  input  logic          iwstart        ;
  input  strb_t         iwstrb         ;
  input  hb_col_t       iwcol          ;
  input  dat_t          iwdat          ;
  // matrix mult interface
  input  logic          iread          ;
  input  logic          irstart        ;
  input  logic          irval          ;
  input  strb_t         irstrb         ;
  input  mm_hb_value_t  irHb   [4][22] ;
  // to output buffer
  output logic          oval           ;
  output strb_t         ostrb          ;
  output dat_t          odat           ;
  // to p1 matrix multiply (E*(T^-1)*A*u' + C*u')
  output logic          owrite2p1      ;
  output logic          owstart2p1     ;
  output dat_t          owdat2p1       ;
  // to p2 matrix multiply A*u'
  output logic          owrite2p2      ;
  output logic          owstart2p2     ;
  output dat_t          owdat2p2   [3] ;
  // to p3 matrix adder
  output logic          owrite2p3      ;
  output logic          owstart2p3     ;
  output dat_t          owdat2p3       ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic         mm__iwrite  [4][22] ;
  logic         mm__iwstart [4][22] ;
  dat_t         mm__iwdat   [4][22] ;
  //
  logic         mm__iread   [4][22] ;
  logic         mm__irstart [4][22] ;
  mm_hb_value_t mm__irHb    [4][22] ;
  logic         mm__irval   [4][22] ;
  strb_t        mm__irstrb  [4][22] ;
  //
  logic         mm__oval    [4][22] ;
  strb_t        mm__ostrb   [4][22] ;
  dat_t         mm__odat    [4][22] ;

  //------------------------------------------------------------------------------------------------------
  // A*u' and C*u'
  //------------------------------------------------------------------------------------------------------

  genvar grow, gcol;

  generate
    for (grow = 0; grow < 4; grow++) begin : mm_row_inst
      for (gcol = 0; gcol < 22; gcol++) begin : mm_col_inst
        if (gcol < cGR_SYST_BIT_COL[pIDX_GR]) begin
          ldpc_3gpp_enc_mm_spram
          #(
            .pADDR_W  ( pADDR_W  ) ,
            .pDAT_W   ( pDAT_W   ) ,
            .pPIPE    ( pPIPE    )
          )
          mm
          (
            .iclk     ( iclk     ) ,
            .ireset   ( ireset   ) ,
            .iclkena  ( iclkena  ) ,
            //
            .iused_zc ( iused_zc ) ,
            //
            .iwrite   ( mm__iwrite  [grow][gcol] ) ,
            .iwstart  ( mm__iwstart [grow][gcol] ) ,
            .iwdat    ( mm__iwdat   [grow][gcol] ) ,
            //
            .iread    ( mm__iread   [grow][gcol] ) ,
            .irstart  ( mm__irstart [grow][gcol] ) ,
            .irHb     ( mm__irHb    [grow][gcol] ) ,
            .irval    ( mm__irval   [grow][gcol] ) ,
            .irstrb   ( mm__irstrb  [grow][gcol] ) ,
            //
            .oval     ( mm__oval    [grow][gcol] ) ,
            .ostrb    ( mm__ostrb   [grow][gcol] ) ,
            .odat     ( mm__odat    [grow][gcol] )
          );
        end
        else begin
          assign mm__oval  [grow][gcol] = '0;
          assign mm__ostrb [grow][gcol] = '0;
          assign mm__odat  [grow][gcol] = '0;
        end

        assign mm__iwrite [grow][gcol] = iwrite & (iwcol == gcol);
        assign mm__iwstart[grow][gcol] = iwstart;
        assign mm__iwdat  [grow][gcol] = iwdat;

        assign mm__iread  [grow][gcol] = iread;
        assign mm__irstart[grow][gcol] = irstart;

        assign mm__irHb   [grow][gcol] = irHb[grow][gcol];

        assign mm__irval  [grow][gcol] = irval;
        assign mm__irstrb [grow][gcol] = irstrb;

      end
    end
  endgenerate

  //------------------------------------------------------------------------------------------------------
  // data bypass
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= iwrite;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      ostrb <= iwstrb;
      odat  <= iwdat;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // acu2p1 : (E*(T^-1)*A*u' + C*u')
  // acu2p2 : A*u'
  // acu2p3 : P*u'
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      owrite2p1 <= 1'b0;
      owrite2p2 <= 1'b0;
      owrite2p3 <= 1'b0;
    end
    else if (iclkena) begin
      owrite2p1 <= mm__oval[0][0];
      owrite2p2 <= mm__oval[0][0];
      owrite2p3 <= mm__oval[0][0];
    end
  end

  dat_t row_dat [4];

  always_ff @(posedge iclk) begin
    dat_t tmp [4];
    //
    if (iclkena) begin
      tmp = '{default : '0};
      for (int row = 0; row < 4; row++) begin
        for (int col = 0; col < 22; col++) begin
          tmp[row] ^= mm__odat[row][col];
        end
      end
      row_dat     <= tmp;
      // write once
      owstart2p1  <= mm__ostrb[0][0].sof;
      owstart2p2  <= mm__ostrb[0][0].sof;
      owstart2p3  <= mm__ostrb[0][0].sof;
    end
  end

  // acu2p1 register is inside ldpc_3gpp_enc_p1 module
  assign owdat2p1     = row_dat[0] ^ row_dat[1] ^ row_dat[2] ^ row_dat[3];

  // acu2p2
  assign owdat2p2[0]  = row_dat[0];
  assign owdat2p2[1]  = row_dat[1];
  assign owdat2p2[2]  = row_dat[2];

  // acu2p3
  assign owdat2p3     = row_dat[0];

endmodule

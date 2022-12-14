/*



  parameter int pLLR_W                =  4 ;
  parameter int pLLR_FP               =  4 ;
  parameter int pODAT_W               =  2 ;
  parameter int pTAG_W                =  8 ;
  parameter int pCODE                 =  0 ;
  parameter int pPTYPE                =  0 ;
  parameter int pN                    = 56 ;
  parameter int pMMAX_TYPE            =  0 ;

  logic                       rsc2_dec__iclk            ;
  logic                       rsc2_dec__ireset          ;
  logic                       rsc2_dec__iclkena         ;
  logic               [3 : 0] rsc2_dec__iNiter          ;
  logic        [pTAG_W-1 : 0] rsc2_dec__itag            ;
  logic                       rsc2_dec__isop            ;
  logic                       rsc2_dec__ieop            ;
  logic                       rsc2_dec__ieof            ;
  logic                       rsc2_dec__ival            ;
  logic signed [pLLR_W-1 : 0] rsc2_dec__iLLR    [0 : 1] ;
  logic                       rsc2_dec__obusy           ;
  logic                       rsc2_dec__ordy            ;
  logic        [pTAG_W-1 : 0] rsc2_dec__otag            ;
  logic                       rsc2_dec__osop            ;
  logic                       rsc2_dec__oeop            ;
  logic                       rsc2_dec__oval            ;
  logic               [1 : 0] rsc2_dec__odat            ;
  logic              [15 : 0] rsc2_dec__oerr            ;



  rsc2_dec
  #(
    .pLLR_W     ( pLLR_W      ) ,
    .pLLR_FP    ( pLLR_FP     ) ,
    .pODAT_W    ( pODAT_W     ) ,
    .pTAG_W     ( pTAG_W      ) ,
    .pCODE      ( pCODE       ) ,
    .pPTYPE     ( pPTYPE      ) ,
    .pN         ( pN          ) ,
    .pMMAX_TYPE ( pMMAX_TYPE  ) ,
  )
  rsc2_dec
  (
    .iclk    ( rsc2_dec__iclk    ) ,
    .ireset  ( rsc2_dec__ireset  ) ,
    .iclkena ( rsc2_dec__iclkena ) ,
    .iNiter  ( rsc2_dec__iNiter  ) ,
    .itag    ( rsc2_dec__itag    ) ,
    .isop    ( rsc2_dec__isop    ) ,
    .ieop    ( rsc2_dec__ieop    ) ,
    .ieof    ( rsc2_dec__ieof    ) ,
    .ival    ( rsc2_dec__ival    ) ,
    .iLLR    ( rsc2_dec__iLLR    ) ,
    .obusy   ( rsc2_dec__obusy   ) ,
    .ordy    ( rsc2_dec__ordy    ) ,
    .otag    ( rsc2_dec__otag    ) ,
    .osop    ( rsc2_dec__osop    ) ,
    .oeop    ( rsc2_dec__oeop    ) ,
    .oval    ( rsc2_dec__oval    ) ,
    .odat    ( rsc2_dec__odat    ) ,
    .oerr    ( rsc2_dec__oerr    )
  );


  assign rsc2_dec__iclk    = '0 ;
  assign rsc2_dec__ireset  = '0 ;
  assign rsc2_dec__iclkena = '0 ;
  assign rsc2_dec__iNiter  = '0 ;
  assign rsc2_dec__itag    = '0 ;
  assign rsc2_dec__isop    = '0 ;
  assign rsc2_dec__ieop    = '0 ;
  assign rsc2_dec__ieof    = '0 ;
  assign rsc2_dec__ival    = '0 ;
  assign rsc2_dec__iLLR    = '0 ;



*/

//
// Project       : rsc2
// Author        : Shekhalev Denis (des00)
// Workfile      : rsc2_dec.v
// Description   : top level for rsc2 decoder components with dynamic parameters change on fly
//                 Data process path is :
//                  source -> 2D input buffer -> decoder + extr_ram -> 2D buffer -> sink
//

`include "define.vh"

module rsc2_dec
#(
  parameter int pLLR_W                =        5 ,  // LLR width
  parameter int pLLR_FP               = pLLR_W-2 ,  // LLR fixed point
  parameter int pODAT_W               =        2 ,  // Output data width 2/4/8
  parameter int pTAG_W                =        8 ,  // Tag port bitwidth
  //
  parameter int pCODE                 =        0 ,  // coderate [0 : 7] - [1/3; 1/2; 2/3; 3/4; 4/5; 5/6; 6/7; 7/8]
  parameter int pPTYPE                =        0 ,  // permutation type [0: 33] - reordered Table A-1/2/4/5
  parameter int pN                    =       56 ,
  //
  parameter int pMMAX_TYPE            =        0    // 0 - max Log Map (only supported)
                                                    // 1 - const 1 max Log Map
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  iNiter  ,
  //
  itag    ,
  isop    ,
  ieop    ,
  ival    ,
  iLLR    ,
  //
  obusy   ,
  ordy    ,
  //
  otag    ,
  osop    ,
  oeop    ,
  oval    ,
  odat    ,
  //
  oerr
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                       iclk           ;
  input  logic                       ireset         ;
  input  logic                       iclkena        ;
  //
  input  logic               [3 : 0] iNiter         ; // number of iteration >= 2
  //
  input  logic        [pTAG_W-1 : 0] itag           ;
  input  logic                       isop           ;
  input  logic                       ieop           ;
  input  logic                       ival           ;
  input  logic signed [pLLR_W-1 : 0] iLLR   [0 : 1] ;
  // input handshake interface
  output logic                       obusy          ;
  output logic                       ordy           ;
  //
  output logic        [pTAG_W-1 : 0] otag           ;
  output logic                       osop           ;
  output logic                       oeop           ;
  output logic                       oval           ;
  output logic       [pODAT_W-1 : 0] odat           ;
  //
  output logic              [15 : 0] oerr           ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cADDR_W = clogb2(pN);

  localparam int cIB_TAG_W =  4 + pTAG_W; // {Niter, tag}
  localparam int cOB_TAG_W = 16 + pTAG_W; // {decerr, tag}

  `include "rsc2_dec_types.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  // parameter table
  logic           [3 : 0] used_Niter     ;
  logic          [12 : 0] used_N         ;
  logic          [12 : 0] used_Nm1       ;
  logic          [12 : 0] used_P     [4] ;
  logic          [12 : 0] used_P0comp    ;
  logic          [12 : 0] used_Pincr     ;

  // source
  logic                   source__owrite          ;
  logic                   source__owfull          ;
  logic           [1 : 0] source__owsel           ;
  logic   [cADDR_W-1 : 0] source__owaddr          ;
  bit_llr_t               source__osLLR   [0 : 1] ;
  bit_llr_t               source__oyLLR   [0 : 1] ;
  bit_llr_t               source__owLLR   [0 : 1] ;

  // input buffer
  logic [cIB_TAG_W-1 : 0] ibuffer__iwtag   ;
  logic [cIB_TAG_W-1 : 0] ibuffer__ortag   ;
  logic                   ibuffer__oempty  ;
  logic                   ibuffer__oemptya ;
  logic                   ibuffer__ofull   ;
  logic                   ibuffer__ofulla  ;

  // address generator
  logic                    addr_gen__obitinv ;
  logic          [12 : 0] faddr_gen__osaddr  ;
  logic          [12 : 0] faddr_gen__opaddr  ;
  logic          [12 : 0] baddr_gen__osaddr  ;
  logic          [12 : 0] baddr_gen__opaddr  ;

  // ctrl
  logic                   ctrl__obuf_rempty      ;

  logic                   ctrl__oaddr_pmode      ;
  logic                   ctrl__oaddr_clear      ;
  logic                   ctrl__oaddr_enable     ;

  logic                   ctrl__ofirst_sub_stage ;
  logic                   ctrl__olast_sub_stage  ;
  logic                   ctrl__oeven_sub_stage  ;
  logic                   ctrl__osub_stage_warm  ;

  logic                   ctrl__odec_sop         ;
  logic                   ctrl__odec_val         ;
  logic                   ctrl__odec_eop         ;

  // decoder engine
  logic                   dec__ifirst           ;
  logic                   dec__ilast            ;
  logic                   dec__ieven            ;
  logic                   dec__ibitswap         ;
  logic                   dec__iwarm            ;

  logic                   dec__isop             ;
  logic                   dec__ival             ;
  logic                   dec__ieop             ;

  logic   [cADDR_W-1 : 0] dec__ifaddr           ;
  bit_llr_t               dec__ifsLLR   [0 : 1] ;
  bit_llr_t               dec__ifyLLR   [0 : 1] ;
  bit_llr_t               dec__ifwLLR   [0 : 1] ;
  Lextr_t                 dec__ifLextr          ;

  logic   [cADDR_W-1 : 0] dec__ibaddr           ;
  bit_llr_t               dec__ibsLLR   [0 : 1] ;
  bit_llr_t               dec__ibyLLR   [0 : 1] ;
  bit_llr_t               dec__ibwLLR   [0 : 1] ;
  Lextr_t                 dec__ibLextr          ;

  state_t                 dec__if_rp_state_even ;
  state_t                 dec__if_rp_state_odd  ;
  state_t                 dec__ib_rp_state_even ;
  state_t                 dec__ib_rp_state_odd  ;

  state_t                 dec__of_rp_state_even ;
  state_t                 dec__of_rp_state_odd  ;
  state_t                 dec__ob_rp_state_even ;
  state_t                 dec__ob_rp_state_odd  ;

  logic                   dec__osop             ;
  logic                   dec__oeop             ;
  logic                   dec__oval             ;
  logic                   dec__odatval          ;

  logic   [cADDR_W-1 : 0] dec__ofaddr           ;
  Lextr_t                 dec__ofLextr          ;
  logic           [1 : 0] dec__ofdat            ;

  logic   [cADDR_W-1 : 0] dec__obaddr           ;
  Lextr_t                 dec__obLextr          ;
  logic           [1 : 0] dec__obdat            ;

  logic                   dec__odone            ;
  logic          [15 : 0] dec__oerr             ;

  // output buffer
  logic                   obuffer__oempty ;
  logic [cOB_TAG_W-1 : 0] obuffer__iwtag  ;
  logic [cOB_TAG_W-1 : 0] obuffer__ortag  ;

  // sink
  logic                   sink__ifull   ;
  logic   [pODAT_W-1 : 0] sink__irdata  ;
  logic          [15 : 0] sink__ierr    ;
  logic    [pTAG_W-1 : 0] sink__itag    ;
  logic                   sink__orempty ;
  logic   [cADDR_W-1 : 0] sink__oraddr  ;

  // temp variable
  logic    [pTAG_W-1 : 0] data_tag ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
  // synthesis translate_off

  logic [12 : 0] ntable__oN;

  rsc2_ntable
  ntable
  (
    .iptype ( pPTYPE     ) ,
    .oN     ( ntable__oN ) ,
    .oNm1   (            )
  );

  initial begin : info
    @(posedge iclk iff iclkena & ival & isop);
    $display("bw paramters used for decoding:");
    $display("block length %0d. code rate %0d", ntable__oN, pCODE);
    case (pMMAX_TYPE)
      1       : $display("C=1.5 MaxLog Map");
      2       : $display("C=2.0 MaxLog Map");
      3       : $display("LUT   MaxLog Map");
      default : $display("MaxLog Map");
    endcase
    $display("iteration number : %0d", iNiter);
    $display("fixed point_w : %0d", pLLR_FP);
    $display("input bit LLR : %0d", $size(bit_llr_t));
    $display("duo bit LLR : %0d", $size(dbit_llr_t));
    $display("extrinsic (Lext) LLR : %0d", $size(extr_llr_t), 2**(cL_EXT_W-1)-1);
    $display("trellis state (alpha/beta) LLR : %0d, max state : %0d", $size(trel_state_t), 2**(cSTATE_W-2));
    $display("trellis Lapo LLR : %0d", $size(trel_branch_t));
  end
  // synthesis translate_on
  //------------------------------------------------------------------------------------------------------
  // source module
  //------------------------------------------------------------------------------------------------------

  rsc2_dec_source
  #(
    .pLLR_W            ( pLLR_W       ) ,
    .pLLR_FP           ( pLLR_FP      ) ,
    .pADDR_W           ( cADDR_W      ) ,
    .pUSE_W_BIT        ( (pCODE == 0) ) ,
    .pUSE_EOP_VAL_MASK ( 0            )
  )
  source
  (
    .iclk    ( iclk             ) ,
    .ireset  ( ireset           ) ,
    .iclkena ( iclkena          ) ,
    //
    .icode   ( pCODE            ) ,
    .iptype  ( pPTYPE           ) ,
    // input interface
    .isop    ( isop             ) ,
    .ieop    ( ieop             ) ,
    .ival    ( ival             ) ,
    .iLLR    ( iLLR             ) ,
    //
    .ifulla  ( ibuffer__ofulla  ) ,
    .iemptya ( ibuffer__oemptya ) ,
    //
    .obusy   ( obusy            ) ,
    .ordy    ( ordy             ) ,
    // ibuffer interface
    .owrite  ( source__owrite   ) ,
    .owfull  ( source__owfull   ) ,
    .owsel   ( source__owsel    ) ,
    .owaddr  ( source__owaddr   ) ,
    .osLLR   ( source__osLLR    ) ,
    .oyLLR   ( source__oyLLR    ) ,
    .owLLR   ( source__owLLR    )
  );

  //
  // align rsc2_dec_source delay
  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (isop & ival) begin
        ibuffer__iwtag <= {iNiter, itag};
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // input buffer
  //------------------------------------------------------------------------------------------------------

  bit_llr_t ibuffer__ofsLLR [0 : 1] ;
  bit_llr_t ibuffer__ofyLLR [0 : 1] ;
  bit_llr_t ibuffer__ofwLLR [0 : 1] ;

  bit_llr_t ibuffer__obsLLR [0 : 1] ;
  bit_llr_t ibuffer__obyLLR [0 : 1] ;
  bit_llr_t ibuffer__obwLLR [0 : 1] ;

  rsc_dec_input_buffer
  #(
    .pLLR_W  ( pLLR_W    ) ,
    .pLLR_FP ( pLLR_FP   ) ,
    .pADDR_W ( cADDR_W   ) ,
    //
    .pTAG_W  ( cIB_TAG_W ) ,
    //
    .pBNUM_W ( 1         )    // 2D
  )
  ibuffer
  (
    .iclk    ( iclk              ) ,
    .ireset  ( ireset            ) ,
    .iclkena ( iclkena           ) ,
    //
    .iwrite  ( source__owrite    ) ,
    .iwfull  ( source__owfull    ) ,
    .iwsel   ( source__owsel     ) ,
    .iwaddr  ( source__owaddr    ) ,
    .isLLR   ( source__osLLR     ) ,
    .iyLLR   ( source__oyLLR     ) ,
    .iwLLR   ( source__owLLR     ) ,
    //
    .iwtag   ( ibuffer__iwtag    ) ,
    //
    .irempty ( ctrl__obuf_rempty ) ,
    //
    .ifsaddr ( faddr_gen__osaddr[cADDR_W-1 : 0] ) ,
    .ofsLLR  ( ibuffer__ofsLLR                  ) ,
    .ifpaddr ( faddr_gen__opaddr[cADDR_W-1 : 0] ) ,
    .ofyLLR  ( ibuffer__ofyLLR                  ) ,
    .ofwLLR  ( ibuffer__ofwLLR                  ) ,
    //
    .ibsaddr ( baddr_gen__osaddr[cADDR_W-1 : 0] ) ,
    .obsLLR  ( ibuffer__obsLLR                  ) ,
    .ibpaddr ( baddr_gen__opaddr[cADDR_W-1 : 0] ) ,
    .obyLLR  ( ibuffer__obyLLR                  ) ,
    .obwLLR  ( ibuffer__obwLLR                  ) ,
    //
    .ortag   ( ibuffer__ortag    ) ,
    //
    .oempty  ( ibuffer__oempty   ) ,
    .oemptya ( ibuffer__oemptya  ) ,
    .ofull   ( ibuffer__ofull    ) ,
    .ofulla  ( ibuffer__ofulla   )
  );

  //
  // remap signals
  always_comb begin
    dec__ifsLLR = ibuffer__ofsLLR;
    dec__ifyLLR = ibuffer__ofyLLR;
    dec__ifwLLR = ibuffer__ofwLLR;

    dec__ibsLLR = ibuffer__obsLLR;
    dec__ibyLLR = ibuffer__obyLLR;
    dec__ibwLLR = ibuffer__obwLLR;

    if (pCODE != 0) begin
      dec__ifwLLR = '{default : '0};
      dec__ibwLLR = '{default : '0};
    end
  end

  assign {used_Niter, data_tag} = ibuffer__ortag;

  //------------------------------------------------------------------------------------------------------
  // decode permutation type decoder
  //------------------------------------------------------------------------------------------------------

  rsc2_ptable
  ptab
  (
    .iclk     ( iclk        ) ,
    .ireset   ( ireset      ) ,
    .iclkena  ( iclkena     ) ,
    //
    .iptype   ( pPTYPE      ) ,
    //
    .oN       ( used_N      ) ,
    .oNm1     ( used_Nm1    ) ,
    .oNmod15  (             ) ,  // n.u.
    //
    .oP       ( used_P      ) ,
    .oP0comp  ( used_P0comp ) ,
    .oPincr   ( used_Pincr  )
  );

  //------------------------------------------------------------------------------------------------------
  // decoder FSM
  //------------------------------------------------------------------------------------------------------

  rsc_dec_ctrl
  ctrl
  (
    .iclk             ( iclk                   ) ,
    .ireset           ( ireset                 ) ,
    .iclkena          ( iclkena                ) ,
    //
    .iN               ( used_N                 ) ,
    .iNiter           ( used_Niter             ) ,
    //
    .ibuf_full        ( ibuffer__ofull         ) ,  // if ibuffer full start
    .obuf_rempty      ( ctrl__obuf_rempty      ) ,
    .iobuf_empty      ( obuffer__oempty        ) ,  // if obuffer is empty end
    //
    .oaddr_pmode      ( ctrl__oaddr_pmode      ) ,
    .oaddr_clear      ( ctrl__oaddr_clear      ) ,
    .oaddr_enable     ( ctrl__oaddr_enable     ) ,
    //
    .ofirst_sub_stage ( ctrl__ofirst_sub_stage ) ,
    .olast_sub_stage  ( ctrl__olast_sub_stage  ) ,
    .oeven_sub_stage  ( ctrl__oeven_sub_stage  ) ,
    .osub_stage_warm  ( ctrl__osub_stage_warm  ) ,
    //
    .idec_eop         ( dec__oeop              ) ,
    .odec_sop         ( ctrl__odec_sop         ) ,
    .odec_val         ( ctrl__odec_val         ) ,
    .odec_eop         ( ctrl__odec_eop         )
  );

  //------------------------------------------------------------------------------------------------------
  // address generators
  //------------------------------------------------------------------------------------------------------

  rsc_dec_addr_gen
  #(
    .pB_nF ( 0 )
  )
  faddr_gen
  (
    .iclk     ( iclk    ) ,
    .ireset   ( ireset  ) ,
    .iclkena  ( iclkena ) ,
    //
    .ipmode   ( ctrl__oaddr_pmode  ) ,
    .iclear   ( ctrl__oaddr_clear  ) ,
    .ienable  ( ctrl__oaddr_enable ) ,
    //
    .iN       ( used_N             ) ,
    .iNm1     ( used_Nm1           ) ,
    .iP       ( used_P             ) ,
    .iP0comp  ( used_P0comp        ) ,
    .iPincr   ( used_Pincr         ) ,
    .iPdvbinv ( 1'b1               ) ,
    //
    .osaddr   ( faddr_gen__osaddr  ) ,
    .opaddr   ( faddr_gen__opaddr  ) ,
    .obitinv  (  addr_gen__obitinv )
  );

  rsc_dec_addr_gen
  #(
    .pB_nF ( 1 )
  )
  baddr_gen
  (
    .iclk     ( iclk    ) ,
    .ireset   ( ireset  ) ,
    .iclkena  ( iclkena ) ,
    //
    .ipmode   ( ctrl__oaddr_pmode  ) ,
    .iclear   ( ctrl__oaddr_clear  ) ,
    .ienable  ( ctrl__oaddr_enable ) ,
    //
    .iN       ( used_N             ) ,
    .iNm1     ( used_Nm1           ) ,
    .iP       ( used_P             ) ,
    .iP0comp  ( used_P0comp        ) ,
    .iPincr   ( used_Pincr         ) ,
    .iPdvbinv ( 1'b1               ) ,
    //
    .osaddr   ( baddr_gen__osaddr  ) ,
    .opaddr   ( baddr_gen__opaddr  ) ,
    .obitinv  (  ) // n.u.
  );

  //------------------------------------------------------------------------------------------------------
  // decoder engine
  //------------------------------------------------------------------------------------------------------

  rsc2_dec_engine
  #(
    .pLLR_W     ( pLLR_W     ) ,
    .pLLR_FP    ( pLLR_FP    ) ,
    .pADDR_W    ( cADDR_W    ) ,
    .pMM_ADDR_W ( cADDR_W-1  ) , // 1/2 of pN
    .pMMAX_TYPE ( pMMAX_TYPE )
  )
  dec
  (
    .iclk             ( iclk                  ) ,
    .ireset           ( ireset                ) ,
    .iclkena          ( iclkena               ) ,
    //
    .ifirst           ( dec__ifirst           ) ,
    .ilast            ( dec__ilast            ) ,
    .ieven            ( dec__ieven            ) ,
    .ibitswap         ( dec__ibitswap         ) ,
    .iwarm            ( dec__iwarm            ) ,
    //
    .isop             ( dec__isop             ) ,
    .ival             ( dec__ival             ) ,
    .ieop             ( dec__ieop             ) ,
    //
    .ifaddr           ( dec__ifaddr           ) ,
    .ifsLLR           ( dec__ifsLLR           ) ,
    .ifyLLR           ( dec__ifyLLR           ) ,
    .ifwLLR           ( dec__ifwLLR           ) ,
    .ifLextr          ( dec__ifLextr          ) ,
    //
    .ibaddr           ( dec__ibaddr           ) ,
    .ibsLLR           ( dec__ibsLLR           ) ,
    .ibyLLR           ( dec__ibyLLR           ) ,
    .ibwLLR           ( dec__ibwLLR           ) ,
    .ibLextr          ( dec__ibLextr          ) ,
    //
    .if_rp_state_even ( dec__if_rp_state_even ) ,
    .if_rp_state_odd  ( dec__if_rp_state_odd  ) ,
    .ib_rp_state_even ( dec__ib_rp_state_even ) ,
    .ib_rp_state_odd  ( dec__ib_rp_state_odd  ) ,
    //
    .of_rp_state_even ( dec__of_rp_state_even ) ,
    .of_rp_state_odd  ( dec__of_rp_state_odd  ) ,
    .ob_rp_state_even ( dec__ob_rp_state_even ) ,
    .ob_rp_state_odd  ( dec__ob_rp_state_odd  ) ,
    //
    .osop             ( dec__osop             ) ,
    .oeop             ( dec__oeop             ) ,
    .oval             ( dec__oval             ) ,
    .odatval          ( dec__odatval          ) ,
    //
    .ofaddr           ( dec__ofaddr           ) ,
    .ofLextr          ( dec__ofLextr          ) ,
    .ofdat            ( dec__ofdat            ) ,
    //
    .obaddr           ( dec__obaddr           ) ,
    .obLextr          ( dec__obLextr          ) ,
    .obdat            ( dec__obdat            ) ,
    //
    .odone            ( dec__odone            ) ,
    .oerr             ( dec__oerr             )
  );

  assign dec__ifirst            = ctrl__ofirst_sub_stage;
  assign dec__ilast             = ctrl__olast_sub_stage;
  assign dec__ieven             = ctrl__oeven_sub_stage;

  assign dec__if_rp_state_even  = dec__of_rp_state_even;
  assign dec__if_rp_state_odd   = dec__of_rp_state_odd ;
  assign dec__ib_rp_state_even  = dec__ob_rp_state_even;
  assign dec__ib_rp_state_odd   = dec__ob_rp_state_odd ;

  //
  // align input buffer read delay
  always_ff @(posedge iclk) begin
    if (iclkena) begin
      dec__ifaddr   <= faddr_gen__osaddr[cADDR_W-1 : 0];
      dec__ibaddr   <= baddr_gen__osaddr[cADDR_W-1 : 0];
      dec__ibitswap <=  addr_gen__obitinv;
      //
      dec__iwarm    <= ctrl__osub_stage_warm;
      dec__isop     <= ctrl__odec_sop;
      dec__ival     <= ctrl__odec_val;
      dec__ieop     <= ctrl__odec_eop;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // extrinsic buffer
  //------------------------------------------------------------------------------------------------------

  rsc_dec_extr_ram
  #(
    .pDATA_W ( cL_EXT_W*3 ) ,
    .pADDR_W ( cADDR_W    )
  )
  extr_ram
  (
    .iclk    ( iclk      ) ,
    .ireset  ( ireset    ) ,
    .iclkena ( iclkena   ) ,
    //
    .iwrite  ( dec__oval ) ,
    //
    .iwaddr0 (  dec__ofaddr                                        ) ,
    .iwdata0 ( {dec__ofLextr[3], dec__ofLextr[2], dec__ofLextr[1]} ) ,
    //
    .iwaddr1 (  dec__obaddr                                        ) ,
    .iwdata1 ( {dec__obLextr[3], dec__obLextr[2], dec__obLextr[1]} ) ,
    //
    .iread   ( 1'b1      ) ,
    //
    .iraddr0 ( faddr_gen__osaddr[cADDR_W-1 : 0]                    ) ,
    .ordata0 ( {dec__ifLextr[3], dec__ifLextr[2], dec__ifLextr[1]} ) ,
    //
    .iraddr1 ( baddr_gen__osaddr[cADDR_W-1 : 0]                    ) ,
    .ordata1 ( {dec__ibLextr[3], dec__ibLextr[2], dec__ibLextr[1]} )
  );

  //------------------------------------------------------------------------------------------------------
  // output buffer
  //------------------------------------------------------------------------------------------------------

  rsc_dec_output_buffer
  #(
    .pADDR_W ( cADDR_W   ) ,
    .pRDAT_W ( pODAT_W   ) ,
    .pTAG_W  ( cOB_TAG_W ) ,
    .pBNUM_W ( 1         )  // 2D
  )
  obuffer
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    // write side
    .iwrite  ( dec__odatval    ) ,  // write only at last half-iteration
    .iwfull  ( dec__odone      ) ,
    //
    .ifwaddr ( dec__ofaddr     ) ,
    .ifwdat  ( dec__ofdat      ) ,
    .ibwaddr ( dec__obaddr     ) ,
    .ibwdat  ( dec__obdat      ) ,
    //
    .iwtag   ( obuffer__iwtag  ) ,
    // read side
    .irempty ( sink__orempty   ) ,
    .iraddr  ( sink__oraddr    ) ,
    .ordata  ( sink__irdata    ) ,
    //
    .ortag   ( obuffer__ortag  ) ,
    //
    .oempty  ( obuffer__oempty ) ,
    .oemptya (                 ) ,  // n.u.
    .ofull   ( sink__ifull     ) ,
    .ofulla  (                 )    // n.u.
  );

  assign obuffer__iwtag = {dec__oerr, data_tag};

  assign {sink__ierr, sink__itag} = obuffer__ortag;

  //------------------------------------------------------------------------------------------------------
  // sink module
  //------------------------------------------------------------------------------------------------------

  rsc_dec_sink
  #(
    .pADDR_W ( cADDR_W ) ,
    .pDAT_W  ( pODAT_W ) ,
    .pTAG_W  ( pTAG_W  )
  )
  sink
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    //
    .iN      ( used_N        ) ,
    //
    .ifull   ( sink__ifull   ) ,
    .irdata  ( sink__irdata  ) ,
    .ierr    ( sink__ierr    ) ,
    .itag    ( sink__itag    ) ,
    .orempty ( sink__orempty ) ,
    .oraddr  ( sink__oraddr  ) ,
    //
    .ireq    ( 1'b1   ) ,
    .ofull   (        ) ,
    //
    .otag    ( otag   ) ,
    .osop    ( osop   ) ,
    .oeop    ( oeop   ) ,
    .oval    ( oval   ) ,
    .odat    ( odat   ) ,
    .oerr    ( oerr   )
  );

endmodule


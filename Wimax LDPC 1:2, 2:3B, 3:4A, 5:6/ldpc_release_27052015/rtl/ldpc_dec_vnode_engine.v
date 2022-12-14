/*



  parameter int pCODE     = 1 ;
  parameter int pN        = 1 ;
  parameter int pLLR_W    = 1 ;
  parameter bit pUSE_NORM = 1 ;
  parameter bit pUSE_PIPE = 1 ;



  logic  ldpc_dec_vnode_engine__iclk        ;
  logic  ldpc_dec_vnode_engine__ireset      ;
  logic  ldpc_dec_vnode_engine__iclkena     ;
  logic  ldpc_dec_vnode_engine__isop        ;
  logic  ldpc_dec_vnode_engine__ival        ;
  logic  ldpc_dec_vnode_engine__ieop        ;
  logic  ldpc_dec_vnode_engine__iload       ;
  tcnt_t ldpc_dec_vnode_engine__itcnt       ;
  llr_t  ldpc_dec_vnode_engine__iLLR        ;
  node_t ldpc_dec_vnode_engine__icnode [pC] ;
  logic  ldpc_dec_vnode_engine__osop        ;
  logic  ldpc_dec_vnode_engine__oval        ;
  logic  ldpc_dec_vnode_engine__oeop        ;
  tcnt_t ldpc_dec_vnode_engine__otcnt       ;
  node_t ldpc_dec_vnode_engine__ovnode [pC] ;
  logic  ldpc_dec_vnode_engine__obitsop     ;
  logic  ldpc_dec_vnode_engine__obitval     ;
  logic  ldpc_dec_vnode_engine__obiteop     ;
  logic  ldpc_dec_vnode_engine__obitdat     ;
  logic  ldpc_dec_vnode_engine__obiterr     ;



  ldpc_dec_vnode_engine
  #(
    .pCODE      ( pCODE     ) ,
    .pN         ( pN        ) ,
    .pLLR_W     ( pLLR_W    ) ,
    .pUSE_NORM  ( pUSE_NORM ) ,
    .pUSE_PIPE  ( pUSE_PIPE )
  )
  ldpc_dec_vnode_engine
  (
    .iclk    ( ldpc_dec_vnode_engine__iclk    ) ,
    .ireset  ( ldpc_dec_vnode_engine__ireset  ) ,
    .iclkena ( ldpc_dec_vnode_engine__iclkena ) ,
    .isop    ( ldpc_dec_vnode_engine__isop    ) ,
    .ival    ( ldpc_dec_vnode_engine__ival    ) ,
    .ieop    ( ldpc_dec_vnode_engine__ieop    ) ,
    .iload   ( ldpc_dec_vnode_engine__iload   ) ,
    .itcnt   ( ldpc_dec_vnode_engine__itcnt   ) ,
    .iLLR    ( ldpc_dec_vnode_engine__iLLR    ) ,
    .icnode  ( ldpc_dec_vnode_engine__icnode  ) ,
    .osop    ( ldpc_dec_vnode_engine__osop    ) ,
    .oval    ( ldpc_dec_vnode_engine__oval    ) ,
    .oeop    ( ldpc_dec_vnode_engine__oeop    ) ,
    .otcnt   ( ldpc_dec_vnode_engine__otcnt   ) ,
    .ovnode  ( ldpc_dec_vnode_engine__ovnode  ) ,
    .obitsop ( ldpc_dec_vnode_engine__obitsop ) ,
    .obitval ( ldpc_dec_vnode_engine__obitval ) ,
    .obiteop ( ldpc_dec_vnode_engine__obiteop ) ,
    .obitdat ( ldpc_dec_vnode_engine__obitdat ) ,
    .obiterr ( ldpc_dec_vnode_engine__obiterr )
  );


  assign ldpc_dec_vnode_engine__iclk    = '0 ;
  assign ldpc_dec_vnode_engine__ireset  = '0 ;
  assign ldpc_dec_vnode_engine__iclkena = '0 ;
  assign ldpc_dec_vnode_engine__isop    = '0 ;
  assign ldpc_dec_vnode_engine__ival    = '0 ;
  assign ldpc_dec_vnode_engine__ieop    = '0 ;
  assign ldpc_dec_vnode_engine__iload   = '0 ;
  assign ldpc_dec_vnode_engine__itcnt   = '0 ;
  assign ldpc_dec_vnode_engine__iLLR    = '0 ;
  assign ldpc_dec_vnode_engine__icnode  = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_dec_vnode_engine.v
// Description   : LDPC decoder variable node arithmetic eengine: read cnode and count vnode. Count aposteriory  L(Qi)   = L(Pi) + sum(L(rji) and
//                  vnode update values L(qij)  = L(Pi) + sum(Lrij)|(i ~= j) = L(Qi) - L(rji)|(i == j)
//

`include "define.vh"

module ldpc_dec_vnode_engine
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  isop    ,
  ival    ,
  ieop    ,
  iload   ,
  itcnt   ,
  iLLR    ,
  icnode  ,
  //
  osop    ,
  oval    ,
  oeop    ,
  otcnt   ,
  ovnode  ,
  //
  obitsop ,
  obitval ,
  obiteop ,
  obitdat ,
  obiterr
);

  parameter int pLLR_W        = 4;
  parameter int pLLR_BY_CYCLE = 1;
  parameter bit pUSE_NORM     = 1;  // use normalization
  parameter bit pUSE_PIPE     = 1;

  `include "ldpc_parameters.vh"
  `include "ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic  iclk         ;
  input  logic  ireset       ;
  input  logic  iclkena      ;
  //
  input  logic  isop         ;
  input  logic  ival         ;
  input  logic  ieop         ;
  input  logic  iload        ;
  input  tcnt_t itcnt        ;
  input  llr_t  iLLR         ;
  input  node_t icnode  [pC] ;
  //
  output logic  osop         ;
  output logic  oval         ;
  output logic  oeop         ;
  output tcnt_t otcnt        ;
  output node_t ovnode  [pC] ;
  //
  output logic  obitsop      ;
  output logic  obitval      ;
  output logic  obiteop      ;
  output logic  obitdat      ;
  output logic  obiterr      ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cCN_SUM_STAGE_NUM     = clogb2(pC+1);
  localparam int cCN_SUM_NUM_PER_STAGE = 2**(cCN_SUM_STAGE_NUM-1);

  localparam int cCN_SUM_W             = cNODE_W + cCN_SUM_STAGE_NUM;

  typedef logic signed [cCN_SUM_W-1 : 0] cn_sum_t;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  node_t    cnode2sum  [2*cCN_SUM_NUM_PER_STAGE];

  node_t    cnode      [cCN_SUM_STAGE_NUM][pC]  /* synthesis keep*/;
  llr_t     LLR        [cCN_SUM_STAGE_NUM]      /* synthesis keep*/;
  tcnt_t    tcnt       [cCN_SUM_STAGE_NUM]      /* synthesis keep*/;

  cn_sum_t  cn_sum     [cCN_SUM_STAGE_NUM][cCN_SUM_NUM_PER_STAGE];

  cn_sum_t  vnode      [pC];
  cn_sum_t  vnode_norm [pC];

  tcnt_t    tcnt2out;

  logic  [cCN_SUM_STAGE_NUM : 0] sop    /* synthesis keep */; // + 1 bit
  logic  [cCN_SUM_STAGE_NUM : 0] eop    /* synthesis keep */;
  logic  [cCN_SUM_STAGE_NUM : 0] val    /* synthesis keep */;
  logic  [cCN_SUM_STAGE_NUM : 0] load   /* synthesis keep */;

  //------------------------------------------------------------------------------------------------------
  // controls
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      val <= '0;
    else if (iclkena) begin
      val <= (val << 1) | ival;
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      sop   <= (sop << 1)  | isop;
      eop   <= (eop << 1)  | ieop;
      load  <= (load << 1) | iload;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // L(Qi) = L(Pi) + sum(L(rji)
  //------------------------------------------------------------------------------------------------------

  always_comb begin
    for (int i = 0; i < 2*cCN_SUM_NUM_PER_STAGE; i++) begin
      if (i == 0)
        cnode2sum[i] = iLLR <<< (cNODE_W - pLLR_W); // align fixed point
      else if (i < (pC+1))
        cnode2sum[i] = icnode[i-1];
      else
        cnode2sum[i] = '0;
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      for (int stage = 0; stage < cCN_SUM_STAGE_NUM; stage++) begin
        if (stage == 0) begin
          cnode[stage][0:pC-1]  <= icnode[0:pC-1];
          LLR  [stage]          <= iLLR;
          tcnt [stage]          <= itcnt;
          for (int i = 0; i < cCN_SUM_NUM_PER_STAGE; i++) begin
            cn_sum[stage][i] <= cnode2sum[2*i] + cnode2sum[2*i+1];
          end
        end
        else begin
          cnode[stage] <= cnode[stage-1];
          LLR  [stage] <= LLR  [stage-1];
          tcnt [stage] <= tcnt [stage-1];
          for (int i = 0; i < (cCN_SUM_NUM_PER_STAGE >> stage); i++) begin
            cn_sum[stage][i] <= cn_sum[stage-1][2*i] + cn_sum[stage-1][2*i+1];
          end
        end
      end // stage
    end // iclkena
  end

  //------------------------------------------------------------------------------------------------------
  // L(qij) = = L(Qi) - L(rji)|(i == j)
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      tcnt2out <= tcnt[cCN_SUM_STAGE_NUM-1];
      for (int i = 0; i < pC; i++) begin
        vnode[i] <= cn_sum[cCN_SUM_STAGE_NUM-1][0] - cnode[cCN_SUM_STAGE_NUM-1][i];
      end
    end
  end

  generate
    if (pUSE_PIPE) begin
      always_ff @(posedge iclk or posedge ireset) begin
        if (ireset)
          oval <= 1'b0;
        else if (iclkena)
          oval <= val[cCN_SUM_STAGE_NUM];
      end

      always_ff @(posedge iclk) begin
        if (iclkena) begin
          osop  <= sop[cCN_SUM_STAGE_NUM];
          oeop  <= eop[cCN_SUM_STAGE_NUM];
          otcnt <= tcnt2out;
          for (int i = 0; i < pC; i++) begin
            vnode_norm[i] <= load[cCN_SUM_STAGE_NUM] ? vnode[i] : normalize(vnode[i]);
          end
        end
      end

      // register for ovnode is outside
      always_comb begin
        for (int i = 0; i < pC; i++) begin
          ovnode[i] = saturate(vnode_norm[i]);
        end
      end
    end
    else begin
      assign osop  = sop[cCN_SUM_STAGE_NUM];
      assign oval  = val[cCN_SUM_STAGE_NUM];
      assign oeop  = eop[cCN_SUM_STAGE_NUM];
      assign otcnt = tcnt2out;

      // register for ovnode is outside
      always_comb begin
        for (int i = 0; i < pC; i++) begin
          vnode_norm[i] = normalize(vnode[i]);
          ovnode[i]     = load[cCN_SUM_STAGE_NUM] ? vnode[i][cNODE_W-1 : 0] : saturate(vnode_norm[i]);
        end
      end
    end
  endgenerate

  //------------------------------------------------------------------------------------------------------
  // aposteriory LLR decoding
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    obitdat <= cn_sum[cCN_SUM_STAGE_NUM-1][0][cCN_SUM_W-1];
    obiterr <= cn_sum[cCN_SUM_STAGE_NUM-1][0][cCN_SUM_W-1] ^ LLR[cCN_SUM_STAGE_NUM-1][pLLR_W-1];
  end

  assign obitsop = sop[cCN_SUM_STAGE_NUM];
  assign obitval = val[cCN_SUM_STAGE_NUM];
  assign obiteop = eop[cCN_SUM_STAGE_NUM];

  //------------------------------------------------------------------------------------------------------
  // used functions
  //------------------------------------------------------------------------------------------------------

  function automatic cn_sum_t normalize (input cn_sum_t dat);
    logic signed [cCN_SUM_W+2 : 0] tmp; // +3 bit
  begin
    if (pUSE_NORM) begin // 0.875
      tmp = (dat <<< 3) - dat + (dat[cCN_SUM_W-1] ? 3 : 4);
//    tmp = (dat <<< 3) - dat + 4;
      normalize = tmp[cCN_SUM_W+2 : 3];
    end
    else begin
      normalize = dat;
    end
  end
  endfunction

  function automatic node_t saturate (input cn_sum_t dat);
    logic                           sign;
    logic [cCN_SUM_W-1 : cNODE_W-1] sbits;
    logic                           overflow;
  begin
    sign      = dat[cCN_SUM_W-1];

    sbits     = sign ? ~dat[cCN_SUM_W-1 : cNODE_W-1] : dat[cCN_SUM_W-1 : cNODE_W-1];

    overflow  = (sbits != 0);

    saturate  = overflow ? {sign, {(cNODE_W-1){~sign}}} : dat[cNODE_W-1 : 0];
  end
  endfunction

endmodule

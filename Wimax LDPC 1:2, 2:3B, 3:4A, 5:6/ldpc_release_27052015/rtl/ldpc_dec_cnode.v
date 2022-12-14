/*



  parameter int pCODE          = 1 ;
  parameter int pN             = 1 ;
  parameter int pLLR_W         = 4 ;
  parameter int pLLR_BY_CYCLE  = 1 ;
  parameter bit pUSE_NORM      = 1 ;



  logic      ldpc_dec_cnode__iclk                        ;
  logic      ldpc_dec_cnode__ireset                      ;
  logic      ldpc_dec_cnode__iclkena                     ;
  logic      ldpc_dec_cnode__isop                        ;
  logic      ldpc_dec_cnode__ival                        ;
  logic      ldpc_dec_cnode__ieop                        ;
  tcnt_t     ldpc_dec_cnode__itcnt                       ;
  zcnt_t     ldpc_dec_cnode__izcnt                       ;
  logic      ldpc_dec_cnode__ivmask  [pC]                ;
  node_t     ldpc_dec_cnode__ivnode  [pC][pLLR_BY_CYCLE] ;
  logic      ldpc_dec_cnode__osop                        ;
  logic      ldpc_dec_cnode__oval                        ;
  mem_addr_t ldpc_dec_cnode__oaddr   [pC][pLLR_BY_CYCLE] ;
  mem_sela_t ldpc_dec_cnode__osela   [pC][pLLR_BY_CYCLE] ;
  logic      ldpc_dec_cnode__omask   [pC]                ;
  node_t     ldpc_dec_cnode__ocnode  [pC][pLLR_BY_CYCLE] ;
  logic      ldpc_dec_cnode__obusy                       ;



  ldpc_dec_cnode
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pUSE_NORM     ( pUSE_NORM     )
  )
  ldpc_dec_cnode
  (
    .iclk    ( ldpc_dec_cnode__iclk    ) ,
    .ireset  ( ldpc_dec_cnode__ireset  ) ,
    .iclkena ( ldpc_dec_cnode__iclkena ) ,
    .isop    ( ldpc_dec_cnode__isop    ) ,
    .ival    ( ldpc_dec_cnode__ival    ) ,
    .ieop    ( ldpc_dec_cnode__ieop    ) ,
    .itcnt   ( ldpc_dec_cnode__itcnt   ) ,
    .izcnt   ( ldpc_dec_cnode__izcnt   ) ,
    .ivmask  ( ldpc_dec_cnode__ivmask  ) ,
    .ivnode  ( ldpc_dec_cnode__ivnode  ) ,
    .osop    ( ldpc_dec_cnode__osop    ) ,
    .oval    ( ldpc_dec_cnode__oval    ) ,
    .oaddr   ( ldpc_dec_cnode__oaddr   ) ,
    .osela   ( ldpc_dec_cnode__osela   ) ,
    .omask   ( ldpc_dec_cnode__omask   ) ,
    .ocnode  ( ldpc_dec_cnode__ocnode  ) ,
    .obusy   ( ldpc_dec_cnode__obusy   )
  );


  assign ldpc_dec_cnode__iclk    = '0 ;
  assign ldpc_dec_cnode__ireset  = '0 ;
  assign ldpc_dec_cnode__iclkena = '0 ;
  assign ldpc_dec_cnode__isop    = '0 ;
  assign ldpc_dec_cnode__ival    = '0 ;
  assign ldpc_dec_cnode__ieop    = '0 ;
  assign ldpc_dec_cnode__itcnt   = '0 ;
  assign ldpc_dec_cnode__izcnt   = '0 ;
  assign ldpc_dec_cnode__ivmask  = '0 ;
  assign ldpc_dec_cnode__ivnode  = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_dec_cnode.v
// Description   : LDPC decoder check node arithmetic top module: read vnode and count cnode. Consist of pC*pLLR_BY_CYCLE engines.
//

`include "define.vh"

module ldpc_dec_cnode
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  isop    ,
  ival    ,
  ieop    ,
  itcnt   ,
  izcnt   ,
  ivmask  ,
  ivnode  ,
  //
  oval    ,
  oaddr   ,
  osela   ,
  omask   ,
  ocnode  ,
  //
  obusy
);

  parameter int pLLR_W        = 4;
  parameter int pLLR_BY_CYCLE = 2;
  parameter bit pUSE_NORM     = 1;

  `include "ldpc_parameters.vh"
  `include "ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic      iclk                        ;
  input  logic      ireset                      ;
  input  logic      iclkena                     ;
  //
  input  logic      isop                        ;
  input  logic      ival                        ;
  input  logic      ieop                        ;
  input  tcnt_t     itcnt                       ;
  input  zcnt_t     izcnt                       ;
  input  logic      ivmask  [pC]                ;
  input  node_t     ivnode  [pC][pLLR_BY_CYCLE] ;
  //
  output logic      oval                        ;
  output mem_addr_t oaddr   [pC][pLLR_BY_CYCLE] ;
  output mem_sela_t osela   [pC][pLLR_BY_CYCLE] /* synthesis keep */;
  output logic      omask   [pC]                ;
  output node_t     ocnode  [pC][pLLR_BY_CYCLE] ;
  //
  output logic      obusy                       ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic  engine__oval       [pC][pLLR_BY_CYCLE] ;
  tcnt_t engine__otcnt      [pC][pLLR_BY_CYCLE] ;
  logic  engine__otcnt_zero [pC][pLLR_BY_CYCLE] ;
  zcnt_t engine__ozcnt      [pC][pLLR_BY_CYCLE] ;
  node_t engine__ocnode     [pC][pLLR_BY_CYCLE] ;

  logic  engine__obusy      [pC][pLLR_BY_CYCLE] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  generate
    genvar gc, gllra;
    for (gc = 0; gc < pC; gc++) begin : engine_inst_c_gen
      for (gllra = 0; gllra < pLLR_BY_CYCLE; gllra++) begin : engine_inst_llra_gen
        ldpc_dec_cnode_engine
        #(
          .pCODE         ( pCODE         ) ,
          .pN            ( pN            ) ,
          .pLLR_W        ( pLLR_W        ) ,
          .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
          .pUSE_NORM     ( pUSE_NORM     )
        )
        engine
        (
          .iclk       ( iclk    ) ,
          .ireset     ( ireset  ) ,
          .iclkena    ( iclkena ) ,
          //
          .isop       ( isop                           ) ,
          .ival       ( ival                           ) ,
          .ieop       ( ieop                           ) ,
          .itcnt      ( itcnt                          ) ,
          .izcnt      ( izcnt                          ) ,
          .ivmask     ( ivmask             [gc]        ) ,
          .ivnode     ( ivnode             [gc][gllra] ) ,
          //
          .oval       ( engine__oval       [gc][gllra] ) ,
          .otcnt      ( engine__otcnt      [gc][gllra] ) ,
          .otcnt_zero ( engine__otcnt_zero [gc][gllra] ) ,
          .ozcnt      ( engine__ozcnt      [gc][gllra] ) ,
          .ocnode     ( engine__ocnode     [gc][gllra] ) ,
          //
          .obusy      ( engine__obusy      [gc][gllra] )
        );
      end
    end
  endgenerate

  //------------------------------------------------------------------------------------------------------
  // tables for address generation
  //------------------------------------------------------------------------------------------------------

  logic       used_busy;
  logic       used_val;
  tcnt_t      used_tcnt;
  logic       used_tcnt_zero;
  zcnt_t      used_zcnt;

  mem_addr_t  zacc;
  paddr_t     raddr     [pC];

  paddr_t     raddr2out [pC];
  tcnt_t      tcnt2out;
  zcnt_t      zcnt2out;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  addr_tab_t addr_tab;

  always_comb begin
`ifdef MODEL_TECH
    addr_tab = get_addr_tab(0); // no print file
`else
    `include "ldpc_dec_addr_gen_tab.vh"
`endif
  end

  //------------------------------------------------------------------------------------------------------
  // output data and address generation
  //------------------------------------------------------------------------------------------------------

  assign used_val       = engine__oval        [0][0];
  assign used_busy      = engine__obusy       [0][0];
  assign used_tcnt      = engine__otcnt       [0][0];
  assign used_tcnt_zero = engine__otcnt_zero  [0][0];
  assign used_zcnt      = engine__ozcnt       [0][0];

  assign obusy = used_busy;

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= used_val;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      // address generation (start at 1 tick early)
      if (used_busy) begin
        zacc <= used_tcnt_zero ? '0 : (zacc + cZ_MAX[cADDR_W-1 : 0]);
        // mux and shift address
        for (int c = 0; c < pC; c++) begin
          raddr[c].baddr <= get_mod(addr_tab[c][used_tcnt][0].baddr, used_zcnt, cZ_MAX);
        end
        tcnt2out <= used_tcnt;
        zcnt2out <= used_zcnt;
      end
      // data output
      if (used_val) begin
        ocnode  <= engine__ocnode;
        // mux and shift address delay
        for (int c = 0; c < pC; c++) begin
          raddr2out[c].baddr <= zacc + raddr[c].baddr;
          for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
            raddr2out[c].offset[llra] <= addr_tab[c][tcnt2out][zcnt2out].offset [llra];
            raddr2out[c].sela[llra]   <= addr_tab[c][tcnt2out][0].sela          [llra];
          end
        end
      end
    end
  end

  always_comb begin
    for (int c = 0; c < pC; c++) begin
      omask[c] = 1'b0; // no write mask
      for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
        oaddr[c][llra] = raddr2out[c].baddr + raddr2out[c].offset[llra];
        osela[c][llra] = raddr2out[c].sela[llra];
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // used function
  //------------------------------------------------------------------------------------------------------

  typedef logic [cF_ZCNT_W-1 : 0] dat_t;
  typedef logic [cF_ZCNT_W   : 0] dat_p1_t;

  function dat_t get_mod (input dat_t acc, incr, mod);
    dat_p1_t  acc_next;
    dat_p1_t  acc_next_mod;
  begin
    acc_next     = acc + incr;
    acc_next_mod = acc_next - mod;
    get_mod      = acc_next_mod[cF_ZCNT_W] ? acc_next[cF_ZCNT_W-1 : 0] : acc_next_mod[cF_ZCNT_W-1 : 0];
  end
  endfunction

endmodule

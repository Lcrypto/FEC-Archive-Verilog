/*



  parameter int pCODE          = 8 ;
  parameter int pN             = 1 ;
  parameter int pLLR_W         = 1 ;
  parameter int pLLR_BY_CYCLE  = 1 ;
  parameter int pTAG_W         = 1 ;



  logic                     ldpc_dec_mem__iclk                         ;
  logic                     ldpc_dec_mem__ireset                       ;
  logic                     ldpc_dec_mem__iclkena                      ;
  logic      [pTAG_W-1 : 0] ldpc_dec_mem__irtag                        ;
  mem_addr_t                ldpc_dec_mem__iraddr   [pC][pLLR_BY_CYCLE] ;
  mem_sela_t                ldpc_dec_mem__irsela   [pC][pLLR_BY_CYCLE] ;
  logic                     ldpc_dec_mem__irmask   [pC]                ;
  logic      [pTAG_W-1 : 0] ldpc_dec_mem__ortag                        ;
  logic                     ldpc_dec_mem__ormask   [pC]                ;
  node_t                    ldpc_dec_mem__ordat    [pC][pLLR_BY_CYCLE] ;
  logic                     ldpc_dec_mem__iwrite                       ;
  mem_addr_t                ldpc_dec_mem__iwaddr   [pC][pLLR_BY_CYCLE] ;
  mem_sela_t                ldpc_dec_mem__iwsela   [pC][pLLR_BY_CYCLE] ;
  logic                     ldpc_dec_mem__iwmask   [pC]                ;
  node_t                    ldpc_dec_mem__iwdat    [pC][pLLR_BY_CYCLE] ;



  ldpc_dec_mem
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pTAG_W        ( pTAG_W        )
  )
  ldpc_dec_mem
  (
    .iclk    ( ldpc_dec_mem__iclk    ) ,
    .ireset  ( ldpc_dec_mem__ireset  ) ,
    .iclkena ( ldpc_dec_mem__iclkena ) ,
    .irtag   ( ldpc_dec_mem__irtag   ) ,
    .iraddr  ( ldpc_dec_mem__iraddr  ) ,
    .irsela  ( ldpc_dec_mem__irsela  ) ,
    .irmask  ( ldpc_dec_mem__irmask  ) ,
    .ortag   ( ldpc_dec_mem__ortag   ) ,
    .ormask  ( ldpc_dec_mem__ormask  ) ,
    .ordat   ( ldpc_dec_mem__ordat   ) ,
    .iwrite  ( ldpc_dec_mem__iwrite  ) ,
    .iwaddr  ( ldpc_dec_mem__iwaddr  ) ,
    .iwsela  ( ldpc_dec_mem__iwsela  ) ,
    .iwmask  ( ldpc_dec_mem__iwmask  ) ,
    .iwdat   ( ldpc_dec_mem__iwdat   )
  );


  assign ldpc_dec_mem__iclk    = '0 ;
  assign ldpc_dec_mem__ireset  = '0 ;
  assign ldpc_dec_mem__iclkena = '0 ;
  assign ldpc_dec_mem__irtag   = '0 ;
  assign ldpc_dec_mem__iraddr  = '0 ;
  assign ldpc_dec_mem__irsela  = '0 ;
  assign ldpc_dec_mem__irmask  = '0 ;
  assign ldpc_dec_mem__iwrite  = '0 ;
  assign ldpc_dec_mem__iwaddr  = '0 ;
  assign ldpc_dec_mem__iwsela  = '0 ;
  assign ldpc_dec_mem__iwmask  = '0 ;
  assign ldpc_dec_mem__iwdat   = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_dec_mem.v
// Description   : Special shift ram array for LDPC parallel decoding
//

`include "define.vh"

module ldpc_dec_mem
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  irtag   ,
  iraddr  ,
  irsela  ,
  irmask  ,
  ortag   ,
  ormask  ,
  ordat   ,
  //
  iwrite  ,
  iwaddr  ,
  iwsela  ,
  iwmask  ,
  iwdat
);

  parameter int pLLR_W        = 4;
  parameter int pLLR_BY_CYCLE = 8;
  parameter int pTAG_W        = 2;

  `include "ldpc_parameters.vh"
  `include "ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                     iclk                        ;
  input  logic                     ireset                      ;
  input  logic                     iclkena                     ;
  //
  input  logic      [pTAG_W-1 : 0] irtag                       ;
  input  mem_addr_t                iraddr  [pC][pLLR_BY_CYCLE] ;
  input  mem_sela_t                irsela  [pC][pLLR_BY_CYCLE] ;
  input  logic                     irmask  [pC]                ;
  output logic      [pTAG_W-1 : 0] ortag                       ;
  output logic                     ormask  [pC]                ;
  output node_t                    ordat   [pC][pLLR_BY_CYCLE] ;
  //
  input  logic                     iwrite                      ;
  input  mem_addr_t                iwaddr  [pC][pLLR_BY_CYCLE] ;
  input  mem_sela_t                iwsela  [pC][pLLR_BY_CYCLE] ;
  input  logic                     iwmask  [pC]                ;
  input  node_t                    iwdat   [pC][pLLR_BY_CYCLE] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

//node_t                mem [pC][pLLR_BY_CYCLE][cLDPC_NUM/pLLR_BY_CYCLE] /* synthesis ramstyle = "no_rw_check" */; // stupid QUA

`ifdef MODEL_TECH
  bit   [cNODE_W-1 : 0] mem [pC][pLLR_BY_CYCLE][2**cADDR_W];
`endif

  logic                 write;
  mem_addr_t            waddr    [pC][pLLR_BY_CYCLE];
  node_t                wdat     [pC][pLLR_BY_CYCLE];

  logic  [pTAG_W-1 : 0]  rtag_r1                      /* synthesis keep */;
  mem_sela_t            rsela_r1 [pC][pLLR_BY_CYCLE]  /* synthesis keep */;
  logic                 rmask_r1 [pC]                 /* synthesis keep */;

  mem_addr_t            raddr    [pC][pLLR_BY_CYCLE]  /* synthesis keep */;

  logic  [pTAG_W-1 : 0]  rtag_r0                      /* synthesis keep */;
  mem_sela_t            rsela_r0 [pC][pLLR_BY_CYCLE]  /* synthesis keep */;
  logic                 rmask_r0 [pC]                 /* synthesis keep */;
  node_t                 rdat_r0 [pC][pLLR_BY_CYCLE]  /* synthesis keep */;

  logic  [pTAG_W-1 : 0] rtag                          /* synthesis keep */;
  mem_sela_t            rsela    [pC][pLLR_BY_CYCLE]  /* synthesis keep */;
  logic                 rmask    [pC]                 /* synthesis keep */;
  node_t                rdat     [pC][pLLR_BY_CYCLE]  /* synthesis keep */;

  //------------------------------------------------------------------------------------------------------
  // write muxed data : take 2 cycle
  //------------------------------------------------------------------------------------------------------

  mem_sela_t twsela  [pC][pLLR_BY_CYCLE];

  always_comb begin
    for (int c = 0; c < pC; c++) begin
      for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
        twsela[c][iwsela[c][llra]] = llra[cSELA_W-1 : 0];
      end
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      write <= iwrite;
      waddr <= iwaddr;
      for (int c = 0; c < pC; c++) begin
        for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
          wdat [c][llra] <= iwmask[c] ? {1'b1, {(cNODE_W-1){1'b0}}} : iwdat[c][twsela[c][llra]];
        end
      end
      //
//    if (write) begin  // stupid QUA
//      for (int c = 0; c < pC; c++) begin
//        for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
//          mem[c][llra][waddr[c][llra]] <= wdat[c][llra];
//        end
//      end
//    end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // read masked data : take 4 cycles
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      // + 1
       rtag_r1 <= irtag;
      rsela_r1 <= irsela;
      rmask_r1 <= irmask;
      raddr    <= iraddr;
      // + 2
       rtag_r0 <=  rtag_r1;
      rsela_r0 <= rsela_r1;
      rmask_r0 <= rmask_r1;
//    for (int c = 0; c < pC; c++) begin // stupid QUA
//      for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
//        rdat_r0[c][llra] <= mem[c][llra][raddr[c][llra]];
//      end
//    end
      // + 3
      rtag  <=  rtag_r0;
      rsela <= rsela_r0;
      rmask <= rmask_r0;
//    rdat  <=  rdat_r0;  // stupid QUA
      // + 4
      ortag   <= rtag;
      ormask  <= rmask;
      for (int c = 0; c < pC; c++) begin
        for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
          ordat[c][llra] <= rmask[c] ? '0 : rdat[c][rsela[c][llra]];
        end
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  generate
    genvar gc, gllra;
    for (gc = 0; gc < pC; gc++) begin : mem_c
      for (gllra = 0; gllra < pLLR_BY_CYCLE; gllra++) begin : mem_llra
        ldpc_dec_mem_block
        #(
          .pADDR_W ( cADDR_W ) ,
          .pDAT_W  ( cNODE_W )
        )
        memb
        (
          .iclk    ( iclk    ) ,
          .ireset  ( ireset  ) ,
          .iclkena ( iclkena ) ,
          //
          .iwrite  ( write             ) ,
          .iwaddr  ( waddr [gc][gllra] ) ,
          .iwdat   ( wdat  [gc][gllra] ) ,
          //
          .iraddr  ( raddr [gc][gllra] ) ,
          .ordat   ( rdat  [gc][gllra] )
        );
        //
`ifdef MODEL_TECH
        assign mem[gc][gllra] = memb.mem;
`endif
      end
    end
  endgenerate

endmodule

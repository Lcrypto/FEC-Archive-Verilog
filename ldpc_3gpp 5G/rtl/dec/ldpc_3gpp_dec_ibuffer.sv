/*



  parameter int pIDX_GR       =   0 ;
  parameter int pCODE         =   4 ;
  parameter int pDO_PUNCT     =   0 ;
  //
  parameter int pD_ADDR_W      =  8 ;
  parameter int pP_ADDR_W      =  8 ;
  //
  parameter int pLLR_W         =  5 ;
  //
  parameter int pROW_BY_CYCLE  =  1 ;
  parameter int pLLR_BY_CYCLE  =  8 ;
  //
  parameter int pTAG_W         =  8 ;



  logic                       ldpc_3gpp_dec_ibuffer__iclk                                                  ;
  logic                       ldpc_3gpp_dec_ibuffer__ireset                                                ;
  logic                       ldpc_3gpp_dec_ibuffer__iclkena                                               ;
  //
  logic [cCOL_BY_CYCLE-1 : 0] ldpc_3gpp_dec_ibuffer__iwrite                                                ;
  logic               [1 : 0] ldpc_3gpp_dec_ibuffer__iclear                                                ;
  logic [pROW_BY_CYCLE-1 : 0] ldpc_3gpp_dec_ibuffer__ipwrite                                               ;
  logic [pROW_BY_CYCLE-1 : 0] ldpc_3gpp_dec_ibuffer__ipclear                                               ;
  logic                       ldpc_3gpp_dec_ibuffer__iwfull                                                ;
  logic     [pP_ADDR_W-1 : 0] ldpc_3gpp_dec_ibuffer__iwaddr                                                ;
  llr_t                       ldpc_3gpp_dec_ibuffer__iLLR                                  [pLLR_BY_CYCLE] ;
  logic        [pTAG_W-1 : 0] ldpc_3gpp_dec_ibuffer__iwtag                                                 ;
  //
  logic                       ldpc_3gpp_dec_ibuffer__irempty                                               ;
  logic     [pP_ADDR_W-1 : 0] ldpc_3gpp_dec_ibuffer__iraddr                                                ;
  llr_t                       ldpc_3gpp_dec_ibuffer__oLLR                   [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  llr_t                       ldpc_3gpp_dec_ibuffer__opLLR   [pROW_BY_CYCLE]               [pLLR_BY_CYCLE] ;
  logic        [pTAG_W-1 : 0] ldpc_3gpp_dec_ibuffer__ortag                                                 ;
  //
  logic                       ldpc_3gpp_dec_ibuffer__oempty                                                ;
  logic                       ldpc_3gpp_dec_ibuffer__oemptya                                               ;
  logic                       ldpc_3gpp_dec_ibuffer__ofull                                                 ;
  logic                       ldpc_3gpp_dec_ibuffer__ofulla                                                ;



  ldpc_3gpp_dec_ibuffer
  #(
    .pIDX_GR       ( pIDX_GR       ) ,
    .pCODE         ( pCODE         ) ,
    .pDO_PUNCT     ( pDO_PUNCT     ) ,
    //
    .pD_ADDR_W     ( pD_ADDR_W     ) ,
    .pP_ADDR_W     ( pP_ADDR_W     ) ,
    //
    .pLLR_W        ( pLLR_W        ) ,
    //
    .pROW_BY_CYCLE ( pROW_BY_CYCLE ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    //
    .pTAG_W        ( pTAG_W        )
  )
  ldpc_3gpp_dec_ibuffer
  (
    .iclk    ( ldpc_3gpp_dec_ibuffer__iclk    ) ,
    .ireset  ( ldpc_3gpp_dec_ibuffer__ireset  ) ,
    .iclkena ( ldpc_3gpp_dec_ibuffer__iclkena ) ,
    //
    .iwrite  ( ldpc_3gpp_dec_ibuffer__iwrite  ) ,
    .iclear  ( ldpc_3gpp_dec_ibuffer__iclear  ) ,
    .ipwrite ( ldpc_3gpp_dec_ibuffer__ipwrite ) ,
    .ipclear ( ldpc_3gpp_dec_ibuffer__ipclear ) ,
    .iwfull  ( ldpc_3gpp_dec_ibuffer__iwfull  ) ,
    .iwaddr  ( ldpc_3gpp_dec_ibuffer__iwaddr  ) ,
    .iLLR    ( ldpc_3gpp_dec_ibuffer__iLLR    ) ,
    .iwtag   ( ldpc_3gpp_dec_ibuffer__iwtag   ) ,
    //
    .irempty ( ldpc_3gpp_dec_ibuffer__irempty ) ,
    .iraddr  ( ldpc_3gpp_dec_ibuffer__iraddr  ) ,
    .oLLR    ( ldpc_3gpp_dec_ibuffer__oLLR    ) ,
    .opLLR   ( ldpc_3gpp_dec_ibuffer__opLLR   ) ,
    .ortag   ( ldpc_3gpp_dec_ibuffer__ortag   ) ,
    //
    .oempty  ( ldpc_3gpp_dec_ibuffer__oempty  ) ,
    .oemptya ( ldpc_3gpp_dec_ibuffer__oemptya ) ,
    .ofull   ( ldpc_3gpp_dec_ibuffer__ofull   ) ,
    .ofulla  ( ldpc_3gpp_dec_ibuffer__ofulla  )
  );


  assign ldpc_3gpp_dec_ibuffer__iclk    = '0 ;
  assign ldpc_3gpp_dec_ibuffer__ireset  = '0 ;
  assign ldpc_3gpp_dec_ibuffer__iclkena = '0 ;
  assign ldpc_3gpp_dec_ibuffer__iwrite  = '0 ;
  assign ldpc_3gpp_dec_ibuffer__iclear  = '0 ;
  assign ldpc_3gpp_dec_ibuffer__ipwrite = '0 ;
  assign ldpc_3gpp_dec_ibuffer__ipclear = '0 ;
  assign ldpc_3gpp_dec_ibuffer__iwfull  = '0 ;
  assign ldpc_3gpp_dec_ibuffer__iwaddr  = '0 ;
  assign ldpc_3gpp_dec_ibuffer__iLLR    = '0 ;
  assign ldpc_3gpp_dec_ibuffer__iwtag   = '0 ;
  assign ldpc_3gpp_dec_ibuffer__irempty = '0 ;
  assign ldpc_3gpp_dec_ibuffer__iraddr  = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_ibuffer.sv
// Description   : input 2D ram buffer with 2D tag interface. Ram read latency is 2 tick
//

`include "define.vh"

module ldpc_3gpp_dec_ibuffer
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  iwrite  ,
  iclear  ,
  ipwrite ,
  ipclear ,
  iwfull  ,
  iwaddr  ,
  iLLR    ,
  iwtag   ,
  //
  irempty ,
  iraddr  ,
  oLLR    ,
  opLLR   ,
  ortag   ,
  //
  oempty  ,
  oemptya ,
  ofull   ,
  ofulla
);

  parameter int pD_ADDR_W = 8 ;  // data LLR address width
  parameter int pP_ADDR_W = 8 ;  // parity LLR addres width (pP_ADDR_W == pD_ADDR_W * log2(46/pROW_BY_CYCLE)

  parameter int pTAG_W    = 8 ;

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_dec_types.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                       iclk                                                  ;
  input  logic                       ireset                                                ;
  input  logic                       iclkena                                               ;
  //
  input  logic [cCOL_BY_CYCLE-1 : 0] iwrite                                                ;
  input  logic               [1 : 0] iclear                                                ;
  input  logic [pROW_BY_CYCLE-1 : 0] ipwrite                                               ;
  input  logic [pROW_BY_CYCLE-1 : 0] ipclear                                               ;
  input  logic                       iwfull                                                ;
  input  logic     [pP_ADDR_W-1 : 0] iwaddr                                                ;
  input  llr_t                       iLLR                                  [pLLR_BY_CYCLE] ;
  input  logic        [pTAG_W-1 : 0] iwtag                                                 ;
  //
  input  logic                       irempty                                               ;
  input  logic     [pP_ADDR_W-1 : 0] iraddr                                                ;
  output llr_t                       oLLR                   [cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  output llr_t                       opLLR   [pROW_BY_CYCLE]               [pLLR_BY_CYCLE] ;
  output logic        [pTAG_W-1 : 0] ortag                                                 ;
  //
  output logic                       oempty                                                ; // any buffer is empty
  output logic                       oemptya                                               ; // all buffers is empty
  output logic                       ofull                                                 ; // any buffer is full
  output logic                       ofulla                                                ; // all buffers is full

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cD_ADDR_W = pD_ADDR_W + 1;
  localparam int cP_ADDR_W = pP_ADDR_W + 1;
  localparam int cDAT_W    = pLLR_BY_CYCLE * pLLR_W;

  logic b_wused ; // bank write used
  logic b_rused ; // bank read used

  // data mem
  logic [cCOL_BY_CYCLE-1 : 0] mem__iwrite;
  logic     [cD_ADDR_W-1 : 0] mem__iwaddr;
  logic        [cDAT_W-1 : 0] mem__iwdat  [cCOL_BY_CYCLE];

  logic     [cD_ADDR_W-1 : 0] mem__iraddr;
  logic        [cDAT_W-1 : 0] mem__ordat  [cCOL_BY_CYCLE];

  // parity mem
  logic [pROW_BY_CYCLE-1 : 0] pmem__iwrite;
  logic     [cP_ADDR_W-1 : 0] pmem__iwaddr;
  logic        [cDAT_W-1 : 0] pmem__iwdat [pROW_BY_CYCLE];

  logic     [cP_ADDR_W-1 : 0] pmem__iraddr;
  logic        [cDAT_W-1 : 0] pmem__ordat [pROW_BY_CYCLE];

  //------------------------------------------------------------------------------------------------------
  // buffer logic
  //------------------------------------------------------------------------------------------------------

  codec_buffer_nD_slogic
  #(
    .pBNUM_W ( 1 )  // 2D buffer
  )
  nD_slogic
  (
    .iclk     ( iclk    ) ,
    .ireset   ( ireset  ) ,
    .iclkena  ( iclkena ) ,
    //
    .iwfull   ( iwfull  ) ,
    .ob_wused ( b_wused ) ,
    .irempty  ( irempty ) ,
    .ob_rused ( b_rused ) ,
    //
    .oempty   ( oempty  ) ,
    .oemptya  ( oemptya ) ,
    .ofull    ( ofull   ) ,
    .ofulla   ( ofulla  )
  );

  //------------------------------------------------------------------------------------------------------
  // data LLR ram
  //------------------------------------------------------------------------------------------------------

  genvar gcol;

  generate
    for (gcol = 0; gcol < cCOL_BY_CYCLE; gcol++) begin : dLLR_ram_inst
      if (pDO_PUNCT & (gcol < 2)) begin
        assign mem__ordat[gcol] = '0; // not used
      end
      else if (pIDX_GR & (gcol >= 14)) begin
        assign mem__ordat[gcol] = '0; // truncate
      end
      else begin
        codec_mem_block
        #(
          .pADDR_W ( cD_ADDR_W ) ,
          .pDAT_W  ( cDAT_W    ) ,
          .pPIPE   ( 1         )
        )
        mem
        (
          .iclk    ( iclk                 ) ,
          .ireset  ( ireset               ) ,
          .iclkena ( iclkena              ) ,
          //
          .iwrite  ( mem__iwrite  [gcol]  ) ,
          .iwaddr  ( mem__iwaddr          ) ,
          .iwdat   ( mem__iwdat   [gcol]  ) ,
          //
          .iraddr  ( mem__iraddr          ) ,
          .ordat   ( mem__ordat   [gcol]  )
        );
      end
    end
  endgenerate

  assign mem__iwrite = iwrite;
  assign mem__iwaddr = {b_wused, iwaddr[pD_ADDR_W-1 : 0]};
  assign mem__iraddr = {b_rused, iraddr[pD_ADDR_W-1 : 0]};

  always_comb begin

    for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
      for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
        if (col < 2)
          mem__iwdat[col][llra*pLLR_W +: pLLR_W] = iclear[col] ? '0 : iLLR[llra];
        else
          mem__iwdat[col][llra*pLLR_W +: pLLR_W] = iLLR[llra];
        //
        oLLR[col][llra] = mem__ordat[col][llra*pLLR_W +: pLLR_W];
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // parity LLR ram
  //------------------------------------------------------------------------------------------------------

  // synthesis translate_off
  bit [pLLR_BY_CYCLE*pLLR_W-1 : 0] mem_mirrow [pROW_BY_CYCLE][2**cP_ADDR_W];
  // synthesis translate_on

  genvar grow;

  generate
    for (grow = 0; grow < pROW_BY_CYCLE; grow++) begin : pLLR_ram_inst
      if (pCODE < 4) begin
        assign pmem__ordat[grow] = '0;  // not used
      end
      else if ((pCODE < pROW_BY_CYCLE) & (grow >= pCODE)) begin
        assign pmem__ordat[grow] = '0;  // truncate ram
      end
      else begin
        codec_mem_block
        #(
          .pADDR_W ( cP_ADDR_W ) ,
          .pDAT_W  ( cDAT_W    ) ,
          .pPIPE   ( 1         )
        )
        pmem
        (
          .iclk    ( iclk               ) ,
          .ireset  ( ireset             ) ,
          .iclkena ( iclkena            ) ,
          //
          .iwrite  ( pmem__iwrite[grow] ) ,
          .iwaddr  ( pmem__iwaddr       ) ,
          .iwdat   ( pmem__iwdat [grow] ) ,
          //
          .iraddr  ( pmem__iraddr       ) ,
          .ordat   ( pmem__ordat [grow] )
        );

        // synthesis translate_off
        assign mem_mirrow[grow] = pmem.mem;
        // synthesis translate_on
      end
    end
  endgenerate

  assign pmem__iwrite = ipwrite;
  assign pmem__iwaddr = {b_wused, iwaddr[pP_ADDR_W-1 : 0]};
  assign pmem__iraddr = {b_rused, iraddr[pP_ADDR_W-1 : 0]};

  always_comb begin
    for (int row = 0; row < pROW_BY_CYCLE; row++) begin
      for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
        pmem__iwdat[row][llra*pLLR_W +: pLLR_W] = ipclear[row] ? '0 : iLLR[llra];
        //
        opLLR[row][llra] = pmem__ordat[row][llra*pLLR_W +: pLLR_W];
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // tag ram
  //------------------------------------------------------------------------------------------------------

  logic [pTAG_W-1 : 0] tram [2] /* synthesis ramstyle = "logic" */;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (iwfull) begin
        tram [b_wused] <= iwtag;
      end
    end
  end

  assign ortag = tram[b_rused];

endmodule

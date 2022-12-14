/*


  parameter int pADDR_W       =  8 ;
  parameter int pLLR_BY_cYCLE =  1 ;
  parameter int pROW_BY_CYCLE =  8 ;
  parameter int cCOL_BY_CYCLE = 26 ;



  logic        ldpc_3gpp_dec_mem_state_block__iclk                                                    ;
  logic        ldpc_3gpp_dec_mem_state_block__ireset                                                  ;
  logic        ldpc_3gpp_dec_mem_state_block__iclkena                                                 ;
  //
  hb_zc_t      ldpc_3gpp_dec_mem_state_block__iused_zc                                                ;
  //
  logic        ldpc_3gpp_dec_mem_state_block__iwrite                                                  ;
  strb_t       ldpc_3gpp_dec_mem_state_block__iwstrb                                                  ;
  node_state_t ldpc_3gpp_dec_mem_state_block__iwstate   [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  logic        ldpc_3gpp_dec_mem_state_block__iread                                                   ;
  logic        ldpc_3gpp_dec_mem_state_block__irstart                                                 ;
  logic        ldpc_3gpp_dec_mem_state_block__irval                                                   ;
  strb_t       ldpc_3gpp_dec_mem_state_block__irstrb                                                  ;
  //
  logic        ldpc_3gpp_dec_mem_state_block__orval                                                   ;
  strb_t       ldpc_3gpp_dec_mem_state_block__orstrb                                                  ;
  node_state_t ldpc_3gpp_dec_mem_state_block__orstate   [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;



  ldpc_3gpp_dec_mem_state_block
  #(
    .pADDR_W       ( pADDR_W       ) ,
    //
    .pLLR_BY_cYCLE ( pLLR_BY_cYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE )

  )
  ldpc_3gpp_dec_mem_state_block
  (
    .iclk       ( ldpc_3gpp_dec_mem_state_block__iclk       ) ,
    .ireset     ( ldpc_3gpp_dec_mem_state_block__ireset     ) ,
    .iclkena    ( ldpc_3gpp_dec_mem_state_block__iclkena    ) ,
    //
    .iused_zc   ( ldpc_3gpp_dec_mem_state_block__iused_zc   ) ,
    //
    .iwrite     ( ldpc_3gpp_dec_mem_state_block__iwrite     ) ,
    .iwstrb     ( ldpc_3gpp_dec_mem_state_block__iwstrb     ) ,
    .iwstate    ( ldpc_3gpp_dec_mem_state_block__iwstate    ) ,
    //
    .iread      ( ldpc_3gpp_dec_mem_state_block__iread      ) ,
    .irstart    ( ldpc_3gpp_dec_mem_state_block__irstart    ) ,
    .irval      ( ldpc_3gpp_dec_mem_state_block__irval      ) ,
    .irstrb     ( ldpc_3gpp_dec_mem_state_block__irstrb     ) ,
    //
    .orval      ( ldpc_3gpp_dec_mem_state_block__orval      ) ,
    .orstrb     ( ldpc_3gpp_dec_mem_state_block__orstrb     ) ,
    .orstate    ( ldpc_3gpp_dec_mem_state_block__orstate    )
  );


  assign ldpc_3gpp_dec_mem_state_block__iclk       = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__ireset     = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__iclkena    = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__iused_zc   = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__iwrite     = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__iwstrb     = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__iwstate    = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__iread      = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__irstart    = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__irval      = '0 ;
  assign ldpc_3gpp_dec_mem_state_block__irstrb     = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_mem_state_block.sv
// Description   : single dimentsion mem component for node history states
//                  Ram write delay 3 tick (2 address generator + 1 ram)
//                  Ram read delay 4 tick (2 address generator + 2 ram)

//

`include "define.vh"

module ldpc_3gpp_dec_mem_state_block
(
  iclk      ,
  ireset    ,
  iclkena   ,
  //
  iused_zc  ,
  //
  iwrite    ,
  iwstrb    ,
  iwstate   ,
  //
  iread     ,
  irstart   ,
  irval     ,
  irstrb    ,
  //
  orval     ,
  orstrb    ,
  orstate
);

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_dec_types.svh"

  parameter int pADDR_W = cMEM_ADDR_W;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 iclk                                                     ;
  input  logic                 ireset                                                   ;
  input  logic                 iclkena                                                  ;
  //
  input  hb_zc_t               iused_zc                                                 ;
  //
  input  logic                 iwrite                                                   ;
  input  strb_t                iwstrb                                                   ;
  input  node_state_t          iwstate    [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;
  //
  input  logic                 iread                                                    ;
  input  logic                 irstart                                                  ;
  input  logic                 irval                                                    ;
  input  strb_t                irstrb                                                   ;
  //
  output logic                 orval                                                    ;
  output strb_t                orstrb                                                   ;
  output node_state_t          orstate    [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cSTATE_W   = $bits(node_state_t);
  localparam int cMEM_DAT_W = pROW_BY_CYCLE * cCOL_BY_CYCLE * pLLR_BY_CYCLE * cSTATE_W;

  typedef logic [pADDR_W-1 : 0] mem_addr_t;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic         write;

  logic [3 : 0] rval;
  strb_t        rstrb [4]; // ram (2) + address (2)

  mem_addr_t  row_raddr;
  mem_addr_t  row_waddr;

  struct packed {
    logic   done;
    hb_zc_t value;
  } zc_rcnt, zc_wcnt;

  node_state_t  wstate [pROW_BY_CYCLE][cCOL_BY_CYCLE][pLLR_BY_CYCLE] ;

  logic         memb__iwrite ;
  mem_addr_t    memb__iwaddr ;
  mem_addr_t    memb__iraddr ;

  node_state_t [pROW_BY_CYCLE-1 : 0][cCOL_BY_CYCLE-1 : 0][pLLR_BY_CYCLE-1 : 0] memb__iwdat;
  node_state_t [pROW_BY_CYCLE-1 : 0][cCOL_BY_CYCLE-1 : 0][pLLR_BY_CYCLE-1 : 0] memb__ordat;

  //------------------------------------------------------------------------------------------------------
  // write address
  //  vnode : row ->  zc (get full vertical line in some rows)
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      write <= 1'b0;
    else if (iclkena)
      write <= iwrite;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      wstate <= iwstate;
      //
      if (iwrite) begin // vnode mode only
        if (iwstrb.sof & iwstrb.sop) begin
          row_waddr     <= '0;
          zc_wcnt       <= '0;
        end
        else if (iwstrb.sop) begin
          row_waddr     <= '0;
          zc_wcnt.value <= zc_wcnt.value + 1'b1;
        end
        else begin
          row_waddr     <= row_waddr + iused_zc;
        end
      end // iwrite
    end // iclke
  end

  //------------------------------------------------------------------------------------------------------
  // read addres
  //  vnode : row ->  zc (get full vertical line in some rows)
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      rval  <= '0;
    else if (iclkena)
      rval <= (rval << 1) | iread;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      for (int i = 0; i < $size(rstrb); i++) begin
        rstrb[i] <= (i == 0) ? irstrb : rstrb[i-1];
      end
      //
      if (iread) begin // vnode mode only
        if (irstrb.sof & irstrb.sop) begin
          row_raddr     <= '0;
          zc_rcnt       <= '0;
        end
        else if (irstrb.sop) begin
          row_raddr     <= '0;
          zc_rcnt.value <= zc_rcnt.value + 1'b1;
        end
        else begin
          row_raddr     <= row_raddr + iused_zc;
        end
      end // iread
    end // iclkena
  end // iclk

  //------------------------------------------------------------------------------------------------------
  // ram itself
  //------------------------------------------------------------------------------------------------------

  codec_mem_block
  #(
    .pADDR_W ( pADDR_W    ) ,
    .pDAT_W  ( cMEM_DAT_W ) ,
    .pPIPE   ( 1          )
  )
  memb
  (
    .iclk    ( iclk         ) ,
    .ireset  ( ireset       ) ,
    .iclkena ( iclkena      ) ,
    //
    .iwrite  ( memb__iwrite ) ,
    .iwaddr  ( memb__iwaddr ) ,
    .iwdat   ( memb__iwdat  ) ,
    //
    .iraddr  ( memb__iraddr ) ,
    .ordat   ( memb__ordat  )
  );

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      memb__iwrite <= write;
      memb__iwaddr <= row_waddr + zc_wcnt.value;
      memb__iraddr <= row_raddr + zc_rcnt.value;
      //
      for (int row = 0; row < pROW_BY_CYCLE; row++) begin
        for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
          for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
            memb__iwdat[row][col][llra] <= wstate[row][col][llra];
          end
        end
      end
    end
  end

  assign orval  = rval [3]; // 2 + 2 tick
  assign orstrb = rstrb[3];

  always_comb begin
    for (int row = 0; row < pROW_BY_CYCLE; row++) begin
      for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
        for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
          orstate[row][col][llra] = memb__ordat[row][col][llra];
        end
      end
    end
  end

endmodule

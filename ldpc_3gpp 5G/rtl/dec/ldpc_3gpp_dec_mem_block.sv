/*


  parameter int pADDR_W       = 8 ;
  //
  parameter int pLLR_W        = 8 ;
  parameter int pNODE_W       = 8 ;
  //
  parameter int pLLR_BY_cYCLE = 1 ;



  logic         ldpc_3gpp_dec_mem_block__iclk                       ;
  logic         ldpc_3gpp_dec_mem_block__ireset                     ;
  logic         ldpc_3gpp_dec_mem_block__iclkena                    ;
  //
  hb_zc_t       ldpc_3gpp_dec_mem_block__iused_zc                   ;
  logic         ldpc_3gpp_dec_mem_block__ic_nv_mode                 ;
  //
  logic         ldpc_3gpp_dec_mem_block__iwrite                     ;
  mm_hb_value_t ldpc_3gpp_dec_mem_block__iwHb                       ;
  strb_t        ldpc_3gpp_dec_mem_block__iwstrb                     ;
  node_t        ldpc_3gpp_dec_mem_block__iwdat      [pLLR_BY_CYCLE] ;
  //
  logic         ldpc_3gpp_dec_mem_block__iread                      ;
  logic         ldpc_3gpp_dec_mem_block__irstart                    ;
  mm_hb_value_t ldpc_3gpp_dec_mem_block__irHb                       ;
  logic         ldpc_3gpp_dec_mem_block__irval                      ;
  strb_t        ldpc_3gpp_dec_mem_block__irstrb                     ;
  //
  logic         ldpc_3gpp_dec_mem_block__orval                      ;
  strb_t        ldpc_3gpp_dec_mem_block__orstrb                     ;
  logic         ldpc_3gpp_dec_mem_block__ormask                     ;
  node_t        ldpc_3gpp_dec_mem_block__ordat      [pLLR_BY_CYCLE] ;



  ldpc_3gpp_dec_mem_block
  #(
    .pADDR_W       ( pADDR_W       ) ,
    //
    .pLLR_W        ( pLLR_W        ) ,
    .pNODE_W       ( pNODE_W       ) ,
    //
    .pLLR_BY_cYCLE ( pLLR_BY_cYCLE )
  )
  ldpc_3gpp_dec_mem_block
  (
    .iclk       ( ldpc_3gpp_dec_mem_block__iclk       ) ,
    .ireset     ( ldpc_3gpp_dec_mem_block__ireset     ) ,
    .iclkena    ( ldpc_3gpp_dec_mem_block__iclkena    ) ,
    //
    .iused_zc   ( ldpc_3gpp_dec_mem_block__iused_zc   ) ,
    .ic_nv_mode ( ldpc_3gpp_dec_mem_block__ic_nv_mode ) ,
    //
    .iwrite     ( ldpc_3gpp_dec_mem_block__iwrite     ) ,
    .iwHb       ( ldpc_3gpp_dec_mem_block__iwHb       ) ,
    .iwstrb     ( ldpc_3gpp_dec_mem_block__iwstrb     ) ,
    .iwdat      ( ldpc_3gpp_dec_mem_block__iwdat      ) ,
    //
    .iread      ( ldpc_3gpp_dec_mem_block__iread      ) ,
    .irstart    ( ldpc_3gpp_dec_mem_block__irstart    ) ,
    .irHb       ( ldpc_3gpp_dec_mem_block__irHb       ) ,
    .irval      ( ldpc_3gpp_dec_mem_block__irval      ) ,
    .irstrb     ( ldpc_3gpp_dec_mem_block__irstrb     ) ,
    //
    .orval      ( ldpc_3gpp_dec_mem_block__orval      ) ,
    .orstrb     ( ldpc_3gpp_dec_mem_block__orstrb     ) ,
    .ormask     ( ldpc_3gpp_dec_mem_block__ormask     ) ,
    .ordat      ( ldpc_3gpp_dec_mem_block__ordat      )
  );


  assign ldpc_3gpp_dec_mem_block__iclk       = '0 ;
  assign ldpc_3gpp_dec_mem_block__ireset     = '0 ;
  assign ldpc_3gpp_dec_mem_block__iclkena    = '0 ;
  assign ldpc_3gpp_dec_mem_block__iused_zc   = '0 ;
  assign ldpc_3gpp_dec_mem_block__ic_nv_mode = '0 ;
  assign ldpc_3gpp_dec_mem_block__iwrite     = '0 ;
  assign ldpc_3gpp_dec_mem_block__iwHb       = '0 ;
  assign ldpc_3gpp_dec_mem_block__iwsstrb    = '0 ;
  assign ldpc_3gpp_dec_mem_block__iwdat      = '0 ;
  assign ldpc_3gpp_dec_mem_block__iread      = '0 ;
  assign ldpc_3gpp_dec_mem_block__irstart    = '0 ;
  assign ldpc_3gpp_dec_mem_block__irHb       = '0 ;
  assign ldpc_3gpp_dec_mem_block__irval      = '0 ;
  assign ldpc_3gpp_dec_mem_block__irstrb     = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_mem_block.sv
// Description   : multidimentsion mem component for nodes.
//                  Ram write delay 3 tick (2 address generator + 1 ram)
//                  Ram read delay 4 tick (2 address generator + 2 ram)
//

`include "define.vh"

module ldpc_3gpp_dec_mem_block
(
  iclk       ,
  ireset     ,
  iclkena    ,
  //
  iused_zc   ,
  ic_nv_mode ,
  //
  iwrite     ,
  iwHb       ,
  iwstrb     ,
  iwdat      ,
  //
  iread      ,
  irstart    ,
  irHb       ,
  irval      ,
  irstrb     ,
  //
  orval      ,
  orstrb     ,
  ormask     ,
  ordat
);

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_dec_types.svh"

  parameter int pADDR_W = cMEM_ADDR_W;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic         iclk                       ;
  input  logic         ireset                     ;
  input  logic         iclkena                    ;
  //
  input  hb_zc_t       iused_zc                   ;
  input  logic         ic_nv_mode                 ;
  //
  input  logic         iwrite                     ;
  input  mm_hb_value_t iwHb                       ;
  input  strb_t        iwstrb                     ;
  input  node_t        iwdat      [pLLR_BY_CYCLE] ;
  //
  input  logic         iread                      ;
  input  logic         irstart                    ;
  input  mm_hb_value_t irHb                       ;
  input  logic         irval                      ;
  input  strb_t        irstrb                     ;
  //
  output logic         orval                      ;
  output strb_t        orstrb                     ;
  output logic         ormask                     ;
  output node_t        ordat      [pLLR_BY_CYCLE] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cMEM_DAT_W = pLLR_BY_CYCLE * pNODE_W;

  typedef logic    [pADDR_W-1 : 0] mem_addr_t;
  typedef logic [cMEM_DAT_W-1 : 0] mem_data_t;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic         write;

  logic [3 : 0] rval;
  strb_t        rstrb [4]; // ram (2) + address (2)
  logic [3 : 0] rmask;

  mem_addr_t  row_raddr;
  mem_addr_t  row_waddr;

  struct packed {
    logic   done;
    hb_zc_t value;
  } zc_rcnt, zc_wcnt;

  node_t     wdat [pLLR_BY_CYCLE] ;

  logic      memb__iwrite ;
  mem_addr_t memb__iwaddr ;
  mem_data_t memb__iwdat  ;

  mem_addr_t memb__iraddr ;
  mem_data_t memb__ordat  ;

  //------------------------------------------------------------------------------------------------------
  // write address
  //  cnode : zc  -> row (get full horizontal line in one row)
  //  vnode : row ->  zc (get full vertical   line in some rows)
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      write <= 1'b0;
    else if (iclkena)
      write <= iwrite;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      wdat <= iwdat;
      //
      if (iwrite) begin
        if (ic_nv_mode) begin // cnode mode
          if (iwstrb.sof & iwstrb.sop) begin
            zc_wcnt.value <=  iwHb.wshift;
            zc_wcnt.done  <= (iwHb.wshift == iused_zc-1);
            //
            row_waddr     <= '0;
          end
          else if (iwstrb.sop) begin
            zc_wcnt.value <=  iwHb.wshift;
            zc_wcnt.done  <= (iwHb.wshift == iused_zc-1);
            //
            row_waddr     <= row_waddr + iused_zc;
          end
          else begin
            zc_wcnt.value <= zc_wcnt.done   ? '0   : (zc_wcnt.value + 1'b1);
            zc_wcnt.done  <= (iused_zc < 2) ? 1'b1 : (zc_wcnt.value == iused_zc-2);
          end
        end
        else begin // vnode mode
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
        end // ic_nv_mode
      end // iwrite
    end // iclkena
  end // iclk

  //------------------------------------------------------------------------------------------------------
  // read addres
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      rval  <= '0;
    else if (iclkena)
      rval <= (rval << 1) | iread;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      rmask <= (rmask << 1) | irHb.is_masked;
      for (int i = 0; i < $size(rstrb); i++) begin
        rstrb[i] <= (i == 0) ? irstrb : rstrb[i-1];
      end
      //
      if (iread) begin
        if (ic_nv_mode) begin // cnode mode
          if (irstrb.sof & irstrb.sop) begin
            zc_rcnt.value <=  irHb.wshift;
            zc_rcnt.done  <= (irHb.wshift == iused_zc-1);
            //
            row_raddr     <= '0;
          end
          else if (irstrb.sop) begin
            zc_rcnt.value <=  irHb.wshift;
            zc_rcnt.done  <= (irHb.wshift == iused_zc-1);
            //
            row_raddr     <= row_raddr + iused_zc;
          end
          else begin
            zc_rcnt.value <= zc_rcnt.done   ? '0   : (zc_rcnt.value + 1'b1);
            zc_rcnt.done  <= (iused_zc < 2) ? 1'b1 : (zc_rcnt.value == iused_zc-2);
          end
        end
        else begin  // vnode mode
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
        end // ic_nv_mode
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
      for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
        memb__iwdat[pNODE_W*llra +: pNODE_W] <= wdat[llra];
      end
    end
  end

  assign orval  = rval [3]; // 2 + 2 tick
  assign orstrb = rstrb[3];

  always_comb begin
    for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
      ordat[llra] = memb__ordat[pNODE_W*llra +: pNODE_W];
    end
  end

  assign ormask = rmask[3];

endmodule

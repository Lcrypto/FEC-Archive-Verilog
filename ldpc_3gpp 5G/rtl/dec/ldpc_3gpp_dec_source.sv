/*



  parameter int pADDR_W       = 8 ;
  //
  parameter int pLLR_W        = 5 ;
  //
  parameter int pLLR_BY_CYCLE = 1 ;
  parameter int pROW_BY_CYCLE = 1 ;



  logic                       ldpc_3gpp_dec_source__iclk                        ;
  logic                       ldpc_3gpp_dec_source__ireset                      ;
  logic                       ldpc_3gpp_dec_source__iclkena                     ;
  //
  logic                       ldpc_3gpp_dec_source__isop                        ;
  logic                       ldpc_3gpp_dec_source__ieop                        ;
  logic                       ldpc_3gpp_dec_source__ival                        ;
  llr_t                       ldpc_3gpp_dec_source__iLLR        [pLLR_BY_CYCLE] ;
  //
  code_ctx_t                  ldpc_3gpp_dec_source__icode_ctx                   ;
  //
  logic                       ldpc_3gpp_dec_source__obusy                       ;
  logic                       ldpc_3gpp_dec_source__ordy                        ;
  //
  logic                       ldpc_3gpp_dec_source__iempty                      ;
  logic                       ldpc_3gpp_dec_source__iemptya                     ;
  logic                       ldpc_3gpp_dec_source__ifull                       ;
  logic                       ldpc_3gpp_dec_source__ifulla                      ;
  //
  logic [cCOL_BY_CYCLE-1 : 0] ldpc_3gpp_dec_source__owrite                      ;
  logic               [1 : 0] ldpc_3gpp_dec_source__oclear                      ;
  logic [pROW_BY_CYCLE-1 : 0] ldpc_3gpp_dec_source__opwrite                     ;
  logic [pROW_BY_CYCLE-1 : 0] ldpc_3gpp_dec_source__opclear                     ;
  logic                       ldpc_3gpp_dec_source__owfull                      ;
  logic       [pADDR_W-1 : 0] ldpc_3gpp_dec_source__owaddr                      ;
  llr_t                       ldpc_3gpp_dec_source__owLLR       [pLLR_BY_CYCLE] ;



  ldpc_3gpp_dec_source
  #(
    .pADDR_W       ( pADDR_W       ) ,
    //
    .pLLR_W        ( pLLR_W        ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE )
  )
  ldpc_3gpp_dec_source
  (
    .iclk       ( ldpc_3gpp_dec_source__iclk      ) ,
    .ireset     ( ldpc_3gpp_dec_source__ireset    ) ,
    .iclkena    ( ldpc_3gpp_dec_source__iclkena   ) ,
    //
    .isop       ( ldpc_3gpp_dec_source__isop      ) ,
    .ieop       ( ldpc_3gpp_dec_source__ieop      ) ,
    .ival       ( ldpc_3gpp_dec_source__ival      ) ,
    .iLLR       ( ldpc_3gpp_dec_source__iLLR      ) ,
    //
    .icode_ctx  ( ldpc_3gpp_dec_source__icode_ctx ) ,
    //
    .obusy      ( ldpc_3gpp_dec_source__obusy     ) ,
    .ordy       ( ldpc_3gpp_dec_source__ordy      ) ,
    //
    .iempty     ( ldpc_3gpp_dec_source__iempty    ) ,
    .iemptya    ( ldpc_3gpp_dec_source__iemptya   ) ,
    .ifull      ( ldpc_3gpp_dec_source__ifull     ) ,
    .ifulla     ( ldpc_3gpp_dec_source__ifulla    ) ,
    //
    .owrite     ( ldpc_3gpp_dec_source__owrite    ) ,
    .oclear     ( ldpc_3gpp_dec_source__oclear    ) ,
    .opwrite    ( ldpc_3gpp_dec_source__opwrite   ) ,
    .opclear    ( ldpc_3gpp_dec_source__opclear   ) ,
    .owfull     ( ldpc_3gpp_dec_source__owfull    ) ,
    .owaddr     ( ldpc_3gpp_dec_source__owaddr    ) ,
    .owLLR      ( ldpc_3gpp_dec_source__owLLR     )
  );


  assign ldpc_3gpp_dec_source__iclk      = '0 ;
  assign ldpc_3gpp_dec_source__ireset    = '0 ;
  assign ldpc_3gpp_dec_source__iclkena   = '0 ;
  assign ldpc_3gpp_dec_source__isop      = '0 ;
  assign ldpc_3gpp_dec_source__ieop      = '0 ;
  assign ldpc_3gpp_dec_source__ival      = '0 ;
  assign ldpc_3gpp_dec_source__iLLR      = '0 ;
  assign ldpc_3gpp_dec_source__icode_ctx = '0 ;
  assign ldpc_3gpp_dec_source__iempty    = '0 ;
  assign ldpc_3gpp_dec_source__iemptya   = '0 ;
  assign ldpc_3gpp_dec_source__ifull     = '0 ;
  assign ldpc_3gpp_dec_source__ifulla    = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_source.sv
// Description   : Input LLR saturaion and input buffer address generation module
//

`include "define.vh"

module ldpc_3gpp_dec_source
(
  iclk      ,
  ireset    ,
  iclkena   ,
  //
  isop      ,
  ieop      ,
  ival      ,
  iLLR      ,
  //
  icode_ctx ,
  //
  obusy     ,
  ordy      ,
  //
  iempty    ,
  iemptya   ,
  ifull     ,
  ifulla    ,
  //
  owrite    ,
  oclear    ,
  opwrite   ,
  opclear   ,
  owfull    ,
  owaddr    ,
  owLLR
);

  parameter int pADDR_W = 10 ;  // used to optimize ram resources for fixed decoder

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_dec_types.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                       iclk                    ;
  input  logic                       ireset                  ;
  input  logic                       iclkena                 ;
  //
  input  logic                       isop                    ;
  input  logic                       ieop                    ;
  input  logic                       ival                    ;
  input  llr_t                       iLLR    [pLLR_BY_CYCLE] ;
  //
  input  code_ctx_t                  icode_ctx               ;
  //
  output logic                       obusy                   ;
  output logic                       ordy                    ;
  // 2D buffer state
  input  logic                       iempty                  ;
  input  logic                       iemptya                 ;
  input  logic                       ifull                   ;
  input  logic                       ifulla                  ;
  //
  output logic [cCOL_BY_CYCLE-1 : 0] owrite                  ;
  output logic               [1 : 0] oclear                  ;
  output logic [pROW_BY_CYCLE-1 : 0] opwrite                 ;
  output logic [pROW_BY_CYCLE-1 : 0] opclear                 ;
  output logic                       owfull                  ;
  output logic       [pADDR_W-1 : 0] owaddr                  ;
  output llr_t                       owLLR   [pLLR_BY_CYCLE] ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic                       write;
  logic [cCOL_BY_CYCLE-1 : 0] write_mask;
  logic [cCOL_BY_CYCLE-1 : 0] write_clear;
  logic [pROW_BY_CYCLE-1 : 0] write_pmask;
  logic [pROW_BY_CYCLE-1 : 0] write_pclear;

  struct packed {
    logic   done;
    hb_zc_t value;
  } zc_cnt;

  hb_zc_t               used_zc;
  logic                 used_idxGr;
  logic                 used_do_punct;

  logic [pADDR_W-1 : 0] row_addr;

  //------------------------------------------------------------------------------------------------------
  // get size of zc block. pLLR_BY_CYCLE == 1/2/4/8
  //------------------------------------------------------------------------------------------------------

  assign used_zc        = cZC_TAB[icode_ctx.idxLs][icode_ctx.idxZc]/pLLR_BY_CYCLE;
  assign used_idxGr     = icode_ctx.idxGr;
  assign used_do_punct  = icode_ctx.do_punct;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      write  <= '0;
      owfull <= '0;
    end
    else if (iclkena) begin
      write  <= ival;
      owfull <= ival & ieop;
    end
  end

  assign owrite   = {cCOL_BY_CYCLE{write}} & (write_mask | write_clear);
  assign oclear   = write_clear;
  assign opwrite  = {pROW_BY_CYCLE{write}} & (write_pmask | write_pclear);
  assign opclear  = write_pclear;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival) begin
        // LLR saturation and invertion
        for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
          if (&{iLLR[llra][pLLR_W-1], ~iLLR[llra][pLLR_W-2 : 0]}) // -2^(N-1)
            owLLR[llra] <= {1'b0, {(pLLR_W-2){1'b1}} ,1'b1};   // -(2^(N-1) - 1)
          else
            owLLR[llra] <= -iLLR[llra];
        end
        // zc counter
        if (isop) begin
          zc_cnt      <= '0;
          zc_cnt.done <= (used_zc < 2);
        end
        else begin
          zc_cnt.value <= zc_cnt.done   ? '0   : (zc_cnt.value + 1'b1);
          zc_cnt.done  <= (used_zc < 2) ? 1'b1 : (zc_cnt.value == (used_zc-2));
        end
        // address counter
        if (isop) begin
          owaddr   <= '0;
          row_addr <= '0;
        end
        else if (zc_cnt.done) begin
          owaddr <= row_addr;
          if (write_pmask[pROW_BY_CYCLE-1]) begin
            row_addr  <= row_addr + used_zc;
            owaddr    <= row_addr + used_zc;
          end
        end
        else begin
          owaddr <= owaddr + 1'b1;
        end
        // write data mask
        // write parity mask
        if (isop) begin
          write_mask   <= used_do_punct ? 3'b100 : 1'b1;  // skip and clear first 2
          write_clear  <= used_do_punct ?  2'b11 : 2'b00;  //
          write_pmask  <= '0;
          write_pclear <= '0;
        end
        else if (zc_cnt.done) begin
          if (used_idxGr & write_mask[cGR_MAJOR_BIT_COL[used_idxGr]-1]) begin  // short graph
            write_mask <= '0;
          end
          else begin
            write_mask <= (write_mask << 1);
          end
          //
          write_clear <= '0;
          //
          if (write_mask[cGR_SYST_BIT_COL[used_idxGr]-1]) begin // start write to both
            write_pmask  <= 1'b1;
          end
          else begin
            write_pmask  <= (write_pmask  << 1) | write_pmask[pROW_BY_CYCLE-1];
          end
          //
          if (write_mask[cGR_SYST_BIT_COL[used_idxGr]-1] | write_pmask[pROW_BY_CYCLE-1]) begin // start write to both
            write_pclear <= '1 - 1'b1; // 0x11110
          end
          else begin
            write_pclear <= (write_pclear << 1);
          end
        end
      end // ival
    end // iclkena
  end // iclk

  assign ordy   = !owfull & !ifulla;  // not ready if all buffers is full
  assign obusy  =  owfull | !iemptya; // busy if any buffer is not empty

endmodule

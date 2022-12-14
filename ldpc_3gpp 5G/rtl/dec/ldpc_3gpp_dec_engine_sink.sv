/*


  parameter bit pIDX_GR       =  0 ;
  //
  parameter int pLLR_BY_CYCLE =  1 ;
  parameter int pROW_BY_CYCLE =  8 ;
  //
  parameter int pDAT_W        =  1 ;
  parameter int pDAT_NUM      = 22 ;
  //
  parameter int pADDR_W       =  8 ;
  //
  parameter int pERR_W        =  1 ;
  parameter int pTAG_W        =  4 ;



  logic                            ldpc_3gpp_dec_engine_sink__iclk                      ;
  logic                            ldpc_3gpp_dec_engine_sink__ireset                    ;
  logic                            ldpc_3gpp_dec_engine_sink__iclkena                   ;
  //
  code_ctx_t                       ldpc_3gpp_dec_engine_sink__icode_ctx                 ;
  //
  logic                            ldpc_3gpp_dec_engine_sink__ival                      ;
  logic                            ldpc_3gpp_dec_engine_sink__isop                      ;
  logic                            ldpc_3gpp_dec_engine_sink__ieop                      ;
  logic      [pLLR_BY_CYCLE-1 : 0] ldpc_3gpp_dec_engine_sink__idat      [cCOL_BY_CYCLE] ;
  //
  logic             [pTAG_W-1 : 0] ldpc_3gpp_dec_engine_sink__itag                      ;
  logic                            ldpc_3gpp_dec_engine_sink__idecfail                  ;
  logic             [pERR_W-1 : 0] ldpc_3gpp_dec_engine_sink__ierr                      ;
  //
  code_ctx_t                       ldpc_3gpp_dec_engine_sink__ocode_ctx                 ;
  //
  logic                            ldpc_3gpp_dec_engine_sink__owrite                    ;
  logic                            ldpc_3gpp_dec_engine_sink__owfull                    ;
  logic            [pADDR_W-1 : 0] ldpc_3gpp_dec_engine_sink__owaddr                    ;
  logic             [pDAT_W-1 : 0] ldpc_3gpp_dec_engine_sink__owdat     [pDAT_NUM]      ;
  //
  logic             [pTAG_W-1 : 0] ldpc_3gpp_dec_engine_sink__otag                      ;
  logic                            ldpc_3gpp_dec_engine_sink__odecfail                  ;
  logic             [pERR_W-1 : 0] ldpc_3gpp_dec_engine_sink__oerr                      ;



  ldpc_3gpp_dec_engine_sink
  #(
    .pIDX_GR       ( pIDX_GR       ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE ) ,
    //
    .pDAT_W        ( pDAT_W        ) ,
    .pDAT_NUM      ( pDAT_NUM      ) ,
    //
    .pADDR_W       ( pADDR_W       ) ,
    //
    .pERR_W        ( pERR_W        ) ,
    .pTAG_W        ( pTAG_W        )
  )
  ldpc_3gpp_dec_engine_sink
  (
    .iclk      ( ldpc_3gpp_dec_engine_sink__iclk      ) ,
    .ireset    ( ldpc_3gpp_dec_engine_sink__ireset    ) ,
    .iclkena   ( ldpc_3gpp_dec_engine_sink__iclkena   ) ,
    //
    .icode_ctx ( ldpc_3gpp_dec_engine_sink__icode_ctx ) ,
    //
    .ival      ( ldpc_3gpp_dec_engine_sink__ival      ) ,
    .isop      ( ldpc_3gpp_dec_engine_sink__isop      ) ,
    .ieop      ( ldpc_3gpp_dec_engine_sink__ieop      ) ,
    .idat      ( ldpc_3gpp_dec_engine_sink__idat      ) ,
    //
    .itag      ( ldpc_3gpp_dec_engine_sink__itag      ) ,
    .idecfail  ( ldpc_3gpp_dec_engine_sink__idecfail  ) ,
    .ierr      ( ldpc_3gpp_dec_engine_sink__ierr      ) ,
    //
    .ocode_ctx ( ldpc_3gpp_dec_engine_sink__ocode_ctx ) ,
    //
    .owrite    ( ldpc_3gpp_dec_engine_sink__owrite    ) ,
    .owfull    ( ldpc_3gpp_dec_engine_sink__owfull    ) ,
    .owaddr    ( ldpc_3gpp_dec_engine_sink__owaddr    ) ,
    .owdat     ( ldpc_3gpp_dec_engine_sink__owdat     ) ,
    //
    .otag      ( ldpc_3gpp_dec_engine_sink__otag      ) ,
    .odecfail  ( ldpc_3gpp_dec_engine_sink__odecfail  ) ,
    .oerr      ( ldpc_3gpp_dec_engine_sink__oerr      )
  );


  assign ldpc_3gpp_dec_engine_sink__iclk      = '0 ;
  assign ldpc_3gpp_dec_engine_sink__ireset    = '0 ;
  assign ldpc_3gpp_dec_engine_sink__iclkena   = '0 ;
  assign ldpc_3gpp_dec_engine_sink__icode_ctx = '0 ;
  assign ldpc_3gpp_dec_engine_sink__ival      = '0 ;
  assign ldpc_3gpp_dec_engine_sink__isop      = '0 ;
  assign ldpc_3gpp_dec_engine_sink__ieop      = '0 ;
  assign ldpc_3gpp_dec_engine_sink__idat      = '0 ;
  assign ldpc_3gpp_dec_engine_sink__itag      = '0 ;
  assign ldpc_3gpp_dec_engine_sink__idecfail  = '0 ;
  assign ldpc_3gpp_dec_engine_sink__ierr      = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_engine_sink.sv
// Description   : module to do DWC (pLLR_BY_CYCLE -> pDAT_W) data conversion
//                 and remap data (14/22 columns -> less columns) for optimize ram efficiency
//

`include "define.vh"

module ldpc_3gpp_dec_engine_sink
(
  iclk      ,
  ireset    ,
  iclkena   ,
  //
  icode_ctx ,
  //
  ival      ,
  isop      ,
  ieop      ,
  idat      ,
  //
  itag      ,
  idecfail  ,
  ierr      ,
  //
  ocode_ctx ,
  //
  owrite    ,
  owfull    ,
  owaddr    ,
  owdat     ,
  //
  otag      ,
  odecfail  ,
  oerr
);

  parameter int pDAT_W    =  8 ;  // must be multiple of pLLR_BY_CYCLE
  parameter int pDAT_NUM  = 22 ;
  //
  parameter int pADDR_W   =  8 ;  // define from pDAT_W/pDAT_NUM pair
  //
  parameter int pERR_W    = 16 ;
  parameter int pTAG_W    =  4 ;

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_dec_types.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                            iclk                      ;
  input  logic                            ireset                    ;
  input  logic                            iclkena                   ;
  //
  input  code_ctx_t                       icode_ctx                 ;
  //
  input  logic                            ival                      ;
  input  logic                            isop                      ;
  input  logic                            ieop                      ;
  input  logic      [pLLR_BY_CYCLE-1 : 0] idat      [cCOL_BY_CYCLE] ;
  //
  input  logic             [pTAG_W-1 : 0] itag                      ;
  input  logic                            idecfail                  ;
  input  logic             [pERR_W-1 : 0] ierr                      ;
  //
  output code_ctx_t                       ocode_ctx                 ;
  //
  output logic                            owrite                    ;
  output logic                            owfull                    ;
  output logic            [pADDR_W-1 : 0] owaddr                    ;
  output logic             [pDAT_W-1 : 0] owdat          [pDAT_NUM] ;
  //
  output logic             [pTAG_W-1 : 0] otag                      ;
  output logic                            odecfail                  ;
  output logic             [pERR_W-1 : 0] oerr                      ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cREMAP_FACTOR  = ceil(cGR_SYST_BIT_COL[pIDX_GR], pDAT_NUM);  // take only systematic bits
  localparam int cREMAP_CNT_W   = clogb2(cREMAP_FACTOR);

  localparam int cDWC_FACTOR    = pDAT_W/pLLR_BY_CYCLE;
  localparam int cDWC_CNT_W     = clogb2(cDWC_FACTOR);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic                 write;
  logic                 wfull;
  logic [pADDR_W-1 : 0] waddr;

  logic  [pDAT_W-1 : 0] dwc_dat [cREMAP_FACTOR * pDAT_NUM];
  logic                 dwc_write;

  struct packed {
    logic                    done;
    logic [cDWC_CNT_W-1 : 0] value;
  } dwc_cnt;

  hb_zc_t used_zc;

  logic [cREMAP_CNT_W : 0] remap_write_cnt; // + 1 bit
  logic                    remap_wfull;
  logic    [pADDR_W-1 : 0] remap_waddr;
  logic     [pDAT_W-1 : 0] remap_dat  [pDAT_NUM][cREMAP_FACTOR];


  //------------------------------------------------------------------------------------------------------
  // tags
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival & isop) begin
        ocode_ctx <= icode_ctx;
        otag      <= itag;
        odecfail  <= idecfail;
      end
      //
      if (ival) begin
        oerr <= isop ? ierr : (oerr + ierr);
      end
    end
  end

  assign used_zc = cZC_TAB[icode_ctx.idxLs][icode_ctx.idxZc]/pDAT_W;

  //------------------------------------------------------------------------------------------------------
  // DWC converter : bit order LSB first
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      write <= 1'b0;
      wfull <= 1'b0;
    end
    else if (iclkena) begin
      write <= ival;
      wfull <= ival & ieop;
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival) begin
        // dwc counter
        if (isop) begin
          dwc_cnt       <= '0;
          dwc_cnt.done  <= (cDWC_FACTOR < 2);
        end
        else begin
          dwc_cnt.value <= dwc_cnt.done ? '0 : (dwc_cnt + 1'b1);
          dwc_cnt.done  <= (cDWC_FACTOR < 2) ? 1'b1 : dwc_cnt.value == (cDWC_FACTOR-2);
        end
        // waddr
        waddr <= isop ? '0 : (waddr + dwc_cnt.done);
        //
        for (int col = 0; col < cGR_SYST_BIT_COL[pIDX_GR]; col++) begin
          if (pDAT_W == pLLR_BY_CYCLE) begin
            dwc_dat[col] <= idat[col];
          end
          else begin
            dwc_dat[col] <= {idat[col], dwc_dat[col][pDAT_W-1 : pLLR_BY_CYCLE]};
          end
        end
      end // ival
    end // iclkena
  end // iclk

  assign dwc_write = write & dwc_cnt.done;

  //------------------------------------------------------------------------------------------------------
  // optional remap (only in DWC mode)
  //------------------------------------------------------------------------------------------------------

  generate
    if (cREMAP_FACTOR == 1) begin // no remap write data as is

      assign owrite = dwc_write;
      assign owfull = wfull;
      assign owaddr = waddr;
      assign owdat  = dwc_dat;

    end
    else if (cREMAP_FACTOR <= cDWC_FACTOR)  begin // do remap

      always_ff @(posedge iclk or posedge ireset) begin
        if (ireset) begin
          remap_write_cnt <= '1;
          remap_wfull     <= '0;
        end
        else if (iclkena) begin
          if (dwc_write) begin
            remap_write_cnt <= cREMAP_FACTOR-1;
          end
          else if (!remap_write_cnt[cREMAP_CNT_W]) begin
            remap_write_cnt <= remap_write_cnt - 1'b1;
          end
          //
          if (dwc_write) begin
            remap_wfull <= wfull;
          end
        end
      end

      always_ff @(posedge iclk) begin
        if (iclkena) begin
          // waddr
          if (dwc_write) begin
            remap_waddr <= waddr;
          end
          else if (!remap_write_cnt[cREMAP_CNT_W]) begin
            remap_waddr <= remap_waddr + used_zc;
          end
          // wdata
          if (dwc_write) begin
            for (int num = 0; num < pDAT_NUM; num++) begin
              for (int i = 0; i < cREMAP_FACTOR; i++) begin
                remap_dat[num][i] <= dwc_dat[num*cREMAP_FACTOR + i];
              end
            end
          end
          else if (!remap_write_cnt[cREMAP_CNT_W]) begin
            for (int num = 0; num < pDAT_NUM; num++) begin
              for (int i = 0; i < cREMAP_FACTOR-1; i++) begin
                remap_dat[num][i] <= remap_dat[num][i+1];
              end
            end
          end // write
        end // iclkena
      end // iclk

      //
      //
      always_ff @(posedge iclk or posedge ireset) begin
        if (ireset) begin
          owrite <= 1'b0;
          owfull <= 1'b0;
        end
        else if (iclkena) begin
          owrite <= !remap_write_cnt[cREMAP_CNT_W];
          owfull <= !remap_write_cnt[cREMAP_CNT_W] & remap_wfull & (remap_write_cnt[cREMAP_CNT_W-1 : 0] == 0);
        end
      end

      always_ff @(posedge iclk) begin
        if (iclkena) begin
          owaddr <= remap_waddr;
          for (int num = 0; num < pDAT_NUM; num++) begin
            owdat[num] <= remap_dat[num][0];
          end
        end
      end

    end
    else begin

      assign owdat[-1] = 'x;  // incorrect parameter settings
      // synthesis translate_off
      always_comb begin
        $error("incorrect data width conversion");
      end
      // synthesis translate_on
    end
  endgenerate

endmodule

//
// Project       : ldpc 3gpp
// Author        : Shekhalev Denis (des00)
// Workfile      : bertest_beh.v
// Description   : testbench for 3GPP LDPC codec for QPSK AWGN
//

`timescale 1ns/1ns

`include "define.vh"
`include "awgn_class.vh"
`include "pkt_class.vh"

//`define __MEM_LOG_ON__
//`define __DATA_CAPTURE_ON__

module bertest;

  localparam int cENC_DAT_W   =  8 ;

  localparam int cDEC_DAT_W   =  8 ;

  `include "../rtl/ldpc_3gpp/ldpc_3gpp_constants.svh"
  `include "../rtl/ldpc_3gpp/ldpc_3gpp_hc.svh"

  parameter bit pIDX_GR       = 0 ;
  parameter int pIDX_LS       = 0 ;
  parameter int pIDX_ZC       = 7 ;
  parameter int pCODE         = 8 ;
  parameter int pDO_PUNCT     = 1 ;

  //
  parameter int pERR_W        = 16 ;
  parameter int pERR_SFACTOR  =  2 ;
  //
  parameter int pLLR_BY_CYCLE =  1 ;
  parameter int pROW_BY_CYCLE =  8 ;
  //
  parameter int pVNORM_FACTOR =  7 ;
  parameter int pCNORM_FACTOR =  7 ;

  parameter bit pUSE_SC_MODE  =  1 ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic                    iclk          ;
  logic                    ireset        ;
  logic                    iclkena       ;

  logic                    iidxGr        ;
  logic            [2 : 0] iidxLs        ;
  logic            [2 : 0] iidxZc        ;
  logic            [5 : 0] icode         ;
  logic                    ipunct        ;

  logic            [7 : 0] iNiter        ;
  logic                    ifmode        ;
  //
  logic                    enc__isop     ;
  logic                    enc__ival     ;
  logic                    enc__ieop     ;
  logic [cENC_DAT_W-1 : 0] enc__idat     ;
  //
  logic                    enc__obusy    ;
  logic                    enc__ordy     ;
  //
  logic                    enc__ireq     ;
  logic                    enc__ofull    ;
  //
  logic                    enc__osop     ;
  logic                    enc__oval     ;
  logic                    enc__oeop     ;
  logic [cENC_DAT_W-1 : 0] enc__odat     ;

  logic                    dec__isop     ;
  logic                    dec__ival     ;
  logic                    dec__ieop     ;

  logic                    dec__obusy    ;
  logic                    dec__ordy     ;

  logic                    dec__ireq     ;
  logic                    dec__ofull    ;

  logic                    dec__osop     ;
  logic                    dec__oval     ;
  logic                    dec__oeop     ;
  logic [cDEC_DAT_W-1 : 0] dec__odat     ;

  logic                    dec__odecfail ;
  logic     [pERR_W-1 : 0] dec__oerr     ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_enc_fix
  #(
    .pDAT_W    ( cENC_DAT_W ) ,
    //
    .pIDX_GR   ( pIDX_GR    ) ,
    .pIDX_LS   ( pIDX_LS    ) ,
    .pIDX_ZC   ( pIDX_ZC    ) ,
    .pCODE     ( pCODE      ) ,
    .pDO_PUNCT ( pDO_PUNCT  )
  )
  enc
  (
    .iclk    ( iclk       ) ,
    .ireset  ( ireset     ) ,
    .iclkena ( iclkena    ) ,
    //
    .isop    ( enc__isop  ) ,
    .ival    ( enc__ival  ) ,
    .ieop    ( enc__ieop  ) ,
    .idat    ( enc__idat  ) ,
    .itag    ( '0         ) ,
    //
    .obusy   ( enc__obusy ) ,
    .ordy    ( enc__ordy  ) ,
    //
    .ireq    ( enc__ireq  ) ,
    .ofull   ( enc__ofull ) ,
    //
    .osop    ( enc__osop  ) ,
    .oval    ( enc__oval  ) ,
    .oeop    ( enc__oeop  ) ,
    .odat    ( enc__odat  ) ,
    .otag    (            )
  );

  bit [2 : 0] enc_req_cnt;

  always_ff @(posedge iclk) begin
    enc_req_cnt <= enc_req_cnt + 1'b1;
  end

  assign enc__ireq = !dec__obusy & &enc_req_cnt;  // 1/8 of cycle when decoder is not busy

  //------------------------------------------------------------------------------------------------------
  // QPSK mapper. Power is 2
  //     00 = -1-1i
  //     01 = -1+1i
  //     10 =  1-1i
  //     11 =  1+1i
  //------------------------------------------------------------------------------------------------------

  const real cQPSK_POW = 2.0;

  logic            [7 : 0] enc_sop;
  logic            [7 : 0] enc_val;
  logic            [7 : 0] enc_eop;
  logic [cENC_DAT_W-1 : 0] enc_dat;

  logic             qpsk_sop;
  logic             qpsk_val;
  logic             qpsk_eop;
  cmplx_real_dat_t  qpsk;

  always_ff @(posedge iclk) begin
    enc_sop <= (enc__oval & enc__osop) ? 8'b0000_0001 : (enc_sop >> 1);
    enc_val <=  enc__oval              ? 8'b0101_0101 : (enc_val >> 1);
    enc_eop <= (enc__oval & enc__oeop) ? 8'b0100_0000 : (enc_eop >> 1);
    enc_dat <=  enc__oval              ? enc__odat    : (enc_dat >> 1);
  end

  assign qpsk_sop = enc_sop[0];
  assign qpsk_val = enc_val[0];
  assign qpsk_eop = enc_eop[0];

  assign qpsk.re  = enc_dat[1] ? 1 : -1;
  assign qpsk.im  = enc_dat[0] ? 1 : -1;

  //------------------------------------------------------------------------------------------------------
  // awgn channel
  //------------------------------------------------------------------------------------------------------

  awgn_class        awgn = new;

  cmplx_real_dat_t  awgn_ch;
  bit               awgn_sop;
  bit               awgn_eop;
  bit               awgn_val;

  const bit awgn_bypass = 0;

  always_ff @(posedge iclk) begin
    awgn_sop <= qpsk_sop;
    awgn_eop <= qpsk_eop;
    awgn_val <= qpsk_val;
    if (qpsk_val) begin
      awgn_ch <= awgn.add(qpsk, awgn_bypass);
    end
  end

  //------------------------------------------------------------------------------------------------------
  // scale data: set QPSK ref point to -+1024 point and saturate canstellation to -2047 : + 2047 point
  //------------------------------------------------------------------------------------------------------

  const int NGC_MAX = 2047;
  const int NGC_REF = 1024;

  bit signed [15 : 0] ngc_dat_re;
  bit signed [15 : 0] ngc_dat_im;

  always_comb begin
    ngc_dat_re = $floor(awgn_ch.re * NGC_REF + 0.5);
    ngc_dat_im = $floor(awgn_ch.im * NGC_REF + 0.5);
    // saturate
    if (ngc_dat_re > NGC_MAX)
      ngc_dat_re = NGC_MAX;
    else if (ngc_dat_re < -NGC_MAX)
      ngc_dat_re = -NGC_MAX;
    //
    if (ngc_dat_im > NGC_MAX)
      ngc_dat_im = NGC_MAX;
    else if (ngc_dat_im < -NGC_MAX)
      ngc_dat_im = -NGC_MAX;
  end

  //------------------------------------------------------------------------------------------------------
  // cut off bits for decoder
  //  take 5bits {5.3} from ref point
  //------------------------------------------------------------------------------------------------------

//localparam int cDAT_W = 4; // {4.2}
  localparam int cDAT_W = 5; // {5.3}

  bit signed [cDAT_W-1 : 0] dat2llr_re;
  bit signed [cDAT_W-1 : 0] dat2llr_im;

  always_comb begin
    dat2llr_re = ngc_dat_re[11 : 12-cDAT_W];
    dat2llr_im = ngc_dat_im[11 : 12-cDAT_W];
  end

  //------------------------------------------------------------------------------------------------------
  // get LLR stream
  //------------------------------------------------------------------------------------------------------

  parameter int pLLR_W  =  cDAT_W;
  parameter int pNODE_W =  pLLR_W; //max(6, cDAT_W);

  logic               [1 : 0] dec_sop;
  logic               [1 : 0] dec_val;
  logic               [1 : 0] dec_eop;
  logic signed [pLLR_W-1 : 0] dec_LLR  [2] ;

  logic signed [pLLR_W-1 : 0] dec__iLLR  [pLLR_BY_CYCLE] ;

  always_ff @(posedge iclk) begin
    dec_sop <= (awgn_val & awgn_sop) ? 2'b01 : (dec_sop >> 1);
    dec_val <=  awgn_val             ? 2'b11 : (dec_val >> 1);
    dec_eop <= (awgn_val & awgn_eop) ? 2'b10 : (dec_eop >> 1);

    if (awgn_val) begin
      dec_LLR[0] <= dat2llr_im;
      dec_LLR[1] <= dat2llr_re;
    end
    else begin
      dec_LLR[0] <= dec_LLR[1];
    end
  end

  assign dec__isop    = dec_sop[0];
  assign dec__ival    = dec_val[0];
  assign dec__ieop    = dec_eop[0];

  assign dec__iLLR[0] = dec_LLR[0];

  //------------------------------------------------------------------------------------------------------
  // decoder
  //------------------------------------------------------------------------------------------------------

  ldpc_3gpp_dec_fix
  #(
    .pIDX_GR       ( pIDX_GR       ) ,
    .pIDX_LS       ( pIDX_LS       ) ,
    .pIDX_ZC       ( pIDX_ZC       ) ,
    .pCODE         ( pCODE         ) ,
    .pDO_PUNCT     ( pDO_PUNCT     ) ,
    //
    .pLLR_W        ( pLLR_W        ) ,
    .pNODE_W       ( pNODE_W       ) ,
    //
    .pDAT_W        ( cDEC_DAT_W    ) ,
    //
    .pERR_W        ( pERR_W        ) ,
    .pERR_SFACTOR  ( pERR_SFACTOR  ) ,
    //
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pROW_BY_CYCLE ( pROW_BY_CYCLE ) ,
    //
    .pVNORM_FACTOR ( pVNORM_FACTOR ) ,
    .pCNORM_FACTOR ( pCNORM_FACTOR ) ,
    .pUSE_SC_MODE  ( pUSE_SC_MODE  )
  )
  dec
  (
    .iclk     ( iclk     ) ,
    .ireset   ( ireset   ) ,
    .iclkena  ( iclkena  ) ,
    //
    .iNiter   ( iNiter        ) ,
    .ifmode   ( ifmode        ) ,
    //
    .ival     ( dec__ival     ) ,
    .isop     ( dec__isop     ) ,
    .ieop     ( dec__ieop     ) ,
    .itag     ( '0            ) ,
    .iLLR     ( dec__iLLR     ) ,
    //
    .obusy    ( dec__obusy    ) ,
    .ordy     ( dec__ordy     ) ,
    //
    .ireq     ( dec__ireq     ) ,
    .ofull    ( dec__ofull    ) ,
    //
    .oval     ( dec__oval     ) ,
    .osop     ( dec__osop     ) ,
    .oeop     ( dec__oeop     ) ,
    .otag     (               ) ,
    .odat     ( dec__odat     ) ,
    //
    .odecfail ( dec__odecfail ) ,
    .oerr     ( dec__oerr     )
  );

  assign dec__ireq = 1'b1;

  //------------------------------------------------------------------------------------------------------
  //  capture data
  //------------------------------------------------------------------------------------------------------

`ifdef __DATA_CAPTURE_ON__
  int enc_data  [4096];
  int enc_addr;

  int enc_odata [4096];
  int enc_oaddr;

  int dec_dLLR   [4096];
  int dec_addr;

  initial begin
    int cfp;

    enc_addr  = 0;
    enc_oaddr = 0;
    dec_addr  = 0;

    fork
      forever begin
        @(posedge iclk iff enc__ival);
        enc_data[enc_addr] = enc__idat;
        enc_addr++;
        if (enc__ieop) break;
      end
      //
      forever begin
        @(posedge iclk iff enc__oval);
        enc_odata[enc_oaddr] = enc__odat;
        enc_oaddr++;
        if (enc__oeop) break;
      end
      //
      forever begin
        @(posedge iclk iff dec__ival);
        dec_dLLR[dec_addr] = dec__iLLR[0];
        dec_addr++;
        if (dec__ieop) break;
      end
    join

    //
    cfp = $fopen("get_test_data.m");

    $fdisplay(cfp, "function [enc_data, enc_odata, dec_data] = get_test_data\n");

    $fdisplay(cfp, "enc_data = [ ...");
    for (int n = 0; n < enc_addr; n++) begin
      for (int i = 0; i < cENC_DAT_W; i++) begin
        if (i == cENC_DAT_W-1)
          $fdisplay(cfp, "%0d ...", enc_data[n][i]);
        else
          $fwrite(cfp, "%0d ", enc_data[n][i]);
      end
    end
    $fdisplay(cfp, "];");
    //
    $fdisplay(cfp, "enc_odata = [ ...");
    for (int n = 0; n < enc_oaddr; n++) begin
      for (int i = 0; i < cENC_DAT_W; i++) begin
        if (i == cENC_DAT_W-1)
          $fdisplay(cfp, "%0d ...", enc_odata[n][i]);
        else
          $fwrite(cfp, "%0d ", enc_odata[n][i]);
      end
    end
    $fdisplay(cfp, "];");
    //
    $fdisplay(cfp, "dec_data = [ ...");
    for (int n = 0; n < dec_addr; n++) begin
      if ((n % cENC_DAT_W) == cENC_DAT_W-1)
        $fdisplay(cfp, "%0d ...", dec_dLLR[n]);
      else
        $fwrite(cfp, "%0d ", dec_dLLR[n]);
    end
    $fdisplay(cfp, "];\n");
    $fdisplay(cfp, "end");
    $fclose(cfp);
  end
`endif

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  initial begin
    iclk <= 1'b0;
    #5ns forever #5ns iclk = ~iclk;
  end

  initial begin
    ireset = 1'b1;
    repeat (2) @(negedge iclk);
    ireset = 1'b0;
  end

  assign iclkena  = 1'b1;

  //------------------------------------------------------------------------------------------------------
  // tb settings
  //------------------------------------------------------------------------------------------------------

  assign iNiter = 10;
  assign ifmode = 0;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  const int B = 1e5;

  int Npkt;

`ifdef __DATA_CAPTURE_ON__
  real EbNo [] = '{4.0};
`else
  real EbNo [] = '{1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0};
//real EbNo [] = '{3.625};
//real EbNo [] = '{4.0};
//real EbNo [] = '{4.0, 4.5, 5.0, 5.5};
//real EbNo [] = '{3.5, 3.75, 4.0, 4.25, 4.5, 4.75, 5.0};
//real EbNo [] = '{2.5, 3.0, 3.5, 4.0, 4.5, 4.75};
//real EbNo [] = '{4.25, 4.5, 4.75};
//real EbNo [] = '{0.5, 1.0, 1.5, 2.0, 2.5, 3.0};
//real EbNo [] = '{0.5, 0.75, 1.0, 1.25, 1.5, 1.75};
`endif

  //------------------------------------------------------------------------------------------------------
  // data generator
  //------------------------------------------------------------------------------------------------------

  event test_done;

  pkt_class #(1) code_queue [$];

  initial begin
    real coderate;
    int  data_bit_length;

    pkt_class #(1) code;
    //
    code_queue.delete();
    //
    enc__isop <= '0;
    enc__ieop <= '0;
    enc__ival <= '0;
    enc__idat <= '0;
    //
    awgn.init_EbNo(.EbNo(EbNo[0]), .bps(2), .coderate(1.0), .Ps(cQPSK_POW), .seed(0));
    //
    @(posedge iclk iff !ireset);

    coderate        = get_coderate(pIDX_GR, pCODE, pDO_PUNCT);
    data_bit_length = get_data_bit_length(pIDX_GR, pIDX_LS, pIDX_ZC);

    Npkt = B/data_bit_length;
`ifdef __DATA_CAPTURE_ON__
      Npkt = 1;
`endif

    foreach (EbNo[k]) begin
      //
      repeat (10) @(posedge iclk);
      awgn.init_EbNo(.EbNo(EbNo[k]), .bps(2), .coderate(coderate), .Ps(cQPSK_POW), .seed(2));
      awgn.log();
      void'(awgn.add('{0, 0}, 0));
      repeat (10) @(posedge iclk);
      //
      @(posedge iclk iff enc__ordy);
      //
      for (int n = 0; n < Npkt; n++) begin
        // generate data
        code = new(data_bit_length);
        void'(code.randomize());

        // drive data
        for (int i = 0; i < data_bit_length/cENC_DAT_W; i++) begin
          enc__ival <= 1'b1;
          enc__isop <= (i == 0);
          enc__ieop <= (i == data_bit_length/cENC_DAT_W-1);
          for (int j = 0; j < cENC_DAT_W; j++) begin
            enc__idat[j] <= code.dat[cENC_DAT_W*i + j];
          end
          @(posedge iclk iff enc__ordy);
          enc__ival <= 1'b0;
          enc__isop <= 1'b0;
          enc__ieop <= 1'b0;
        end
        // save reference
        code_queue.push_back(code);
        //
        @(posedge iclk iff enc__ordy);
        //
`ifndef __DATA_CAPTURE_ON__
        if ((n % 128) == 0)
`endif
        begin
          $display("sent %0d packets", n);
        end
      end
      //
      @(test_done);
    end
  end

  //------------------------------------------------------------------------------------------------------
  // data reciver & checker
  //------------------------------------------------------------------------------------------------------

  int numerr      [];
  int est_numerr  [];

  initial begin
    real coderate;
    int  data_bit_length;
    int  code_bit_length;
    //
    pkt_class #(1) decode;
    pkt_class #(1) code;
    //
    int addr;
    int err;
    int n;
    string s;
    //
    coderate        = get_coderate(pIDX_GR, pCODE, pDO_PUNCT);
    data_bit_length = get_data_bit_length(pIDX_GR, pIDX_LS, pIDX_ZC);
    code_bit_length = data_bit_length/coderate;
    //
    numerr      = new[EbNo.size()];
    est_numerr  = new[EbNo.size()];
    foreach (numerr[k]) begin
      numerr[k]     = 0;
      est_numerr[k] = 0;
    end
    decode    = new(data_bit_length);
    //
    //
    @(posedge iclk iff !ireset);
    repeat (2) @(posedge iclk);
    //
    foreach (EbNo[k]) begin
      n = 0;
      //
      do begin
        @(posedge iclk);
        if (dec__oval) begin
          if (dec__osop) addr = 0;
          //
          for (int i = 0; i < cDEC_DAT_W; i++) begin
            decode.dat[addr] = dec__odat[i];
            addr++;
          end
          //
          if (dec__oeop) begin
            n++;
            code    = code_queue.pop_front();

            err     = code.do_compare(decode);
            //
            numerr[k]     += err;
            est_numerr[k] += dec__oerr;
`ifndef __DATA_CAPTURE_ON__
            if ((n % 32) == 0)
`endif
            begin
              $display("%0t decode done %0d. decfail = %0d, err = %0d, est err %0d", $time, n, dec__odecfail, numerr[k], est_numerr[k]);
            end
          end
        end
      end
      while (n < Npkt);
      -> test_done;

      // intermediate results
      $display("decode EbN0(SNR) = %0.2f(%0.2f) done. ber = %0.2e, fer = %0.2e", EbNo[k], awgn.SNR, numerr[k]*1.0/(Npkt*data_bit_length), est_numerr[k]*1.0/(Npkt*code_bit_length));
    end
    // final results
    for (int k = 0; k < EbNo.size(); k++) begin
      $display("bits %0d EbNo = %0.2f: ber = %0.2e. fer = %0.2e", Npkt*data_bit_length, EbNo[k], numerr[k]*1.0/(Npkt*data_bit_length), est_numerr[k]*1.0/(Npkt*code_bit_length));
    end
    //
    #1us;
    $display("test done %0t", $time);
    $stop;
  end

  //------------------------------------------------------------------------------------------------------
  // usefull functions
  //------------------------------------------------------------------------------------------------------

  function automatic real get_coderate (input bit idxGr, int code, bit do_punct);
  begin
    if (idxGr) begin
      if (do_punct)
        get_coderate = 1.0*10/(8 + code);
      else
        get_coderate = 1.0*10/(10 + code);
    end
    else begin
      if (do_punct)
        get_coderate = 1.0*22/(20 + code);
      else
        get_coderate = 1.0*22/(22 + code);
    end
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  // MEM capture logic
  //------------------------------------------------------------------------------------------------------
`ifdef __MEM_LOG_ON__
  //
  // capture ram
  // dec.engine.mem.node_mem_row_inst[row].node_mem_col_inst[col].inst.memb[]
  int fp;

  initial begin
    string tstr;

    int used_row;
    int used_col;
    int used_zc;

    int iter;

    fp = $fopen("dec_3gpp_input_log.txt", "w");

    @(posedge iclk iff dec__obusy);

    @(negedge dec.engine.ctrl__ivnode_busy iff dec.engine.ctrl__oload_mode);

    repeat (4) @(posedge iclk);

    $fdisplay(fp, "initial upload metric");

//  used_row = pIDX_GR ? 42 : 46;
    used_row = 16;
    used_col = pIDX_GR ? 14 : 26;
    used_zc  = dec.engine.hb_tab__oused_zc;

    for (int row = 0; row < used_row; row++) begin
      for (int zc = 0; zc < used_zc; zc++) begin
        tstr = $psprintf("[%0d][%0d] = [", row, zc);
        for (int col = 0; col < used_col; col++) begin
          if (pLLR_BY_CYCLE == 1) begin
            tstr = {tstr, $psprintf("%3d ", $signed(dec.engine.mem.mem_mirrow[row % pROW_BY_CYCLE][col][zc + (row/pROW_BY_CYCLE)*used_zc][0 +: dec.pNODE_W]))};
          end
        end
        tstr = {tstr, "]"};
        //
        if (row >= 4) begin
          tstr = {tstr, $psprintf("[%3d] ", $signed(dec.ibuffer.mem_mirrow[row % pROW_BY_CYCLE][zc + (row/pROW_BY_CYCLE)*used_zc][0 +: dec.pLLR_W]))};
        end
        $fdisplay(fp, "%s", tstr);
      end
      $fdisplay(fp, "");
    end

    $fclose(fp);

    iter = 0;

    fp = $fopen("dec_3gpp_iter_log.txt", "w");
    do begin
      @(negedge dec.engine.ctrl__icnode_busy);
      repeat (5) @(posedge iclk);
      $fdisplay(fp, "cnode %0d iter", iter);

      for (int row = 0; row < used_row; row++) begin
        for (int zc = 0; zc < used_zc; zc++) begin
          tstr = $psprintf("[%0d][%0d] = [", row, zc);
          for (int col = 0; col < used_col; col++) begin
            if (pLLR_BY_CYCLE == 1) begin
              tstr = {tstr, $psprintf("%3d ", $signed(dec.engine.mem.mem_mirrow[row % pROW_BY_CYCLE][col][zc + (row/pROW_BY_CYCLE)*used_zc][0 +: dec.pNODE_W]))};
            end
          end
          $fdisplay(fp, "%s", {tstr, "]"});
        end
        $fdisplay(fp, "");
      end

      @(negedge dec.engine.ctrl__ivnode_busy);
      repeat (5) @(posedge iclk);
      $fdisplay(fp, "vnode %0d iter", iter);

      for (int row = 0; row < used_row; row++) begin
        for (int zc = 0; zc < used_zc; zc++) begin
          tstr = $psprintf("[%0d][%0d] = [", row, zc);
          for (int col = 0; col < used_col; col++) begin
            if (pLLR_BY_CYCLE == 1) begin
              tstr = {tstr, $psprintf("%3d ", $signed(dec.engine.mem.mem_mirrow[row % pROW_BY_CYCLE][col][zc + (row/pROW_BY_CYCLE)*used_zc][0 +: dec.pNODE_W]))};
            end
          end
          $fdisplay(fp, "%s", {tstr, "]"});
        end
        $fdisplay(fp, "");
      end

      iter++;

      if (dec__obusy == 0) break;
    end
    while (1);

    $fclose(fp);

  end

`endif

endmodule



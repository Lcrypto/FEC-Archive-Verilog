//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : bertest.vh
// Description   : testbench for LDPC coder/decoder
//

`include "define.vh"
`include "awgn.vh"
`include "types.vh"

module bertest_rtl ;

  localparam pCODE  = 5;
//localparam pN     = 576;
  localparam pN     = 2304;

  localparam pDAT_W = 4; // encoder bitwidth 2/4/8
  localparam pTAG_W = 4;

  localparam pLLR_BY_CYCLE = 8; // decoder "bitwidth" 2/4/8/16

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  real cCODE_RATE [] = '{ 1.0/3,
                          1.0/2, 2.0/3, 3.0/4, 4.0/5, 5.0/6, 6.0/7, 7.0/8, 8.0/9, 9.0/10,
                          2.0/5};

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic                       iclk     ;
  logic                       ireset   ;
  logic                       iclkena  ;

  logic                       enc__isop     ;
  logic                       enc__ieop     ;
  logic                       enc__ieof     ;
  logic                       enc__ival     ;
  logic        [pTAG_W-1 : 0] enc__itag     ;
  logic        [pDAT_W-1 : 0] enc__idat     ;
  //
  logic                       enc__ordy     ;
  logic                       enc__osop     ;
  logic                       enc__oeop     ;
  logic                       enc__oeof     ;
  logic                       enc__oval     ;
  logic        [pDAT_W-1 : 0] enc__odat     ;
  logic        [pTAG_W-1 : 0] enc__otag     ;

  bit                 [7 : 0] dec__iNiter;

  logic                       dec__isop  ;
  logic                       dec__ieop  ;
  logic                       dec__ieof  ;
  logic                       dec__ival  ;
  logic        [pTAG_W-1 : 0] dec__itag;

  logic                       dec__obusy ;
  logic                       dec__ordy  ;

  logic                       dec__osop  ;
  logic                       dec__oeop  ;
  logic                       dec__oval  ;
  logic [pLLR_BY_CYCLE-1 : 0] dec__odat  ;
  logic        [pTAG_W-1 : 0] dec__otag;

  logic              [15 : 0] dec__oerr  ;


  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  ldpc_enc
  #(
    .pCODE  ( pCODE  ) ,
    .pDAT_W ( pDAT_W ) ,
    .pTAG_W ( pTAG_W ) ,
    .pN     ( pN     )
  )
  enc
  (
    .iclk    ( iclk      ) ,
    .ireset  ( ireset    ) ,
    .iclkena ( iclkena   ) ,
    //
    .isop    ( enc__isop ) ,
    .ieop    ( enc__ieop ) ,
    .ieof    ( enc__ieof ) ,
    .ival    ( enc__ival ) ,
    .itag    ( enc__itag ) ,
    .idat    ( enc__idat ) ,
    //
    .ordy    ( enc__ordy ) ,
    //
    .osop    ( enc__osop ) ,
    .oeop    ( enc__oeop ) ,
    .oeof    ( enc__oeof ) ,
    .oval    ( enc__oval ) ,
    .otag    ( enc__otag ) ,
    .odat    ( enc__odat )
  );

  //------------------------------------------------------------------------------------------------------
  // QPSK mapper. Power is
  //     00 = -1-1i
  //     01 = -1+1i
  //     10 =  1-1i
  //     11 =  1+1i
  //------------------------------------------------------------------------------------------------------

  const real cQPSK_POW = 2.0;

  bit        [3 : 0] qpsk_sop;
  bit        [3 : 0] qpsk_eop;
  bit        [3 : 0] qpsk_eof;
  bit        [3 : 0] qpsk_val;
  bit [pDAT_W-1 : 0] qpsk_dat;

  generate
    if (pDAT_W == 8) begin
      always_ff @(posedge iclk) begin
        qpsk_sop <= enc__oval ? {enc__osop, 3'b0} : (qpsk_sop << 1);
        qpsk_eop <= enc__oval ? {3'b0, enc__oeop} : (qpsk_eop << 1);
        qpsk_eof <= enc__oval ? {3'b0, enc__oeof} : (qpsk_eof << 1);
        qpsk_val <= enc__oval ? 4'b1111           : (qpsk_val << 1);
        qpsk_dat <= enc__oval ? enc__odat         : (qpsk_dat >> 2);
      end
    end
    else if (pDAT_W == 4) begin
      always_ff @(posedge iclk) begin
        qpsk_sop <= enc__oval ? {enc__osop, 3'b0}       : (qpsk_sop << 1);
        qpsk_eop <= enc__oval ? {1'b0, enc__oeop, 2'b0} : (qpsk_eop << 1);
        qpsk_eof <= enc__oval ? {1'b0, enc__oeof, 2'b0} : (qpsk_eof << 1);
        qpsk_val <= enc__oval ? 4'b1100                 : (qpsk_val << 1);
        qpsk_dat <= enc__oval ? enc__odat               : (qpsk_dat >> 2);
      end
    end
    else if (pDAT_W == 2) begin
      always_ff @(posedge iclk) begin
        qpsk_sop <= {enc__osop, 3'b0};
        qpsk_eop <= {enc__oeop, 3'b0};
        qpsk_eof <= {enc__oeof, 3'b0};
        qpsk_val <= {enc__oval, 3'b0};
        qpsk_dat <= enc__odat;
      end
    end
    else begin

    end
  endgenerate

  cmplx_real_dat_t   qpsk;

  assign qpsk.re = qpsk_dat[1] ? 1 : -1;
  assign qpsk.im = qpsk_dat[0] ? 1 : -1;

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
    awgn_sop <= qpsk_sop[3];
    awgn_eop <= qpsk_eof[3]; // enc__oeop - it's systematic bits end
    awgn_val <= qpsk_val[3];
    if (qpsk_val[3]) begin
      awgn_ch = awgn.add(qpsk, awgn_bypass);
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

//  dat2llr_re = ngc_dat_re[11 : 12-cDAT_W] + ngc_dat_re[15];
//  dat2llr_im = ngc_dat_im[11 : 12-cDAT_W] + ngc_dat_im[15];

//  dat2llr_re = ngc_dat_re[11 : 12-cDAT_W] + (ngc_dat_re[15] & (ngc_dat_re[12-cDAT_W-1 : 0] != 0));
//  dat2llr_im = ngc_dat_im[11 : 12-cDAT_W] + (ngc_dat_im[15] & (ngc_dat_im[12-cDAT_W-1 : 0] != 0));
  end

  //------------------------------------------------------------------------------------------------------
  // get LLR stream
  //------------------------------------------------------------------------------------------------------

  logic signed [cDAT_W-1 : 0] dec__iLLR [pLLR_BY_CYCLE];

  bit [2 : 0] dec_cnt;

  always_ff @(posedge iclk) begin
    if (awgn_val)
      dec_cnt <= awgn_sop ? 1'b1 : (dec_cnt + 1'b1);
    //
    if (pLLR_BY_CYCLE == 16) begin
      dec__ival <= awgn_val & !awgn_sop & &dec_cnt[2:0];
      dec__ieop <= awgn_eop;
      //
      if (awgn_val & awgn_sop)
        dec__isop <= 1'b1;
      else if (dec__ival)
        dec__isop <= 1'b0;
      //
      if (awgn_val) begin
        for (int i = 0; i < pLLR_BY_CYCLE/2; i++) begin
          dec__iLLR[pLLR_BY_CYCLE-1 - 2*i] <= (i == 0) ? dat2llr_re : dec__iLLR[pLLR_BY_CYCLE-1 - 2*(i-1)];
          dec__iLLR[pLLR_BY_CYCLE-2 - 2*i] <= (i == 0) ? dat2llr_im : dec__iLLR[pLLR_BY_CYCLE-2 - 2*(i-1)];;
        end
      end
    end
    else if (pLLR_BY_CYCLE == 8) begin
      dec__ival <= awgn_val & !awgn_sop & &dec_cnt[1:0];
      dec__ieop <= awgn_eop;
      //
      if (awgn_val & awgn_sop)
        dec__isop <= 1'b1;
      else if (dec__ival)
        dec__isop <= 1'b0;
      //
      if (awgn_val) begin
        for (int i = 0; i < pLLR_BY_CYCLE/2; i++) begin
          dec__iLLR[pLLR_BY_CYCLE-1 - 2*i] <= (i == 0) ? dat2llr_re : dec__iLLR[pLLR_BY_CYCLE-1 - 2*(i-1)];
          dec__iLLR[pLLR_BY_CYCLE-2 - 2*i] <= (i == 0) ? dat2llr_im : dec__iLLR[pLLR_BY_CYCLE-2 - 2*(i-1)];;
        end
      end
    end
    else if (pLLR_BY_CYCLE == 6) begin
      dec__ival <= awgn_val & !awgn_sop & (dec_cnt == 2);
      if (awgn_val & (dec_cnt == 2))
        dec_cnt <= '0;
      //
      dec__ieop <= awgn_eop;
      //
      if (awgn_val & awgn_sop)
        dec__isop <= 1'b1;
      else if (dec__ival)
        dec__isop <= 1'b0;
      //
      if (awgn_val) begin
        for (int i = 0; i < pLLR_BY_CYCLE/2; i++) begin
          dec__iLLR[pLLR_BY_CYCLE-1 - 2*i] <= (i == 0) ? dat2llr_re : dec__iLLR[pLLR_BY_CYCLE-1 - 2*(i-1)];
          dec__iLLR[pLLR_BY_CYCLE-2 - 2*i] <= (i == 0) ? dat2llr_im : dec__iLLR[pLLR_BY_CYCLE-2 - 2*(i-1)];;
        end
      end
    end
    else if (pLLR_BY_CYCLE == 4) begin
      dec__ival <= awgn_val & !awgn_sop & dec_cnt[0];
      dec__ieop <= awgn_eop;
      //
      if (awgn_val & awgn_sop)
        dec__isop <= 1'b1;
      else if (dec__ival)
        dec__isop <= 1'b0;
      //
      if (awgn_val) begin
        for (int i = 0; i < pLLR_BY_CYCLE/2; i++) begin
          dec__iLLR[pLLR_BY_CYCLE-1 - 2*i] <= (i == 0) ? dat2llr_re : dec__iLLR[pLLR_BY_CYCLE-1 - 2*(i-1)];
          dec__iLLR[pLLR_BY_CYCLE-2 - 2*i] <= (i == 0) ? dat2llr_im : dec__iLLR[pLLR_BY_CYCLE-2 - 2*(i-1)];;
        end
      end
    end
    else if (pLLR_BY_CYCLE == 2) begin
      dec__ival     <= awgn_val;
      dec__isop     <= awgn_sop;
      dec__ieop     <= awgn_eop;
      dec__iLLR[1]  <= dat2llr_re;
      dec__iLLR[0]  <= dat2llr_im;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // decoder
  //------------------------------------------------------------------------------------------------------

  ldpc_dec
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    //
    .pLLR_W        ( cDAT_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pTAG_W        ( pTAG_W        ) ,
    //
    .pNORM_VNODE   ( 1             ) ,
    .pNORM_CNODE   ( 1             )
  )
  dec_rtl
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    //
    .iNiter  ( dec__iNiter  ) ,
    //
    .isop    ( dec__isop    ) ,
    .ieop    ( dec__ieop    ) ,
    .ival    ( dec__ival    ) ,
    .itag    ( dec__itag    ) ,
    .iLLR    ( dec__iLLR    ) ,
    //
    .obusy   ( dec__obusy   ) ,
    .ordy    ( dec__ordy    ) ,
    //
    .osop    ( dec__osop    ) ,
    .oeop    ( dec__oeop    ) ,
    .oval    ( dec__oval    ) ,
    .otag    ( dec__otag    ) ,
    .odat    ( dec__odat    ) ,
    //
    .oerr    ( dec__oerr    )
  );

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

  assign dec__iNiter = 10;

//const int Npkt = 1;
  const int Npkt = 128;
//const int Npkt = 4096;

//real EbNo [] = '{2.5, 2.75, 3.0, 3.25, 3.5, 3.75, 4.0};
//real EbNo [] = '{3.6};
//real EbNo [] = '{6.0};
//real EbNo [] = '{0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0};
//real EbNo [] = '{0.5, 1.0, 1.5, 2.0, 2.5, 3.0};
//real EbNo [] = '{0.5, 1.0, 1.5, 2.0, 2.5};
//real EbNo [] = '{0.5, 0.75, 1.0, 1.25, 1.5, 1.75};
  real EbNo [] = '{3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0};
//real EbNo [] = '{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  pkt_class code_queue [$];

  initial begin
    pkt_class code;
    //
    code_queue.delete();
    //
    enc__isop <= '0;
    enc__ieop <= '0;
    enc__ieof <= '0;
    enc__ival <= '0;
    enc__idat <= '0;
    //
    awgn.init_EbNo(.EbNo(EbNo[0]), .bps(2), .coderate(1.0), .Ps(cQPSK_POW), .seed(0));
    //
    @(posedge iclk iff !ireset);

    foreach (EbNo[k]) begin
      //
      repeat (10) @(posedge iclk);
      awgn.init_EbNo(.EbNo(EbNo[k]), .bps(2), .coderate(cCODE_RATE[pCODE]), .Ps(cQPSK_POW), .seed(2));
      awgn.log();
      void'(awgn.add('{0, 0}, 0));
      repeat (10) @(posedge iclk);
      //
      @(posedge iclk iff enc__ordy);
      //
      for (int n = 0; n < Npkt; n++) begin
        // generate data
        code = new(enc.cLDPC_DNUM);
        void'(code.randomize());

        // drive data
        for (int i = 0; i < enc.cLDPC_NUM/pDAT_W; i++) begin
          enc__ival <= 1'b1;
          enc__isop <= (i == 0);
          enc__ieop <= (i == enc.cLDPC_DNUM/pDAT_W-1);
          enc__ieof <= (i == enc.cLDPC_NUM/pDAT_W-1);
          if (i < enc.cLDPC_DNUM/pDAT_W) begin
            for (int j = 0; j < pDAT_W; j++) begin
              enc__idat[j] <= code.dat[pDAT_W*i + j];
            end
          end
          @(posedge iclk iff enc__ordy);
          enc__ival <= 1'b0;
          enc__isop <= 1'b0;
          enc__ieop <= 1'b0;
          enc__ieof <= 1'b0;
          if (pDAT_W == 4)
            @(posedge iclk);              // wait for pDAT_W/2 for QPSK mapping
          else if (pDAT_W == 8)
            repeat (3) @(posedge iclk);   // wait for 3*pDAT_W/2 for QPSK mapping
        end
        // save reference
        code_queue.push_back(code);
        // wait decoder free modules free
        repeat (16) @(posedge iclk);    // true hack

//      @(posedge iclk iff !dec__obusy);
        @(posedge iclk iff dec__ordy);
        //
        if ((n % 128) == 0)
          $display("sent %0d packets", n);
      end
    end
  end

  int numerr      [];
  int est_numerr  [];

  initial begin
    pkt_class decode;
    pkt_class code;
    int addr;
    int err;
    int n;
    string s;
    //
    numerr      = new[EbNo.size()];
    est_numerr  = new[EbNo.size()];
    foreach (numerr[k]) begin
      numerr[k]     = 0;
      est_numerr[k] = 0;
    end
    decode = new(enc.cLDPC_DNUM);
    //
    foreach (EbNo[k]) begin
      n = 0;
      //
      do begin
        @(posedge iclk);
        if (dec__oval) begin
          if (dec__osop) addr = 0;
          //
          for (int i = 0; i < pLLR_BY_CYCLE; i++) begin
            decode.dat[addr++] = dec__odat[i];
          end
          //
          if (dec__oeop) begin
            n++;
            code = code_queue.pop_front();
            err = code.do_compare(decode);
            numerr[k] += err;
            est_numerr[k] += dec__oerr;

//          $display("%0t decode done %0d. err = %0d, est err %0d", $time, n, err, dec__oerr);
            if ((n % 32) == 0) begin
              $display("decode done %0d. err = %0d, est err %0d", n, numerr[k], est_numerr[k]);
            end

//          if (n == 21) begin
//            $display("code %p", code);
//            $stop;
//          end

          end
        end
      end
      while (n < Npkt);
      $display("decode EbN0 = %0f done. ber = %0e, fer = %0e", EbNo[k], numerr[k]*1.0/(Npkt*enc.cLDPC_DNUM), est_numerr[k]*1.0/(Npkt*enc.cLDPC_DNUM));
    end
    for (int k = 0; k < EbNo.size(); k++) begin
      $display("bits %0d EbNo = %f: ber = %0e. fer = %0e", Npkt*enc.cLDPC_DNUM, EbNo[k], numerr[k]*1.0/(Npkt*enc.cLDPC_DNUM), est_numerr[k]*1.0/(Npkt*enc.cLDPC_DNUM));
    end
    #10us;
    $stop;
  end

endmodule



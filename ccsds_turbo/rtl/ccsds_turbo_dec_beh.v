//
// Project       : ccsds turbo
// Author        : Shekhalev Denis (des00)
// Workfile      : ccsds_turbo_dec_beh.vh
// Description   : behaviour model of MAP decoder with static configuration
//

`include "define.vh"

//`define __LOG_DECODER_INPUT_ENABLE__
//`define __LOG_DECODER_ITER_ENABLE__
//`define __LOG_DECODER_STAGE_ENABLE__

module ccsds_turbo_dec_beh
#(
  parameter int         pLLR_W        =     5 ,  // LLR width
  parameter int         pLLR_FP       =     3 ,  // LLR fixed point
  //
  parameter int         pN_ITER       =     8 ,
  //
  parameter bit [3 : 0] pCODE         =     1 ,
  parameter int         pN            =    48 ,
  //
  parameter int         pMMAX_TYPE    =     0 ,
  //
  parameter real        pK_LEXTR      =  0.75 ,
  parameter bit         pUSE_SC_LOGIC =     1
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  isop    ,
  ieop    ,
  ival    ,
  iLLR    ,
  //
  obusy   ,
  ordy    ,
  //
  osop    ,
  oeop    ,
  oval    ,
  odat    ,
  //
  oerr
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                       iclk    ;
  input  logic                       ireset  ;
  input  logic                       iclkena ;
  //
  input  logic                       isop    ;
  input  logic                       ieop    ;
  input  logic                       ival    ;
  input  logic signed [pLLR_W-1 : 0] iLLR    ;
  //
  output logic                       obusy   ;
  output logic                       ordy    ;
  //
  output logic                       osop    ;
  output logic                       oeop    ;
  output logic                       oval    ;
  output logic                       odat    ;
  //
  output logic              [15 : 0] oerr    ;

  //------------------------------------------------------------------------------------------------------
  // used types
  //------------------------------------------------------------------------------------------------------

  localparam int cBLLR_W        = pLLR_W + 2;  // +2 bit metric is b0 + b1 + b2

  localparam int cLEXT_W        = pLLR_W + 3;  // +3 bit of systematic  metric

  localparam int cTREL_STATE_W  = cLEXT_W + 3;

  localparam int cTREL_BRANCH_W = cTREL_STATE_W; // state + ind(1) + inx(3)

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  typedef bit signed         [pLLR_W-1 : 0] bit_llr_t;

  typedef bit signed        [cBLLR_W-1 : 0] pbit_llr_t;
  typedef bit signed        [cLEXT_W-1 : 0] L_ext_t;

  typedef bit signed  [cTREL_STATE_W-1 : 0] trel_state_t;
  typedef bit signed [cTREL_BRANCH_W-1 : 0] trel_branch_t;

  localparam int cL_EXT_SLEVEL    = 2**(cLEXT_W - 1) - 1;

  localparam int cTREL_STATE_MAX  = 2**(cTREL_STATE_W - 3); // (!!!!!!!!!) define cTREL_BRANCH_W >= cTREL_STATE_W

  const real FP = 2.0**pLLR_FP;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  bit_llr_t  LLR_ram     [6*(pN+4)];

  bit_llr_t  a00_LLR_ram [pN+4]; // single bit symbol systematic LLR
  bit_llr_t  a01_LLR_ram [pN+4]; // single bit symbol parity
  bit_llr_t  a02_LLR_ram [pN+4];
  bit_llr_t  a03_LLR_ram [pN+4];
  bit_llr_t  a11_LLR_ram [pN+4];
  bit_llr_t  a13_LLR_ram [pN+4];

  bit_llr_t  data_ram    [pN];

  //------------------------------------------------------------------------------------------------------
  // trellis
  //------------------------------------------------------------------------------------------------------

  `include "ccsds_turbo_trellis.vh"

  //------------------------------------------------------------------------------------------------------
  // main
  //------------------------------------------------------------------------------------------------------

  int addr; // input buffer access address

  initial begin : main
    int err;
    //
    osop  <= 1'b0;
    oeop  <= 1'b0;
    oval  <= 1'b0;
    odat  <= '0;
    oerr  <= '0;
    obusy <= '0;
    ordy  <= '0;
    //
    @(posedge iclk iff !ireset);
    //
    $display("bw paramters used for decoding:");
    $display("Block length %0d. code rate %0d", pN, pCODE);
    $display("iteration number : %0d", pN_ITER);
    //
    @(posedge iclk);
    ordy <= 1'b1;
    //
    log_trellis(1);
    //
    forever begin
      // fill input buffers
      if (ival) begin
        if (isop) begin
          addr = 0;
        end
        // saturate min negative metric
        if (&{iLLR[pLLR_W-1], ~iLLR[pLLR_W-2 : 0]}) // -2^(N-1)
          LLR_ram[addr] <= {1'b1, {(pLLR_W-2){1'b0}}, 1'b1};   // -(2^(N-1) - 1)
        else
          LLR_ram[addr] <= iLLR;
        //
        addr++;
        //
        if (ieop) begin
          ordy  <= 1'b0;
          obusy <= 1'b1;
        end
      end
      if (obusy) begin
        //
        do_depuncturing();
        //
//      err = do_decode ();
        err = do_opt_decode ();
        //
        for (int i = 0; i < $size(data_ram); i++) begin
          osop <= (i == 0);
          oval <= 1'b1;
          oeop <= (i == ($size(data_ram)-1));
          odat <= data_ram[i];
          oerr <= err;
          @(posedge iclk);
          osop <= 1'b0;
          oval <= 1'b0;
          oeop <= 1'b0;
        end
        obusy <= 1'b0;
        ordy  <= 1'b1;
      end
      @(posedge iclk);
    end
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  function automatic void do_depuncturing();
    int Nlength;
  begin
    Nlength = $size(a00_LLR_ram);

    a00_LLR_ram = '{default : 0};
    a01_LLR_ram = '{default : 0};
    a02_LLR_ram = '{default : 0};
    a03_LLR_ram = '{default : 0};

    a11_LLR_ram = '{default : 0};
    a13_LLR_ram = '{default : 0};
    //
    case (pCODE)
      0 : begin // 1/2
        for (int i = 0; i < Nlength; i++) begin
          a00_LLR_ram[i] = LLR_ram[2*i+0];
          if ((i % 2) == 0)
            a01_LLR_ram[i] = LLR_ram[2*i+1];
          else
            a11_LLR_ram[i] = LLR_ram[2*i+1];
        end
      end
      1 : begin // 1/3
        for (int i = 0; i < Nlength; i++) begin
          a00_LLR_ram[i] = LLR_ram[3*i+0];
          a01_LLR_ram[i] = LLR_ram[3*i+1];
          a11_LLR_ram[i] = LLR_ram[3*i+2];
        end
      end
      2 : begin // 1/4
        for (int i = 0; i < Nlength; i++) begin
          a00_LLR_ram[i] = LLR_ram[4*i+0];
          a02_LLR_ram[i] = LLR_ram[4*i+1];
          a03_LLR_ram[i] = LLR_ram[4*i+2];
          a11_LLR_ram[i] = LLR_ram[4*i+3];
        end
      end
      3 : begin // 1/6
        for (int i = 0; i < Nlength; i++) begin
          a00_LLR_ram[i] = LLR_ram[6*i+0];
          a01_LLR_ram[i] = LLR_ram[6*i+1];
          a02_LLR_ram[i] = LLR_ram[6*i+2];
          a03_LLR_ram[i] = LLR_ram[6*i+3];
          a11_LLR_ram[i] = LLR_ram[6*i+4];
          a13_LLR_ram[i] = LLR_ram[6*i+5];
        end
      end
    endcase
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  typedef struct packed {
    bit pre_sign;
    bit pre_zero;
  } sc_state_t;

  function automatic int do_decode ();
    // channel metrics
    bit_llr_t     inx       [pN+4][2];
    pbit_llr_t    inz1      [pN+4][8];
    pbit_llr_t    inz2      [pN+4][8];
    // stage metrics
    trel_state_t  inx1      [pN+4][2];
    trel_state_t  inx2      [pN+4][2];

    trel_state_t  llrx1     [pN+4][2];
    trel_state_t  llrx2     [pN+4][2];

    trel_state_t  outx1     [pN+4][2];
    trel_state_t  outx2     [pN+4][2];
    trel_state_t  outx      [pN+4][2];

    // ram buffers
    L_ext_t       Lext_ram    [pN+4][2];
    sc_state_t    Lext_ram_sc [pN+4][2];

    int Nlength;

    int err;
    //
    int fp;

  begin
    Nlength = $size(a00_LLR_ram);
    //
    // metric initialization
    for (int i = 0; i < Nlength; i++) begin
      // 2D metric
      inx[i][0] = 0;
      inx[i][1] = a00_LLR_ram[i];
      // 8D metric
      inz1[i][0] = 0;
      inz2[i][0] = 0;
      for (int j = 1; j < 8; j++) begin
        inz1[i][j] = get_parity_bit_LLR(a03_LLR_ram[i], a02_LLR_ram[i], a01_LLR_ram[i], j);
        inz2[i][j] = get_parity_bit_LLR(a13_LLR_ram[i],              0, a11_LLR_ram[i], j);
      end
    end
`ifdef __LOG_DECODER_INPUT_ENABLE__
    fp = $fopen("llr.txt", "w");
    for (int i = 0; i < Nlength; i++) begin
      $fdisplay (fp, "systematic bit LLR [%0d] = %0d", i, a00_LLR_ram[i]);
      $fdisplay (fp, "parity 0   bit LLR [%0d] = %0d %0d %0d -> %p", i, a03_LLR_ram[i], a02_LLR_ram[i], a01_LLR_ram[i], inz1[i]);
      $fdisplay (fp, "parity 1   bit LLR [%0d] = %0d %0d %0d -> %p", i, a13_LLR_ram[i],              0, a11_LLR_ram[i], inz2[i]);
      $fdisplay (fp, "");
    end
    $fclose(fp);
`endif
    //
    // rams init
    Lext_ram    = '{default : '{default : '0}};
    Lext_ram_sc = '{default : '{default : '{pre_zero : 1'b1, pre_sign : 1'b0}}};
    //
`ifdef __LOG_DECODER_STAGE_ENABLE__
    fp = $fopen("stage.txt", "w");
    $fclose(fp);
`endif
`ifdef __LOG_DECODER_ITER_ENABLE__
    fp = $fopen("iter.txt", "w");
`endif
    //
    // decode
    for (int iter = 0; iter < pN_ITER; iter++) begin
      //
      // stage 0
      //
      // add extrinsic
      for (int i = 0; i < Nlength; i++) begin
        for (int b = 0; b < 2; b++) begin
          inx1[i][b] = inx[i][b] + Lext_ram[i][b];
        end
      end
      // decode
      void'(decode_stage(outx1, inx1, inz1));
      //
      // get extrinsic L12 for next stage (no trellis termination)
      for (int i = 0; i < Nlength-4; i++) begin
        for (int b = 0; b < 2; b++) begin
          Lext_ram[i][b] = Lext_saturate(outx1[i][b] - inx1[i][b], cL_EXT_SLEVEL, pK_LEXTR);
        end
      end
`ifdef __LOG_DECODER_ITER_ENABLE__
      for (int i = 0; i < Nlength; i++) begin
        $fdisplay(fp, "iter %0d d0: %0d : inx = %p -> Lext = %p, outx = %p ", iter, i, inx[i], Lext_ram[i], outx1[i]);
//      if (i == 47)
//        $display("iter %0d d0: %0d : inx = %p, inx1 = %p, Lext = %p, outx = %p ", iter, i, inx[i], inx1[i], Lext_ram[i], outx1[i]);
      end
`endif
      //
      // stage 1
      //
      //
      // get Le12 + Ls for next stage
      for (int i = 0; i < Nlength; i++) begin
        for (int b = 0; b < 2; b++) begin
          llrx1[i][b] = Lext_ram[i][b] + inx[i][b];
        end
      end
      //
      // interleave L12 + Ls
      for (int addr = 0; addr < Nlength; addr++) begin
        automatic int i_addr;
        //
        if (addr < (Nlength-4)) // no interleave at trellis termination
          i_addr = get_permutaded_addr_zero(addr);
        else
          i_addr = addr;
        //
        for (int b = 0; b < 2; b++) begin
          inx2[addr][b] = llrx1[i_addr][b];
        end
      end
      // decode
      void'(decode_stage(outx2, inx2, inz2));
      //
      // get extrinsic Le21 for next stage
      for (int i = 0; i < Nlength; i++) begin
        for (int b = 0; b < 2; b++) begin
          llrx2[i][b] = Lext_saturate(outx2[i][b] - inx2[i][b], cL_EXT_SLEVEL, pK_LEXTR);
        end
      end
      //
      // deinterleave L12 + Ls ( no trellis termination)
      for (int addr = 0; addr < Nlength-4; addr++) begin
        automatic int d_addr;
        //
        d_addr = get_permutaded_addr_zero(addr);
        //
        for (int b = 0; b < 2; b++) begin
          Lext_ram[d_addr][b] = llrx2[addr][b];
          // sc logic
          if (pUSE_SC_LOGIC) begin
            if (!Lext_ram_sc[d_addr][b].pre_zero) begin // if previous value is not zero
              if (Lext_ram_sc[d_addr][b].pre_sign != (Lext_ram[d_addr][b] < 0)) begin // sign changed
                Lext_ram[d_addr][b] = 0;
              end
            end
            Lext_ram_sc[d_addr][b].pre_zero = (Lext_ram[d_addr][b] == 0);
            Lext_ram_sc[d_addr][b].pre_sign = (Lext_ram[d_addr][b] <  0);
          end
          //
          outx    [d_addr][b] = outx2[addr][b];
        end
      end
`ifdef __LOG_DECODER_ITER_ENABLE__
      for (int i = 0; i < Nlength; i++) begin
        $fdisplay(fp, "iter %0d d1: %0d : inx = %p -> Lext = %p, outx = %p ", iter, i, inx[i], Lext_ram[i], outx1[i]);
//      if (i == 47)
//        $display("iter %0d d1: %0d : inx = %p, inx2 = %p, Lext = %p, outx = %p ", iter, i, inx[i], llrx1[i], Lext_ram[i], outx[i]);
      end
`endif

    end
`ifdef __LOG_DECODER_ITER_ENABLE__
        $fclose(fp);
`endif

    //
    // take decision
    err = 0;
    for (int i = 0; i < $size(data_ram); i++) begin
      automatic int tmp;
      automatic bit hd;
      //
      hd         = (a00_LLR_ram[i] >= 0);
      //
      tmp        = outx[i][1] - outx[i][0];
      //
      data_ram[i] = (tmp >= 0);
      //
      err += (data_ram[i] ^ hd);
    end
    //
    do_decode = err;
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  // do optimization about metrics and so on
  //------------------------------------------------------------------------------------------------------

  function automatic int do_opt_decode ();
    // channel metrics
    bit_llr_t     inx       [pN+4];
    pbit_llr_t    inz1      [pN+4][8];
    pbit_llr_t    inz2      [pN+4][8];
    // stage metrics
    trel_state_t  inx1      [pN+4];
    trel_state_t  inx2      [pN+4];

    trel_state_t  llrx1     [pN+4];
    trel_state_t  llrx2     [pN+4];

    trel_state_t  outx1     [pN+4];
    trel_state_t  outx2     [pN+4];
    trel_state_t  outx      [pN+4];

    // ram buffers
    L_ext_t       Lext_ram    [pN+4];
    sc_state_t    Lext_ram_sc [pN+4];

    int Nlength;

    int err;
    //
    int fp;

  begin
    Nlength = $size(a00_LLR_ram);
    //
    // metric initialization
    for (int i = 0; i < Nlength; i++) begin
      // 2D metric
      inx[i] = a00_LLR_ram[i];
      // 8D metric
      inz1[i][0] = 0;
      inz2[i][0] = 0;
      for (int j = 1; j < 8; j++) begin
        inz1[i][j] = get_parity_bit_LLR(a03_LLR_ram[i], a02_LLR_ram[i], a01_LLR_ram[i], j);
        inz2[i][j] = get_parity_bit_LLR(a13_LLR_ram[i],              0, a11_LLR_ram[i], j);
      end
    end
`ifdef __LOG_DECODER_INPUT_ENABLE__
    fp = $fopen("llr.txt", "w");
    for (int i = 0; i < Nlength; i++) begin
      $fdisplay (fp, "systematic bit LLR [%0d] = %0d", i, a00_LLR_ram[i]);
      $fdisplay (fp, "parity 0   bit LLR [%0d] = %0d %0d %0d -> %p", i, a03_LLR_ram[i], a02_LLR_ram[i], a01_LLR_ram[i], inz1[i]);
      $fdisplay (fp, "parity 1   bit LLR [%0d] = %0d %0d %0d -> %p", i, a13_LLR_ram[i],              0, a11_LLR_ram[i], inz2[i]);
      $fdisplay (fp, "");
    end
    $fclose(fp);
`endif
    //
    // rams init
    Lext_ram    = '{default : '0};
    Lext_ram_sc = '{default : '{pre_zero : 1'b1, pre_sign : 1'b0}};
    //
`ifdef __LOG_DECODER_STAGE_ENABLE__
    fp = $fopen("stage.txt", "w");
    $fclose(fp);
`endif
`ifdef __LOG_DECODER_ITER_ENABLE__
    fp = $fopen("iter.txt", "w");
`endif
    //
    // decode
    for (int iter = 0; iter < pN_ITER; iter++) begin
      //
      // stage 0
      //
      // add extrinsic
      for (int i = 0; i < Nlength; i++) begin
        inx1[i] = inx[i] + Lext_ram[i];
      end
      // decode
      void'(decode_opt_stage(outx1, inx1, inz1));
      //
      // get extrinsic L12 for next stage (no trellis termination)
      for (int i = 0; i < Nlength-4; i++) begin
        Lext_ram[i] = Lext_saturate(outx1[i] - inx1[i], cL_EXT_SLEVEL, pK_LEXTR);
      end
`ifdef __LOG_DECODER_ITER_ENABLE__
      for (int i = 0; i < Nlength; i++) begin
        $fdisplay(fp, "iter %0d d0: %0d : inx = %5d -> Lext = %5d, outx = %5d ", iter, i, inx[i], Lext_ram[i], outx1[i]);
      end
`endif
      //
      // stage 1
      //
      //
      // get Le12 + Ls for next stage
      for (int i = 0; i < Nlength; i++) begin
        llrx1[i] = Lext_ram[i] + inx[i];
      end
      //
      // interleave L12 + Ls
      for (int addr = 0; addr < Nlength; addr++) begin
        automatic int i_addr;
        //
        if (addr < (Nlength-4)) // no interleave at trellis termination
          i_addr = get_permutaded_addr_zero(addr);
        else
          i_addr = addr;
        //
        inx2[addr] = llrx1[i_addr];
      end
      // decode
      void'(decode_opt_stage(outx2, inx2, inz2));
      //
      // get extrinsic Le21 for next stage
      for (int i = 0; i < Nlength; i++) begin
        llrx2[i] = Lext_saturate(outx2[i] - inx2[i], cL_EXT_SLEVEL, pK_LEXTR);
      end
      //
      // deinterleave L12 + Ls ( no trellis termination)
      for (int addr = 0; addr < Nlength-4; addr++) begin
        automatic int d_addr;
        //
        d_addr = get_permutaded_addr_zero(addr);
        //
        Lext_ram[d_addr] = llrx2[addr];
        // sc logic
        if (pUSE_SC_LOGIC) begin
          if (!Lext_ram_sc[d_addr].pre_zero) begin // if previous value is not zero
            if (Lext_ram_sc[d_addr].pre_sign != (Lext_ram[d_addr] < 0)) begin // sign changed
              Lext_ram[d_addr] = 0;
            end
          end
          Lext_ram_sc[d_addr].pre_zero = (Lext_ram[d_addr] == 0);
          Lext_ram_sc[d_addr].pre_sign = (Lext_ram[d_addr] <  0);
        end
        //
        outx[d_addr] = outx2[addr];
      end
`ifdef __LOG_DECODER_ITER_ENABLE__
      for (int i = 0; i < Nlength; i++) begin
        $fdisplay(fp, "iter %0d d1: %0d : inx = %5d -> Lext = %5d, outx = %5d ", iter, i, inx[i], Lext_ram[i], outx1[i]);
      end
`endif

    end
`ifdef __LOG_DECODER_ITER_ENABLE__
        $fclose(fp);
`endif

    //
    // take decision
    err = 0;
    for (int i = 0; i < $size(data_ram); i++) begin
      automatic bit hd;
      //
      hd         = (a00_LLR_ram[i] >= 0);
      //
      data_ram[i] = (outx[i] >= 0);
      //
      err += (data_ram[i] ^ hd);
    end
    //
    do_opt_decode = err;
  end
  endfunction


  //------------------------------------------------------------------------------------------------------
  // usefull functions
  //------------------------------------------------------------------------------------------------------

  // function to get parity bit
  //    b[2 : 0] LLR of bits
  //    t   - 3'b001.....3'b111 parity bit type
  function automatic pbit_llr_t get_parity_bit_LLR (int b2, b1, b0, t);
    int sum;
  begin
    sum = 0;
    //
    if (t[0]) sum += b0;
    if (t[1]) sum += b1;
    if (t[2]) sum += b2;
    //
    return sum;
  end
  endfunction

  //
  // function to count MMAX* function using different ways
  function automatic int mmax (int a, b);
    int tmp;
  begin
    if (pMMAX_TYPE == 3) begin
      mmax  = (a > b) ? a : b;
      tmp   = (a > b) ? (a-b) : (b-a);
      if (tmp <= (0.125*FP))
        mmax += 0.625*FP;
      else if (tmp <= (0.375*FP))
        mmax += 0.5*FP;
      else if (tmp <= (0.75*FP))
        mmax += 0.375*FP;
      else if (tmp <= (1.25*FP))
        mmax += 0.25*FP;
      else if (tmp <= (1.875*FP))
        mmax += 0.125*FP;
    end
    else if (pMMAX_TYPE == 2) begin
      mmax  = (a > b) ? a : b;
      tmp   = (a > b) ? (a-b) : (b-a);
      if (tmp <= (2*FP))
        mmax += 0.125*FP;
    end
    else if (pMMAX_TYPE == 1) begin
      mmax  = (a > b) ? a : b;
      tmp   = (a > b) ? (a-b) : (b-a);
      if (tmp <= (1.5*FP)) // 1.5  -> log(1 + exp(-1.5)) ~= 0.2 /1.25 -> log(1 + exp(-1.25)) ~=0.25
        mmax += 0.125*FP;   // 0.25
    end
    else begin
      mmax = (a > b) ? a : b;
    end
  end
  endfunction

  const int k_idx [int]    = '{1784 : 1, 3568 : 2, 7136 : 3, 8920 : 4};

  const int k1             = 8;
  const int k2_tab [1 : 4] = '{223, 223*2, 223*4, 223*5};
  const int p_tab  [1 : 8] = '{31, 37, 43, 47, 53, 59, 61, 67};

  // s == [0...pN-1] -> [0...pN-1]
  function int get_permutaded_addr_zero (input int s);
    int k2;
    //
    int m;
    int i;
    int j;
    int t;
    int q;
    int c;
    //
    int paddr;
  begin
    k2 = k2_tab[k_idx[pN]];
    //
    m = s % 2;
    i = s /(2*k2);
    j = s /2 - i*k2;
    //
    t = (19*i + 1) % (k1/2);
    q = t % 8 + 1;
    //
    c = (p_tab[q] * j + 21*m) % k2;
    //
    paddr = 2*(t + c*k1/2+1) - m - 1;
    //
    return paddr;
  end
  endfunction

  //
  // saturation function
  function automatic int Lext_saturate (int Le, level, real K = 1.0);
    int tmp;
  begin
    tmp = Le * K;
    if (tmp > level)
      return level;
    else if (tmp < -level)
      return -level;
    else
      return tmp;
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  // decoder step
  //------------------------------------------------------------------------------------------------------

  function automatic void decode_stage
  (
    ref trel_state_t  outd [pN+4][2],
    ref trel_state_t  ind  [pN+4][2],
    ref pbit_llr_t    inp  [pN+4][8]
  );

    trel_state_t  alpha [pN+1+4][16];
    trel_state_t  beta  [pN+1+4][16];

    trel_branch_t gamma  [16][2];
    trel_branch_t tmpLLR [2];

    bit [2 : 0] outb;
    bit [3 : 0] nstate;

    bit overflow;
    int fp;

    trel_state_t tmp [$];

    int Nlength;
  begin
    Nlength = $size(ind);

    // initialization of trellis : trellis start and ends in zero state
    for (int state = 0; state < 16; state++) begin
      alpha      [0][state] = (state == 0) ? 2**(pLLR_W-1) : 0;
      beta [Nlength][state] = (state == 0) ? 2**(pLLR_W-1) : 0;
    end

    // count backward recursion
    // beta(s, k) = sum(beta(s', k+1) * gamma(s, s'))
    for (int k = Nlength-1; k >= 0; k--) begin
      // beta(s', k+1) * gamma(s, s')
      for (int state = 0; state < 16; state++) begin
        for (int inb = 0; inb < 2; inb++) begin
          outb    = trel.outputs    [state][inb];
          nstate  = trel.nextStates [state][inb];
          // systematic + parity bit
          gamma[state][inb] = ind[k][inb] + inp[k][outb];
          // sink state
          gamma[state][inb] = gamma[state][inb] + beta[k+1][nstate];
        end
        //
        beta[k][state] = mmax(gamma[state][0], gamma[state][1]);
        //
        if (state == 0)
          overflow = (beta[k][state] >= cTREL_STATE_MAX);
        else
          overflow |= (beta[k][state] >= cTREL_STATE_MAX);
      end
      // normalize
      if (overflow) begin
        for (int state = 0; state < 16; state++) begin
          beta[k][state] -= cTREL_STATE_MAX;
        end
      end
    end
    //
    // count forward recursion & branch metric
    // alpha(s', k+1) = sum(alpha(s, k) * gamma(s, s'))
    // alpha(s, k) * gamma(s, s') * beta(s',k+1)
    for (int k = 0; k < Nlength; k++) begin
      // alpha(s, k) * gamma(s, s')
      for (int state = 0; state < 16; state++) begin
        for (int inb = 0; inb < 2; inb++) begin
          outb = trel.outputs[state][inb];
          // systematic + parity bits
          gamma[state][inb] = ind[k][inb] + inp[k][outb];
          // source state
          gamma[state][inb] = gamma[state][inb] + alpha[k][state];
        end
      end
      //
      // alpha(s', k+1) = sum(alpha(s, k) * gamma(s, s'))
      for (int nstate = 0; nstate < 16; nstate++) begin
        alpha[k+1][nstate] = mmax(gamma[trel.preStates[nstate][0]][0], gamma[trel.preStates[nstate][1]][1]);
        //
        //
        if (nstate == 0)
          overflow  = (alpha[k+1][nstate] >= cTREL_STATE_MAX);
        else
          overflow |= (alpha[k+1][nstate] >= cTREL_STATE_MAX);
      end
      // normalize
      if (overflow) begin
        for (int state = 0; state < 16; state++) begin
          alpha[k+1][state] -= cTREL_STATE_MAX;
        end
      end
      // alpha(s, k) * gamma(s, s') * beta(s',k+1)
      for (int state = 0; state < 16; state++) begin
        for (int inb = 0; inb < 2; inb++) begin
          nstate = trel.nextStates[state][inb];
          //
          gamma[state][inb] = gamma[state][inb] + beta[k+1][nstate];
        end
      end
      //
      // systematic LLR
      // sum(bm(s, bit_data))
      for (int inb = 0; inb < 2; inb++) begin
        tmpLLR[inb] = mmax (
                        mmax (
                          mmax (
                            mmax(gamma[0][inb], gamma[1][inb]),
                            mmax(gamma[2][inb], gamma[3][inb])
                            ),
                          mmax (
                            mmax(gamma[4][inb], gamma[5][inb]),
                            mmax(gamma[6][inb], gamma[7][inb])
                            )
                          ),
                        mmax (
                          mmax (
                            mmax(gamma[8] [inb], gamma[9] [inb]),
                            mmax(gamma[10][inb], gamma[11][inb])
                            ),
                          mmax (
                            mmax(gamma[12][inb], gamma[13][inb]),
                            mmax(gamma[14][inb], gamma[15][inb])
                            )
                          )
                        );
      end
      //
      outd[k][0] = 0;
      outd[k][1] = tmpLLR[1] - tmpLLR[0];
    end

`ifdef __LOG_DECODER_STAGE_ENABLE__
    fp = $fopen("stage.txt", "a");
    for (int i = Nlength; i >= 0; i--) begin
      for (int s = 15; s >= 0; s--) beta[i][s] = beta[i][s] - beta[i][0];
      tmp = beta[i].max();
      $fdisplay(fp, "beta %0d : %p max idx %p", i, beta[i], beta[i].find_index with (item == tmp[0]));
    end

    for (int i = 0; i <= Nlength; i++) begin
      for (int s = 15; s >= 0; s--) alpha[i][s] = alpha[i][s] - alpha[i][0];
      tmp = alpha[i].max();
      $fdisplay(fp, "alpha %0d : %p max idx %p", i, alpha[i], alpha[i].find_index with (item == tmp[0]));
    end

    for (int i = 0; i < Nlength; i++) begin
      $fdisplay(fp, "out %0d : %p", i, outd[i]);
    end
    $fclose(fp);
`endif
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  // decoder stage optimized for data
  //------------------------------------------------------------------------------------------------------

  int cnt;

  function automatic void decode_opt_stage
  (
    ref trel_state_t  outd [pN+4],
    ref trel_state_t  ind  [pN+4],
    ref pbit_llr_t    inp  [pN+4][8]
  );

    trel_state_t  alpha [pN+1+4][16];
    trel_state_t  beta  [pN+1+4][16];

    trel_branch_t gamma  [16][2];
    trel_branch_t tmpLLR [2];

    bit [2 : 0] outb;
    bit [3 : 0] nstate;

    bit overflow;
    int fp;

    trel_state_t tmp [$];

    trel_state_t  tbeta [16];

    int Nlength;
  begin
    Nlength = $size(ind);

    // initialization of trellis : trellis start and ends in zero state
    for (int state = 0; state < 16; state++) begin
      alpha      [0][state] = (state == 0) ? 2**(pLLR_W-1) : 0;
      beta [Nlength][state] = (state == 0) ? 2**(pLLR_W-1) : 0;
    end

    // count backward recursion
    // beta(s, k) = sum(beta(s', k+1) * gamma(s, s'))
    for (int k = Nlength-1; k >= 0; k--) begin
      // beta(s', k+1) * gamma(s, s')
      for (int state = 0; state < 16; state++) begin
        for (int inb = 0; inb < 2; inb++) begin
          outb    = trel.outputs    [state][inb];
          nstate  = trel.nextStates [state][inb];
          // systematic + parity bit
          if (inb == 0)
            gamma[state][inb] =          inp[k][outb];
          else
            gamma[state][inb] = ind[k] + inp[k][outb];
          // sink state
          gamma[state][inb] = gamma[state][inb] + beta[k+1][nstate];
        end
        //
        beta[k][state] = mmax(gamma[state][0], gamma[state][1]);
        //
        if (state == 0)
          overflow = (beta[k][state] >= cTREL_STATE_MAX);
        else
          overflow |= (beta[k][state] >= cTREL_STATE_MAX);
      end

//    if (k == 1780 || k == 1779) begin
//      for (int s = 15; s >= 0; s--) tbeta[s] = beta[k][s] - beta[k][0];
//      $display("%p %p \ngamma %p -> \nstate %p", ind[k], inp[k], gamma, tbeta);
//    end

      // normalize
      if (overflow) begin
        for (int state = 0; state < 16; state++) begin
          beta[k][state] -= cTREL_STATE_MAX;
        end
      end
    end
    //
    // count forward recursion & branch metric
    // alpha(s', k+1) = sum(alpha(s, k) * gamma(s, s'))
    // alpha(s, k) * gamma(s, s') * beta(s',k+1)
    for (int k = 0; k < Nlength; k++) begin
      // alpha(s, k) * gamma(s, s')
      for (int state = 0; state < 16; state++) begin
        for (int inb = 0; inb < 2; inb++) begin
          outb = trel.outputs[state][inb];
          // systematic + parity bits
          if (inb == 0)
            gamma[state][inb] =          inp[k][outb];
          else
            gamma[state][inb] = ind[k] + inp[k][outb];
          // source state
          gamma[state][inb] = gamma[state][inb] + alpha[k][state];
        end
      end
      //
      // alpha(s', k+1) = sum(alpha(s, k) * gamma(s, s'))
      for (int nstate = 0; nstate < 16; nstate++) begin
        alpha[k+1][nstate] = mmax(gamma[trel.preStates[nstate][0]][0], gamma[trel.preStates[nstate][1]][1]);
        //
        //
        if (nstate == 0)
          overflow  = (alpha[k+1][nstate] >= cTREL_STATE_MAX);
        else
          overflow |= (alpha[k+1][nstate] >= cTREL_STATE_MAX);
      end
      // normalize
      if (overflow) begin
        for (int state = 0; state < 16; state++) begin
          alpha[k+1][state] -= cTREL_STATE_MAX;
        end
      end
      // alpha(s, k) * gamma(s, s') * beta(s',k+1)
      for (int state = 0; state < 16; state++) begin
        for (int inb = 0; inb < 2; inb++) begin
          nstate = trel.nextStates[state][inb];
          //
          gamma[state][inb] = gamma[state][inb] + beta[k+1][nstate];
        end
      end
      //
      // systematic LLR
      // sum(bm(s, bit_data))
      for (int inb = 0; inb < 2; inb++) begin
        tmpLLR[inb] = mmax (
                        mmax (
                          mmax (
                            mmax(gamma[0][inb], gamma[1][inb]),
                            mmax(gamma[2][inb], gamma[3][inb])
                            ),
                          mmax (
                            mmax(gamma[4][inb], gamma[5][inb]),
                            mmax(gamma[6][inb], gamma[7][inb])
                            )
                          ),
                        mmax (
                          mmax (
                            mmax(gamma[8] [inb], gamma[9] [inb]),
                            mmax(gamma[10][inb], gamma[11][inb])
                            ),
                          mmax (
                            mmax(gamma[12][inb], gamma[13][inb]),
                            mmax(gamma[14][inb], gamma[15][inb])
                            )
                          )
                        );
      end
      //
      outd[k] = tmpLLR[1] - tmpLLR[0];
    end

`ifdef __LOG_DECODER_STAGE_ENABLE__
    fp = $fopen("stage.txt", "a");
    for (int i = Nlength; i >= 0; i--) begin
      for (int s = 15; s >= 0; s--) beta[i][s] = beta[i][s] - beta[i][0];
      tmp = beta[i].max();
      $fdisplay(fp, "beta %0d : %p max idx %p", i, beta[i], beta[i].find_index with (item == tmp[0]));
    end

    for (int i = 0; i <= Nlength; i++) begin
      for (int s = 15; s >= 0; s--) alpha[i][s] = alpha[i][s] - alpha[i][0];
      tmp = alpha[i].max();
      $fdisplay(fp, "alpha %0d : %p max idx %p", i, alpha[i], alpha[i].find_index with (item == tmp[0]));
    end

    for (int i = 0; i < Nlength; i++) begin
      $fdisplay(fp, "out %0d : %p", i, outd[i]);
    end
    $fclose(fp);
`endif
  end
  endfunction

endmodule

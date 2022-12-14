//
// Project       : ccsds turbo
// Author        : Shekhalev Denis (des00)
// Workfile      : ccsds_turbo_enc_beh.vh
// Description   : behaviour model of encoder with static configuration
//

`include "define.vh"

//`define __LOG_ENCODER_ENABLE__

module ccsds_turbo_enc_beh
#(
  parameter int pN    = 1784 ,  // maximum number of data duobit's <= 4096
  parameter int pCODE =    1    // 0/1/2/3 - 1/2, 1/3, 1/4, 1/6
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  isop    ,
  ieop    ,
  ival    ,
  idat    ,
  //
  obusy   ,
  ordy    ,
  //
  osop    ,
  oeop    ,
  oval    ,
  odat
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic iclk    ;
  input  logic ireset  ;
  input  logic iclkena ;
  //
  input  logic isop    ;
  input  logic ieop    ;
  input  logic ival    ;
  input  logic idat    ;
  //
  output logic obusy   ;
  output logic ordy    ;
  //
  output logic osop    ;
  output logic oeop    ;
  output logic oval    ;
  output logic odat    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  `include "ccsds_turbo_trellis.vh"

  typedef struct packed {
    logic         term;
    logic [3 : 0] a;
    logic [3 : 0] state;
  } encode_t;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  bit data_ram [];

  bit code00_ram [];
  bit code01_ram [];
  bit code02_ram [];
  bit code03_ram [];

  bit code11_ram [];
  bit code13_ram [];

  bit out_ram [];

  initial begin : main
    obusy <= 1'b0;
    ordy  <= 1'b0;
    //
    osop  <= 1'b0;
    oval  <= 1'b0;
    oeop  <= 1'b0;
    //
    @(posedge iclk iff !ireset);
    //
    data_ram    = new [pN];
    // add termination (!!!)
    code00_ram  = new [pN+4];
    code01_ram  = new [pN+4];
    code02_ram  = new [pN+4];
    code03_ram  = new [pN+4];
    code11_ram  = new [pN+4];
    code13_ram  = new [pN+4];
    // assemble data
    out_ram = new[6*(pN+4)];
    case (pCODE)
      0 : out_ram = new[2*(pN+4)];  // 1/2
      1 : out_ram = new[3*(pN+4)];  // 1/3
      2 : out_ram = new[4*(pN+4)];  // 1/4
      3 : out_ram = new[6*(pN+4)];  // 1/6
    endcase
    //
    obusy <= 1'b0;
    ordy  <= 1'b1;
    //
    forever begin
      int addr;
      //
      if (ival) begin
        if (isop) begin
          addr = 0;
        end
        //
        data_ram[addr++] = idat;
        //
        if (ieop) begin
          obusy <= 1'b1;
          ordy  <= 1'b0;
        end
      end
      //
      if (obusy) begin
        do_coding     ();
        //
        do_puncturing ();
        //
        for (int i = 0; i < $size(out_ram); i++) begin
          osop <= (i == 0);
          oval <= 1'b1;
          oeop <= (i == ($size(out_ram)-1));
          odat <= out_ram[i];
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
  // coding
  //------------------------------------------------------------------------------------------------------

  function automatic void do_coding ();
    bit         data2code0;
    bit         data2code1;

    bit [3 : 0] state0;
    bit [3 : 0] state1;

    encode_t    code0;
    encode_t    code1;

    int fp;
  begin
`ifdef __LOG_ENCODER_ENABLE__
    fp = $fopen("encoder.log", "w");
`endif
    state0 = 0;
    state1 = 0;
    // data phase
    for (int i = 0; i < pN; i++) begin
      data2code0 = data_ram[i];
      data2code1 = data_ram[get_permutaded_addr(i+1)-1];
      //
      code0 = do_encode(data2code0, state0);
      code1 = do_encode(data2code1, state1);
      //
      code00_ram[i] = code0.a[0];
      code01_ram[i] = code0.a[1];
      code02_ram[i] = code0.a[2];
      code03_ram[i] = code0.a[3];
      //
      code11_ram[i] = code1.a[1];
      code13_ram[i] = code1.a[3];
      //
`ifdef __LOG_ENCODER_ENABLE__
      $fdisplay(fp, "%0d :: (%0d & %0d) -> (%0d & %b_%b)\t\t\t (%0d & %0d) -> (%0d & %b)", i,
                state0, data2code0, code0.state, code0.a[0], code0.a[3 : 1],
                state1, data2code1, code1.state, code1.a[3 : 1] & 3'b101);
`endif
      //
      state0 = code0.state;
      state1 = code1.state;
    end
    $fdisplay(fp, "do termination");
    // termination phase
    for (int i = pN; i < pN + 4; i++) begin
      code0 = do_encode(code0.term, state0);
      code1 = do_encode(code1.term, state1);
      //
      code00_ram[i] = code0.a[0];
      code01_ram[i] = code0.a[1];
      code02_ram[i] = code0.a[2];
      code03_ram[i] = code0.a[3];
      //
      code11_ram[i] = code1.a[1];
      code13_ram[i] = code1.a[3];
`ifdef __LOG_ENCODER_ENABLE__
      $fdisplay(fp, "%0d :: (%0d & %0d) -> (%0d & %b_%b)\t\t\t (%0d & %0d) -> (%0d & %b)", i,
                state0, data2code0, code0.state, code0.a[0], code0.a[3 : 1],
                state1, data2code1, code1.state, code1.a[3 : 1] & 3'b101);
`endif
      //
      state0 = code0.state;
      state1 = code1.state;
    end
`ifdef __LOG_ENCODER_ENABLE__
    $fclose(fp);
`endif
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  // permutation
  //------------------------------------------------------------------------------------------------------

  const int k_idx [int]    = '{1784 : 1, 3568 : 2, 7136 : 3, 8920 : 4};

  const int k1             = 8;
  const int k2_tab [1 : 4] = '{223, 223*2, 223*4, 223*5};
  const int p_tab  [1 : 8] = '{31, 37, 43, 47, 53, 59, 61, 67};

  // s == [1...pN] -> [1...pN]
  function int get_permutaded_addr (input int s);
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
    m = (s-1) % 2;
    i = (s-1)/(2*k2);
    j = (s-1)/2 - i*k2;
    //
    t = (19*i + 1) % (k1/2);
    q = t % 8 + 1;
    //
    c = (p_tab[q] * j + 21*m) % k2;
    //
    paddr = 2*(t + c*k1/2+1) - m;
    //
    return paddr;
  end
  endfunction

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

  //------------------------------------------------------------------------------------------------------
  // puncture
  //------------------------------------------------------------------------------------------------------

  function void do_puncturing ();
  begin
    case (pCODE)
      0 : begin // 1/2
        for (int i = 0; i < $size(code00_ram); i++) begin
          out_ram[2*i+0] = code00_ram[i];
          if ((i % 2) == 0)
            out_ram[2*i+1] = code01_ram[i];
          else
            out_ram[2*i+1] = code11_ram[i];
        end
      end
      1 : begin // 1/3
        for (int i = 0; i < $size(code00_ram); i++) begin
          out_ram[3*i+0] = code00_ram[i];
          out_ram[3*i+1] = code01_ram[i];
          out_ram[3*i+2] = code11_ram[i];
        end
      end
      2 : begin // 1/4
        for (int i = 0; i < $size(code00_ram); i++) begin
          out_ram[4*i+0] = code00_ram[i];
          out_ram[4*i+1] = code02_ram[i];
          out_ram[4*i+2] = code03_ram[i];
          out_ram[4*i+3] = code11_ram[i];
        end
      end
      3 : begin // 1/6
        for (int i = 0; i < $size(code00_ram); i++) begin
          out_ram[6*i+0] = code00_ram[i];
          out_ram[6*i+1] = code01_ram[i];
          out_ram[6*i+2] = code02_ram[i];
          out_ram[6*i+3] = code03_ram[i];
          out_ram[6*i+4] = code11_ram[i];
          out_ram[6*i+5] = code13_ram[i];
        end
      end
    endcase
  end
  endfunction

endmodule

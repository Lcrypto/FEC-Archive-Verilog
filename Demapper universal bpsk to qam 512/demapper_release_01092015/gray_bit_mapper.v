/*






  logic         gray_bit_mapper__iclk     ;
  logic         gray_bit_mapper__ireset   ;
  logic         gray_bit_mapper__iclkena  ;
  logic         gray_bit_mapper__isop     ;
  logic         gray_bit_mapper__ival     ;
  logic         gray_bit_mapper__ieop     ;
  logic [3 : 0] gray_bit_mapper__iqam     ;
  logic [7 : 0] gray_bit_mapper__idat     ;
  logic         gray_bit_mapper__osop     ;
  logic         gray_bit_mapper__oval     ;
  logic         gray_bit_mapper__oeop     ;
  logic [3 : 0] gray_bit_mapper__oqam     ;
  logic [4 : 0] gray_bit_mapper__odat_re  ;
  logic [4 : 0] gray_bit_mapper__odat_im  ;



  gray_bit_mapper
  gray_bit_mapper
  (
    .iclk    ( gray_bit_mapper__iclk    ) ,
    .ireset  ( gray_bit_mapper__ireset  ) ,
    .iclkena ( gray_bit_mapper__iclkena ) ,
    .isop    ( gray_bit_mapper__isop    ) ,
    .ival    ( gray_bit_mapper__ival    ) ,
    .ieop    ( gray_bit_mapper__ieop    ) ,
    .iqam    ( gray_bit_mapper__iqam    ) ,
    .idat    ( gray_bit_mapper__idat    ) ,
    .osop    ( gray_bit_mapper__osop    ) ,
    .oval    ( gray_bit_mapper__oval    ) ,
    .oeop    ( gray_bit_mapper__oeop    ) ,
    .oqam    ( gray_bit_mapper__oqam    ) ,
    .odat_re ( gray_bit_mapper__odat_re ) ,
    .odat_im ( gray_bit_mapper__odat_im )
  );


  assign gray_bit_mapper__iclk    = '0 ;
  assign gray_bit_mapper__ireset  = '0 ;
  assign gray_bit_mapper__iclkena = '0 ;
  assign gray_bit_mapper__isop    = '0 ;
  assign gray_bit_mapper__ival    = '0 ;
  assign gray_bit_mapper__ieop    = '0 ;
  assign gray_bit_mapper__iqam    = '0 ;
  assign gray_bit_mapper__idat    = '0 ;



*/



module gray_bit_mapper
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  isop    ,
  ival    ,
  ieop    ,
  iqam    ,
  idat    ,
  //
  osop    ,
  oval    ,
  oeop    ,
  oqam    ,
  odat_re ,
  odat_im
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic         iclk     ;
  input  logic         ireset   ;
  input  logic         iclkena  ;
  //
  input  logic         isop     ;
  input  logic         ival     ;
  input  logic         ieop     ;
  input  logic [3 : 0] iqam     ;
  input  logic [9 : 0] idat     ;
  //
  output logic         osop     ;
  output logic         oval     ;
  output logic         oeop     ;
  output logic [3 : 0] oqam     ;
  output logic [4 : 0] odat_re  ;
  output logic [4 : 0] odat_im  ;

  //------------------------------------------------------------------------------------------------------
  // bit conversion tables for not square modulations
  //------------------------------------------------------------------------------------------------------

  localparam int cDAT_W = 5;

  //  8PSK mapper : a = cos(pi/8), b = cos(3*pi/8)
  //    000 (0) = -b - ai
  //    001 (1) = -a - bi
  //    011 (3) =  a - bi
  //    010 (2) =  b - ai
  //    110 (6) =  b + ai
  //    111 (7) =  a + bi
  //    101 (5) = -a + bi
  //    100 (4) = -b + ai

  localparam logic [3 : 0] cQAM8_TAB [0 : 7] = '{
    4'b00_01, // 0
    4'b01_00, // 1
    4'b00_10, // 2
    4'b01_11, // 3
    4'b11_01, // 4
    4'b10_00, // 5
    4'b11_10, // 6
    4'b10_11  // 7
  };

  localparam logic [5 : 0] cQAM32_TAB  [0 : 31]   = '{
    18, 10, 26, 34, 17, 9, 25, 33, 19, 11, 27, 35, 20, 12, 28, 36, 8, 2, 32, 42, 16, 1, 24, 41, 13, 3, 37, 43, 21, 4, 29, 44
  };

  localparam logic [7 : 0] cQAM128_TAB [0 : 127]  = '{
    39, 55, 38, 54, 87, 71, 86, 70, 40, 56, 41, 57, 88, 72, 89, 73, 151, 135, 150, 134, 103, 119, 102, 118, 152, 136, 153, 137, 104, 120, 105, 121, 36, 52, 37, 53, 84, 68, 85, 69, 35, 51, 34, 50, 83, 67, 82, 66, 148, 132, 149, 133, 100, 116, 101, 117, 147, 131, 146, 130, 99, 115, 98, 114, 23, 7, 22, 6, 8, 9, 43, 59, 24, 25, 42, 58, 91, 75, 90, 74, 167, 183, 166, 182, 184, 185, 155, 139, 168, 169, 154, 138, 107, 123, 106, 122, 20, 4, 21, 5, 3, 2, 32, 48, 19, 18, 33, 49, 80, 64, 81, 65, 164, 180, 165, 181, 179, 178, 144, 128, 163, 162, 145, 129, 96, 112, 97, 113
  };

  localparam logic [9 : 0] cQAM512_TAB [0 : 511] = '{default : '0};

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic         qam2_im,    qam2_re;
  logic         qam4_im,    qam4_re;

  logic [1 : 0] qam8_im,    qam8_re;
  logic [1 : 0] qam16_im,   qam16_re;

  logic [2 : 0] qam32_im,   qam32_re;
  logic [2 : 0] qam64_im,   qam64_re;

  logic [3 : 0] qam128_im,  qam128_re;
  logic [3 : 0] qam256_im,  qam256_re;

  logic [4 : 0] qam512_im,  qam512_re;
  logic [4 : 0] qam1024_im, qam1024_re;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  initial begin
    oval    <= '0;
    oqam    <= '0;
    odat_re <= '0;
    odat_im <= '0;
  end
  // synthesis translate_on
  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  // BPSK mapper
  //      0 = -1 - 1i
  //      1 =  1 + 1i
  assign  qam2_im               = idat[0];
  assign  qam2_re               = idat[0];

  // QPSK mapper
  //     00 = -1 - 1i
  //     01 = -1 + 1i
  //     10 =  1 - 1i
  //     11 =  1 + 1i
  assign  qam4_im               = idat[1];
  assign  qam4_re               = idat[0];

  assign {qam8_im,  qam8_re}    = cQAM8_TAB[idat[2:0]];

  assign  qam16_im              = gray2bin(idat[3:2], 2);
  assign  qam16_re              = gray2bin(idat[1:0], 2);

  assign {qam32_im, qam32_re}   = cQAM32_TAB[idat[4:0]];

  assign  qam64_im              = gray2bin(idat[5:3], 3);
  assign  qam64_re              = gray2bin(idat[2:0], 3);

  assign {qam128_im, qam128_re} = cQAM128_TAB[idat[6:0]];

  assign  qam256_im             = gray2bin(idat[7:4], 4);
  assign  qam256_re             = gray2bin(idat[3:0], 4);

  assign {qam512_im, qam512_re} = cQAM512_TAB[idat[8:0]];

  assign  qam1024_im            = gray2bin(idat[9:5], 5);
  assign  qam1024_re            = gray2bin(idat[4:0], 5);

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      osop <= isop;
      oeop <= ieop;
      oqam <= iqam;
      case (iqam)
        4'd1    : begin odat_re <= {4'h0, qam2_re};   odat_im <= {4'h0, qam2_im};   end
        4'd2    : begin odat_re <= {4'h0, qam4_re};   odat_im <= {4'h0, qam4_im};   end
        //
        4'd3    : begin odat_re <= {3'h0, qam8_re};   odat_im <= {3'h0, qam8_im};   end
        4'd4    : begin odat_re <= {3'h0, qam16_re};  odat_im <= {3'h0, qam16_im};  end
        //
        4'd5    : begin odat_re <= {2'h0, qam32_re};  odat_im <= {2'h0, qam32_im};  end
        4'd6    : begin odat_re <= {2'h0, qam64_re};  odat_im <= {2'h0, qam64_im};  end
        //
        4'd7    : begin odat_re <= {1'h0, qam128_re}; odat_im <= {1'h0, qam128_im}; end
        4'd8    : begin odat_re <= {1'h0, qam256_re}; odat_im <= {1'h0, qam256_im}; end
        //
        4'd9    : begin odat_re <= qam512_re;         odat_im <= qam512_im;         end
        4'd10   : begin odat_re <= qam1024_re;        odat_im <= qam1024_im;        end
        //
        default : begin odat_re <= {4'h0, qam4_re};   odat_im <= {4'h0, qam4_im};   end
      endcase
    end
  end

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= ival;
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  function automatic logic [cDAT_W-1 : 0] gray2bin (input logic [cDAT_W-1 : 0] gray, input int size);
    bit [cDAT_W-1 : 0] gray_mask;
    bit [cDAT_W-1 : 0] gray_masked;
  begin
    gray_mask   = {cDAT_W{1'b1}} >> (cDAT_W - size);
    gray_masked = gray & gray_mask;
    //
    gray2bin    = '0;
    for (int i = 0; i < cDAT_W; i++) begin
      gray2bin[i] = ^(gray_masked >> i);
    end
  end
  endfunction

endmodule

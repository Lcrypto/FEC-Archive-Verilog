
  typedef logic signed [8 : 0] dat_t;

  typedef dat_t rom_t [0 : 31]; // 1024 is max

  //
  // canstellation base point (least point in constellation)
  localparam int   cQPSK    = 64;
  localparam dat_t cQAM8_L  = 24;
  localparam dat_t cQAM8_M  = 58;
  localparam int   cQAM16   = 32;
  localparam int   cQAM32   = 16;
  localparam int   cQAM64   = 16;
  localparam int   cQAM128  = 8;
  localparam int   cQAM256  = 8;
  localparam int   cQAM512  = 4;
  localparam int   cQAM1024 = 4;

  //------------------------------------------------------------------------------------------------------
  // qam mapper points tables
  //------------------------------------------------------------------------------------------------------

  rom_t cQPSK_TAB   ;
  rom_t cQAM8_TAB   ;
  rom_t cQAM16_TAB  ;
  rom_t cQAM32_TAB  ;
  rom_t cQAM64_TAB  ;
  rom_t cQAM128_TAB ;
  rom_t cQAM256_TAB ;
  rom_t cQAM512_TAB ;
  rom_t cQAM1024_TAB;

  always_comb begin
    cQPSK_TAB     = gen_tab(1,     cQPSK);
    //
    cQAM8_TAB[0]  = -cQAM8_M;
    cQAM8_TAB[1]  = -cQAM8_L;
    cQAM8_TAB[2]  =  cQAM8_L;
    cQAM8_TAB[3]  =  cQAM8_M;
    //
    cQAM16_TAB    = gen_tab(3,    cQAM16);
    cQAM32_TAB    = gen_tab(5,    cQAM32);
    cQAM64_TAB    = gen_tab(7,    cQAM64);
    cQAM128_TAB   = gen_tab(11,  cQAM128);
    cQAM256_TAB   = gen_tab(15,  cQAM256);
    cQAM512_TAB   = gen_tab(23,  cQAM512);
    cQAM1024_TAB  = gen_tab(31, cQAM1024);
  end

  function automatic rom_t gen_tab (input int max_idx, input int level);
    int j;
  begin
    j = 0;
    for (int i = -max_idx; i <= max_idx; i += 2) begin
      gen_tab[j++] = i*level;
    end
  end
  endfunction


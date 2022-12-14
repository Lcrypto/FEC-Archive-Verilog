

module tb_demapper ;

  localparam int cDAT_W = 8;
  localparam int cLLR_W = 4;

  bit iclk;
  bit ireset;
  bit iclkena;

  logic               [3 : 0] data_symb_qam   ;
  logic                       data_symb_sop   ;
  logic                       data_symb_val   ;
  logic                       data_symb_eop   ;
  logic               [9 : 0] data_symb_dat   ;

  logic                       bit_mapper__osop    ;
  logic                       bit_mapper__oval    ;
  logic                       bit_mapper__oeop    ;
  logic               [4 : 0] bit_mapper__odat_re ;
  logic               [4 : 0] bit_mapper__odat_im ;
  logic               [3 : 0] bit_mapper__oqam    ;

  logic                       mapper__oval        ;
  logic signed        [7 : 0] mapper__odat_re     ;
  logic signed        [7 : 0] mapper__odat_im     ;

  logic                       demapper__oval      ;
  logic                       demapper__osop      ;
  logic               [3 : 0] demapper__oqam      ;
  logic signed [cLLR_W-1 : 0] demapper__oLLR [10] ;

  //------------------------------------------------------------------------------------------------------
  // bit mapper
  //------------------------------------------------------------------------------------------------------

  gray_bit_mapper
  bit_mapper
  (
    .iclk    ( iclk            ) ,
    .ireset  ( ireset          ) ,
    .iclkena ( iclkena         ) ,
    //
    .isop    ( data_symb_sop   ) ,
    .ival    ( data_symb_val   ) ,
    .ieop    ( data_symb_eop   ) ,
    .iqam    ( data_symb_qam   ) ,
    .idat    ( data_symb_dat   ) ,
    //
    .osop    ( bit_mapper__osop    ) ,
    .oval    ( bit_mapper__oval    ) ,
    .oeop    ( bit_mapper__oeop    ) ,
    .oqam    ( bit_mapper__oqam    ) ,
    .odat_re ( bit_mapper__odat_re ) ,
    .odat_im ( bit_mapper__odat_im )
  );

  //------------------------------------------------------------------------------------------------------
  // mapper
  //------------------------------------------------------------------------------------------------------

  logic         mapper__osop;
  logic [3 : 0] mapper__oqam;

  mapper
  mapper
  (
    .iclk    ( iclk                ) ,
    .ireset  ( ireset              ) ,
    .iclkena ( iclkena             ) ,
    //
    .ival    ( bit_mapper__oval    ) ,
    .iqam    ( bit_mapper__oqam    ) ,
    .idat_re ( bit_mapper__odat_re ) ,
    .idat_im ( bit_mapper__odat_im ) ,
    //
    .oval    ( mapper__oval        ) ,
    .odat_re ( mapper__odat_re     ) ,
    .odat_im ( mapper__odat_im     )
  );

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      mapper__osop <= bit_mapper__osop;
      mapper__oqam <= bit_mapper__oqam;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // LLR
  //------------------------------------------------------------------------------------------------------

  demapper
  #(
    .pDAT_W ( cDAT_W ) ,
    .pLLR_W ( cLLR_W )
  )
  demapper
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    //
    .ival    ( mapper__oval    ) ,
    .isop    ( mapper__osop    ) ,
    .iqam    ( mapper__oqam    ) ,
    .idat_re ( mapper__odat_re ) ,
    .idat_im ( mapper__odat_im ) ,
    //
    .oval    ( demapper__oval  ) ,
    .osop    ( demapper__osop  ) ,
    .oqam    ( demapper__oqam  ) ,
    .oLLR    ( demapper__oLLR  )
  );

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  initial begin
    iclk <= 1'b0;
    #5ns forever #5ns iclk = ~iclk;
  end

  assign ireset = 1'b0;
  assign iclkena = 1'b1;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  initial begin : main
    int tqam;

    data_symb_qam <= '0;
    data_symb_sop <= '0;
    data_symb_val <= '0;
    data_symb_eop <= '0;
    data_symb_dat <= '0;
    //
    repeat (20) @(posedge iclk);
    //
    for (tqam = 1; tqam <= 10; tqam++) begin
      if (tqam == 9) continue;
      data_symb_qam <= tqam;
      for (int i = 0; i < 2**tqam; i++) begin
        set_data((i == 0), 0, i);
      end
//    repeat (20) @(posedge iclk);
    end

    repeat (20) @(posedge iclk);
    $stop;
  end

  initial begin : check_data
    int tdat, tsop, tqam;
    int tmp, mask;
    //
    forever begin
      get_data(tdat, tsop, tqam);
      //
      if (tsop) begin
        $display("%0t get qam%0d frame", $time, tqam);
      end
      tmp = tsop ? 0 : tmp+1;
      //
      mask = (1'b1 << tqam) - 1;
      tdat &= mask;
      assert (tdat == tmp) else begin
        $display("compare error %0h != %0h at qam = %0d", tmp, tdat, tqam);
      end
      //
    end
  end


  task set_data (input sop, eop, int dat, int delay = 0);
    data_symb_sop <= sop;
    data_symb_eop <= eop;
    data_symb_val <= 1'b1;
    data_symb_dat <= dat;
    @(posedge iclk);
    data_symb_sop <= 1'b0;
    data_symb_eop <= 1'b0;
    data_symb_val <= 1'b0;
    data_symb_dat <= dat;
    repeat (delay) @(posedge iclk);
  endtask

  task get_data (output int dat, sop, qam) ;
    @(posedge iclk iff demapper__oval);
    dat = 0;
    for (int i = 0; i < 10; i++) begin
      dat[i] = (demapper__oLLR[i] >= 0);
    end
    qam = demapper__oqam;
    sop = demapper__osop;
  endtask

endmodule

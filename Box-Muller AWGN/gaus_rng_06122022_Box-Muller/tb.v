

module tb_rng ;

  parameter int pSEED0   =  0;//656790 ;
  parameter int pSEED1   =  0;
  parameter int pSEED2   =  0;
  parameter int pDAT_W   =  16 ;
  parameter int pGAIN_W  =  16 ;



  logic                 iclk     ;
  logic                 ireset   ;
  logic                 iclkena  ;
  logic                 ienable  ;
  logic [pGAIN_W-1 : 0] igain    ;
  logic                 oval     ;
  logic  [pDAT_W-1 : 0] odat_re  ;
  logic  [pDAT_W-1 : 0] odat_im  ;

  gaus_rng
  #(
    .pSEED0  ( pSEED0  ) ,
    .pSEED1  ( pSEED1  ) ,
    .pSEED2  ( pSEED2  ) ,
    .pDAT_W  ( pDAT_W  ) ,
    .pGAIN_W ( pGAIN_W )
  )
  gaus_rng
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    .ienable ( ienable ) ,
    .igain   ( igain   ) ,
    .oval    ( oval    ) ,
    .odat_re ( odat_re ) ,
    .odat_im ( odat_im )
  );


  initial begin
    iclk <= 1'b0;
    forever begin
      #5ns iclk = #5ns ~iclk;
    end
  end

  assign iclkena = 1'b1;

  initial begin
    ienable <= 0;
    #1us;
    @(posedge iclk);
    ienable <= 1'b1;
  end

  assign igain = 65535;

endmodule

/*



  parameter int pADDR_W  = 256 ;
  parameter int pDAT_W   =   8 ;
  parameter bit pPIPE    =   0 ;



  logic                 polar_mem_ablock__ireset   ;
  logic                 polar_mem_ablock__iwclk    ;
  logic                 polar_mem_ablock__iwclkena ;
  logic                 polar_mem_ablock__iwrite   ;
  logic [pADDR_W-1 : 0] polar_mem_ablock__iwaddr   ;
  logic  [pDAT_W-1 : 0] polar_mem_ablock__iwdat    ;
  logic                 polar_mem_ablock__irclk    ;
  logic                 polar_mem_ablock__irclkena ;
  logic [pADDR_W-1 : 0] polar_mem_ablock__iraddr   ;
  logic  [pDAT_W-1 : 0] polar_mem_ablock__ordat    ;



  polar_mem_ablock
  #(
    .pADDR_W ( pADDR_W ) ,
    .pDAT_W  ( pDAT_W  ) ,
    .pPIPE   ( pPIPE   )
  )
  polar_mem_ablock
  (
    .ireset   ( polar_mem_ablock__ireset   ) ,
    .iwclk    ( polar_mem_ablock__iwclk    ) ,
    .iwclkena ( polar_mem_ablock__iwclkena ) ,
    .iwrite   ( polar_mem_ablock__iwrite   ) ,
    .iwaddr   ( polar_mem_ablock__iwaddr   ) ,
    .iwdat    ( polar_mem_ablock__iwdat    ) ,
    .irclk    ( polar_mem_ablock__irclk    ) ,
    .irclkena ( polar_mem_ablock__irclkena ) ,
    .iraddr   ( polar_mem_ablock__iraddr   ) ,
    .ordat    ( polar_mem_ablock__ordat    )
  );


  assign polar_mem_ablock__ireset   = '0 ;
  assign polar_mem_ablock__iwclk    = '0 ;
  assign polar_mem_ablock__iwclkena = '0 ;
  assign polar_mem_ablock__iwrite   = '0 ;
  assign polar_mem_ablock__iwaddr   = '0 ;
  assign polar_mem_ablock__iwdat    = '0 ;
  assign polar_mem_ablock__irclk    = '0 ;
  assign polar_mem_ablock__irclkena = '0 ;
  assign polar_mem_ablock__iraddr   = '0 ;



*/

//
// Project       : polar code
// Author        : Shekhalev Denis (des00)
// Workfile      : polar_mem_ablock.v
// Description   : Simple dual clock (asynchronus) dual port ram with pipeline register
//


module polar_mem_ablock
#(
  parameter int pADDR_W = 256 ,
  parameter int pDAT_W  =   8 ,
  parameter bit pPIPE   =   0
)
(
  ireset    ,
  //
  iwclk     ,
  iwclkena  ,
  iwrite    ,
  iwaddr    ,
  iwdat     ,
  //
  irclk     ,
  irclkena  ,
  iraddr    ,
  ordat
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 ireset   ;
  //
  input  logic                 iwclk    ;
  input  logic                 iwclkena ;
  input  logic                 iwrite   ;
  input  logic [pADDR_W-1 : 0] iwaddr   ;
  input  logic  [pDAT_W-1 : 0] iwdat    ;
  //
  input  logic                 irclk    ;
  input  logic                 irclkena ;
  input  logic [pADDR_W-1 : 0] iraddr   ;
  output logic  [pDAT_W-1 : 0] ordat    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  bit   [pDAT_W-1 : 0] mem  [2**pADDR_W] /* synthesis ramstyle = "no_rw_check" */;
  logic [pDAT_W-1 : 0] rdat [2];

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge irclk) begin
    if (irclkena) begin
      rdat[0] <= mem[iraddr];
      rdat[1] <= rdat[0];
    end
  end

  assign ordat = rdat[pPIPE];

  always_ff @(posedge iwclk) begin
    if (iwclkena) begin
      if (iwrite)
        mem[iwaddr] <= iwdat;
    end
  end

endmodule

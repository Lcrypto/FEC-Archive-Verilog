/*



  parameter int pADDR_W  = 256 ;
  parameter int pDAT_W   =   8 ;
  parameter bit pPIPE    =   0 ;


  logic                 polar_mem_block__iclk     ;
  logic                 polar_mem_block__ireset   ;
  logic                 polar_mem_block__iclkena  ;
  logic                 polar_mem_block__iwrite   ;
  logic [pADDR_W-1 : 0] polar_mem_block__iwaddr   ;
  logic  [pDAT_W-1 : 0] polar_mem_block__iwdat    ;
  logic [pADDR_W-1 : 0] polar_mem_block__iraddr   ;
  logic  [pDAT_W-1 : 0] polar_mem_block__ordat    ;



  polar_mem_block
  #(
    .pADDR_W ( pADDR_W ) ,
    .pDAT_W  ( pDAT_W  ) ,
    .pPIPE   ( pPIPE   )
  )
  polar_mem_block
  (
    .iclk    ( polar_mem_block__iclk    ) ,
    .ireset  ( polar_mem_block__ireset  ) ,
    .iclkena ( polar_mem_block__iclkena ) ,
    .iwrite  ( polar_mem_block__iwrite  ) ,
    .iwaddr  ( polar_mem_block__iwaddr  ) ,
    .iwdat   ( polar_mem_block__iwdat   ) ,
    .iraddr  ( polar_mem_block__iraddr  ) ,
    .ordat   ( polar_mem_block__ordat   )
  );


  assign polar_mem_block__iclk    = '0 ;
  assign polar_mem_block__ireset  = '0 ;
  assign polar_mem_block__iclkena = '0 ;
  assign polar_mem_block__iwrite  = '0 ;
  assign polar_mem_block__iwaddr  = '0 ;
  assign polar_mem_block__iwdat   = '0 ;
  assign polar_mem_block__iraddr  = '0 ;



*/

//
// Project       : polar code
// Author        : Shekhalev Denis (des00)
// Workfile      : polar_mem_block.v
// Description   : Simple dual port ram with pipeline register
//


module polar_mem_block
#(
  parameter int pADDR_W = 256 ,
  parameter int pDAT_W  =   8 ,
  parameter bit pPIPE   =   0
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  iwrite  ,
  iwaddr  ,
  iwdat   ,
  iraddr  ,
  ordat
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 iclk     ;
  input  logic                 ireset   ;
  input  logic                 iclkena  ;
  input  logic                 iwrite   ;
  input  logic [pADDR_W-1 : 0] iwaddr   ;
  input  logic  [pDAT_W-1 : 0] iwdat    ;
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

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      rdat[0]  <= mem[iraddr];
      rdat[1]  <= rdat[0];
      //
      if (iwrite)
        mem[iwaddr] <= iwdat;
    end
  end

  assign ordat = rdat[pPIPE];

endmodule

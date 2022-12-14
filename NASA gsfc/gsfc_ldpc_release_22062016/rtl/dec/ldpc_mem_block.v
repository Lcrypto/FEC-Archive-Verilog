/*



  parameter int pADDR_W  = 256 ;
  parameter int pDAT_W   =   8 ;



  logic                 ldpc_mem_block__iclk     ;
  logic                 ldpc_mem_block__ireset   ;
  logic                 ldpc_mem_block__iclkena  ;
  logic                 ldpc_mem_block__iwrite   ;
  logic [pADDR_W-1 : 0] ldpc_mem_block__iwaddr   ;
  logic  [pDAT_W-1 : 0] ldpc_mem_block__iwdat    ;
  logic [pADDR_W-1 : 0] ldpc_mem_block__iraddr   ;
  logic  [pDAT_W-1 : 0] ldpc_mem_block__ordat    ;



  ldpc_mem_block
  #(
    .pADDR_W ( pADDR_W ) ,
    .pDAT_W  ( pDAT_W  )
  )
  ldpc_mem_block
  (
    .iclk    ( ldpc_mem_block__iclk    ) ,
    .ireset  ( ldpc_mem_block__ireset  ) ,
    .iclkena ( ldpc_mem_block__iclkena ) ,
    .iwrite  ( ldpc_mem_block__iwrite  ) ,
    .iwaddr  ( ldpc_mem_block__iwaddr  ) ,
    .iwdat   ( ldpc_mem_block__iwdat   ) ,
    .iraddr  ( ldpc_mem_block__iraddr  ) ,
    .ordat   ( ldpc_mem_block__ordat   )
  );


  assign ldpc_mem_block__iclk    = '0 ;
  assign ldpc_mem_block__ireset  = '0 ;
  assign ldpc_mem_block__iclkena = '0 ;
  assign ldpc_mem_block__iwrite  = '0 ;
  assign ldpc_mem_block__iwaddr  = '0 ;
  assign ldpc_mem_block__iwdat   = '0 ;
  assign ldpc_mem_block__iraddr  = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_mem_block.v
// Description   : Simple dual port ram with pipeline register
//


module ldpc_mem_block
#(
  parameter int pADDR_W = 256 ,
  parameter int pDAT_W  =   8
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

  bit   [pDAT_W-1 : 0] mem [2**pADDR_W] /* synthesis ramstyle = "no_rw_check" */;
  logic [pDAT_W-1 : 0] rdat;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      rdat  <= mem[iraddr];
      ordat <= rdat;
      //
      if (iwrite)
        mem[iwaddr] <= iwdat;
    end
  end

endmodule

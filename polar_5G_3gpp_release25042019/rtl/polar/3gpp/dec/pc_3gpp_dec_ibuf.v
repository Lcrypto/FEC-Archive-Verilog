/*



  parameter int pWADDR_W  = 8 ;
  parameter int pRADDR_W  = 8 ;
  parameter int pLLR_W    = 4 ;
  parameter int pWORD_W   = 8 ;
  parameter int pTAG_W    = 4 ;
  parameter int pBNUM_W   = 2 ;



  logic                  pc_3gpp_dec_ibuf__iclk               ;
  logic                  pc_3gpp_dec_ibuf__ireset             ;
  logic                  pc_3gpp_dec_ibuf__iclkena            ;
  logic                  pc_3gpp_dec_ibuf__iwrite             ;
  logic                  pc_3gpp_dec_ibuf__iwfull             ;
  logic [pWADDR_W-1 : 0] pc_3gpp_dec_ibuf__iwLLR_addr         ;
  logic [pWADDR_W-1 : 0] pc_3gpp_dec_ibuf__iwLLR_frzb_addr    ;
  logic [pWADDR_W-1 : 0] pc_3gpp_dec_ibuf__ifrzb_addr         ;
  logic  [ pLLR_W-1 : 0] pc_3gpp_dec_ibuf__iwLLR              ;
  logic                  pc_3gpp_dec_ibuf__iwfrzb             ;
  logic   [pTAG_W-1 : 0] pc_3gpp_dec_ibuf__iwtag              ;
  logic                  pc_3gpp_dec_ibuf__irempty            ;
  logic [pRADDR_W-1 : 0] pc_3gpp_dec_ibuf__irLLR_addr         ;
  logic [pRADDR_W-1 : 0] pc_3gpp_dec_ibuf__irfrzb_addr        ;
  logic   [pLLR_W-1 : 0] pc_3gpp_dec_ibuf__orLLR    [pWORD_W] ;
  logic  [pWORD_W-1 : 0] pc_3gpp_dec_ibuf__orLLR_frzb         ;
  logic  [pWORD_W-1 : 0] pc_3gpp_dec_ibuf__orfrzb             ;
  logic   [pTAG_W-1 : 0] pc_3gpp_dec_ibuf__ortag              ;
  logic                  pc_3gpp_dec_ibuf__oempty             ;
  logic                  pc_3gpp_dec_ibuf__oemptya            ;
  logic                  pc_3gpp_dec_ibuf__ofull              ;
  logic                  pc_3gpp_dec_ibuf__ofulla             ;



  pc_3gpp_dec_ibuf
  #(
    .pWADDR_W ( pWADDR_W ) ,
    .pRADDR_W ( pRADDR_W ) ,
    .pLLR_W   ( pLLR_W   ) ,
    .pWORD_W  ( pWORD_W  ) ,
    .pTAG_W   ( pTAG_W   ) ,
    .pBNUM_W  ( pBNUM_W  )
  )
  pc_3gpp_dec_ibuf
  (
    .iclk            ( pc_3gpp_dec_ibuf__iclk            ) ,
    .ireset          ( pc_3gpp_dec_ibuf__ireset          ) ,
    .iclkena         ( pc_3gpp_dec_ibuf__iclkena         ) ,
    .iwrite          ( pc_3gpp_dec_ibuf__iwrite          ) ,
    .iwfull          ( pc_3gpp_dec_ibuf__iwfull          ) ,
    .iwLLR_addr      ( pc_3gpp_dec_ibuf__iwLLR_addr      ) ,
    .iwLLR_frzb_addr ( pc_3gpp_dec_ibuf__iwLLR_frzb_addr ) ,
    .iwfrzb_addr     ( pc_3gpp_dec_ibuf__iwfrzb_addr     ) ,
    .iwLLR           ( pc_3gpp_dec_ibuf__iwLLR           ) ,
    .iwfrzb          ( pc_3gpp_dec_ibuf__iwfrzb          ) ,
    .iwtag           ( pc_3gpp_dec_ibuf__iwtag           ) ,
    .irempty         ( pc_3gpp_dec_ibuf__irempty         ) ,
    .irLLR_addr      ( pc_3gpp_dec_ibuf__irLLR_addr      ) ,
    .irfrzb_addr     ( pc_3gpp_dec_ibuf__irfrzb_addr     ) ,
    .orLLR           ( pc_3gpp_dec_ibuf__orLLR           ) ,
    .orLLR_frzb      ( pc_3gpp_dec_ibuf__orLLR_frzb      ) ,
    .orfrzb          ( pc_3gpp_dec_ibuf__orfrzb          ) ,
    .ortag           ( pc_3gpp_dec_ibuf__ortag           ) ,
    .oempty          ( pc_3gpp_dec_ibuf__oempty          ) ,
    .oemptya         ( pc_3gpp_dec_ibuf__oemptya         ) ,
    .ofull           ( pc_3gpp_dec_ibuf__ofull           ) ,
    .ofulla          ( pc_3gpp_dec_ibuf__ofulla          )
  );


  assign pc_3gpp_dec_ibuf__iclk             = '0 ;
  assign pc_3gpp_dec_ibuf__ireset           = '0 ;
  assign pc_3gpp_dec_ibuf__iclkena          = '0 ;
  assign pc_3gpp_dec_ibuf__iwrite           = '0 ;
  assign pc_3gpp_dec_ibuf__iwfull           = '0 ;
  assign pc_3gpp_dec_ibuf__iwLLR_addr       = '0 ;
  assign pc_3gpp_dec_ibuf__iwLLR_frzb_addr  = '0 ;
  assign pc_3gpp_dec_ibuf__iwfrzb_addr      = '0 ;
  assign pc_3gpp_dec_ibuf__iwLLR            = '0 ;
  assign pc_3gpp_dec_ibuf__iwfrzb           = '0 ;
  assign pc_3gpp_dec_ibuf__iwtag            = '0 ;
  assign pc_3gpp_dec_ibuf__irempty          = '0 ;
  assign pc_3gpp_dec_ibuf__irLLR_addr       = '0 ;
  assign pc_3gpp_dec_ibuf__irfrzb_addr      = '0 ;



*/

//
// Project       : polar code 3gpp
// Author        : Shekhalev Denis (des00)
// Workfile      : pc_3gpp_dec_ibuf.v
// Description   : Polar decoder input nD buffer for channel LLR, channel frozen bits for reencode and frozen bits for decoding
//                 The buffer has manual DWC at writing
//

module pc_3gpp_dec_ibuf
#(
  parameter int pWADDR_W  = 8 ,
  parameter int pRADDR_W  = 4 ,
  parameter int pLLR_W    = 4 ,
  parameter int pWORD_W   = 8 , // engine word width
  parameter int pTAG_W    = 4 ,
  parameter int pBNUM_W   = 2
)
(
  iclk            ,
  ireset          ,
  iclkena         ,
  //
  iwrite          ,
  iwfull          ,
  iwLLR_addr      ,
  iwLLR_frzb_addr ,
  iwfrzb_addr     ,
  iwLLR           ,
  iwfrzb          ,
  iwtag           ,
  //
  irempty         ,
  irLLR_addr      ,
  irfrzb_addr     ,
  orLLR           ,
  orLLR_frzb      ,
  orfrzb          ,
  ortag           ,
  //
  oempty          ,
  oemptya         ,
  ofull           ,
  ofulla
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                  iclk                      ;
  input  logic                  ireset                    ;
  input  logic                  iclkena                   ;
  //
  input  logic                  iwrite                    ;
  input  logic                  iwfull                    ;
  input  logic [pWADDR_W-1 : 0] iwLLR_addr                ;
  input  logic [pWADDR_W-1 : 0] iwLLR_frzb_addr           ;
  input  logic [pWADDR_W-1 : 0] iwfrzb_addr               ;
  input  logic   [pLLR_W-1 : 0] iwLLR                     ;
  input  logic                  iwfrzb                    ;
  input  logic   [pTAG_W-1 : 0] iwtag                     ;
  //
  input  logic                  irempty                   ;
  input  logic [pRADDR_W-1 : 0] irLLR_addr                ;
  input  logic [pRADDR_W-1 : 0] irfrzb_addr               ;
  output logic   [pLLR_W-1 : 0] orLLR           [pWORD_W] ;
  output logic  [pWORD_W-1 : 0] orLLR_frzb                ;
  output logic  [pWORD_W-1 : 0] orfrzb                    ;
  output logic   [pTAG_W-1 : 0] ortag                     ;
  //
  output logic                  oempty                    ;
  output logic                  oemptya                   ;
  output logic                  ofull                     ;
  output logic                  ofulla                    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cRAM_WADDR_W = pWADDR_W + pBNUM_W;
  localparam int cRAM_RADDR_W = pRADDR_W + pBNUM_W;

  localparam int cRAMB_N      = pWORD_W;

  localparam int cLSB_W       = cRAM_WADDR_W - cRAM_RADDR_W;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [pBNUM_W-1 : 0] b_wused ; // bank write used
  logic [pBNUM_W-1 : 0] b_rused ; // bank read used

  logic [cRAM_WADDR_W-1 : 0] ram_LLR_waddr;
  logic [cRAM_WADDR_W-1 : 0] ram_LLR_frzb_waddr;
  logic [cRAM_WADDR_W-1 : 0] ram_frzb_waddr;

  logic [cRAM_RADDR_W-1 : 0] ram_LLR_raddr;
  logic [cRAM_RADDR_W-1 : 0] ram_frzb_raddr;

  logic                      mem_LLR__iwrite       [cRAMB_N] ;
  logic [cRAM_RADDR_W-1 : 0] mem_LLR__iwaddr                 ;
  logic       [pLLR_W-1 : 0] mem_LLR__iwdat                  ;
  logic [cRAM_RADDR_W-1 : 0] mem_LLR__iraddr                 ;
  logic       [pLLR_W-1 : 0] mem_LLR__ordat        [cRAMB_N] ;

  logic                      mem_LLR_frzb__iwrite  [cRAMB_N] ;
  logic [cRAM_RADDR_W-1 : 0] mem_LLR_frzb__iwaddr            ;
  logic                      mem_LLR_frzb__iwdat             ;
  logic [cRAM_RADDR_W-1 : 0] mem_LLR_frzb__iraddr            ;
  logic                      mem_LLR_frzb__ordat   [cRAMB_N] ;

  logic                      mem_frzb__iwrite      [cRAMB_N] ;
  logic [cRAM_RADDR_W-1 : 0] mem_frzb__iwaddr                ;
  logic                      mem_frzb__iwdat                 ;
  logic [cRAM_RADDR_W-1 : 0] mem_frzb__iraddr                ;
  logic                      mem_frzb__ordat       [cRAMB_N] ;

  //------------------------------------------------------------------------------------------------------
  // buffer logic
  //------------------------------------------------------------------------------------------------------

  polar_buffer_nD_slogic
  #(
    .pBNUM_W ( pBNUM_W )
  )
  nD_slogic
  (
    .iclk     ( iclk    ) ,
    .ireset   ( ireset  ) ,
    .iclkena  ( iclkena ) ,
    //
    .iwfull   ( iwfull  ) ,
    .ob_wused ( b_wused ) ,
    .irempty  ( irempty ) ,
    .ob_rused ( b_rused ) ,
    //
    .oempty   ( oempty  ) ,
    .oemptya  ( oemptya ) ,
    .ofull    ( ofull   ) ,
    .ofulla   ( ofulla  )
  );

  assign ram_LLR_waddr      = {b_wused, iwLLR_addr};
  assign ram_LLR_frzb_waddr = {b_wused, iwLLR_frzb_addr};
  assign ram_frzb_waddr     = {b_wused, iwfrzb_addr};

  assign ram_LLR_raddr      = {b_rused, irLLR_addr};
  assign ram_frzb_raddr     = {b_rused, irfrzb_addr};

  //------------------------------------------------------------------------------------------------------
  // data/frozen bit ram
  //------------------------------------------------------------------------------------------------------
`ifdef __USE_ALTERA_MACRO__
  altsyncram
  #(
    .address_aclr_b                     ( "NONE"          ) ,
    .address_reg_b                      ( "CLOCK0"        ) ,
    //
    .lpm_type                           ( "altsyncram"    ) ,
    //
    .numwords_a                         ( 2**cRAM_WADDR_W ) ,
    .numwords_b                         ( 2**cRAM_RADDR_W ) ,
    //
    .operation_mode                     ( "DUAL_PORT"     ) ,
    .outdata_aclr_b                     ( "NONE"          ) ,
    .outdata_reg_b                      ( "UNREGISTERED"  ) ,
    .power_up_uninitialized             ( "FALSE"         ) ,
    .read_during_write_mode_mixed_ports ( "DONT_CARE"     ) ,
    //
    .widthad_a                          ( cRAM_WADDR_W    ) ,
    .widthad_b                          ( cRAM_RADDR_W    ) ,
    //
    .width_a                            ( 1               ) ,
    .width_b                            ( cRAMB_N         ) ,
    //
    .width_byteena_a                    ( 1               )
  )
  ram_LLR_frzb
  (
    .address_a      ( ram_LLR_frzb_waddr ),
    .address_b      ( ram_LLR_raddr      ),
    .clock0         ( iclk               ),
    .data_a         ( iwfrzb             ),
    .wren_a         ( iwrite             ),
    .q_b            ( orLLR_frzb         ),
    //
    .aclr0          ( 1'b0               ),
    .aclr1          ( 1'b0               ),
    .addressstall_a ( 1'b0               ),
    .addressstall_b ( 1'b0               ),
    .byteena_a      ( 1'b1               ),
    .byteena_b      ( 1'b1               ),
    .clock1         ( 1'b1               ),
    .clocken0       ( iclkena            ),
    .clocken1       ( 1'b1               ),
    .clocken2       ( 1'b1               ),
    .clocken3       ( 1'b1               ),
    .data_b         ( {cRAMB_N{1'b1}}    ),
    .eccstatus      (                    ),
    .q_a            (                    ),
    .rden_a         ( 1'b1               ),
    .rden_b         ( 1'b1               ),
    .wren_b         ( 1'b0               )
  );

  altsyncram
  #(
    .address_aclr_b                     ( "NONE"          ) ,
    .address_reg_b                      ( "CLOCK0"        ) ,
    //
    .lpm_type                           ( "altsyncram"    ) ,
    //
    .numwords_a                         ( 2**cRAM_WADDR_W ) ,
    .numwords_b                         ( 2**cRAM_RADDR_W ) ,
    //
    .operation_mode                     ( "DUAL_PORT"     ) ,
    .outdata_aclr_b                     ( "NONE"          ) ,
    .outdata_reg_b                      ( "UNREGISTERED"  ) ,
    .power_up_uninitialized             ( "FALSE"         ) ,
    .read_during_write_mode_mixed_ports ( "DONT_CARE"     ) ,
    //
    .widthad_a                          ( cRAM_WADDR_W    ) ,
    .widthad_b                          ( cRAM_RADDR_W    ) ,
    //
    .width_a                            ( 1               ) ,
    .width_b                            ( cRAMB_N         ) ,
    //
    .width_byteena_a                    ( 1               )
  )
  ram_frzb
  (
    .address_a      ( ram_frzb_waddr  ),
    .address_b      ( ram_frzb_raddr  ),
    .clock0         ( iclk            ),
    .data_a         ( iwfrzb          ),
    .wren_a         ( iwrite          ),
    .q_b            ( orfrzb          ),
    //
    .aclr0          ( 1'b0            ),
    .aclr1          ( 1'b0            ),
    .addressstall_a ( 1'b0            ),
    .addressstall_b ( 1'b0            ),
    .byteena_a      ( 1'b1            ),
    .byteena_b      ( 1'b1            ),
    .clock1         ( 1'b1            ),
    .clocken0       ( iclkena         ),
    .clocken1       ( 1'b1            ),
    .clocken2       ( 1'b1            ),
    .clocken3       ( 1'b1            ),
    .data_b         ( {cRAMB_N{1'b1}} ),
    .eccstatus      (                 ),
    .q_a            (                 ),
    .rden_a         ( 1'b1            ),
    .rden_b         ( 1'b1            ),
    .wren_b         ( 1'b0            )
  );
`endif

  assign mem_LLR__iwaddr      = ram_LLR_waddr       [cRAM_WADDR_W-1 -: cRAM_RADDR_W];
  assign mem_LLR__iwdat       = iwLLR;
  assign mem_LLR__iraddr      = ram_LLR_raddr;

  assign mem_LLR_frzb__iwaddr = ram_LLR_frzb_waddr  [cRAM_WADDR_W-1 -: cRAM_RADDR_W];
  assign mem_LLR_frzb__iwdat  = iwfrzb;
  assign mem_LLR_frzb__iraddr = ram_LLR_raddr;

  assign mem_frzb__iwaddr     = ram_frzb_waddr      [cRAM_WADDR_W-1 -: cRAM_RADDR_W];
  assign mem_frzb__iwdat      = iwfrzb;
  assign mem_frzb__iraddr     = ram_frzb_raddr;

  generate
    genvar i;
    for (i = 0; i < cRAMB_N; i++) begin : ram_inst_gen

      polar_mem_block
      #(
        .pADDR_W ( cRAM_RADDR_W ) ,
        .pDAT_W  ( pLLR_W       ) ,
        .pPIPE   ( 0            )
      )
      mem_LLR
      (
        .iclk    ( iclk                ) ,
        .ireset  ( ireset              ) ,
        .iclkena ( iclkena             ) ,
        //
        .iwrite  ( mem_LLR__iwrite [i] ) ,
        .iwaddr  ( mem_LLR__iwaddr     ) ,
        .iwdat   ( mem_LLR__iwdat      ) ,
        //
        .iraddr  ( mem_LLR__iraddr     ) ,
        .ordat   ( mem_LLR__ordat  [i] )
      );

      assign mem_LLR__iwrite [i] = iwrite & (ram_LLR_waddr[cLSB_W-1 : 0] == i);

      assign orLLR           [i] = mem_LLR__ordat [i];
      //
      //
      //
`ifndef __USE_ALTERA_MACRO__
      polar_mem_block
      #(
        .pADDR_W ( cRAM_RADDR_W ) ,
        .pDAT_W  ( 1            ) ,
        .pPIPE   ( 0            )
      )
      mem_LLR_frzb
      (
        .iclk    ( iclk                     ) ,
        .ireset  ( ireset                   ) ,
        .iclkena ( iclkena                  ) ,
        //
        .iwrite  ( mem_LLR_frzb__iwrite [i] ) ,
        .iwaddr  ( mem_LLR_frzb__iwaddr     ) ,
        .iwdat   ( mem_LLR_frzb__iwdat      ) ,
        //
        .iraddr  ( mem_LLR_frzb__iraddr     ) ,
        .ordat   ( mem_LLR_frzb__ordat  [i] )
      );

      assign mem_LLR_frzb__iwrite [i] = iwrite & (ram_LLR_frzb_waddr[cLSB_W-1 : 0] == i);

      assign orLLR_frzb           [i] = mem_LLR_frzb__ordat[i];
      //
      //
      //
      polar_mem_block
      #(
        .pADDR_W ( cRAM_RADDR_W ) ,
        .pDAT_W  ( 1            ) ,
        .pPIPE   ( 0            )
      )
      mem_frzb
      (
        .iclk    ( iclk                 ) ,
        .ireset  ( ireset               ) ,
        .iclkena ( iclkena              ) ,
        //
        .iwrite  ( mem_frzb__iwrite [i] ) ,
        .iwaddr  ( mem_frzb__iwaddr     ) ,
        .iwdat   ( mem_frzb__iwdat      ) ,
        //
        .iraddr  ( mem_frzb__iraddr     ) ,
        .ordat   ( mem_frzb__ordat  [i] )
      );

      assign mem_frzb__iwrite [i] = iwrite & (ram_frzb_waddr[cLSB_W-1 : 0] == i);

      assign orfrzb           [i] = mem_frzb__ordat[i];
`endif
    end
  endgenerate

  //------------------------------------------------------------------------------------------------------
  // tag ram
  //------------------------------------------------------------------------------------------------------

  logic [pTAG_W-1 : 0] tram [0 : (2**pBNUM_W)-1] /*synthesis ramstyle = "logic"*/;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (iwfull)
        tram [b_wused] <= iwtag;
    end
  end

  assign ortag = tram[b_rused];

endmodule

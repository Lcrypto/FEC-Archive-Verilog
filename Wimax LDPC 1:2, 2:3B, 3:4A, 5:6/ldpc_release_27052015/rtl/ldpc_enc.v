/*



  parameter int pCODE               =  1 ;
  parameter int pN                  = 48 ;
  parameter int pDAT_W              =  4 ;
  parameter int pTAG_W              =  4 ;
  parameter bit pUSE_CMASK_ADDR_GEN =  0 ;


  logic                ldpc_enc__iclk     ;
  logic                ldpc_enc__ireset   ;
  logic                ldpc_enc__iclkena  ;
  logic                ldpc_enc__isop     ;
  logic                ldpc_enc__ieop     ;
  logic                ldpc_enc__ieof     ;
  logic                ldpc_enc__ival     ;
  logic [pTAG_W-1 : 0] ldpc_enc__itag     ;
  logic [pDAT_W-1 : 0] ldpc_enc__idat     ;
  logic                ldpc_enc__ordy     ;
  logic                ldpc_enc__osop     ;
  logic                ldpc_enc__oeop     ;
  logic                ldpc_enc__oeof     ;
  logic                ldpc_enc__oval     ;
  logic [pTAG_W-1 : 0] ldpc_enc__otag     ;
  logic [pDAT_W-1 : 0] ldpc_enc__odat     ;



  ldpc_enc
  #(
    .pCODE               ( pCODE               ) ,
    .pN                  ( pN                  ) ,
    .pDAT_W              ( pDAT_W              ) ,
    .pTAG_W              ( pTAG_W              ) ,
    .pUSE_CMASK_ADDR_GEN ( pUSE_CMASK_ADDR_GEN )
  )
  ldpc_enc
  (
    .iclk    ( ldpc_enc__iclk    ) ,
    .ireset  ( ldpc_enc__ireset  ) ,
    .iclkena ( ldpc_enc__iclkena ) ,
    .isop    ( ldpc_enc__isop    ) ,
    .ieop    ( ldpc_enc__ieop    ) ,
    .ieof    ( ldpc_enc__ieof    ) ,
    .ival    ( ldpc_enc__ival    ) ,
    .itag    ( ldpc_enc__itag    ) ,
    .idat    ( ldpc_enc__idat    ) ,
    .ordy    ( ldpc_enc__ordy    ) ,
    .osop    ( ldpc_enc__osop    ) ,
    .oeop    ( ldpc_enc__oeop    ) ,
    .oval    ( ldpc_enc__oval    ) ,
    .otag    ( ldpc_enc__otag    ) ,
    .odat    ( ldpc_enc__odat    )
  );


  assign ldpc_enc__iclk    = '0 ;
  assign ldpc_enc__ireset  = '0 ;
  assign ldpc_enc__iclkena = '0 ;
  assign ldpc_enc__isop    = '0 ;
  assign ldpc_enc__ieop    = '0 ;
  assign ldpc_enc__ieof    = '0 ;
  assign ldpc_enc__ival    = '0 ;
  assign ldpc_enc__itag    = '0 ;
  assign ldpc_enc__idat    = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_enc.v
// Description   : LDPC encoder with static encoding parameters. Encoder work on fly and use WIMAX H matrix
//                  Encoder work based upon H matrix decomposition and can be used only for matrix with X = -E*(T^-1)*B+D == EYE matrix
//

`include "define.vh"

module ldpc_enc
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  isop    ,
  ieop    ,
  ieof    ,
  ival    ,
  itag    ,
  idat    ,
  //
  ordy    ,
  //
  osop    ,
  oeop    ,
  oeof    ,
  oval    ,
  otag    ,
  odat
);

  parameter int pDAT_W              =  4; // 2^N bits granularity of encoder word
  parameter int pTAG_W              =  4;
  parameter bit pUSE_CMASK_ADDR_GEN =  0; // use complex mask counting function (use less resources)

  `include "ldpc_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                iclk    ;
  input  logic                ireset  ;
  input  logic                iclkena ;
  //
  input  logic                isop    ; // start of frame
  input  logic                ieop    ; // end of payload
  input  logic                ieof    ; // end of frame
  input  logic                ival    ; // valid of frame
  input  logic [pTAG_W-1 : 0] itag    ;
  input  logic [pDAT_W-1 : 0] idat    ; // frame data
  //
  output logic                ordy    ;
  //
  output logic                osop    ; // start of packet
  output logic                oeop    ; // end of packet
  output logic                oeof    ; // end of packet
  output logic                oval    ; // valid of packet
  output logic [pTAG_W-1 : 0] otag    ;
  output logic [pDAT_W-1 : 0] odat    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cBS_W    = clogb2(pDAT_W);

  localparam int cBASE    = pZF/pDAT_W;
  localparam int cADDR_W  = clogb2(cBASE);  // circshift(Hb[i]) address

  localparam int cP_NUM   = (cLDPC_NUM - cLDPC_DNUM)/pDAT_W;
  localparam int cP1_NUM  = cP_NUM/pC;
  localparam int cP2_NUM  = cP_NUM - cP1_NUM;

  localparam int cPCNT_W  = clogb2(cP1_NUM);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic                  addr_gen__iclear          ;
  logic                  addr_gen__ienable         ;
  logic    [cBASE-1 : 0] addr_gen__obitena    [pC] ;
  logic    [cBASE-1 : 0] addr_gen__obitsel    [pC] ;
  logic    [cBS_W-1 : 0] addr_gen__obitshift  [pC] ;
  logic  [cADDR_W-1 : 0] addr_gen__oaddr_low  [pC] ;
  logic  [cADDR_W-1 : 0] addr_gen__oaddr_high [pC] ;

  enum bit [2 : 0] {
    cRESET_STATE  ,
    //
    cDATA_STATE   ,
    cGET_P1_STATE ,
    cDO_P1_STATE  ,
    cDO_P2_STATE
  } state ;

  logic                sop;
  logic                eop;
  logic                eof;
  logic                val;
  logic [pTAG_W-1 : 0] tag;

  struct packed {
    logic [cPCNT_W-1 : 0] value ;
    logic                 p1done;
  } cnt;

  //------------------------------------------------------------------------------------------------------
  // align data
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      val <= 1'b0;
    else if (iclkena & ordy)
      val <= ival;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      sop <= isop;
      eop <= ieop;
      eof <= ieof;
      if (isop)
        tag <= itag;
    end
  end

  //------------------------------------------------------------------------------------------------------
  // FSM
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      state <= cRESET_STATE;
    end
    else if (iclkena) begin
      if (ival & isop)
        state <= cDATA_STATE;
      else
        unique case (state)
          cRESET_STATE  : state <= cRESET_STATE;
          //
          cDATA_STATE   : state <= (val & eop)        ? cGET_P1_STATE                       : cDATA_STATE;
          cGET_P1_STATE : state <= cDO_P1_STATE;
          cDO_P1_STATE  : state <= (val & cnt.p1done) ? cDO_P2_STATE                        : cDO_P1_STATE;
          cDO_P2_STATE  : state <= (val & eof)        ? (isop ? cDATA_STATE : cRESET_STATE) : cDO_P2_STATE;
        endcase
    end
  end

  assign ordy = (state != cGET_P1_STATE);

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (state == cGET_P1_STATE) begin
        cnt <= '0;
      end
      else if (val & (state == cDO_P1_STATE)) begin
        cnt.value   <= cnt.value + 1'b1;
        cnt.p1done  <= (cnt.value == cP1_NUM-2);
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // address generator for acu ram
  //------------------------------------------------------------------------------------------------------

  ldpc_enc_addr_gen
  #(
    .pCODE      ( pCODE               ) ,
    .pN         ( pN                  ) ,
    .pDAT_W     ( pDAT_W              ) ,
    .pUSE_CMASK ( pUSE_CMASK_ADDR_GEN )
  )
  addr_gen
  (
    .iclk       ( iclk       ) ,
    .ireset     ( ireset     ) ,
    .iclkena    ( iclkena    ) ,
    //
    .iclear     ( addr_gen__iclear     ) ,
    .ienable    ( addr_gen__ienable    ) ,
    //
    .obitena    ( addr_gen__obitena    ) ,
    .obitsel    ( addr_gen__obitsel    ) ,
    .obitshift  ( addr_gen__obitshift  )
  );

  assign addr_gen__iclear  = (isop & ival) | (val & eof);
  assign addr_gen__ienable = val & (state == cDATA_STATE | state == cDO_P1_STATE);

  //------------------------------------------------------------------------------------------------------
  // acu ram logic
  //------------------------------------------------------------------------------------------------------

  logic   [pDAT_W-1 : 0] acu  [pC][cBASE]; // {A*u', C*u'}
  logic   [pDAT_W-1 : 0] p1       [cBASE]; // B*p1'

  logic [2*pDAT_W-1 : 0] wdat [pC];

  always_comb begin : acu_wdata_process
    for (int i = 0; i < pC; i++) begin
      // muxed data/acu[pC-1][0] for mult
      wdat[i] = {p1[0], {pDAT_W{1'b0}}} >> addr_gen__obitshift[i];
    end
  end

  always_ff @(posedge iclk) begin
    logic [pDAT_W-1 : 0] tmp;
    //
    // acu[][] logic
    if (iclkena) begin
      if ((ival & isop) | (val & eof)) begin
        for (int j = 0; j < cBASE; j++) begin
          for (int i = 0; i < pC; i++) begin
            acu[i][j] <= '0;
          end
        end
      end
      else if (val) begin
        if (state == cDO_P2_STATE) begin
          // p2 = (T^-1)*(A*u'+B*p1') and shift register output (clear acu[0..pC-2])
          for (int j = 0; j < cBASE; j++) begin
            acu[0][j] <= (j == cBASE-1) ? (acu[0][0] ^ acu[1][0]) : acu[0][j+1];
            for (int i = 1; i < pC-1; i++) begin
              if (j == cBASE-1)
                acu[i][j] <= acu[i+1][0];
              else
                acu[i][j] <= acu[i][j+1];
            end
          end
        end
        else if (state == cDATA_STATE | state == cDO_P1_STATE) begin // (A+C)*u' or B*p1'
          for (int j = 0; j < cBASE; j++) begin
            for (int i = 0; i < pC; i++) begin
              if (addr_gen__obitena[i][j]) begin
                acu[i][j] <= acu[i][j] ^ (addr_gen__obitsel[i][j] ? wdat[i][2*pDAT_W-1 : pDAT_W] : wdat[i][  pDAT_W-1 : 0]);
              end
            end // cBASE
          end // pC
        end // state
      end // val
      //
      // p1[0] use as register for bitshift realization
      if (state == cGET_P1_STATE) begin
        // p1 = E*(T^-1)*(A*u') + C*u'
        for (int j = 0; j < cBASE; j++) begin
          for (int i = 0; i < pC; i++) begin
            tmp = (i == 0) ? acu[i][j] : (tmp ^ acu[i][j]);
          end
          p1[j] <= tmp ;
        end
      end
      else if (state == cDO_P1_STATE) begin
        // shift register output
        if (val) begin
          for (int i = 0; i < cBASE-1; i++) begin
            p1[i] <= p1[i+1];
          end
        end
      end
      else begin
        p1[0] <= idat;
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // output mapping
  //------------------------------------------------------------------------------------------------------

  wire val2out = val & (state == cDATA_STATE | state == cDO_P1_STATE | state == cDO_P2_STATE);

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      oval <= 1'b0;
    else if (iclkena)
      oval <= val2out;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      osop <= sop;
      oeop <= eop;
      oeof <= eof;
      if (val2out) begin
        unique case (state)
          cDO_P2_STATE : odat <= acu[0][0];
          default      : odat <= p1[0];
        endcase
        //
        if (sop)
          otag <= tag;
      end
    end
  end

endmodule

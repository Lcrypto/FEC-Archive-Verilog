/*



  parameter int pCODE          = 8 ;
  parameter int pLLR_BY_CYCLE  = 1 ;
  parameter int pIBUF_DELAY    = 4 ;



  logic       ldpc_dec_sbuf_uctrl__iclk        ;
  logic       ldpc_dec_sbuf_uctrl__ireset      ;
  logic       ldpc_dec_sbuf_uctrl__iclkena     ;
  logic       ldpc_dec_sbuf_uctrl__ibuf_full   ;
  mem_addr_t  ldpc_dec_sbuf_uctrl__obuf_addr   ;
  logic       ldpc_dec_sbuf_uctrl__ibuf_rempty ;
  logic       ldpc_dec_sbuf_uctrl__oudone      ;
  logic       ldpc_dec_sbuf_uctrl__oval        ;
  logic       ldpc_dec_sbuf_uctrl__osop        ;



  ldpc_dec_sbuf_uctrl
  #(
    .pCODE         ( pCODE         ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pIBUF_DELAY   ( pIBUF_DELAY   )
  )
  ldpc_dec_sbuf_uctrl
  (
    .iclk        ( ldpc_dec_sbuf_uctrl__iclk        ) ,
    .ireset      ( ldpc_dec_sbuf_uctrl__ireset      ) ,
    .iclkena     ( ldpc_dec_sbuf_uctrl__iclkena     ) ,
    .ibuf_full   ( ldpc_dec_sbuf_uctrl__ibuf_full   ) ,
    .obuf_addr   ( ldpc_dec_sbuf_uctrl__obuf_addr   ) ,
    .ibuf_rempty ( ldpc_dec_sbuf_uctrl__ibuf_rempty ) ,
    .oudone      ( ldpc_dec_sbuf_uctrl__oudone      ) ,
    .oval        ( ldpc_dec_sbuf_uctrl__oval        ) ,
    .osop        ( ldpc_dec_sbuf_uctrl__osop        )
  );


  assign ldpc_dec_sbuf_uctrl__iclk        = '0 ;
  assign ldpc_dec_sbuf_uctrl__ireset      = '0 ;
  assign ldpc_dec_sbuf_uctrl__iclkena     = '0 ;
  assign ldpc_dec_sbuf_uctrl__ibuf_full   = '0 ;
  assign ldpc_dec_sbuf_uctrl__ibuf_rempty = '0 ;



*/

// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_dec_sbuf_uctrl.v
// Description   : Upload data to shift mem FSM. Used for decoder with splited input buffer only
//

`include "define.vh"

module ldpc_dec_sbuf_uctrl
(
  iclk        ,
  ireset      ,
  iclkena     ,
  //
  ibuf_full   ,
  obuf_addr   ,
  //
  ibuf_rempty ,
  oudone      ,
  //
  oval        ,
  osop
);

  parameter int pLLR_W        = 5;
  parameter int pLLR_BY_CYCLE = 8;
  parameter int pIBUF_DELAY   = 4; // input buffer align delay

  `include "ldpc_parameters.vh"
  `include "ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic       iclk        ;
  input  logic       ireset      ;
  input  logic       iclkena     ;
  // input buffer interface
  input  logic       ibuf_full   ;
  output mem_addr_t  obuf_addr   ;
  // decoder FSM interface
  input  logic       ibuf_rempty ;
  output logic       oudone      ;  // upload done
  // vnode upload interface
  output logic       oval        ;
  output logic       osop        ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  enum bit [1 : 0] {
    cRESET_STATE    ,
    cWAIT_STATE     ,
    cDO_STATE       ,
    cWAIT_RDY_STATE
  } state;


  struct packed {
    mem_addr_t  val;
    logic       zero;
    logic       done;
  } cnt;

  logic [pIBUF_DELAY-1 : 0]  val_line;
  logic [pIBUF_DELAY-1 : 0]  sop_line;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      state <= cRESET_STATE;
    end
    else if (iclkena) begin
      case (state)
        cRESET_STATE    : state <= cWAIT_STATE;
        //
        cWAIT_STATE     : state <= ibuf_full   ? cDO_STATE       : cWAIT_STATE;
        //
        cDO_STATE       : state <= cnt.done    ? cWAIT_RDY_STATE : cDO_STATE;
        //
        cWAIT_RDY_STATE : state <= ibuf_rempty ? cWAIT_STATE     : cWAIT_RDY_STATE;
      endcase
    end
  end

  assign oudone = (state == cWAIT_RDY_STATE);

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (state == cWAIT_STATE) begin
        cnt <= '{val : '0, done : 1'b0, zero : 1'b1};
      end
      else if (state == cDO_STATE) begin
        cnt.val  <= cnt.val + 1'b1;
        cnt.done <= (cnt.val == cBLOCK_SIZE-2);
        cnt.zero <= &cnt.val;
      end
    end
  end

  assign obuf_addr = cnt.val;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      val_line <= (val_line << 1) | (state == cDO_STATE);
      sop_line <= (sop_line << 1) | (state == cDO_STATE & cnt.zero);
    end
  end

  assign oval = val_line[pIBUF_DELAY-1];
  assign osop = sop_line[pIBUF_DELAY-1];

endmodule

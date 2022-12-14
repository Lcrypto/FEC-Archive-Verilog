/*



  parameter int pCODE          = 8 ;
  parameter int pN             = 8 ;
  parameter int pLLR_W         = 1 ;
  parameter int pLLR_BY_CYCLE  = 1 ;
  parameter int pNODE_BY_CYCLE = 1 ;
  parameter bit pUSE_MN_MODE   = 0 ;



  logic         gsfc_ldpc_dec_ctrl__iclk         ;
  logic         gsfc_ldpc_dec_ctrl__ireset       ;
  logic         gsfc_ldpc_dec_ctrl__iclkena      ;
  logic [7 : 0] gsfc_ldpc_dec_ctrl__iNiter       ;
  logic         gsfc_ldpc_dec_ctrl__ibuf_full    ;
  logic         gsfc_ldpc_dec_ctrl__obuf_rempty  ;
  logic         gsfc_ldpc_dec_ctrl__iobuf_empty  ;
  logic         gsfc_ldpc_dec_ctrl__oload_mode   ;
  logic         gsfc_ldpc_dec_ctrl__oc_nv_mode   ;
  logic         gsfc_ldpc_dec_ctrl__oaddr_clear  ;
  logic         gsfc_ldpc_dec_ctrl__oaddr_enable ;
  logic         gsfc_ldpc_dec_ctrl__ivnode_busy  ;
  logic         gsfc_ldpc_dec_ctrl__ovnode_sop   ;
  logic         gsfc_ldpc_dec_ctrl__ovnode_val   ;
  logic         gsfc_ldpc_dec_ctrl__ovnode_eop   ;
  logic         gsfc_ldpc_dec_ctrl__icnode_busy  ;
  logic         gsfc_ldpc_dec_ctrl__ocnode_sop   ;
  logic         gsfc_ldpc_dec_ctrl__ocnode_val   ;
  logic         gsfc_ldpc_dec_ctrl__ocnode_eop   ;
  logic         gsfc_ldpc_dec_ctrl__olast_iter   ;



  gsfc_ldpc_dec_ctrl
  #(
    .pCODE          ( pCODE          ) ,
    .pN             ( pN             ) ,
    .pLLR_W         ( pLLR_W         ) ,
    .pLLR_BY_CYCLE  ( pLLR_BY_CYCLE  ) ,
    .pNODE_BY_CYCLE ( pNODE_BY_CYCLE ) ,
    .pUSE_MN_MODE   ( pUSE_MN_MODE   )
  )
  gsfc_ldpc_dec_ctrl
  (
    .iclk         ( gsfc_ldpc_dec_ctrl__iclk         ) ,
    .ireset       ( gsfc_ldpc_dec_ctrl__ireset       ) ,
    .iclkena      ( gsfc_ldpc_dec_ctrl__iclkena      ) ,
    .iNiter       ( gsfc_ldpc_dec_ctrl__iNiter       ) ,
    .ibuf_full    ( gsfc_ldpc_dec_ctrl__ibuf_full    ) ,
    .obuf_rempty  ( gsfc_ldpc_dec_ctrl__obuf_rempty  ) ,
    .iobuf_empty  ( gsfc_ldpc_dec_ctrl__iobuf_empty  ) ,
    .oload_mode   ( gsfc_ldpc_dec_ctrl__oload_mode   ) ,
    .oc_nv_mode   ( gsfc_ldpc_dec_ctrl__oc_nv_mode   ) ,
    .oaddr_clear  ( gsfc_ldpc_dec_ctrl__oaddr_clear  ) ,
    .oaddr_enable ( gsfc_ldpc_dec_ctrl__oaddr_enable ) ,
    .ivnode_busy  ( gsfc_ldpc_dec_ctrl__ivnode_busy  ) ,
    .ovnode_sop   ( gsfc_ldpc_dec_ctrl__ovnode_sop   ) ,
    .ovnode_val   ( gsfc_ldpc_dec_ctrl__ovnode_val   ) ,
    .ovnode_eop   ( gsfc_ldpc_dec_ctrl__ovnode_eop   ) ,
    .icnode_busy  ( gsfc_ldpc_dec_ctrl__icnode_busy  ) ,
    .ocnode_sop   ( gsfc_ldpc_dec_ctrl__ocnode_sop   ) ,
    .ocnode_val   ( gsfc_ldpc_dec_ctrl__ocnode_val   ) ,
    .ocnode_eop   ( gsfc_ldpc_dec_ctrl__ocnode_eop   ) ,
    .olast_iter   ( gsfc_ldpc_dec_ctrl__olast_iter   )
  );


  assign gsfc_ldpc_dec_ctrl__iclk        = '0 ;
  assign gsfc_ldpc_dec_ctrl__ireset      = '0 ;
  assign gsfc_ldpc_dec_ctrl__iclkena     = '0 ;
  assign gsfc_ldpc_dec_ctrl__iNiter      = '0 ;
  assign gsfc_ldpc_dec_ctrl__ibuf_full   = '0 ;
  assign gsfc_ldpc_dec_ctrl__iobuf_empty = '0 ;
  assign gsfc_ldpc_dec_ctrl__ivnode_busy = '0 ;
  assign gsfc_ldpc_dec_ctrl__icnode_busy = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : gsfc_ldpc_dec_ctrl.v
// Description   : Main FSM. Generate address generator & vnode/cnode engines control signals
//

`include "define.vh"

module gsfc_ldpc_dec_ctrl
(
  iclk         ,
  ireset       ,
  iclkena      ,
  //
  iNiter       ,
  //
  ibuf_full    ,
  obuf_rempty  ,
  //
  iobuf_empty  ,
  //
  oload_mode   ,
  oc_nv_mode   ,
  //
  oaddr_clear  ,
  oaddr_enable ,
  //
  ivnode_busy  ,
  ovnode_sop   ,
  ovnode_val   ,
  ovnode_eop   ,
  //
  icnode_busy  ,
  ocnode_sop   ,
  ocnode_val   ,
  ocnode_eop   ,
  //
  olast_iter
);

  parameter bit pUSE_MN_MODE  = 0;  // use multi node working mode (decoders wirh output ram)

  `include "gsfc_ldpc_parameters.vh"
  `include "gsfc_ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic         iclk          ;
  input  logic         ireset        ;
  input  logic         iclkena       ;
  //
  input  logic [7 : 0] iNiter        ;
  // input buffer interface
  input  logic         ibuf_full     ;
  output logic         obuf_rempty   ;
  // output buffer interface
  input  logic         iobuf_empty   ;
  //
  output logic         oload_mode    ;
  output logic         oc_nv_mode    ;
  //
  output logic         oaddr_clear   ;
  output logic         oaddr_enable  ;
  //
  input  logic         ivnode_busy   ;
  output logic         ovnode_sop    ;
  output logic         ovnode_val    ;
  output logic         ovnode_eop    ;
  //
  input  logic         icnode_busy   ;
  output logic         ocnode_sop    ;
  output logic         ocnode_val    ;
  output logic         ocnode_eop    ;
  //
  output logic         olast_iter    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  enum bit [2 : 0] {
    cRESET_STATE,
    cWAIT_STATE ,
    //
    cVSTEP_STATE,
    cWAIT_VDONE_STATE,
    //
    cHSTEP_STATE,
    cWAIT_HDONE_STATE,
    //
    cDONE_STATE,
    //
    cWAIT_O_STATE
  } next_state, state /* synthesis syn_encoding = "sequential" */;

  struct packed {
    mem_addr_t cnt;
    logic      done;
    logic      zero;
  } step;

  struct packed {
    logic [7 : 0] cnt;
    logic         last;
  } iter;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      state <= cRESET_STATE;
    else if (iclkena)
      state <= next_state;
  end

  wire outbuf_nrdy = iter.last & !iobuf_empty;

  always_comb begin
    case (state)
      cRESET_STATE      : next_state = cWAIT_STATE;
      //
      cWAIT_STATE       : next_state = ibuf_full    ? cVSTEP_STATE                                  : cWAIT_STATE;
      //
      cVSTEP_STATE      : next_state = step.done    ? cWAIT_VDONE_STATE                             : cVSTEP_STATE;
      cWAIT_VDONE_STATE : next_state = !ivnode_busy ? (iter.last ? cDONE_STATE : cHSTEP_STATE)      : cWAIT_VDONE_STATE;
      //
      cHSTEP_STATE      : next_state = step.done    ? cWAIT_HDONE_STATE                             : cHSTEP_STATE;
      cWAIT_HDONE_STATE : next_state = !icnode_busy ? (outbuf_nrdy ? cWAIT_O_STATE : cVSTEP_STATE)  : cWAIT_HDONE_STATE;

      cWAIT_O_STATE     : next_state = !outbuf_nrdy ? cVSTEP_STATE : cWAIT_O_STATE;
      //
      cDONE_STATE       : next_state = cWAIT_STATE;  // need to wait addr_gen latency for set_empty signal
      //
      default           : next_state = cRESET_STATE;
    endcase
  end

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      obuf_rempty   <= 1'b0;
      oc_nv_mode    <= 1'b0;
      oaddr_clear   <= 1'b0;
      oaddr_enable  <= 1'b0;
    end
    else if (iclkena) begin
      obuf_rempty  <= (next_state == cDONE_STATE);

      oc_nv_mode   <= (next_state == cHSTEP_STATE) | (next_state == cWAIT_HDONE_STATE);

      oaddr_clear  <= (next_state ==  cWAIT_STATE) | (next_state == cWAIT_HDONE_STATE) | (next_state == cWAIT_VDONE_STATE);
      oaddr_enable <= (next_state == cVSTEP_STATE) | (next_state == cHSTEP_STATE);
    end
  end

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      {ovnode_sop, ovnode_val, ovnode_eop} <= '0;
      {ocnode_sop, ocnode_val, ocnode_eop} <= '0;
    end
    else if (iclkena) begin
      ovnode_sop <= (state == cVSTEP_STATE) & step.zero;
      ovnode_val <= (state == cVSTEP_STATE);
      ovnode_eop <= (state == cVSTEP_STATE) & step.done;

      ocnode_sop <= (state == cHSTEP_STATE) & step.zero;
      ocnode_val <= (state == cHSTEP_STATE);
      ocnode_eop <= (state == cHSTEP_STATE) & step.done;
    end
  end

  assign olast_iter = (state == cVSTEP_STATE) & iter.last;

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (state == cWAIT_STATE) begin
        oload_mode  <= 1'b1;
        iter.cnt    <= iNiter;
        iter.last   <= 1'b0;
      end
      else if (state == cWAIT_VDONE_STATE & !ivnode_busy) begin
        oload_mode  <= 1'b0;
        iter.cnt    <= iter.cnt - 1'b1;
        iter.last   <= (iter.cnt == 1);
      end
      //
      if (state == cWAIT_STATE | state == cWAIT_HDONE_STATE | state == cWAIT_VDONE_STATE) begin
        step <= '{cnt : '0, done : 1'b0, zero : 1'b1};
      end
      else if (state == cHSTEP_STATE | state == cVSTEP_STATE) begin
        step.cnt  <= step.cnt + 1'b1;
        //
        if (pUSE_MN_MODE)
          step.done <= (step.cnt == cBLOCK_SIZE-2);
        else
          step.done <= (state == cVSTEP_STATE & iter.last) ? (step.cnt == cDATA_SIZE-2) : (step.cnt == cBLOCK_SIZE-2);
        //
        step.zero <= &step.cnt;
      end
    end
  end

endmodule

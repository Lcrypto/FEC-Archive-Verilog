/*



  parameter int pCODE         = 1 ;
  parameter int pN            = 1 ;
  parameter int pLLR_W        = 4 ;
  parameter int pLLR_BY_CYCLE = 1 ;
  parameter bit pUSE_NORM     = 1 ;


  logic  ldpc_dec_cnode_engine__iclk       ;
  logic  ldpc_dec_cnode_engine__ireset     ;
  logic  ldpc_dec_cnode_engine__iclkena    ;
  logic  ldpc_dec_cnode_engine__isop       ;
  logic  ldpc_dec_cnode_engine__ival       ;
  logic  ldpc_dec_cnode_engine__ieop       ;
  tcnt_t ldpc_dec_cnode_engine__itcnt      ;
  zcnt_t ldpc_dec_cnode_engine__izcnt      ;
  logic  ldpc_dec_cnode_engine__ivmask     ;
  node_t ldpc_dec_cnode_engine__ivnode     ;
  logic  ldpc_dec_cnode_engine__oval       ;
  tcnt_t ldpc_dec_cnode_engine__otcnt      ;
  logic  ldpc_dec_cnode_engine__otcnt_zero ;
  zcnt_t ldpc_dec_cnode_engine__ozcnt      ;
  node_t ldpc_dec_cnode_engine__ocnode     ;
  logic  ldpc_dec_cnode_engine__obusy      ;



  ldpc_dec_cnode_engine
  #(
    .pCODE         ( pCODE         ) ,
    .pN            ( pN            ) ,
    .pLLR_W        ( pLLR_W        ) ,
    .pLLR_BY_CYCLE ( pLLR_BY_CYCLE ) ,
    .pUSE_NORM     ( pUSE_NORM     )
  )
  ldpc_dec_cnode_engine
  (
    .iclk       ( ldpc_dec_cnode_engine__iclk       ) ,
    .ireset     ( ldpc_dec_cnode_engine__ireset     ) ,
    .iclkena    ( ldpc_dec_cnode_engine__iclkena    ) ,
    .isop       ( ldpc_dec_cnode_engine__isop       ) ,
    .ival       ( ldpc_dec_cnode_engine__ival       ) ,
    .ieop       ( ldpc_dec_cnode_engine__ieop       ) ,
    .itcnt      ( ldpc_dec_cnode_engine__itcnt      ) ,
    .izcnt      ( ldpc_dec_cnode_engine__izcnt      ) ,
    .ivmask     ( ldpc_dec_cnode_engine__ivmask     ) ,
    .ivnode     ( ldpc_dec_cnode_engine__ivnode     ) ,
    .oval       ( ldpc_dec_cnode_engine__oval       ) ,
    .otcnt      ( ldpc_dec_cnode_engine__otcnt      ) ,
    .otcnt_zero ( ldpc_dec_cnode_engine__otcnt_zero ) ,
    .ozcnt      ( ldpc_dec_cnode_engine__ozcnt      ) ,
    .ocnode     ( ldpc_dec_cnode_engine__ocnode     ) ,
    .obusy      ( ldpc_dec_cnode_engine__obusy      )
  );


  assign ldpc_dec_cnode_engine__iclk    = '0 ;
  assign ldpc_dec_cnode_engine__ireset  = '0 ;
  assign ldpc_dec_cnode_engine__iclkena = '0 ;
  assign ldpc_dec_cnode_engine__isop    = '0 ;
  assign ldpc_dec_cnode_engine__ival    = '0 ;
  assign ldpc_dec_cnode_engine__ieop    = '0 ;
  assign ldpc_dec_cnode_engine__itcnt   = '0 ;
  assign ldpc_dec_cnode_engine__izcnt   = '0 ;
  assign ldpc_dec_cnode_engine__ivmask  = '0 ;
  assign ldpc_dec_cnode_engine__ivnode  = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_dec_cnode_engine.v
// Description   : LDPC decoder check node arithmetic engine: read vnode and count cnode. Module use sequentual sort algorithm, the count and writeback cnode values
//                  L(r_ji) = prod(sign(vn_ij)) * min(abs(vn_ij)) exclude (j ~= 1)
//

`include "define.vh"

module ldpc_dec_cnode_engine
(
  iclk       ,
  ireset     ,
  iclkena    ,
  //
  isop       ,
  ival       ,
  ieop       ,
  itcnt      ,
  izcnt      ,
  ivmask     ,
  ivnode     ,
  //
  oval       ,
  ocnode     ,
  //
  obusy      ,
  otcnt      ,
  otcnt_zero ,
  ozcnt
);

  parameter int pLLR_W        = 4;
  parameter int pLLR_BY_CYCLE = 1;
  parameter bit pUSE_NORM     = 1;

  `include "ldpc_parameters.vh"
  `include "ldpc_dec_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic  iclk       ;
  input  logic  ireset     ;
  input  logic  iclkena    ;
  //
  input  logic  isop       ;
  input  logic  ival       ;
  input  logic  ieop       ;
  input  tcnt_t itcnt      ;
  input  zcnt_t izcnt      ;
  input         ivmask     ;
  input  node_t ivnode     ;
  //
  output logic  oval       ;
  output node_t ocnode     ;
  //
  output logic  obusy      ;
  output tcnt_t otcnt      ;
  output logic  otcnt_zero ;
  output zcnt_t ozcnt      ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  typedef logic [cNODE_W-1 : 0] vnode_t; // != node_t because unsigned !!!!!

  typedef struct {
    logic             prod_sign;
    vnode_t           min1;
    vnode_t           min2;
    tcnt_t            min1_idx;
    //
    logic  [pT-1 : 0] vn_sign;
    //
    zcnt_t            vn_zcnt;
  } vn_min_t;

  logic     val;

  struct packed {
    tcnt_t  val;
    logic   done;
    logic   zero;
  } tcnt_in;

  zcnt_t    zcnt_in;

  logic     sign_vnode;
  vnode_t   abs_vnode;

  vn_min_t  vn;

  logic     sort_done;
  vn_min_t  sort_vn;

  logic     cn_val;
  logic     cn_sign;
  node_t    cn_abs;

  //------------------------------------------------------------------------------------------------------
  // prepare data
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      val <= 1'b0;
    else if (iclkena)
      val <= ival;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (ival) begin
        zcnt_in <= izcnt;
        //
        if (isop) begin
          tcnt_in.val   <= '0;
          tcnt_in.done  <= 1'b0;
          tcnt_in.zero  <= 1'b1;
        end
        else begin
          tcnt_in.val   <= tcnt_in.done ? '0 : (tcnt_in.val + 1'b1);
          tcnt_in.zero  <= tcnt_in.done | &tcnt_in.val;
          tcnt_in.done  <= (tcnt_in.val == pT-2);
        end
        //
        if (ivmask) begin
          sign_vnode <= 1'b0;
          abs_vnode  <= {1'b1, {(cNODE_W-1){1'b0}}};
        end
        else begin
          sign_vnode <= ivnode[cNODE_W-1];
          abs_vnode  <= (ivnode ^ {cNODE_W{ivnode[cNODE_W-1]}}) + ivnode[cNODE_W-1];
        end
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // sequential sort : master
  //------------------------------------------------------------------------------------------------------

  wire check1 = (abs_vnode < vn.min1);
  wire check2 = (abs_vnode < vn.min2);

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (val) begin
        if (tcnt_in.zero) begin
          vn.prod_sign  <= sign_vnode;
          vn.vn_sign    <= (vn.vn_sign << 1) | sign_vnode;
          //
          vn.min1       <= abs_vnode;
          vn.min2       <= '1;
          vn.min1_idx   <= tcnt_in.val;
          //
          vn.vn_zcnt    <= zcnt_in;
        end
        else begin
          vn.prod_sign  <= vn.prod_sign ^ sign_vnode;
          vn.vn_sign    <= (vn.vn_sign << 1) | sign_vnode;
          //
          if (check1) begin
            vn.min1     <= abs_vnode;
            vn.min1_idx <= tcnt_in.val;
          end
          if (check2) begin
            vn.min2 <= check1 ? vn.min1 : abs_vnode;
          end
        end // (tcnt != 0)
      end // val
    end // iclkena
  end // iclk

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      sort_done <= 1'b0;
    else if (iclkena)
      sort_done <= val & tcnt_in.done;
  end

  //------------------------------------------------------------------------------------------------------
  // sequential flush
  //------------------------------------------------------------------------------------------------------

  struct packed {
    tcnt_t val;
    logic  done;
    logic  zero;
  } tcnt_out;

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      obusy <= 1'b0;
      oval  <= 1'b0;
    end
    else if (iclkena) begin
      if (sort_done)
        obusy <= 1'b1;
      else if (tcnt_out.done)
        obusy <= 1'b0;
      //
      oval <= obusy;
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (sort_done) begin
        sort_vn       <= vn;
        sort_vn.min1  <= normalize(vn.min1);
        sort_vn.min2  <= normalize(vn.min2);
        tcnt_out      <= '0;
        tcnt_out.zero <= 1'b1;
      end
      else if (obusy) begin
        tcnt_out.val    <=  tcnt_out.val + 1'b1;
        tcnt_out.done   <= (tcnt_out.val == pT-2);
        tcnt_out.zero   <= &tcnt_out.val;
        sort_vn.vn_sign <= sort_vn.vn_sign << 1;
      end
      //
      if (obusy) begin
        cn_abs      <= (sort_vn.min1_idx == tcnt_out.val) ? sort_vn.min2 : sort_vn.min1;
        cn_sign     <= sort_vn.vn_sign[pT-1] ^ sort_vn.prod_sign;
      end
    end
  end

  // register outside of module
  assign ocnode     = (cn_abs ^ {cNODE_W{cn_sign}}) + cn_sign;

  // one tick early
  assign otcnt      = tcnt_out.val;
  assign otcnt_zero = tcnt_out.zero;
  assign ozcnt      = sort_vn.vn_zcnt;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  function automatic vnode_t normalize (input vnode_t dat);
    logic [cNODE_W+2 : 0] tmp; // + 3 bit
  begin
    if (pUSE_NORM) begin //0.875
      tmp = (dat <<< 3) - dat + 4;
      normalize = tmp[cNODE_W+2 : 3];
    end
    else begin
      normalize = dat;
    end
  end
  endfunction

endmodule

/*



  parameter int pLLR_W        =  4 ;
  parameter int pNODE_W       =  4 ;
  parameter bit pNORM_FACTOR  =  7 ;


  logic  ldpc_3gpp_dec_cnode_p_engine__iclk                     ;
  logic  ldpc_3gpp_dec_cnode_p_engine__ireset                   ;
  logic  ldpc_3gpp_dec_cnode_p_engine__iclkena                  ;
  //
  logic  ldpc_3gpp_dec_cnode_p_engine__ival                     ;
  strb_t ldpc_3gpp_dec_cnode_p_engine__istrb                    ;
  logic  ldpc_3gpp_dec_cnode_p_engine__ivmask   [cCOL_BY_CYCLE] ;
  node_t ldpc_3gpp_dec_cnode_p_engine__ivnode   [cCOL_BY_CYCLE] ;
  logic  ldpc_3gpp_dec_cnode_p_engine__ipmask                   ;
  node_t ldpc_3gpp_dec_cnode_p_engine__ipnode                   ;
  //
  logic  ldpc_3gpp_dec_cnode_p_engine__oval                     ;
  strb_t ldpc_3gpp_dec_cnode_p_engine__ostrb                    ;
  node_t ldpc_3gpp_dec_cnode_p_engine__ocnode   [cCOL_BY_CYCLE] ;
  //
  logic  ldpc_3gpp_dec_cnode_p_engine__odecfail                 ;



  ldpc_3gpp_dec_cnode_p_engine
  #(
    .pLLR_W        ( pLLR_W        ) ,
    .pNODE_W       ( pNODE_W       ) ,
    .pNORM_FACTOR  ( pNORM_FACTOR  )
  )
  ldpc_3gpp_dec_cnode_p_engine
  (
    .iclk       ( ldpc_3gpp_dec_cnode_p_engine__iclk       ) ,
    .ireset     ( ldpc_3gpp_dec_cnode_p_engine__ireset     ) ,
    .iclkena    ( ldpc_3gpp_dec_cnode_p_engine__iclkena    ) ,
    //
    .ival       ( ldpc_3gpp_dec_cnode_p_engine__ival       ) ,
    .istrb      ( ldpc_3gpp_dec_cnode_p_engine__istrb      ) ,
    .ivmask     ( ldpc_3gpp_dec_cnode_p_engine__ivmask     ) ,
    .ivnode     ( ldpc_3gpp_dec_cnode_p_engine__ivnode     ) ,
    .ipmask     ( ldpc_3gpp_dec_cnode_p_engine__ipmask     ) ,
    .ipnode     ( ldpc_3gpp_dec_cnode_p_engine__ipnode     ) ,
    //
    .oval       ( ldpc_3gpp_dec_cnode_p_engine__oval       ) ,
    .ostrb      ( ldpc_3gpp_dec_cnode_p_engine__ostrb      ) ,
    .ocnode     ( ldpc_3gpp_dec_cnode_p_engine__ocnode     )
    //
    .odecfail   ( ldpc_3gpp_dec_cnode_p_engine__odecfail   )
  );


  assign ldpc_3gpp_dec_cnode_p_engine__iclk    = '0 ;
  assign ldpc_3gpp_dec_cnode_p_engine__ireset  = '0 ;
  assign ldpc_3gpp_dec_cnode_p_engine__iclkena = '0 ;
  assign ldpc_3gpp_dec_cnode_p_engine__ival    = '0 ;
  assign ldpc_3gpp_dec_cnode_p_engine__istrb   = '0 ;
  assign ldpc_3gpp_dec_cnode_p_engine__ivmask  = '0 ;
  assign ldpc_3gpp_dec_cnode_p_engine__ivnode  = '0 ;
  assign ldpc_3gpp_dec_cnode_p_engine__ipmask  = '0 ;
  assign ldpc_3gpp_dec_cnode_p_engine__ipnode  = '0 ;



*/

//
// Project       : ldpc 3gpp TS 38.212 v15.7.0
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_3gpp_dec_cnode_p_engine.sv
// Description   : LDPC decoder check node arithmetic engine: read vnode and count cnode.
//                  Module use sequential/paralel sort algorithm, the count and writeback cnode values
//                  L(r_ji) = prod(sign(vn_ij)) * min(abs(vn_ij)) exclude (j ~= 1)
//                  Module works by 2 step :  1 step :: pcol_by_cycle parallel partial sequential pLLR_BY_CYCLE search for pT/pcol_by_cycle cycles..
//                                            2 step :: pcol_by_cycle sequential full search
//

`include "define.vh"

module ldpc_3gpp_dec_cnode_p_engine
(
  iclk     ,
  ireset   ,
  iclkena  ,
  //
  ival     ,
  istrb    ,
  ivmask   ,
  ivnode   ,
  ipmask   ,
  ipnode   ,
  //
  oval     ,
  ostrb    ,
  ocnode   ,
  //
  odecfail
);

  parameter int pNORM_FACTOR  = 7;  // pNORM_FACTOR/8 - normalization factor

  `include "../ldpc_3gpp_constants.svh"
  `include "ldpc_3gpp_dec_types.svh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic  iclk                      ;
  input  logic  ireset                    ;
  input  logic  iclkena                   ;
  //
  input  logic  ival                      ;
  input  strb_t istrb                     ;
  input  logic  ivmask    [cCOL_BY_CYCLE] ;
  input  node_t ivnode    [cCOL_BY_CYCLE] ;
  input  logic  ipmask                    ;
  input  node_t ipnode                    ;
  //
  output logic  oval                      ;
  output strb_t ostrb                     ;
  output node_t ocnode    [cCOL_BY_CYCLE] ;
  //
  output logic  odecfail                  ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cSORT_TREE_LEVEL = clogb2(cCOL_BY_CYCLE + 1);

  typedef int sort_tree_t [0 : cSORT_TREE_LEVEL];

  localparam sort_tree_t cSORT_TREE = gen_sort_tree(cCOL_BY_CYCLE + 1);

  function sort_tree_t gen_sort_tree (input int col_by_cycle);
    gen_sort_tree[0] = col_by_cycle;
    for (int i = 1; i <= cSORT_TREE_LEVEL; i++)  begin
      col_by_cycle     = (col_by_cycle >> 1) + col_by_cycle[0];
      gen_sort_tree[i] = col_by_cycle;
    end
  endfunction

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic         val;
  strb_t        strb;
  logic         pmask;

  vnode_sign_t  sign_vnode;
  vnode_t       abs_vnode [cCOL_BY_CYCLE];

  logic         sign_pnode ;
  vnode_t       abs_pnode  ;

  logic         sort_start;

  vn_min_t      vn2sort   [cCOL_BY_CYCLE + 1];
  strb_t        vn_strb   [cSORT_TREE_LEVEL];
  vnode_sign_t  vn_sign   [cSORT_TREE_LEVEL];
  logic         prod_sign [cSORT_TREE_LEVEL];
  logic         vn_pmask  [cSORT_TREE_LEVEL];

  vn_min_t      masked_vn ;

  logic         p_engine__ival [cSORT_TREE_LEVEL][cCOL_BY_CYCLE]    ;
  vn_min_t      p_engine__ivn  [cSORT_TREE_LEVEL][cCOL_BY_CYCLE][2] ;
  logic         p_engine__oval [cSORT_TREE_LEVEL][cCOL_BY_CYCLE]    ;
  vn_min_t      p_engine__ovn  [cSORT_TREE_LEVEL][cCOL_BY_CYCLE]    ;

  logic         vn_sort_done;
  strb_t        vn_sort_strb;
  logic         vn_sort_pmask;
  vn_min_t      vn_sort;

  logic         sorted_vn_val;
  strb_t        sorted_vn_strb;
  vn_min_t      sorted_vn;

  logic         decfail_acc;

  vnode_sign_t  cn_sign;
  vnode_t       cn_abs  [cCOL_BY_CYCLE];

  //------------------------------------------------------------------------------------------------------
  // prepare vnodes for sort
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset)
      val <= 1'b0;
    else if (iclkena)
      val <= ival;
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      strb  <= istrb;
      pmask <= ipmask;
      // vnode
      for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
        if (ivmask[col]) begin
          sign_vnode[col] <= 1'b0;
          abs_vnode [col] <= {1'b1, {(pNODE_W-1){1'b0}}};
        end
        else begin
          sign_vnode[col] <=  ivnode[col][pNODE_W-1];
          abs_vnode [col] <= (ivnode[col] ^ {pNODE_W{ivnode[col][pNODE_W-1]}}) + ivnode[col][pNODE_W-1];
        end
      end
      // pnode
      if (ipmask) begin
        sign_pnode <= 1'b0;
        abs_pnode  <= {1'b1, {(pNODE_W-1){1'b0}}};
      end
      else begin
        sign_pnode <=  ipnode[pNODE_W-1];
        abs_pnode  <= (ipnode ^ {pNODE_W{ipnode[pNODE_W-1]}}) + ipnode[pNODE_W-1];
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // assemble data for sort
  //------------------------------------------------------------------------------------------------------

  always_comb begin
    for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
      vn2sort[col].min1     = abs_vnode [col] ;
      vn2sort[col].min2     = '1;
      vn2sort[col].min1_col = col;
    end
    //
    vn2sort[cCOL_BY_CYCLE].min1     = abs_pnode;
    vn2sort[cCOL_BY_CYCLE].min2     = '1;
    vn2sort[cCOL_BY_CYCLE].min1_col = cCOL_BY_CYCLE;
  end

  assign sort_start = val;

  // align delay of signs
  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (sort_start) begin
        vn_strb   [0] <= strb;
        vn_sign   [0] <= sign_vnode;
        prod_sign [0] <= ^sign_vnode ^ sign_pnode;
        vn_pmask  [0] <= pmask;
      end
      //
      for (int i = 1; i < cSORT_TREE_LEVEL; i++) begin
        vn_strb   [i] <= vn_strb   [i-1];
        vn_sign   [i] <= vn_sign   [i-1];
        prod_sign [i] <= prod_sign [i-1];
        vn_pmask  [i] <= vn_pmask  [i-1];
      end
    end
  end

  //------------------------------------------------------------------------------------------------------
  // parallel sort : master
  //------------------------------------------------------------------------------------------------------

  always_comb begin
    masked_vn       = '0;
    masked_vn.min1  = '1;
    masked_vn.min2  = '1;
  end

  //
  // sorting tree
  //
  generate
    genvar i, j;
    for (i = 0; i < cSORT_TREE_LEVEL; i++) begin : sort_tree_level_gen // binary tree level
      for (j = 0; j < cSORT_TREE[i+1]; j++) begin : sort_tree_stage_gen
        ldpc_3gpp_dec_cnode_p_2way_engine
        #(
          .pLLR_W  ( pLLR_W  ) ,
          .pNODE_W ( pNODE_W )
        )
        p_engine
        (
          .iclk    ( iclk    ) ,
          .ireset  ( ireset  ) ,
          .iclkena ( iclkena ) ,
          //
          .ival    ( p_engine__ival [i][j] ) ,
          .ivn     ( p_engine__ivn  [i][j] ) ,
          //
          .oval    ( p_engine__oval [i][j] ) ,
          .ovn     ( p_engine__ovn  [i][j] )
        );
        //
        //
        always_comb begin
          p_engine__ival[i][j]    = (i == 0) ? sort_start       : p_engine__oval[i-1][0];
          //
          p_engine__ivn [i][j][0] = (i == 0) ? vn2sort[2*j + 0] : p_engine__ovn [i-1][2*j + 0];
          p_engine__ivn [i][j][1] = (i == 0) ? vn2sort[2*j + 1] : p_engine__ovn [i-1][2*j + 1];
          // odd tree layer -> need bypass odd vn
          if (cSORT_TREE[i][0] & (j == cSORT_TREE[i+1]-1)) begin
            p_engine__ivn [i][j][1] = masked_vn;
          end
        end
      end
    end
  endgenerate

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_comb begin
    vn_sort_done      = p_engine__oval [cSORT_TREE_LEVEL-1][0];
    vn_sort           = p_engine__ovn  [cSORT_TREE_LEVEL-1][0];
    //
    vn_sort.prod_sign = prod_sign      [cSORT_TREE_LEVEL-1];
    vn_sort.vn_sign   = vn_sign        [cSORT_TREE_LEVEL-1];
    //
    vn_sort_strb      = vn_strb        [cSORT_TREE_LEVEL-1];
    vn_sort_pmask     = vn_pmask       [cSORT_TREE_LEVEL-1];
  end

  //------------------------------------------------------------------------------------------------------
  // parallel flush : slave
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      sorted_vn_val <= 1'b0;
      oval          <= 1'b0;
    end
    else if (iclkena) begin
      sorted_vn_val <= vn_sort_done;
      oval          <= sorted_vn_val;
    end
  end

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      sorted_vn_strb <= vn_sort_strb;
      //
      if (vn_sort_done) begin
        sorted_vn           <= vn_sort;
        sorted_vn.min1      <= normalize(vn_sort.min1);
        sorted_vn.min2      <= normalize(vn_sort.min2);
        sorted_vn.prod_sign <= vn_sort.prod_sign;
        // parity mask is inverted. count decfail only for major matrix
        decfail_acc         <= (vn_sort_strb.sof & vn_sort_strb.sop) ? (vn_sort.prod_sign & vn_sort_pmask) :
                                                        (decfail_acc | (vn_sort.prod_sign & vn_sort_pmask));
      end
      //
      ostrb <= sorted_vn_strb;
      if (sorted_vn_val) begin
        odecfail <= decfail_acc;
        for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
          cn_sign [col] <=  sorted_vn.vn_sign[col] ^ sorted_vn.prod_sign;
          cn_abs  [col] <= (sorted_vn.min1_col == col) ? sorted_vn.min2 : sorted_vn.min1;
        end
      end
    end
  end

  // register outside of module
  always_comb begin
    for (int col = 0; col < cCOL_BY_CYCLE; col++) begin
      ocnode[col] = (cn_abs[col] ^ {pNODE_W{cn_sign[col]}}) + cn_sign[col];
    end
  end

  //------------------------------------------------------------------------------------------------------
  // used functions
  //------------------------------------------------------------------------------------------------------

  function automatic vnode_t normalize (input vnode_t dat);
    logic [pNODE_W+2 : 0] tmp; // + 3 bit
  begin
    if (pNORM_FACTOR != 0) begin //0.875
      case (pNORM_FACTOR)
        4       : begin // 0.5
          tmp = (dat <<< 2) + 4;
        end
        5       : begin // 0.625
          tmp = (dat <<< 2) + dat + 4;
        end
        6       : begin // 0.75
          tmp = (dat <<< 2) + (dat <<< 1) + 4;
        end
        default : begin // 0.875
          tmp = (dat <<< 3) - dat + 4;
        end
      endcase
      normalize = tmp[pNODE_W+2 : 3];
    end
    else begin
      normalize = dat;
    end
  end
  endfunction

endmodule

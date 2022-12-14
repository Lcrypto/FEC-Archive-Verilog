//
// Project       : GSFC ldpc (7154, 8176)
// Author        : Shekhalev Denis (des00)
// Workfile      : gsfc_ldpc_dec_parameters.v
// Description   : Decoder parameters & types declaration file
//

  //------------------------------------------------------------------------------------------------------
  // decoder parameters
  //------------------------------------------------------------------------------------------------------

  parameter int pLLR_W                = 4;
  parameter int pLLR_BY_CYCLE         = 1;  // amount of metric per clock cycle. must be multiple of pZF. Only 1/7 is supported (!!!)
  parameter int pNODE_BY_CYCLE        = 1;  // amount of one metric cnode/vnode per clock cycle. must be multiple of pT. Only 1 is supported (!!!)
                                            // the decoder rate is pLLR_BY_CYCLE * pNODE_BY_CYCLE cnode/vnode per clock cycle

  //------------------------------------------------------------------------------------------------------
  // used typese
  //------------------------------------------------------------------------------------------------------

  localparam int cNODE_W = pLLR_W + 0;  // extend internal node bitwidth to increase fixed point part when normaliation used

  typedef logic signed  [pLLR_W-1 : 0] llr_t;
  typedef logic signed [cNODE_W-1 : 0] node_t;
  typedef logic        [cNODE_W-1 : 0] vnode_t; // != node_t because unsigned !!!!!

  //------------------------------------------------------------------------------------------------------
  // used bitwidths
  //------------------------------------------------------------------------------------------------------

  // buffer/shift memory address
  localparam int cADDR_MAX    = cLDPC_NUM/(pLLR_BY_CYCLE * pNODE_BY_CYCLE);
  localparam int cADDR_W      = clogb2(cADDR_MAX);

  // shift memory multiplexing address
  localparam int cSELA_W      = (pLLR_BY_CYCLE == 1) ? 1 : clogb2(pLLR_BY_CYCLE);

  //
  localparam int cNODE_CNT_W  = clogb2(pNODE_BY_CYCLE);

  // H matrix t counter :: scaled by pNODE_BY_CYCLE
  localparam int cT_MAX       = pT/pNODE_BY_CYCLE;
  localparam int cTCNT_W      = (cT_MAX == 1) ? 1 : clogb2(cT_MAX);

  // expansion factor counter :: scaled by pLLR_BY_CYCLE
  localparam int cZ_MAX       = pZF/pLLR_BY_CYCLE;
  localparam int cZCNT_W      = clogb2(cZ_MAX);

  // block (data + parity) size in pLLR_BY_CYCLE * pNODE_BY_CYCLE
  localparam int cBLOCK_SIZE  = cLDPC_NUM/(pLLR_BY_CYCLE * pNODE_BY_CYCLE);
  // data size in pLLR_BY_CYCLE for pNODE_BY_CYCLE == 1
  localparam int cDATA_SIZE   = cLDPC_DNUM/pLLR_BY_CYCLE;

  // bit errors per cycle
  localparam int cBIT_ERR_MAX = pLLR_BY_CYCLE * pNODE_BY_CYCLE;
  localparam int cBIT_ERR_W   = clogb2(cBIT_ERR_MAX);

  typedef bit   [cADDR_W-1 : 0] mem_addr_t;
  typedef bit   [cSELA_W-1 : 0] mem_sela_t;

  typedef logic [cTCNT_W-1 : 0] tcnt_t;
  typedef logic [cZCNT_W-1 : 0] zcnt_t;

  typedef logic [cNODE_CNT_W-1 : 0] node_cnt_t;

  typedef struct packed {
    logic               prod_sign;
    vnode_t             min1;
    vnode_t             min2;
    tcnt_t              min1_idx;     // serial   node index
    node_cnt_t          min1_node;    // parallel node index
    bit                 min1_weigth;  // weigth   index
    //
    logic [pW*pT-1 : 0] vn_sign;
    //
    zcnt_t              vn_zcnt;
  } vn_min_t;

  //------------------------------------------------------------------------------------------------------
  // generation of address table to pipeline decoder by pLLR_BY_CYCLE processing
  //------------------------------------------------------------------------------------------------------

  localparam int cFADDR_W = clogb2(cLDPC_NUM/pLLR_BY_CYCLE); // full address width only for tables (do single table for variable pNODE_BY_CYCLE)

  typedef struct {
    bit [cFADDR_W-1 : 0] baddr;
    bit [cFADDR_W-1 : 0] offset  [pLLR_BY_CYCLE];
    bit [cFADDR_W-1 : 0] offsetm [pLLR_BY_CYCLE];  // offset mask :: true_offset = (baddr == 0 & ofsetm != 0) ? (offset + cZ_MAX) : offset
    mem_sela_t           sela    [pLLR_BY_CYCLE];
    mem_sela_t           invsela [pLLR_BY_CYCLE];
  } paddr_t;

  typedef paddr_t addr_tab_t [pC][pW][pT][cZ_MAX];

  function addr_tab_t get_addr_tab (input bit do_print = 0, short_print = 0);
    int taddr ;
    //
    int addr    [pLLR_BY_CYCLE];
    int maddr   [pLLR_BY_CYCLE];
    int sela    [pLLR_BY_CYCLE];
    int invsela [pLLR_BY_CYCLE];
    int offset  [pLLR_BY_CYCLE];
    int offsetm [pLLR_BY_CYCLE];
    //
    int fp;
  begin
    // synthesis translate_off
    if (do_print) begin
      fp = $fopen("../rtl/gsfc_ldpc/dec/gsfc_ldpc_dec_addr_gen_tab.vh");
      $fdisplay(fp, "//");
      if (short_print)
        $fdisplay(fp, "// (!!!) IT'S GENERATED short table for %0d/%0d coderate, %0d bits do %0d LLR per cycle(!!!)", pCODE, pCODE+1, pN, pLLR_BY_CYCLE);
      else
        $fdisplay(fp, "// (!!!) IT'S GENERATED full table for %0d/%0d coderate, %0d bits do %0d LLR per cycle(!!!)", pCODE, pCODE+1, pN, pLLR_BY_CYCLE);
      $fdisplay(fp, "//");
    end
    // synthesis translate_on
    for (int c = 0; c < pC; c++) begin
      for (int w = 0; w < pW; w++) begin
        for (int t = 0; t < pT; t++) begin
          for (int z = 0; z < cZ_MAX; z++) begin
            // generate all address
            for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
              taddr = (Hb[c][t][w] + llra + pZF + z*pLLR_BY_CYCLE) % pZF;
              //
              addr[llra] = taddr / pLLR_BY_CYCLE;
              sela[llra] = taddr % pLLR_BY_CYCLE;
            end
            // get muxed address
            for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
              maddr   [sela[llra]] = addr[llra];
              invsela [sela[llra]] = llra;
            end
            // detect offsets and masked offsets
            for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
              offset  [llra] = maddr[llra] - maddr[0];
              offsetm [llra] = (offset [llra] == 0) ? 0 : -1;
            end
            //
            get_addr_tab[c][w][t][z].baddr = maddr[0];
            for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
              get_addr_tab[c][w][t][z].offset  [llra] = offset  [llra];
              get_addr_tab[c][w][t][z].offsetm [llra] = offsetm [llra];
              get_addr_tab[c][w][t][z].sela    [llra] = sela    [llra];
              get_addr_tab[c][w][t][z].invsela [llra] = invsela [llra];
            end
            // synthesis translate_off
            if (do_print) begin
              if (!short_print)
                $fdisplay(fp, "  addr_tab[%0d][%0d][%0d][%0d] = %p;", c, w, t, z, get_addr_tab[c][w][t][z]);
              else if (z == 0)
                $fdisplay(fp, "  addr_tab[%0d][%0d][%0d][%0d] = %p;", c, w, t, z, get_addr_tab[c][w][t][z]);
            end
            // synthesis translate_on
          end
        end
      end
    end
    // synthesis translate_off
    if (do_print)
      $fclose(fp);
    // synthesis translate_on
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  // function to pipeline decoder by pNODE_BY_CYCLE processing
  //------------------------------------------------------------------------------------------------------

  typedef paddr_t maddr_tab_t [pC][pW][pNODE_BY_CYCLE][cT_MAX][cZ_MAX];

  function maddr_tab_t get_maddr_tab (input addr_tab_t taddr_tab);
    for (int c = 0; c < pC; c++) begin
      for (int w = 0; w < pW; w++) begin
        for (int n = 0; n < pNODE_BY_CYCLE; n++) begin
          for (int t = 0; t < cT_MAX; t++) begin
            get_maddr_tab[c][w][n][t] = taddr_tab[c][w][n*cT_MAX + t];
          end
        end
      end
    end
  endfunction


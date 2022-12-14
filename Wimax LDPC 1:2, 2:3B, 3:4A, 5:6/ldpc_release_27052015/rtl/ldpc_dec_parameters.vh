//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_dec_parameters.v
// Description   : Decoder parameters & types declaration file
//

  //------------------------------------------------------------------------------------------------------
  // used typese
  //------------------------------------------------------------------------------------------------------

  localparam int cNODE_W = pLLR_W + 0;  // extend internal node bitwidth to increase fixed point part when normaliation used

  typedef logic signed  [pLLR_W-1 : 0] llr_t;
  typedef logic signed [cNODE_W-1 : 0] node_t;

  //------------------------------------------------------------------------------------------------------
  // used bitwidths
  //------------------------------------------------------------------------------------------------------

  // shift memory address
  localparam int cADDR_W  = clogb2(cLDPC_NUM/pLLR_BY_CYCLE) ;
  // shift memory multiplexing address
  localparam int cSELA_W  = clogb2(pLLR_BY_CYCLE);

  // H matrix  t counter
  localparam int cTCNT_W  = clogb2(pT);

  // expansion factor counter
  localparam int cZ_MAX     = pZF/pLLR_BY_CYCLE;
  localparam int cZCNT_W    = clogb2(cZ_MAX);
  localparam int cF_ZCNT_W  = clogb2(pZF); // full Z width

  // block (data + parity) size in pLLR_BY_CYCLE
  localparam int cBLOCK_SIZE  = cLDPC_NUM/pLLR_BY_CYCLE;
  // data size in pLLR_BY_CYCLE
  localparam int cDATA_SIZE   = cLDPC_DNUM/pLLR_BY_CYCLE;

  typedef bit [cADDR_W-1 : 0] mem_addr_t;
  typedef bit [cSELA_W-1 : 0] mem_sela_t;

  typedef logic [cTCNT_W-1 : 0] tcnt_t;
  typedef logic [cZCNT_W-1 : 0] zcnt_t;

  //------------------------------------------------------------------------------------------------------
  // used tables
  //------------------------------------------------------------------------------------------------------
/*
  typedef int mH_t [pC][pT][pLLR_BY_CYCLE];

  mH_t mHb;  // Hb scaled to pZF

  assign mHb = get_mHb (0);

  function automatic mH_t get_mHb (input nul);
  begin
    for (int i = 0; i < pT; i++) begin
      for (int j = 0; j < pC; j++) begin
        for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
          get_mHb[j][i][llra] = (Hb[j][i] + llra + pZF) % pZF;
        end
      end
    end
  end
  endfunction
*/

  typedef struct {
    mem_addr_t baddr;
    mem_addr_t offset [pLLR_BY_CYCLE];
    mem_sela_t sela   [pLLR_BY_CYCLE];
  } paddr_t;

  typedef paddr_t addr_tab_t [pC][pT][cZ_MAX];

  function addr_tab_t get_addr_tab (input bit do_print = 0);
    int taddr ;
    int addr   [pLLR_BY_CYCLE];
    int maddr  [pLLR_BY_CYCLE];
    int sela   [pLLR_BY_CYCLE];
    int offset [pLLR_BY_CYCLE];
    int fp;
  begin
    if (do_print) begin
      fp = $fopen("../rtl/ldpc/ldpc_dec_addr_gen_tab.vh");
      $fdisplay(fp, "//");
      $fdisplay(fp, "// (!!!) IT'S GENERATED FILE for %0d/%0d coderate, %0d bits do %0d bits per cycle (!!!)", pCODE, pCODE+1, pN, pLLR_BY_CYCLE);
      $fdisplay(fp, "//");
    end
    //
    for (int c = 0; c < pC; c++) begin
      for (int t = 0; t < pT; t++) begin
        for (int z = 0; z < pZF/pLLR_BY_CYCLE; z++) begin
          // generate all address
          for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
            taddr = (Hb[c][t] + llra + pZF + z*pLLR_BY_CYCLE) % pZF;

            addr[llra] = taddr / pLLR_BY_CYCLE;
            sela[llra] = taddr % pLLR_BY_CYCLE;
          end
          // get muxed address
          for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
            maddr[sela[llra]] = addr[llra];
          end
          // detect offsets
          for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
            offset[llra] = maddr[llra] - maddr[0];
          end
          //
          get_addr_tab[c][t][z].baddr = maddr[0];
          for (int llra = 0; llra < pLLR_BY_CYCLE; llra++) begin
            get_addr_tab[c][t][z].offset[llra] = offset [llra];
            get_addr_tab[c][t][z].sela  [llra] = sela   [llra];
          end
          if (do_print)
            $fdisplay(fp, "  addr_tab[%0d][%0d][%0d] = %p;", c, t, z, get_addr_tab[c][t][z]);
        end
      end
    end
    if (do_print)
      $fclose(fp);
  end
  endfunction

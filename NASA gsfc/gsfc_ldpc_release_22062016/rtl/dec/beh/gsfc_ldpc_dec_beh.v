/*



  parameter int pCODE     =  1 ;
  parameter int pN        = 48 ;
  parameter int pLLR_W    =  5 ;
  parameter int pLLR_NUM  =  2 ;
  parameter int pTAG_W    =  4 ;



  logic                         gsfc_ldpc_dec_beh__iclk                     ;
  logic                         gsfc_ldpc_dec_beh__ireset                   ;
  logic                         gsfc_ldpc_dec_beh__iclkena                  ;
  logic                 [7 : 0] gsfc_ldpc_dec_beh__iNiter                   ;
  logic                         gsfc_ldpc_dec_beh__isop                     ;
  logic                         gsfc_ldpc_dec_beh__ieop                     ;
  logic                         gsfc_ldpc_dec_beh__ival                     ;
  logic          [pTAG_W-1 : 0] gsfc_ldpc_dec_beh__itag                     ;
  logic signed   [pLLR_W-1 : 0] gsfc_ldpc_dec_beh__iLLR    [0 : pLLR_NUM-1] ;
  logic                         gsfc_ldpc_dec_beh__obusy                    ;
  logic                         gsfc_ldpc_dec_beh__ordy                     ;
  logic                         gsfc_ldpc_dec_beh__osop                     ;
  logic                         gsfc_ldpc_dec_beh__oeop                     ;
  logic                         gsfc_ldpc_dec_beh__oval                     ;
  logic          [pTAG_W-1 : 0] gsfc_ldpc_dec_beh__otag                     ;
  logic        [pLLR_NUM-1 : 0] gsfc_ldpc_dec_beh__odat                     ;
  logic                [15 : 0] gsfc_ldpc_dec_beh__oerr                     ;



  gsfc_ldpc_dec_beh
  #(
    .pCODE    ( pCODE    ) ,
    .pN       ( pN       ) ,
    .pLLR_W   ( pLLR_W   ) ,
    .pLLR_NUM ( pLLR_NUM ) ,
    .pTAG_W   ( pTAG_W   )
  )
  gsfc_ldpc_dec_beh
  (
    .iclk    ( gsfc_ldpc_dec_beh__iclk    ) ,
    .ireset  ( gsfc_ldpc_dec_beh__ireset  ) ,
    .iclkena ( gsfc_ldpc_dec_beh__iclkena ) ,
    .iNiter  ( gsfc_ldpc_dec_beh__iNiter  ) ,
    .isop    ( gsfc_ldpc_dec_beh__isop    ) ,
    .ieop    ( gsfc_ldpc_dec_beh__ieop    ) ,
    .ival    ( gsfc_ldpc_dec_beh__ival    ) ,
    .itag    ( gsfc_ldpc_dec_beh__itag    ) ,
    .iLLR    ( gsfc_ldpc_dec_beh__iLLR    ) ,
    .obusy   ( gsfc_ldpc_dec_beh__obusy   ) ,
    .ordy    ( gsfc_ldpc_dec_beh__ordy    ) ,
    .osop    ( gsfc_ldpc_dec_beh__osop    ) ,
    .oeop    ( gsfc_ldpc_dec_beh__oeop    ) ,
    .oval    ( gsfc_ldpc_dec_beh__oval    ) ,
    .otag    ( gsfc_ldpc_dec_beh__otag    ) ,
    .odat    ( gsfc_ldpc_dec_beh__odat    ) ,
    .oerr    ( gsfc_ldpc_dec_beh__oerr    )
  );


  assign gsfc_ldpc_dec_beh__iclk    = '0 ;
  assign gsfc_ldpc_dec_beh__ireset  = '0 ;
  assign gsfc_ldpc_dec_beh__iclkena = '0 ;
  assign gsfc_ldpc_dec_beh__iNiter  = '0 ;
  assign gsfc_ldpc_dec_beh__isop    = '0 ;
  assign gsfc_ldpc_dec_beh__ieop    = '0 ;
  assign gsfc_ldpc_dec_beh__ival    = '0 ;
  assign gsfc_ldpc_dec_beh__itag    = '0 ;
  assign gsfc_ldpc_dec_beh__iLLR    = '0 ;



*/

//
// Project       : GSFC ldpc (7154, 8176)
// Author        : Shekhalev Denis (des00)
// Workfile      : gsfc_ldpc_dec_beh.v
// Description   : behaviour LDPC decoder. Normalized min-sum algorithm is used.
//                 the input LLR inversion must be done outside the decoder (!!!)
//


module gsfc_ldpc_dec_beh
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  iNiter  ,
  //
  isop    ,
  ieop    ,
  ival    ,
  itag    ,
  iLLR    ,
  //
  obusy   ,
  ordy    ,
  //
  osop    ,
  oeop    ,
  oval    ,
  otag    ,
  odat    ,
  oerr
);

  parameter int pLLR_W      =  5 ;
  parameter int pLLR_NUM    =  1 ;
  parameter int pTAG_W      =  4 ;
  parameter bit pNORM_VNODE =  1 ; // 1/0 vnode noramlization coefficient is 0.875/1
  parameter bit pNORM_CNODE =  1 ; // 1/0 cnode noramlization coefficient is 0.875/1
  parameter bit pLOG_ON     =  0 ;

  `include "gsfc_ldpc_parameters.vh"

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                         iclk                     ;
  input  logic                         ireset                   ;
  input  logic                         iclkena                  ;
  //
  input  logic                 [7 : 0] iNiter                   ;
  //
  input  logic                         isop                     ;
  input  logic                         ieop                     ;
  input  logic                         ival                     ;
  input  logic          [pTAG_W-1 : 0] itag                     ;
  input  logic signed   [pLLR_W-1 : 0] iLLR    [0 : pLLR_NUM-1] ;
  //
  output logic                         obusy                    ;
  output logic                         ordy                     ;
  //
  output logic                         osop                     ;
  output logic                         oeop                     ;
  output logic                         oval                     ;
  output logic          [pTAG_W-1 : 0] otag                     ;
  output logic        [pLLR_NUM-1 : 0] odat                     ;
  //
  output logic                [15 : 0] oerr                     ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  typedef int llr_t;
  typedef int vn_t ;
  typedef int cn_t ;

  localparam int cVN_MAX = 2**31-1;

  typedef struct {
    bit   sign;   // 1/0 :: (x >= 0) ? 0 : 1
    vn_t  min1;
    vn_t  min2;
    int   min1_idx;
  } vn_min_t;

  typedef vn_t vn_row_t [2*pT];

  typedef int zline_t [pZF];

  real alpha = pNORM_CNODE ? 0.75 : 1;
  real beta  = pNORM_VNODE ? 0.75 : 1;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    do_decode_mlab();
  end

  //------------------------------------------------------------------------------------------------------
  // task to do LDPC encode using matlab like style
  //  collect all data -> decode -> pull data out
  //------------------------------------------------------------------------------------------------------

//`define __UPLOAD__

  task do_decode_mlab ();
    llr_t     llr        [pT][pZF]; // pT - H sub matrix by pZF metrics

    vn_t      vn  [pC][2][pT][pZF];

    vn_t      vn_line [2*pT];
    vn_min_t  vn_min  ;
    //
    cn_t      cn_abs;
    bit       cn_sign;
    //
    cn_t      cn_sum  [pT][pZF];
    //
    bit       decode      [pT][pZF]; // decoded bits
    int       err;

    string tstr;
    int fp;
    int mfp;
  begin
    obusy <= 1'b0;
    ordy  <= 1'b1;
    //
    oval  <= 1'b0;
    osop  <= 1'b0;
    oeop  <= 1'b0;
    odat  <= '0;
    otag  <= '0;
    //
`ifdef __UPLOAD__
    begin
    $display("upload file");
      llr =
        `include "llr_in_stream.vh"
      ;
`else
    // assemble llrs
    if (isop & ival) begin
      for (int t = 0; t < pT; t++) begin
        for (int z = 0; z < pZF; z += pLLR_NUM) begin
          for (int i = 0; i < pLLR_NUM; i++) begin
            llr[t][z + i] = -saturate_llr(iLLR[i]);
          end
          if (!ieop)
            @(posedge iclk iff ival);
        end
      end
      obusy <= 1'b1;
      ordy  <= 1'b0;
      @(posedge iclk);
`endif
      //
      if (pLOG_ON) begin
        fp = $fopen("llr_in_stream.vh", "w");
        $fdisplay(fp, "%p", llr);
        $fclose(fp);
        //
        fp  = $fopen("llr_in.log", "w");
        $display("save llr_in");
        for (int z = 0; z < pZF; z++) begin
          tstr = "";
          for (int t = 0; t < pT; t++) begin
            tstr ={tstr, $psprintf("%0.1f, ", llr[t][z])};
          end
          $fdisplay(fp, "[%0d] = %s",z, tstr);
        end
        $fclose(fp);
      end

      //------------------------------------------------------------------------------------------------------
      // decode
      //------------------------------------------------------------------------------------------------------

      // decoder initialization
      for (int c = 0; c < pC; c++) begin
        for (int w = 0; w < 2; w++) begin
          vn[c][w] = llr;
        end
      end

      if (pLOG_ON) begin
        mfp = $fopen("vn_beh.log", "w");
      end

      // decode iterations
      for (int iter = 0; iter < iNiter; iter++) begin
        if (pLOG_ON) begin
          tstr = $psprintf("vn_%0d.log", iter);
          fp = $fopen(tstr, "w");
        end

        if (pLOG_ON) begin
          $fdisplay(fp, "============================== iteration %0d ==============================", iter);
        end
        //
        // horizontal step L(r_ji) = prod(sign(vn_ij)) * min(abs(vn_ij))|(j ~= 1)
        if (pLOG_ON) begin
          $fdisplay(fp, "============================== h step ==============================");
        end
        for (int c = 0; c < pC; c++) begin
          if (pLOG_ON) begin
            $fdisplay(fp, "h step c = %0d", c);
          end
          for (int z = 0; z < pZF; z++) begin
            // 1/2 horizontal step :: read vnodes
            for (int t = 0; t < pT; t++) begin
              for (int w = 0; w < 2; w++) begin
                vn_line[2*t + w] = vn[c][w][t][(z + Hb[c][t][w]) % pZF];
              end
            end
            if (pLOG_ON) begin
              $fdisplay(fp, "vn___line[%0d][%0d] %p", c, z, vn_line);
            end
            //
            // 1/2 horizontal step :: detect min
            vn_min = vsort(vn_line); // packed cnode
            if (pLOG_ON) begin
              $fdisplay(fp, "vn____min[%0d][%0d] %p", c, z, vn_min);
            end
            //
            // 2/2 of horizontal step : do exception of (j ~= i)
            // if i == k
            //   L(r_ji) = prod(sign_ij)|(j ~= 1) * vn_min1;
            // else
            //   L(r_ji) = prod(sign_ij)|(j ~= 1) * vn_min2;
            for (int t = 0; t < pT; t++) begin
              for (int w = 0; w < 2; w++) begin
                if (vn_min.min1_idx == (2*t + w))
                  cn_abs = vn_min.min2 * alpha;
                else
                  cn_abs = vn_min.min1 * alpha;
                //
                cn_sign = (vn_line[2*t + w] < 0) ? !vn_min.sign : vn_min.sign;
                //
                vn[c][w][t][(z + Hb[c][t][w]) % pZF] = cn_sign ? -cn_abs : cn_abs;
                //
                vn_line[2*t + w] = cn_sign ? -cn_abs : cn_abs;
              end
            end
            if (pLOG_ON) begin
              $fdisplay(fp, "vn_u_line[%0d][%0d] %p\n", c, z, vn_line);
            end
          end
        end
        if (pLOG_ON) begin
          $fdisplay(mfp, "============================== h step results ==============================");
          for (int c = 0; c < pC; c++) begin
            for (int w = 0; w < pW; w++) begin
              for (int z = 0; z < pZF; z++) begin
                tstr = "";
                for (int t = 0; t < pT; t++) begin
                  tstr ={tstr, $psprintf("%0.1f, ", vn[c][w][t][z])};
                end
                $fdisplay(mfp, "vn[%0d][%0d][%0d] = %s",  c, w, z, tstr);
              end
            end
          end
        end
        //
        // vertical step
        // count aposteriory L(Qi) = L(Pi) + sum(L(rji). sum is based upon vertical connections of check nodes (column of H)
        if (pLOG_ON) begin
          $fdisplay(fp, "============================== v step ==============================");
        end
        for (int t = 0; t < pT; t++) begin
          //
          // 1/2 vertical step
          cn_sum[t] = llr[t];
          for (int z = 0; z < pZF; z++) begin
            for (int c = 0; c < pC; c++) begin
              for (int w = 0; w < 2; w++) begin
                cn_sum[t][z] += vn[c][w][t][z];
              end
            end
          end
          //
          // 2/2 vertical step
          // do hard decision
          for (int z = 0; z < pZF; z++) begin
            decode[t][z] = (cn_sum[t][z] < 0);
          end
          // update variable nodes
          // L(qij) = L(Pi) + sum(Lrij)|(i ~= j) = L(Qi) - L(rji)|(i == j)
          for (int z = 0; z < pZF; z++) begin
            for (int c = 0; c < pC; c++) begin
              int tmp;
              for (int w = 0; w < 2; w++) begin
                tmp = (cn_sum[t][z] - vn[c][w][t][z]) * beta;
                vn[c][w][t][z] = saturate_sum(tmp);
              end
            end
          end
        end

        if (pLOG_ON) begin
          for (int z = 0; z < pZF; z++) begin
            tstr = "";
            for (int t = 0; t < pT; t++) begin
              tstr ={tstr, $psprintf("%0.1f, ", cn_sum[t][z])};
            end
            $fdisplay(fp, "cn_sum [%0d] = %s",  z, tstr);
          end
        end

        if (pLOG_ON) begin
          $fdisplay(fp, "");
          for (int c = 0; c < pC; c++) begin
            for (int z = 0; z < pZF; z++) begin
              for (int w = 0; w < 2; w++) begin
                tstr = "";
                for (int t = 0; t < pT; t++) begin
                  tstr = {tstr, $psprintf("%0.1f, ", vn[c][w][t][z])};
                end
                $fdisplay(fp, "[%0d][%0d][%0d] = %s", c, w, z, tstr);
              end
            end
          end
        end

        if (pLOG_ON) begin
          $fdisplay(mfp, "============================== v step results ==============================");
          for (int c = 0; c < pC; c++) begin
            for (int w = 0; w < pW; w++) begin
              for (int z = 0; z < pZF; z++) begin
                tstr = "";
                for (int t = 0; t < pT; t++) begin
                  tstr ={tstr, $psprintf("%0.1f, ", vn[c][w][t][z])};
                end
                $fdisplay(mfp, "vn[%0d][%0d][%0d] = %s",  c, w, z, tstr);
              end
            end
          end
        end

        if (fp) $fclose(fp);
      end
      if (mfp) $fclose(mfp);
      //
      // count errors
      err = 0;
      for (int t = 0; t < pT; t++) begin
        for (int z = 0; z < pZF; z += pLLR_NUM) begin
          for (int i = 0; i < pLLR_NUM; i++) begin
            if (decode[t][z + i] != (llr[t][z + i] < 0)) begin
              err++;
            end
          end
        end
      end
      //
      // output data
      for (int t = 0; t < (pT-pC); t++) begin
        for (int z = 0; z < pZF; z += pLLR_NUM) begin
          osop <= (t == 0) & (z == 0);
          if (t == 0 & z == 0)
            oerr <= err;
          oeop <= (t == (pT-pC)-1) & (z == pZF - pLLR_NUM);
          //
          oval <= 1'b1;
          for (int i = 0; i < pLLR_NUM; i++) begin
            odat[i] <= decode[t][z + i]; // msb is first
          end
          @(posedge iclk);
          osop <= 1'b0;
          oeop <= 1'b0;
          oval <= 1'b0;
        end
      end
      obusy <= 1'b0;
      ordy  <= 1'b0;
    end
  end
  endtask

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  function automatic vn_min_t vsort (input vn_row_t data);
    vn_row_t adata;
    vn_row_t tmp;
  begin
    for (int i = 0; i < $size(data); i++) begin
      adata[i] = (data[i] < 0) ? -data[i] : data[i];
    end
    tmp = adata;
    tmp.sort;
    //
    vsort.min1 = tmp[0];
    vsort.min2 = tmp[1];
    //
    vsort.sign = 1'b0; // positive
    vsort.min1_idx = -1;
    for (int i = 0; i < $size(data); i++) begin
      vsort.sign ^= (data[i] < 0);
      if (vsort.min1_idx == -1) begin
        if (adata[i] == tmp[0])
          vsort.min1_idx = i;
      end
    end
  end
  endfunction

  function automatic bit signed [pLLR_W-1 : 0] saturate_llr (input bit signed [pLLR_W-1 : 0] dat);
    if (dat == {1'b1, {{pLLR_W-1}{1'b0}}})
      saturate_llr = {1'b1, {{pLLR_W-2}{1'b0}}, 1'b1};
    else
      saturate_llr = dat;
  endfunction

  function automatic int saturate_sum (input int dat);
    const int cMAX =  (2**(pLLR_W-1)-1);
    const int cMIN = -(2**(pLLR_W-1));
  begin
    if (dat > cMAX)
      return cMAX;
    else if (dat < cMIN)
      return cMIN;
    else
      return dat;
  end
  endfunction

endmodule

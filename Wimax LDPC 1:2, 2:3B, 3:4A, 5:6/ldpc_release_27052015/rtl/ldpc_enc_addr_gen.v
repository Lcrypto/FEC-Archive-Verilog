/*

  parameter int pCODE      =   1 ;
  parameter int pN         = 576 ;
  parameter int pDAT_W     =   4 ;
  parameter bit pUSE_CMASK =   0 ;


  logic                 ldpc_enc_addr_gen__iclk            ;
  logic                 ldpc_enc_addr_gen__ireset          ;
  logic                 ldpc_enc_addr_gen__iclkena         ;
  logic                 ldpc_enc_addr_gen__iclear          ;
  logic                 ldpc_enc_addr_gen__ienable         ;
  logic [cBASE_W-1 : 0] ldpc_enc_addr_gen__obitena    [pC] ;
  logic [cBASE_W-1 : 0] ldpc_enc_addr_gen__obitsel    [pC] ;
  logic   [cBS_W-1 : 0] ldpc_enc_addr_gen__obitshift  [pC] ;



  ldpc_enc_addr_gen
  #(
    .pCODE      ( pCODE      ) ,
    .pN         ( pN         ) ,
    .pDAT_W     ( pDAT_W     ) ,
    .pUSE_CMASK ( pUSE_CMASK )
  )
  ldpc_enc_addr_gen
  (
    .iclk       ( ldpc_enc_addr_gen__iclk       ) ,
    .ireset     ( ldpc_enc_addr_gen__ireset     ) ,
    .iclkena    ( ldpc_enc_addr_gen__iclkena    ) ,
    .iclear     ( ldpc_enc_addr_gen__iclear     ) ,
    .ienable    ( ldpc_enc_addr_gen__ienable    ) ,
    .obitena    ( ldpc_enc_addr_gen__obitena    ) ,
    .obitsel    ( ldpc_enc_addr_gen__obitsel    ) ,
    .obitshift  ( ldpc_enc_addr_gen__obitshift  )
  );


  assign ldpc_enc_addr_gen__iclk    = '0 ;
  assign ldpc_enc_addr_gen__ireset  = '0 ;
  assign ldpc_enc_addr_gen__iclkena = '0 ;
  assign ldpc_enc_addr_gen__iclear  = '0 ;
  assign ldpc_enc_addr_gen__ienable = '0 ;



*/

//
// Project       : ldpc
// Author        : Shekhalev Denis (des00)
// Workfile      : ldpc_enc_addr_gen.v
// Description   : LDPC encoder address generator. Generate control signal for special memory to do matrix multiplication.
//

`include "define.vh"

module ldpc_enc_addr_gen
(
  iclk       ,
  ireset     ,
  iclkena    ,
  //
  iclear     ,
  ienable    ,
  //
  obitena    ,
  obitsel    ,
  obitshift
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  `include "ldpc_parameters.vh"

  parameter int pDAT_W      = 4;                // 2^N bits granularity of encoder word
  parameter bit pUSE_CMASK  = 0;                // use complex mask counting function (use less resources)

  localparam int cBS_W      = clogb2(pDAT_W);   // bitshift width

  localparam int cBASE      = pZF/pDAT_W;       // number of addresses inside acu ram
  localparam int cADDR_W    = clogb2(cBASE);    // circshift(Hb[i]) address

  localparam int cCADDR_W   = clogb2(pT-pC+1);  // Hb matrix column address

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic               iclk            ;
  input  logic               ireset          ;
  input  logic               iclkena         ;
  //
  input  logic               iclear          ;
  input  logic               ienable         ;
  //
  output logic [cBASE-1 : 0] obitena     [pC]; // disable word update
  output logic [cBASE-1 : 0] obitsel     [pC]; // select word source
  output logic [cBS_W-1 : 0] obitshift   [pC]; // value of offset reg

  //------------------------------------------------------------------------------------------------------
  // count base addreses table
  //------------------------------------------------------------------------------------------------------

  typedef logic [cADDR_W-1 : 0] dat_t;
  typedef logic   [cADDR_W : 0] dat_p1_t;
  typedef logic   [cBS_W-1 : 0] shift_t;

  typedef struct packed {
    dat_t   addr;
    shift_t shift;
  } mHb_dat_t;

  typedef mHb_dat_t mHb_t [pC][pT];

  mHb_t mHb_tab;
  mHb_t addr_high_tab;

  assign mHb_tab        = get_mHb_tab  (0);
  assign addr_high_tab  = get_high_tab (0);

  //------------------------------------------------------------------------------------------------------
  // functions to count tables
  //------------------------------------------------------------------------------------------------------

  function automatic mHb_t get_mHb_tab (input bit nul);
    for (int i = 0; i < pC; i++) begin
      for (int j = 0; j < pT; j++) begin
        get_mHb_tab[i][j] = '0;
        if (Hb[i][j] >= 0) begin
          get_mHb_tab[i][j].shift = Hb[i][j] % pDAT_W;
          get_mHb_tab[i][j].addr  = cBASE - ((Hb[i][j]/pDAT_W) % cBASE);
        end
      end
    end
  endfunction

  function automatic mHb_t get_high_tab (input bit nul);
    for (int i = 0; i < pC; i++) begin
      for (int j = 0; j < pT; j++) begin
        get_high_tab[i][j] = '0;
        if (Hb[i][j] >= 0) begin
          get_high_tab[i][j].shift = Hb[i][j] % pDAT_W;
          get_high_tab[i][j].addr  = (cBASE - ((Hb[i][j]/pDAT_W) % cBASE)) % cBASE;
        end
      end
    end
  endfunction

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic  [cADDR_W-1 : 0] baddr;
  logic                  baddr_done;
  logic                  baddr_zero;
  logic [cCADDR_W-1 : 0] caddr;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      if (iclear) begin
        baddr       <= 1'b1;
        baddr_done  <= '0;
        baddr_zero  <= '0;
        caddr       <= '0;
        //
        for (int i = 0; i < pC; i++) begin
          obitshift [i] <= addr_high_tab[i][0].shift;
          if (pUSE_CMASK)
            {obitena[i], obitsel[i]} <= get_bitmask (Hb[i][0][31], mHb_tab[i][0].addr, 0, cBASE);
          else
            {obitena[i], obitsel[i]} <= get_bitmask2(Hb[i][0][31], addr_high_tab[i][0].addr);
        end
      end
      else if (ienable) begin
        baddr       <= baddr_done ? '0 : (baddr + 1'b1);
        baddr_done  <= (baddr == cBASE-2);
        baddr_zero  <= baddr_done;
        caddr       <= caddr + baddr_done;
        for (int i = 0; i < pC; i++) begin
          obitshift  [i] <= addr_high_tab[i][caddr].shift;
          if (pUSE_CMASK)
            {obitena[i], obitsel[i]} <= get_bitmask(Hb[i][caddr][31], mHb_tab[i][caddr].addr, baddr, cBASE);
          else begin
            if (baddr_zero) begin
              {obitena[i], obitsel[i]} <= get_bitmask2(Hb[i][caddr][31], addr_high_tab[i][caddr].addr);
            end
            else begin
              obitena[i] <= {obitena[i][cBASE-2 : 0], obitena[i][cBASE-1]};
              obitsel[i] <= {obitsel[i][cBASE-2 : 0], obitsel[i][cBASE-1]};
            end
          end // pUSE_CMASK
        end // [pC]
      end // ienable
    end // iclkena
  end

  //------------------------------------------------------------------------------------------------------
  // functions to get bitmask
  //------------------------------------------------------------------------------------------------------

  function logic [2*cBASE-1 : 0] get_bitmask (input logic sign, input dat_t acc, incr, mod);
    logic [cADDR_W-1 : 0] addr_high;
    logic   [cBASE-1 : 0] bitclr;
    logic   [cBASE-1 : 0] bitsel;
  begin
    bitclr = '1;
    bitsel = '0;

    addr_high   = get_mod(acc, incr, mod);

    bitclr[addr_high] = sign;
    bitsel[addr_high] = 1'b1;

    bitclr[(addr_high == 0) ? (cBASE-1) : (addr_high-1)] = sign;
    //
    get_bitmask = {~bitclr, bitsel};
  end
  endfunction

  function logic [2*cBASE-1 : 0] get_bitmask2 (input logic sign, input dat_t addr_high);
    logic [cBASE-1 : 0] bitclr;
    logic [cBASE-1 : 0] bitsel;
  begin
    bitclr = '1;
    bitsel = '0;

    bitclr[addr_high] = sign;
    bitsel[addr_high] = 1'b1;

    bitclr[(addr_high == 0) ? (cBASE-1) : (addr_high-1)] = sign;
    //
    get_bitmask2 = {~bitclr, bitsel};
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  // synthesable mod(a,b) function
  //------------------------------------------------------------------------------------------------------

  function dat_t get_mod (input dat_t acc, incr, mod);
    dat_p1_t  acc_next;
    dat_p1_t  acc_next_mod;
    logic     acc_next_eq;
  begin
    acc_next     = acc + incr;
    acc_next_mod = acc_next - mod;
    get_mod      = acc_next_mod[cADDR_W] ? acc_next[cADDR_W-1 : 0] : acc_next_mod[cADDR_W-1 : 0];
  end
  endfunction

endmodule

//
// Project       : bch
// Author        : Shekhalev Denis (des00)
// Revision      : $Revision: 14481 $
// Date          : $Date$
// Workfile      : rs_functions.vh
// Description   :
//

  `include "gf_functions.vh"

  //------------------------------------------------------------------------------------------------------
  // code generator poly
  //  NOTE :: порядок корней генераторного полинома инверсный, т.е.
  //    [check..0] = x^0..x^check. Это нужно учитывать при разработке кодера
  //------------------------------------------------------------------------------------------------------

  function automatic gpoly_t generate_pol_coeficients (input uint_t genstart, rootspace, lcheck, input rom_t index_of, alpha_to);
    data_t  gg    [0 : check];
    data_t  ggmul [0 : check];
    uint_t  alpha;
    uint_t  alpha_step;
  begin
    lcheck = (lcheck < 2) ? 2 : lcheck;
    // initialization
    alpha_step = alpha_to[rootspace];

    gg[0] = 1;
    gg[1] = alpha_to[(genstart*rootspace) % gf_n_max];
    for (int i = 2; i <= check; i++) gg [i] = 0;

    alpha = alpha_to[((genstart + 1)*rootspace) % gf_n_max];

    for (int j = 0; j <= lcheck-2; j++) begin
      for (int p = 1; p <= j+2; p++)
        //ggmul[p] = gf_mul(gg[p-1], alpha, index_of, alpha_to);
        ggmul[p] = gf_mult_a_by_b(gg[p-1], alpha);

      for (int p = 1; p <= j+2; p++)
        //gg[p] = gf_add(gg[p], ggmul[p]);
        gg[p] = gg[p] ^ ggmul[p];

      //alpha = gf_mul(alpha, alpha_step, index_of, alpha_to);
      alpha = gf_mult_a_by_b(alpha, alpha_step);
    end
    generate_pol_coeficients = gg;
  end
  endfunction

  function automatic gpoly_t clear_gpoly (input data_t val = 0);
    for (int i = 0; i < $size(clear_gpoly); i++) begin
      clear_gpoly[i] = val;
    end
  endfunction



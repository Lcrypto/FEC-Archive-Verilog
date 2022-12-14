`ifndef __DEFINE_VH__

  `define __DEFINE_VH__

  //------------------------------------------------------------------------------------------------------
  // useful function's
  //------------------------------------------------------------------------------------------------------

  //
  // function to count logarithm for parameters
  //

  function automatic int clogb2 (input int data);
    int i;
    clogb2 = 0;
    if (data > 0) begin
      for (i = 0; 2**i < data; i++)
        clogb2 = i + 1;
    end
  endfunction


  function automatic int max (input int a,b );
    if (a >=b )
      max = a;
    else
      max = b;
  endfunction


  function automatic int min (input int a,b );
    if (a <=b )
      min = a;
    else
      min = b;
  endfunction

  function automatic int abs (input int a);
    abs = (a < 0) ? -a : a;
  endfunction

`endif

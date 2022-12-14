//
// Project       : c4D-8PSK TCM
// Author        : Shekhalev Denis (des00)
// Workfile      : types.vh
// Description   : 4D-8PSK TCM codec data packet class
//

  class pkt_class;

    bit       [1 : 0] code;
    rand bit [10 : 0] dat [];

    function new (int n, int code = 0);
      dat = new [n];
      this.code = code;
    endfunction : new

    constraint data_range
    {
      if (code == 0)
        foreach ( dat[i] ) dat[i][10: 8] == 0;
      else if (code == 1)
        foreach ( dat[i] ) dat[i][10: 9] == 0;
      else if (code == 2)
        foreach ( dat[i] ) dat[i][10:10] == 0;
    }

    function int do_compare (pkt_class rdat);
      bit [10 : 0] biterr;
      int err;
    begin
      assert (rdat.dat.size() == dat.size()) else begin
        $error("data array size compare mismatch");
        return dat.size();
      end
      err = 0;
      for (int i = 0; i < $size(dat); i++) begin
        biterr = (dat[i] ^ rdat.dat[i]);
        //
        err += sum(biterr);
      end
      return err;
    end
    endfunction

    function int sum (input bit [10 : 0] biterr);
      sum = 0;
      for (int i = 0; i < 11; i++) begin
        sum += biterr[i];
      end
    endfunction

  endclass


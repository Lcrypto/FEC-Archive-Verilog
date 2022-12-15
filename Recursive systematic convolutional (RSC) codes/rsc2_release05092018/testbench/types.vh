//
// Project       : rsc
// Author        : Shekhalev Denis (des00)
// Workfile      : types.vh
// Description   : RSC codec data duobit packet class
//

  class pkt_class;
    rand bit [1 : 0] dat [];

    function new (int n);
      dat = new [n];
    endfunction : new

    function int do_compare (pkt_class rdat);
      int err;
    begin
      assert (rdat.dat.size() == dat.size()) else begin
        $error("data array size compare mismatch");
        return dat.size();
      end
      err = 0;
      for (int i = 0; i < $size(dat); i++) begin
        err += (dat[i][0] != rdat.dat[i][0]);
        err += (dat[i][1] != rdat.dat[i][1]);
      end
      return err;
    end
    endfunction

  endclass


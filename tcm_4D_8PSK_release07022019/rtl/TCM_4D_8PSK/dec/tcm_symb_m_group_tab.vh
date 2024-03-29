//
// Project       : 4D-8PSK TCM
// Author        : Shekhalev Denis (des00)
// Workfile      : tcm_symb_m_group_tab.v
// Description   : 4D 8PSK symbol metric mapping table
//
//

  localparam bit [1 : 0] cSM_IDX_275_TAB [16][16][4] =
  '{
    '{// BM0000
      '{0, 0, 0, 0}, // C0 + C0 + C0 + C0
      '{0, 2, 2, 0}, // C0 + C2 + C2 + C0
      '{2, 2, 0, 0}, // C2 + C2 + C0 + C0
      '{2, 0, 2, 0}, // C2 + C0 + C2 + C0
      '{1, 1, 1, 1}, // C1 + C1 + C1 + C1
      '{1, 3, 3, 1}, // C1 + C3 + C3 + C1
      '{3, 3, 1, 1}, // C3 + C3 + C1 + C1
      '{3, 1, 3, 1}, // C3 + C1 + C3 + C1
      '{0, 0, 2, 2}, // C0 + C0 + C2 + C2
      '{0, 2, 0, 2}, // C0 + C2 + C0 + C2
      '{2, 2, 2, 2}, // C2 + C2 + C2 + C2
      '{2, 0, 0, 2}, // C2 + C0 + C0 + C2
      '{1, 1, 3, 3}, // C1 + C1 + C3 + C3
      '{1, 3, 1, 3}, // C1 + C3 + C1 + C3
      '{3, 3, 3, 3}, // C3 + C3 + C3 + C3
      '{3, 1, 1, 3}  // C3 + C1 + C1 + C3
    },
    '{// BM0001
      '{1, 1, 3, 0}, // C1 + C1 + C3 + C0
      '{1, 3, 1, 0}, // C1 + C3 + C1 + C0
      '{3, 3, 3, 0}, // C3 + C3 + C3 + C0
      '{3, 1, 1, 0}, // C3 + C1 + C1 + C0
      '{0, 0, 0, 1}, // C0 + C0 + C0 + C1
      '{0, 2, 2, 1}, // C0 + C2 + C2 + C1
      '{2, 2, 0, 1}, // C2 + C2 + C0 + C1
      '{2, 0, 2, 1}, // C2 + C0 + C2 + C1
      '{1, 1, 1, 2}, // C1 + C1 + C1 + C2
      '{1, 3, 3, 2}, // C1 + C3 + C3 + C2
      '{3, 3, 1, 2}, // C3 + C3 + C1 + C2
      '{3, 1, 3, 2}, // C3 + C1 + C3 + C2
      '{0, 0, 2, 3}, // C0 + C0 + C2 + C3
      '{0, 2, 0, 3}, // C0 + C2 + C0 + C3
      '{2, 2, 2, 3}, // C2 + C2 + C2 + C3
      '{2, 0, 0, 3}  // C2 + C0 + C0 + C3
    },
    '{// BM0010
      '{1, 1, 0, 0}, // C1 + C1 + C0 + C0
      '{1, 3, 2, 0}, // C1 + C3 + C2 + C0
      '{3, 3, 0, 0}, // C3 + C3 + C0 + C0
      '{3, 1, 2, 0}, // C3 + C1 + C2 + C0
      '{0, 0, 1, 1}, // C0 + C0 + C1 + C1
      '{0, 2, 3, 1}, // C0 + C2 + C3 + C1
      '{2, 2, 1, 1}, // C2 + C2 + C1 + C1
      '{2, 0, 3, 1}, // C2 + C0 + C3 + C1
      '{1, 1, 2, 2}, // C1 + C1 + C2 + C2
      '{1, 3, 0, 2}, // C1 + C3 + C0 + C2
      '{3, 3, 2, 2}, // C3 + C3 + C2 + C2
      '{3, 1, 0, 2}, // C3 + C1 + C0 + C2
      '{0, 0, 3, 3}, // C0 + C0 + C3 + C3
      '{0, 2, 1, 3}, // C0 + C2 + C1 + C3
      '{2, 2, 3, 3}, // C2 + C2 + C3 + C3
      '{2, 0, 1, 3}  // C2 + C0 + C1 + C3
    },
    '{// BM0011
      '{0, 0, 3, 0}, // C0 + C0 + C3 + C0
      '{0, 2, 1, 0}, // C0 + C2 + C1 + C0
      '{2, 2, 3, 0}, // C2 + C2 + C3 + C0
      '{2, 0, 1, 0}, // C2 + C0 + C1 + C0
      '{1, 1, 0, 1}, // C1 + C1 + C0 + C1
      '{1, 3, 2, 1}, // C1 + C3 + C2 + C1
      '{3, 3, 0, 1}, // C3 + C3 + C0 + C1
      '{3, 1, 2, 1}, // C3 + C1 + C2 + C1
      '{0, 0, 1, 2}, // C0 + C0 + C1 + C2
      '{0, 2, 3, 2}, // C0 + C2 + C3 + C2
      '{2, 2, 1, 2}, // C2 + C2 + C1 + C2
      '{2, 0, 3, 2}, // C2 + C0 + C3 + C2
      '{1, 1, 2, 3}, // C1 + C1 + C2 + C3
      '{1, 3, 0, 3}, // C1 + C3 + C0 + C3
      '{3, 3, 2, 3}, // C3 + C3 + C2 + C3
      '{3, 1, 0, 3}  // C3 + C1 + C0 + C3
    },
    '{// BM0100
      '{1, 2, 3, 0}, // C1 + C2 + C3 + C0
      '{1, 0, 1, 0}, // C1 + C0 + C1 + C0
      '{3, 0, 3, 0}, // C3 + C0 + C3 + C0
      '{3, 2, 1, 0}, // C3 + C2 + C1 + C0
      '{0, 1, 0, 1}, // C0 + C1 + C0 + C1
      '{0, 3, 2, 1}, // C0 + C3 + C2 + C1
      '{2, 3, 0, 1}, // C2 + C3 + C0 + C1
      '{2, 1, 2, 1}, // C2 + C1 + C2 + C1
      '{1, 2, 1, 2}, // C1 + C2 + C1 + C2
      '{1, 0, 3, 2}, // C1 + C0 + C3 + C2
      '{3, 0, 1, 2}, // C3 + C0 + C1 + C2
      '{3, 2, 3, 2}, // C3 + C2 + C3 + C2
      '{0, 1, 2, 3}, // C0 + C1 + C2 + C3
      '{0, 3, 0, 3}, // C0 + C3 + C0 + C3
      '{2, 3, 2, 3}, // C2 + C3 + C2 + C3
      '{2, 1, 0, 3}  // C2 + C1 + C0 + C3
    },
    '{// BM0101
      '{0, 1, 2, 0}, // C0 + C1 + C2 + C0
      '{0, 3, 0, 0}, // C0 + C3 + C0 + C0
      '{2, 3, 2, 0}, // C2 + C3 + C2 + C0
      '{2, 1, 0, 0}, // C2 + C1 + C0 + C0
      '{1, 2, 3, 1}, // C1 + C2 + C3 + C1
      '{1, 0, 1, 1}, // C1 + C0 + C1 + C1
      '{3, 0, 3, 1}, // C3 + C0 + C3 + C1
      '{3, 2, 1, 1}, // C3 + C2 + C1 + C1
      '{0, 1, 0, 2}, // C0 + C1 + C0 + C2
      '{0, 3, 2, 2}, // C0 + C3 + C2 + C2
      '{2, 3, 0, 2}, // C2 + C3 + C0 + C2
      '{2, 1, 2, 2}, // C2 + C1 + C2 + C2
      '{1, 2, 1, 3}, // C1 + C2 + C1 + C3
      '{1, 0, 3, 3}, // C1 + C0 + C3 + C3
      '{3, 0, 1, 3}, // C3 + C0 + C1 + C3
      '{3, 2, 3, 3}  // C3 + C2 + C3 + C3
    },
    '{// BM0110
      '{0, 1, 3, 0}, // C0 + C1 + C3 + C0
      '{0, 3, 1, 0}, // C0 + C3 + C1 + C0
      '{2, 3, 3, 0}, // C2 + C3 + C3 + C0
      '{2, 1, 1, 0}, // C2 + C1 + C1 + C0
      '{1, 2, 0, 1}, // C1 + C2 + C0 + C1
      '{1, 0, 2, 1}, // C1 + C0 + C2 + C1
      '{3, 0, 0, 1}, // C3 + C0 + C0 + C1
      '{3, 2, 2, 1}, // C3 + C2 + C2 + C1
      '{0, 1, 1, 2}, // C0 + C1 + C1 + C2
      '{0, 3, 3, 2}, // C0 + C3 + C3 + C2
      '{2, 3, 1, 2}, // C2 + C3 + C1 + C2
      '{2, 1, 3, 2}, // C2 + C1 + C3 + C2
      '{1, 2, 2, 3}, // C1 + C2 + C2 + C3
      '{1, 0, 0, 3}, // C1 + C0 + C0 + C3
      '{3, 0, 2, 3}, // C3 + C0 + C2 + C3
      '{3, 2, 0, 3}  // C3 + C2 + C0 + C3
    },
    '{// BM0111
      '{1, 2, 2, 0}, // C1 + C2 + C2 + C0
      '{1, 0, 0, 0}, // C1 + C0 + C0 + C0
      '{3, 0, 2, 0}, // C3 + C0 + C2 + C0
      '{3, 2, 0, 0}, // C3 + C2 + C0 + C0
      '{0, 1, 3, 1}, // C0 + C1 + C3 + C1
      '{0, 3, 1, 1}, // C0 + C3 + C1 + C1
      '{2, 3, 3, 1}, // C2 + C3 + C3 + C1
      '{2, 1, 1, 1}, // C2 + C1 + C1 + C1
      '{1, 2, 0, 2}, // C1 + C2 + C0 + C2
      '{1, 0, 2, 2}, // C1 + C0 + C2 + C2
      '{3, 0, 0, 2}, // C3 + C0 + C0 + C2
      '{3, 2, 2, 2}, // C3 + C2 + C2 + C2
      '{0, 1, 1, 3}, // C0 + C1 + C1 + C3
      '{0, 3, 3, 3}, // C0 + C3 + C3 + C3
      '{2, 3, 1, 3}, // C2 + C3 + C1 + C3
      '{2, 1, 3, 3}  // C2 + C1 + C3 + C3
    },
    '{// BM1000
      '{0, 0, 2, 0}, // C0 + C0 + C2 + C0
      '{0, 2, 0, 0}, // C0 + C2 + C0 + C0
      '{2, 2, 2, 0}, // C2 + C2 + C2 + C0
      '{2, 0, 0, 0}, // C2 + C0 + C0 + C0
      '{1, 1, 3, 1}, // C1 + C1 + C3 + C1
      '{1, 3, 1, 1}, // C1 + C3 + C1 + C1
      '{3, 3, 3, 1}, // C3 + C3 + C3 + C1
      '{3, 1, 1, 1}, // C3 + C1 + C1 + C1
      '{0, 0, 0, 2}, // C0 + C0 + C0 + C2
      '{0, 2, 2, 2}, // C0 + C2 + C2 + C2
      '{2, 2, 0, 2}, // C2 + C2 + C0 + C2
      '{2, 0, 2, 2}, // C2 + C0 + C2 + C2
      '{1, 1, 1, 3}, // C1 + C1 + C1 + C3
      '{1, 3, 3, 3}, // C1 + C3 + C3 + C3
      '{3, 3, 1, 3}, // C3 + C3 + C1 + C3
      '{3, 1, 3, 3}  // C3 + C1 + C3 + C3
    },
    '{// BM1001
      '{1, 1, 1, 0}, // C1 + C1 + C1 + C0
      '{1, 3, 3, 0}, // C1 + C3 + C3 + C0
      '{3, 3, 1, 0}, // C3 + C3 + C1 + C0
      '{3, 1, 3, 0}, // C3 + C1 + C3 + C0
      '{0, 0, 2, 1}, // C0 + C0 + C2 + C1
      '{0, 2, 0, 1}, // C0 + C2 + C0 + C1
      '{2, 2, 2, 1}, // C2 + C2 + C2 + C1
      '{2, 0, 0, 1}, // C2 + C0 + C0 + C1
      '{1, 1, 3, 2}, // C1 + C1 + C3 + C2
      '{1, 3, 1, 2}, // C1 + C3 + C1 + C2
      '{3, 3, 3, 2}, // C3 + C3 + C3 + C2
      '{3, 1, 1, 2}, // C3 + C1 + C1 + C2
      '{0, 0, 0, 3}, // C0 + C0 + C0 + C3
      '{0, 2, 2, 3}, // C0 + C2 + C2 + C3
      '{2, 2, 0, 3}, // C2 + C2 + C0 + C3
      '{2, 0, 2, 3}  // C2 + C0 + C2 + C3
    },
    '{// BM1010
      '{1, 1, 2, 0}, // C1 + C1 + C2 + C0
      '{1, 3, 0, 0}, // C1 + C3 + C0 + C0
      '{3, 3, 2, 0}, // C3 + C3 + C2 + C0
      '{3, 1, 0, 0}, // C3 + C1 + C0 + C0
      '{0, 0, 3, 1}, // C0 + C0 + C3 + C1
      '{0, 2, 1, 1}, // C0 + C2 + C1 + C1
      '{2, 2, 3, 1}, // C2 + C2 + C3 + C1
      '{2, 0, 1, 1}, // C2 + C0 + C1 + C1
      '{1, 1, 0, 2}, // C1 + C1 + C0 + C2
      '{1, 3, 2, 2}, // C1 + C3 + C2 + C2
      '{3, 3, 0, 2}, // C3 + C3 + C0 + C2
      '{3, 1, 2, 2}, // C3 + C1 + C2 + C2
      '{0, 0, 1, 3}, // C0 + C0 + C1 + C3
      '{0, 2, 3, 3}, // C0 + C2 + C3 + C3
      '{2, 2, 1, 3}, // C2 + C2 + C1 + C3
      '{2, 0, 3, 3}  // C2 + C0 + C3 + C3
    },
    '{// BM1011
      '{0, 0, 1, 0}, // C0 + C0 + C1 + C0
      '{0, 2, 3, 0}, // C0 + C2 + C3 + C0
      '{2, 2, 1, 0}, // C2 + C2 + C1 + C0
      '{2, 0, 3, 0}, // C2 + C0 + C3 + C0
      '{1, 1, 2, 1}, // C1 + C1 + C2 + C1
      '{1, 3, 0, 1}, // C1 + C3 + C0 + C1
      '{3, 3, 2, 1}, // C3 + C3 + C2 + C1
      '{3, 1, 0, 1}, // C3 + C1 + C0 + C1
      '{0, 0, 3, 2}, // C0 + C0 + C3 + C2
      '{0, 2, 1, 2}, // C0 + C2 + C1 + C2
      '{2, 2, 3, 2}, // C2 + C2 + C3 + C2
      '{2, 0, 1, 2}, // C2 + C0 + C1 + C2
      '{1, 1, 0, 3}, // C1 + C1 + C0 + C3
      '{1, 3, 2, 3}, // C1 + C3 + C2 + C3
      '{3, 3, 0, 3}, // C3 + C3 + C0 + C3
      '{3, 1, 2, 3}  // C3 + C1 + C2 + C3
    },
    '{// BM1100
      '{1, 2, 1, 0}, // C1 + C2 + C1 + C0
      '{1, 0, 3, 0}, // C1 + C0 + C3 + C0
      '{3, 0, 1, 0}, // C3 + C0 + C1 + C0
      '{3, 2, 3, 0}, // C3 + C2 + C3 + C0
      '{0, 1, 2, 1}, // C0 + C1 + C2 + C1
      '{0, 3, 0, 1}, // C0 + C3 + C0 + C1
      '{2, 3, 2, 1}, // C2 + C3 + C2 + C1
      '{2, 1, 0, 1}, // C2 + C1 + C0 + C1
      '{1, 2, 3, 2}, // C1 + C2 + C3 + C2
      '{1, 0, 1, 2}, // C1 + C0 + C1 + C2
      '{3, 0, 3, 2}, // C3 + C0 + C3 + C2
      '{3, 2, 1, 2}, // C3 + C2 + C1 + C2
      '{0, 1, 0, 3}, // C0 + C1 + C0 + C3
      '{0, 3, 2, 3}, // C0 + C3 + C2 + C3
      '{2, 3, 0, 3}, // C2 + C3 + C0 + C3
      '{2, 1, 2, 3}  // C2 + C1 + C2 + C3
    },
    '{// BM1101
      '{0, 1, 0, 0}, // C0 + C1 + C0 + C0
      '{0, 3, 2, 0}, // C0 + C3 + C2 + C0
      '{2, 3, 0, 0}, // C2 + C3 + C0 + C0
      '{2, 1, 2, 0}, // C2 + C1 + C2 + C0
      '{1, 2, 1, 1}, // C1 + C2 + C1 + C1
      '{1, 0, 3, 1}, // C1 + C0 + C3 + C1
      '{3, 0, 1, 1}, // C3 + C0 + C1 + C1
      '{3, 2, 3, 1}, // C3 + C2 + C3 + C1
      '{0, 1, 2, 2}, // C0 + C1 + C2 + C2
      '{0, 3, 0, 2}, // C0 + C3 + C0 + C2
      '{2, 3, 2, 2}, // C2 + C3 + C2 + C2
      '{2, 1, 0, 2}, // C2 + C1 + C0 + C2
      '{1, 2, 3, 3}, // C1 + C2 + C3 + C3
      '{1, 0, 1, 3}, // C1 + C0 + C1 + C3
      '{3, 0, 3, 3}, // C3 + C0 + C3 + C3
      '{3, 2, 1, 3}  // C3 + C2 + C1 + C3
    },
    '{// BM1110
      '{0, 1, 1, 0}, // C0 + C1 + C1 + C0
      '{0, 3, 3, 0}, // C0 + C3 + C3 + C0
      '{2, 3, 1, 0}, // C2 + C3 + C1 + C0
      '{2, 1, 3, 0}, // C2 + C1 + C3 + C0
      '{1, 2, 2, 1}, // C1 + C2 + C2 + C1
      '{1, 0, 0, 1}, // C1 + C0 + C0 + C1
      '{3, 0, 2, 1}, // C3 + C0 + C2 + C1
      '{3, 2, 0, 1}, // C3 + C2 + C0 + C1
      '{0, 1, 3, 2}, // C0 + C1 + C3 + C2
      '{0, 3, 1, 2}, // C0 + C3 + C1 + C2
      '{2, 3, 3, 2}, // C2 + C3 + C3 + C2
      '{2, 1, 1, 2}, // C2 + C1 + C1 + C2
      '{1, 2, 0, 3}, // C1 + C2 + C0 + C3
      '{1, 0, 2, 3}, // C1 + C0 + C2 + C3
      '{3, 0, 0, 3}, // C3 + C0 + C0 + C3
      '{3, 2, 2, 3}  // C3 + C2 + C2 + C3
    },
    '{// BM1111
      '{1, 2, 0, 0}, // C1 + C2 + C0 + C0
      '{1, 0, 2, 0}, // C1 + C0 + C2 + C0
      '{3, 0, 0, 0}, // C3 + C0 + C0 + C0
      '{3, 2, 2, 0}, // C3 + C2 + C2 + C0
      '{0, 1, 1, 1}, // C0 + C1 + C1 + C1
      '{0, 3, 3, 1}, // C0 + C3 + C3 + C1
      '{2, 3, 1, 1}, // C2 + C3 + C1 + C1
      '{2, 1, 3, 1}, // C2 + C1 + C3 + C1
      '{1, 2, 2, 2}, // C1 + C2 + C2 + C2
      '{1, 0, 0, 2}, // C1 + C0 + C0 + C2
      '{3, 0, 2, 2}, // C3 + C0 + C2 + C2
      '{3, 2, 0, 2}, // C3 + C2 + C0 + C2
      '{0, 1, 3, 3}, // C0 + C1 + C3 + C3
      '{0, 3, 1, 3}, // C0 + C3 + C1 + C3
      '{2, 3, 3, 3}, // C2 + C3 + C3 + C3
      '{2, 1, 1, 3}  // C2 + C1 + C1 + C3
    }
  };

  localparam bit [1 : 0] cSM_IDX_250_TAB [16][8][4] =
  '{
    '{// BM0000
      '{0, 0, 0, 0}, // C0 + C0 + C0 + C0
      '{0, 2, 2, 0}, // C0 + C2 + C2 + C0
      '{2, 2, 0, 0}, // C2 + C2 + C0 + C0
      '{2, 0, 2, 0}, // C2 + C0 + C2 + C0
      '{0, 0, 2, 2}, // C0 + C0 + C2 + C2
      '{0, 2, 0, 2}, // C0 + C2 + C0 + C2
      '{2, 2, 2, 2}, // C2 + C2 + C2 + C2
      '{2, 0, 0, 2}  // C2 + C0 + C0 + C2
    },
    '{// BM0001
      '{0, 0, 1, 1}, // C0 + C0 + C1 + C1
      '{0, 2, 3, 1}, // C0 + C2 + C3 + C1
      '{2, 2, 1, 1}, // C2 + C2 + C1 + C1
      '{2, 0, 3, 1}, // C2 + C0 + C3 + C1
      '{0, 0, 3, 3}, // C0 + C0 + C3 + C3
      '{0, 2, 1, 3}, // C0 + C2 + C1 + C3
      '{2, 2, 3, 3}, // C2 + C2 + C3 + C3
      '{2, 0, 1, 3}  // C2 + C0 + C1 + C3
    },
    '{// BM0010
      '{0, 1, 0, 1}, // C0 + C1 + C0 + C1
      '{0, 3, 2, 1}, // C0 + C3 + C2 + C1
      '{2, 3, 0, 1}, // C2 + C3 + C0 + C1
      '{2, 1, 2, 1}, // C2 + C1 + C2 + C1
      '{0, 1, 2, 3}, // C0 + C1 + C2 + C3
      '{0, 3, 0, 3}, // C0 + C3 + C0 + C3
      '{2, 3, 2, 3}, // C2 + C3 + C2 + C3
      '{2, 1, 0, 3}  // C2 + C1 + C0 + C3
    },
    '{// BM0011
      '{0, 1, 3, 0}, // C0 + C1 + C3 + C0
      '{0, 3, 1, 0}, // C0 + C3 + C1 + C0
      '{2, 3, 3, 0}, // C2 + C3 + C3 + C0
      '{2, 1, 1, 0}, // C2 + C1 + C1 + C0
      '{0, 1, 1, 2}, // C0 + C1 + C1 + C2
      '{0, 3, 3, 2}, // C0 + C3 + C3 + C2
      '{2, 3, 1, 2}, // C2 + C3 + C1 + C2
      '{2, 1, 3, 2}  // C2 + C1 + C3 + C2
    },
    '{// BM0100
      '{0, 0, 2, 0}, // C0 + C0 + C2 + C0
      '{0, 2, 0, 0}, // C0 + C2 + C0 + C0
      '{2, 2, 2, 0}, // C2 + C2 + C2 + C0
      '{2, 0, 0, 0}, // C2 + C0 + C0 + C0
      '{0, 0, 0, 2}, // C0 + C0 + C0 + C2
      '{0, 2, 2, 2}, // C0 + C2 + C2 + C2
      '{2, 2, 0, 2}, // C2 + C2 + C0 + C2
      '{2, 0, 2, 2}  // C2 + C0 + C2 + C2
    },
    '{// BM0101
      '{0, 0, 3, 1}, // C0 + C0 + C3 + C1
      '{0, 2, 1, 1}, // C0 + C2 + C1 + C1
      '{2, 2, 3, 1}, // C2 + C2 + C3 + C1
      '{2, 0, 1, 1}, // C2 + C0 + C1 + C1
      '{0, 0, 1, 3}, // C0 + C0 + C1 + C3
      '{0, 2, 3, 3}, // C0 + C2 + C3 + C3
      '{2, 2, 1, 3}, // C2 + C2 + C1 + C3
      '{2, 0, 3, 3}  // C2 + C0 + C3 + C3
    },
    '{// BM0110
      '{0, 1, 2, 1}, // C0 + C1 + C2 + C1
      '{0, 3, 0, 1}, // C0 + C3 + C0 + C1
      '{2, 3, 2, 1}, // C2 + C3 + C2 + C1
      '{2, 1, 0, 1}, // C2 + C1 + C0 + C1
      '{0, 1, 0, 3}, // C0 + C1 + C0 + C3
      '{0, 3, 2, 3}, // C0 + C3 + C2 + C3
      '{2, 3, 0, 3}, // C2 + C3 + C0 + C3
      '{2, 1, 2, 3}  // C2 + C1 + C2 + C3
    },
    '{// BM0111
      '{0, 1, 1, 0}, // C0 + C1 + C1 + C0
      '{0, 3, 3, 0}, // C0 + C3 + C3 + C0
      '{2, 3, 1, 0}, // C2 + C3 + C1 + C0
      '{2, 1, 3, 0}, // C2 + C1 + C3 + C0
      '{0, 1, 3, 2}, // C0 + C1 + C3 + C2
      '{0, 3, 1, 2}, // C0 + C3 + C1 + C2
      '{2, 3, 3, 2}, // C2 + C3 + C3 + C2
      '{2, 1, 1, 2}  // C2 + C1 + C1 + C2
    },
    '{// BM1000
      '{1, 1, 1, 1}, // C1 + C1 + C1 + C1
      '{1, 3, 3, 1}, // C1 + C3 + C3 + C1
      '{3, 3, 1, 1}, // C3 + C3 + C1 + C1
      '{3, 1, 3, 1}, // C3 + C1 + C3 + C1
      '{1, 1, 3, 3}, // C1 + C1 + C3 + C3
      '{1, 3, 1, 3}, // C1 + C3 + C1 + C3
      '{3, 3, 3, 3}, // C3 + C3 + C3 + C3
      '{3, 1, 1, 3}  // C3 + C1 + C1 + C3
    },
    '{// BM1001
      '{1, 1, 0, 0}, // C1 + C1 + C0 + C0
      '{1, 3, 2, 0}, // C1 + C3 + C2 + C0
      '{3, 3, 0, 0}, // C3 + C3 + C0 + C0
      '{3, 1, 2, 0}, // C3 + C1 + C2 + C0
      '{1, 1, 2, 2}, // C1 + C1 + C2 + C2
      '{1, 3, 0, 2}, // C1 + C3 + C0 + C2
      '{3, 3, 2, 2}, // C3 + C3 + C2 + C2
      '{3, 1, 0, 2}  // C3 + C1 + C0 + C2
    },
    '{// BM1010
      '{1, 2, 3, 0}, // C1 + C2 + C3 + C0
      '{1, 0, 1, 0}, // C1 + C0 + C1 + C0
      '{3, 0, 3, 0}, // C3 + C0 + C3 + C0
      '{3, 2, 1, 0}, // C3 + C2 + C1 + C0
      '{1, 2, 1, 2}, // C1 + C2 + C1 + C2
      '{1, 0, 3, 2}, // C1 + C0 + C3 + C2
      '{3, 0, 1, 2}, // C3 + C0 + C1 + C2
      '{3, 2, 3, 2}  // C3 + C2 + C3 + C2
    },
    '{// BM1011
      '{1, 2, 0, 1}, // C1 + C2 + C0 + C1
      '{1, 0, 2, 1}, // C1 + C0 + C2 + C1
      '{3, 0, 0, 1}, // C3 + C0 + C0 + C1
      '{3, 2, 2, 1}, // C3 + C2 + C2 + C1
      '{1, 2, 2, 3}, // C1 + C2 + C2 + C3
      '{1, 0, 0, 3}, // C1 + C0 + C0 + C3
      '{3, 0, 2, 3}, // C3 + C0 + C2 + C3
      '{3, 2, 0, 3}  // C3 + C2 + C0 + C3
    },
    '{// BM1100
      '{1, 1, 3, 1}, // C1 + C1 + C3 + C1
      '{1, 3, 1, 1}, // C1 + C3 + C1 + C1
      '{3, 3, 3, 1}, // C3 + C3 + C3 + C1
      '{3, 1, 1, 1}, // C3 + C1 + C1 + C1
      '{1, 1, 1, 3}, // C1 + C1 + C1 + C3
      '{1, 3, 3, 3}, // C1 + C3 + C3 + C3
      '{3, 3, 1, 3}, // C3 + C3 + C1 + C3
      '{3, 1, 3, 3}  // C3 + C1 + C3 + C3
    },
    '{// BM1101
      '{1, 1, 2, 0}, // C1 + C1 + C2 + C0
      '{1, 3, 0, 0}, // C1 + C3 + C0 + C0
      '{3, 3, 2, 0}, // C3 + C3 + C2 + C0
      '{3, 1, 0, 0}, // C3 + C1 + C0 + C0
      '{1, 1, 0, 2}, // C1 + C1 + C0 + C2
      '{1, 3, 2, 2}, // C1 + C3 + C2 + C2
      '{3, 3, 0, 2}, // C3 + C3 + C0 + C2
      '{3, 1, 2, 2}  // C3 + C1 + C2 + C2
    },
    '{// BM1110
      '{1, 2, 1, 0}, // C1 + C2 + C1 + C0
      '{1, 0, 3, 0}, // C1 + C0 + C3 + C0
      '{3, 0, 1, 0}, // C3 + C0 + C1 + C0
      '{3, 2, 3, 0}, // C3 + C2 + C3 + C0
      '{1, 2, 3, 2}, // C1 + C2 + C3 + C2
      '{1, 0, 1, 2}, // C1 + C0 + C1 + C2
      '{3, 0, 3, 2}, // C3 + C0 + C3 + C2
      '{3, 2, 1, 2}  // C3 + C2 + C1 + C2
    },
    '{// BM1111
      '{1, 2, 2, 1}, // C1 + C2 + C2 + C1
      '{1, 0, 0, 1}, // C1 + C0 + C0 + C1
      '{3, 0, 2, 1}, // C3 + C0 + C2 + C1
      '{3, 2, 0, 1}, // C3 + C2 + C0 + C1
      '{1, 2, 0, 3}, // C1 + C2 + C0 + C3
      '{1, 0, 2, 3}, // C1 + C0 + C2 + C3
      '{3, 0, 0, 3}, // C3 + C0 + C0 + C3
      '{3, 2, 2, 3}  // C3 + C2 + C2 + C3
    }
  };

  localparam bit [1 : 0] cSM_IDX_225_TAB [16][4][4] =
  '{
    '{// BM0000
      '{0, 0, 0, 0}, // C0 + C0 + C0 + C0
      '{2, 0, 2, 0}, // C2 + C0 + C2 + C0
      '{0, 2, 0, 2}, // C0 + C2 + C0 + C2
      '{2, 2, 2, 2}  // C2 + C2 + C2 + C2
    },
    '{// BM0001
      '{0, 1, 0, 1}, // C0 + C1 + C0 + C1
      '{2, 1, 2, 1}, // C2 + C1 + C2 + C1
      '{0, 3, 0, 3}, // C0 + C3 + C0 + C3
      '{2, 3, 2, 3}  // C2 + C3 + C2 + C3
    },
    '{// BM0010
      '{0, 2, 0, 0}, // C0 + C2 + C0 + C0
      '{2, 2, 2, 0}, // C2 + C2 + C2 + C0
      '{0, 0, 0, 2}, // C0 + C0 + C0 + C2
      '{2, 0, 2, 2}  // C2 + C0 + C2 + C2
    },
    '{// BM0011
      '{0, 3, 0, 1}, // C0 + C3 + C0 + C1
      '{2, 3, 2, 1}, // C2 + C3 + C2 + C1
      '{0, 1, 0, 3}, // C0 + C1 + C0 + C3
      '{2, 1, 2, 3}  // C2 + C1 + C2 + C3
    },
    '{// BM0100
      '{1, 1, 1, 1}, // C1 + C1 + C1 + C1
      '{3, 1, 3, 1}, // C3 + C1 + C3 + C1
      '{1, 3, 1, 3}, // C1 + C3 + C1 + C3
      '{3, 3, 3, 3}  // C3 + C3 + C3 + C3
    },
    '{// BM0101
      '{1, 0, 1, 0}, // C1 + C0 + C1 + C0
      '{3, 0, 3, 0}, // C3 + C0 + C3 + C0
      '{1, 2, 1, 2}, // C1 + C2 + C1 + C2
      '{3, 2, 3, 2}  // C3 + C2 + C3 + C2
    },
    '{// BM0110
      '{1, 3, 1, 1}, // C1 + C3 + C1 + C1
      '{3, 3, 3, 1}, // C3 + C3 + C3 + C1
      '{1, 1, 1, 3}, // C1 + C1 + C1 + C3
      '{3, 1, 3, 3}  // C3 + C1 + C3 + C3
    },
    '{// BM0111
      '{1, 2, 1, 0}, // C1 + C2 + C1 + C0
      '{3, 2, 3, 0}, // C3 + C2 + C3 + C0
      '{1, 0, 1, 2}, // C1 + C0 + C1 + C2
      '{3, 0, 3, 2}  // C3 + C0 + C3 + C2
    },
    '{// BM1000
      '{0, 2, 2, 0}, // C0 + C2 + C2 + C0
      '{2, 2, 0, 0}, // C2 + C2 + C0 + C0
      '{0, 0, 2, 2}, // C0 + C0 + C2 + C2
      '{2, 0, 0, 2}  // C2 + C0 + C0 + C2
    },
    '{// BM1001
      '{0, 3, 2, 1}, // C0 + C3 + C2 + C1
      '{2, 3, 0, 1}, // C2 + C3 + C0 + C1
      '{0, 1, 2, 3}, // C0 + C1 + C2 + C3
      '{2, 1, 0, 3}  // C2 + C1 + C0 + C3
    },
    '{// BM1010
      '{0, 0, 2, 0}, // C0 + C0 + C2 + C0
      '{2, 0, 0, 0}, // C2 + C0 + C0 + C0
      '{0, 2, 2, 2}, // C0 + C2 + C2 + C2
      '{2, 2, 0, 2}  // C2 + C2 + C0 + C2
    },
    '{// BM1011
      '{0, 1, 2, 1}, // C0 + C1 + C2 + C1
      '{2, 1, 0, 1}, // C2 + C1 + C0 + C1
      '{0, 3, 2, 3}, // C0 + C3 + C2 + C3
      '{2, 3, 0, 3}  // C2 + C3 + C0 + C3
    },
    '{// BM1100
      '{1, 3, 3, 1}, // C1 + C3 + C3 + C1
      '{3, 3, 1, 1}, // C3 + C3 + C1 + C1
      '{1, 1, 3, 3}, // C1 + C1 + C3 + C3
      '{3, 1, 1, 3}  // C3 + C1 + C1 + C3
    },
    '{// BM1101
      '{1, 2, 3, 0}, // C1 + C2 + C3 + C0
      '{3, 2, 1, 0}, // C3 + C2 + C1 + C0
      '{1, 0, 3, 2}, // C1 + C0 + C3 + C2
      '{3, 0, 1, 2}  // C3 + C0 + C1 + C2
    },
    '{// BM1110
      '{1, 1, 3, 1}, // C1 + C1 + C3 + C1
      '{3, 1, 1, 1}, // C3 + C1 + C1 + C1
      '{1, 3, 3, 3}, // C1 + C3 + C3 + C3
      '{3, 3, 1, 3}  // C3 + C3 + C1 + C3
    },
    '{// BM1111
      '{1, 0, 3, 0}, // C1 + C0 + C3 + C0
      '{3, 0, 1, 0}, // C3 + C0 + C1 + C0
      '{1, 2, 3, 2}, // C1 + C2 + C3 + C2
      '{3, 2, 1, 2}  // C3 + C2 + C1 + C2
    }
  };

  localparam bit [1 : 0] cSM_IDX_200_TAB [16][2][4] =
  '{
    '{// BM0000
      '{0, 0, 0, 0}, // C0 + C0 + C0 + C0
      '{2, 2, 2, 2}  // C2 + C2 + C2 + C2
    },
    '{// BM0001
      '{2, 2, 2, 0}, // C2 + C2 + C2 + C0
      '{0, 0, 0, 2}  // C0 + C0 + C0 + C2
    },
    '{// BM0010
      '{1, 1, 1, 1}, // C1 + C1 + C1 + C1
      '{3, 3, 3, 3}  // C3 + C3 + C3 + C3
    },
    '{// BM0011
      '{3, 3, 3, 1}, // C3 + C3 + C3 + C1
      '{1, 1, 1, 3}  // C1 + C1 + C1 + C3
    },
    '{// BM0100
      '{2, 2, 0, 0}, // C2 + C2 + C0 + C0
      '{0, 0, 2, 2}  // C0 + C0 + C2 + C2
    },
    '{// BM0101
      '{0, 0, 2, 0}, // C0 + C0 + C2 + C0
      '{2, 2, 0, 2}  // C2 + C2 + C0 + C2
    },
    '{// BM0110
      '{3, 3, 1, 1}, // C3 + C3 + C1 + C1
      '{1, 1, 3, 3}  // C1 + C1 + C3 + C3
    },
    '{// BM0111
      '{1, 1, 3, 1}, // C1 + C1 + C3 + C1
      '{3, 3, 1, 3}  // C3 + C3 + C1 + C3
    },
    '{// BM1000
      '{2, 0, 2, 0}, // C2 + C0 + C2 + C0
      '{0, 2, 0, 2}  // C0 + C2 + C0 + C2
    },
    '{// BM1001
      '{0, 2, 0, 0}, // C0 + C2 + C0 + C0
      '{2, 0, 2, 2}  // C2 + C0 + C2 + C2
    },
    '{// BM1010
      '{3, 1, 3, 1}, // C3 + C1 + C3 + C1
      '{1, 3, 1, 3}  // C1 + C3 + C1 + C3
    },
    '{// BM1011
      '{1, 3, 1, 1}, // C1 + C3 + C1 + C1
      '{3, 1, 3, 3}  // C3 + C1 + C3 + C3
    },
    '{// BM1100
      '{0, 2, 2, 0}, // C0 + C2 + C2 + C0
      '{2, 0, 0, 2}  // C2 + C0 + C0 + C2
    },
    '{// BM1101
      '{2, 0, 0, 0}, // C2 + C0 + C0 + C0
      '{0, 2, 2, 2}  // C0 + C2 + C2 + C2
    },
    '{// BM1110
      '{1, 3, 3, 1}, // C1 + C3 + C3 + C1
      '{3, 1, 1, 3}  // C3 + C1 + C1 + C3
    },
    '{// BM1111
      '{3, 1, 1, 1}, // C3 + C1 + C1 + C1
      '{1, 3, 3, 3}  // C1 + C3 + C3 + C3
    }
  };


# Verilog Forward Error Correction Archive:   BOX-Muller for fast AWGN generation, Universal Demapper from BPSK to QAM-512,  different Forward Error Correction coders and decoders: Hamming code, Golay code (24), 4-dimension 8-ary phase shift keying trellis coded modulation (TCM_4D_8PSK), BCH, CCSDS and recursive systematic convolutional (RSC) Turbo codes, 5G Polar code and QC-LDPC code 5G/WIMAX/NASA GSFC (8176,7156).

Verilog implementation of 
* BOX-Muller for fast AWGN generation 
* Universal Demapper from BPSK to QAM-512
* different Forward Error Correction encoders and decoders:
Hamming code, Golay code (24), 4-dimension 8-ary phase shift keying trellis coded modulation (TCM_4D_8PSK), 
BCH, CCSDS and recursive systematic convolutional (RSC) Turbo codes, 5G Polar code and QC-LDPC code 5G/WIMAX/NASA GSFC (8176,7156).

from Denis V. Shekhalev (des00 [dog]  opencores.org).



For example Wimax LDPC 2D Normalize Min-Sum decoder (Support 1/2, 2/3B, 3/4A, 5/6) synth results:
on old Cyclone IV C6 speed grade
2304 length, rate 5/6, 8 LLRs processed per clock with 5 bit input 
FPGA Resource: 11872LC, 6624Reg, 37 M9K,  210 Mhz.
Decoder latency = 2*(Niter*length/LRRs_per_clock) + 30 clock.


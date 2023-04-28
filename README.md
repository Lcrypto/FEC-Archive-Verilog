# Verilog RTL Forward Error Correction Archive:   BOX-Muller for fast AWGN generation, Universal Demapper from BPSK to QAM-512,  different Forward Error Correction encoders and decoders: Hamming code, Golay code (24), 4-dimension 8-ary phase shift keying trellis coded modulation (TCM 4D 8PSK), BCH, CCSDS and recursive systematic convolutional (RSC) Turbo codes, 5G Polar code and QC-LDPC codes 5G/WIMAX/NASA GSFC .

The GitHub repository contains a Verilog RTL Forward Error Correction Archive, including various tools and implementations for different forward error correction (FEC) encoders and decoders. These include Hamming code, Golay code (24), 4-dimension 8-ary phase shift keying trellis coded modulation (TCM 4D 8PSK), BCH, CCSDS, recursive systematic convolutional (RSC) Turbo codes, 5G Polar code, and QC-LDPC codes for 5G/WIMAX/NASA GSFC.

The archive also includes synthesized Verilog RTL implementation of BOX-Muller for fast Additive White Gaussian Noise (AWGN) generation and Universal Demapper from Binary Phase Shift Keying (BPSK) to Quadrature Amplitude Modulation (QAM)-512.

All of these tools and implementations were developed by Denis Vladimirovich Shekhalev, a Senior Engineer at the Scientific and Educational Center "Engineering Center of Microwave Technic and Technology", National Research Tomsk State University in Russia.

For example, the Wimax LDPC 2D Normalized Min-Sum decoder (supporting 1/2, 2/3B, 3/4A, 5/6 rates) was synthesized on an old Cyclone IV C6 speed grade with 2304 length, rate 5/6, 8 LLRs processed per clock (decoder parallelism degree) with 5 bit input. The FPGA resource utilization was 11872LC, 6624Reg, 37 M9K, and the maximum clock frequency was 210 MHz. The decoder latency was calculated as 2*(Niter*length/LRRs_per_clock) + 30 clocks.


*J. Zhang, M. Fossorier, D. Gu and J. Zhang, "Two-dimensional correction for min-sum decoding of irregular LDPC codes," in IEEE Communications Letters, vol. 10, no. 3, pp. 180-182, March 2006, doi: 10.1109/LCOMM.2006.1603377.

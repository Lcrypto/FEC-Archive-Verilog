set incdir  D:/work_des00/prj_verilog/prj_transport18e/fpga/2release/ldpc
set rtldir  D:/work_des00/prj_verilog/prj_transport18e/fpga/2release/ldpc/rtl
set tbdir   D:/work_des00/prj_verilog/prj_transport18e/fpga/2release/ldpc/tb
#
#
vlog -incr -sv +O4 +incdir+$incdir+$rtldir $rtldir/*.v

vlog +initreg+0 -sv -lint +incdir+$tbdir+$incdir $tbdir/bertest_rtl.v

vsim -sv_seed 123 bertest_rtl
sa

Wimax LDPC ����� �� ����������� �������������. �������������� �������� 1/2, 2/3B, 3/4A, 5/6.

����� ������������� 2D normalized Min-Sum. ������� �������� � [b]�������[/b] ���������, ������ ���������� ������������ ����������� ������ �������������� �� 1 ����. ���������� ������ �� ���� ������ ���� ������ ������� T ������� H = 24.

���������� �������� �� ���� �������. ������ 4, ��������� �6, ������ 2304, �������� ����������� 5/6, �������� ��������� 8 ������ �� 1 ����, ����������� ������� 5 ���: 11872LC, 6624Reg, 37 M9K, �������� 210 ���. �������� ��������� ������� ������, �.�. � �������� ���� �������� ������, ��� ������ ����������� ������ � ������� ������ � ������ ������ 1 �������.

�������� �������, ����, 2/4/6/8/16 ������ �� ����. ����� ������������� = 2*(Niter*length/���-�� ������ �� ����) + ����������� ������� 30 ������).



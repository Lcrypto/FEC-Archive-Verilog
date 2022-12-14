set incdir  D:/work_des00/prj_verilog/prj_transport18e/fpga/2release/ldpc
set rtldir  D:/work_des00/prj_verilog/prj_transport18e/fpga/2release/ldpc/rtl
set tbdir   D:/work_des00/prj_verilog/prj_transport18e/fpga/2release/ldpc/tb
#
#
vlog -incr -sv +O4 +incdir+$incdir+$rtldir $rtldir/*.v

vlog +initreg+0 -sv -lint +incdir+$tbdir+$incdir $tbdir/bertest_rtl.v

vsim -sv_seed 123 bertest_rtl
sa

Wimax LDPC кодек со статической конфигурацией. Поддерживаемые скорости 1/2, 2/3B, 3/4A, 5/6.

Метод декодирования 2D normalized Min-Sum. Декодер работает с [b]прямыми[/b] метриками, ширина интерфейса определяется количеством метрик обрабатываемых за 1 такт. Количество метрик за такт должно быть кратно размеру T матрицы H = 24.

Результаты декодера на плис средние. Сыклон 4, спидгрейт с6, длинна 2304, скорость кодирования 5/6, скорость обработки 8 метрик за 1 такт, разрядность метрики 5 бит: 11872LC, 6624Reg, 37 M9K, тактовая 210 МГц. Томрозит генерация адресов памяти, т.к. в ваймаксе есть нечетные сдвиги, что делает невозможным работу с блочком памяти в режиме больше 1 метрики.

Тестбенч бертест, кпск, 2/4/6/8/16 метрик за такт. Время декодирования = 2*(Niter*length/кол-во метрик за такт) + латентность порядка 30 тактов).



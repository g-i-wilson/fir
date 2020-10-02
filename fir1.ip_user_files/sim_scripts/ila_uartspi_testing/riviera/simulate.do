onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+ila_uartspi_testing -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ila_uartspi_testing xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ila_uartspi_testing.udo}

run -all

endsim

quit -force

onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+ila_qd -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ila_qd xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ila_qd.udo}

run -all

endsim

quit -force

onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib ila_qd_opt

do {wave.do}

view wave
view structure
view signals

do {ila_qd.udo}

run -all

quit -force

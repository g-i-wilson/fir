onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib ila_uartspi_testing_opt

do {wave.do}

view wave
view structure
view signals

do {ila_uartspi_testing.udo}

run -all

quit -force

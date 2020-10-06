onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib ila_uartspitap_opt

do {wave.do}

view wave
view structure
view signals

do {ila_uartspitap.udo}

run -all

quit -force

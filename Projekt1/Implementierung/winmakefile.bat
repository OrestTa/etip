set name=implementierung1
ghdl -a %name%.vhd testbench.vhd
ghdl -e testbench
ghdl -r testbench --stop-time=10000ms--vcd=%name%.vcd
gtkwave %name%.vcd
pause
del work-obj93.cf %name%.vcd

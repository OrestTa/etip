set name=implementierung1
ghdl -a %name%.vhd testbench.vhd
ghdl -e testbench
ghdl -r --stop-time=10000ms testbench --vcd=%name%.vcd
gtkwave %name%.vcd
pause
del work-obj93.cf %name%.vcd
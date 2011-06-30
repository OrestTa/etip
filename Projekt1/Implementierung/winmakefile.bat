set name=im1d
ghdl -a --ieee=synopsys %name%.vhd
ghdl -a --ieee=synopsys testbench.vhd
ghdl -e --ieee=synopsys testbench
ghdl -r --ieee=synopsys testbench --vcd=%name%.vcd
gtkwave %name%.vcd
pause
del work-obj93.cf %name%.vcd
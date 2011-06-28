GHDL=ghdl
WAVE=gtkwave

all: run

compile: implementierung1d.vhd testbench.vhd
	${GHDL} -a implementierung1d.vhd testbench.vhd

simulate: compile
	${GHDL} -e testbench

run: simulate
	./testbench --stop-time=2000ms --vcd=testbench.w
	${WAVE} testbench.w

clean:
	rm e~testbench.o implementierung1d.o testbench testbench.o testbench.w work-obj93.cf

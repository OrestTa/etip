GHDL=ghdl
WAVE=gtkwave

all: run

compile: implementierung1.vhd testbench.vhd
	${GHDL} -a implementierung1.vhd testbench.vhd

simulate: compile
	${GHDL} -e testbench

run: simulate
	./testbench --stop-time=20000ms --vcd=testbench.w
	${WAVE} testbench.w

clean:
	rm e~testbench.o implementierung1.o testbench testbench.o testbench.w work-obj93.cf

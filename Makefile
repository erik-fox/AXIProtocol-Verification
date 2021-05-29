setup:
	vlib work
	vmap work work

compile:
	vlog top.sv
	vlog tbBFM.sv
	vlog duv.sv
	vlog AXI_top_design.sv
	vlog axiprotocol_pkg.sv
	vlog AXI_slave.sv
	vlog AXI_master.sv
	vlog AXI_Interface.sv
	vopt +cover=bcesxf top -o top_optimized
#	vopt +acc top -o top_optimized

run: 
	vsim +TESTCASE=full_test top_optimized -coverage

clean:
	rm -rf work work.$(MODE) transcript *~ vsim.wlf *.log dgs.dbg dmslogdir

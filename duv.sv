

module duv(tbbfm bfm); 
parameter SIZE=3;
parameter WIDTH=32; 


logic [4095:0][7:0] slave_mem;
logic [4095:0][7:0] master_mem;
  
// Interface instance
 axi intf();

// Top design instance
AXI_top_design #(.WIDTH(32),.SIZE(3))
	top_inst	(.clk(bfm.clk),
				 .resetn(bfm.reset),
				 .slave_mem(slave_mem),
				 .master_mem(master_mem),
				.awaddr(bfm.awaddr),
				.awlen(bfm.awlen),
				.wstrb(bfm.wstrb),
				.awsize(bfm.awsize),
				.awburst(bfm.awburst),
				.wdata(bfm.wdata),
				.awid(bfm.awid),
				.araddr(bfm.araddr),
				.arid(bfm.arid),
				.arlen(bfm.arlen),
				.arsize(bfm.arsize),
				.arburst(bfm.arburst),
				 .intf(intf)

);

endmodule

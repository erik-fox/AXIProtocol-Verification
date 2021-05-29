

module duv(tbbfm bfm); 
parameter SIZE=3;
parameter WIDTH=32; 


logic [4095:0][7:0] slave_mem;
logic [4095:0][7:0] master_mem;
	


 assign bfm.ARREADY = intf.ARREADY;
 assign bfm.ARID = intf.ARID;
 assign bfm.ARADDR = intf.ARADDR;
 assign bfm.ARLEN= intf.ARLEN;
 assign bfm.ARSIZE= intf.ARSIZE;
 assign bfm.ARBURST= intf.ARBURST;
 assign bfm.ARVALID = intf.ARVALID;

 assign bfm.RID = intf.RID;
 assign bfm.RDATA = intf.RDATA;
 assign bfm.RRESP = intf. RRESP;
 assign bfm.RLAST = intf.RLAST;
 assign bfm.RVALID = intf.RVALID;
 assign bfm.RREADY = intf.RREADY;

assign bfm.AWREADY= intf.AWREADY;
assign bfm.AWVALID=intf.AWVALID;
assign bfm.AWBURST=intf.AWBURST;
assign bfm.AWSIZE=intf.AWSIZE;
assign bfm.AWLEN=intf.AWLEN;
assign bfm.AWADDR=intf.AWADDR;
assign bfm.AWID=intf.AWID;

assign bfm.WREADY= intf.WREADY;
assign bfm.WVALID= intf.WVALID;
assign bfm.WLAST=intf.WLAST;
assign bfm.WSTRB=intf.WSTRB;
assign bfm.WDATA=intf.WDATA;
assign bfm.WID=intf.WID;

assign bfm.BID=intf.BID;
assign bfm.BRESP=intf.BRESP;
assign bfm.BVALID=intf.BVALID;
assign bfm.BREADY=intf.BREADY;
  
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

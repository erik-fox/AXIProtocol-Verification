

module duv(tbbfm bfm); 
parameter SIZE=3;
parameter WIDTH=32; 


logic [4095:0][7:0] slave_mem;
logic [4095:0][7:0] master_mem;
	
wire		AWREADY;
wire		AWVALID;
wire	[SIZE-2:0]	AWBURST;
wire	[SIZE-1:0]	AWSIZE;
wire	[(WIDTH/8)-1:0]	AWLEN;
wire	[WIDTH-1:0]	AWADDR;
wire	[(WIDTH/8)-1:0]	AWID;

// DATA WRITE CHANNEL
wire		WREADY;
wire		WVALID;
wire		WLAST;
wire	[(WIDTH/8)-1:0]	WSTRB;
wire	[WIDTH:0]	WDATA;
wire	[(WIDTH/8)-1:0]	WID;

// WRITE RESPONSE CHANNEL
wire	[(WIDTH/8)-1:0]	BID;
wire	[SIZE-2:0]	BRESP;
wire		BVALID;
wire		BREADY;

// READ ADDRESS CHANNEL
wire		ARREADY;
wire	[(WIDTH/8)-1:0]	ARID;
wire	[WIDTH-1:0]	ARADDR;
wire	[(WIDTH/8)-1:0]	ARLEN;
wire	[SIZE-1:0]	ARSIZE;
wire	[SIZE-2:0]	ARBURST;
wire		ARVALID;

// READ DATA CHANNEL
wire	[(WIDTH/8)-1:0]	RID;
wire	[WIDTH-1:0]	RDATA;
wire	[SIZE-2:0]	RRESP;
wire		RLAST;
wire		RVALID;
wire		RREADY;
wire CLOCK, RESET;

 assign CLOCK = bfm.clk;
 assign RESET = bfm.reset;
 assign ARREADY = bfm.ARREADY;
 assign ARID = bfm.ARID;
 assign ARADDR = bfm.ARADDR;
 assign ARLEN= bfm.ARLEN;
 assign ARSIZE= bfm.ARSIZE;
 assign ARBURST= bfm.ARBURST;
 assign ARVALID = bfm.ARVALID;

 assign RID = bfm.RID;
 assign RDATA = bfm.RDATA;
 assign RRESP = bfm. RRESP;
 assign RLAST = bfm.RLAST;
 assign RVALID = bfm.RVALID;
 assign RREADY = bfm.RREADY;

assign AWREADY= bfm.AWREADY;
assign AWVALID=bfm.AWVALID;
assign AWBURST=bfm.AWBURST;
assign AWSIZE=bfm.AWSIZE;
assign AWLEN=bfm.AWLEN;
assign AWADDR=bfm.AWADDR;
assign AWID=bfm.AWID;

assign WREADY= bfm.WREADY;
assign WVALID= bfm.WVALID;
assign WLAST=bfm.WLAST;
assign WSTRB=bfm.WSTRB;
assign WDATA=bfm.WDATA;
assign WID=bfm.WID;

assign BID=bfm.BID;
assign BRESP=bfm.BRESP;
assign BVALID=bfm.BVALID;
assign BREADY=bfm.BREADY;
  
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

interface tbbfm;
//INPUTS
bit reset;
bit clk;
bit [31:0] araddr, awaddr, wdata;
bit [3:0] arid, arlen, awlen, wstrb, awid;
bit [2:0] arsize, awsize;
bit [1:0] arburst, awburst;

//PROTOCOL SIGNALS

bit		AWREADY;
bit		AWVALID;
bit	[SIZE-2:0]	AWBURST;
bit	[SIZE-1:0]	AWSIZE;
bit	[(WIDTH/8)-1:0]	AWLEN;
bit	[WIDTH-1:0]	AWADDR;
bit	[(WIDTH/8)-1:0]	AWID;

// DATA WRITE CHANNEL
bit		WREADY;
bit		WVALID;
bit		WLAST;
bit	[(WIDTH/8)-1:0]	WSTRB;
bit	[WIDTH:0]	WDATA;
bit	[(WIDTH/8)-1:0]	WID;

// WRITE RESPONSE CHANNEL
bit	[(WIDTH/8)-1:0]	BID;
bit	[SIZE-2:0]	BRESP;
bit		BVALID;
bit		BREADY;

// READ ADDRESS CHANNEL
bit		ARREADY;
bit	[(WIDTH/8)-1:0]	ARID;
bit	[WIDTH-1:0]	ARADDR;
bit	[(WIDTH/8)-1:0]	ARLEN;
bit	[SIZE-1:0]	ARSIZE;
bit	[SIZE-2:0]	ARBURST;
bit		ARVALID;

// READ DATA CHANNEL
bit	[(WIDTH/8)-1:0]	RID;
bit	[WIDTH-1:0]	RDATA;
bit	[SIZE-2:0]	RRESP;
bit		RLAST;
bit		RVALID;
bit		RREADY;
  
initial
begin
	clk=0;
	reset=0;
	#10
	reset=1;
	forever 
	begin
		#10;
		clk=~clk;
	end
end


endinterface

interface tbbfm;
bit reset;
bit clk;
bit [31:0] araddr, awaddr, wdata;
bit [3:0] arid, arlen, awlen, wstrb, awid;
bit [2:0] arsize, awsize;
bit [1:0] arburst, awburst;
  
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

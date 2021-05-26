package axiprotocol;
  
class request;
	//What are the appropriate constraints
	rand bit rw;
	rand bit [31:0] address; 
	rand bit[3:0] readid;
	rand bit [3:0]readlen; 
	rand bit [2:0] readsize; 
	rand bit[1:0] readburst;
	rand bit [31:0]waddress; 
	rand bit [3:0] wlen;
	rand bit [3:0] wstrobe; 
	rand bit [2:0] wsize; 
	rand bit [1:0] wburst; 
	rand bit [31:0] data; 
	rand bit [3:0] writeid;

	//CONSTRAINTS
		
endclass// Code your design here
class tester;
	virtual tbbfm bfm;
    	function new(virtual tbbfm b);
      		bfm=b;
    	endfunction
	task execute();
		request r0;
		string testcase;

		r0=new();

		//$value$plusargs("TESTCASE=%s",testcase);
		//case(testcase)
			//Read Burst
			//Overlapping readburst:
			//write burst
			//out of order transactions
		//endcase

		repeat(1000) 
		begin
          	@(negedge bfm.clk)
         	 begin
			assert(r0.randomize());
   
			case(r0.rw)
				1'b0:read(r0.address,r0.readid, r0.readlen,r0.readsize,r0.readburst);//read
				1'b1:write(r0.waddress,r0.wlen, r0.wstrobe, r0.wsize,r0.wburst, r0.data, r0.writeid);//write
			endcase
          	end
		end
	endtask
	task read(input bit [31:0] address, input bit[3:0] readid, input bit [3:0]readlen,input bit [2:0] readsize, input bit[1:0] readburst);
		bfm.araddr=address;
    		bfm.arid=readid;
    		bfm.arlen=readlen;
  		bfm.arsize=readsize;
  		bfm.arburst=readburst;
	endtask
  
	task write(input bit [31:0]waddress, input bit [3:0] wlen, input bit [3:0] wstrobe, input bit [2:0] wsize, input bit [1:0] wburst, input bit [31:0] data, input bit [3:0] writeid);
		bfm.awaddr=waddress;
  		bfm.awlen=wlen;
  		bfm.wstrb=wstrobe;
  		bfm.awsize=wsize;
		bfm.awburst=wburst;
 		bfm.wdata=data;
		bfm.awid=writeid;

	endtask
endclass 

class coverage;
	covergroup inputs;
		readaddr: bfm.araddr;
		readid: bfm.arid;
		readlen: bfm.arlen;
		readsize: bfm.arsize;
		readburst: bfm.arburst;
		writeaddr: bfm.awaddr;
		writelen: bfm.awlen;
		writestrobe: bfm.wstrb;
		writesize: bfm.awsize;
		writeburst: bfm.awburst;
		writedata: bfm.wdata;
		writeide: bfm.awid;
	endgroup
	function new( virtual interface tbbfm b);
		inputs = new();
		bfm=b;
	endfunction
endclass


class testbench;
	virtual tbbfm bfm;
	tester tester_h;
    	coverage coverage_h;
    	//scoreboard scoreboard_h;
	//checker checker_h;
    
    	function new (virtual tbbfm b);
      		bfm = b;
    	endfunction
    
    	task execute();
      		tester_h = new(bfm);
      		coverage_h= new(bfm);
      		//scoreboard_h = new(bfm);
		//checker_h = new(bfm);
      		fork
        		tester_h.execute();
        		coverage_h.execute();
        		//scoreboard_h.execute();
			//checker_h.execute();
      		join_none
    	endtask
endclass
  
	



endpackage

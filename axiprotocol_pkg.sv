package axiprotocol;
  
class request;
	//What are the appropriate constraints
	rand bit [2:0] op;
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
	//FROM THE SPEC:
	//AWLEN/ARLEN 0000 ->1 through 1111->16; wrapping bursts, length must be 2,4,8,16
	//ARSIZE/AWSIZE 000->1 through 111 -> 128 size of transfer must not exceed data bus width in transaction
	//ARBURST/AWBURST 00 -> fixed 01 -> INCR 10-> WRAP
	//IN THE CODE:
	//awaddr>32'h5ff and <=32'hfff and awsize <3'b100
	//arsize 000, 001, 010
	//arburst 00, 01, 10
	//arlen 0001,0011, 0111,1111
	//awburst 00,01,10,
	//awsize 000, 001,010
	//awlen 0001,0011,0111,1111
	//araddr>32'h1ff aradddr<=32'hfff 
	//wstrb 0001, 0010, 0100,1000,0011,0101,1001, 0110, 1010,1100,00111,1110,1011, 1101, 1111,	
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
			//Read Burst -> test the different possiblities
			//Overlapping readburst:
			//write burst
			//out of order transactions
		//endcase

		repeat(1000) 
		begin
          	@(negedge bfm.clk)
         	 begin
			assert(r0.randomize());
   
			case(r0.op)
				3'b000:read(r0.address,r0.readid, r0.readlen,r0.readsize,r0.readburst);//read
				3'b001:write(r0.waddress,r0.wlen, r0.wstrobe, r0.wsize,r0.wburst, r0.data, r0.writeid);//write
			//	3'b010:overlapping readbursts
			//	3'b010:out of order transactions
			//	3'b010:
			//	3'b010:
			//	3'b010:
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
	virtual tbbfm bfm;
	covergroup inputs;
		readaddr:coverpoint bfm.araddr;
		readid:coverpoint bfm.arid;
		readlen:coverpoint bfm.arlen;
		readsize:coverpoint bfm.arsize;
		readburst: coverpoint bfm.arburst;
		writeaddr:coverpoint bfm.awaddr;
		writelen:coverpoint bfm.awlen;
		writestrobe:coverpoint bfm.wstrb;
		writesize:coverpoint bfm.awsize;
		writeburst:coverpoint bfm.awburst;
		writedata:coverpoint bfm.wdata;
		writeide:coverpoint bfm.awid;
	endgroup
	//State coverage
	//State Transition coverage
	//Output coverage
	
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
        		//coverage_h.execute();
        		//scoreboard_h.execute();
			//checker_h.execute();
      		join_none
    	endtask
endclass
  
	



endpackage

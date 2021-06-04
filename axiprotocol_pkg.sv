package axiprotocol;
  
class request;
	//What are the appropriate constraints
	rand bit [2:0] op;
	rand bit [31:0] address; 
	randc bit [3:0] readid;
	randc bit [3:0]readlen; 
	rand bit [2:0] readsize; 
	rand bit [1:0] readburst;
	rand bit [31:0]waddress; 
	rand bit [3:0] wlen;
	randc bit [3:0] wstrobe; 
	rand bit [2:0] wsize; 
	rand bit [1:0] wburst; 
	rand bit [31:0] data; 
	randc bit [3:0] writeid;
  
	//CONSTRAINTS
	//FROM THE SPEC:
	//AWLEN/ARLEN 0000 ->1 through 1111->16; wrapping bursts, length must be 2,4,8,16
	constraint AW_len{wlen dist {1:/11,2:/5, 3:/11, [4:6]:/15, 7:/11, [8:14]:/35, 15:/11 };}     //awlen 0001,0011,0111,1111
	constraint AR_len{readlen dist {1:/11,2:/5, 3:/11, [4:6]:/15, 7:/11,[8:14]:/35, 15:/11 };}   //arlen 0001,0011, 0111,1111
	//ARSIZE/AWSIZE 000->1 through 111 -> 128 size of transfer must not exceed data bus width in transaction
	constraint AR_size{readsize dist {[1:3]:/60,[4:8]:/40};}									 //arsize 000, 001, 010
	constraint AW_size{wsize dist {[1:3]:/60, [4:8]:/40};}									 //awsize 000, 001,010
	//ARBURST/AWBURST 00 -> fixed 01 -> INCR 10-> WRAP
	constraint AR_Burst{readburst inside {[0:2]};}												//arburst 00, 01, 10
	constraint AW_Burst{wburst inside {[0:2]};}													//awburst 00,01,10
	//IN THE CODE:
	//awaddr>32'h5ff and <=32'hfff and awsize <3'b100
	constraint AW_Addr{waddress dist {[32'h5ff:32'hfff]:/60, [0:32'h5ff]:/20,[32'hfff:32'hffffffff]:/20};}	
		
	//araddr>32'h1ff aradddr<=32'hfff 
	constraint AR_Addr{address inside {[32'h1ff:32'hfff]};}
	//wstrb 0001, 0010, 0100,1000,0011,0101,1001, 0110, 1010,1100,00111,1110,1011, 1101, 1111,	
	constraint W_strobe{wstrobe inside {[1:15]};}
	
	constraint Op{op inside {[0:3]}; }
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

		$value$plusargs("TESTCASE=%s",testcase);
		case(testcase)
			"readburst": read(32'h000005FF, 4'b0000, 4'b0000,3'b000,2'b00);//Read Burst 
			"overlapping_readburst":begin read(32'h000005FF, 4'b0000, 4'b0000,3'b000,2'b00);read(32'h00000600, 4'b0000, 4'b0000,3'b000,2'b00);end //overlapping readbursts
			"write_burst":write(32'h000006FE,4'b0011, 4'b0100, 3'b010,2'b01,32'hFFFFFFFF,4'b0100);//write burst
			"out_of_order":begin fork read(32'h000008FF, 4'b0001,4'b0011,3'b010,2'b01);write(32'h000006FE,4'b0011, 4'b0100, 3'b010,2'b01,32'hFFFFFFFF,4'b0100);join end // Transaction ordering
			"fulltest":determine();
			"reset_axi":reset_bus();
		endcase

		repeat(1000) 
		begin
          	@(posedge bfm.clk);
         	 begin
			   //$display("Hi");
			    assert(r0.randomize());
                 //$display($time,"r0.op=%d",r0.op);
			case(r0.op)
				3'b000: begin read(r0.address,r0.readid, r0.readlen,r0.readsize,r0.readburst); end//read
				3'b001: begin write(r0.waddress,r0.wlen, r0.wstrobe, r0.wsize,r0.wburst, r0.data, r0.writeid); end//write
				3'b010: begin read(r0.address,r0.readid, r0.readlen,r0.readsize,r0.readburst);read(32'h00000600, 4'b0000, 4'b0000,3'b000,2'b00);end //overlapping readbursts
				3'b011: begin fork read(r0.address, r0.readid,r0.readlen,r0.readsize,r0.readburst);write(r0.waddress,r0.wlen, r0.wstrobe, r0.wsize,r0.wburst,r0.data,r0.writeid);join end // Transaction ordering
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
         	forever begin
           @(posedge bfm.ARREADY);
             	break;
        	 end 
  
	endtask
  
	task write(input bit [31:0]waddress, input bit [3:0] wlen, input bit [3:0] wstrobe, input bit [2:0] wsize, input bit [1:0] wburst, input bit [31:0] data, input bit [3:0] writeid);

			bfm.awaddr=waddress;
  			bfm.awlen=wlen;
	  		bfm.wstrb=wstrobe;
  			bfm.awsize=wsize;
			bfm.awburst=wburst;
 			bfm.wdata=data;
			bfm.awid=writeid;
         forever begin
           @(posedge bfm.AWREADY);
             	break;
         end
    
	endtask
	task determine();
		#50
		read(32'h00000FFF, 4'b0000, 4'b0000,3'b000,2'b00); //readburst
		#50
		read(32'h000005FF, 4'b0000, 4'b0000,3'b000,2'b00);//overlapping readburst
		read(32'h00000600, 4'b0000, 4'b0000,3'b000,2'b00);
		#50
		write(32'h000006FF,4'b0000, 4'b0000, 3'b000,2'b00,32'hFFFFFFFF,4'b0000);//write burst
    		#50	
		read(32'h000008FF, 4'b0000, 4'b0011,3'b000,2'b00);//variable read burst length
		#50
    		write(32'h000006FE,4'b0011, 4'b0000, 3'b000,2'b00,32'hFFFFFFFF,4'b0000);// variable write burst length
		#50
    		read(32'h000008FF, 4'b0000, 4'b0011,3'b000,2'b01);//variable read burst type
		#50
		write(32'h000006FE,4'b0011, 4'b0000, 3'b000,2'b01,32'hFFFFFFFF,4'b0000);// variable write burst type  
    		#50
		read(32'h000008FF, 4'b0000, 4'b0011,3'b010,2'b01);//variable read burst size
		#50
    		write(32'h000006FE,4'b0011, 4'b0000, 3'b010,2'b01,32'hFFFFFFFF,4'b0000);// variable write burst size
    		#50
    		read(32'h000008FF, 4'b0001,4'b0011,3'b010,2'b01);//Transaction ordering
	   	write(32'h000006FE,4'b0011, 4'b0100, 3'b010,2'b01,32'hFFFFFFFF,4'b0100);// Transaction ordering
		#50
		for(int i=32'h00000600;i<=32'h0000060F;i++) begin
			write(i,4'b0000, 4'b0000, 3'b000,2'b00,i,4'b0000);
		end
	
		
		read(32'h00000600,4'b0000,4'b0000,3'b001,2'b00); //fixed read burst with size 1
		read(32'h00000600,4'b0000,4'b0000,3'b001,2'b00); //fixed read burst with size 2
		read(32'h00000600,4'b0000,4'b0000,3'b010,2'b00); //fixed read burst with size 4
		#50
		read(32'h00000600,4'b0000,4'b0001,3'b000,2'b01); //incrementing read burst with size 1
		read(32'h00000600,4'b0000,4'b0001,3'b001,2'b01); //incrementing read burst with size 2
		read(32'h00000600,4'b0000,4'b0001,3'b010,2'b01); //incrementing read burst with size 4
		#50
		read(32'h00000600,4'b0000,4'b0001,3'b000,2'b10); //wrapping readburst with length 2 and size 1
		read(32'h00000600,4'b0000,4'b0001,3'b001,2'b10); //wrapping readburst with length 2 and size 2
		read(32'h00000600,4'b0000,4'b0001,3'b010,2'b10); //wrapping readburst with length 2 and size 4
		#50
		read(32'h00000600,4'b0000,4'b0011,3'b000,2'b10); //wrapping readburst with length 4 and size 1
		read(32'h00000600,4'b0000,4'b0011,3'b001,2'b10); //wrapping readburst with length 4 and size 2
		read(32'h00000600,4'b0000,4'b0011,3'b010,2'b10); //wrapping readburst with length 4 and size 4
		#50
		read(32'h00000600,4'b0000,4'b0111,3'b000,2'b10); //wrapping readburst with length 8 and size 1
		read(32'h00000600,4'b0000,4'b0111,3'b001,2'b10); //wrapping readburst with length 8 and size 2
		read(32'h00000600,4'b0000,4'b0111,3'b010,2'b10); //wrapping readburst with length 8 and size 4
		#50
		read(32'h00000600,4'b0000,4'b1111,3'b000,2'b10); //wrapping readburst with length 16 and size 1
		read(32'h00000600,4'b0000,4'b1111,3'b001,2'b10); //wrapping readburst with length 16 and size 2
		read(32'h00000600,4'b0000,4'b1111,3'b010,2'b10); //wrapping readburst with length 16 and size 4
		//write and reading from same location
		#50
		write(32'h000006FF,4'b0000, 4'b0000, 3'b000,2'b00,32'hFFFFFFFF,4'b0000);
		read(32'h000006FF,4'b0000,4'b0000,3'b000,2'b00);
		//simultaneous write to different memory locations
		#50 
		write(32'h00000755,4'b0000, 4'b0000, 3'b000,2'b00,32'hFFFFFFFF,4'b0000);
		write(32'h00000765,4'b0000, 4'b0000, 3'b000,2'b00,32'hFFFFFFFF,4'b0000);
		//back to back writes to same memory and reading from it atlast
		#50 
		write(32'h000007EE,4'b0000, 4'b0000, 3'b000,2'b00,32'hFFF89000,4'b0000);
		write(32'h000007EE,4'b0000, 4'b0000, 3'b000,2'b00,32'hFFF89670,4'b0000);
		read(32'h000007EE,4'b0000,4'b0000,3'b000,2'b00);
		//Access out-of-bound memory
		#50
		read(32'hFFFFF7EE,4'b0000,4'b0000,3'b000,2'b00);
	endtask		
	task reset_bus();
		@(negedge bfm.clk)
		bfm.reset <= 'b0;
		@(negedge bfm.clk)
		bfm.reset <= 'b1;
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
		writeid:coverpoint bfm.awid;
		read: cross readid, readlen, readsize, readburst;
		write: cross writelen, writestrobe, writesize, writeburst, writeid;
	endgroup
	covergroup outputs;
		//readburst
		readaddressvalid:coverpoint bfm.ARVALID;
		readaddressready:coverpoint bfm.ARREADY;
		readlast:coverpoint bfm.RLAST;
		readvalid:coverpoint bfm.RVALID;
		readready:coverpoint bfm.RREADY;
		readaddresssignals: cross readaddressvalid, readaddressready;
		readsignals: cross readvalid, readready;
		readsignalslast: cross readvalid, readready, readlast;
		//writeburst
		writeaddressvalid:coverpoint bfm.AWVALID;
		writeaddressready:coverpoint bfm.AWREADY;
		writelast: coverpoint bfm.WLAST;
		writevalid: coverpoint bfm.WVALID;
		writeready: coverpoint bfm.WREADY;
		writesignals: cross writevalid, writeready;
		writesignalslast: cross writelast, writevalid, writeready;
		writeresponse: coverpoint bfm.BRESP;
		writeresponsevalid: coverpoint bfm.BVALID;
		writeresponseready: coverpoint bfm.BREADY;
		writeresponsecross: cross writeresponse, writeresponsevalid, writeresponseready; 
	endgroup
	
	function new( virtual interface tbbfm b);
		inputs = new();
		outputs= new();
		bfm=b;
	endfunction
	task execute();
		forever begin
			@(posedge bfm.clk);
			inputs.sample();
			outputs.sample();
		end
	endtask 
endclass

class readq;
	bit [31:0] address;
	bit [3:0] readid; 
	bit [3:0]readlen; 
	bit [2:0] readsize; 
	bit [1:0] readburst;
	int bursts_remaining;
   
endclass
class writeq;
	bit [31:0]waddress;  
	bit [3:0] wlen;
	bit [3:0] wstrobe;
	bit [2:0] wsize;
	bit [1:0] wburst;
	bit [31:0] data;
	bit [3:0] writeid;
	int bursts_remaining;
   
endclass

class scoreboard;
	virtual tbbfm bfm;
	function new(virtual tbbfm b);
		bfm=b;
	endfunction
	task execute();
     		readq read_queue [$];
		writeq write_queue [$];
		fork
			forever @(posedge bfm.RLAST)
				if(!bfm.RVALID)
					$error(" Invalid RLast signal %0t", $time);
		join_none
		fork
			forever@(posedge bfm.WLAST)
				if(!bfm.WVALID)
					$error("Invalid Wlast signal %0t", $time);
		join_none
		fork
			forever @(posedge bfm.ARVALID)
        		begin
				readq rq=new();
				#1;
				if(bfm.araddr==bfm.ARADDR && bfm.arid==bfm.ARID && bfm.arlen == bfm.ARLEN && bfm.arsize==bfm.ARSIZE && bfm.arburst==bfm.ARBURST)
				begin
					rq.address=bfm.ARADDR;
					rq.readid=bfm.ARID;
					rq.readlen=bfm.ARLEN;
					rq.bursts_remaining= bfm.ARLEN+1;
					rq.readsize=bfm.ARSIZE;
					rq.readburst=bfm.ARBURST;
					@(posedge bfm.ARREADY) 
					begin
						if(bfm.araddr==bfm.ARADDR && bfm.arid==bfm.ARID && bfm.arlen == bfm.ARLEN && bfm.arsize==bfm.ARSIZE && bfm.arburst==bfm.ARBURST)
						begin
							$display("push to queue %0t",$time);
							read_queue.push_front(rq);
						end
						else
							$error("Master signal not matching input  on ARREADY %0t", $time);
					end 
				
				end
				else
					$error("Master signal not matching input  on ARVALID %0t", $time);
            		end
		join_none
		
		fork
			forever @(posedge bfm.AWVALID)
        		begin
				writeq wq=new();
				#1;
				if(bfm.awaddr==bfm.AWADDR && bfm.awid==bfm.AWID && bfm.awlen == bfm.AWLEN && bfm.awsize==bfm.AWSIZE && bfm.awburst==bfm.AWBURST)
				begin
					wq.waddress=bfm.AWADDR;
					wq.writeid=bfm.AWID;
					wq.wlen=bfm.AWLEN;
					wq.bursts_remaining= bfm.AWLEN+1;
					wq.wsize=bfm.AWSIZE;
					wq.wburst=bfm.AWBURST;
					@(posedge bfm.AWREADY) 
					begin
						if(bfm.awaddr==bfm.AWADDR && bfm.awid==bfm.AWID && bfm.awlen == bfm.AWLEN && bfm.awsize==bfm.AWSIZE && bfm.awburst==bfm.AWBURST)
						begin
							$display("push to queue %0t",$time);
							write_queue.push_front(wq);
						end
						else
							$error("Master signal not matching input  on AWREADY %0t", $time);
					end 
				
				end
				else
					$error("Master signal not matching input  on AWVALID %0t", $time);
            		end
		join_none
		
		
		

		fork
			forever @(bfm.araddr)
        		begin
				#1;
				if(bfm.araddr!=bfm.ARADDR || bfm.arid!=bfm.ARID || bfm.arlen != bfm.ARLEN || bfm.arsize!=bfm.ARSIZE || bfm.arburst!=bfm.ARBURST)
				begin
					$error("Master signal not matching input on address change %0t", $time);
					if(!bfm.ARVALID)
						$error("Master not applying valid on address change, necessary for overlapping readbursts %0t", $time);
				end
				else if(!bfm.ARVALID)
              				$error("Master not applying valid on address change, necessary for overlapping readbursts %0t", $time);
			end
            	
		join_none

		fork
			forever @(posedge bfm.RREADY)
			begin
				int i=0;
				#1;
				if(read_queue.size()>0)
				begin
					$display("queue size %d %0t", read_queue.size(), $time);
					for(i = read_queue.size()-1; i>=-1;i--)
					begin
						if(i==-1)
						begin
							$error("No matches in the queue for signal changes %0t", $time);
							break;
						end
						if(read_queue[i].readid==bfm.RID)
							break;
					end
					if (i !=-1)//MATCH
					begin
						$display("RVALID %d RLAST %d %0t", bfm.RVALID,bfm.RLAST,$time);
						if(bfm.RVALID && !bfm.RLAST)//no particular valid order for valid and ready.  they just need to be up together
						begin
							if(read_queue[i].bursts_remaining==1)
							begin
								$display("bursts remaining %d %0t", read_queue[i].bursts_remaining,$time);
								$error("Missing RLAST signal from slave on last burst %0t", $time);
								read_queue.delete(i);
								$display("pop from queue %0t",$time);
							end
							else
								read_queue[i].bursts_remaining=read_queue[i].bursts_remaining-1;
						end
						else if(bfm.RVALID && bfm.RLAST)
						begin
							if(read_queue[i].bursts_remaining!=1)
								$error("Premature RLAST %0t",$time);
							else
							begin
								read_queue.delete(i);
								$display("pop from queue %0t",$time);
							end
						end
					end
				end
			end
		join_none
		fork
			forever @(posedge bfm.WREADY)
			begin
				int i=0;
				#1;
				if(write_queue.size()>0)
				begin
					$display("queue size %d %0t", write_queue.size(), $time);
					for(i = write_queue.size()-1; i>=-1;i--)
					begin
						if(i==-1)
						begin
							$error("No matches in the queue for signal changes %0t", $time);
							break;
						end
						if(write_queue[i].writeid==bfm.WID)
							break;
					end
				
					if (i !=-1)//MATCH
					begin
						$display("WVALID %d WLAST %d %0t", bfm.WVALID,bfm.WLAST,$time);
						if(bfm.WVALID && !bfm.WLAST)//no particular valid order for valid and ready.  they just need to be up together
						begin
							if(write_queue[i].bursts_remaining==1)
							begin
								$display("bursts remaining %d %0t", write_queue[i].bursts_remaining,$time);
								$error("Missing WLAST signal from slave on last burst %0t", $time);
								write_queue.delete(i);
								$display("pop from queue %0t",$time);
							end
							else
								write_queue[i].bursts_remaining=write_queue[i].bursts_remaining-1;
						end
						else if(bfm.WVALID && bfm.WLAST)
						begin
							if(write_queue[i].bursts_remaining!=1)
								$error("Premature WLAST %0t",$time);
							else
							begin
								@(posedge bfm.BVALID)
								begin
									if(bfm.BREADY)
									begin
										if(bfm.BID==write_queue[i].writeid)
										begin
											write_queue.delete(i);
											$display("pop from queue %0t",$time);
										end
										else
											$error("BID doesn't match WID %0t",$time);
									end
									else
										$error("BVALID and BREADY timing error %0t", $time);
								end
							end
						end
					end
				end
			end
		join_none
	endtask
endclass
      
      
      
class testbench;
	virtual tbbfm bfm;
	tester tester_h;
    	coverage coverage_h;
    	scoreboard scoreboard_h;

    
    	function new (virtual tbbfm b);
      		bfm = b;
    	endfunction
    
    	task execute();
      		tester_h = new(bfm);
      		coverage_h= new(bfm);
      		scoreboard_h = new(bfm);
      		fork
        		tester_h.execute();
        		coverage_h.execute();
        		scoreboard_h.execute();
		
      		join_none
    	endtask
endclass
  
	



endpackage

module top;
import axiprotocol::*; 
tbbfm bfm();	
duv d0 (bfm);	
testbench testbench_h;

initial
begin
	$display("WOrking");
	$dumpfile("dump.vcd"); $dumpvars;
	testbench_h = new(bfm);
    	testbench_h.execute();
end
initial
begin
     	#1000
      	$finish();
end
endmodule

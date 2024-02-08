class generator;

	transaction xtn_gen;
	
	mailbox #(transaction) gen2drv;
	
	int no_of_packets=0;	// Counter to get requested no of stimuli by the user
	
	event drv_next;			// allows us to know when DRV has completed its task
	event sb_next;			// allows us to know when SB has completed its task
	event gen_done;
	
	// Constructor function
	function new (mailbox #(transaction) GEN2DRV);
		xtn_gen 	 = new();
		this.xtn_gen = GEN2DRV;
	endfunction
	
	task run();
		repeat(no_of_packets) begin
			assert(xtn_gen.randomize())
				else $error("at time t=%0t, [GEN]: Randomization Failed", $time);
			
			if(xtn_gen.oper == 1'b0)	// send
				$display("at time t=%0t, [GEN]: OPER=%0s din=0x%0h", $time, xtn_gen.oper.name(), xtn_gen.din);
				
			else if(xtn_gen.oper == 1'b1)// receive
				$display("at time t=%0t, [GEN]: OPER=%0s", $time, xtn_gen.oper.name());			
			
			gen2drv.put(xtn_gen.copy);	// send the deep copy to DRV
			
			@(drv_next);	// wait for DRV to send to DUT
			@(sb_next);		// wait for SB to compare single XTN
		end
		->(gen_done);		// tells whole Verif. Env to stop the simulation after requested no of stimulus are sent
	endtask
	
endclass
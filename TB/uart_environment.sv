class environment;

	generator  gen;
	driver	   drv;
	monitor	   mon;
	scoreboard scb;
	
	mailbox #(transaction) 			 gen2drv;
	mailbox #(bit [`DATA_WIDTH-1:0]) drv2sb;
	mailbox #(bit [`DATA_WIDTH-1:0]) mon2sb;
	
	virtual intf vif_env;
	
	//event gen_done;
	event drv_next;
	event sb_next;
	
	function new(virtual intf VIF_ENV);
      	// Initialize mailboxes 	// V.IMP
        gen2drv = new();
        drv2sb  = new();
        mon2sb  = new();
      
		// Initialize transactor's handles
        gen = new(gen2drv);
        drv = new(gen2drv, drv2sb);
        mon = new(mon2sb);
      	scb = new(drv2sb, mon2sb);
		
		// Connect virtual interface
		this.vif_env = VIF_ENV;
		drv.vif_drv  = vif_env;
		mon.vif_mon  = vif_env;
		
      	// Connect Events
      	gen.drv_next = drv_next;
		drv.drv_next = drv_next;
        gen.sb_next	 = sb_next;
		scb.sb_next  = sb_next;
	endfunction
	
	task pre_test();
		drv.reset();
	endtask
	
	task test();
		fork		// FIXME: Idk why they used fork-join_any. what would happen without it?
          gen.run();
          drv.run();
          mon.run();
          scb.run();
        join_any
	endtask
	
	task post_test();
      wait(gen.gen_done.triggered);
      $display("at time t=%0t, All Stimulii Finished \nTotal:%0d Passed:%0d Failed:%0d", $time, /*gen.no_of_packets*/ (scb.pass_count+scb.fail_count), scb.pass_count, scb.fail_count);
      $display("---------------------------------------------------------------------");
	  $finish();	// Once all requested no of stimuli are triggered then stop the simulation.
	endtask
	
	task run();
		pre_test();
		test();
		post_test();
	endtask
	
endclass
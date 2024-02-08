class driver;

	transaction xtn_drv;
	
	mailbox #(transaction) 			 drv2gen;
	mailbox #(bit [`DATA_WIDTH-1:0]) drv2sb;
	
	virtual intf vif_drv;
	
	event drv_next;
	
	bit [`DATA_WIDTH-1:0] datarx;	// Random data sent to Rx module of UART. This will be used to send to SB.
	
	// Constructor functions
	function new(mailbox #(transaction) DRV2GEN, mailbox #(bit [`DATA_WIDTH-1:0]) DRV2SB);
		xtn_drv = new();
		this.drv2gen = DRV2GEN;
		this.drv2sb	 = DRV2SB;
	endfunction
	
	task reset();
		vif_drv.reset  <= 1'b0;	// Enable reset (active low reset in RTL)
		vif_drv.rx	   <= 1'b1;	// Disable Rx
		vif_drv.newd   <= 1'b0;	// Disable new data flag
		vif_drv.din	   <=  'b0;	// Clear input data bus
		
		repeat
			@(posedge vif_drv.clk); // reset is applied as per global/system clock. can also be applied by internal uart clock. 
			
		vif_drv.reset  <= 1'b1;	// Disable reset after 1 system-clock pulse
		@(posedge vif_drv.clk);
		
		$display("at time t=%0t, [DRV]: Reset Done!");
		$display("----------------------------------------------------------");
	endtask
	
	task run();
		forever begin
			drv2gen.get(xtn_drv);
			
			if(xtn_drv.oper == 1'b0) begin 		// send
				@(posedge vif_drv.uclktx);		// Use uart's Tx internal clock
				vif_drv.reset <= 1'b1;			// Disable reset just in case
				vif_drv.newd  <= 1'b1;			// New data is available
				vif_drv.rx 	  <= 1'b1;			// Rx disable
				vif_drv.din   <= xtn_drv.din;	// load data to the interface
				
				$display("at time t=%0t, [DRV]: OPER=SEND din=0x%0h", $time, xtn_gen.din);
				
				@(posedge vif_drv.uclktx);		// stabalize new data for 1 clk pulse to sense by DUT
				vif_drv.newd <= 1'b0;
				
				drv2sb.put(xtn_drv.din);
				wait(vif_drv.done_tx == 1'b1);	// This makes sure data transfer is completed by uart_tx module
				
			end
			
			else if(xtn_drv.oper == 1'b1) begin // receive
				@(posedge vif_drv.uclkrx);
				vif_drv.reset <= 1'b1;
				vif_drv.rx 	  <= 1'b0;			// Rx is started, flag
				vif_drv.newd  <= 1'b0;			// No new data available to Tx
				
				@(posedge vif_drv.uclkrx);
				for (int i=0; i<=`DATA_WIDTH-1; i++) begin
					vif_drv.rx <= $urandom;
					datarx[i]  = vif_drv.rx;	// Save data in local var to send to SB. (acc to RTL this would be doutrx)
				end
				
				$display("at time t=%0t, [DRV]: OPER=RECEIVE DATA RCVD=0x%0h", $time, datarx);
				
				drv2sb.put(datarx);
				wait(vif_drv.done_rx == 1'b1);
				vif_drv.rx <= 1'b1;				// Disable Rx after the end of every single receive process

			end
			
			->(drv_next);						// Single Tx Sent. Signal to GEN  to send next stimuli
		end
	endtask

endclass
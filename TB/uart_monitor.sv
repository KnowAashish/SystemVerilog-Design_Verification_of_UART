class monitor;
	
  mailbox #(bit [`DATA_WIDTH-1:0]) mon2sb;
	
	virtual intf vif_mon;
	
	bit [`DATA_WIDTH-1:0] txrcvd;
	bit [`DATA_WIDTH-1:0] doutrcvd;
	
  function new (mailbox #(bit [`DATA_WIDTH-1:0]) MON2SB);
		this.mon2sb = MON2SB;
	endfunction
	
	task run();
		forever begin
			
          	@(posedge vif_mon.uclk_tx);
            if((vif_mon.newd==1'b1) && (vif_mon.rx==1'b1)) begin	// send operation
              	@(posedge vif_mon.uclk_tx);
				for (int i=0; i<=`DATA_WIDTH-1; i++) begin
                    @(posedge vif_mon.uclk_tx);
					txrcvd[i] = vif_mon.tx;
				end
				$display("at time t=%0t, [MON]: Data Sent from MON to SB = 0x%0h", $time, txrcvd);
				
              	@(posedge vif_mon.uclk_tx);			// FIXME: IDK why they require another @posedge. What would happen without using this?
				mon2sb.put(txrcvd);
			end
			
			else if(vif_mon.newd==1'b0 && vif_mon.rx==1'b0) begin	// receive operation
                @(posedge vif_mon.uclk_rx); // cmnted in solution code but works for me
				wait(vif_mon.done_rx == 1'b1);
				doutrcvd = vif_mon.dout;
				
				$display("at time t=%0t, [MON]: Data Sent from MON to SB = 0x%0h", $time, doutrcvd);
				
              	@(posedge vif_mon.uclk_rx);			// FIXME: IDK why they require another @posedge. What would happen without using this?
				mon2sb.put(doutrcvd);
			end
			
		end
	endtask
	
endclass

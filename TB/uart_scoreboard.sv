class scoreboard;

	mailbox #(bit [`DATA_WIDTH-1:0]) sb2drv;	// this will get either din (for Tx) or dout (for Rx) stimulus from DRV
	mailbox #(bit [`DATA_WIDTH-1:0]) sb2mon;	// this will get either din (for Tx) sampled by tx signal of DUT_TX or dout of DUT_RX module
	
	bit [`DATA_WIDTH-1:0] drvrcvd;				// from DRV
	bit [`DATA_WIDTH-1:0] monrcvd;				// from MON
	
	event sb_next;
  
  	int pass_count=0, fail_count=0;
	
  function new(mailbox #(bit [`DATA_WIDTH-1:0]) SB2DRV, SB2MON);
		this.sb2drv = SB2DRV;
		this.sb2mon = SB2MON;
	endfunction
	
	task run();
		forever begin
			// here, the data received from DRV and MON would belong to same Transaction. Because, we are manually coding operations to be serial i.e., one transaction after another.
			sb2drv.get(drvrcvd);
			sb2mon.get(monrcvd);
			
			$display("at time t=%0t, [SCB]: DRV DATA: 0x%0h MON DATA: 0x%0h", $time, drvrcvd, monrcvd);
			
			if(drvrcvd == monrcvd) begin
				$display("at time t=%0t, [SCB]: PASSED - DATA MATCH", $time);
              	pass_count++;
			end
			else begin
				$display("at time t=%0t, [SCB]: FAILED - DATA MISMATCH", $time);
              	fail_count++;
            end
			
          $display("---------------------------------------------------------------------");
			->sb_next;
		end
	endtask
	
endclass
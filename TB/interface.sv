interface intf();

	bit 				  clk;
	bit 				  reset;
	bit [`DATA_WIDTH-1:0] din;
	bit [`DATA_WIDTH-1:0] dout;
	bit 				  newd;
	bit 				  rx;
	bit 				  tx;
	bit 				  done_rx;
	bit 				  done_tx;
	
	bit					  uclk_tx;
	bit					  uclk_rx;
	
endinterface
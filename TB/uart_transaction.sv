class transaction;
	
	rand bit [`DATA_WIDTH-1:0] din;
	bit newd;
	bit rx;		// planning to use urandom for this input
	bit tx;
	bit done_tx;
	bit done_rx;
	bit [`DATA_WIDTH-1:0] dout;
	
	typedef enum bit {send=1'b0, receive=1'b1} oper_type;
	randc oper_type oper;
	
	// Logic for deep copy of the transaction packet
	function transaction copy();
      	copy 		 = new();
		copy.din 	 = this.din;
		copy.newd 	 = this.newd;
		copy.rx 	 = this.rx;
		copy.tx 	 = this.tx;
		copy.done_tx = this.done_tx;
		copy.done_rx = this.done_rx;
		copy.dout 	 = this.dout;
		copy.oper 	 = this.oper;
	endfunction
	
endclass

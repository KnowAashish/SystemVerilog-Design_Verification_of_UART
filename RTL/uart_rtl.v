`define DATA_WIDTH 8

module uart_top #(parameter clk_freq=1000000, baudrate=9600)
				(input clk,
				input reset,
				input newd,
				input [`DATA_WIDTH-1:0] din,
				input rx,
				output reg tx,
				output reg done_tx,
				output done_rx,
				output [`DATA_WIDTH-1:0] dout);
	
	uart_tx #(clk_freq, baudrate) DUT_TX (.clk(clk), .reset(reset), .newd(newd), .din(din), .tx(tx), .done_tx(done_tx));
	uart_rx #(clk_freq, baudrate) DUT_RX (.clk(clk), .reset(reset), .rx(rx), .done_rx(done_rx), .dout(dout));
	
endmodule

//////////////////////////////////////////////////////////////////////////////

module uart_tx #(parameter clk_freq = 1000000, baudrate = 9600)
				(input clk, reset,
				input newd,
                input [`DATA_WIDTH-1:0] din,
				output reg tx,	// Serial Transmission of 8-bit data
				output reg done_tx);
	
	localparam clk_count = (clk_freq/baudrate);	// No. of system clock (main clk) required to Tx 1-bit
	
  	enum bit {idle=1'b0, send=1'b1} state;	// FSM states
  
	int count, countbit;
	
	reg [`DATA_WIDTH-1:0] temp;
	
	reg uclk=0;	// UART's Internal Clock based on baudrate
  				// here =0 is V.IMP as we are waiting for posedge in DRV
	
	// Generate uclk
	always@(posedge clk) begin
		if(count < clk_count/2) begin
			count <= count+1;
		end
		else begin
			count <= 0;
			uclk <= !uclk;
		end	
	end
	
	// Essentially, all operations inside UART Tx & Rx work as per uclk. As per TX, the data bit is loaded for the 1st high of uclk,
	// which is of duration clk_count/2 and data bit remains constant for rest of clk_count/2.
	
	always@(posedge uclk) begin
		if(!reset) begin
			state 	<= idle;
			tx 		<= 1'b1;
			done_tx <= 1'b0;
		end
		else begin
			case(state)
			
				idle: begin
					countbit <= 1'b0;
					tx 		 <= 1'b1;
					done_tx  <= 1'b0;
					
					if(newd) begin
						state 	<= send;
						tx 		<= 1'b0;	// when newd is high, we send start of Tx in next pulse, which is tx = 1'b0
						temp	<= din;		// sample the data in temp bus
					end
					else begin
						state 	<= idle;
						tx 		<= 1'b1;
						done_tx <= 1'b0;
					end
				end
				
				send: begin
					if(countbit<=`DATA_WIDTH-1) begin
						tx 		 <= temp[countbit];
						done_tx  <= 1'b0; 	// added
                      	state 	 <= send;	// V.IMP to stay in send until finished
						countbit <= countbit + 1;
					end
					else begin
						tx		 <= 1'b1;	// stop bit high, end of Tx
						done_tx  <= 1'b1;
						state	 <= idle;
						countbit <= 0;
						
					end
				end
				
				default: begin
					state 	 <= idle;
					tx 		 <= 1'b1;
					done_tx	 <= 1'b0;
					countbit <= 0;
				end
			
			endcase
		end
	end
endmodule

//////////////////////////////////////////////////////////////////////////////

module uart_rx #(parameter clk_freq=1000000, baudrate=9600)
	(input clk, reset,
	input rx,
	output reg done_rx,
	output reg [`DATA_WIDTH-1:0] dout);
	
	localparam clk_count = clk_freq/baudrate;
	
	integer count=0;
	integer countbit=0;	// SV has int, verilog has integer
	
	reg uclk=0;		// = 0 was an issue in DRV. V.IMP
	
	enum bit {idle = 1'b0, receive = 1'b1} state;
		
	always@(posedge clk) begin
        if (count < clk_count/2) begin
			count <= count+1;
		end
		else begin
			count <= 0;
			uclk  <= !uclk;
		end
	end
	
	always@(posedge uclk) begin
		if(!reset) begin
			state	 <= idle;
			done_rx  <= 1'b0;
			countbit <= 0;
			dout	 <= 0;
		end
		
		else begin
			case(state)
				
				idle: begin
					countbit <= 0;
					dout	 <= 0;
					done_rx  <= 1'b0;
					
					if(rx==1'b0)	// start of Rx
						state <= receive;
					else
						state <= idle;
				end
			
				receive: begin
					if (countbit <= `DATA_WIDTH-1) begin
						dout 	 <= {rx,dout[7:1]};			// this data remains on dout even after done_rx goes 0->1->0
						 done_rx  <= 1'b0;
						 countbit <= countbit+1;
                      	 state	  <= receive;
					end
					else begin
						state  	 <= idle;
						done_rx  <= 1'b1;
						countbit <= 0;
					end
				end
			
				default: begin
					state 	 <= idle;
					done_rx  <= 1'b0;
					countbit <= 0;
					dout 	 <= 'b0;
				end
              
			 endcase
		end
	end
	
endmodule

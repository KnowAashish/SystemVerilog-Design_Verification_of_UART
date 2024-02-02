`define DATA_WIDTH 8

module uart_top;


endmodule

//////////////////////////////////////////////////////////////////////////////

module uart_tx #(parameter clk_freq = 1000000, baudrate = 9600)
				(input clk, reset,
				input newd,
				input [`DATA_WIDTH-1:0] din;
				output reg tx;	// Serial Transmission of 8-bit data
				output reg done_tx);
	
	localparam clk_count = (clk_freq/baudrate);	// No. of system clock (main clk) required to Tx 1-bit
	
	typedef enum bit (idle=1'b0, transfer=1'b1) state_type;	// FSM states
	state_type state = idle;	// default idle
	
	int count, countbit;
	
	reg uclk;	// UART's Internal Clock based on baudrate
	
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
	
	// Essentially, all operations inside UART Tx & Rx work as per uclk. As per TX, the data bit is loaded for the 1st high of uclk, which is of duration clk_count/2 and data bit remains constant for rest of clk_count/2.
	
	always@(posedge uclk) begin
		if(!reset) begin
			tx <= 1'b1;
			done_tx <= 1'b0;
			state <= idle;
		end
		else begin
			
			case(state)
			
				idle: begin
					if(newd) begin
						state <= transfer;
						tx <= 1'b0;
						countbit <= 0;
					end
					else
						state <= idle;
						tx <= 1'b1;
						countbit <= 0;
				end
				
				transfer: begin
					if(count<=7) begin
						
					end
				end
			
			endcase
		end
	end

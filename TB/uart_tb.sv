`define DATA_WIDTH 8

`include "uart_interface.sv"	// added
`include "uart_package.sv"
import uart_pkg::*;

module uart_tb;
  
    //import uart_pkg::*;	// import here or before module. Makes no difference
  
	intf intf_tb();
	
	// Instantiate DUT top
	uart_top #(1000000, 9600) DUT_TOP (.clk(intf_tb.clk), .reset(intf_tb.reset), .newd(intf_tb.newd), .din(intf_tb.din), .tx(intf_tb.tx), .done_tx(intf_tb.done_tx), .rx(intf_tb.rx), .dout(intf_tb.dout), .done_rx(intf_tb.done_rx));
  
  
	// Generate Global Clock
	always
		#5 intf_tb.clk <= !intf_tb.clk;
  
  // Connect uart_tx's and uart_rx's internal uclk with the interface via uart_top
	assign intf_tb.uclk_tx = DUT_TOP.DUT_TX.uclk;
	assign intf_tb.uclk_rx = DUT_TOP.DUT_RX.uclk;
  
	environment env;
	
	initial begin
		env = new(intf_tb);
		env.gen.no_of_packets=15;
		env.run();
	end
	
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars;
	end
  
endmodule
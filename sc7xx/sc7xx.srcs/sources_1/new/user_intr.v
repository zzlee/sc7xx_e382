`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2025 02:31:25 PM
// Design Name: 
// Module Name: user_intr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module user_intr #(
	parameter INTR_WIDTH = 8
) (
    // System Signals
    input ap_clk,      // Clock
    input ap_rst_n,    // Asynchronous Reset, active low

    // Interrupt Source
	input [INTR_WIDTH-1:0] intr,

	// User IRQ
	input  [INTR_WIDTH-1:0]     usr_irq_ack,
	output reg [INTR_WIDTH-1:0] usr_irq_req
);
	integer i;

	always @(posedge ap_clk or negedge ap_rst_n) begin
		if(! ap_rst_n) begin
			for(i = 0;i < INTR_WIDTH;i = i+1) begin
				usr_irq_req[i] <= 0;
			end
		end else begin
			for(i = 0;i < INTR_WIDTH;i = i+1) begin
				if(intr[i])
					usr_irq_req[i] <= 1;

				if(usr_irq_ack[i])
					usr_irq_req[i] <= 0;
			end
		end
	end

endmodule

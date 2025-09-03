`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2025 09:35:14 AM
// Design Name: 
// Module Name: generic_ctrl
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

module generic_ctrl #(
parameter
	C_S_AXI_ADDR_WIDTH = 5,
	C_S_AXI_DATA_WIDTH = 32
) (
	input clk,
	input rst_n,

	input  [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_ctrl_awaddr,
	input                             s_axi_ctrl_awvalid,
	output                            s_axi_ctrl_awready,
	input  [C_S_AXI_DATA_WIDTH-1:0]   s_axi_ctrl_wdata,
	input  [C_S_AXI_DATA_WIDTH/8-1:0] s_axi_ctrl_wstrb,
	input                             s_axi_ctrl_wvalid,
	output                            s_axi_ctrl_wready,
	output [1:0]                      s_axi_ctrl_bresp,
	output                            s_axi_ctrl_bvalid,
	input                             s_axi_ctrl_bready,
	input  [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_ctrl_araddr,
	input                             s_axi_ctrl_arvalid,
	output                            s_axi_ctrl_arready,
	output [C_S_AXI_DATA_WIDTH-1:0]   s_axi_ctrl_rdata,
	output [1:0]                      s_axi_ctrl_rresp,
	output                            s_axi_ctrl_rvalid,
	input                             s_axi_ctrl_rready,

	output wire                          interrupt,

	output wire                          ap_start,
	input  wire                          ap_done,
	input  wire                          ap_ready,
	input  wire                          ap_idle
);
//------------------------Address Info-------------------
// Protocol Used: ap_ctrl_hs
//
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read/COR)
//        bit 7  - auto_restart (Read/Write)
//        bit 9  - interrupt (Read)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0 - enable ap_done interrupt (Read/Write)
//        bit 1 - enable ap_ready interrupt (Read/Write)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0 - ap_done (Read/TOW)
//        bit 1 - ap_ready (Read/TOW)
//        others - reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
	ADDR_AP_CTRL          = 5'h00,
	ADDR_GIE              = 5'h04,
	ADDR_IER              = 5'h08,
	ADDR_ISR              = 5'h0c,
	WRIDLE                = 2'd0,
	WRDATA                = 2'd1,
	WRRESP                = 2'd2,
	WRRESET               = 2'd3,
	RDIDLE                = 2'd0,
	RDDATA                = 2'd1,
	RDRESET               = 2'd2,
	ADDR_BITS             = 5;

//------------------------Local signal-------------------
	wire                            ACLK_EN;
	wire                            ACLK;
	wire                            ARESET;
	wire [C_S_AXI_ADDR_WIDTH-1:0]   AWADDR;
	wire                            AWVALID;
	wire                            AWREADY;
	wire [C_S_AXI_DATA_WIDTH-1:0]   WDATA;
	wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB;
	wire                            WVALID;
	wire                            WREADY;
	wire [1:0]                      BRESP;
	wire                            BVALID;
	wire                            BREADY;
	wire [C_S_AXI_ADDR_WIDTH-1:0]   ARADDR;
	wire                            ARVALID;
	wire                            ARREADY;
	wire [C_S_AXI_DATA_WIDTH-1:0]   RDATA;
	wire [1:0]                      RRESP;
	wire                            RVALID;
	wire                            RREADY;

	reg  [1:0]                    wstate = WRRESET;
	reg  [1:0]                    wnext;
	reg  [ADDR_BITS-1:0]          waddr;
	wire [C_S_AXI_DATA_WIDTH-1:0] wmask;
	wire                          aw_hs;
	wire                          w_hs;
	reg  [1:0]                    rstate = RDRESET;
	reg  [1:0]                    rnext;
	reg  [C_S_AXI_DATA_WIDTH-1:0] rdata;
	wire                          ar_hs;
	wire [ADDR_BITS-1:0]          raddr;
	// internal registers
	reg                           int_ap_idle = 1'b0;
	reg                           int_ap_ready = 1'b0;
	wire                          task_ap_ready;
	reg                           int_ap_done = 1'b0;
	wire                          task_ap_done;
	reg                           int_task_ap_done = 1'b0;
	reg                           int_ap_start = 1'b0;
	reg                           int_interrupt = 1'b0;
	reg                           int_auto_restart = 1'b0;
	reg                           auto_restart_status = 1'b0;
	wire                          auto_restart_done;
	reg                           int_gie = 1'b0;
	reg  [1:0]                    int_ier = 2'b0;
	reg  [1:0]                    int_isr = 2'b0;

//------------------------Instantiation------------------
assign ACLK_EN = 1;
assign ACLK = clk;
assign ARESET = ~rst_n;
assign AWADDR = s_axi_ctrl_awaddr;
assign AWVALID = s_axi_ctrl_awvalid;
assign s_axi_ctrl_awready = AWREADY;
assign WDATA = s_axi_ctrl_wdata;
assign WSTRB = s_axi_ctrl_wstrb;
assign WVALID = s_axi_ctrl_wvalid;
assign s_axi_ctrl_wready = WREADY;
assign s_axi_ctrl_bresp = BRESP;
assign s_axi_ctrl_bvalid = BVALID;
assign BREADY = s_axi_ctrl_bready;
assign ARADDR = s_axi_ctrl_araddr;
assign ARVALID = s_axi_ctrl_arvalid;
assign s_axi_ctrl_arready = ARREADY;
assign s_axi_ctrl_rdata = RDATA;
assign s_axi_ctrl_rresp = RRESP;
assign s_axi_ctrl_rvalid = RVALID;
assign RREADY = s_axi_ctrl_rready;

//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BRESP   = 2'b00;  // OKAY
assign BVALID  = (wstate == WRRESP);
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
	if (ARESET)
		wstate <= WRRESET;
	else if (ACLK_EN)
		wstate <= wnext;
end

// wnext
always @(*) begin
	case (wstate)
		WRIDLE:
			if (AWVALID)
				wnext = WRDATA;
			else
				wnext = WRIDLE;
		WRDATA:
			if (WVALID)
				wnext = WRRESP;
			else
				wnext = WRDATA;
		WRRESP:
			if (BREADY)
				wnext = WRIDLE;
			else
				wnext = WRRESP;
		default:
			wnext = WRIDLE;
	endcase
end

// waddr
always @(posedge ACLK) begin
	if (ACLK_EN) begin
		if (aw_hs)
			waddr <= {AWADDR[ADDR_BITS-1:2], {2{1'b0}}};
	end
end

//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA);
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
	if (ARESET)
		rstate <= RDRESET;
	else if (ACLK_EN)
		rstate <= rnext;
end

// rnext
always @(*) begin
	case (rstate)
		RDIDLE:
			if (ARVALID)
				rnext = RDDATA;
			else
				rnext = RDIDLE;
		RDDATA:
			if (RREADY & RVALID)
				rnext = RDIDLE;
			else
				rnext = RDDATA;
		default:
			rnext = RDIDLE;
	endcase
end

// rdata
always @(posedge ACLK) begin
	if (ACLK_EN) begin
		if (ar_hs) begin
			rdata <= 'b0;
			case (raddr)
				ADDR_AP_CTRL: begin
					rdata[0] <= int_ap_start;
					rdata[1] <= int_task_ap_done;
					rdata[2] <= int_ap_idle;
					rdata[3] <= int_ap_ready;
					rdata[7] <= int_auto_restart;
					rdata[9] <= int_interrupt;
				end
				ADDR_GIE: begin
					rdata <= int_gie;
				end
				ADDR_IER: begin
					rdata <= int_ier;
				end
				ADDR_ISR: begin
					rdata <= int_isr;
				end
			endcase
		end
	end
end


//------------------------Register logic-----------------
assign interrupt         = int_interrupt;
assign ap_start          = int_ap_start;
assign task_ap_done      = (ap_done && !auto_restart_status) || auto_restart_done;
assign task_ap_ready     = ap_ready && !int_auto_restart;
assign auto_restart_done = auto_restart_status && (ap_idle && !int_ap_idle);

// int_interrupt
always @(posedge ACLK) begin
	if (ARESET)
		int_interrupt <= 1'b0;
	else if (ACLK_EN) begin
		if (int_gie && (|int_isr))
			int_interrupt <= 1'b1;
		else
			int_interrupt <= 1'b0;
	end
end

// int_ap_start
always @(posedge ACLK) begin
	if (ARESET)
		int_ap_start <= 1'b0;
	else if (ACLK_EN) begin
		if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0] && WDATA[0])
			int_ap_start <= 1'b1;
		else if (ap_ready)
			int_ap_start <= int_auto_restart; // clear on handshake/auto restart
	end
end

// int_ap_done
always @(posedge ACLK) begin
	if (ARESET)
		int_ap_done <= 1'b0;
	else if (ACLK_EN) begin
			int_ap_done <= ap_done;
	end
end

// int_task_ap_done
always @(posedge ACLK) begin
	if (ARESET)
		int_task_ap_done <= 1'b0;
	else if (ACLK_EN) begin
		if (task_ap_done)
			int_task_ap_done <= 1'b1;
		else if (ar_hs && raddr == ADDR_AP_CTRL)
			int_task_ap_done <= 1'b0; // clear on read
	end
end

// int_ap_idle
always @(posedge ACLK) begin
	if (ARESET)
		int_ap_idle <= 1'b0;
	else if (ACLK_EN) begin
			int_ap_idle <= ap_idle;
	end
end

// int_ap_ready
always @(posedge ACLK) begin
	if (ARESET)
		int_ap_ready <= 1'b0;
	else if (ACLK_EN) begin
		if (task_ap_ready)
			int_ap_ready <= 1'b1;
		else if (ar_hs && raddr == ADDR_AP_CTRL)
			int_ap_ready <= 1'b0;
	end
end

// int_auto_restart
always @(posedge ACLK) begin
	if (ARESET)
		int_auto_restart <= 1'b0;
	else if (ACLK_EN) begin
		if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0])
			int_auto_restart <= WDATA[7];
	end
end

// auto_restart_status
always @(posedge ACLK) begin
	if (ARESET)
		auto_restart_status <= 1'b0;
	else if (ACLK_EN) begin
		if (int_auto_restart)
			auto_restart_status <= 1'b1;
		else if (ap_idle)
			auto_restart_status <= 1'b0;
	end
end

// int_gie
always @(posedge ACLK) begin
	if (ARESET)
		int_gie <= 1'b0;
	else if (ACLK_EN) begin
		if (w_hs && waddr == ADDR_GIE && WSTRB[0])
			int_gie <= WDATA[0];
	end
end

// int_ier
always @(posedge ACLK) begin
	if (ARESET)
		int_ier <= 1'b0;
	else if (ACLK_EN) begin
		if (w_hs && waddr == ADDR_IER && WSTRB[0])
			int_ier <= WDATA[1:0];
	end
end

// int_isr[0]
always @(posedge ACLK) begin
	if (ARESET)
		int_isr[0] <= 1'b0;
	else if (ACLK_EN) begin
		if (int_ier[0] & ap_done)
			int_isr[0] <= 1'b1;
		else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
			int_isr[0] <= int_isr[0] ^ WDATA[0]; // toggle on write
	end
end

// int_isr[1]
always @(posedge ACLK) begin
	if (ARESET)
		int_isr[1] <= 1'b0;
	else if (ACLK_EN) begin
		if (int_ier[1] & ap_ready)
			int_isr[1] <= 1'b1;
		else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
			int_isr[1] <= int_isr[1] ^ WDATA[1]; // toggle on write
	end
end

//synthesis translate_off
always @(posedge ACLK) begin
	if (ACLK_EN) begin
		if (int_gie & ~int_isr[0] & int_ier[0] & ap_done)
			$display ("// Interrupt Monitor : interrupt for ap_done detected @ \"%0t\"", $time);
		if (int_gie & ~int_isr[1] & int_ier[1] & ap_ready)
			$display ("// Interrupt Monitor : interrupt for ap_ready detected @ \"%0t\"", $time);
	end
end
//synthesis translate_on

//------------------------Memory logic-------------------

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 05/01/2025 02:34:07 PM
// Design Name:
// Module Name: sc7xx_top
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


module sc7xx_top(
	input [0:0]  pcie_clk_clk_n,
	input [0:0]  pcie_clk_clk_p,
	input [3:0]  pcie_mgt_rxn,
	input [3:0]  pcie_mgt_rxp,
	output [3:0] pcie_mgt_txn,
	output [3:0] pcie_mgt_txp,
	input        pcie_rst_n
);

	sc7xx_wrapper sc7xx_wrapper(
		.pcie_clk_clk_n(pcie_clk_clk_n),
		.pcie_clk_clk_p(pcie_clk_clk_p),
		.pcie_mgt_rxn(pcie_mgt_rxn),
		.pcie_mgt_rxp(pcie_mgt_rxp),
		.pcie_mgt_txn(pcie_mgt_txn),
		.pcie_mgt_txp(pcie_mgt_txp),
		.pcie_rst_n(pcie_rst_n)
	);

endmodule

#set_property PACKAGE_PIN T14 [get_ports OSC_27MHz]
#set_property IOSTANDARD LVCMOS33 [get_ports OSC_27MHz]

set_false_path -from [get_ports pcie_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports pcie_rst_n]
set_property PULLUP true [get_ports pcie_rst_n]
set_property PACKAGE_PIN V11 [get_ports pcie_rst_n]

#set_property IOSTANDARD LVDS [ get_ports "PCIE_clk_p" ]
set_property PACKAGE_PIN D6 [get_ports pcie_clk_clk_p]
set_property PACKAGE_PIN D5 [get_ports pcie_clk_clk_n]
#set_property IOSTANDARD LVDS [ get_ports "PCIE_clk_n" ]

# 100M
create_clock -period 10.000 -name PCIE_CLOCK [get_ports pcie_clk_clk_p]

# 125M
#create_clock -period 8.000 -name PCIE_CLOCK [get_ports PCIE_clk_p]

#set_property LOC GTPE2_CHANNEL_X0Y3 [get_cells {mb_sys_i/mb_sys_i/xdma_0/inst/mb_sys_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN G3 [get_ports {pcie_mgt_rxn[0]}]
set_property PACKAGE_PIN G4 [get_ports {pcie_mgt_rxp[0]}]
set_property PACKAGE_PIN B1 [get_ports {pcie_mgt_txn[0]}]
set_property PACKAGE_PIN B2 [get_ports {pcie_mgt_txp[0]}]

#set_property LOC GTPE2_CHANNEL_X0Y2 [get_cells {mb_sys_i/mb_sys_i/xdma_0/inst/mb_sys_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN C3 [get_ports {pcie_mgt_rxn[1]}]
set_property PACKAGE_PIN C4 [get_ports {pcie_mgt_rxp[1]}]
set_property PACKAGE_PIN D1 [get_ports {pcie_mgt_txn[1]}]
set_property PACKAGE_PIN D2 [get_ports {pcie_mgt_txp[1]}]

#set_property LOC GTPE2_CHANNEL_X0Y1 [get_cells {mb_sys_i/mb_sys_i/xdma_0/inst/mb_sys_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN A3 [get_ports {pcie_mgt_rxn[2]}]
set_property PACKAGE_PIN A4 [get_ports {pcie_mgt_rxp[2]}]
set_property PACKAGE_PIN F1 [get_ports {pcie_mgt_txn[2]}]
set_property PACKAGE_PIN F2 [get_ports {pcie_mgt_txp[2]}]

#set_property LOC GTPE2_CHANNEL_X0Y0 [get_cells {mb_sys_i/mb_sys_i/xdma_0/inst/mb_sys_xdma_0_0_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]
set_property PACKAGE_PIN E3 [get_ports {pcie_mgt_rxn[3]}]
set_property PACKAGE_PIN E4 [get_ports {pcie_mgt_rxp[3]}]
set_property PACKAGE_PIN H1 [get_ports {pcie_mgt_txn[3]}]
set_property PACKAGE_PIN H2 [get_ports {pcie_mgt_txp[3]}]

set_property BITSTREAM.CONFIG.CONFIGRATE 40 [current_design]

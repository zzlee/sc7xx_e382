# sc7xx FPGA Project

This project is a Xilinx Vivado FPGA design for the sc7xx platform. The design utilizes a PCIe interface for communication with a host system and incorporates AXI-Stream for high-speed data handling.

## Project Overview

The design is built around a Xilinx Artix-7 FPGA (xc7a50tcsg325-2). It includes a PCIe Gen2 x4 interface, AXI-Stream data paths, and various control and status registers accessible via an AXI-Lite interface.

### Key Features

*   PCIe Gen2 x4 interface using the Xilinx DMA for PCIe (XDMA) IP core.
*   AXI-Stream interfaces for data input and output.
*   AXI-Lite interface for control and status registers.
*   Custom Verilog modules for data generation, sinking, and interrupt handling.

## Getting Started

### Prerequisites

*   Xilinx Vivado 2024.2

### Building the Project

1.  **Launch Vivado:** Open the Vivado IDE.
2.  **Open the Tcl Console:** In Vivado, select `Tools -> Tcl Console`.
3.  **Recreate the Project:** In the Tcl Console, navigate to the project directory and source the `sc7xx.tcl` script to recreate the project.

    ```tcl
    cd /path/to/sc7xx_e382
    source sc7xx.tcl
    ```

4.  **Generate Bitstream:** After the project is created, click on "Generate Bitstream" in the Flow Navigator to synthesize, implement, and generate the bitstream file.

## Project Structure

The project is organized as follows:

*   `sc7xx.tcl`: Tcl script to recreate the Vivado project.
*   `sc7xx/`: Directory containing the Vivado project files.
    *   `sc7xx.xpr`: Vivado project file.
    *   `sc7xx.srcs/`: Directory for source files (Verilog, constraints).
    *   `sc7xx.runs/`: Directory for synthesis and implementation runs.
    *   `sc7xx.gen/`: Directory for generated files.


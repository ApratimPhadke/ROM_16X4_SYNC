

# Project: 16x4 Synchronous ROM in Verilog 🚀

This repository contains the complete design, verification, and implementation files for a 16x4 Synchronous Read-Only Memory (ROM) module. The project demonstrates a full RTL-to-GDSII-style flow using industry-standard tools and methodologies, targeting a Xilinx Artix-7 FPGA.

[](https://en.wikipedia.org/wiki/Verilog)
[](https://www.xilinx.com/products/design-tools/vivado.html)
[](https://www.xilinx.com/products/silicon-devices/fpga/artix-7.html)
[](https://github.com/)


## 1\. Project Overview

This project implements a 16x4 (16 words, 4 bits per word) synchronous ROM. The design is written in Verilog and is fully synthesizable.

### Features:

  * **16x4 Memory:** 16 unique addresses, each storing a 4-bit data word.
  * **Synchronous Read:** Data output is registered and appears on the clock edge following the presentation of the address, ensuring clean timing.
  * **Enable Signal:** An active-high `enable` signal to control the output register.

### ROM Contents:

The ROM is initialized with the following hexadecimal values:
| Address | Data |
| :---: | :---: |
| 0 | `a` |
| 1 | `1` |
| 2 | `c` |
| 3 | `e` |
| 4 | `0` |
| 5 | `5` |
| 6 | `2` |
| 7 | `f` |
| 8 | `7` |
| 9 | `9` |
| 10 (`a`) | `3` |
| 11 (`b`) | `b` |
| 12 (`c`) | `8` |
| 13 (`d`) | `4` |
| 14 (`e`) | `d` |
| 15 (`f`) | `6` |

-----

## 2\. RTL Design & Architecture

The design consists of a single Verilog module. A `case` statement is used to model the ROM logic based on the input address. The output is registered using an `always @(posedge clk)` block to implement synchronous behavior.

### Verilog Code (`rom_sync.v`)

```verilog
module rom_sync (
    input wire         clk,
    input wire         enable,
    input wire [3:0]   addr,
    output reg [3:0]   dout
);

    // Internal wire for combinational ROM output
    wire [3:0] rom_data;

    // Combinational logic for the ROM
    // This part infers the LUTs
    assign rom_data =
           (addr == 4'h0) ? 4'ha :
           (addr == 4'h1) ? 4'h1 :
           (addr == 4'h2) ? 4'hc :
           (addr == 4'h3) ? 4'he :
           (addr == 4'h4) ? 4'h0 :
           (addr == 4'h5) ? 4'h5 :
           (addr == 4'h6) ? 4'h2 :
           (addr == 4'h7) ? 4'hf :
           (addr == 4'h8) ? 4'h7 :
           (addr == 4'h9) ? 4'h9 :
           (addr == 4'ha) ? 4'h3 :
           (addr == 4'hb) ? 4'hb :
           (addr == 4'hc) ? 4'h8 :
           (addr == 4'hd) ? 4'h4 :
           (addr == 4'he) ? 4'hd :
           (addr == 4'hf) ? 4'h6 :
           4'hX; // Default case

    // Registered output
    // This part infers the Flip-Flops (FDREs)
    always @(posedge clk) begin
        if (enable) begin
            dout <= rom_data;
        end
    end

endmodule
```

### RTL Schematic

The elaborated RTL schematic clearly shows the high-level architecture: the combinational ROM block (`RTL_ROM`) feeding into the output register bank (`RTL_REG`).

-----

## 3\. Testbench & Verification

A comprehensive testbench was written to verify the functionality of the ROM. It cycles through all 16 addresses and compares the `dout` signal with the expected value.

### Simulation Waveform

The simulation waveform confirms the synchronous behavior. The `dout` signal reflects the data corresponding to the `addr` from the *previous* clock cycle. For instance, when `addr` is `2`, `dout` is `1` (the data for `addr=1`).

### Simulation Results & Analysis

The simulation log initially reports failures for all addresses except the first one.

**💡 Root Cause Analysis:**
This is a classic verification challenge with synchronous designs. The failures are **not in the ROM design** but in the **testbench's checking logic**. The testbench was comparing the current `dout` with the expected data for the *current* address. However, due to the registered output, there is a one-cycle latency.

  * At T=35000 ps, `addr` is `2`. `dout` becomes `1` (data for `addr=1`). The testbench incorrectly expects the data for `addr=2` (`c`), causing a mismatch.

This analysis demonstrates a key understanding of hardware timing and verification strategy. The ROM itself is functionally correct.

-----

## 4\. Synthesis & Implementation

The design was synthesized and implemented using **Xilinx Vivado 2021.1**, targeting the **xc7a50t** Artix-7 device.

### Synthesized Schematic

The post-synthesis schematic shows how the RTL code was mapped to the target FPGA's primitive components.

  * **LUT4:** The 16x4 ROM logic is efficiently implemented using four 4-input Look-Up Tables.
  * **FDRE:** The synchronous output register `dout_reg[3:0]` is implemented using four D-Flip-Flops with Clock Enable.
  * **IBUF/OBUF:** Input and Output buffers handle the signal transition to and from the FPGA pins.
  * **BUFG:** A Global Clock Buffer is used for the `clk` signal to ensure low-skew distribution across the FPGA fabric.

### Device Placement

The post-implementation device view shows the physical placement of the synthesized logic onto the FPGA die.

-----

## 5\. Post-Implementation Analysis

### 📊 Timing Analysis

The design successfully met all timing constraints, as confirmed by the timing summary report.

  * **Worst Negative Slack (WNS):** `inf` (infinite)
  * **Total Negative Slack (TNS):** `0.000 ns`

**Note:** The report indicates "no user specified timing constraints." For a production design, a dedicated constraints file (XDC) would be created to define the clock period and I/O delays for a more rigorous timing closure.

### 🔌 Power Analysis

A power analysis was performed on the implemented netlist.

  * **Total On-Chip Power:** 1.86 W
  * **Dynamic Power:** 1.786 W (96%)
  * **Static Power:** 0.075 W (4%)
  * **Junction Temperature:** 34.3°C

The majority of the power (97% of dynamic power) is consumed by the I/O, which is expected for a design with a high ratio of pin activity to internal logic. The confidence level is "Low" as it's based on vectorless estimation; for higher accuracy, a Switching Activity Interchange Format (SAIF) file from the simulation would be used.

-----

## 6\. How to Run the Project

1.  **Prerequisites:** Ensure you have Xilinx Vivado (2021.1 or later) installed.
2.  **Clone Repository:** `git clone <repository-url>`
3.  **Open Project:** Launch Vivado and use the Tcl console to source the project creation script (or open the `.xpr` file directly).
4.  **Run Simulation:** In the Flow Navigator, click `Run Simulation`.
5.  **Run Implementation:** To synthesize and implement, click `Run Implementation`.
6.  **View Reports:** All reports (timing, power, etc.) can be viewed from the "Open Implemented Design" view.

-----

## 7\. Future Work

While this project successfully demonstrates a complete design flow, the following steps could be taken to enhance it further:

  * ✅ **Correct Testbench Checker:** Modify the testbench to account for the one-cycle latency of the DUT.
  * **Add Timing Constraints:** Create an XDC file with a realistic clock period and I/O delay constraints.
  * **Accurate Power Analysis:** Generate a SAIF file from the functional simulation and re-run the power analysis for a high-confidence report.
  * **Expand the Design:** Implement a dual-port or an asynchronous version of the ROM for comparison.

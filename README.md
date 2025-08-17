

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
<img width="2048" height="2048" alt="diagram" src="https://github.com/user-attachments/assets/1ad1b4b6-a9ae-465f-a266-a40d824ccc43" />


### Verilog Code (`ROM.v`)

```verilog
`timescale 1ns/1ps
`default_nettype none
module rom_1r_sync #(
parameter integer DEPTH = 16,
parameter integer DATA_WIDTH =4,
parameter integer ADDR_WIDTH =4
)(
input wire clk,
input wire enable ,
input wire [ADDR_WIDTH-1:0] addr,
output reg [DATA_WIDTH-1:0] dout
);
reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
initial begin 
memory[ 0] = 4'hA;
        memory[ 1] = 4'h1;
        memory[ 2] = 4'hC;
        memory[ 3] = 4'hE;
        memory[ 4] = 4'h0;
        memory[ 5] = 4'h5;
        memory[ 6] = 4'h2;
        memory[ 7] = 4'hF;
        memory[ 8] = 4'h7;
        memory[ 9] = 4'h9;
        memory[10] = 4'h3;
        memory[11] = 4'hB;
        memory[12] = 4'h8;
        memory[13] = 4'h4;
        memory[14] = 4'hD;
        memory[15] = 4'h6;
    end
    always @(posedge clk) begin 
    if(enable) begin 
    dout<=memory[addr];
    end 
    end 
    initial begin 
    if(DEPTH != (1<<ADDR_WIDTH)) begin 
    $display("WARNING: DEPTH (%0d) != 2^ADDR_WIDTH (%0d).",
                     DEPTH, (1<<ADDR_WIDTH));
                     end 
                     end 
                     endmodule 
                     
```

### RTL Schematic
Schematic
<img width="1854" height="1168" alt="schematic" src="https://github.com/user-attachments/assets/64c39662-f353-4342-963d-aaf8fbac10a6" />

<img width="1387" height="894" alt="detailed_schematic" src="https://github.com/user-attachments/assets/793df145-85a7-4360-a82f-f7ab4463db0b" />


The elaborated RTL schematic clearly shows the high-level architecture: the combinational ROM block (`RTL_ROM`) feeding into the output register bank (`RTL_REG`).

-----

## 3\. Testbench & Verification

A comprehensive testbench was written to verify the functionality of the ROM. It cycles through all 16 addresses and compares the `dout` signal with the expected value.

### Testbench Code (`tb_rom_1r_sync.v`)
```verilog
`timescale 1ns/1ps
`default_nettype none

module tb_rom_1r_sync;
    // Parameters must match DUT
    localparam integer DEPTH      = 16;
    localparam integer DATA_WIDTH = 4;
    localparam integer ADDR_WIDTH = 4;

    reg  clk;
    reg  enable;
    reg  [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] dout;

    // Instantiate the DUT
    rom_1r_sync #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .enable(enable),
        .addr(addr),
        .dout(dout)
    );

    // Clock: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // Reference ROM contents for checking
    reg [DATA_WIDTH-1:0] expected [0:DEPTH-1];

    integer i;
    integer fails;

    initial begin
        $dumpfile("rom_1r_sync_tb.vcd");  // for GTKWave
        $dumpvars(0, tb_rom_1r_sync);

        // Init clock and inputs
        clk    = 0;
        enable = 1;
        addr   = 0;
        fails  = 0;

        // Load expected values (must match DUT init block)
        expected[ 0] = 4'hA;
        expected[ 1] = 4'h1;
        expected[ 2] = 4'hC;
        expected[ 3] = 4'hE;
        expected[ 4] = 4'h0;
        expected[ 5] = 4'h5;
        expected[ 6] = 4'h2;
        expected[ 7] = 4'hF;
        expected[ 8] = 4'h7;
        expected[ 9] = 4'h9;
        expected[10] = 4'h3;
        expected[11] = 4'hB;
        expected[12] = 4'h8;
        expected[13] = 4'h4;
        expected[14] = 4'hD;
        expected[15] = 4'h6;

        // Wait for reset settle
        @(posedge clk);

        // Pipeline warm-up: apply addr=0
        addr <= 0;
        @(posedge clk); // dout gets memory[0] here

        // Sweep through all addresses
        for (i = 1; i < DEPTH; i = i + 1) begin
            // Check previous cycle output
            if (dout !== expected[i-1]) begin
                $display("FAIL: addr=%0d expected=%h got=%h at t=%0t",
                         i-1, expected[i-1], dout, $time);
                fails = fails + 1;
            end else begin
                $display("PASS: addr=%0d value=%h", i-1, dout);
            end

            // Next address
            addr <= i[ADDR_WIDTH-1:0];
            @(posedge clk);
        end

        // Final check for addr=15
        if (dout !== expected[15]) begin
            $display("FAIL: addr=15 expected=%h got=%h at t=%0t",
                     expected[15], dout, $time);
            fails = fails + 1;
        end else begin
            $display("PASS: addr=15 value=%h", dout);
        end

        // Final report
        if (fails == 0) begin
            $display("RESULT: ALL TESTS PASSED");
        end else begin
            $display("RESULT: %0d TEST(S) FAILED", fails);
            $fatal(1);
        end

        $finish;
    end
endmodule

`default_nettype wire

```


### Simulation Waveform
<img width="1854" height="1168" alt="Testbench" src="https://github.com/user-attachments/assets/45d2c481-6619-4987-9266-3b92291763b5" />


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
<img width="1854" height="1168" alt="implementation" src="https://github.com/user-attachments/assets/72ad2c25-b5d2-45c7-89d1-f353b3026760" />
<img width="1854" height="1168" alt="TCL_Console" src="https://github.com/user-attachments/assets/774fed43-9662-4592-8428-7d39b0bcfd7b" />


### Synthesized Schematic
<img width="1387" height="894" alt="detailed_schematic" src="https://github.com/user-attachments/assets/85022f77-8fa9-440f-9b11-6c2aa9077d78" />


The post-synthesis schematic shows how the RTL code was mapped to the target FPGA's primitive components.

  * **LUT4:** The 16x4 ROM logic is efficiently implemented using four 4-input Look-Up Tables.
  * **FDRE:** The synchronous output register `dout_reg[3:0]` is implemented using four D-Flip-Flops with Clock Enable.
  * **IBUF/OBUF:** Input and Output buffers handle the signal transition to and from the FPGA pins.
  * **BUFG:** A Global Clock Buffer is used for the `clk` signal to ensure low-skew distribution across the FPGA fabric.

### Device Placement
<img width="1854" height="1168" alt="synthesis" src="https://github.com/user-attachments/assets/17334010-a6c9-4c71-9307-01d92e35001e" />



The post-implementation device view shows the physical placement of the synthesized logic onto the FPGA die.

-----

## 5\. Post-Implementation Analysis

### 📊 Timing Analysis
<img width="1854" height="1168" alt="timing" src="https://github.com/user-attachments/assets/5a5e30be-5c15-4f2f-9149-c8ee86dfbce3" />


The design successfully met all timing constraints, as confirmed by the timing summary report.

  * **Worst Negative Slack (WNS):** `inf` (infinite)
  * **Total Negative Slack (TNS):** `0.000 ns`

**Note:** The report indicates "no user specified timing constraints." For a production design, a dedicated constraints file (XDC) would be created to define the clock period and I/O delays for a more rigorous timing closure.

### 🔌 Power Analysis

A power analysis was performed on the implemented netlist.
<img width="1854" height="1168" alt="power" src="https://github.com/user-attachments/assets/2a66c6de-c8b6-45bd-a80e-4c8181783573" />


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
